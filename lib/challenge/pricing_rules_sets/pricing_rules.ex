defmodule PricingRules do
  @moduledoc """
  Module to implement individual pricing rules. The pricing rules could be used exclusively by adding the selected functions
  to price rule sets in the PricingRulesSets module.

  With the help of unique pricing rules it is possible to implement conventional or exotic pricing rule funtions.

  Each pricing rule input should be a subtotal() map and should return an updated subtotal map()
  """
  alias ProcessProductsJson
  alias CheckoutFunctions
  @type subtotal() :: map()
  @type product_price() :: float()
  @type product_code() :: String.t()
  @type path() :: String.t()
  @type filename() :: String.t()

  @doc """
   The marketing department believes in 2-for-1 promotions (buy two of the same product, get one free),
   and would like for there to be a 2-for-1 special on `VOUCHER` items.

   Example input arguments
   subtotal = %{"Bar" => 2, "Foo" => 3, "Subtotal" => 0}
   product_code = "Foo"
   store_product_list = []
  """

  def pricing_rule_2_for_1(checkout_cart, product_code) do
    {_code, _name, price, quantity, _ccy} =
      CheckoutFunctions.get_checkout_cart_element_attributes(checkout_cart, product_code)

    cart_element = CheckoutFunctions.get_checkout_cart_element(checkout_cart, product_code)

    checkout_cart =
      cond do
        quantity < 2 ->
          checkout_cart

        quantity >= 2 ->
          case rem(quantity, 2) do
            0 ->
              CheckoutFunctions.update_checkout_cart(checkout_cart, %{
                cart_element
                | "Price" => price * 0.5
              })

            _ ->
              CheckoutFunctions.update_checkout_cart(checkout_cart, [
                %{cart_element | "Price" => price * 0.5, "Quantity" => quantity - 1},
                %{cart_element | "Quantity" => 1}
              ])
          end
      end

    IO.puts("checkout_cart #{inspect(checkout_cart)}")
    checkout_cart
  end

  @doc """
   The CFO insists that the best way to increase sales is with discounts on bulk purchases
   (buying x or more of a product, the price of that product is reduced), and demands that
   if you buy 3 or more `TSHIRT` items, the price per unit should be 19.00€.
  """

  def pricing_rule_bulk_purchase(checkout_cart, product_code, bulk_limit, new_price) do
    {_code, _name, _price, quantity, _ccy} =
      CheckoutFunctions.get_checkout_cart_element_attributes(checkout_cart, product_code)

    cart_element = CheckoutFunctions.get_checkout_cart_element(checkout_cart, product_code)

    checkout_cart =
      cond do
        quantity < bulk_limit ->
          checkout_cart

        quantity >= bulk_limit ->
          CheckoutFunctions.update_checkout_cart(checkout_cart, %{
            cart_element
            | "Price" => new_price
          })
      end

    IO.puts("checkout_cart #{inspect(checkout_cart)}")
    checkout_cart
  end
end
