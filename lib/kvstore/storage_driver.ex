defmodule Storage.Driver do
  @moduledoc """
  Implemenets interaction with the Disk Based Term Storage.
  Separated to keep the storage inetrace independet of the storage choosen
  """
  require Logger
 
  @doc """
  Initializes a storage
  """
  def initialize_storage() do
    storage_name = Application.get_env(:kvstore, :storage_name, :disk_storage)
    initialize_ttl(storage_name)
  end

  @doc """
  Creates a key/value element in the storage.
  Creates a process which deletes the element after the ttl exceeding.
  """
  def create_element(storage_ref, {key, value, ttl}) do
    Task.start fn -> delete_element_after(storage_ref, key, ttl) end
    :dets.insert_new(storage_ref, {key,value, ttl, DateTime.utc_now |> DateTime.to_unix})
  end

  @doc """
  Reads an element by key
  """
  def read_element(storage_ref, key) do
    case :dets.lookup(storage_ref, key) do
      [] -> :no_element
      [{_key, value, _ttl, _timestamp}] -> value
      [_|_] -> :too_many_elements
    end
  end

  @doc """
  Update an element's value by a key
  """
  def update_element(storage_ref, {key, value}) do
    case :dets.lookup(storage_ref, key) do
      [] -> :no_element
      [{key, _pvalue, ttl, timestamp}] -> :dets.insert(storage_ref, {key, value, ttl, timestamp})
      [_|_] -> :too_many_elements
    end
  end

  @doc """
  Updates an element's ttl during a storage initialization
  """
  defp update_element_ttl(storage_ref, {key, ttl}) do
    case :dets.lookup(storage_ref, key) do
      [] -> :no_element
      [{key, value, _pttl, timestamp}] -> :dets.insert(storage_ref, {key, value, ttl, timestamp})
      [_|_] -> :too_many_elements
    end
  end

  @doc """
  Deletes an element by a key
  """
  def delete_element(storage_ref, key) do
    :dets.delete(storage_ref, key)
  end

  @doc """
  Closes a connection to the storage
  """
  def close_storage(storage_ref) do
     :dets.close(storage_ref)
  end

  @doce """
  Opens a connection to the storage
  """
  defp open_file(storage_name) do
    {:ok, storage_ref} = :dets.open_file(storage_name, [type: :set])
    storage_ref
  end

  @doc """
  For each existing element, check if the time to live of the element is exceeded.
  If true, deletes the element. Overwise, updates a ttl in the storage with an actual value
  """
  defp initialize_ttl(storage_name) do
    storage_ref = open_file(storage_name)
    :ok = process_elements(storage_ref, :dets.first(storage_ref))
    storage_ref
  end

  @doc """
  Deletes an element after ttl exceeding.
  """
  defp delete_element_after(storage_ref, key, ttl) do
    receive do
      {:update_ttl, new_ttl} -> delete_element_after(storage_ref, key, new_ttl)
    after
      ttl -> delete_element(storage_ref, key)
    end
  end

  @doc """
  Initialize a ttl for each eleemnt in an existing storage
  """
  defp process_elements(_str_ref, :"$end_of_table") do
    :ok
  end

  defp process_elements(storage_ref, key) do
        [{key, _value, ttl, timestamp}] = :dets.lookup(storage_ref, key)
        current_time =  DateTime.utc_now |> DateTime.to_unix
        time_elapsed_in_sec = current_time - timestamp
        ttl_diff = ttl - (time_elapsed_in_sec * 1000)
        if ttl_diff > 0 do
          update_element_ttl(storage_ref, {key, ttl_diff})
          Task.start fn -> delete_element_after(storage_ref, key, ttl_diff) end
        else
          delete_element(storage_ref, key)
        end

        process_elements(storage_ref, :dets.next(storage_ref, key))
  end

end
