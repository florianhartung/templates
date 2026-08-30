{
    outputs = { self }: {
        templates.rust-crate = {
            path = ./rust-crate;
            description = "A single-crate Rust project";
        };
    };
}