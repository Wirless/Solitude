const otbm2json = require("../otbm2json");

const ITEM_TO_ADD = 4526; // Item ID to add to matching tiles
const MIN_TILE_ID = 4644;
const MAX_TILE_ID = 4655;

// Read the map data using the otbm2json library
const mapData = otbm2json.read("map.otbm");

// Go over all nodes
mapData.data.nodes.forEach(function(node) {

  node.features.forEach(function(feature) {
    
    // Skip anything that is not a tile area
    if (feature.type !== otbm2json.HEADERS.OTBM_TILE_AREA) return; 

    // For each tile area, go over all actual tiles
    feature.tiles.forEach(function(tile) {

      // Skip anything that is not a tile (e.g., house tiles)
      if (tile.type !== otbm2json.HEADERS.OTBM_TILE) return; 

      // Check if the tile ID is within the specified range
      if (tile.tileid >= MIN_TILE_ID && tile.tileid <= MAX_TILE_ID) {
        // Add the new item to the tile's items array
        if (!tile.items) {
          tile.items = []; // Initialize items array if it doesn't exist
        }
        tile.items.push({
          id: ITEM_TO_ADD,
          type: otbm2json.HEADERS.OTBM_ITEM
        });
      }

    });

  });

});

// Write the modified map data back to OTBM format
otbm2json.write("modified_map.otbm", mapData);
