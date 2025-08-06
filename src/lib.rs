pub mod templates;
pub mod handlers;
use sqlx::PgPool;

use crate::templates::Templates;
use std::sync::Arc;

#[derive(Clone)]
pub struct AppState {
    pub templates: Arc<Templates>,
    pub pool: PgPool,
}