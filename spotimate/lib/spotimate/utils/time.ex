defmodule Spotimate.Utils.Time do
  
  def delayed_action(wait_ms, action) do
    Process.sleep(wait_ms)
    action.()
  end

end