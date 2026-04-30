// ERP Application entry point

// Dashboard route
route("GET", "/", func() {
  return render("dashboard", record())
})

// Product routes with views
route("GET", "/products", func() {
  return render("products_list", record())
})

route("GET", "/products/new", func() {
  return render("products_list", record())
})

route("POST", "/products", func() {
  var name = param("name")
  var price = to_int(param("price"))
  var stock = to_int(param("stock"))
  create("products", "name", name, "price", price, "stock", stock)
  return redirect("/products")
})

route("GET", "/orders", func() {
  return render("orders_list", record())
})

route("GET", "/orders/new", func() {
  return render("orders_list", record())
})

route("POST", "/orders", func() {
  var product_id = to_int(param("product_id"))
  var quantity = to_int(param("quantity"))
  var total = to_int(param("total"))
  var status = param("status")
  create("orders", "product_id", product_id, "quantity", quantity, "total", total, "status", status)
  return redirect("/orders")
})

// Start server
serve(3000)
