// Copyright 2023 The Forgotten Server Authors and Alejandro Mujica for many specific source code changes, All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "iomapserialize.h"
#include "game.h"
#include "bed.h"
#include "configmanager.h"
#include "iomap.h"

#include <fmt/format.h>
#include <fstream>
#include <filesystem>

extern Game g_game;
extern ConfigManager g_config;

MapDataLoadResult_t IOMapSerialize::loadMapData()
{
	if (!g_config.getBoolean(ConfigManager::ENABLE_MAP_DATA_FILES)) {
		return MAP_DATA_LOAD_NONE;
	}

	// compare date times
	auto otbmLastWriteTime = std::filesystem::last_write_time(fmt::format("data/world/{:s}.otbm", g_config.getString(ConfigManager::MAP_NAME)));

	const std::string filename = "gamedata/map.tvpm";
	std::ifstream fileTest(filename, std::ios::binary);
	if (fileTest.is_open()) {
		auto liveMapDataWriteTime = std::filesystem::last_write_time("gamedata/map.tvpm");

		if (otbmLastWriteTime > liveMapDataWriteTime) {
			std::cout << "> INFO: Original OTBM map is newer than live map data, proceeding to load original OTBM map." << std::endl;
			g_game.toggleSendPlayersToTemple(true);
			return MAP_DATA_LOAD_NONE;
		} else {
			std::cout << "> INFO: Live Map Data is being used." << std::endl;
		}

		int64_t start = OTSYS_TIME();

		g_game.map.width = g_game.map.height = 65000; // default map size is max size

		const auto& size = std::filesystem::file_size(std::filesystem::path(filename));

		std::string content(size, '\0');
		fileTest.read(content.data(), size);

		PropStream propStream;
		propStream.init(content.data(), size);

		uint64_t totalTiles = 0;
		propStream.read<uint64_t>(totalTiles);

		for (uint64_t i = 0; i < totalTiles; i++) {
			MapDataTileType_t tileType;
			propStream.read<MapDataTileType_t>(tileType);

			uint16_t x, y;
			uint8_t z;

			propStream.read<uint16_t>(x);
			propStream.read<uint16_t>(y);
			propStream.read<uint8_t>(z);

			Tile* tile = nullptr;
			if (tileType == MAP_TILE_DYNAMIC) {
				tile = new DynamicTile(x, y, z);
			} else if (tileType == MAP_TILE_STATIC) {
				tile = new StaticTile(x, y, z);
			} else {
				uint32_t houseId;
				propStream.read<uint32_t>(houseId);
				House* house = g_game.map.houses.addHouse(houseId);
				tile = new HouseTile(x, y, z, house);
			}

			uint32_t tileFlags = 0;
			propStream.read<uint32_t>(tileFlags);
			tile->setFlags(tileFlags);

			uint32_t totalItems = 0;
			propStream.read<uint32_t>(totalItems);

			if (totalItems == 0) {
				g_game.map.setTile(tile->getPosition(), tile);
				continue;
			}

			for (uint32_t ii = 0; ii < totalItems; ii++) {
				Item* item = Item::CreateItem(propStream);
				if (!item) {
					std::cout << fmt::format("ERROR - [IOMapSerialize::loadMapData]: Failed to create item - {:s}", filename) << std::endl;
					delete tile;
					return MAP_DATA_LOAD_ERROR;
				}

				if (!item->unserializeTVPFormat(propStream)) {
					std::cout << "> ERROR - [IOMapSerialize::loadMapData]: Failed to unserialize item in file " << filename << std::endl;
					delete item;
					delete tile;
					return MAP_DATA_LOAD_ERROR;
				}

				tile->internalAddThing(item);
				item->startDecaying();
			}

			tile->makeRefreshItemList();
			g_game.map.setTile(tile->getPosition(), tile);
		}

		uint8_t totalTowns = 0;
		propStream.read<uint8_t>(totalTowns);

		for (uint32_t i = 0; i < totalTowns; i++) {
			uint8_t id;
			propStream.read<uint8_t>(id);
			std::string name;
			propStream.readString(name);
			uint32_t x, y;
			uint8_t z;
			propStream.read<uint32_t>(x);
			propStream.read<uint32_t>(y);
			propStream.read<uint8_t>(z);
			Town* town = new Town(id);
			town->setName(name);
			town->setTemplePos(Position(x, y, z));
			g_game.map.towns.addTown(id, town);
		}

		uint32_t totalHouses = 0;
		propStream.read<uint32_t>(totalHouses);

		for (uint32_t i = 0; i < totalHouses; i++) {
			uint32_t houseId;
			propStream.read<uint32_t>(houseId);
			
			std::string name;
			propStream.readString(name);

			uint32_t townId;
			propStream.read<uint32_t>(townId);

			uint32_t rent;
			propStream.read<uint32_t>(rent);

			Position entryPos;
			propStream.read<uint16_t>(entryPos.x);
			propStream.read<uint16_t>(entryPos.y);
			propStream.read<uint8_t>(entryPos.z);

			House* house = g_game.map.houses.addHouse(houseId);
			house->setName(name);
			house->setTownId(townId);
			house->setRent(rent);
			house->setEntryPos(entryPos);
		}

		propStream.readString(g_game.map.spawnfile);
		propStream.readString(g_game.map.housefile);

		std::cout << "> Live Map loading time: " << (OTSYS_TIME() - start) / (1000.) << " seconds." << std::endl;
	} else {
		return MAP_DATA_LOAD_NONE;
	}

	g_game.cleanup();
	return MAP_DATA_LOAD_FOUND;
}

bool IOMapSerialize::loadHouseItems(Map* map)
{
	int64_t start = OTSYS_TIME();

	for (const auto& it : g_game.map.houses.getHouses()) {
		House* house = it.second;

		const std::string filename = fmt::format("gamedata/houses/{:d}.tvph", house->getId());
		std::ifstream fileTest(filename, std::ios::binary);
		if (fileTest.is_open()) {
			const auto& size = std::filesystem::file_size(std::filesystem::path(filename));

			std::string content(size, '\0');
			fileTest.read(content.data(), size);

			PropStream propStream;
			propStream.init(content.data(), size);

			std::string houseName;
			propStream.readString(houseName);

			uint32_t totalTiles;
			propStream.read<uint32_t>(totalTiles);

			bool hasTiles = !house->getTiles().empty();

			for (uint32_t i = 0; i < totalTiles; i++) {
				uint16_t x, y, z;

				propStream.read<uint16_t>(x);
				propStream.read<uint16_t>(y);
				propStream.read<uint16_t>(z);

				uint32_t totalItems = 0;
				propStream.read<uint32_t>(totalItems);

				bool loadedHouse = true;

				Tile* tile = map->getTile(x, y, z);
				if (!tile) {
					std::cout << fmt::format("> WARNING: Tile no longer exists {:d}-{:d}-{:d}:{:d}", x, y, z, totalItems)
					          << std::endl;
					loadedHouse = false;
					break;
				}

				HouseTile* houseTile = static_cast<HouseTile*>(tile);
				if (!hasTiles) {
					// OTBM was not loaded, so set house tiles here
					house->addTile(static_cast<HouseTile*>(houseTile));
				}

				std::vector<Item*> preloadedItems{};

				for (uint32_t ii = 0; ii < totalItems; ii++) {
					Item* item = Item::CreateItem(propStream);
					if (!item) {
						std::cout << "> ERROR - [IOMapSerialize::loadHouseItems]: Failed to load item in file "
						          << filename << std::endl;
						delete item;
						loadedHouse = false;
						break;
					}

					if (!item->unserializeTVPFormat(propStream)) {
						std::cout << "> ERROR - [IOMapSerialize::loadHouseItems]: Failed to unserialize item in file "
						          << filename << std::endl;
						delete item;
						loadedHouse = false;
						break;
					}

					preloadedItems.push_back(item);
				}

				if (loadedHouse) {
					// house tile is saved on disk, so clean it up no matter what
					// also cleans up the stock furniture from CIP map that comes from original OTBM
					tile->cleanHouseItems();

					for (Item* houseItem : preloadedItems) {
						tile->internalAddThing(houseItem);
						houseItem->startDecaying();
					}
				}
				else {
					for (Item* houseItem : preloadedItems) {
						delete houseItem;
					}
				}
			}

			// update house doors
			house->updateDoorDescription();

			fileTest.close();
		}
	}

	std::cout << "> Loaded house items in: " << (OTSYS_TIME() - start) / (1000.) << " s" << std::endl;
	return true;
}

bool IOMapSerialize::saveHouseItems()
{
	std::cout << "> Saving house items..." << std::endl;
	int64_t start = OTSYS_TIME();

	for (const auto& it : g_game.map.houses.getHouses()) {
		const House* house = it.second;
		if (!saveHouseTVPFormat(house)) {
			std::cout << "> ERROR: Failed to save house " << house->getId() << ":" << house->getName() << std::endl;
			return false;
		}
	}

	std::cout << "> Saved house data files in: " << (OTSYS_TIME() - start) / (1000.) << " s" << std::endl;
	return true;
}

bool IOMapSerialize::saveMapData()
{
	if (!g_config.getBoolean(ConfigManager::ENABLE_MAP_DATA_FILES)) {
		return true;
	}

	std::cout << "> Saving map data..." << std::endl;

	int64_t start = OTSYS_TIME();

	std::ostringstream ss;
	ss << "gamedata/map.tvpm";

	std::ofstream file;
	file.open(ss.str(), std::ios::out | std::ios::binary | std::ios::trunc);
	if (!file.is_open()) {
		std::cout << "> ERROR: Cannot open " << ss.str() << " for saving." << std::endl;
		return false;
	}

	PropWriteStream f;

	const auto& tiles = g_game.getTilesToSave();

	f.write<uint64_t>(tiles.size());

	for (const Tile* tile : tiles) {
		const Position& pos = tile->getPosition();

		if (dynamic_cast<const HouseTile*>(tile)) {
			f.write<uint8_t>(MAP_TILE_HOUSE);
		} else if (dynamic_cast<const DynamicTile*>(tile)) {
			f.write<uint8_t>(MAP_TILE_DYNAMIC);
		} else {
			f.write<uint8_t>(MAP_TILE_STATIC);
		}

		f.write<uint16_t>(pos.x);
		f.write<uint16_t>(pos.y);
		f.write<uint8_t>(pos.z);

		std::vector<const Item*> savingItems;

		if (const Item* ground = tile->getGround()) {
			savingItems.push_back(ground);
		}

		std::list<Item*> borderItems;
		if (const auto& items = tile->getItemList()) {
			for (auto it = items->rbegin(); it != items->rend(); it++) {
				Item* item = (*it);
				if (item->isAlwaysOnTop() && Item::items[item->getID()].alwaysOnTopOrder == 1) {
					borderItems.push_front(item);
				} else {
					savingItems.push_back(item);
				}
			}
		}

		if (const HouseTile* const houseTile = dynamic_cast<const HouseTile*>(tile)) {
			f.write<uint32_t>(houseTile->getHouse()->getId());
		}

		uint32_t realTileFlags = tile->getFlags();
		realTileFlags &= ~TILESTATE_FLOORCHANGE;

		f.write<uint32_t>(realTileFlags);

		f.write<uint32_t>(savingItems.size() + borderItems.size());

		for (const Item* item : borderItems) {
			item->serializeTVPFormat(f);
		}

		for (const Item* item : savingItems) {
			item->serializeTVPFormat(f);
		}
	}

	f.write<uint8_t>(g_game.map.towns.getTowns().size());
	for (const auto& it : g_game.map.towns.getTowns()) {
		Town* town = it.second;
		f.write<uint8_t>(town->getID());
		f.writeString(town->getName());
		f.write<uint32_t>(town->getTemplePosition().x);
		f.write<uint32_t>(town->getTemplePosition().y);
		f.write<uint8_t>(town->getTemplePosition().z);
	}

	f.write<uint32_t>(g_game.map.houses.getHouses().size());
	for (const auto& it : g_game.map.houses.getHouses()) {
		House* house = it.second;
		f.write<uint32_t>(house->getId());
		f.writeString(house->getName());
		f.write<uint32_t>(house->getTownId());
		f.write<uint32_t>(house->getRent());
		f.write<uint16_t>(house->getEntryPosition().x);
		f.write<uint16_t>(house->getEntryPosition().y);
		f.write<uint8_t>(house->getEntryPosition().z);
	}

	f.writeString(g_game.map.spawnfile);
	f.writeString(g_game.map.housefile);

	size_t size;
	const char* data = f.getStream(size);
	file.write(data, size);
	file.close();

	std::cout << "> Saved map data in: " <<
		(OTSYS_TIME() - start) / (1000.) << " s" << std::endl;
	return true;
}

bool IOMapSerialize::loadContainer(PropStream& propStream, Container* container)
{
	while (container->serializationCount > 0) {
		if (!loadItem(propStream, container)) {
			std::cout << "[Warning - IOMapSerialize::loadContainer] Unserialization error for container item: " << container->getID() << std::endl;
			return false;
		}
		container->serializationCount--;
	}

	uint8_t endAttr;
	if (!propStream.read<uint8_t>(endAttr) || endAttr != 0) {
		std::cout << "[Warning - IOMapSerialize::loadContainer] Unserialization error for container item: " << container->getID() << std::endl;
		return false;
	}
	return true;
}

bool IOMapSerialize::loadItem(PropStream& propStream, Cylinder* parent)
{
	uint16_t id;
	if (!propStream.read<uint16_t>(id)) {
		return false;
	}

	Tile* tile = nullptr;
	if (parent->getParent() == nullptr) {
		tile = parent->getTile();
	}

	const ItemType& iType = Item::items[id];
	if (iType.moveable || iType.forceSerialize || !tile) {
		//create a new item
		Item* item = Item::CreateItem(id);
		if (item) {
			if (item->unserializeAttr(propStream)) {
				Container* container = item->getContainer();
				if (container && !loadContainer(propStream, container)) {
					delete item;
					return false;
				}

				parent->internalAddThing(item);
				item->startDecaying();
			} else {
				std::cout << "WARNING: Unserialization error in IOMapSerialize::loadItem()" << id << std::endl;
				delete item;
				return false;
			}
		}
	} else {
		// Stationary items like doors/beds/blackboards/bookcases
		Item* item = nullptr;
		if (const TileItemVector* items = tile->getItemList()) {
			for (Item* findItem : *items) {
				if (findItem->getID() == id) {
					item = findItem;
					break;
				} else if (iType.isDoor() && findItem->getDoor()) {
					item = findItem;
					break;
				} else if (iType.isBed() && findItem->getBed()) {
					item = findItem;
					break;
				}
			}
		}

		if (item) {
			if (item->unserializeAttr(propStream)) {
				Container* container = item->getContainer();
				if (container && !loadContainer(propStream, container)) {
					return false;
				}

				g_game.transformItem(item, id);
			} else {
				std::cout << "WARNING: Unserialization error in IOMapSerialize::loadItem()" << id << std::endl;
			}
		} else {
			//The map changed since the last save, just read the attributes
			std::unique_ptr<Item> dummy(Item::CreateItem(id));
			if (dummy) {
				dummy->unserializeAttr(propStream);
				Container* container = dummy->getContainer();
				if (container) {
					if (!loadContainer(propStream, container)) {
						return false;
					}
				} else if (BedItem* bedItem = dynamic_cast<BedItem*>(dummy.get())) {
					uint32_t sleeperGUID = bedItem->getSleeper();
					if (sleeperGUID != 0) {
						g_game.removeBedSleeper(sleeperGUID);
					}
				}
			}
		}
	}
	return true;
}

void IOMapSerialize::saveItem(PropWriteStream& stream, const Item* item)
{
	const Container* container = item->getContainer();

	// Write ID & props
	stream.write<uint16_t>(item->getID());
	item->serializeAttr(stream);

	if (container) {
		// Hack our way into the attributes
		stream.write<uint8_t>(ATTR_CONTAINER_ITEMS);
		stream.write<uint32_t>(container->size());
		for (auto it = container->getReversedItems(), end = container->getReversedEnd(); it != end; ++it) {
			saveItem(stream, *it);
		}
	}

	stream.write<uint8_t>(0x00); // attr end
}

void IOMapSerialize::saveTile(PropWriteStream& stream, const Tile* tile)
{
	const TileItemVector* tileItems = tile->getItemList();
	if (!tileItems) {
		return;
	}

	std::forward_list<Item*> items;
	uint16_t count = 0;
	for (Item* item : *tileItems) {
		const ItemType& it = Item::items[item->getID()];

		// Note that these are NEGATED, ie. these are the items that will be saved.
		if (!(it.moveable || it.forceSerialize || item->getDoor() || (item->getContainer() && !item->getContainer()->empty()) || it.canWriteText || item->getBed())) {
			continue;
		}

		items.push_front(item);
		++count;
	}

	if (!items.empty()) {
		const Position& tilePosition = tile->getPosition();
		stream.write<uint16_t>(tilePosition.x);
		stream.write<uint16_t>(tilePosition.y);
		stream.write<uint8_t>(tilePosition.z);

		stream.write<uint32_t>(count);
		for (const Item* item : items) {
			saveItem(stream, item);
		}
	}
}

bool IOMapSerialize::loadHouseInfo()
{
	Database& db = Database::getInstance();

	DBResult_ptr result = db.storeQuery("SELECT `id`, `owner`, `paid`, `warnings` FROM `houses`");
	if (!result) {
		return false;
	}

	do {
		House* house = g_game.map.houses.getHouse(result->getNumber<uint32_t>("id"));
		if (house) {
			house->setOwner(result->getNumber<uint32_t>("owner"), false);
			house->setPaidUntil(result->getNumber<time_t>("paid"));
			house->setPayRentWarnings(result->getNumber<uint32_t>("warnings"));
		}
	} while (result->next());

	result = db.storeQuery("SELECT `house_id`, `listid`, `list` FROM `house_lists`");
	if (result) {
		do {
			House* house = g_game.map.houses.getHouse(result->getNumber<uint32_t>("house_id"));
			if (house) {
				house->setAccessList(result->getNumber<uint32_t>("listid"), result->getString("list"));
			}
		} while (result->next());
	}
	return true;
}

bool IOMapSerialize::saveHouseInfo()
{
	Database& db = Database::getInstance();

	DBTransaction transaction;
	if (!transaction.begin()) {
		return false;
	}

	if (!db.executeQuery("DELETE FROM `house_lists`")) {
		return false;
	}

	for (const auto& it : g_game.map.houses.getHouses()) {
		House* house = it.second;
		DBResult_ptr result = db.storeQuery(fmt::format("SELECT `id` FROM `houses` WHERE `id` = {:d}", house->getId()));
		if (result) {
			db.executeQuery(fmt::format(
			    "UPDATE `houses` SET `owner` = {:d}, `paid` = {:d}, `warnings` = {:d}, `name` = {:s}, `town_id` = {:d}, `rent` = {:d}, `size` = {:d}, `beds` = {:d} WHERE `id` = {:d}",
			    house->getOwner(), house->getPaidUntil(), house->getPayRentWarnings(),
			    db.escapeString(house->getName()), house->getTownId(), house->getRent(), house->getTiles().size(),
			    house->getBedCount(), house->getId()));
		} else {
			db.executeQuery(fmt::format(
			    "INSERT INTO `houses` (`id`, `owner`, `paid`, `warnings`, `name`, `town_id`, `rent`, `size`, `beds`) VALUES ({:d}, {:d}, {:d}, {:d}, {:s}, {:d}, {:d}, {:d}, {:d})",
			    house->getId(), house->getOwner(), house->getPaidUntil(), house->getPayRentWarnings(),
			    db.escapeString(house->getName()), house->getTownId(), house->getRent(), house->getTiles().size(),
			    house->getBedCount()));
		}
	}

	DBInsert stmt("INSERT INTO `house_lists` (`house_id` , `listid` , `list`) VALUES ");

	for (const auto& it : g_game.map.houses.getHouses()) {
		House* house = it.second;

		std::string listText;
		if (house->getAccessList(GUEST_LIST, listText) && !listText.empty()) {
			if (!stmt.addRow(fmt::format("{:d}, {}, {:s}", house->getId(), static_cast<int>(GUEST_LIST), db.escapeString(listText)))) {
				return false;
			}

			listText.clear();
		}

		if (house->getAccessList(SUBOWNER_LIST, listText) && !listText.empty()) {
			if (!stmt.addRow(fmt::format("{:d}, {}, {:s}", house->getId(), static_cast<int>(SUBOWNER_LIST), db.escapeString(listText)))) {
				return false;
			}

			listText.clear();
		}

		for (Door* door : house->getDoors()) {
			if (door->getAccessList(listText) && !listText.empty()) {
				if (!stmt.addRow(fmt::format("{:d}, {:d}, {:s}", house->getId(), door->getDoorId(), db.escapeString(listText)))) {
					return false;
				}

				listText.clear();
			}
		}
	}

	if (!stmt.execute()) {
		return false;
	}

	return transaction.commit();
}

bool IOMapSerialize::saveHouse(House* house)
{
	Database& db = Database::getInstance();

	//Start the transaction
	DBTransaction transaction;
	if (!transaction.begin()) {
		return false;
	}

	uint32_t houseId = house->getId();
	
	//clear old tile data
	if (!db.executeQuery(fmt::format("DELETE FROM `tile_store` WHERE `house_id` = {:d}", houseId))) {
		return false;
	}

	DBInsert stmt("INSERT INTO `tile_store` (`house_id`, `data`) VALUES ");

	PropWriteStream stream;
	for (HouseTile* tile : house->getTiles()) {
		saveTile(stream, tile);

		size_t attributesSize;
		const char* attributes = stream.getStream(attributesSize);
		if (attributesSize > 0) {
			if (!stmt.addRow(fmt::format("{:d}, {:s}", houseId, db.escapeBlob(attributes, attributesSize)))) {
				return false;
			}
			stream.clear();
		}
	}

	if (!stmt.execute()) {
		return false;
	}

	//End the transaction
	return transaction.commit();
}

bool IOMapSerialize::saveHouseTVPFormat(const House* house)
{
	std::ostringstream ss;
	ss << "gamedata/houses/" << house->getId() << ".tvph";

	std::ofstream file;
	file.open(ss.str(), std::ios::out | std::ios::binary | std::ios::trunc);
	if (!file.is_open()) {
		std::cout << "> ERROR: Cannot open " << ss.str() << " for saving." << std::endl;
		return false;
	}

	PropWriteStream f;

	f.writeString(house->getName());

	const auto& tiles = house->getTiles();
	f.write<uint32_t>(tiles.size());

	for (Tile* tile : house->getTiles()) {
		const Position& pos = tile->getPosition();
		f.write<uint16_t>(pos.x);
		f.write<uint16_t>(pos.y);
		f.write<uint16_t>(pos.z);
		if (const auto& items = tile->getItemList()) {
			std::vector<Item*> houseItems;
			for (auto it = items->rbegin(); it != items->rend(); it++) {
				Item* item = *it;
				if (item->isHouseItem()) {
					houseItems.push_back(item);
				}
			}

			f.write<uint32_t>(houseItems.size());
			for (Item* item : houseItems) {
				item->serializeTVPFormat(f);
			}
		} else {
			f.write<uint32_t>(0);
		}
	}

	size_t size;
	const char* data = f.getStream(size);
	file.write(data, size);
	file.close();
	return true;
}
