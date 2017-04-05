##Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии.
defmodule Storage do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [{:name, __MODULE__}])
  end

  def create({key, value}) do
    GenServer.call(__MODULE__, {:create, {key, value}})
  end

  def read(key) do
    GenServer.call(__MODULE__, {:read, key})
  end

  def update({key, value}) do
    GenServer.call(__MODULE__, {:update, {key, value}})
  end

  def delete(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end
    

  def init([]) do
    {:ok, table} = :dets.open_file(:disk_storage, [type: :set])
    {:ok, table}
  end

  def handle_call({:create, {key, value}}, _from, table) do
    {:reply, :dets.insert_new(table, {key, value}), table}
  end

  def handle_call({:read, key}, _from, table) do
    {:reply, :dets.lookup(table, key), table}
  end

  def handle_call({:update, {key, value}}, _from, table) do
    {:reply, :dets.insert(table, {key, value}), table}
  end

  def handle_call({:delete, key}, _from, table) do
    {:reply, :dets.delete(table, key), table}
  end
  
end

