##Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии.
defmodule Storage do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [{:name, __MODULE__}])
  end

  def create(key, value, ttl) do
    case read(key) do
      :no_element -> GenServer.call(__MODULE__, {:create, {key, value, ttl}})
      _element -> false
    end
  end

  def read(key) do
    GenServer.call(__MODULE__, {:read, key})
  end

  def update(key, value, ttl) do
    case read(key) do
      :no_element -> false
      _element -> GenServer.call(__MODULE__, {:update, {key, value, ttl}})
    end
  end

  def delete(key) do
    case read(key) do
      :no_element -> false
      _element -> GenServer.call(__MODULE__, {:delete, key})
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

  def handle_call({:update, {key, value, ttl}}, _from, table) do
    {:reply, Storage.Driver.update_element(table, {key, value, ttl}), table}
  end

  def handle_call({:delete, key}, _from, table) do
    {:reply, Storage.Driver.delete_element(table, key), table}
  end

  def terminate(_reason, table) do
    Storage.Driver.close_storage(table)
    {:ok}
  end
  
end

