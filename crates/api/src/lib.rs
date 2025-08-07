pub mod templates;
use axum::{Extension, Router};
use sqlx::PgPool;

use crate::templates::Templates;
use std::sync::Arc;

#[derive(Clone)]
pub struct AppState {
    pub templates: Arc<Templates>,
    pub pool: PgPool,
}

 pub fn app(pool: PgPool) -> Router {
    let templates = Arc::new(Templates::default());
    Router::new()
        .merge(
            Router::new()
                .route("/", axum::routing::get(async move || {
                    let templates = templates.clone();
                    match templates.render_home() {
                        Ok(html) => axum::response::Html(html),
                        Err(e) => axum::response::Html(format!("Error rendering template: {}", e)),
                    }
                })),
        ).layer(Extension(pool))
 }