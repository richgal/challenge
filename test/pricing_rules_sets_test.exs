defmodule PricingRulesSetsTest do
  use ExUnit.Case, async: true
  alias PricingRulesSets
  doctest PricingRulesSets

  # Helper funtions

  def sample_checkout_cart do
    [
      %{
        "Code" => "MUG",
        "Name" => "Coffee Mug",
        "Price" => 7.5,
        "Quantity" => 1,
        "ccy" => "€"
      },
      %{
        "Code" => "TSHIRT",
        "Name" => "T-Shirt",
        "Price" => 20.0,
        "Quantity" => 4,
        "ccy" => "€"
      },
      %{
        "Code" => "VOUCHER",
        "Name" => "Voucher",
        "Price" => 5.0,
        "Quantity" => 3,
        "ccy" => "€"
      }
    ]
  end
end
