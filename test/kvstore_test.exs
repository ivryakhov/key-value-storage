##Тестируем как можно больше кейсов.
defmodule KVstoreTest do
  use ExUnit.Case, async: false

  test "create a storage element" do
    Storage.delete("key1")
    assert Storage.read("key1") == :no_element
    assert Storage.create("key1", "value1", 40000) == :success
    assert Storage.read("key1") == "value1"
  end

  test "create a storage element if already exist" do
     Storage.delete("key1_5")
     assert Storage.create("key1_5", "value1_5", 3000000) == :success
     assert Storage.create("key1_5", "value1_7", 3453242) == :already_exists
  end

  test "try non-inger ttl value" do
    assert Storage.create("key1_8", "value1_8", :ttl) == :not_integer_ttl
    assert Storage.create("key1_8", "value1_8", "200000") == :not_integer_ttl
    assert Storage.create("key1_8", "value1_8", 20000.3453) == :not_integer_ttl
  end

  test "try negative ttl value" do
     assert Storage.create("key1_9", "vakue1_9", -90000) == :not_pos_ttl
  end

  test "read a storage element" do
     Storage.create("key2", "value2", 40000)
     assert Storage.read("key2") == "value2"
  end

  test "read an unexistent storage element" do
    assert Storage.read("never_exist") == :no_element
  end

  test "update a storage element" do
    Storage.delete("key3")
    assert Storage.create("key3", "value3", 35000) == :success
    assert Storage.read("key3") == "value3"
    assert Storage.update("key3", "new_value3") == :success
    assert Storage.read("key3") == "new_value3"
  end

  test "update an unexistent element" do
    assert Storage.update("never_exist", "somevalue") == :no_element
  end

  test "delete a storage element" do
    Storage.create("key4", "value4", 21004)
    assert Storage.delete("key4") == :success
    assert Storage.read("key4") == :no_element
  end  

  test "delete an unexistent storage element" do
    assert Storage.delete("never_exist") == :no_element
  end

  test "check if an element exists before ttl exceeding" do
    Storage.delete("5sec")
    assert Storage.create("5sec", "5000", 5000) == :success
    :timer.sleep(3000)
    assert  Storage.read("5sec") ==  "5000"
  end

  test "check if an element does not exist after ttl expiration" do
    Storage.delete("3sec")
    assert Storage.create("3sec", "3000", 3000) == :success
    :timer.sleep(5000)
    assert Storage.read("3sec") == :no_element
  end

  test "check if an element exist after storage open/closing" do
    Storage.delete("20sec")
    assert Storage.create("20sec", "20000", 20000) == :success
    Storage.stop()
    :timer.sleep(6000)
    assert Storage.read("20sec")  == "20000"
  end

  test "check if an elemen does not exist after storage restarting and ttl expiration" do
     Storage.delete("4sec")
     assert Storage.create("4sec", "4000", 4000) == :success
     Storage.stop()
     :timer.sleep(5000)
     assert Storage.read("4sec")  == :no_element
  end

  test "check if an element exist after storage open/closing but absent after ttl expiration" do
     Storage.delete("7sec")
     assert Storage.create("7sec", "7000", 7000) == :success
     Storage.stop()
     :timer.sleep(1000)
     assert Storage.read("7sec") == "7000"
     :timer.sleep(2000)
      assert Storage.read("7sec") == :no_element
  end

  test "the delete_after prosse shoud be kill with an element" do
    Storage.delete("phoenix")
    assert Storage.create("phoenix", "short-life", 5000) == :success
    assert Storage.delete("phoenix") == :success
    assert Storage.create("phoenix", "rebearth", 50000) == :success
    :timer.sleep(5000)
    assert Storage.read("phoenix") == "rebearth"
  end
     
end
