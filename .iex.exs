process_json = ProcessProductsJson
list_summary = fn (x) -> CheckoutFunctions.summarise_product_list(x) end
store_product_list = ProcessProductsJson.get_product_list("./", "products.json")
cart_list = ["VOUCHER", "TSHIRT", "VOUCHER", "VOUCHER", "MUG", "TSHIRT", "TSHIRT"]
