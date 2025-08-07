use sqlx::PgPool;
use axum::{
        body::Body,
        extract::connect_info::MockConnectInfo,
        http::{self, Request, StatusCode},
    };
use tower::{Service, ServiceExt};
use http_body_util::BodyExt;
#[sqlx::test]
async fn test_handler_accounts(db: PgPool) {
    let app = api::app(db);
    let mut resp = app
        .oneshot(
            Request::post("/v1/accounts")
                .header("content-type", "application/json")
                .body(Body::from(r#"{"username": "admin", "password": "12345678"}"#))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(resp.status(), StatusCode::OK);
    let body = resp.into_body().collect().await.unwrap().to_bytes();
    assert_eq!(&body[..], b"hello world");
}
