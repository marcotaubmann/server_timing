# ServerTiming

Time [plugs](https://hexdocs.pm/plug/Plug.html) and expose results through the [Server Timing Header](https://www.w3.org/TR/server-timing/).

Server Timing Header can be used to display execution times for parts of your application in the browsers development tools.

## Installation

```elixir
def deps do
  [
    {:server_timing, github: "marcotaubmann/server_timing", only: :dev}
  ]
end
```

## Usage in Phoenix


```elixir
# in your Endpoint 
defmodule MyAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :my_app

  # initialize ServerTiming
  use ServerTiming

  # ...
  
  # get timing from initialization until a specifig location in you endpoint
  timing_until "RequestId"
  plug Plug.RequestId

  # ...

  # get timing for multiple plugs
  start_timing "Some Plugs"
  plug Plug.MethodOverride
  plug Plug.Head
  stop_timing "Some Plugs"

  # get timing for single plug
  timing plug Plug.Session, @session_options

  # get timing from specifig location in you endpoint until before sending the response
  timing_from "Router"
  plug PhoenixTestWeb.Router
end
```

## License

ServerTiming source code is released under Apache License 2.0.

Check [LICENSE](LICENSE) file for more information.