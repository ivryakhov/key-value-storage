##Тестируем как можно больше кейсов.
defmodule KVstoreTest do
  use ExUnit.Case, async: true

  test "create a storage element" do
    Storage.delete(:key1)
    assert Storage.read(:key1) == :no_element
    assert Storage.create(:key1, "value1", 40000) == true
    assert Storage.read(:key1) == "value1"
  end

  test "create a storage element if already exist" do
     Storage.delete(:key1_5)
     assert Storage.create(:key1_5, "value1_5", 3000000) == true
     assert Storage.create(:key1_5, "value1_7", 3453242) == false
  end

  test "read a storage element" do
     Storage.create(:key2, "value2", 40000)
     assert Storage.read(:key2) == "value2"
  end

  test "read an unexisten storage element" do
    assert Storage.read(:never_exist) == :no_element
  end

  test "update a storage element" do
    Storage.delete(:key3)
    assert Storage.create(:key3, "value3", 35000) == true
    assert Storage.read(:key3) == "value3"
    assert Storage.update(:key3, "new_value3", 35000) == :ok
    assert Storage.read(:key3) == "new_value3"
  end

  test "update an unexisten element" do
    assert Storage.update(:never_exist, "somevalue", 3453) == false
  end

  test "delete a storage element" do
    Storage.create(:key4, "value4", 21004)
    assert Storage.delete(:key4) == :ok
    assert Storage.read(:key4) == :no_element
  end  

  test "delete an unexistent storage element" do
    assert Storage.delete(:never_exist) == false
  end

end
