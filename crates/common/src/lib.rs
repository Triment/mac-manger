//! 通用功能模块

pub mod error;
pub mod utils;
pub mod validation;

/// 版本信息
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
