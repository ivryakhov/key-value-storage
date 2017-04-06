##Тестируем как можно больше кейсов.
defmodule KVstoreTest do
  use ExUnit.Case, async: false

  test "create a storage element" do
    Storage.delete("key1")
    assert Storage.read("key1") == "no such element"
    assert Storage.create("key1", "value1", 40000) == "success"
    assert Storage.read("key1") == "value1"
  end

  test "create a storage element if already exist" do
     Storage.delete("key1_5")
     assert Storage.create("key1_5", "value1_5", 3000000) == "success"
     assert Storage.create("key1_5", "value1_7", 3453242) == "the element already exist"
  end

  test "read a storage element" do
     Storage.create("key2", "value2", 40000)
     assert Storage.read("key2") == "value2"
  end

  test "read an unexisten storage element" do
    assert Storage.read("never_exist") == "no such element"
  end

  test "update a storage element" do
    Storage.delete("key3")
    assert Storage.create("key3", "value3", 35000) == "success"
    assert Storage.read("key3") == "value3"
    assert Storage.update("key3", "new_value3") == "success"
    assert Storage.read("key3") == "new_value3"
  end

  test "update an unexisten element" do
    assert Storage.update("never_exist", "somevalue") == "no such element"
  end

  test "delete a storage element" do
    Storage.create("key4", "value4", 21004)
    assert Storage.delete("key4") == "success"
    assert Storage.read("key4") == "no such element"
  end  

  test "delete an unexistent storage element" do
    assert Storage.delete("never_exist") == "no such element"
  end


end
