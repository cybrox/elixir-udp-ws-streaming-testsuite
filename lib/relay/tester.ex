defmodule Relay.Tester do
  use GenServer

  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvxzy" |> String.split("", trim: true)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init (:ok) do
    receiver_port = get_port_from_env("RELAY_OUT")
    target_port = get_port_from_env("RELAY_IN")
    sender_port = get_port_from_env("SENDER")
    
    {:ok, receiver} = :gen_udp.open(receiver_port, Relay.buffer_opts())
    {:ok, sender} = :gen_udp.open(sender_port, Relay.buffer_opts())

    {:ok, %{
      receiver_port: receiver_port,
      sender_port: sender_port,
      target_port: target_port,
      receiver: receiver,
      sender: sender,
      data: nil
    }}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    received_data = List.to_string(data)
    IO.puts "OK! Received data"

    if received_data == state.data do
      IO.puts "OK! Data mached input"
    else
      IO.puts "ERR Data did not match"
      IO.inspect state.data
      IO.inspect received_data
    end

    {:noreply, state}
  end

  def handle_cast({:send_data, data}, state) do
    :gen_udp.send(state.sender, '127.0.0.1', state.target_port, data)

    {:noreply, %{state | data: data}}
  end
  
  def send_test_data(data) do
    GenServer.cast(__MODULE__, {:send_data, data})
  end

  def generate_test_data(length) do
    Enum.reduce((1..length), [], fn (_i, acc) ->
      [Enum.random(@chars) | acc]
    end) |> Enum.join("")
  end

  defp get_port_from_env(variable) do
    variable
    |> System.get_env()
    |> String.to_integer()
  end
end
