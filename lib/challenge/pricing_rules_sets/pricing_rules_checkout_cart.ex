defmodule PricingRulesCheckoutCart do
  @moduledoc """
  PricingRulesCheckoutCart module supports the generation and modification of checkout_cart() lists.

  checkout_cart() list is summarised and extended representation of a unique cart's product_list()

  all pricing rule functions in the PricingRules module use checkout_cart() as their first argument
  and returns modified checkout_cart() lists.
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
  # cart_element() e.g. ->  %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => 50, "Quantity" => 100, "ccy" => "€"} or [cart_element(), cart_element()]
  @type cart_element() :: map() | list()
  # checkout_cart() e.g. -> [cart_element(), cart_element()]
  @type checkout_cart() :: list()
  # product_attribute e.g. -> %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => 7.5, "ccy" => "€"}
  @type product_attribute() :: map()
  # store_product_list e.g. -> [product_attribute(), product_attribute()]
  @type store_product_list() :: nonempty_list()
  # product_list_summary e.g. -> %{"MUG" => 1, "TSHIRT" => 3, "VOUCHER" => 3}
  @type product_list_summary() :: map()

  @spec summarise_product_list(product_list()) :: product_list_summary()
  def summarise_product_list(product_list) do
    product_list_summary = Enum.frequencies(product_list)
    product_list_summary
  end

  @spec generate_checkout_cart(product_list_summary(), store_product_list()) :: checkout_cart()
  def generate_checkout_cart(product_list_summary, store_product_list) do
    checkout_cart =
      Map.keys(product_list_summary)
      |> Enum.map(fn x ->
        generate_checkout_cart_element(x, product_list_summary, store_product_list)
      end)

    checkout_cart
  end

  @spec generate_checkout_cart_element(
          product_code(),
          product_list_summary(),
          store_product_list()
        ) :: map()
  def generate_checkout_cart_element(product_code, product_list_summary, store_product_list) do
    cart_element =
      Enum.find(store_product_list, fn x -> x["Code"] == product_code end)
      |> Map.put("Quantity", product_list_summary[product_code])

    cart_element
  end

  @spec update_checkout_cart(checkout_cart(), cart_element()) :: checkout_cart()
  def update_checkout_cart(checkout_cart, cart_element) when is_map(cart_element) do
    product_code = cart_element["Code"]

    checkout_cart_update =
      checkout_cart
      |> Enum.reject(fn x -> x["Code"] == product_code end)
      |> List.insert_at(-1, cart_element)

    checkout_cart_update
  end

  def update_checkout_cart(checkout_cart, cart_element) when is_list(cart_element) do
    product_code = hd(cart_element)["Code"]

    checkout_cart_update =
      checkout_cart
      |> Enum.reject(fn x -> x["Code"] == product_code end)
      |> Kernel.++(cart_element)

    checkout_cart_update
  end

  @spec get_checkout_cart_element_attributes(checkout_cart(), product_code()) :: tuple()
  def get_checkout_cart_element_attributes(checkout_cart, product_code) do
    cart_element = Enum.find(checkout_cart, fn x -> x["Code"] == product_code end)

    case cart_element do
      nil ->
        {"not_in_cart", "not_in_cart", 0, 0, nil}

      _ ->
        {cart_element["Code"], cart_element["Name"], cart_element["Price"],
         cart_element["Quantity"], cart_element["ccy"]}
    end
  end

  @spec get_checkout_cart_element(checkout_cart(), product_code()) :: cart_element()
  def get_checkout_cart_element(checkout_cart, product_code) do
    Enum.find(checkout_cart, fn x -> x["Code"] == product_code end)
  end
end
