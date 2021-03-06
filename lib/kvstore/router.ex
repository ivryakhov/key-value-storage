defmodule Router do
  @moduledoc """
  Routes request to web server for key/value storage usign.
  Sample requests:
      curl -d "" "http://localhost:8080/?key=my_key&value=value&ttl=20000"
      curl -G  "http://localhost:8080/?key=my_key"
      curl -X PUT "http://localhost:8080/?key=my_key&value=new_value"
      curl -X DELETE "http://localhost:8080/?key=my_key"
  """
  use Plug.Router

  plug :match
  plug :dispatch

  @reply_dict %{
    :no_element => "no such element",
    :success => "success",
    :failed_create => "failed to create the element",
    :already_exists => "the element already exists",
    :not_pos_ttl => "error: not posistive ttl value",
    :not_integer_ttl => "error: ttl must be an integer",
    :too_many_elements => "error: to many elements with the key provided",
    :failed_to_update => "failed to update the element",
    :failed_to_delete => "failed to delete"
  }

  
  get "/" do
    conn
    |> Plug.Conn.fetch_query_params
    |> read_element
    |> respond
  end

  post "/" do
    conn
    |> Plug.Conn.fetch_query_params
    |> add_element
    |> respond
  end

  put "/" do
    conn
    |> Plug.Conn.fetch_query_params
    |> update_element
    |> respond
  end

  delete "/" do
    conn
    |> Plug.Conn.fetch_query_params
    |> delete_element
    |> respond
  end

  match _, do: send_resp(conn, 404, "Oops!")

  defp add_element(conn) do
    {ttl, _} = Integer.parse(conn.params["ttl"])
    reply = Storage.create(conn.params["key"], conn.params["value"], ttl)
    Plug.Conn.assign(conn, :response, @reply_dict[reply])
  end

  defp read_element(conn) do
    reply = Storage.read(conn.params["key"])
    Plug.Conn.assign(conn, :response, reply)
  end

  defp update_element(conn) do
    reply = Storage.update(conn.params["key"], conn.params["value"])
    Plug.Conn.assign(conn, :response, @reply_dict[reply])
  end

  defp delete_element(conn) do
    reply = Storage.delete(conn.params["key"])
    Plug.Conn.assign(conn, :response, @reply_dict[reply])
  end

  defp respond(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, conn.assigns[:response])
  end
end

