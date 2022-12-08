defmodule PricingRulesTest do
  use ExUnit.Case, async: true
  alias PricingRules
  doctest PricingRules

  test "2_for_1 test" do
    voucher_sample = voucher_2_for_1_applied_sample()
    assert voucher_sample == PricingRules.pricing_rule_2_for_1(sample_checkout_cart(), "VOUCHER")

    tshirt_sample = PricingRules.pricing_rule_2_for_1(sample_checkout_cart(), "TSHIRT")
    tshirt_updated_element = Enum.find(tshirt_sample, fn x -> x["Code"] == "TSHIRT" end)

    assert {10.0, 4, "T-Shirt with discount"} ==
             {tshirt_updated_element["Price"], tshirt_updated_element["Quantity"],
              tshirt_updated_element["Name"]}
  end

  test "bulk test" do
    tshirt_sample =
      PricingRules.pricing_rule_bulk_purchase(sample_checkout_cart(), "TSHIRT", 3, 19.00)

    tshirt_updated_element = Enum.find(tshirt_sample, fn x -> x["Code"] == "TSHIRT" end)

    assert {19.0, 4, "T-Shirt with discount"} ==
             {tshirt_updated_element["Price"], tshirt_updated_element["Quantity"],
              tshirt_updated_element["Name"]}
  end

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

  def voucher_2_for_1_applied_sample do
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
        "Quantity" => 1,
        "ccy" => "€"
      },
      %{
        "Code" => "VOUCHER",
        "Name" => "Voucher with discount",
        "Price" => 2.5,
        "Quantity" => 2,
        "ccy" => "€"
      }
    ]
  end
end
