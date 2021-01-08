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
        <div id="map" style="height: 900px;"></div>
        <script>
        var southWest = L.latLng(<%= w <> ", " <> s %>),
        northEast = L.latLng(<%= e <> ", " <> n %>),
        bounds = L.latLngBounds(southWest, northEast);

        var map = L.map('map').setView([52.5186582,-2.147439], <%= zoom %>)
        //var map = L.map('map').setView([<%= lat <> ", " <> lon %>], <%= zoom %>)
        var vectorStyles = {}
        var openMapTilesUrl = "http://localhost:4000/tiles/{z}/{x}/{y}";
        ////var openMapTilesUrl = "http://localhost:4000/{z}/{x}/{y}.pbf";

      var vectorTileStyling = {
      water: {
      fill: true,
      weight: 1,
      fillColor: '#06cccc',
      color: '#06cccc',
      fillOpacity: 0.2,
      opacity: 0.4,
      },
      admin: {
      weight: 1,
      fillColor: 'pink',
      color: 'pink',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      waterway: {
      weight: 1,
      fillColor: '#2375e0',
      color: '#2375e0',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      landcover: {
      fill: true,
      weight: 1,
      fillColor: '#53e033',
      color: '#53e033',
      fillOpacity: 0.2,
      opacity: 0.4,
      },
      landuse: {
      fill: true,
      weight: 1,
      fillColor: '#e5b404',
      color: '#e5b404',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      park: {
      fill: true,
      weight: 1,
      fillColor: '#84ea5b',
      color: '#84ea5b',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      boundary: {
      weight: 1,
      fillColor: '#c545d3',
      color: '#c545d3',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      aeroway: {
      weight: 1,
      fillColor: '#51aeb5',
      color: '#51aeb5',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      road: {	// mapbox & nextzen only
      weight: 1,
      fillColor: '#f2b648',
      color: '#f2b648',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      tunnel: {	// mapbox only
      weight: 0.5,
      fillColor: '#f2b648',
      color: '#f2b648',
      fillOpacity: 0.2,
      opacity: 0.4,
      // 					dashArray: [4, 4]
      },
      bridge: {	// mapbox only
      weight: 0.5,
      fillColor: '#f2b648',
      color: '#f2b648',
      fillOpacity: 0.2,
      opacity: 0.4,
      // 					dashArray: [4, 4]
      },
      transportation: {	// openmaptiles only
      weight: 0.5,
      fillColor: '#f2b648',
      color: '#f2b648',
      fillOpacity: 0.2,
      opacity: 0.4,
      // 					dashArray: [4, 4]
      },
      transit: {	// nextzen only
      weight: 0.5,
      fillColor: '#f2b648',
      color: '#f2b648',
      fillOpacity: 0.2,
      opacity: 0.4,
      // 					dashArray: [4, 4]
      },
      building: {
      fill: true,
      weight: 1,
      fillColor: '#2b2b2b',
      color: '#2b2b2b',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      water_name: {
      weight: 1,
      fillColor: '#022c5b',
      color: '#022c5b',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      transportation_name: {
      weight: 1,
      fillColor: '#bc6b38',
      color: '#bc6b38',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      place: {
      weight: 1,
      fillColor: '#f20e93',
      color: '#f20e93',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      housenumber: {
      weight: 1,
      fillColor: '#ef4c8b',
      color: '#ef4c8b',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      poi: {
      weight: 1,
      fillColor: '#3bb50a',
      color: '#3bb50a',
      fillOpacity: 0.2,
      opacity: 0.4
      },
      earth: {	// nextzen only
      fill: true,
      weight: 1,
      fillColor: '#c0c0c0',
      color: '#c0c0c0',
      fillOpacity: 0.2,
      opacity: 0.4
      },

      // Do not symbolize some stuff for mapbox
      country_label: [],
      marine_label: [],
      state_label: [],
      place_label: [],
      waterway_label: [],
      poi_label: [],
      road_label: [],
      housenum_label: [],


      // Do not symbolize some stuff for openmaptiles
      country_name: [],
      marine_name: [],
      state_name: [],
      place_name: [],
      waterway_name: [],
      poi_name: [],
      road_name: [],
      housenum_name: [],
      };
      // Monkey-patch some properties for nextzen layer names, because
      // instead of "building" the data layer is called "buildings" and so on

      vectorTileStyling.buildings  = vectorTileStyling.building;
      vectorTileStyling.boundaries = vectorTileStyling.boundary;
      vectorTileStyling.places     = vectorTileStyling.place;
      vectorTileStyling.pois       = vectorTileStyling.poi;
      vectorTileStyling.roads      = vectorTileStyling.road;

        var openMapTilesLayer = L.vectorGrid.protobuf(openMapTilesUrl, {
          attribution: '<%= {:safe, "#{meta.attribution}"} %>',
          minZoom: <%= meta.minzoom %>,
          minZoom: 0,
          //maxNativeZoom: <%= meta.maxzoom %>,
          maxNativeZoom: 14,
          maxZoom: 18,
          vectorTileLayerStyles: vectorTileStyling,
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
    %{z: z, x: x, y: y} = parse_tile_params(params)

    tile = Mbtiles.get_images(z, x, get_tms_y(z, y))

    conn
    |> put_resp_content_type("application/octet-stream")
    |> send_resp(200, tile)
  end

  defp get_tms_y(z, y), do: round(:math.pow(2, z) - 1 - y)

  defp parse_tile_params(params) do
    params
    |> Enum.map(fn {k, v} -> {String.to_atom(k), String.to_integer(v)} end)
    |> Map.new()
  end

  defp get_layer_ids(json) do
    json
    |> Jason.decode!()
    |> Map.get("vector_layers")
    |> Enum.map(&Map.get(&1, "id"))
    |> Enum.sort()
  end
end
