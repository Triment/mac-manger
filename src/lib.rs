pub mod templates;
pub mod handlers;
use bb8::Pool;
use bb8_postgres::PostgresConnectionManager;
use tokio_postgres::NoTls;

use crate::templates::Templates;
use std::sync::Arc;

#[derive(Clone)]
pub struct AppState {
    pub templates: Arc<Templates>,
    pub pool: Pool<PostgresConnectionManager<NoTls>>,
}