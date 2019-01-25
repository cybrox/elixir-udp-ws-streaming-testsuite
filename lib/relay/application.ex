defmodule Relay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = []

    # WS=true RELAY_IN=10666 iex -S mix
    # Expect UDP on RELAY_IN and send to ws connected on :8081
    children = if System.get_env("WS") == "true" do
      [{Relay.Websocket, []} | children]
    else
      children
    end

    # RELAY=true RELAY_IN=10666 RELAY_OUT=10667 SENDER=20666 iex -S mix
    # Expect UDP on RELAY_IN and send UDP on RELAY_OUT using SENDER port
    children = if System.get_env("RELAY") == "true" do
      [{Relay.Listener, []} | children]
    else
      children
    end
    
    # TESTER=true RELAY_IN=10666 RELAY_OUT=10667 SENDER=20667 iex -S mix
    # Send UDP to RELAY_IN via SENDER and expect echo on RELAY_OUT
    children = if System.get_env("TESTER") == "true" do
      [{Relay.Tester, []} | children]
    else
      children
    end

    # RECEIVER=true [DUMP=true] RELAY_IN=10666 iex -S mix
    # Expect UDP on RELAY_IN and DUMP to file if wanted
    children = if System.get_env("RECEIVER") == "true" do
      [{Relay.Receiver, []} | children]
    else
      children
    end

    # SIMULATOR=true RELAY_IN=10666 SENDER=20667 iex-S mix
    # Send UDP to RELAY_IN via SENDER from local capture file
    children = if System.get_env("SIMULATOR") == "true" do
      [{Relay.Simulator, []} | children]
    else
      children
    end

    if children == [], do: IO.puts "NO CHILDREN ACTIVE!"

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Relay.Supervisor]
    Supervisor.start_link(children, opts)
  end
end