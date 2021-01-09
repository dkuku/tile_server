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
      <script src="https://unpkg.com/leaflet.vectorgrid@1.2.0/dist/Leaflet.VectorGrid.js"></script>
      </head>
      <body>
        <div id="map" style="height: 100vh;"></div>
      <div id="data-div" style="display: none;"
           data-s="<%= s %>"
           data-w="<%= w %>"
           data-n="<%= n %>"
           data-e="<%= e %>"
           data-zoom="<%= zoom %>"
           data-minzoom="<%= meta.minzoom %>"
           data-maxzoom="<%= meta.maxzoom %>"
           data-lat="<%= lat %>"
           data-lon="<%= lon %>"
      >
        <%= {:safe, Map.get(meta, :attribution, "")} %>
      </div>
      <script src="/js/map_logic.js"></script>
      </body>
      """
      |> safe_to_string
    )
  end

  def tile(conn, params) do
    %{z: z, x: x, y: y} = parse_tile_params(params)
    allow_gzip = allow_gzip?(conn)

    case Mbtiles.get_images(z, x, y, tms: true, gzip: allow_gzip) do
      :error ->
        conn |> send_resp(404, "tile not found")

      tile ->
        conn
        |> gzip_header(allow_gzip)
        |> put_resp_content_type("application/octet-stream")
        |> send_resp(200, tile)
    end
  end

  defp gzip_header(conn, true = _allow_gzip) do
    prepend_resp_headers(conn, [{"content-encoding", "gzip"}])
  end

  defp gzip_header(conn, _), do: conn

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

  defp allow_gzip?(conn), do: inspect(get_req_header(conn, "accept-encoding")) =~ "gzip"
end
