defmodule ProcessProductsJson do
  @moduledoc """
  This module is created to open, process and make available the products.json file's content for the rest of the application.
  """
  @type path() :: String.t()
  @type filename() :: String.t()
  @type product_attribute_raw() :: map()
  @type product_attribute() :: map()
  @type product_list() :: nonempty_list()
  @type reason() :: atom() | String.t()

  @doc """
  Opens a json file and decode the json format to elixir map format.

  Example input
  path // "./"
  filename // "products.json"

  Example output
  [
  %{"Code" => "VOUCHER", "Name" => "Voucher", "Price" => "5.00€"},
  %{"Code" => "TSHIRT", "Name" => "T-Shirt", "Price" => "20.00€"},
  %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => "7.50€"}
  ]
  """
  @spec json_to_list(path(), filename()) :: product_list() | {:error, reason()}
  def json_to_list(path, filename) do
    file_path = path <> filename

    with true <- File.exists?(file_path),
         {:ok, content} <- File.read(file_path),
         {:ok, product_list} <- Jsonrs.decode(content) do
      product_list
    else
      false -> {:error, :file_not_exist}
      err -> err
    end
  end

  @doc """
  Separates the currency symbol from the raw product attribute's price key to a new map.

  Example input
  %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => "7.50€"}

  Example output
  %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => 7.5, "ccy" => "€"}
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
  @spec separate_currency_on_product_list(product_list()) :: nonempty_list()
  def separate_currency_on_product_list(product_list) do
    product_list_processed = Enum.map(product_list, fn x -> separate_currency(x) end)
    product_list_processed
  end
end
