// Products views
view("products_list", func(data) {
  var nav = [
    record("label", "Dashboard", "url", "/"),
    record("label", "Products", "url", "/products"),
    record("label", "Orders", "url", "/orders")
  ]
  var items = all("products")
  var t = table(items, ["id", "name", "price", "stock"], "products")
  var f = section("Add Product",
    form("/products", ["name", "price", "stock"], "Create Product")
  )
  return page("Products", concat(t, f), nav)
})

view("products_show", func(data) {
  var nav = [
    record("label", "Dashboard", "url", "/"),
    record("label", "Products", "url", "/products"),
    record("label", "Orders", "url", "/orders")
  ]
  var bc = breadcrumb([record("label", "Products", "url", "/products"), "Detail"])
  var d = detail(data, ["id", "name", "price", "stock", "created_at"])
  return page("Product Detail", concat(bc, d), nav)
})
