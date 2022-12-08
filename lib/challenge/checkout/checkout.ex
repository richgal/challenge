defmodule Checkout do
  @moduledoc """
  Interface to interact with the application.
  """
  alias CheckoutFunctions

  # pricing_rule() e.g. -> :pricing_rule
  @type pricing_rule() :: atom()
  # cart_id() e.g. -> "c0e55a1a-47dc-4a13-9149-777f7259dcd8"
  @type cart_id() :: String.t()
  # product_code() e.g. -> "TSHIRT"
  @type product_code() :: String.t()

  @spec new(pricing_rule()) :: cart_id()
  def new(pricing_rule) do
    cart = CheckoutFunctions.generate_new_cart(pricing_rule)
    cart_id = CheckoutServer.call({:new_cart, cart})
    cart_id
  end

  @spec scan(cart_id(), product_code()) :: cart_id()
  def scan(cart_id, product_code) do
    store_product_codes = ProcessProductsJson.get_product_codes("./", "products.json")

    cart_update =
      CheckoutServer.call({:get_cart, cart_id})
      |> CheckoutFunctions.add_product_to_cart(product_code, store_product_codes)

    CheckoutServer.call({:update_checkout_state, cart_update})
  end

  @spec total(cart_id()) :: String.t()
  def total(cart_id) do
    store_product_list = ProcessProductsJson.get_product_list("./", "products.json")
    cart = CheckoutServer.call({:get_cart, cart_id})

    case cart do
      nil ->
        IO.puts("Cart does not exist, start a new cart process with Checkout.new(:pricing_rule)")

      _ ->
        CheckoutFunctions.get_total(cart, store_product_list)
    end
  end
end
