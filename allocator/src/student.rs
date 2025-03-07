#[derive(Debug)]
pub struct Student {
    id: String,
    class: String,
    roll_no: i32,
    subject: String,
}

impl Student {
    pub fn new(id: String, subject: String) -> Self {
        let id_clone = id.clone();
        let (class, roll_no) = id_clone.split_once('-').expect("invalid id format");
        let roll_no: i32 = roll_no.parse().expect("invalid roll number");
        let class = class.to_owned();
        Self {
            id,
            class,
            roll_no,
            subject,
        }
    }

    pub fn id(&self) -> &str {
        &self.id
    }

    pub fn class(&self) -> &str {
        self.class.as_ref()
    }

    pub fn roll_no(&self) -> i32 {
        self.roll_no
    }

    pub fn subject(&self) -> &str {
        self.subject.as_ref()
    }
}
