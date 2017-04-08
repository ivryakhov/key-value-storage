defmodule KVstore do
  @moduledoc"""
  This app implements a key/value storage with TTL support
  and saving a state to a filesystem

  The app replys on http requests. Example usage:

  Create a key/value element:
      curl -d "" "http://localhost:8080/?key=my_key&value=value&ttl=20000"

  Read a key/value element:
      curl -G  "http://localhost:8080/?key=my_key"

  Update an element:
      curl -X PUT "http://localhost:8080/?key=my_key&value=new_value"

  Delete an element:
      curl -X DELETE "http://localhost:8080/?key=my_key"
  """

  use Application
  require Logger

  @doc"""
  Starts the key/value storage server and cowboy server.
  """
  def start(_type, _args) do
    Logger.info "Started application"
    KVstore.Supervisor.start_link
  end
end
