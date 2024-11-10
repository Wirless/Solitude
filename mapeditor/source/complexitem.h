//////////////////////////////////////////////////////////////////////
// This file is part of Remere's Map Editor
//////////////////////////////////////////////////////////////////////
// Remere's Map Editor is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Remere's Map Editor is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//////////////////////////////////////////////////////////////////////

#ifndef RME_CONTAINER_H_
#define RME_CONTAINER_H_

#include "position.h"
#include "item.h"

#pragma pack(1)

struct OTBM_TeleportDestination
{
	uint16_t x;
	uint16_t y;
	uint8_t z;
};

#pragma pack()

class Container : public Item
{
	public:
		Container(const uint16_t type);
		~Container();

		Item* deepCopy() const;
		Item* getItem(size_t index) const;

		size_t getItemCount() const { return contents.size(); }
		size_t getVolume() const { return g_items[id].volume; }

		ItemVector& getVector() { return contents; }
		double getWeight();

		bool unserializeItemNode_OTBM(const IOMap& maphandle, BinaryNode* node) override;
		bool serializeItemNode_OTBM(const IOMap& maphandle, NodeFileWriteHandle& f) const override;
		//bool unserializeItemNode_OTMM(const IOMap& maphandle, BinaryNode* node) override;
		//bool serializeItemNode_OTMM(const IOMap& maphandle, NodeFileWriteHandle& f) const override;

	protected:
		ItemVector contents;
};

class Teleport : public Item
{
	public:
		Teleport(const uint16_t type);

		Item* deepCopy() const;

		void serializeItemAttributes_OTBM(const IOMap& maphandle, NodeFileWriteHandle& f) const override;
		bool readItemAttribute_OTBM(const IOMap& maphandle, OTBM_ItemAttribute attr, BinaryNode* node) override;
		//void serializeItemAttributes_OTMM(const IOMap& maphandle, NodeFileWriteHandle& f) const override;
		//bool readItemAttribute_OTMM(const IOMap& maphandle, OTMM_ItemAttribute attr, BinaryNode* node) override;

		int32_t getX() const { return destination.x; }
		int32_t getY() const { return destination.y; }
		int32_t getZ() const { return destination.z; }

		Position getDestination() const { return destination; }
		void setDestination(const Position& position) { destination = position; }

		bool hasDestination() const { return destination != Position(); }

	protected:
		// We could've made this public and skip the functions, but that would
		// make the handling of aid/uid/text different from handling teleports,
		// which would be weird.
		Position destination;
};

class Door : public Item
{
	public:
		Door(const uint16_t type);

		Item* deepCopy() const;

		uint8_t getDoorID() const { return doorId; }
		void setDoorID(uint8_t id) { doorId = id; }

		uint16_t getKeyHoleNumber() const { return keyHoleNumber; }
		void setKeyHoleNumber(const uint16_t number) { keyHoleNumber = number; }

		uint16_t getDoorLevel() const { return doorLevel; }
		void setDoorLevel(const uint16_t level) { doorLevel = level; }

		uint16_t getQuestNumber() const { return questNumber; }
		void setQuestNumber(const uint16_t number) { questNumber = number; }

		uint16_t getQuestValue() const { return questValue; }
		void setQuestValue(const uint16_t value) { questValue = value; }

		void serializeItemAttributes_OTBM(const IOMap& maphandle, NodeFileWriteHandle& f) const override;
		bool readItemAttribute_OTBM(const IOMap& maphandle, OTBM_ItemAttribute attr, BinaryNode* node) override;
		//void serializeItemAttributes_OTMM(const IOMap& maphandle, NodeFileWriteHandle& f) const override;
		//bool readItemAttribute_OTMM(const IOMap& maphandle, OTMM_ItemAttribute attr, BinaryNode* node) override;

	protected:
		uint8_t doorId;
		uint16_t keyHoleNumber;
		uint16_t doorLevel;
		uint16_t questNumber;
		uint16_t questValue;
};

class Depot : public Item
{
	public:
		Depot(const uint16_t _type);

		Item* deepCopy() const;

		uint8_t getDepotID() const { return depotId; }
		void setDepotID(uint8_t id) { depotId = id; }

		void serializeItemAttributes_OTBM(const IOMap& maphandle, NodeFileWriteHandle& f) const override;
		bool readItemAttribute_OTBM(const IOMap& maphandle, OTBM_ItemAttribute attr, BinaryNode* node) override;
		//void serializeItemAttributes_OTMM(const IOMap& maphandle, NodeFileWriteHandle& f) const override;
		//bool readItemAttribute_OTMM(const IOMap& maphandle, OTMM_ItemAttribute attr, BinaryNode* node) override;

	protected:
		uint8_t depotId;
};

class Key : public Item
{
	public:
		Key(const uint16_t _type);

		Item* deepCopy() const;

		uint16_t getKeyNumber() const { return keyNumber; }
		void setKeyNumber(uint16_t number) { keyNumber = number; }

		void serializeItemAttributes_OTBM(const IOMap& maphandle, NodeFileWriteHandle& f) const override;
		bool readItemAttribute_OTBM(const IOMap& maphandle, OTBM_ItemAttribute attr, BinaryNode* node) override;
		//void serializeItemAttributes_OTMM(const IOMap& maphandle, NodeFileWriteHandle& f) const override;
		//bool readItemAttribute_OTMM(const IOMap& maphandle, OTMM_ItemAttribute attr, BinaryNode* node) override;

	protected:
		uint16_t keyNumber;
};

#endif
