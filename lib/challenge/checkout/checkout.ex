defmodule Checkout do
  @moduledoc """
  This module implements a GenServer to keep the state individual checkout processes related carts (with product lists).
  """
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    Process.flag(:trap_exit, true)
    {:ok, []}
  end

  def call(message) do
    GenServer.call(__MODULE__, message)
  end

  @impl true
  def handle_call({:new_cart, cart}, _from, state) do
    new_state = [cart | state]
    {:reply, cart.cart_id, new_state}
  end

  @impl true
  def handle_call({:update_checkout_state, cart}, _from, state) do
    new_state = CheckoutFunctions.update_checkout_state(cart, state)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:get_cart, cart_id}, _from, state) do
    cart = CheckoutFunctions.get_cart_from_checkout_state(cart_id, state)
    {:reply, cart, state}
  end

  @impl true
  def handle_call({:checkout, cart}, _from, state) do
    new_state = [cart | state]
    {:reply, state, new_state}
  end
end
