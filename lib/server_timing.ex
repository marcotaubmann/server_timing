defmodule ServerTiming do
  @moduledoc """
  Documentation for `ServerTiming`.
  """

  defmacro __using__(_opts) do
    quote do
      import ServerTiming,
        only: [timing_until: 1, timing_from: 1, start_timing: 1, stop_timing: 1, timing: 1]

      plug(ServerTiming, :init)
    end
  end

  defmacro timing_until(name) do
    quote do
      plug(ServerTiming, stop: unquote(name))
    end
  end

  defmacro timing_from(name) do
    quote do
      plug(ServerTiming, start: unquote(name))
    end
  end

  defmacro start_timing(name) do
    quote do
      plug(ServerTiming, start: unquote(name))
    end
  end

  defmacro stop_timing(name) do
    quote do
      plug(ServerTiming, stop: unquote(name))
    end
  end

  defmacro timing({:plug, _, [{:__aliases__, _, module_atom_parts} | _]} = the_plug) do
    name =
      module_atom_parts
      |> Enum.map(&to_string/1)
      |> Enum.join(".")

    quote do
      plug(ServerTiming, start: unquote(name))
      unquote(the_plug)
      plug(ServerTiming, stop: unquote(name))
    end
  end

  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(options), do: options

  @impl true
  def call(conn, :init) do
    conn
    |> put_private(:server_timing_starts, %{})
    |> call(start: :server_timing_init)
    |> register_before_send(&finish/1)
  end

  def call(conn, start: name) do
    starts =
      Map.put(
        conn.private[:server_timing_starts],
        name,
        System.monotonic_time()
      )

    put_private(conn, :server_timing_starts, starts)
  end

  def call(conn, stop: name) do
    {start, starts} = Map.pop(conn.private[:server_timing_starts], name)

    if start == nil do
      init_start = Map.get(conn.private[:server_timing_starts], :server_timing_init)
      put_timing(conn, "until", name, System.monotonic_time() - init_start)
    else
      put_timing(conn, "span", name, System.monotonic_time() - start)
    end
    |> put_private(:server_timing_starts, starts)
  end

  defp finish(conn) do
    starts = Map.delete(conn.private[:server_timing_starts], :server_timing_init)

    Enum.reduce(starts, conn, fn {name, start}, conn ->
      put_timing(conn, "from", name, System.monotonic_time() - start)
    end)
  end

  defp put_timing(conn, type, name, timing_native) when is_atom(name) do
    name = String.replace_leading(to_string(name), "Elixir.", "")
    put_timing(conn, type, name, timing_native)
  end

  defp put_timing(conn, type, name, timing_native) do
    timing = System.convert_time_unit(timing_native, :native, :microsecond) / 1000
    header = {"server-timing", ~s|#{type};desc="#{type} #{to_string(name)}";dur=#{timing}|}
    prepend_resp_headers(conn, [header])
  end
end
