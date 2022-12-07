defmodule PricingRulesSets do
  @moduledoc """
  The PricingRules.PricingRulesSets module's purpose to compose price rule sets which could be applied for
  different checkout processes.

  The individual price rules can be set in the PricingRules module.

  The price rule sets should be developed considering individual cart element as the argument.

  Every pricing rule set must end with the invoke of calculate_total/1 funtion as the last element of the price rule set pipeline

  Every pricing rule set must be registered by adding the function to the pricint_rule_set_registry

  """

  def pricing_rule_set_registry do
    %{
      pricing_rule: &unique_ricing_rule_set/1
    }
  end

  def unique_ricing_rule_set(checkout_cart) do
    checkout_cart
    |> PricingRules.pricing_rule_2_for_1("VOUCHER")
    |> PricingRules.pricing_rule_bulk_purchase("TSHIRT", 3, 19)
    |> calculate_total
  end

  def calculate_total(checkout_cart) do
    checkout_cart
    |> Enum.map(fn x -> x["Quantity"] * x["Price"] end)
    |> Enum.reduce(fn x, acc -> x + acc end)
  end
end
