defmodule ProcessProductsJsonTest do
  use ExUnit.Case, async: true
  alias ProcessProductsJson, as: PPJS
  doctest ProcessProductsJson

  test "json_to_list tests" do
    # file does not exist
    assert {:error, :file_not_exist} == PPJS.json_to_list("./", "non-exitent.json")

    # file read correctly
    result = [
      %{"Code" => "VOUCHER", "Name" => "Voucher", "Price" => "5.00€"},
      %{"Code" => "TSHIRT", "Name" => "T-Shirt", "Price" => "20.00€"},
      %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => "7.50€"}
    ]

    assert result == PPJS.json_to_list("./test/", "products_test.json")
  end

  test "separate_currency function tests" do
    raw_product = %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => "7.50€"}
    processed_product = %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => 7.5, "ccy" => "€"}

    assert processed_product == PPJS.separate_currency(raw_product)
  end

  test "separate_currency_on_product_list function tests" do
    raw_list = [
      %{"Code" => "VOUCHER", "Name" => "Voucher", "Price" => "5.00€"},
      %{"Code" => "TSHIRT", "Name" => "T-Shirt", "Price" => "20.00€"},
      %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => "7.50€"}
    ]

    processed_list = [
      %{"Code" => "VOUCHER", "Name" => "Voucher", "Price" => 5.0, "ccy" => "€"},
      %{"Code" => "TSHIRT", "Name" => "T-Shirt", "Price" => 20.0, "ccy" => "€"},
      %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => 7.5, "ccy" => "€"}
    ]

    assert processed_list == PPJS.separate_currency_on_product_list(raw_list)
  end
end
