{
    outputs = { self }: {
        templates = {
            rust-crate = {
                path = ./rust-crate;
                description = "A single-crate Rust project";
            };
            typst-minimal = {
                path = ./typst-minimal;
                description = "An empty typst project";
            };
        };
    };
}
