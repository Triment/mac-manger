use std::sync::LazyLock;

use axum::{routing::{get, post}, Extension, Json, Router};
use regex::Regex;
use serde::Deserialize;
use sqlx::PgPool;
use validator::Validate;

pub fn router() -> Router {
    Router::new()
        .route("/v1/accounts", post(handler_accounts))
}
static USERNAME_REGEX: LazyLock<Regex> = LazyLock::new(|| Regex::new(r"^[0-9A-Za-z_]+$").unwrap());
#[derive(Deserialize, Validate)]
#[serde(rename_all = "camelCase")]
pub struct AccountAuth {
    #[validate(length(min = 3, max = 16), regex(path = USERNAME_REGEX))]
    username: String,
    #[validate(length(min = 8, max = 32))]
    password: String,
}

async fn handler_accounts(_db: Extension<PgPool>, Json(_req): Json<AccountAuth>) -> &'static str {
    "hello world"
}

// async fn json_body()