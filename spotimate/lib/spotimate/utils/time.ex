defmodule Spotimate.Utils.Time do
  def delayed_action(wait_ms, action) do
    Process.sleep(wait_ms)
    action.()
  end

  def now_utc_millis() do
    DateTime.utc_now() |> DateTime.to_unix(:millisecond)
  end

  def future_utc_millis(offset \\ 0) do
    now_utc_millis() + offset
  end
end
