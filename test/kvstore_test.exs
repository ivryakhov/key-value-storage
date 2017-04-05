##Тестируем как можно больше кейсов.
defmodule KVstoreTest do
  use ExUnit.Case, async: true

  test "create a storage element" do
    Storage.delete(:key1)
    assert Storage.read(:key1) == []
    assert Storage.create({:key1, "value1"}) == true
    assert Storage.read(:key1) == [{:key1, "value1"}]
  end

  test "read a storage element" do
     Storage.create({:key2, "value2"})
     assert Storage.read(:key2) == [{:key2, "value2"}]
  end

  test "update a storage element" do
    Storage.delete(:key3)
    Storage.create({:key3, "value3"})
    assert Storage.read(:key3) == [{:key3, "value3"}]
    assert Storage.update({:key3, "new_value3"}) == :ok
    assert Storage.read(:key3) == [{:key3, "new_value3"}]
  end

  test "delete a storage element" do
    Storage.create({:key4, "value4"})
    assert Storage.delete(:key4) == :ok
    assert Storage.read(:key4) == []
  end  
end
