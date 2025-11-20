use tauri::{
    plugin::{Builder, TauriPlugin},
    Manager, Runtime,
};

pub use models::*;

#[cfg(desktop)]
mod desktop;
#[cfg(mobile)]
mod mobile;

mod commands;
mod error;
mod models;

pub use error::{Error, Result};

#[cfg(desktop)]
use desktop::Duckdb;
#[cfg(mobile)]
use mobile::Duckdb;

/// Extensions to [`tauri::App`], [`tauri::AppHandle`] and [`tauri::Window`] to access the duckdb APIs.
pub trait DuckdbExt<R: Runtime> {
    fn duckdb(&self) -> &Duckdb<R>;
}

impl<R: Runtime, T: Manager<R>> crate::DuckdbExt<R> for T {
    fn duckdb(&self) -> &Duckdb<R> {
        self.state::<Duckdb<R>>().inner()
    }
}

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("duckdb")
        .invoke_handler(tauri::generate_handler![
            commands::ping,
            commands::execute,
            commands::query
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let duckdb = mobile::init(app, api)?;
            #[cfg(desktop)]
            let duckdb = desktop::init(app, api)?;
            app.manage(duckdb);
            Ok(())
        })
        .build()
}
