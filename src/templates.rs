use minijinja::Environment;
use serde::Serialize;

pub struct Templates {
    env: Environment<'static>,
}

impl Default for Templates {
    fn default() -> Self {
        Self::new()
    }
}

impl Templates {
    pub fn new() -> Self {
        let mut env = Environment::new();
        env.add_template("layout", include_str!("../templates/layout.jinja"))
            .unwrap();
        Self { env }
    }

    pub fn render_home(&self) -> Result<String, minijinja::Error> {
        self.env
            .get_template("layout")
            .unwrap()
            .render(minijinja::context! {
                title => "Home",
                welcome_text => "Hello World!",
            })
    }
}