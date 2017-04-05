#Это точка входа в приложение.
defmodule KVstore do
  use Application

  def start(_type, _args) do
    Storage.start_link
  end
end
