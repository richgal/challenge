defmodule Checkout do
  @moduledoc """
  Interface to interact with the CheckoutServer
  """
  alias CheckoutFunctions
  alias PricingRulesCheckoutCart, as: CheckoutCart

  def new(pricing_rule) do
    cart = CheckoutFunctions.generate_new_cart(pricing_rule)
    cart_id = CheckoutServer.call({:new_cart, cart})
    cart_id
  end

  def scan(cart_id, product_code) do
    store_product_codes = ProcessProductsJson.get_product_codes("./", "products.json")

    cart_update =
      CheckoutServer.call({:get_cart, cart_id})
      |> CheckoutFunctions.add_product_to_cart(product_code, store_product_codes)

    CheckoutServer.call({:update_checkout_state, cart_update})
  end

  def total(cart_id) do
    store_product_list = ProcessProductsJson.get_product_list("./", "products.json")
    cart = CheckoutServer.call({:get_cart, cart_id})
    pricing_rule = PricingRulesSets.pricing_rule_set_registry()

    total_price =
      cart
      |> Access.get(:product_list)
      |> CheckoutCart.summarise_product_list()
      |> CheckoutCart.generate_checkout_cart(store_product_list)
      |> pricing_rule[cart.pricing_rule].()

    CheckoutServer.call({:delete_cart, cart_id})
    total_price
  end
end
