defmodule Storage do
  @moduledoc"""
  Implements a genserver for key/valye storing interface and interaction with other modules
  """
  use GenServer
  require Logger

  @doc """
  External API
  """

  def start_link do
    Logger.info "Started storage server"
    GenServer.start_link(__MODULE__, [], [{:name, __MODULE__}])
  end


  @doc """
  Client API


  Creates an element in a storage.
  Does not create if the element with key provided already exist.
  Parameters:
      key - string
      value - string
      ttl - integer
  Output:
      string - result of the operation
  """
  def create(key, value, ttl) do
    case is_integer(ttl) do
      true ->
        case ttl >= 0 do
          true ->
            case read(key) do
              "no such element" -> 
                case GenServer.call(__MODULE__, {:create, {key, value, ttl}}) do
                  true -> "success"
                  false -> "failed to create the element"
                end
              _element -> "the element already exist"
            end
          false ->
            "error: not posistive ttl value"
        end
      false -> "error: ttl must be an integer"
    end
  end


  @doc """
  Reads an element from a storage by a key
  Parameters:
      key - string
  Output:
    string  - result of the operation
  """
  def read(key) do
    case GenServer.call(__MODULE__, {:read, key}) do
      :no_element -> "no such element"
      str_value -> str_value
    end
  end


  @doc """
  Updates an element value in a storage by a key
  Parameters:
      key - string
      value - string
  Output:
      string - result of the operation
  """
  def update(key, value) do
    case read(key) do
      "no such element" -> "no such element"
      _element ->
        case GenServer.call(__MODULE__, {:update, {key, value}}) do
          :no_element -> "no such element"
          :too_many_elements -> "error: to many elements with the key provided"
          :ok -> "success"
          _ -> "failed to update the element"
        end
    end
  end


  @doc """
  Deletes an element from a storage by a key
  Parameters:
      key - string
  Output:
      string -  result of the operation
  """
  def delete(key) do
    case read(key) do
      "no such element" -> "no such element"
      _element -> 
        case GenServer.call(__MODULE__, {:delete, key}) do
          :ok -> "success"
          _ -> "failed to delete"
        end
    end
  end

  @doc """
  Stops the server
  """
  def stop() do
    GenServer.stop(__MODULE__)
  end

  
  @doc """
  GenServer callbacks
  """
  def init([]) do
    table = Storage.Driver.initialize_storage()
    {:ok, table}
  end

  def handle_call({:create, {key, value, ttl}}, _from, table) do
    {:reply, Storage.Driver.create_element(table, {key, value, ttl}), table}
  end

  def handle_call({:read, key}, _from, table) do
    {:reply, Storage.Driver.read_element(table, key), table}
  end

  def handle_call({:update, {key, value}}, _from, table) do
    {:reply, Storage.Driver.update_element(table, {key, value}), table}
  end

  def handle_call({:delete, key}, _from, table) do
    {:reply, Storage.Driver.delete_element(table, key), table}
  end

  def terminate(_reason, table) do
    Storage.Driver.close_storage(table)
    {:ok}
  end
end

