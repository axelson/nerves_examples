defmodule Buzzy do
  use GenServer
  require Logger

  @read_pin_number 20
  @write_pin_number 21

  defmodule State do
    defstruct [:read_pin, :write_pin]
  end

  def start_link(_start) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    {:ok, read_pin} = Circuits.GPIO.open(@read_pin_number, :input)
    :ok = Circuits.GPIO.set_pull_mode(read_pin, :pulldown)
    {:ok, write_pin} = Circuits.GPIO.open(@write_pin_number, :output)

    state = %State{
      read_pin: read_pin,
      write_pin: write_pin
    }

    schedule_tick()

    {:ok, state}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    %State{read_pin: read_pin, write_pin: write_pin} = state
    Logger.info("Tick")

    # read from input
    val = Circuits.GPIO.read(read_pin)
    Logger.info("tick val: #{inspect(val)}")
    Circuits.GPIO.write(write_pin, val)

    schedule_tick()
    {:noreply, state}
  end

  defp schedule_tick do
    Process.send_after(__MODULE__, :tick, 10)
  end
end
