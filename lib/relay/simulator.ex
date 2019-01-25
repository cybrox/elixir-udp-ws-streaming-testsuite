defmodule Relay.Simulator do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init (:ok) do
    target_port = get_port_from_env("RELAY_IN")
    sender_port = get_port_from_env("SENDER")
    do_loop = System.get_env("LOOP") == "true"
    
    {:ok, sender} = :gen_udp.open(sender_port, Relay.buffer_opts())

    data = 
      "./capture"
      |> File.read!()
      |> String.split(";;;;", tirm: true)
      |> Enum.filter(fn frame -> Enum.count(String.split(frame, "::::")) == 2 end)
      |> Enum.map(fn frame ->
        [timestamp, data] = String.split(frame, "::::")
        {timestamp, data}
      end)
      |> Enum.reduce({0, []}, fn ({ts, data}, {last_ts, acc}) ->
        actual_ts = String.to_integer(ts)
        delay = if last_ts == 0, do: 0, else: actual_ts - last_ts
        {actual_ts, acc ++ [{delay, data}]}
      end)
      |> elem(1)
      |> Enum.map(fn {delay, data} ->
        list_data = data |> String.split(",") |> Enum.map(&(String.to_integer(&1)))
        {round(delay / 1000), list_data}
      end)

    IO.puts "STARTING TO STREAM FROM FILE"
    send(self(), :stream)

    {:ok, %{
      sender_port: sender_port,
      target_port: target_port,
      sender: sender,
      data: data,
      frame: 0,
      loop: do_loop
    }}
  end

  def handle_info(:stream, state) do
    {_old_delay, data} = Enum.at(state.data, state.frame)
    {new_delay, _data} = Enum.at(state.data, state.frame + 1, {nil, nil})

    new_state = if new_delay do
      IO.inspect Enum.count(data)
      :gen_udp.send(state.sender, '127.0.0.1', state.target_port, data)
      Process.send_after(self(), :stream, new_delay)
      %{state | frame: state.frame + 1}
    else
      if state.loop do
        Process.send_after(self(), :stream, 0)
        IO.puts "LOOPING STREAM AT PACKET #{state.frame}"
        %{state | frame: 0}
      else
        IO.puts "STREAMING ENDED AT PACKET #{state.frame}"
        state
      end
    end

    {:noreply, new_state}
  end

  defp get_port_from_env(variable) do
    variable
    |> System.get_env()
    |> String.to_integer()
  end
end
