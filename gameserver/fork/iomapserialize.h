// Copyright 2023 The Forgotten Server Authors and Alejandro Mujica for many specific source code changes, All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#pragma once

#include "map.h"
#include "house.h"

enum MapDataLoadResult_t : uint8_t
{
	MAP_DATA_LOAD_NONE,
	MAP_DATA_LOAD_FOUND,
	MAP_DATA_LOAD_ERROR,
};

enum MapDataTileType_t : uint8_t
{
	MAP_TILE_DYNAMIC,
	MAP_TILE_STATIC,
	MAP_TILE_HOUSE,
};

class IOMapSerialize
{
	public:
		static MapDataLoadResult_t loadMapData();
		static bool loadHouseItems(Map* map);

		static bool saveHouseItems();
		static bool saveMapData();

		static bool loadHouseInfo();
		static bool saveHouseInfo();

		static bool saveHouse(House* house);
		static bool saveHouseTVPFormat(const House* house);

	private:
		static void saveItem(PropWriteStream& stream, const Item* item);
		static void saveTile(PropWriteStream& stream, const Tile* tile);

		static bool loadContainer(PropStream& propStream, Container* container);
		static bool loadItem(PropStream& propStream, Cylinder* parent);
};
