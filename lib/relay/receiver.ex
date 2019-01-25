defmodule Relay.Receiver do
  use GenServer

  @max_packets 100

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init (:ok) do
    receiver_port = get_port_from_env("RELAY_IN")
    will_dump = System.get_env("DUMP") == "true"

    {:ok, receiver} = :gen_udp.open(receiver_port, Relay.buffer_opts())

    {:ok, %{
      receiver_port: receiver_port,
      receiver: receiver,
      dump: will_dump,
      packets: 0,
      payload: ""
    }}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    IO.inspect Enum.count(data)

    new_state = if state.dump do
      binary_data = data |> Enum.map(&(Integer.to_string(&1))) |> Enum.join(",")
      payload = "#{get_timestamp()}::::#{binary_data};;;;"
      %{state | packets: state.packets + 1, payload: state.payload <> payload}
    else
      IO.inspect data
      state
    end

    if new_state.packets && new_state.dump == 1 do
      IO.puts "STARTED CAPTURING SOMETHING"
    end

    if new_state.packets > @max_packets do
      File.write("./capture", new_state.payload)
      IO.puts "REACHED MAX NUMBER OF FRAMES TO CAPTURE"
    end

    {:noreply, new_state}
  end

  def handle_info({_, _socket}, state) do
    {:noreply, state}
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
