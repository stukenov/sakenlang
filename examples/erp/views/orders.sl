// Orders views
view("orders_list", func(data) {
  var nav = [
    record("label", "Dashboard", "url", "/"),
    record("label", "Products", "url", "/products"),
    record("label", "Orders", "url", "/orders")
  ]
  var items = all("orders")
  var t = table(items, ["id", "product_id", "quantity", "total", "status"], "orders")
  var f = section("New Order",
    form("/orders", ["product_id", "quantity", "total", "status"], "Create Order")
  )
  return page("Orders", concat(t, f), nav)
})

view("orders_show", func(data) {
  var nav = [
    record("label", "Dashboard", "url", "/"),
    record("label", "Products", "url", "/products"),
    record("label", "Orders", "url", "/orders")
  ]
  var bc = breadcrumb([record("label", "Orders", "url", "/orders"), "Detail"])
  var d = detail(data, ["id", "product_id", "quantity", "total", "status", "created_at"])
  return page("Order Detail", concat(bc, d), nav)
})
