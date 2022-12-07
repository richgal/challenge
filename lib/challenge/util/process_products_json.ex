defmodule ProcessProductsJson do
  @moduledoc """
  This module is created to open, process and make available the products.json file's content for the rest of the application.
  """
  @typedoc """
   path e.g. -> "./"
  """
  @type path() :: String.t()
  @typedoc """
   filename e.g. -> "products.json"
  """
  @type filename() :: String.t()
  @typedoc """
   product_attribute_raw e.g. -> %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => "7.50€"}
  """
  @type product_attribute_raw() :: map()
  @typedoc """
   product_attribute e.g. -> %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => 7.5, "ccy" => "€"}
  """
  @type product_attribute() :: map()
  @typedoc """
   product_list_raw e.g. ->
    [
      %{"Code" => "VOUCHER", "Name" => "Voucher", "Price" => "5.00€"},
      %{"Code" => "TSHIRT", "Name" => "T-Shirt", "Price" => "20.00€"},
      %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => "7.50€"}
    ]
  """
  @type product_list_raw() :: nonempty_list()
  @typedoc """
   Product list where the currency units and prices are separate keys. 
   product_list e.g. ->
    [
      %{"Code" => "VOUCHER", "Name" => "Voucher", "Price" => 5.0, "ccy" => "€"},
      %{"Code" => "TSHIRT", "Name" => "T-Shirt", "Price" => 20.0, "ccy" => "€"},
      %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => 7.5, "ccy" => "€"}
    ]
  """
  @type product_list() :: nonempty_list()
  @typedoc """
   reason e.g. -> :file_not_exist
  """
  @type reason() :: atom() | String.t()

  @doc """
  Opens a json file and decode the json format to elixir map format.
  """
  @spec json_to_list(path(), filename()) :: product_list_raw() | {:error, reason()}
  def json_to_list(path, filename) do
    file_path = path <> filename

    with true <- File.exists?(file_path),
         {:ok, content} <- File.read(file_path),
         {:ok, product_list_raw} <- Jsonrs.decode(content) do
      product_list_raw
    else
      false -> {:error, :file_not_exist}
      err -> err
    end
  end

  @doc """
  Separates the currency symbol from the raw product attribute's price key to a new map.
  """
  @spec separate_currency(product_attribute_raw()) :: product_attribute()
  def separate_currency(product_attribute_raw) do
    {price, currency} = Float.parse(product_attribute_raw["Price"])
    product_attribute = Map.put(product_attribute_raw, "ccy", currency)
    product_attribute = %{product_attribute | "Price" => price}
    product_attribute
  end

  @doc """
  Iterates trough the product list to reformat the list elements maps with prices and currencies
  with the use of separate_currency function.
  """
  @spec separate_currency_on_product_list(product_list_raw()) :: nonempty_list()
  def separate_currency_on_product_list(product_list_raw) do
    product_list = Enum.map(product_list_raw, fn x -> separate_currency(x) end)
    product_list
  end

  @doc """
  Generates formatted product list
  """
  @spec get_product_list(path(), filename()) :: product_list()
  def get_product_list(path, filename) do
    product_list =
      json_to_list(path, filename)
      |> separate_currency_on_product_list()

    product_list
  end
end
