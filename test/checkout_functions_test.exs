defmodule CheckoutFunctionsTest do
  use ExUnit.Case, async: true
  alias CheckoutFunctions
  doctest CheckoutFunctions

  test "generate new cart tests" do
    cart = CheckoutFunctions.generate_new_cart(:pricing_rule)
    assert 36 == String.length(cart.cart_id)
    assert [] == cart.product_list
  end

  test "add_product_to_cart tests" do
    # assert empty product list
    cart = %{cart_id: "c0e55a1a-47dc-4a13-9149-777f7259dcd8", product_list: []}
    assert [] == cart.product_list

    # add item to cart
    cart_after_item_added = CheckoutFunctions.add_product_to_cart(cart, "TSHIRT", %{"TSHIRT" => 1, "MUG" => 2})
    assert "TSHIRT" == hd(cart_after_item_added.product_list)
    assert cart.cart_id == cart_after_item_added.cart_id
  end
end
