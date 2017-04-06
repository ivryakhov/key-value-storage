defmodule Storage.Driver do
 
  @storage_name :disk_storage
    
  def initialize_storage() do
    case :dets.info(@storage_name) do
      :undefined -> open_file(@storage_name)
      _InfoList  -> initialize_ttl(@storage_name)
    end
  end

  def create_element(storage_ref, {key, value, ttl}) do
    Task.start fn -> delete_element_after(storage_ref, key, ttl) end
    :dets.insert_new(storage_ref, {key,value, ttl, DateTime.utc_now |> DateTime.to_unix})
  end

  def read_element(storage_ref, key) do
    case :dets.lookup(storage_ref, key) do
      [] -> :no_element
      [{_key, value, _ttl, _timestamp}] -> value
      [_|_] -> :too_many_elements
    end
  end

  def update_element(storage_ref, {key, value, ttl}) do
    case :dets.lookup(storage_ref, key) do
      [] -> :no_element
      [{key, _pvalue, _pttl, timestamp}] -> :dets.insert(storage_ref, {key, value, ttl, timestamp})
      [_|_] -> :too_many_elements
    end
  end

  def delete_element(storage_ref, key) do
    :dets.delete(storage_ref, key)
  end

  def close_storage(storage_ref) do
     :dets.close(storage_ref)
  end

  defp open_file(storage_name) do
    {:ok, storage_ref} = :dets.open_file(storage_name, [type: :set])
    storage_ref
  end

  defp initialize_ttl(storage_name) do
    storage_ref = open_file(storage_name)
    :ok = process_elements(storage_ref, :dets.first(storage_ref))
    storage_ref
  end

  defp delete_element_after(storage_ref, key, ttl) do
    receive do
      {:update_ttl, new_ttl} -> delete_element_after(storage_ref, key, new_ttl)
    after
      ttl -> delete_element(storage_ref, key)
    end
  end

  defp process_elements(_str_ref, :"$end_of_table") do
    :ok
  end

  defp process_elements(storage_ref, key) do
        [{key, value, ttl, timestamp}] = :dets.lookup(storage_ref, key)
        current_time =  DateTime.utc_now |> DateTime.to_unix
        time_elapsed_in_sec = current_time - timestamp
        ttl_diff = time_elapsed_in_sec * 1000 - ttl
        if ttl_diff > 0 do
          update_element(storage_ref, {key, value, ttl_diff})
          delete_element_after(storage_ref, key, ttl_diff)
        else
          delete_element(storage_ref, key)
        end

        process_elements(storage_ref, :dets.next(storage_ref, key))
  end

end
