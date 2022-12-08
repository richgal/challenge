defmodule CheckoutFunctions do
  @moduledoc """
  Functions for the basic funtionalities of the application.

  These funtions are used to interact with the CheckoutServer.

  * initializing unique cart
  * add item to cart
  * support functions to filter, update and remove CheckoutServer's state elements.

  """
  alias alias PricingRulesCheckoutCart, as: CheckoutCart

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
  @type reason() :: String.t()
  # these coming from product.json store_product_codes() e.g. -> [product_code(), product_code()]
  @type store_product_codes() :: map()
  @type store_product_list() :: list()

  @spec generate_new_cart(pricing_rule()) :: cart() | {:error, reason()}
  def generate_new_cart(pricing_rule) do
    pricing_rules_reg = PricingRulesSets.pricing_rule_set_registry()

    case Map.has_key?(pricing_rules_reg, pricing_rule) do
      true ->
        %{cart_id: UUID.uuid4(), product_list: [], pricing_rule: pricing_rule}

      false ->
        IO.puts(
          "Pricing rule is not in the pricing rule set registry. :no_discout pricing rule set will be applied"
        )

        %{cart_id: UUID.uuid4(), product_list: [], pricing_rule: :no_discout}
    end
  end

  @spec add_product_to_cart(cart(), product_code(), store_product_codes()) ::
          cart() | {:error, reason()}
  def add_product_to_cart(cart, product_code, store_product_codes) do
    case Map.has_key?(store_product_codes, product_code) do
      true ->
        %{cart | product_list: [product_code | cart.product_list]}

      false ->
        IO.puts("Product is not in the products.json file. No product added")
        %{cart | product_list: cart.product_list}
    end
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

  @spec update_checkout_server_state(cart(), checkout_state()) :: checkout_state()
  def remove_cart_from_checkout_server_state(cart_id, checkout_state) do
    checkout_state_update =
      checkout_state
      |> Enum.reject(fn x -> x.cart_id == cart_id end)

    checkout_state_update
  end

  @spec get_total(cart(), store_product_list()) :: String.t()
  def get_total(cart, store_product_list) do
    pricing_rule = PricingRulesSets.pricing_rule_set_registry()

    total_price =
      cart
      |> Access.get(:product_list)
      |> CheckoutCart.summarise_product_list()
      |> CheckoutCart.generate_checkout_cart(store_product_list)
      |> pricing_rule[cart.pricing_rule].()

    :ok = CheckoutServer.call({:delete_cart, cart.cart_id})
    total_price
  end
end
