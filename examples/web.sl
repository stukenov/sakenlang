route("GET", "/", func() {
    return "<h1>sakenlang web</h1><p>Привет, мир!</p>"
})

route("GET", "/hello", func() {
    let name = param("name")
    return "<h1>Привет, " + name + "!</h1>"
})

serve(3000)
