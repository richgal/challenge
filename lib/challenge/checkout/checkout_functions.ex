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
  @type store_product_list() :: nonempty_list()
  @type product_list() :: list()
  @type product_list_summary() :: map()

  @spec generate_new_cart() :: cart()
  def generate_new_cart do
    %{cart_id: UUID.uuid4(), product_list: []}
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

  @spec generate_subtotal(cart_summary()) :: subtotal()
  def generate_subtotal(cart_summary) do
    %{"cart_summary" => cart_summary, "Subtotal" => 0}
  end

  @spec get_product_quantity(subtotal(), product_code()) :: integer()
  def get_product_quantity(subtotal, product_code) do
    quantity =
      case Map.has_key?(subtotal, product_code) do
        true -> subtotal[product_code]
        false -> 0
      end

    quantity
  end

  @spec get_product_price(product_code(), store_product_list()) :: float()
  def get_product_price(product_code, store_product_list) do
    product_price =
      store_product_list
      |> Enum.find(fn x -> x["Code"] == product_code end)
      |> Map.get("Price")

    product_price
  end
end
