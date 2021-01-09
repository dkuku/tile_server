

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

function get(param){
    var dataDiv = document.getElementById('data-div');
    dataParam = dataDiv.getAttribute('data-' + param);
    try {
        return Number(dataParam)
    }
    catch {
        return dataParam
    }
}

var lat = get("lat");
var lon = get("lon");
var minZoom = get("minzoom")
var maxZoom = get("maxzoom")
var zoom = get("zoom")
var s = get("s")
var n = get("n")
var e = get("e")
var w = get("w")
var attribution = document.getElementById('data-div').innerHTML;
var openMapTilesUrl = "http://localhost:4000/tiles/{z}/{x}/{y}";
var openMapTilesUrl = "http://localhost:4000/static_tiles/{z}/{x}/{y}.pbf";

var southWest = L.latLng(w, s),
    northEast = L.latLng(e, n),
    bounds = L.latLngBounds(southWest, northEast);

var map = L.map('map').setView([lat, lon], zoom)
var openMapTilesLayer = L.vectorGrid.protobuf(openMapTilesUrl, {
    attribution: attribution,
    minZoom: minZoom,
    maxZoom: maxZoom,
    vectorTileLayerStyles: vectorTileStyling,
    maxBounds: bounds
});
openMapTilesLayer.addTo(map);

function onLocationFound(e) {
  var radius = e.accuracy / 2;
  L.marker(e.latlng).addTo(map)
    .bindPopup("You are within " + radius + " meters from this point").openPopup();
  L.circle(e.latlng, radius).addTo(map);
}

//map.on('locationfound', onLocationFound);
//map.locate({setView: true, watch: true, maxZoom: zoom});
