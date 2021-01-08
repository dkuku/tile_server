defmodule TileServerWeb.MapController do
  use TileServerWeb, :controller
  import Phoenix.HTML

  def index(conn, _params) do
    meta = TileServer.Mbtiles.get_metadata()
    [w, s, e, n] = String.split(meta["bounds"], ",")
    [lat, lon, _zoom] = String.split(meta["center"], ",")

    html(
      conn,
      ~E"""
      <head>
      <link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" />
      <script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet.js"></script>
      <script src="https://unpkg.com/leaflet.vectorgrid@1.2.0"></script>
      </head>
      <body>
        <div id="map" style="height: 500px;"></div>
        <script>
        var southWest = L.latLng(<%= w <> ", " <> s %>),
        northEast = L.latLng(<%= e <> ", " <> n %>),
        bounds = L.latLngBounds(southWest, northEast);

        var map = L.map('map').setView([<%= lat <> ", " <> lon %>], <%= meta["maskLevel"] %>)
        var vectorStyles = {}
        var openMapTilesUrl = "http://localhost:4000/tiles/{z}/{x}/{y}";
        //var openMapTilesUrl = "http://localhost:4000/{z}/{x}/{y}.pbf";

        var openMapTilesLayer = L.vectorGrid.protobuf(openMapTilesUrl, {
          vectorTileLayerStyles: vectorStyles,
          attribution: '<%= {:safe, "#{meta["attribution"]}"} %>',
          maxZoom: <%= meta["maxzoom"] %>,
          minZoom: <%= meta["minzoom"] %>,
          maxBounds: bounds
        });
        openMapTilesLayer.addTo(map);
      </script>
      </body>
      """
      |> safe_to_string
    )
  end

  def tile(conn, params) do
    %{"z" => z, "x" => x, "y" => y} = params
    tile = TileServer.Mbtiles.get_images(z, x, y)

    conn
    |> put_resp_content_type("application/octet-stream")
    |> send_resp(200, tile)
  end
end
