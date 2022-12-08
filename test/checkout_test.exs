defmodule CheckoutTest do
  use ExUnit.Case, async: true
  alias Checkout
  doctest Checkout

  test "checkout case 1" do
    co = Checkout.new(:pricing_rule)
    Checkout.scan(co, "TSHIRT")
    Checkout.scan(co, "MUG")
    Checkout.scan(co, "VOUCHER")
    assert "32.50€" == Checkout.total(co)
  end

  test "checkout case 2" do
    co = Checkout.new(:pricing_rule)
    Checkout.scan(co, "VOUCHER")
    Checkout.scan(co, "TSHIRT")
    Checkout.scan(co, "VOUCHER")
    assert "25.00€" == Checkout.total(co)
  end

  test "checkout case 3" do
    co = Checkout.new(:pricing_rule)
    Checkout.scan(co, "TSHIRT")
    Checkout.scan(co, "TSHIRT")
    Checkout.scan(co, "TSHIRT")
    Checkout.scan(co, "VOUCHER")
    Checkout.scan(co, "TSHIRT")
    assert "81.00€" == Checkout.total(co)
  end

  test "checkout case 4" do
    co = Checkout.new(:pricing_rule)
    Checkout.scan(co, "VOUCHER")
    Checkout.scan(co, "TSHIRT")
    Checkout.scan(co, "VOUCHER")
    Checkout.scan(co, "VOUCHER")
    Checkout.scan(co, "MUG")
    Checkout.scan(co, "TSHIRT")
    Checkout.scan(co, "TSHIRT")
    assert "74.50€" == Checkout.total(co)
  end

end
