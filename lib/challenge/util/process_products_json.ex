defmodule ProcessProductsJson do
  @moduledoc """
  This module is created to open, process and make available the products.json file's content for the rest of the application.
  """

  # path e.g. -> "./"
  @type path() :: String.t()
  # path e.g. -> filename e.g. -> "products.json"
  @type filename() :: String.t()
  # product_attribute_raw e.g. -> %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => "7.50€"}
  @type product_attribute_raw() :: map()
  # product_attribute e.g. -> %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => 7.5, "ccy" => "€"}
  @type product_attribute() :: map()
  # product_list_raw e.g. -> [%{"Code" => "VOUCHER", "Name" => "Voucher", "Price" => "5.00€"}, %{"Code" => "TSHIRT", "Name" => "T-Shirt", "Price" => "20.00€"}]
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
  # reason e.g. -> :file_not_exist
  @type reason() :: atom() | String.t()

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

  @spec separate_currency(product_attribute_raw()) :: product_attribute()
  def separate_currency(product_attribute_raw) do
    {price, currency} = Float.parse(product_attribute_raw["Price"])
    product_attribute = Map.put(product_attribute_raw, "ccy", currency)
    product_attribute = %{product_attribute | "Price" => price}
    product_attribute
  end

  @spec separate_currency_on_product_list(product_list_raw()) :: nonempty_list()
  def separate_currency_on_product_list(product_list_raw) do
    product_list = Enum.map(product_list_raw, fn x -> separate_currency(x) end)
    product_list
  end

  @spec get_product_list(path(), filename()) :: product_list()
  def get_product_list(path, filename) do
    product_list =
      json_to_list(path, filename)
      |> separate_currency_on_product_list()

    product_list
  end

  def get_product_codes(path, filename) do
    product_list = get_product_list(path, filename)
    product_codes = Enum.frequencies(Enum.map(product_list, fn x -> x["Code"] end))
    product_codes
  end
end
