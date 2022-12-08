# ReadMe

# Checkout application - Challenge solution

## Install and start the application

Start with iex for development purposes

```bash
git@github.com:richgal/challenge.git challenge
cd challenge
mix deps.get
iex -S mix
```

Start as release

```bash
git@github.com:richgal/challenge.git challenge
cd challenge
mix deps.get --only prod
MIX_ENV=prod mix release
_build/prod/rel/challenge/bin/challenge start

_build/prod/rel/challenge/bin/challenge remote

_build/prod/rel/challenge/bin/challenge stop
```

## Demo

```bash
co = Checkout.new(:pricing_rule)
"a95ae504-2a0a-4ae6-ba78-b051f07683d6" # the id will be unique
Checkout.scan(co, "TSHIRT")
:ok
Checkout.scan(co, "MUG")
:ok
Checkout.scan(co, "VOUCHER")
:ok
Checkout.total(co)
"32.50€"
```

## Usage

### Add product

Add a new entry to the products.json file in the base folder. 

### Add pricing rule

1. Define price rule in the `PricingRules` module. Important! All pricing rules must take `checkout_cart()` type value as their first argument and return a `checkout_cart()` value.
2. The pricing rule must be part of a pricing rule set as a pipeline element. `PricingRulesSets`  module handles the set functions. e.g.

```elixir
def unique_ricing_rule_set(checkout_cart) do
    checkout_cart
    |> PricingRules.pricing_rule_2_for_1("VOUCHER")
    |> PricingRules.pricing_rule_bulk_purchase("TSHIRT", 3, 19.00)
    |> calculate_total("€")
  end
```

1. The pricing rule sets must end with a `calculate_total/2` function call. 
2. Once the pricing rule set is ready it must registered in the `pricing_rule_set_registry/0` funtcion. 

```elixir
def pricing_rule_set_registry do
    %{
      pricing_rule: &unique_ricing_rule_set/1,
      no_discout: &no_discount/1
    }
  end
```

1. A registered pricing rule set can be used as argument when calling `Checkout.new/1`. 

### Test

Just run `mix test` in the project folder. 

## Potential improvements

- manage items with different currencies
- load product list json to memory or to db so the prices could be queried individually
- remove cart from GenServer
- remove item from cart
- use map as GenServer state and cart id-s as keys

## Notes

- sequentally only one product can be added to one cart at a time
- it assumes only products will be scanned that are in the json
- The scan funtions only recognises the “Code” attributes of the items
