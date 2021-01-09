defmodule TileServerWeb.MapController do
  use TileServerWeb, :controller
  import Phoenix.HTML
  alias TileServer.Mbtiles

  @doc """
  https://github.com/mapbox/mbtiles-spec/blob/master/1.3/spec.md
  """
  def index(conn, _params) do
    meta = Mbtiles.get_metadata()
    [w, s, e, n] = String.split(meta.bounds, ",")
    [lon, lat, zoom] = String.split(meta.center, ",")
    layers = get_layer_ids(meta.json)
    IO.inspect(layers)

    html(
      conn,
      ~E"""
      <head>
      <link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" />
      <script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet.js"></script>
      <script src="https://unpkg.com/leaflet.vectorgrid@latest/dist/Leaflet.VectorGrid.js"></script>
      </head>
      <body>
        <div id="map" style="height: 100vh;"></div>
      <div id="data-div"
           data-s="<%= s %>"
           data-w="<%= w %>"
           data-n="<%= n %>"
           data-e="<%= e %>"
           data-zoom="<%= zoom %>"
           data-minzoom="<%= meta.minzoom %>"
           data-maxzoom="<%= meta.maxzoom %>"
           data-lat="<%= lat %>"
           data-lon="<%= lon %>"
      ></div>
      <div id="attr-div" style="display: none;"><%= {:safe, Map.get(meta, :attribution, "")} %></div>
      <script src="/js/map_logic.js"></script>
      </body>
      """
      |> safe_to_string
    )
  end

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

  def get_layer_ids(json) do
    json
    |> Jason.decode!()
    |> Map.get("vector_layers")
    |> Enum.map(&Map.get(&1, "id"))
    |> Enum.sort()
  end
end
