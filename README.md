# Elixir UDP & WS Streaming Test Suite
This repository is a collection of tools that are helpful when working with UDP and Websocket streaming and relays. This code is untested (kind of, some functions test their counterpart) and not intended for use as-is.    

Also, the code in this repository is very pragmatic and lacks a lot of error handling / retries. The intended use of this repository is to serve as a reference and starting point for people who want to work with UDP and Websocket streaming or for quickly testing your own implementations. We use proper implementations of the functions exposed here for realtime H.264 video streaming.

* Recording UDP traffic to a file
* Recording WS traffic to a file
* Relaying UDP traffic to UDP
* Relaying UDP traffic to Websocket
* Testing a UDP to UDP relay
* Testing a UDP to Websocket relay
* Send recorded UDP traffic with original packet timing

---

## Functionality

**Connect to websocket and output received data**   
Connects to websocket on `WS_URL:WS_PORT` with `WS_PATH`    
Will output all received data or store it to a file

```bash
WSRECEIVER=true WS_URL=127.0.0.1 WS_PORT=9091 WS_PATH="/producer?stream_id=test" iex -S mix
```


**Streaming from UDP to websocket clients**    
Expect UDP on `RELAY_IN` and send to ws connected on :8081    
This is used as a direct replacement for visio

```bash
WS=true RELAY_IN=10666 iex -S mix
```

**Streaming from UDP to a websocket server**    
Expect UDP on `RELAY_IN` relay the data to `WS_TARGET`    
This is what will eventually be implemented on the AVC1

```bash
WSRELAY=true RELAY_IN=10666 WS_URL=127.0.0.1 WS_PORT=9091 WS_PATH="/producer?stream_id=test" iex -S mix
```

**Relaying an incoming UDP stream**    
Expect UDP on `RELAY_IN` and send UDP on `RELAY_OUT` using `SENDER` port

```bash
RELAY=true RELAY_IN=10666 RELAY_OUT=10667 SENDER=20666 iex -S mix
```

**Testing the UDP relay echo functionality**    
Send UDP to `RELAY_IN` via `SENDER` and expect echo on `RELAY_OUT`

```bash
TESTER=true RELAY_IN=10666 RELAY_OUT=10667 SENDER=20667 iex -S mix
```


**Testing the UDP to Websocket relay**     
Expect UDP on `RELAY_IN` and checks if the same data is returned via websocket
```bash
WSTESTER=true RELAY_IN=10667 WS_URL=127.0.0.1 WS_PORT=8081 WS_PATH="/" iex -S mix
```

**Record UDP traffic and save to file**    
Expect UDP on `RELAY_IN` and `DUMP` to `./recording` file if wanted

```bash
RECEIVER=true [DUMP=true] RELAY_IN=10666 iex -S mix
```

**Dispatch recorded UDP traffic**    
Send UDP to `RELAY_IN` via `SENDER` from local `./recording` file

```bash
SIMULATOR=true RELAY_IN=10666 SENDER=20667 iex-S mix
```
