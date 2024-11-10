// Copyright 2023 The Forgotten Server Authors and Alejandro Mujica for many specific source code changes, All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "monster.h"
#include "game.h"
#include "spells.h"
#include "events.h"
#include "configmanager.h"
#include "weapons.h"

extern Game g_game;
extern Monsters g_monsters;
extern Events* g_events;
extern ConfigManager g_config;

uint32_t Monster::monsterAutoID = 0x40000000;

Monster* Monster::createMonster(const std::string& name, const std::vector<LootBlock>* extraLoot /* = nullptr*/)
{
	MonsterType* mType = g_monsters.getMonsterType(name);
	if (!mType) {
		return nullptr;
	}
	return new Monster(mType, extraLoot);
}

void Monster::addMonsterItemInventory(Container* bagItem, Item* item)
{
	const ItemType& itemType = Item::items.getItemType(item->getID());
	const WeaponType_t weaponType = itemType.weaponType;
	if (weaponType == WEAPON_AXE ||
		weaponType == WEAPON_CLUB ||
		weaponType == WEAPON_SWORD ||
		weaponType == WEAPON_SHIELD ||
		weaponType == WEAPON_WAND ||
		weaponType == WEAPON_DISTANCE ||
		itemType.decayTime > 0 ||
		itemType.charges > 0 ||
		itemType.stopTime) {
		if (bagItem->size() < bagItem->capacity()) {
			bagItem->addItemBack(item);
		}
		else {
			delete item;
		}
	}
	else {
		if (item->getSlotPosition() & SLOTP_HEAD && !inventory[CONST_SLOT_HEAD]) {
			inventory[CONST_SLOT_HEAD] = item;
		}
		else if (item->getSlotPosition() & SLOTP_NECKLACE && !inventory[CONST_SLOT_NECKLACE]) {
			inventory[CONST_SLOT_NECKLACE] = item;
		}
		else if (item->getSlotPosition() & SLOTP_ARMOR && !inventory[CONST_SLOT_ARMOR]) {
			inventory[CONST_SLOT_ARMOR] = item;
		}
		else if (item->getSlotPosition() & SLOTP_HAND && !inventory[CONST_SLOT_LEFT]) {
			inventory[CONST_SLOT_LEFT] = item;
		}
		else if (item->getSlotPosition() & SLOTP_HAND && !inventory[CONST_SLOT_RIGHT]) {
			inventory[CONST_SLOT_RIGHT] = item;
		}
		else if (item->getSlotPosition() & SLOTP_LEGS && !inventory[CONST_SLOT_LEGS]) {
			inventory[CONST_SLOT_LEGS] = item;
		}
		else if (item->getSlotPosition() & SLOTP_FEET && !inventory[CONST_SLOT_FEET]) {
			inventory[CONST_SLOT_FEET] = item;
		}
		else if (item->getSlotPosition() & SLOTP_RING && !inventory[CONST_SLOT_RING]) {
			inventory[CONST_SLOT_RING] = item;
		}
		else if (item->getSlotPosition() & SLOTP_AMMO && !inventory[CONST_SLOT_AMMO]) {
			inventory[CONST_SLOT_AMMO] = item;
		}
		else {
			if (bagItem->size() < bagItem->capacity()) {
				bagItem->addItemBack(item);
			}
			else {
				delete item;
			}
		}
	}
}

Monster::Monster(MonsterType* mType, const std::vector<LootBlock>* extraLoot /* = nullptr*/) :
	Creature(),
	nameDescription(mType->nameDescription),
	mType(mType)
{
	defaultOutfit = mType->info.outfit;
	currentOutfit = mType->info.outfit;
	skull = mType->info.skull;
	health = mType->info.health;
	healthMax = mType->info.healthMax;
	baseSpeed = mType->info.baseSpeed;
	internalLight = mType->info.light;
	hiddenHealth = mType->info.hiddenHealth;
	currentSkill = mType->info.baseSkill;
	skillFactorPercent = mType->info.skillFactorPercent;
	skillNextLevel = mType->info.skillNextLevel;
	direction = DIRECTION_NORTH;

	// register creature events
	for (const std::string& scriptName : mType->info.scripts) {
		if (!registerCreatureEvent(scriptName)) {
			std::cout << "[Warning - Monster::Monster] Unknown event name: " << scriptName << std::endl;
		}
	}

	if (!g_config.getBoolean(ConfigManager::MONSTERS_SPAWN_WITH_LOOT)) {
		return;
	}

	// inventory loot generation
	Container* bagItem = Item::CreateItem(1987, 1)->getContainer();
	if (!bagItem) {
		return;
	}

	const int32_t configRate = g_config.getNumber(ConfigManager::RATE_LOOT);
	for (auto lootInfo = mType->info.lootItems.rbegin(); lootInfo != mType->info.lootItems.rend(); ++lootInfo) {
		const int32_t lootrate = lootInfo->chance * (configRate > 0 ? configRate : 1);

		if (uniform_random(0, MAX_LOOTCHANCE) <= lootrate) {
			Item* item = Item::CreateItem(lootInfo->id, static_cast<uint16_t>(random(1, static_cast<int32_t>(lootInfo->countmax))));
			if (!item) {
				continue;
			}

			const ItemType& itemType = Item::items.getItemType(lootInfo->id);
			if (itemType.charges > 0) {
				item->setCharges(static_cast<uint16_t>(itemType.charges));
			}

			if (itemType.isFluidContainer()) {
				item->setSubType(FLUID_NONE);
			}

			addMonsterItemInventory(bagItem, item);
		}
	}

	if (extraLoot) {
		for (auto& lootInfo : *extraLoot) {
			const int32_t lootrate = lootInfo.chance * (configRate > 0 ? configRate : 1);

			if (uniform_random(0, MAX_LOOTCHANCE) <= lootrate) {
				Item* item = Item::CreateItem(lootInfo.id, static_cast<uint16_t>(random(1, static_cast<int32_t>(lootInfo.countmax))));
				if (!item) {
					continue;
				}

				const ItemType& itemType = Item::items.getItemType(lootInfo.id);
				if (itemType.charges > 0) {
					item->setCharges(static_cast<uint16_t>(itemType.charges));
				}

				if (itemType.isFluidContainer()) {
					item->setSubType(FLUID_NONE);
				}

				addMonsterItemInventory(bagItem, item);
			}
		}
	}

	if (bagItem->getItemHoldingCount() != 0) {
		inventory[CONST_SLOT_BACKPACK] = bagItem;
	} else {
		bagItem->decrementReferenceCounter();
	}
}

Monster::~Monster()
{
	if (isSummon()) {
		if (master) {
			master->decrementReferenceCounter();
			master = nullptr;
		}
	}

	for (int32_t slot = CONST_SLOT_FIRST; slot <= CONST_SLOT_LAST; slot++) {
		if (Item* inventoryItem = inventory[slot]) {
			inventoryItem->decrementReferenceCounter();
		}
	}

	clearTargetList();
}

void Monster::addList()
{
	g_game.addMonster(this);
}

void Monster::removeList()
{
	g_game.removeMonster(this);
}

const std::string& Monster::getName() const
{
	if (name.empty()) {
		return mType->name;
	}
	return name;
}

void Monster::setName(const std::string& newName)
{
	if (getName() == newName) {
		return;
	}

	this->name = newName;

	// NOTE: Due to how client caches known creatures,
	// it is not feasible to send creature update to everyone that has ever met it
	SpectatorVec spectators;
	g_game.map.getSpectators(spectators, position, true, true);
	for (Creature* spectator : spectators) {
		if (Player* tmpPlayer = spectator->getPlayer()) {
			tmpPlayer->sendUpdateTileCreature(this);
		}
	}
}

const std::string& Monster::getNameDescription() const
{
	if (nameDescription.empty()) {
		return mType->nameDescription;
	}
	return nameDescription;
}

bool Monster::canSee(const Position& pos) const
{
	return Creature::canSee(getPosition(), pos, 10, 10);
}

bool Monster::canWalkOnFieldType(CombatType_t combatType) const
{
	switch (combatType) {
		case COMBAT_ENERGYDAMAGE:
			return mType->info.canWalkOnEnergy;
		case COMBAT_FIREDAMAGE:
			return mType->info.canWalkOnFire;
		case COMBAT_EARTHDAMAGE:
			return mType->info.canWalkOnPoison;
		default:
			return true;
	}
}

void Monster::onCreatureAppear(Creature* creature, bool isLogin)
{
	Creature::onCreatureAppear(creature, isLogin);

	if (mType->info.creatureAppearEvent != -1) {
		// onCreatureAppear(self, creature)
		LuaScriptInterface* scriptInterface = mType->info.scriptInterface;
		if (!scriptInterface->reserveScriptEnv()) {
			std::cout << "[Error - Monster::onCreatureAppear] Call stack overflow" << std::endl;
			return;
		}

		ScriptEnvironment* env = scriptInterface->getScriptEnv();
		env->setScriptId(mType->info.creatureAppearEvent, scriptInterface);

		lua_State* L = scriptInterface->getLuaState();
		scriptInterface->pushFunction(mType->info.creatureAppearEvent);

		LuaScriptInterface::pushUserdata<Monster>(L, this);
		LuaScriptInterface::setMetatable(L, -1, "Monster");

		LuaScriptInterface::pushUserdata<Creature>(L, creature);
		LuaScriptInterface::setCreatureMetatable(L, -1, creature);

		if (scriptInterface->callFunction(2)) {
			return;
		}
	}

	if (creature == this) {
		updateTargetList();
		updateIdleStatus();
		addYieldToDo();
	} else {
		onCreatureEnter(creature);

		addYieldToDo();
	}
}

void Monster::onRemoveCreature(Creature* creature, bool isLogout)
{
	Creature::onRemoveCreature(creature, isLogout);

	if (mType->info.creatureDisappearEvent != -1) {
		// onCreatureDisappear(self, creature)
		LuaScriptInterface* scriptInterface = mType->info.scriptInterface;
		if (!scriptInterface->reserveScriptEnv()) {
			std::cout << "[Error - Monster::onCreatureDisappear] Call stack overflow" << std::endl;
			return;
		}

		ScriptEnvironment* env = scriptInterface->getScriptEnv();
		env->setScriptId(mType->info.creatureDisappearEvent, scriptInterface);

		lua_State* L = scriptInterface->getLuaState();
		scriptInterface->pushFunction(mType->info.creatureDisappearEvent);

		LuaScriptInterface::pushUserdata<Monster>(L, this);
		LuaScriptInterface::setMetatable(L, -1, "Monster");

		LuaScriptInterface::pushUserdata<Creature>(L, creature);
		LuaScriptInterface::setCreatureMetatable(L, -1, creature);

		if (scriptInterface->callFunction(2)) {
			return;
		}
	}

	if (creature == this) {
		if (spawn) {
			spawn->decreaseMonsterCount();
			spawn->startSpawnCheck(Spawns::calculateSpawnDelay(spawnInterval));
		}

		setIdle(true);
	} else {
		onCreatureLeave(creature);
	}
}

void Monster::onCreatureMove(Creature* creature, const Tile* newTile, const Position& newPos,
                             const Tile* oldTile, const Position& oldPos, bool teleport)
{
	Creature::onCreatureMove(creature, newTile, newPos, oldTile, oldPos, teleport);

	if (mType->info.creatureMoveEvent != -1) {
		// onCreatureMove(self, creature, oldPosition, newPosition)
		LuaScriptInterface* scriptInterface = mType->info.scriptInterface;
		if (!scriptInterface->reserveScriptEnv()) {
			std::cout << "[Error - Monster::onCreatureMove] Call stack overflow" << std::endl;
			return;
		}

		ScriptEnvironment* env = scriptInterface->getScriptEnv();
		env->setScriptId(mType->info.creatureMoveEvent, scriptInterface);

		lua_State* L = scriptInterface->getLuaState();
		scriptInterface->pushFunction(mType->info.creatureMoveEvent);

		LuaScriptInterface::pushUserdata<Monster>(L, this);
		LuaScriptInterface::setMetatable(L, -1, "Monster");

		LuaScriptInterface::pushUserdata<Creature>(L, creature);
		LuaScriptInterface::setCreatureMetatable(L, -1, creature);

		LuaScriptInterface::pushPosition(L, oldPos);
		LuaScriptInterface::pushPosition(L, newPos);

		if (scriptInterface->callFunction(4)) {
			return;
		}
	}

	if (creature == this) {
		if (isAttackPanicking && !isReachingTarget) {
			panicToggleCount++;
		}

		if (attackedCreature) {
			const Position& followPosition = attackedCreature->getPosition();
			const Position& position = getPosition();

			const int32_t offset_x = Position::getDistanceX(followPosition, position);
			const int32_t offset_y = Position::getDistanceY(followPosition, position);
			if ((offset_x > 1 || offset_y > 1) && mType->info.changeTargetChance > 0) {
				const Direction dir = getDirectionTo(position, followPosition);
				const Position& checkPosition = getNextPosition(dir, position);

				if (const Tile* tile = g_game.map.getTile(checkPosition)) {
					const Creature* topCreature = tile->getTopCreature();
					if (topCreature && attackedCreature != topCreature && isOpponent(topCreature)) {
						attackedCreature = nullptr;
					}
				}
			}
		}

		updateTargetList();
		updateIdleStatus();
		addYieldToDo();
	} else {
		const bool canSeeNewPos = canSee(newPos);
		const bool canSeeOldPos = canSee(oldPos);

		if (canSeeNewPos && !canSeeOldPos) {
			onCreatureEnter(creature);
		} else if (!canSeeNewPos && canSeeOldPos) {
			onCreatureLeave(creature);
		}

		updateIdleStatus();
		addYieldToDo();

		if (creature == attackedCreature) {
			if (isExecuting && currentToDo < totalToDo && toDoEntries[currentToDo].type == TODO_ATTACK) {
				const int64_t now = OTSYS_TIME();
				if (now < earliestMeleeAttack && earliestMeleeAttack - now > 200) {
					if (newPos.z != getPosition().z || !Position::areInRange<1, 1>(getPosition(), newPos)) {
						clearToDo();
						if (mType->info.targetDistance == 1) {
							addWaitToDo(100);
						}
						startToDo();
					}
				}
			}
		}
	}
}

void Monster::onCreatureSay(Creature* creature, SpeakClasses type, const std::string& text)
{
	Creature::onCreatureSay(creature, type, text);

	if (mType->info.creatureSayEvent != -1) {
		// onCreatureSay(self, creature, type, message)
		LuaScriptInterface* scriptInterface = mType->info.scriptInterface;
		if (!scriptInterface->reserveScriptEnv()) {
			std::cout << "[Error - Monster::onCreatureSay] Call stack overflow" << std::endl;
			return;
		}

		ScriptEnvironment* env = scriptInterface->getScriptEnv();
		env->setScriptId(mType->info.creatureSayEvent, scriptInterface);

		lua_State* L = scriptInterface->getLuaState();
		scriptInterface->pushFunction(mType->info.creatureSayEvent);

		LuaScriptInterface::pushUserdata<Monster>(L, this);
		LuaScriptInterface::setMetatable(L, -1, "Monster");

		LuaScriptInterface::pushUserdata<Creature>(L, creature);
		LuaScriptInterface::setCreatureMetatable(L, -1, creature);

		lua_pushnumber(L, type);
		LuaScriptInterface::pushString(L, text);

		scriptInterface->callVoidFunction(4);
	}
}

void Monster::addTarget(Creature* creature, bool pushFront/* = false*/)
{
	assert(creature != this);
	if (std::find(targetList.begin(), targetList.end(), creature) == targetList.end()) {
		creature->incrementReferenceCounter();
		if (pushFront) {
			targetList.push_front(creature);
		} else {
			targetList.push_back(creature);
		}
	}
}

void Monster::removeTarget(Creature* creature)
{
	const auto& it = std::find(targetList.begin(), targetList.end(), creature);
	if (it != targetList.end()) {
		creature->decrementReferenceCounter();
		targetList.erase(it);
	}
}

void Monster::updateTargetList()
{
	auto targetIterator = targetList.begin();
	while (targetIterator != targetList.end()) {
		Creature* creature = *targetIterator;
		if (creature->getHealth() <= 0 || !canSee(creature->getPosition())) {
			creature->decrementReferenceCounter();
			targetIterator = targetList.erase(targetIterator);
		} else {
			++targetIterator;
		}
	}

	SpectatorVec spectators;
	g_game.map.getSpectators(spectators, position, true);
	spectators.erase(this);
	for (Creature* spectator : spectators) {
		onCreatureFound(spectator);
	}
}

void Monster::clearTargetList()
{
	for (Creature* creature : targetList) {
		creature->decrementReferenceCounter();
	}
	targetList.clear();
}

void Monster::addSkillPoint()
{
	if (skillLearningPoints == 0 || skillFactorPercent <= 999) {
		return;
	}

	skillCurrentExp++;
	if (skillCurrentExp < skillNextLevel) {
		return;
	}
	skillCurrentExp = 0;

	const int32_t delta = skillNextLevel;

	currentSkill += mType->info.skillAddCount;

	if (skillFactorPercent <= 1049) {
		skillNextLevel = delta * (currentSkill + 2 - mType->info.baseSkill);
		return;
	}

	const double factor = skillFactorPercent / 1000.0;
	double pow;

	if (static_cast<int32_t>(currentSkill + 2 - mType->info.baseSkill) < 0) {
		pow = 1.0 / std::pow(factor, mType->info.baseSkill - currentSkill + 2);
	} else {
		pow = std::pow(factor, currentSkill + 2 - mType->info.baseSkill);
	}

	const double formula = (pow / 1.0) / (factor / 1.0) * delta;
	skillNextLevel = static_cast<uint32_t>(formula);
}

void Monster::onCreatureFound(Creature* creature, bool pushFront/* = false*/)
{
	if (!creature) {
		return;
	}

	if (!canSee(creature->getPosition())) {
		return;
	}

	if (isOpponent(creature)) {
		addTarget(creature, pushFront);
	}

	updateIdleStatus();
	addYieldToDo();
}

void Monster::onCreatureEnter(Creature* creature)
{
	onCreatureFound(creature, true);
}

bool Monster::isOpponent(const Creature* creature) const
{
	if (isSummon() && getMaster()->getPlayer()) {
		if (creature == getMaster()) {
			return false;
		}
	} else {
		if (creature->isSummon()) {
			if (creature->master->getMonster()) {
				return false;
			}
		} else if (creature->getMonster()) {
			// monsters cannot attack eachother
			return false;
		}

		if (creature->getNpc()) {
			return false;
		}
	}

	if (const Player* player = creature->getPlayer()) {
		if (player->isInGhostMode()) {
			return false; // ignore ghost mode GMs walking around
		}
	}
	return true;
}

bool Monster::isCreatureAvoidable(const Creature* creature) const
{
	if (const Monster* monster = creature->getMonster()) {
		if (!canPushCreatures()) {
			return false;
		}

		if (!monster->isPushable()) {
			return false;
		}
	} else if (const Player* player = creature->getPlayer()) {
		if (!player->isInGhostMode() && player != master) {
			return false;
		}
	} 

	return true;
}

void Monster::onCreatureLeave(Creature* creature)
{
	//update targetList
	if (isOpponent(creature)) {
		removeTarget(creature);
		updateIdleStatus();
	}
}

BlockType_t Monster::blockHit(Creature* attacker, CombatType_t combatType, int32_t& damage,
                              bool checkDefense /* = false*/, bool checkArmor /* = false*/, bool /* field = false */, bool /* ignoreResistances = false */, bool meleeHit /*= false*/)
{
	BlockType_t blockType = Creature::blockHit(attacker, combatType, damage, checkDefense, checkArmor, false, false, meleeHit);

	if (damage != 0) {
		int32_t elementMod = 0;
		const auto& it = mType->info.elementMap.find(combatType);
		if (it != mType->info.elementMap.end()) {
			elementMod = it->second;
		}

		if (elementMod != 0) {
			damage = static_cast<int32_t>(std::round(damage * ((100 - elementMod) / 100.)));
			if (damage <= 0) {
				damage = 0;
				blockType = BLOCK_ARMOR;
			}
		}
	}

	return blockType;
}

bool Monster::isTarget(const Creature* creature) const
{
	if (creature->isRemoved() || !creature->isAttackable() ||
	        creature->getZone() == ZONE_PROTECTION || !canSeeCreature(creature)) {
		return false;
	}

	if (creature->getPosition().z != getPosition().z) {
		return false;
	}

	return true;
}

bool Monster::selectTarget(Creature* creature)
{
	if (!isTarget(creature)) {
		return false;
	}

	return setAttackedCreature(creature);
}

void Monster::setIdle(bool idle)
{
	if (isRemoved() || getHealth() <= 0) {
		return;
	}

	isIdle = idle;

	if (!isIdle) {
		g_game.addCreatureCheck(this);
	} else {
		onIdleStatus();
		clearTargetList();
		Game::removeCreatureCheck(this);
	}
}

void Monster::updateIdleStatus()
{
	bool idle = false;
	if (!isSummon() && targetList.empty()) {
		// never idle if there are active conditions
		idle = conditions.empty();
	}

	setIdle(idle);
}

void Monster::onAddCondition(ConditionType_t type)
{
	if (type == CONDITION_FIRE && isImmune(COMBAT_FIREDAMAGE)) {
		removeCondition(CONDITION_FIRE);
	}

	if (type == CONDITION_POISON && isImmune(COMBAT_EARTHDAMAGE)) {
		removeCondition(CONDITION_POISON);
	}

	if (type == CONDITION_ENERGY && isImmune(COMBAT_ENERGYDAMAGE)) {
		removeCondition(CONDITION_ENERGY);
	}

	updateIdleStatus();
}

void Monster::onEndCondition(ConditionType_t type)
{
	updateIdleStatus();
}

void Monster::onAttackedCreature(Creature* creature, bool addInFightTicks /* = true */)
{
	Creature::onAttackedCreature(creature, addInFightTicks);

	if (isSummon()) {
		master->onAttackedCreature(creature, addInFightTicks);
	}
}

void Monster::onAttackedCreatureBlockHit(BlockType_t blockType, bool meleeHit /* = false */)
{
	switch (blockType) {
		case BLOCK_NONE: {
			// This function is called for any damage being dealt, so only reset skill points from a melee attack
			if (meleeHit) {
				skillLearningPoints = 30;
			}
			break;
		}

		case BLOCK_IMMUNITY:
		case BLOCK_DEFENSE:
		case BLOCK_ARMOR: {
			//need to draw blood every 30 hits
			if (skillLearningPoints > 0) {
				--skillLearningPoints;
			}
			break;
		}

		default: {
			break;
		}
	}
}

void Monster::onIdleStimulus()
{
	if (isIdle || isExecuting || isRemoved() || getHealth() <= 0) {
		return;
	}

	// Panic toggle count means 3 steps before entering normal state
	// This is following CIP monster states in code
	if (isAttackPanicking && panicToggleCount >= 3) {
		isAttackPanicking = false;
		panicToggleCount = 0;
	}

	isReachingTarget = false;

	if (g_config.getBoolean(ConfigManager::REMOVE_ON_DESPAWN) && 
		!isInSpawnRange(getPosition()) || 
		(lifeTimeExpiration > 0 && OTSYS_TIME() >= static_cast<int64_t>(lifeTimeExpiration))) {
		g_game.addMagicEffect(this->getPosition(), CONST_ME_POFF);
		g_game.removeCreature(this);
		return;
	}

	if (isSummon()) {
		if (master->getHealth() <= 0) {
			changeHealth(-getMaxHealth());
			return;
		}
		
		if (master->isRemoved()) {
			if (master->getPlayer()) {
				g_game.removeCreature(this);
				g_game.addMagicEffect(getPosition(), CONST_ME_POFF);
			} else {
				changeHealth(-getMaxHealth());
			}
			return;
		}

		const Position& myPos = getPosition();
		const Position& ourMasterPos = master->getPosition();

		if (!Position::areInRange<30, 30, 1>(myPos, ourMasterPos)) {
			if (master->getPlayer()) {
				g_game.removeCreature(this);
				g_game.addMagicEffect(getPosition(), CONST_ME_POFF);
			} else {
				changeHealth(-getMaxHealth());
			}
			return;
		}

		if (!canSee(ourMasterPos)) {
			addWaitToDo(1000);
			startToDo();
			return;
		}

		bool allowTargeting = true;
		if (!canSeeCreature(master)) {
			if (master->getMonster()) {
				allowTargeting = true;
			} else if (master->getAttackedCreature() == nullptr || master->getAttackedCreature() == this) {
				allowTargeting = false;
			}
		}

		if (master->getZone() == ZONE_PROTECTION || !allowTargeting || myPos.z != ourMasterPos.z) {
			doDefensiveSpells();
			addWaitToDo(1000);
			if (master->getAttackedCreature() == this) {
				Direction dir;
				if (getRandomStep(getPosition(), dir)) {
					addWalkToDo(dir);
					addWaitToDo(1000);
				}
			}
			startToDo();
			return;
		}

		attackedCreature = master->getAttackedCreature();

		if (attackedCreature == this) {
			attackedCreature = nullptr;
		}

		if (!attackedCreature) {
			// begin talking
			const int32_t r = rand();
			if (r == 50 * (r / 50) && !mType->info.voiceVector.empty()) {
				const voiceBlock_t& voiceBlock = mType->info.voiceVector[random(0, static_cast<int32_t>(mType->info.voiceVector.size() - 1))];
				g_game.internalCreatureSay(this, voiceBlock.yellText ? TALKTYPE_MONSTER_YELL : TALKTYPE_MONSTER_SAY, voiceBlock.text, false);
			}

			// entering here exits the function
			doDefensiveSpells();

			const int32_t distance = Position::getDistanceX(myPos, ourMasterPos) + Position::getDistanceY(ourMasterPos, myPos);
			if (distance > 1) {
				if (distance == 2) {
					// Is within range; do nothing
					addWaitToDo(1000);
					startToDo();
				} else {
					int32_t maxDist = 1;
					if (myPos.x == ourMasterPos.x || myPos.y == ourMasterPos.y) {
						maxDist++; // We want to move 1 sqm away, unless we are on the same axis
					}
					if (distance == 3) {
						addWaitToDo(1000); // Add a slow step when close to being in range
					}
					std::vector<Direction> dirList;
					if (getPathTo(ourMasterPos, dirList, 1, maxDist, true, true, 12)) {
						// Try find a path to master
						addWalkToDo(dirList, 3);
						startToDo();
					} else {
						// Master unreachable, step randomly
						Direction dir;
						getRandomStep(myPos, dir);
						addWalkToDo(dir);
						addWaitToDo(1000);
						startToDo();
					}
				}
			} else {
				//Too close, take a random step out of the way
				Direction dir;
				getRandomStep(myPos, dir);
				addWalkToDo(dir);
				addWaitToDo(1000);
				startToDo();
			}
			return;
		}
	}

	if (attackedCreature) {
		if (!isTarget(attackedCreature) || !canSee(attackedCreature->getPosition())) {
			attackedCreature = nullptr;
		}

		if (!isSummon() && mType->info.changeTargetChance > random(0, 99)) {
			attackedCreature = nullptr;			
		}
	}

	// begin talking
	const int32_t r = rand();
	if (r == 50 * (r / 50) && !mType->info.voiceVector.empty()) {
		const voiceBlock_t& voiceBlock = mType->info.voiceVector[random(0, static_cast<int32_t>(mType->info.voiceVector.size() - 1))];
		g_game.internalCreatureSay(this, voiceBlock.yellText ? TALKTYPE_MONSTER_YELL : TALKTYPE_MONSTER_SAY, voiceBlock.text, false);
	}

	// begin select target
	std::vector<Direction> tempDirList;
	if (!isSummon() && attackedCreature && !getPathTo(attackedCreature->getPosition(), tempDirList, 0, 1, true, true, 8)) {
		attackedCreature = nullptr;
	}

	if ((!attackedCreature && !isSummon())) {
		int32_t goodness = std::numeric_limits<int32_t>::max();
		int32_t tieBreaker = 0;
		int32_t randomResult = random(0, 99);
		TargetSearchType_t targetSearchType = TARGETSEARCH_NONE;

		if (randomResult < mType->info.strategyNearestEnemy) {
			targetSearchType = TARGETSEARCH_NEAREST;
		} else {
			randomResult -= mType->info.strategyNearestEnemy;
		}

		if (targetSearchType == TARGETSEARCH_NONE && randomResult < mType->info.strategyWeakestEnemy) {
			targetSearchType = TARGETSEARCH_WEAKEST;
		} else {
			randomResult -= mType->info.strategyWeakestEnemy;
		}

		if (targetSearchType == TARGETSEARCH_NONE && randomResult < mType->info.strategyMostDamageEnemy) {
			targetSearchType = TARGETSEARCH_MOSTDAMAGE;
			goodness = 0;
		} else {
			randomResult -= mType->info.strategyMostDamageEnemy;
		}

		if (targetSearchType == TARGETSEARCH_NONE) {
			targetSearchType = TARGETSEARCH_RANDOM;
		}

		SpectatorVec spectators;
		g_game.map.getSpectators(spectators, getPosition(), false, false, 10, 10, 10, 10);
		spectators.erase(this); // Always delete self

		// Correct spectator vector
		SpectatorVec copySpectators = spectators;
		for (Creature* spectator : copySpectators) {
			if (!isOpponent(spectator) || !isTarget(spectator)) {
				spectators.erase(spectator);
			}
		}

		//spectators = copySpectators;

		for (Creature* spectator : spectators) {
			const Position& myPos = getPosition();
			const Position& spectatorPos = spectator->getPosition();
			int32_t distance = std::max<int32_t>(Position::getDistanceX(myPos, spectatorPos), Position::getDistanceY(myPos, spectatorPos));

			if (distance > 10) {
				continue;
			}

			if (targetSearchType == TARGETSEARCH_MOSTDAMAGE) {
				const int32_t totalDamage = getDamageDealtByAttacker(spectator);
				randomResult = random(0, 99);
				if (totalDamage > goodness || totalDamage == goodness && randomResult > tieBreaker) {
					selectTarget(spectator); // select this target
					goodness = totalDamage;
					tieBreaker = randomResult;
				}
			} else if (targetSearchType == TARGETSEARCH_WEAKEST) {
				const int32_t health = spectator->getMaxHealth();
				randomResult = random(0, 99);
				if (health < goodness || health == goodness && randomResult > tieBreaker) {
					selectTarget(spectator); // select this target
					goodness = health;
					tieBreaker = randomResult;
				}
			} else if (targetSearchType == TARGETSEARCH_NEAREST) {
				distance = Position::getDistanceX(myPos, spectatorPos) + Position::getDistanceY(myPos, spectatorPos);
				randomResult = random(0, 99);
				if (distance < goodness || distance == goodness && randomResult > tieBreaker) {
					selectTarget(spectator); // select this target
					goodness = distance;
					tieBreaker = randomResult;
				}
			} else {
				distance = 0;
				randomResult = random(0, 99);
				if (distance < goodness || distance == goodness && randomResult > tieBreaker) {
					selectTarget(spectator); // select this target
					goodness = distance;
					tieBreaker = randomResult;
				}
			}
		}

		/*if (!attackedCreature && randomTarget) {
			if (spectators.size() == 1) {
				selectTarget(spectators.at(0));
			} else {
				selectTarget(spectators.at(uniform_random(0, spectators.size() - 1)));
			}
		}*/
	} // end select target

	doAttackSpells();
	doDefensiveSpells();

	if (attackedCreature && isOpponent(attackedCreature) && !isSummon() && summons.size() < mType->info.maxSummons) {
		for (const summonBlock_t& summonBlock : mType->info.summons) {
			if (summons.size() >= mType->info.maxSummons) {
				continue;
			}

			uint32_t summonCount = 0;
			for (const Creature* summon : summons) {
				if (summon->getName() == summonBlock.name) {
					++summonCount;
				}
			}

			if (summonCount >= summonBlock.max) {
				continue;
			}

			if (!uniform_random(0, summonBlock.delay) && (isSummon() || !isFleeing() || uniform_random(1, 3) == 1)) {
				if (Monster* summon = Monster::createMonster(summonBlock.name)) {
					Position pos = getPosition();
					g_game.searchSummonField(pos.x, pos.y, pos.z, 2);
					if (g_game.placeCreature(summon, pos, summonBlock.force)) {
						summon->setDropLoot(false);
						summon->setSkillLoss(false);
						summon->setMaster(this);
						g_game.addMagicEffect(getPosition(), CONST_ME_MAGIC_BLUE);
						g_game.addMagicEffect(summon->getPosition(), CONST_ME_TELEPORT);
					} else {
						delete summon;
					}
				}
			}
		}
	} // end spell casting

	if (attackedCreature && (attackedCreature != master)) {
		const Position& myPos = getPosition();
		const Position& targetPos = attackedCreature->getPosition();

		if (isFleeing() && !isSummon()) {
			Direction dir;
			if (!getFlightStep(targetPos, dir)) {
				getRandomStep(myPos, dir);
				addWaitToDo(1000);
			}
			addWalkToDo(dir);
			if (getSpeed() == 0) {
				addWaitToDo(1000);
			}
			startToDo();
			return;
		}

		int32_t maxSteps = 3;
		if (mType->info.targetDistance > 1 && g_game.canThrowObjectTo(myPos, targetPos, false)) {
			const int32_t distance = std::max<int32_t>(Position::getDistanceX(myPos, targetPos), Position::getDistanceY(myPos, targetPos));
			if (distance < mType->info.targetDistance) {
				Direction dir;
				isAttackPanicking = false;
				if (!getFlightStep(targetPos, dir)) {
					addWaitToDo(1000);
					updateLookDirection();
					addAttackToDo();
					startToDo();
					return;
				}

				addWalkToDo(dir);

				if (isEscaping) {
					addWaitToDo(1000);
				}

				if (distance <= 1) {
					updateLookDirection();
					addAttackToDo();
					isEscaping = true;
				} else {
					addWaitToDo(100);
					isEscaping = false;
				}

				startToDo();
				return;
			}

			if (distance == mType->info.targetDistance) {
				isEscaping = false;

				int32_t currentX = myPos.x;
				int32_t currentY = myPos.y;
				const int32_t danceRandom = rand();
				const int32_t dancingOdds = danceRandom % 5;

				if (danceRandom % 5 == 1) {
					direction = DIRECTION_EAST;
					currentX++;
				} else if (dancingOdds <= 1) {
					if (danceRandom == 5 * (danceRandom / 5)) {
						direction = DIRECTION_WEST;
						currentX--;
					}
				} else if (dancingOdds == 2) {
					direction = DIRECTION_NORTH;
					currentY--;
				} else if (dancingOdds == 3) {
					direction = DIRECTION_SOUTH;
					currentY++;
				}

				if (dancingOdds <= 3 && canWalkTo(myPos, direction)) {
					const int32_t xdistance = std::abs(targetPos.x - currentX);
					const int32_t ydistance = std::abs(targetPos.y - currentY);
					int32_t stepdistance = ydistance;

					if (xdistance >= ydistance) {
						stepdistance = xdistance;
					}

					if (stepdistance == 4) {
						addWalkToDo(direction);
					}
				}

				updateLookDirection();
				addAttackToDo();
				addWaitToDo(1000);
				startToDo();
				return;
			}

			isEscaping = false;
			maxSteps = distance - 4 + 1;
		} else {
			if (Position::areInRange<1, 1>(myPos, targetPos)) {
				if (!isHostile() && isSummon() || isHostile()) {
					const int32_t danceRandom = rand();
					const int32_t dancingOdds = danceRandom % 5;

					int32_t currentX = myPos.x;
					int32_t currentY = myPos.y;

					if (danceRandom % 5 == 1) {
						direction = DIRECTION_EAST;
						currentX++;
					} else if (dancingOdds <= 1) {
						if (danceRandom == 5 * (danceRandom / 5)) {
							direction = DIRECTION_WEST;
							currentX--;
						}
					} else if (dancingOdds == 2) {
						direction = DIRECTION_NORTH;
						currentY--;
					} else if (dancingOdds == 3) {
						direction = DIRECTION_SOUTH;
						currentY++;
					}

					Position position = myPos;
					position.x = static_cast<uint16_t>(currentX);
					position.y = static_cast<uint16_t>(currentY);

					if (Position::areInRange<1, 1>(position, targetPos) && dancingOdds <= 3 && canWalkTo(myPos, direction)) {
						addWalkToDo(direction);
					}
				}

				updateLookDirection();
				addAttackToDo();
				addWaitToDo(1000);
				startToDo();
				return;
			}
		}

		std::vector<Direction> dirList;
		if (!isSummon()) {
			pathBlockCheck = true;
		}
		const bool foundPath = getPathTo(targetPos, dirList, 0, 1, true, true, 12);
		pathBlockCheck = false;

		if (foundPath) {
			isReachingTarget = true;
			addWalkToDo(dirList, maxSteps);
			updateLookDirection();
			addAttackToDo();
			addWaitToDo(100);
			startToDo();
			return;
		}

		addWaitToDo(100);
		updateLookDirection();
		addAttackToDo();
	}

	Direction dir;
	if (getRandomStep(getPosition(), dir)) {
		addWalkToDo(dir);
		addWaitToDo(1000);
		updateLookDirection();
	} else {
		addWaitToDo(1000);
	}

	startToDo();
}

void Monster::onThink(uint32_t interval)
{
	Creature::onThink(interval);

	if (mType->info.thinkEvent != -1) {
		// onThink(self, interval)
		LuaScriptInterface* scriptInterface = mType->info.scriptInterface;
		if (!scriptInterface->reserveScriptEnv()) {
			std::cout << "[Error - Monster::onThink] Call stack overflow" << std::endl;
			return;
		}

		ScriptEnvironment* env = scriptInterface->getScriptEnv();
		env->setScriptId(mType->info.thinkEvent, scriptInterface);

		lua_State* L = scriptInterface->getLuaState();
		scriptInterface->pushFunction(mType->info.thinkEvent);

		LuaScriptInterface::pushUserdata<Monster>(L, this);
		LuaScriptInterface::setMetatable(L, -1, "Monster");

		lua_pushnumber(L, interval);

		if (scriptInterface->callFunction(2)) {
			return;
		}
	}

	if (isInSpawnRange(position)) {
		updateIdleStatus();
	}
}

void Monster::doAttacking()
{
	if (!attackedCreature || getHealth() <= 0 || isRemoved() || mType->info.baseSkill == 0) {
		return;
	}

	const Position& myPos = getPosition();
	const Position& targetPos = attackedCreature->getPosition();

	int64_t nextAttackTime = OTSYS_TIME() + 200;
	if (earliestMeleeAttack >= nextAttackTime) {
		nextAttackTime = earliestMeleeAttack;
	}
	earliestMeleeAttack = nextAttackTime;

	for (spellBlock_t& spellBlock : mType->info.attackSpells) {
		if (!spellBlock.isMelee) {
			continue;
		}

		if (attackedCreature->getZone() != ZONE_PROTECTION && Position::areInRange<1, 1, 0>(myPos, targetPos)) {
			spellBlock.minCombatValue = spellBlock.maxCombatValue = -Weapons::getMaxMeleeDamage(currentSkill, mType->info.baseAttack);
			minCombatValue = maxCombatValue = spellBlock.maxCombatValue;

			spellBlock.spell->castSpell(this, attackedCreature);

			addSkillPoint();

			isAttackPanicking = false;

			nextAttackTime = OTSYS_TIME() + 2000;
			if (earliestMeleeAttack >= nextAttackTime) {
				nextAttackTime = earliestMeleeAttack;
			}
			earliestMeleeAttack = nextAttackTime;
		}

		break;
	}
}

bool Monster::pushItem(const Position& fromPos, Item* item)
{
	const Position& itemPos = item->getPosition();
	Cylinder* toCylinder = nullptr;
	Tile* tile;

	if (itemPos.y - 1 == fromPos.y) {
		tile = g_game.map.getTile(itemPos.x, itemPos.y + 1, itemPos.z);
		if (tile && tile->getGround() && !tile->hasFlag(TILESTATE_BLOCKSOLID) && tile->getCreatureCount() == 0) {
			toCylinder = tile;
		}
	}

	if (itemPos.y + 1 == fromPos.y) {
		tile = g_game.map.getTile(itemPos.x, itemPos.y - 1, itemPos.z);
		if (tile && tile->getGround() && !tile->hasFlag(TILESTATE_BLOCKSOLID) && tile->getCreatureCount() == 0) {
			toCylinder = tile;
		}
	}

	if (itemPos.x - 1 == fromPos.x) {
		tile = g_game.map.getTile(itemPos.x + 1, itemPos.y, itemPos.z);
		if (tile && tile->getGround() && !tile->hasFlag(TILESTATE_BLOCKSOLID) && tile->getCreatureCount() == 0) {
			toCylinder = tile;
		}
	}

	if (itemPos.x + 1 == fromPos.x) {
		tile = g_game.map.getTile(itemPos.x - 1, itemPos.y, itemPos.z);
		if (tile && tile->getGround() && !tile->hasFlag(TILESTATE_BLOCKSOLID) && tile->getCreatureCount() == 0) {
			toCylinder = tile;
		}
	}

	if (!toCylinder) {
		tile = g_game.map.getTile(itemPos.x, itemPos.y - 1, itemPos.z);
		if (itemPos.y - 1 != fromPos.y && tile && tile->getGround() && !tile->hasFlag(TILESTATE_BLOCKSOLID) && tile->getCreatureCount() == 0) {
			toCylinder = tile;
		} else {
			tile = g_game.map.getTile(itemPos.x, itemPos.y + 1, itemPos.z);
			if (fromPos.y - 1 != itemPos.y && tile && tile->getGround() && !tile->hasFlag(TILESTATE_BLOCKSOLID) && tile->getCreatureCount() == 0) {
				toCylinder = tile;
			} else {
				tile = g_game.map.getTile(itemPos.x - 1, itemPos.y, itemPos.z);
				if (fromPos.x + 1 != itemPos.x && tile && tile->getGround() && !tile->hasFlag(TILESTATE_BLOCKSOLID) && tile->getCreatureCount() == 0) {
					toCylinder = tile;
				} else {
					tile = g_game.map.getTile(itemPos.x + 1, itemPos.y, itemPos.z);
					if (fromPos.x - 1 != itemPos.x && tile && tile->getGround() && !tile->hasFlag(TILESTATE_BLOCKSOLID) && tile->getCreatureCount() == 0) {
						toCylinder = tile;
					}
				}
			}
		}
	}

	if (toCylinder && g_game.internalMoveItem(item->getParent(), toCylinder, INDEX_WHEREEVER, item, item->getItemCount(), nullptr) == RETURNVALUE_NOERROR) {
		return true;
	}

	return false;
}

void Monster::pushItems(const Position& fromPos, Tile* fromTile)
{
	//We can not use iterators here since we can push the item to another tile
	//which will invalidate the iterator.
	//start from the end to minimize the amount of traffic
	if (const TileItemVector* items = fromTile->getItemList()) {
		uint32_t moveCount = 0;
		uint32_t removeCount = 0;

		const int32_t downItemSize = fromTile->getDownItemCount();
		for (int32_t i = downItemSize; --i >= 0;) {
			Item* item = items->at(i);
			if (item && item->hasProperty(CONST_PROP_MOVEABLE) && (item->hasProperty(CONST_PROP_BLOCKPATH)
			        || item->hasProperty(CONST_PROP_BLOCKSOLID))) {
				if (item->getActionId() >= 1000 && item->getActionId() <= 2000) {
					continue;
				}

				if (moveCount < 20 && Monster::pushItem(fromPos, item)) {
					++moveCount;
				} else if (g_game.internalRemoveItem(item) == RETURNVALUE_NOERROR) {
					++removeCount;
				}
			}
		}

		if (removeCount > 0) {
			g_game.addMagicEffect(fromTile->getPosition(), CONST_ME_BLOCKHIT);
		}
	}
}

bool Monster::pushCreature(const Position& fromPos, Creature* creature)
{
	static std::vector<Direction> dirList {
			DIRECTION_NORTH,
		DIRECTION_WEST, DIRECTION_EAST,
			DIRECTION_SOUTH
	};
	std::shuffle(dirList.begin(), dirList.end(), getRandomGenerator());

	for (const Direction dir : dirList) {
		const Position& tryPos = Spells::getCasterPosition(creature, dir);

		if (tryPos == fromPos) {
			continue;
		}

		const Tile* toTile = g_game.map.getTile(tryPos);
		if (toTile && !toTile->hasFlag(TILESTATE_BLOCKPATH)) {
			if (g_game.internalMoveCreature(creature, dir) == RETURNVALUE_NOERROR) {
				return true;
			}
		}
	}
	return false;
}

void Monster::pushCreatures(const Position& fromPos, Tile* fromTile)
{
	//We can not use iterators here since we can push a creature to another tile
	//which will invalidate the iterator.
	if (const CreatureVector* creatures = fromTile->getCreatures()) {
		uint32_t removeCount = 0;
		const Monster* lastPushedMonster = nullptr;

		for (size_t i = 0; i < creatures->size();) {
			Monster* monster = creatures->at(i)->getMonster();
			if (monster && monster->isPushable()) {
				if (monster != lastPushedMonster && Monster::pushCreature(fromPos, monster)) {
					lastPushedMonster = monster;
					continue;
				}

				monster->changeHealth(-monster->getHealth());
				removeCount++;
			}

			++i;
		}

		if (removeCount > 0) {
			g_game.addMagicEffect(fromTile->getPosition(), CONST_ME_BLOCKHIT);
		}
	}
}

bool Monster::getRandomStep(const Position& creaturePos, Direction& resultDir) const
{
	static std::vector<Direction> dirList{
			DIRECTION_NORTH,
		DIRECTION_WEST, DIRECTION_EAST,
			DIRECTION_SOUTH
	};
	std::shuffle(dirList.begin(), dirList.end(), getRandomGenerator());

	for (const Direction dir : dirList) {
		if (canWalkTo(creaturePos, dir)) {
			resultDir = dir;
			return true;
		}
	}
	return false;
}

bool Monster::getFlightStep(const Position& targetPos, Direction& resultDir) const
{
	const Position& creaturePos = getPosition();

	int32_t offsetx = Position::getOffsetX(creaturePos, targetPos);
	int32_t offsety = Position::getOffsetY(creaturePos, targetPos);
	int32_t reverseoffsety = Position::getOffsetY(targetPos, creaturePos);

	if (offsety > -1) {
		reverseoffsety = offsety;
	}

	Direction firstStep = DIRECTION_NONE;

	if (offsetx > reverseoffsety) {
		firstStep = DIRECTION_EAST; // 1
	}

	int32_t helper = offsetx;
	if (offsetx <= -1) {
		helper = -offsetx;
	}

	if (reverseoffsety > helper) {
		firstStep = DIRECTION_NORTH; // 3
	}

	helper = Position::getOffsetY(targetPos, creaturePos);
	if (offsety > -1) {
		helper = offsety;
	}

	if (-offsetx > helper) {
		firstStep = DIRECTION_WEST; // 5
	}

	helper = offsetx;
	if (offsetx <= -1) {
		helper = -offsetx;
	}

	if (offsety > helper) {
		firstStep = DIRECTION_SOUTH; // 7
	}

	///////////////////

	if (canWalkTo(creaturePos, firstStep)) {
		resultDir = firstStep;
		return true;
	}

	// list of possible directions (not-checked)
	std::vector<Direction> directions;
	std::vector<Direction> diagonalDirections;

	if (offsetx >= 0) {
		directions.push_back(DIRECTION_EAST);
	}

	if (offsety <= 0) {
		directions.push_back(DIRECTION_NORTH);
	}

	if (offsetx <= 0) {
		directions.push_back(DIRECTION_WEST);
	}

	if (offsety >= 0) {
		directions.push_back(DIRECTION_SOUTH);
	}

	std::shuffle(std::begin(directions), std::end(directions), getRandomGenerator());

	if (offsetx >= 1 && offsety <= -1 || offsety < 0 && offsetx > 0) {
		diagonalDirections.push_back(DIRECTION_NORTHEAST);
	}

	if (offsetx <= -1 && offsety <= -1 || offsety < 0 && offsetx < 0) {
		diagonalDirections.push_back(DIRECTION_NORTHWEST);
	}

	if (offsetx >= 1 && offsety >= 1 || offsety > 0 && offsetx > 0) {
		diagonalDirections.push_back(DIRECTION_SOUTHEAST);
	}

	if (offsetx <= -1 && offsety >= 1 || offsety > 0 && offsetx < 0) {
		diagonalDirections.push_back(DIRECTION_SOUTHWEST);
	}

	if (diagonalDirections.empty()) {
		if (creaturePos.x - targetPos.x >= creaturePos.y - targetPos.y) {
			directions.push_back(DIRECTION_NORTHEAST);
		}

		if (creaturePos.x - targetPos.x <= targetPos.y - creaturePos.y) {
			directions.push_back(DIRECTION_NORTHWEST);
		}

		if (creaturePos.x - targetPos.x <= creaturePos.y - targetPos.y) {
			directions.push_back(DIRECTION_SOUTHWEST);
		}

		if (creaturePos.x - targetPos.x >= -(creaturePos.y - targetPos.y)) {
			directions.push_back(DIRECTION_SOUTHEAST);
		}
	}

	std::shuffle(std::begin(diagonalDirections), std::end(diagonalDirections), getRandomGenerator());

	for (const Direction& dir : directions) {
		if (canWalkTo(creaturePos, dir)) {
			resultDir = dir;
			return true;
		}
	}

	for (const Direction& dir : diagonalDirections) {
		if (canWalkTo(creaturePos, dir)) {
			resultDir = dir;
			return true;
		}
	}

	return false;
}

bool Monster::canWalkTo(Position pos, Direction dir) const
{
	pos = getNextPosition(dir, pos);
	if (isInSpawnRange(getPosition()) && !isInSpawnRange(pos)) {
		return false;
	}

	const Tile* tile = g_game.map.getTile(pos);
	if (!tile) {
		return false;
	}

	uint32_t flags = FLAG_PATHFINDING;
	if (isPathBlockingChecking()) {
		flags |= FLAG_IGNOREBLOCKCREATURE;
	}

	if (tile->queryAdd(0, *this, 1, flags) != RETURNVALUE_NOERROR) {
		return false;
	}

	const Creature* topCreature = tile->getTopVisibleCreature(this);
	if (topCreature && (!canPushCreatures() || !topCreature->isPushable())) {
		return false;
	}

	return true;
}

void Monster::death(Creature*)
{
	setAttackedCreature(nullptr);

	clearTargetList();
	onIdleStatus();
}

Item* Monster::getCorpse(Creature* lastHitCreature, Creature* mostDamageCreature)
{
	Item* corpse = Creature::getCorpse(lastHitCreature, mostDamageCreature);
	if (corpse) {
		if (mostDamageCreature) {
			if (mostDamageCreature->getPlayer()) {
				corpse->setCorpseOwner(mostDamageCreature->getID());
			} else {
				const Creature* mostDamageCreatureMaster = mostDamageCreature->getMaster();
				if (mostDamageCreatureMaster && mostDamageCreatureMaster->getPlayer()) {
					corpse->setCorpseOwner(mostDamageCreatureMaster->getID());
				}
			}
		}
	}
	return corpse;
}

bool Monster::isInSpawnRange(const Position& pos) const
{
	if (!spawn) {
		return true;
	}

	if (spawn->getRadius() == 0) {
		return true;
	}

	if (!Spawns::isInZone(masterPos, spawn->getRadius(), pos)) {
		return false;
	}

	if (Position::getDistanceZ(pos, masterPos) >= 2) { // 2 floor distance to despawn
		return false;
	}

	return true;
}

bool Monster::getCombatValues(int32_t& min, int32_t& max)
{
	if (minCombatValue == 0 && maxCombatValue == 0) {
		return false;
	}

	min = minCombatValue;
	max = maxCombatValue;
	return true;
}

void Monster::doAttackSpells()
{
	for (const spellBlock_t& spellBlock : mType->info.attackSpells) {
		if (spellBlock.isMelee) {
			continue;
		}

		if (!(rand() % spellBlock.delay) && (isSummon() || !isFleeing() || random(1, 3) == 1)) {
			if (spellBlock.updateLook) {
				updateLookDirection();

				if (!attackedCreature) {
					// cannot use this spell since we have no target
					continue;
				}
			}

			if (spellBlock.range != 0 && attackedCreature) {
				const Position& myPos = getPosition();
				const Position& targetPos = attackedCreature->getPosition();
				const int32_t targetDistance = std::max<int32_t>(Position::getDistanceX(myPos, targetPos), Position::getDistanceY(myPos, targetPos));
				if (!g_game.canThrowObjectTo(myPos, targetPos, false) || targetDistance > static_cast<int32_t>(spellBlock.range)) {
					continue;
				}
			}

			minCombatValue = spellBlock.minCombatValue;
			maxCombatValue = spellBlock.maxCombatValue;

			if (attackedCreature) {
				spellBlock.spell->castSpell(this, attackedCreature);
			}
		}
	}
}

void Monster::doDefensiveSpells()
{
	for (const spellBlock_t& spellBlock : mType->info.defenseSpells) {
		if (!(rand() % spellBlock.delay) && (isSummon() || !isFleeing() || random(1, 3) == 1)) {
			if (spellBlock.updateLook) {
				updateLookDirection();
			}

			minCombatValue = spellBlock.minCombatValue;
			maxCombatValue = spellBlock.maxCombatValue;
			spellBlock.spell->castSpell(this, this);
		}
	}
}

void Monster::updateLookDirection()
{
	Direction newDir = DIRECTION_NONE;

	if (attackedCreature) {
		const Position& pos = getPosition();
		const Position& attackedCreaturePos = attackedCreature->getPosition();

		const int32_t offsetx = Position::getOffsetX(attackedCreaturePos, pos);
		int32_t offsetxr = Position::getOffsetX(pos, attackedCreaturePos);
		const int32_t offsety = Position::getOffsetY(attackedCreaturePos, pos);

		if (offsetx > -1) {
			offsetxr = offsetx;
		}

		int32_t offsetyr = Position::getOffsetY(pos, attackedCreaturePos);

		if (offsety > -1) {
			offsetyr = offsety;
		}

		int32_t value;
		if (offsetxr >= offsetyr) {
			value = 2 * (static_cast<uint32_t>(offsetx) >> 31) + 1;
		} else {
			value = 2 * (offsety >= 0);
		}

		newDir = static_cast<Direction>(value);
	}

	if (newDir != DIRECTION_NONE) {
		g_game.internalCreatureTurn(this, newDir);
	}
}

void Monster::dropLoot(Container* corpse, Creature*)
{
	if (corpse && lootDrop) {
		if (g_config.getBoolean(ConfigManager::MONSTERS_SPAWN_WITH_LOOT)) {
			for (int32_t slot = CONST_SLOT_FIRST; slot <= CONST_SLOT_LAST; slot++) {
				Item* inventoryItem = inventory[slot];
				if (!inventoryItem) {
					continue;
				}

				if (corpse->queryAdd(INDEX_WHEREEVER, *inventoryItem, inventoryItem->getItemCount(), 0) == RETURNVALUE_NOERROR) {
					corpse->internalAddThing(inventoryItem);
				} else {
					inventoryItem->decrementReferenceCounter();
				}

				// remove item from the inventory
				inventory[slot] = nullptr;
			}
		}

		g_events->eventMonsterOnDropLoot(this, corpse);
	}
}

void Monster::drainHealth(Creature* attacker, int32_t damage)
{
	Creature::drainHealth(attacker, damage);

	if (damage > 0 && attacker) {
		if (attackedCreature) {
			const Position& myPos = getPosition();
			const Position& targetPos = attackedCreature->getPosition();
			if (!Position::areInRange<1, 1>(myPos, targetPos) && canSeeCreature(attacker)) {
				isAttackPanicking = true;
			}
		}

		for (Creature* target : targetList) {
			if (isTarget(target)) {
				isAttackPanicking = true;
			}
		}

		if (isSummon() && master) {
			if (!canSee(master->getPosition())) {
				Direction dir;
				if (getRandomStep(getPosition(), dir)) {
					addWalkToDo(dir);
					startToDo();
				}
			}
		}
		else {
			addYieldToDo();
		}
	}

	if (isInvisible()) {
		removeCondition(CONDITION_INVISIBLE);
	}
}

void Monster::changeHealth(int32_t healthChange, bool sendHealthChange/* = true*/)
{
	//In case a player with ignore flag set attacks the monster
	setIdle(false);
	Creature::changeHealth(healthChange, sendHealthChange);
}

LightInfo Monster::getCreatureLight() const
{
	if (internalLight.level != 0) {
		return internalLight;
	}

	LightInfo light = Creature::getCreatureLight();
	for (int32_t slot = CONST_SLOT_FIRST; slot <= CONST_SLOT_LAST; slot++) {
		const Item* inventoryItem = inventory[slot];
		if (!inventoryItem) {
			continue;
		}

		const LightInfo itemLight = inventoryItem->getLightInfo();
		if (itemLight.level > light.level) {
			light = itemLight;
		}
	}

	return light;
}

bool Monster::challengeCreature(Creature* creature, bool force/* = false*/)
{
	if (isSummon()) {
		return false;
	}

	if (!mType->info.isChallengeable && !force) {
		return false;
	}

	return selectTarget(creature);
}

slots_t getItemSlotType(const ItemType& it)
{
	slots_t slot = CONST_SLOT_RIGHT;
	if (it.weaponType != WeaponType_t::WEAPON_SHIELD) {
		const int32_t slotPosition = it.slotPosition;

		if (slotPosition & SLOTP_HEAD) {
			slot = CONST_SLOT_HEAD;
		} else if (slotPosition & SLOTP_NECKLACE) {
			slot = CONST_SLOT_NECKLACE;
		} else if (slotPosition & SLOTP_ARMOR) {
			slot = CONST_SLOT_ARMOR;
		} else if (slotPosition & SLOTP_LEGS) {
			slot = CONST_SLOT_LEGS;
		} else if (slotPosition & SLOTP_FEET) {
			slot = CONST_SLOT_FEET;
		} else if (slotPosition & SLOTP_RING) {
			slot = CONST_SLOT_RING;
		} else if (slotPosition & SLOTP_AMMO) {
			slot = CONST_SLOT_AMMO;
		} else if (slotPosition & SLOTP_TWO_HAND || slotPosition & SLOTP_LEFT) {
			slot = CONST_SLOT_LEFT;
		}
	}

	return slot;
}
int32_t Monster::getArmor() const 
{
	int32_t armor = mType->info.armor;

	// inventory armor increase
	if (g_config.getBoolean(ConfigManager::MONSTERS_SPAWN_WITH_LOOT)) {
		for (int32_t slot = CONST_SLOT_FIRST; slot <= CONST_SLOT_LAST; slot++) {
			const Item* inventoryItem = inventory[slot];
			if (!inventoryItem) {
				continue;
			}

			if (slot == getItemSlotType(Item::items.getItemType(inventoryItem->getID()))) {
				armor += inventoryItem->getArmor();
			}
		}
	}

	if (g_config.getBoolean(ConfigManager::USE_CLASSIC_COMBAT_FORMULAS)) {
		if (armor > 1) {
			armor = rand() % (armor >> 1) + (armor >> 1);
		}
	}

	return armor;
}

int32_t Monster::getDefense() const
{
	int32_t totalDefense = mType->info.defense;

	if (g_config.getBoolean(ConfigManager::USE_CLASSIC_COMBAT_FORMULAS)) {
		fightMode_t newFightMode = FIGHTMODE_BALANCED;
		if (!attackedCreature && OTSYS_TIME() >= earliestMeleeAttack) {
			newFightMode = FIGHTMODE_DEFENSE;
		}

		if (newFightMode == FIGHTMODE_DEFENSE) {
			totalDefense += 8 * totalDefense / 10;
		} // monsters are never in full attack mode

		const int32_t formula = (5 * (currentSkill) + 50) * totalDefense;
		const int32_t rnd = rand() % 100;
		totalDefense = formula * ((rand() % 100 + rnd) / 2) / 10000;
	}

	return totalDefense;
}

bool Monster::canPushItems() const
{
	return mType->info.canPushItems;
}
