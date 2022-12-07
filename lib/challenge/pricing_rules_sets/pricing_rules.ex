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

  def pricing_rule_2_for_1(subtotal, product_code, store_product_list) do
    quantity = CheckoutFunctions.get_product_quantity(subtotal, product_code)
    price = CheckoutFunctions.get_product_price(product_code, store_product_list)

    product_subtotal =
      cond do
        quantity == 0 ->
          0

        quantity == 1 ->
          price

        quantity == 2 ->
          2 * price * 0.5

        quantity > 2 ->
          case rem(quantity, 2) do
            0 -> quantity * price * 0.5
            _ -> (quantity - 1) * price * 0.5 + price
          end
      end

    product_subtotal
  end

  @doc """
   The CFO insists that the best way to increase sales is with discounts on bulk purchases
   (buying x or more of a product, the price of that product is reduced), and demands that
   if you buy 3 or more `TSHIRT` items, the price per unit should be 19.00€.
  """

  def pricing_rule_bulk_purchase(subtotal, product_code, store_product_list) do
    quantity = CheckoutFunctions.get_product_quantity(subtotal, product_code)
    price = CheckoutFunctions.get_product_price(product_code, store_product_list)

    product_subtotal =
      cond do
        quantity == 0 -> 0
        quantity < 3 -> quantity * price
        quantity >= 3 -> quantity * 19.00
      end

    product_subtotal
  end

  def pricing_rule_reqular_purchase(subtotal, product_code, store_product_list) do
    quantity = CheckoutFunctions.get_product_quantity(subtotal, product_code)
    price = CheckoutFunctions.get_product_price(product_code, store_product_list)

    product_subtotal =
      cond do
        quantity == 0 -> 0
        quantity > 0 -> quantity * price
      end

    product_subtotal
  end
end
