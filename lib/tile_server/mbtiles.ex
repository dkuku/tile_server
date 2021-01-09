defmodule TileServer.Mbtiles do
  def get_images(z, x, y) do
    query =
      "SELECT tile_data FROM tiles where zoom_level = ? and tile_column = ? and tile_row = ?"

    with {:ok, [data]} <- Sqlitex.Server.query(TilesDB, query, bind: [z, x, y]),
         [tile_data: tile_blob] <- data,
         {:blob, tile} <- tile_blob do
      tile
      #:zlib.gunzip(tile)
    else
      error ->
        IO.inspect(error)
        :error
    end
  end

  def get_metadata do
    query = "SELECT * FROM metadata"

    with {:ok, rows} <- Sqlitex.Server.query(TilesDB, query) do
      Enum.reduce(rows, %{}, fn [name: name, value: value], acc ->
        Map.put(acc, String.to_atom(name), value)
      end)
    else
      error -> IO.inspect(error)
    end
  end

  def query(query) do
    {:ok, rows} = Sqlitex.Server.query(TilesDB, query)
    rows
  end
end
