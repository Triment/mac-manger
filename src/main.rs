use axum::{
    extract::{FromRequestParts, State},
    http::{request::Parts, StatusCode},
    response::{Html, IntoResponse, Response},
    routing::{get, post},
    Json, RequestPartsExt, Router,
};
use std::sync::Arc;
use minijinja::Environment;
use mac_mange::AppState;
use mac_mange::templates::Templates;
use bb8::{Pool, PooledConnection};
use bb8_postgres::PostgresConnectionManager;
use tokio_postgres::NoTls;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let manager =
        PostgresConnectionManager::new_from_stringlike("host=reqack.com user=postgres password=admin@cd123 dbname=postgres", NoTls)
            ?;
    let pool = Pool::builder().build(manager).await?;
    let app = Router::new()
        .route("/", get(handler_home))
        .with_state(Arc::new(AppState {
            templates: Arc::new(Templates::new()),
            pool,
        }));

    let addr = "127.0.0.1:3000";
    println!("listening on http://{}", addr);

    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000").await?;
    axum::serve(listener, app).await?;
    Ok(())
}

async fn handler_home(State(state): State<std::sync::Arc<AppState>>) -> Result<Html<String>, StatusCode> {


    let rendered = state.templates.render_home().unwrap();
    let conn = state.pool.get().await.map_err(internal_error).unwrap();
    let row = conn
        .query_one("select 1 + 1", &[])
        .await
        .map_err(internal_error).unwrap();
    let two: i32 = row.try_get(0).map_err(internal_error).unwrap();
    println!("{}", two);
    Ok(Html(rendered))
}

fn internal_error<E>(err: E) -> (StatusCode, String)
where
    E: std::error::Error,
{
    (StatusCode::INTERNAL_SERVER_ERROR, err.to_string())
}