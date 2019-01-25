defmodule Relay.WebsocketRelay do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init (:ok) do
    receiver_port = get_port_from_env("RELAY_IN")
    socket_port = get_port_from_env("WS_PORT")
    socket_host = System.get_env("WS_URL")
    socket_path = System.get_env("WS_PATH")

    {:ok, receiver} = :gen_udp.open(receiver_port, Relay.buffer_opts())

    socket = Socket.Web.connect!(socket_host, socket_port, path: socket_path)

    {:ok, %{
      receiver_port: receiver_port,
      receiver: receiver,
      socket: socket
    }}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    IO.inspect Enum.count(data)
    Socket.Web.send!(state.socket, {:binary, :binary.list_to_bin(data)})
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
