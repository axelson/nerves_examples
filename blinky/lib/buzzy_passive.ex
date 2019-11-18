defmodule BuzzyPassive do
  use GenServer
  require Logger

  @write_pin_number 16

  defmodule State do
    defstruct [:write_pin, :current_value, :sleep_time]
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    {:ok, write_pin} = Circuits.GPIO.open(@write_pin_number, :output)
    IO.inspect(write_pin, label: "write_pin")

    state = %State{
      write_pin: write_pin,
      current_value: 0,
      sleep_time: Keyword.get(opts, :sleep_time, 10)
    }

    schedule_tick(state)

    {:ok, state}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    %State{current_value: current_value, write_pin: write_pin} = state
    Logger.info("Tick")

    # read from input
    Logger.info("tick val: #{inspect(current_value)}")
    Circuits.GPIO.write(write_pin, current_value)

    schedule_tick(state)

    state = %State{state | current_value: next_value(current_value)}
    {:noreply, state}
  end

  defp next_value(0), do: 1
  defp next_value(1), do: 0

  defp schedule_tick(state) do
    %State{sleep_time: sleep_time} = state
    Process.send_after(__MODULE__, :tick, sleep_time)
  end
end
