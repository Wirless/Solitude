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

#include "main.h"

#include "complexitem.h"

#include "iomap.h"

// Container
Container::Container(const uint16_t type) : Item(type, 0)
{
	////
}

Container::~Container()
{
	for(Item* item : contents) {
		delete item;
	}
}

Item* Container::deepCopy() const
{
	Item* copy = Item::deepCopy();
	Container* copyContainer = dynamic_cast<Container*>(copy);
	if(copyContainer) {
		for(Item* item : contents) {
			copyContainer->contents.push_back(item->deepCopy());
		}
	}
	return copy;
}

Item* Container::getItem(size_t index) const
{
	if(index < contents.size()) {
		return contents[index];
	}
	return nullptr;
}

double Container::getWeight()
{
	return g_items[id].weight;
}

// Teleport
Teleport::Teleport(const uint16_t type) : Item(type, 0),
	destination(0, 0, 0)
{
	////
}

Item* Teleport::deepCopy() const
{
	Teleport* copy = static_cast<Teleport*>(Item::deepCopy());
	copy->destination = destination;
	return copy;
}

// Door
Door::Door(const uint16_t type) : Item(type, 0),
	doorId(0),
	keyHoleNumber(0),
	doorLevel(0),
	questNumber(0),
	questValue(0)
{
	////
}

Item* Door::deepCopy() const
{
	Door* copy = static_cast<Door*>(Item::deepCopy());
	copy->doorId = doorId;
	copy->keyHoleNumber = keyHoleNumber;
	copy->doorLevel = doorLevel;
	copy->questNumber = questNumber;
	copy->questValue = questValue;
	return copy;
}

// Depot
Depot::Depot(const uint16_t type) : Item(type, 0),
	depotId(0)
{
	////
}

Item* Depot::deepCopy() const
{
	Item* copy = Item::deepCopy();
	Depot* copy_depot = dynamic_cast<Depot*>(copy);
	if(copy_depot) {
		copy_depot->depotId = depotId;
	}
	return copy;
}

// Key
Key::Key(const uint16_t type) : Item(type, 0),
keyNumber(0)
{
	////
}

Item* Key::deepCopy() const
{
	Item* copy = Item::deepCopy();
	Key* copy_key = dynamic_cast<Key*>(copy);
	if (copy_key) {
		copy_key->keyNumber = keyNumber;
	}
	return copy;
}
