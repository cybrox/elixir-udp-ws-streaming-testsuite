defmodule Relay.Websocket do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init (:ok) do
    receiver_port = get_port_from_env("RELAY_IN")
    
    {:ok, receiver} = :gen_udp.open(receiver_port, Relay.buffer_opts() ++ [:binary])

    IO.puts "awaiting client"
    server = Socket.Web.listen!(8081)
    socket = server |> Socket.Web.accept!()
    socket |> Socket.Web.accept!()
    IO.puts "connected client"

    {:ok, %{
      receiver_port: receiver_port,
      receiver: receiver,
      socket: socket
    }}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    Socket.Web.send!(state.socket, {:binary, data})
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
