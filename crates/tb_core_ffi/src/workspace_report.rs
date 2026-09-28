//! Token usage grouped by workspace and model for the native treemap.

use serde::Serialize;
use serde_json::Value;
use std::collections::BTreeMap;

#[derive(Default)]
struct Workspace {
    label: String,
    tokens: i64,
    models: BTreeMap<String, i64>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct WorkspaceRow {
    key: String,
    label: String,
    tokens: i64,
    models: Vec<ModelRow>,
}

#[derive(Serialize)]
struct ModelRow {
    name: String,
    tokens: i64,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct WorkspaceReport {
    total_tokens: i64,
    workspaces: Vec<WorkspaceRow>,
}

pub(crate) fn run(
    context: &crate::LocalSourceContext,
    year: &str,
    clients: Option<Vec<String>>,
) -> Result<Value, String> {
    let year = if year.is_empty() {
        None
    } else if year.len() == 4 && year.bytes().all(|b| b.is_ascii_digit()) {
        Some(year.to_owned())
    } else {
        return Err("invalid year filter".to_owned());
    };
    let mut options = context.report_options(year, clients);
    options.group_by = tokscale_core::GroupBy::WorkspaceModel;
    let runtime = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .map_err(|e| format!("build runtime: {e}"))?;
    let report = runtime.block_on(tokscale_core::get_model_report(options))?;
    // Some clients store a real workspace path while others encode the same
    // path for a session directory. Merge only exact encoded/path matches.
    let path_keys: BTreeMap<String, String> = report
        .entries
        .iter()
        .filter_map(|entry| entry.workspace_key.as_ref())
        .filter(|key| key.starts_with('/'))
        .map(|key| (key.replace('/', "-"), key.clone()))
        .collect();
    let mut grouped: BTreeMap<String, Workspace> = BTreeMap::new();
    for entry in report.entries {
        let original_key = entry.workspace_key.unwrap_or_else(|| "unknown".to_owned());
        let key = path_keys
            .get(&original_key)
            .cloned()
            .unwrap_or(original_key);
        let mut label = entry
            .workspace_label
            .unwrap_or_else(|| "Unknown project".to_owned());
        if key.starts_with('/') {
            if let Some(name) = std::path::Path::new(&key)
                .file_name()
                .and_then(|name| name.to_str())
            {
                label = name.to_owned();
            }
        }
        let tokens = entry
            .input
            .saturating_add(entry.output)
            .saturating_add(entry.cache_read)
            .saturating_add(entry.cache_write)
            .saturating_add(entry.reasoning);
        if tokens <= 0 {
            continue;
        }
        let workspace = grouped.entry(key).or_default();
        workspace.label = label;
        workspace.tokens = workspace.tokens.saturating_add(tokens);
        let model = workspace.models.entry(entry.model).or_default();
        *model = model.saturating_add(tokens);
    }
    let mut total_tokens = 0_i64;
    let mut workspaces = Vec::with_capacity(grouped.len());
    for (key, workspace) in grouped {
        total_tokens = total_tokens.saturating_add(workspace.tokens);
        let mut models: Vec<_> = workspace
            .models
            .into_iter()
            .map(|(name, tokens)| ModelRow { name, tokens })
            .collect();
        models.sort_by(|a, b| b.tokens.cmp(&a.tokens).then(a.name.cmp(&b.name)));
        workspaces.push(WorkspaceRow {
            key,
            label: workspace.label,
            tokens: workspace.tokens,
            models,
        });
    }
    workspaces.sort_by(|a, b| b.tokens.cmp(&a.tokens).then(a.label.cmp(&b.label)));
    serde_json::to_value(WorkspaceReport {
        total_tokens,
        workspaces,
    })
    .map_err(|e| format!("serialize workspace report: {e}"))
}
