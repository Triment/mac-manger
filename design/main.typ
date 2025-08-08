#import "@preview/cetz:0.4.1"
#set document(
    title: "通用资产管理系统",
    author: "as",
    date: auto
)
=== tokio 异步

共享状态需要使用`Arc<Mutex<T>>`来包装,一般情况不使用`tokio::sync::Mutex`,在数据竞争并不严重的情况下，使用`std::sync::Mutex`更为简单和高效。
```rust
use std::sync::{Arc, Mutex};
```
tokio的线程之间不能共享没实现`send`
```rust
use std::sync::{Mutex, MutexGuard};

async fn increment_and_do_stuff(mutex: &Mutex<i32>) {
    let mut lock: MutexGuard<i32> = mutex.lock().unwrap();
    *lock += 1;

    do_something_async().await;
}//lock会在作用域结束的时候自动释放，但是 do_something_async().await会导致lock移到新的线程

async fn increment_and_do_stuff(mutex: &Mutex<i32>) {
    {
        let mut lock: MutexGuard<i32> = mutex.lock().unwrap();
        *lock += 1;
    } // 这可以确保在调用 do_something_async() 之前锁被释放
    //drop(lock);目前编译器无法识别显式释放
    do_something_async().await;
}
```
有些互斥锁 crate 会为其 MutexGuard 实现Send，可以编译但是会死锁

==== 解决方式 确保互斥锁保护不会出现在异步函数的任何地方
```rust
use std::sync::Mutex;
//包装在结构体中
struct CanIncrement {
    mutex: Mutex<i32>,
}
impl CanIncrement {
    // 在同步方法中取锁
    fn increment(&self) {
        let mut lock = self.mutex.lock().unwrap();
        *lock += 1;
    }
}

async fn increment_and_do_stuff(can_incr: &CanIncrement) {
    can_incr.increment();
    do_something_async().await;
}
```
然而
```rust
use tokio::sync::Mutex; // note! This uses the Tokio mutex

// This compiles!
// (but restructuring the code would be better in this case)
async fn increment_and_do_stuff(mutex: &Mutex<i32>) {
    let mut lock = mutex.lock().await;
    *lock += 1;

    do_something_async().await;
}
```
这是可以编译的`tokio::sync::Mutex`也代价更高，总结下来：
- 互斥锁难以处理使用`tokio::sync::Mutex`
- 专用任务管理状态，消息传递给其他线程
- 用Mutex
- 避免互斥