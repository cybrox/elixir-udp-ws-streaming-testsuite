defmodule Relay.WebsocketReceiver do
  use GenServer

  @max_packets 50

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init (:ok) do
    will_dump = System.get_env("DUMP") == "true"
    socket_port = get_port_from_env("WS_PORT")
    socket_host = System.get_env("WS_URL")
    socket_path = System.get_env("WS_PATH")

    socket = Socket.Web.connect!(socket_host, socket_port, path: socket_path)

    send(self(), :receive_data)

    {:ok, %{
      socket: socket,
      dump: will_dump,
      packets: 0,
      payload: ""
    }}
  end

  def handle_info(:receive_data, state) do
    {:binary, data} = Socket.Web.recv!(state.socket)

    new_state = if state.dump do
      binary_data = data |> :binary.bin_to_list() |> Enum.map(&(Integer.to_string(&1))) |> Enum.join(",")
      payload = "#{get_timestamp()}::::#{binary_data};;;;"
      %{state | packets: state.packets + 1, payload: state.payload <> payload}
    else
      IO.inspect data
      state
    end

    if new_state.packets && new_state.dump == 1 do
      IO.puts "STARTED CAPTURING SOMETHING"
    end

    if new_state.packets == @max_packets do
      File.write("./record", new_state.payload)
      IO.puts "REACHED MAX NUMBER OF FRAMES TO CAPTURE"
    end

    send(self(), :receive_data)
    {:noreply, new_state}
  end

  defp get_timestamp do
    {mega, sec, micro} = :erlang.timestamp()
    ((mega * 1000000) + sec) * 1000000 + micro
  end

  defp get_port_from_env(variable) do
    variable
    |> System.get_env()
    |> String.to_integer()
  end
end
