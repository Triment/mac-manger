//! 错误处理模块

/// 应用错误类型
#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("数据库错误: {0}")]
    Database(#[from] sqlx::Error),

    #[error("验证错误: {0}")]
    Validation(String),

    #[error("未授权")]
    Unauthorized,

    #[error("禁止访问")]
    Forbidden,

    #[error("未找到资源")]
    NotFound,

    #[error("内部服务器错误: {0}")]
    Internal(String),
}

/// 结果类型别名
pub type Result<T> = std::result::Result<T, AppError>;