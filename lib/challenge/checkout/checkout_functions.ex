defmodule CheckoutFunctions do
  @moduledoc """
  Functions for supporting the Checkout module.

  * initializing unique cart
  * manage item additions

  """

  @typedoc """
   cart e.g. -> %{cart_id: "c0e55a1a-47dc-4a13-9149-777f7259dcd8", product_list: []}
  """
  @type cart() :: map()
  @typedoc """
   cart_summary e.g. -> %{"Bar" => 2, "Foo" => 3}
  """
  @type cart_summary() :: map()
  @typedoc """
   product_code e.g. -> "TSHIRT"
  """
  @type product_code() :: String.t()
  @typedoc """
   subtotal e.g. -> %{"Bar" => 2, "Foo" => 3, "Subtotal" => 0}
  """
  @type subtotal() :: map()
  @typedoc """
   This list refers to the processed json elements.

   store_product_list e.g. ->
    [
      %{"Code" => "VOUCHER", "Name" => "Voucher", "Price" => 5.0, "ccy" => "€"},
      %{"Code" => "TSHIRT", "Name" => "T-Shirt", "Price" => 20.0, "ccy" => "€"},
      %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => 7.5, "ccy" => "€"}
    ]
  """
  @type checkout_cart() :: list()
  @type store_product_list() :: nonempty_list()
  @type product_list() :: list()
  @type product_list_summary() :: map()
  @type pricing_rule() :: atom()

  @spec generate_new_cart(pricing_rule()) :: cart()
  def generate_new_cart(pricing_rule) do
    %{cart_id: UUID.uuid4(), product_list: [], pricing_rule: pricing_rule}
  end

  @spec add_product_to_cart(cart(), product_code()) :: cart()
  def add_product_to_cart(cart, product_code) do
    new_produt_list = [product_code | cart.product_list]
    %{cart | product_list: new_produt_list}
  end

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

  def get_cart_element_attributes(checkout_cart, product_code) do
    cart_element = Enum.find(checkout_cart, fn x -> x["Code"] == product_code end)

    case cart_element do
      nil ->
        {"not_in_cart", "not_in_cart", 0, 0, nil}

      _ ->
        {cart_element["Code"], cart_element["Name"], cart_element["Price"],
         cart_element["Quantity"], cart_element["ccy"]}
    end
  end

  def get_cart_element(checkout_cart, product_code) do
    Enum.find(checkout_cart, fn x -> x["Code"] == product_code end)
  end
end
