defmodule Relay do
  def buffer_opts do
    [
      buffer: 50000,
      recbuf: 50000,
      sndbuf: 50000
    ]
  end
end
