defmodule CheckoutFunctions do
  @moduledoc """
  Functions for supporting the CheckoutServer module.

  * initializing unique cart
  * add item to cart
  * support functions to filter and update CheckoutServer's state

  """

  # cart() e.g. -> %{cart_id: "c0e55a1a-47dc-4a13-9149-777f7259dcd8", product_list: [], pricing_rule: :pricing_rule}
  @type cart() :: map()
  # product_code() e.g. -> "TSHIRT"
  @type product_code() :: String.t()
  # cart_id() e.g. -> "c0e55a1a-47dc-4a13-9149-777f7259dcd8"
  @type cart_id() :: String.t()
  # product_list() e.g. -> [product_code(), product_code()]
  @type product_list() :: list()
  # pricing_rule() e.g. -> :pricing_rule
  @type pricing_rule() :: atom()
  # checkout_state() e.g. -> [cart(), cart(), ...]
  @type checkout_state() :: list()

  @spec generate_new_cart(pricing_rule()) :: cart_id()
  def generate_new_cart(pricing_rule) do
    cart = %{cart_id: UUID.uuid4(), product_list: [], pricing_rule: pricing_rule}
    cart
  end

  @spec add_product_to_cart(cart(), product_code()) :: cart()
  def add_product_to_cart(cart, product_code) do
    new_produt_list = [product_code | cart.product_list]
    %{cart | product_list: new_produt_list}
  end

  @spec get_cart_from_checkout_server_state(cart_id(), checkout_state()) :: cart()
  def get_cart_from_checkout_server_state(cart_id, checkout_state) do
    cart = Enum.find(checkout_state, fn x -> x.cart_id == cart_id end)
    cart
  end

  @spec update_checkout_server_state(cart(), checkout_state()) :: checkout_state()
  def update_checkout_server_state(cart, checkout_state) do
    cart_id = cart.cart_id

    checkout_state_update =
      checkout_state
      |> Enum.reject(fn x -> x.cart_id == cart_id end)
      |> List.insert_at(-1, cart)

    checkout_state_update
  end
end
