defmodule Mix.Tasks.MbtileUnpack do
  use Mix.Task

  @path "priv/static/static_tiles"
  def run(_) do
    {:ok, _started} = Application.ensure_all_started(:tile_server)

    TileServer.Mbtiles.query("select distinct(zoom_level) from tiles;")
    |> Enum.map(fn [zoom_level: zoom] -> process_zoom(zoom) end)
  end

  def process_zoom(zoom) do
    TileServer.Mbtiles.query(
      "select distinct(tile_column) from tiles where zoom_level = #{zoom} ;"
    )
    |> Enum.map(fn [tile_column: column] -> process_columns(zoom, column) end)
  end

  def process_columns(zoom, column) do
    mkdir(zoom, column)
    IO.inspect(column)
  end

  def mkdir(zoom, column) do
    path = Path.join([@path, Integer.to_string(zoom), Integer.to_string(column)])

    case File.mkdir_p(path) do
      :ok ->
        dump_files(zoom, column)

      error ->
        IO.inspect(error)
        IO.inspect(path)
        dump_files(zoom, column)
    end
  end

  def dump_files(zoom, column) do
    TileServer.Mbtiles.query(
      "select * from tiles where zoom_level = #{zoom} and tile_column = #{column} ;"
    )
    |> Enum.map(fn row -> save_file(row) end)
  end

  def save_file(row) do
    [
      zoom_level: zoom,
      tile_column: column,
      tile_row: y_stored,
      tile_data: {:blob, content}
    ] = row

    y = TileServer.Mbtiles.get_tms_y(y_stored, zoom)

    path =
      Path.join([
        @path,
        Integer.to_string(zoom),
        Integer.to_string(column),
        Integer.to_string(y) <> ".pbf.gz"
      ])

    File.write(path, content)
  end
end
