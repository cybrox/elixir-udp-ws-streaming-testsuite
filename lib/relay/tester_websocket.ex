defmodule Relay.TesterWebsocket do
  use GenServer

  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvxzy" |> String.split("", trim: true)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init (:ok) do
    sender_port = get_port_from_env("SENDER")
    target_port = get_port_from_env("RELAY_IN")
    socket_port = get_port_from_env("WS_PORT")
    socket_host = System.get_env("WS_URL")
    socket_path = System.get_env("WS_PATH")

    {:ok, sender} = :gen_udp.open(sender_port, Relay.buffer_opts())
    socket = Socket.Web.connect!(socket_host, socket_port, path: socket_path)

    {:ok, %{
      data: nil,
      socket: socket,
      target_port: target_port,
      sender_port: sender_port,
      sender: sender
    }}
  end

  def handle_info(:receive_data, state) do
    {:binary, received_data} = Socket.Web.recv!(state.socket)

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
    send(self(), :receive_data)

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
