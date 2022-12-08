defmodule PricingRules do
  @moduledoc """
  Module to implement individual pricing rules. The pricing rules could be used exclusively by adding the pricing rule functions
  to price rule sets in the PricingRulesSets module.

  With the help of unique pricing rules it is possible to implement conventional or exotic pricing rule funtions.

  Each pricing rule's first input must be a checkout_cart() list and should return an updated checkout_cart list.
  """
  alias ProcessProductsJson
  alias PricingRulesCheckoutCart, as: CheckoutCart

  # cart_element() e.g. ->  %{"Code" => "MUG", "Name" => "Coffee Mug", "Price" => 50, "Quantity" => 100, "ccy" => "€"}
  @type cart_element() :: map() | list()
  # checkout_cart() e.g. -> [cart_element(), cart_element()]
  @type checkout_cart() :: list()
  # product_code() e.g. -> "MUG"
  @type product_code() :: String.t()

  @doc """
  requirements for pricing_rule_2_for_1 function
  * The marketing department believes in 2-for-1 promotions  (buy two of the same product, get one free),
  and would like for there to be a 2-for-1 special on `VOUCHER` items.
  """

  @spec pricing_rule_2_for_1(checkout_cart(), product_code()) :: checkout_cart()
  def pricing_rule_2_for_1(checkout_cart, product_code) do
    {_code, name, price, quantity, _ccy} =
      CheckoutCart.get_checkout_cart_element_attributes(checkout_cart, product_code)

    cart_element = CheckoutCart.get_checkout_cart_element(checkout_cart, product_code)

    checkout_cart =
      cond do
        quantity < 2 ->
          checkout_cart

        quantity >= 2 ->
          case rem(quantity, 2) do
            0 ->
              CheckoutCart.update_checkout_cart(checkout_cart, %{
                cart_element
                | "Name" => "#{name} with discount",
                  "Price" => price * 0.5
              })

            _ ->
              CheckoutCart.update_checkout_cart(checkout_cart, [
                %{cart_element | "Quantity" => 1},
                %{
                  cart_element
                  | "Name" => "#{name} with discount",
                    "Price" => price * 0.5,
                    "Quantity" => quantity - 1
                }
              ])
          end
      end

    checkout_cart
  end

  @doc """
  requirements for pricing_rule_bulk_purchase function
  * The CFO insists that the best way to increase sales is with discounts on bulk purchases
  (buying x or more of a product, the price of that product is reduced), and demands that if
  you buy 3 or more `TSHIRT` items, the price per unit should be 19.00€.
  """

  @spec pricing_rule_bulk_purchase(checkout_cart(), product_code(), integer(), float()) ::
          checkout_cart()
  def pricing_rule_bulk_purchase(checkout_cart, product_code, bulk_limit, new_price) do
    {_code, name, _price, quantity, _ccy} =
      CheckoutCart.get_checkout_cart_element_attributes(checkout_cart, product_code)

    cart_element = CheckoutCart.get_checkout_cart_element(checkout_cart, product_code)

    checkout_cart =
      cond do
        quantity < bulk_limit ->
          checkout_cart

        quantity >= bulk_limit ->
          CheckoutCart.update_checkout_cart(checkout_cart, %{
            cart_element
            | "Price" => new_price,
              "Name" => "#{name} with discount"
          })
      end

    checkout_cart
  end
end
