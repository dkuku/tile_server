defmodule TileServerWeb.MapController do
  use TileServerWeb, :controller

  def index(conn, _params) do
  html(conn, """
  <head>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet.js"></script>
    <script src="https://unpkg.com/leaflet.vectorgrid@1.2.0"></script>
  </head>
  <body>
      <div id="map" style="height: 200px;"></div>
      <script>
          var map = L.map('map').setView([55.505, -3.25], 12);
  var vectorStyles = {
    water: {	// Apply these options to the "water" layer...
      fill: true,
      weight: 1,
      fillColor: '#06cccc',
      color: '#06cccc',
      fillOpacity: 0.2,
      opacity: 0.4,
    },
    transportation: {	// Apply these options to the "transportation" layer...
      weight: 0.5,
      color: '#f2b648',
      fillOpacity: 0.2,
      opacity: 0.4,
    },
  }
  var openMapTilesUrl = "http://localhost:5000/{z}/{x}/{y}.pbf";

  var openMapTilesLayer = L.vectorGrid.protobuf(openMapTilesUrl, {
    vectorTileLayerStyles: vectorStyles,
    attribution: '© OpenStreetMap contributors, © MapTiler'
  });
  openMapTilesLayer.addTo(map);


  </script>

  </body>
  """)
  end
end
