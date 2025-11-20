use tauri::{command, AppHandle, Runtime};

use crate::models::*;
use crate::DuckdbExt;
use crate::Result;

#[command]
pub(crate) async fn ping<R: Runtime>(
    app: AppHandle<R>,
    payload: PingRequest,
) -> Result<PingResponse> {
    app.duckdb().ping(payload)
}

#[command]
pub(crate) async fn execute<R: Runtime>(
    app: AppHandle<R>,
    payload: ExecuteRequest,
) -> Result<ExecuteResponse> {
    app.duckdb().execute(payload)
}

#[command]
pub(crate) async fn query<R: Runtime>(
    app: AppHandle<R>,
    payload: QueryRequest,
) -> Result<QueryResponse> {
    app.duckdb().query(payload)
}
