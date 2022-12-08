defmodule Checkout do
  @moduledoc """
  Interface to interact with the CheckoutServer
  """
  alias CheckoutFunctions

  def new(pricing_rule) do
    cart = CheckoutFunctions.generate_new_cart(pricing_rule)
    cart_id = CheckoutServer.call({:new_cart, cart})
    cart_id
  end

  def scan(cart_id, product_code) do
    cart = CheckoutServer.call({:get_cart, cart_id})
    cart_update = CheckoutFunctions.add_product_to_cart(cart, product_code)
    CheckoutServer.call({:update_checkout_state, cart_update})
  end
end
