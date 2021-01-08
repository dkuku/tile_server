defmodule TileServer.Mbtiles do
  def get_images(z, x, y) do
    Sqlitex.with_db('priv/united_kingdom.mbtiles', fn db ->
      {:ok, statement} =
        Sqlitex.Statement.prepare(
          db,
          "SELECT tile_data FROM tiles where zoom_level = ? and tile_column = ? and tile_row = ?"
        )

      Sqlitex.Statement.bind_values(statement, [z, x, y])

      {:row, data} = Sqlitex.Statement.exec(statement)

      data
      |> elem(0)
      |> elem(1)
      |> :zlib.gunzip()
    end)
  end

  def get_image_boundaries do
    Sqlitex.with_db('priv/united_kingdom.mbtiles', fn db ->
      {:ok, statement} =
        Sqlitex.Statement.prepare(
          db,
          "SELECT min(zoom_level),  max(zoom_level), min(tile_column), max(tile_column), min(tile_row), max(tile_row) FROM tiles"
        )

      Sqlitex.Statement.bind_values(statement, [])

      {:row, data} = Sqlitex.Statement.exec(statement)

      IO.inspect(data)
    end)
  end

  def get_metadata do
    Sqlitex.with_db('priv/united_kingdom.mbtiles', fn db ->
      {:ok, statement} =
        Sqlitex.Statement.prepare(
          db,
          "SELECT * FROM metadata"
        )

      Sqlitex.Statement.bind_values(statement, [])

      {:ok, rows} = Sqlitex.Statement.fetch_all(statement)

      rows
      |> Enum.reduce(%{}, fn [name: name, value: value], acc -> Map.put(acc, name, value) end)
    end)
  end

  def query(query) do
    Sqlitex.with_db('priv/united_kingdom.mbtiles', fn db ->
      {:ok, statement} = Sqlitex.Statement.prepare(db, query)
      Sqlitex.Statement.bind_values(statement, [])

      Sqlitex.Statement.fetch_all(statement)
    end)
  end
end
