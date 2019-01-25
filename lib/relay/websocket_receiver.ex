defmodule Relay.WebsocketReceiver do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init (:ok) do
    socket_port = get_port_from_env("WS_PORT")
    socket_host = System.get_env("WS_URL")
    socket_path = System.get_env("WS_PATH")

    socket = Socket.Web.connect!(socket_host, socket_port, path: socket_path)

    send(self(), :receive_data)

    {:ok, %{
      socket: socket
    }}
  end

  def handle_info(:receive_data, state) do
    data = Socket.Web.recv!(state.socket)
    IO.inspect data

    send(self(), :receive_data)
    {:noreply, state}
  end

  defp get_port_from_env(variable) do
    variable
    |> System.get_env()
    |> String.to_integer()
  end
end
