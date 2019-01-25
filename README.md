# Elixir H.264 UDP Websocket Test Suite

## Streaming from UDP to Websocket
Expect UDP on `RELAY_IN` and send to ws connected on :8081

```bash
WS=true RELAY_IN=10666 iex -S mix
```

## Relaying an incoming UDP stream
Expect UDP on `RELAY_IN` and send UDP on `RELAY_OUT` using `SENDER` port

```bash
RELAY=true RELAY_IN=10666 RELAY_OUT=10667 SENDER=20666 iex -S mix
```

## Testing the UDP relay echo functionality
Send UDP to `RELAY_IN` via `SENDER` and expect echo on `RELAY_OUT`

```bash
TESTER=true RELAY_IN=10666 RELAY_OUT=10667 SENDER=20667 iex -S mix
```

## Record UDP traffic and save to file
Expect UDP on `RELAY_IN` and `DUMP` to `./recording` file if wanted

```bash
RECEIVER=true [DUMP=true] RELAY_IN=10666 iex -S mix
```

## Dispatch recorded UDP traffic
Send UDP to `RELAY_IN` via `SENDER` from local `./recording` file

```bash
SIMULATOR=true RELAY_IN=10666 SENDER=20667 iex-S mix
```
