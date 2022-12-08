defmodule PricingRulesSets do
  @moduledoc """
  The PricingRulesSets module's purpose to compose price rule sets which could be applied for
  different checkout processes.

  The individual price rules can be set in the PricingRules module.

  The price rule sets should be developed considering checkout_cart() as the argument.

  Every pricing rule set must end with the invoke of calculate_total/1 funtion as the last element of the price rule set pipeline

  Every pricing rule set must be registered by adding the function to the pricint_rule_set_registry/0

  """

  # checkout_cart() e.g. -> [cart_element(), cart_element()]
  @type checkout_cart() :: list()
  # ccy() e.g. -> "€"
  @type ccy() :: String.t()

  def pricing_rule_set_registry do
    %{
      pricing_rule: &unique_ricing_rule_set/1,
      no_discout: &no_discount/1
    }
  end

  # unique pricing rules

  def unique_ricing_rule_set(checkout_cart) do
    checkout_cart
    |> PricingRules.pricing_rule_2_for_1("VOUCHER")
    |> PricingRules.pricing_rule_bulk_purchase("TSHIRT", 3, 19.00)
    |> calculate_total("€")
  end

  def no_discount(checkout_cart) do
    checkout_cart
    |> calculate_total("€")
  end

  # calculate total must be the final invoked funcion in unique pricing rule funtions

  def calculate_total(checkout_cart, ccy) do
    total =
      checkout_cart
      |> Enum.map(fn x -> x["Quantity"] * x["Price"] end)
      |> Enum.reduce(fn x, acc -> x + acc end)

    "#{:erlang.float_to_binary(total, decimals: 2)}#{ccy}"
  end
end
