##Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии.
defmodule Storage do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [{:name, __MODULE__}])
  end

  def create(key, value, ttl) do
    case read(key) do
      "no such element" -> 
        case GenServer.call(__MODULE__, {:create, {key, value, ttl}}) do
            true -> "success"
            false -> "failed to create the element"
        end
      _element -> "the element already exist"
    end
  end

  def read(key) do
    case GenServer.call(__MODULE__, {:read, key}) do
      :no_element -> "no such element"
      str_value -> str_value
    end
  end

  def update(key, value) do
    case read(key) do
      "no such element" -> "no such element"
      _element ->
        case GenServer.call(__MODULE__, {:update, {key, value}}) do
          :no_element -> "no such element"
          :too_many_elements -> "error: to many elements"
          :ok -> "success"
          _ -> "failed to create the element"
        end
    end
  end

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

  def stop() do
    GenServer.stop(__MODULE__)
  end
    

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

