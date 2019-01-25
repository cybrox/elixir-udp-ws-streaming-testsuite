defmodule Relay.Listener do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init (:ok) do
    receiver_port = get_port_from_env("RELAY_IN")
    target_port = get_port_from_env("RELAY_OUT")
    sender_port = get_port_from_env("SENDER")
    
    {:ok, receiver} = :gen_udp.open(receiver_port, Relay.buffer_opts())
    {:ok, sender} = :gen_udp.open(sender_port, Relay.buffer_opts())

    {:ok, %{
      receiver_port: receiver_port,
      sender_port: sender_port,
      target_port: target_port,
      receiver: receiver,
      sender: sender
    }}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    IO.inspect Enum.count(data)

    # Will it work if we convert stuff?
    data = :binary.bin_to_list(:binary.list_to_bin(data))

    :gen_udp.send(state.sender, '192.168.1.55', state.target_port, data)
    {:noreply, state}
  end

  def handle_info({_, _socket}, state) do
    {:noreply, state}
  end

  defp get_port_from_env(variable) do
    variable
    |> System.get_env()
    |> String.to_integer()
  end
end
