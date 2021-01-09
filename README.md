# TileServer

Some background on mbtiles files from [mapbox/mbtiles-spec](https://github.com/mapbox/mbtiles-spec/blob/master/1.3/spec.md)

> MBTiles is a specification for storing tiled map data in SQLite databases for immediate usage and for transfer.
> ...
> The metadata table is used as a key/value store for settings. It MUST contain these two rows:

> name (string): The human-readable name of the tileset.
> format (string): The file format of the tile data: pbf, jpg, png, webp, or an IETF media type for other formats.

We can download an example file from [openmaptiles](https://openmaptiles.org/) or render some ourselves from openstreetmap data. In this tutorial I'll use a file has bundled the assets as `*.pbf` because it's the most complicated format to set up. With images you don't need any plugins for leaflet and the rendering should be much faster in user browser.

 `# sqlite3 priv/united_kingdom.mbtiles`
 ```   
    After downloading a file we can have a look whats really inside:
    sqlite> .headers on
    sqlite> .tables
    gpkg_contents  gpkg_tile_matrix    omtm    
    gpkg_geometry_columns    gpkg_tile_matrix_setpackage_tiles
    gpkg_metadata  images    tiles   
    gpkg_metadata_reference  map
    gpkg_spatial_ref_sysmetadata
```
    
We are interested in tiles and metadata tables:
`sqlite> select * from tiles limit 1;`

zoom_level | tile_column | tile_row | tile_data
--- | --- | --- | ---
14    | 7763   | 10757    |
    
`sqlite> select * from metadata where name is not 'json';`

name   | value
--- | ---
attribution | <a href="http://www.openmaptiles.org/"
center | -3.5793274999999998,55.070035000000004,14
description | Extract from https://openmaptiles.org
maxzoom| 14
minzoom| 0
name   | OpenMapTiles
pixel_scale | 256
mtime  | 1499626373833
format | pbf
id| openmaptiles
version| 3.6.1
maskLevel   | 5
bounds | -9.408655,49.00443,2.25,61.13564
planettime  | 1499040000000
basename    | europe_great-britain.mbtiles
   
The tiles table keeps our tiles - these can be searched by row/column and zoom level and the metadata table has our info about this database.

To use it we will create a new phoenix project
`mix phx.new tile_server --no-ecto --no-html --no-webpack`
We will skip the main libraries to simplify it a bit, the only addition we need is a library to connect with sqlite database:
`{:sqlitex, "~> 1.7"}`
we want to run it under superisor, for that we need to change the config.exs and application.ex
```elixir
config :tile_server, mbtiles_path: "priv/united_kingdom.mbtiles"
```
```elixir
children = [
   .....,
 %{
   id: Sqlitex.Server,
   start: {Sqlitex.Server, :start_link,
 [Application.get_env(:tile_server, :mbtiles_path), [name: TilesDB]]}
 }
]
```
First thing we need to do is parse the metadata - in a new file `TileServer.Mbtiles` I'll create a function that does it
```elixir
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
```
to check if its working we can display it on the homepage, the router needs to be modified:
```elixir
  pipeline :browser do
    plug :accepts, ["html"]
  end
  scope "/", TileServerWeb do
    pipe_through :browser
    get "/", MapController, :index
  end
```
and new map_controller.ex
```elixir
defmodule TileServerWeb.MapController do
  use TileServerWeb, :controller
  alias TileServer.Mbtiles

  def index(conn, _params) do
    meta = Mbtiles.get_metadata()
    text(conn, inspect(meta))
  end
end
```
Ok, this works, other route is for getting the tiles, we need to create another function in our context:
```elixir
  def get_images(z, x, y) do
    query =
"SELECT tile_data FROM tiles where zoom_level = ? and tile_column = ? and tile_row = ?"

    with {:ok, [data]} <- Sqlitex.Server.query(TilesDB, query, bind: [z, x, y]),
    [tile_data: tile_blob] <- data,
    {:blob, tile} <- tile_blob, do: tile
  end
```
Here we are using bind params to avoid sql injection attacks. We also are returning the data from the database without unpacking. To allow the client to process the compressed files we need to set a setting a content encoding header
`{"content-encoding", "gzip"}`
```elixir
  def tile(conn, params) do
    %{z: z, x: x, y: y} = parse_tile_params(params)

    case Mbtiles.get_images(z, x, get_tms_y(z, y)) do
 :error ->
   conn |> send_resp(404, "tile not found")

 tile ->
   conn
   |> prepend_resp_headers([{"content-encoding", "gzip"}])
   |> put_resp_content_type("application/octet-stream")
   |> send_resp(200, tile)
    end
  end

  defp get_tms_y(z, y), do: round(:math.pow(2, z) - 1 - y)

  defp parse_tile_params(params) do
    params
    |> Enum.map(fn {k, v} -> {String.to_atom(k), String.to_integer(v)} end)
    |> Map.new()
  end
```
The other thing that weird is the get_tms_y function - many of the mbtiles files are stored with the y coordinate in reverse order this can be easily seen if the tiles are aligned weirdly when displayed. This param needs to be recalculated. 
And the last puzzle piece is the router entry for our tiles
```
    get "/", MapController, :index
    get "/tiles/:z/:x/:y", MapController, :tile
```
Now we are good to go, My only bottleneck was showing the vector tiles in the browser full screen - this takes some time because the browser needs to process all the data. 
But phoenix does here a good job:
```
[info] GET /tiles/14/9050/5531   
[info] Sent 200 in 3ms 
[info] GET /tiles/14/9048/5528
[info] GET /tiles/14/9048/5530
[info] GET /tiles/14/9049/5527
[info] GET /tiles/14/9051/5527
[info] Sent 200 in 3ms 
[info] Sent 200 in 4ms 
[info] Sent 200 in 4ms 
[info] Sent 200 in 5ms 
[info] GET /tiles/14/9051/5528   
[info] Sent 200 in 6ms 
[info] GET /tiles/14/9048/5529   
[info] GET /tiles/14/9049/5530   
[info] GET /tiles/14/9052/5529   
[info] GET /tiles/14/9050/5527   
[info] GET /tiles/14/9051/5530   
[info] Sent 200 in 3ms 
[info] Sent 200 in 4ms 
[info] Sent 200 in 4ms 
[info] Sent 200 in 5ms 
[info] Sent 200 in 5ms 
```
There is also an alternative to just unpack the files and serve it form the `/priv/static` folder.
To serve it this way we need [mb-util](https://github.com/mapbox/mbutil) app installed - The files are compressed, so we need either unpack them or rename to have `.gz` extension - then phoenix will serve it gzipped and add the header for us. 
```
./mb-util --image_format=pbf countries.mbtiles static_tiles
```
```
# add gz extension
find . -type f -exec mv {} {}.gz ';'

or
# unpack and store unpacked
gzip -d -r -S .pbf *
find . -type f -exec mv '{}' '{}'.pbf \;
```
The endpoint.ex file needs to be modified:
```elixir
  plug Plug.Static,
    at: "/",
    only: ~w(css static_tiles fonts images js)
```
When playing with it I thought to myself that this may be also done using elixir and I created a mix task that does it. By running `mix mbtile_unpack` in the repo directory the task will create a `priv/static/static_files` directory with a structure that can be served without any controllers.

I created a demo phoenix project that shows a test page.
To edit it play with the map_controller and /priv/static/map_logic.js where I added the js logic, all is done using [leaflet](https://leafletjs.com/) and the [vector grid plugin](https://github.com/Leaflet/Leaflet.VectorGrid). Demo repository can be found [tile_server](https://github.com/dkuku/tile_server)
