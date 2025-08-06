use axum::{Extension, Router};
use sqlx::PgPool;
mod admin;
pub fn app(db: PgPool) -> Router {
    Router::new()
        .merge(admin::router())
        .layer(Extension(db))
}