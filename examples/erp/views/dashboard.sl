// Dashboard view
view("dashboard", func(data) {
  var nav = [
    record("label", "Dashboard", "url", "/"),
    record("label", "Products", "url", "/products"),
    record("label", "Orders", "url", "/orders")
  ]
  var product_count = count("products")
  var order_count = count("orders")
  var stats = row(
    concat(stat(product_count, "Products"), stat(order_count, "Orders"))
  )
  var recent_products = all("products")
  var products_table = section("Recent Products",
    concat(
      table(recent_products, ["id", "name", "price", "stock"], "products"),
      button("Add Product", "/products/new", "primary")
    )
  )
  var recent_orders = all("orders")
  var orders_table = section("Recent Orders",
    concat(
      table(recent_orders, ["id", "product_id", "quantity", "total", "status"], "orders"),
      button("New Order", "/orders/new", "primary")
    )
  )
  return page("Dashboard", concat(stats, products_table, orders_table), nav)
})
