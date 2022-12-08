process_json = ProcessProductsJson
store_product_list = ProcessProductsJson.get_product_list("./", "products.json")
cart_list = ["VOUCHER", "TSHIRT", "VOUCHER", "VOUCHER", "MUG", "TSHIRT", "TSHIRT"]
pls = PricingRulesCheckoutCart.summarise_product_list(cart_list)
ccart = PricingRulesCheckoutCart.generate_checkout_cart(pls, store_product_list)
registry = PricingRulesSets.pricing_rule_set_registry()
