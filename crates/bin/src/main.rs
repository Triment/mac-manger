use axum::{
    extract::{FromRequestParts, State},
    http::{request::Parts, StatusCode},
    response::{Html, IntoResponse, Response},
    routing::{get, post},
    Json, RequestPartsExt, Router,
};
use sqlx::postgres::PgPoolOptions;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(dotenvy::var("DATABASE_URL")?.as_str())
        .await?;
    sqlx::migrate!().run(&pool).await?;
    let app = api::app(pool);

    let addr = "127.0.0.1:3000";
    println!("listening on http://{}", addr);

    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000").await?;
    axum::serve(listener, app).await?;
    Ok(())
}

// async fn handler_home(State(state): State<std::sync::Arc<AppState>>) -> Result<Html<String>, StatusCode> {
//     let rendered = state.templates.render_home().unwrap();
//     let conn = state.pool.get().await.map_err(internal_error).unwrap();
//     let row = conn
//         .query_one("select 1 + 1", &[])
//         .await
//         .map_err(internal_error).unwrap();
//     let two: i32 = row.try_get(0).map_err(internal_error).unwrap();
//     println!("{}", two);
//     Ok(Html(rendered))
// }

// fn internal_error<E>(err: E) -> (StatusCode, String)
// where
//     E: std::error::Error,
// {
//     (StatusCode::INTERNAL_SERVER_ERROR, err.to_string())
// }