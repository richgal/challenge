defmodule PricingRulesCheckoutCartTest do
  use ExUnit.Case, async: true
  alias PricingRulesCheckoutCart
  alias ProcessProductsJson, as: PPJS
  doctest PricingRulesCheckoutCart

  test "generate checkout cart tests" do
    product_list = product_list()
    store_product_list = store_product_list()
    product_list_summary = PricingRulesCheckoutCart.summarise_product_list(product_list)
    checkout_cart_result = checkout_cart_result()

    checkout_cart =
      PricingRulesCheckoutCart.generate_checkout_cart(product_list_summary, store_product_list)

    assert checkout_cart_result == checkout_cart
  end

  test "update checkout cart test" do
    checkout_cart = checkout_cart_result()
    updated_cart_element = updated_cart_element()

    updated_checkout_cart =
      PricingRulesCheckoutCart.update_checkout_cart(checkout_cart, updated_cart_element)

    assert 50 ==
             PricingRulesCheckoutCart.get_checkout_cart_element(updated_checkout_cart, "MUG")[
               "Price"
             ]

    assert 100 ==
             PricingRulesCheckoutCart.get_checkout_cart_element(updated_checkout_cart, "MUG")[
               "Quantity"
             ]
  end

  # Test helper functions
  def product_list do
    ["VOUCHER", "TSHIRT", "VOUCHER", "VOUCHER", "MUG", "TSHIRT", "TSHIRT"]
  end

  def store_product_list do
    PPJS.get_product_list("./test/", "products_test.json")
  end

  def checkout_cart_result do
    [
      %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => 7.5, "Quantity" => 1, "ccy" => "€"},
      %{"Code" => "TSHIRT", "Name" => "T-Shirt", "Price" => 20.0, "Quantity" => 3, "ccy" => "€"},
      %{"Code" => "VOUCHER", "Name" => "Voucher", "Price" => 5.0, "Quantity" => 3, "ccy" => "€"}
    ]
  end

  def updated_cart_element do
    %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => 50, "Quantity" => 100, "ccy" => "€"}
  end
end
