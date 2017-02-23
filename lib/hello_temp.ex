defmodule HelloTemp do
  use Application

  @moduledoc """
    Simple example to read temperature from DS18B20 temperature sensor
    For the longer sensors red - 3.3v, yellow - GND, and green - signal 
    For the short sensors  red - 3.3v, black - GND, and yellow - signal 
  """

  require Logger

  @base_dir "/sys/bus/w1/devices/"

  def start(_type, _args) do
    Logger.debug "Start measuring temperature..."
    spawn(fn ->  read_temp_forever() end)
    {:ok, self()}
  end

  defp read_temp_forever do
    File.ls!(@base_dir)
      |> Enum.filter(&(String.starts_with?(&1, "28-")))
      |> Enum.each(&read_temp(&1, @base_dir))

    :timer.sleep(1000)
    read_temp_forever()
  end

  defp read_temp(sensor, base_dir) do
    sensor_data = File.read!("#{base_dir}#{sensor}/w1_slave")
    # Logger.debug("reading sensor: #{sensor}: #{sensor_data}")
    {temp, _} = Regex.run(~r/t=(\d+)/, sensor_data)
    |> List.last
    |> Float.parse
    Logger.debug "#{temp*9/5000+32} F"
  end

end
