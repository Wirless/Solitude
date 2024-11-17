function Player:onLook(thing, position, distance)
	local description = ""
	if hasEventCallback(EVENT_CALLBACK_ONLOOK) then
		description = EventCallback(EVENT_CALLBACK_ONLOOK, self, thing, position, distance, description)
	end
	if thing:isItem() and (thing:getActionId() == 1224 or thing:getActionId() == 1040) then
		self:sendTextMessage(MESSAGE_INFO_DESCR, "You see a loose board.")
		return
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onLookInBattleList(creature, distance)
	local description = ""
	if hasEventCallback(EVENT_CALLBACK_ONLOOKINBATTLELIST) then
		description = EventCallback(EVENT_CALLBACK_ONLOOKINBATTLELIST, self, creature, distance, description)
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onLookInTrade(partner, item, distance)
	local description = "You see " .. item:getDescription(distance)
	if hasEventCallback(EVENT_CALLBACK_ONLOOKINTRADE) then
		description = EventCallback(EVENT_CALLBACK_ONLOOKINTRADE, self, partner, item, distance, description)
	end
	self:sendTextMessage(MESSAGE_INFO_DESCR, description)
end

function Player:onUseItem(item)
	if self:getGroup():getAccess() then	
		if onUseRope(self, item, item:getPosition(), item, item:getPosition()) or onUsePick(self, item, fromPosition, item, item:getPosition()) or
		onUseShovel(self, item, item:getPosition(), item, item:getPosition()) or onUseScythe(self, item, fromPosition, item, item:getPosition()) or
		onUseMachete(self, item, item:getPosition(), item, item:getPosition()) then
		return true
		end
	end
	
	if hasEventCallback(EVENT_CALLBACK_ONUSEITEM) then
		return EventCallback(EVENT_CALLBACK_ONUSEITEM, self, item)
	end
	return false
end

function Player:onMoveItem(item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	-- Do not allow moving of map quest objects
	if item:getActionId() >= 1000 and item:getActionId() <= 2000 then
		return RETURNVALUE_NOTMOVEABLE
	end
	
	-- Convert permanent candelabrum into expiring candelabrum
	if item:getId() == 2057 then
		item:transform(2042)
	end
	
	
	
	
	if item:getId() == 1987 then
		-- Get item description
		local description = item:getDescription():lower()  -- Convert to lowercase for consistency
		local playerName = self:getName():lower()  -- Get player's name in lowercase
		
		-- Pattern to match "It weighs X.XX oz." followed by either nothing or additional text
		local weightPattern = "it weighs %d+%.%d%d oz%."

		-- Check if description matches the weight pattern
		if string.find(description, weightPattern) then
			local postWeightText = description:match(weightPattern .. "(.*)"):gsub("^%s*(.-)%s*$", "%1")  -- Trim whitespace

			-- If there's no text after "oz.", allow anyone to move it
			if postWeightText == "" then
				return true
			elseif postWeightText == playerName then
				-- If there is text after "oz." and it matches the player's name, allow the move
				
			
			-- Define restricted item types (assuming these are predefined constants in your system)
local restrictedItemTypes = {
    ITEM_TYPE_DEPOT,
    ITEM_TYPE_MAILBOX,
    ITEM_TYPE_TRASHHOLDER,
    ITEM_TYPE_CONTAINER,
    ITEM_TYPE_DOOR
}

-- Check if there are movable items on the target tile
local targetTile = Tile(toPosition)
if targetTile then
    for _, tileItem in ipairs(targetTile:getItems()) do
        local itemType = ItemType(tileItem:getId())
        
        -- Check if the item is movable
        if itemType:isMovable() then
            -- If there's a movable item on the target tile, prevent placing the item
            self:sendTextMessage(MESSAGE_STATUS_WARNING, "You cannot place this item on top of other items.")
            return RETURNVALUE_NOTMOVEABLE
        end
        
        -- Check if the item on the tile is one of the restricted types
        local itemTypeID = itemType:getType() -- Get the type of the current item
        
        -- Compare the itemTypeID with the restricted item types
        for _, restrictedItemType in ipairs(restrictedItemTypes) do
            if itemTypeID == restrictedItemType then
                -- If the item type matches a restricted type, prevent placement
                self:sendTextMessage(MESSAGE_STATUS_WARNING, "You cannot place this item on top of a " .. itemType:getName() .. ".")
                return RETURNVALUE_NOTMOVEABLE
            end
        end
    end
end
				return true
			else
				-- Text after "oz." does not match the player's name, prevent moving the item
				self:sendTextMessage(MESSAGE_STATUS_WARNING, "This is not your lootbag.")

				-- Get the tile where the bag is located
				local tile = Tile(item:getPosition())
				if tile then
					-- Loop through all items on the tile
					for _, tileItem in ipairs(tile:getItems()) do
						if tileItem:getId() == 1987 then
							-- Check if this bag belongs to the player
							local tileItemDescription = tileItem:getDescription():lower()
							local postTileItemWeightText = tileItemDescription:match(weightPattern .. "(.*)"):gsub("^%s*(.-)%s*$", "%1")

							-- If the bag belongs to the player, move it and prevent other bags from moving
							if postTileItemWeightText == playerName then
								tileItem:moveTo(toPosition)  -- Move the player's own bag
								return RETURNVALUE_NOTMOVEABLE  -- Prevent moving the other bag
							end
						elseif ItemType(tileItem:getId()):isMovable() then
							-- Move any movable items found on the tile, provided their uniqueId and actionId are both less than 1000
							tileItem:moveTo(toPosition)
						end
					end
				end
				
				-- If no player-owned bag found, prevent moving the loot bag itself
				return RETURNVALUE_NOTMOVEABLE
			end
		else
			-- If the description does not match the weight format, prevent the move as a fallback
			self:sendTextMessage(MESSAGE_STATUS_WARNING, "Item description format is incorrect.")
			return RETURNVALUE_NOTMOVEABLE
		end
	end
	


	
	if toCylinder:isTile() and toCylinder:getGround() and toCylinder:getGround():getActionId() == actionIds.blockingTile then
		return RETURNVALUE_NOTENOUGHROOM
	end

	if hasEventCallback(EVENT_CALLBACK_ONMOVEITEM) then
		return EventCallback(EVENT_CALLBACK_ONMOVEITEM, self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	end
	return RETURNVALUE_NOERROR
end

function Player:onItemMoved(item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	if hasEventCallback(EVENT_CALLBACK_ONITEMMOVED) then
		EventCallback(EVENT_CALLBACK_ONITEMMOVED, self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	end

	-- Open trap
	if item:getId() == 2579 then
		item:transform(2578)
		if item then
			toCylinder:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	end
end

function Player:onMoveCreature(creature, fromPosition, toPosition)
	if hasEventCallback(EVENT_CALLBACK_ONMOVECREATURE) then
		return EventCallback(EVENT_CALLBACK_ONMOVECREATURE, self, creature, fromPosition, toPosition)
	end
	return true
end

function Player:onReportBug(message, position, category)
	if hasEventCallback(EVENT_CALLBACK_ONREPORTBUG) then
		return EventCallback(EVENT_CALLBACK_ONREPORTBUG, self, message, position, category)
	end
	return true
end

function Player:onTurn(direction)
	if hasEventCallback(EVENT_CALLBACK_ONTURN) then
		return EventCallback(EVENT_CALLBACK_ONTURN, self, direction)
	end
	return true
end

function Player:onTradeRequest(target, item)
	-- Check if the item is the specific loot bag with ID 1987
	if item:getId() == 1987 then
		-- Get the item description
		local description = item:getDescription():lower()  -- Convert to lowercase for consistency

		-- Pattern to match "It weighs X.XX oz." with optional text afterward
		local weightPattern = "it weighs %d+%.%d%d oz%."

		-- Check if description matches the weight pattern
		if string.find(description, weightPattern) then
			-- Extract any text after "oz."
			local postWeightText = description:match(weightPattern .. "(.*)"):gsub("^%s*(.-)%s*$", "%1")  -- Trim whitespace

			-- If there's any text after "oz.", it means the bag has an owner name, so deny the trade
			if postWeightText ~= "" then
				self:sendTextMessage(MESSAGE_STATUS_WARNING, "You cannot trade this lootbag as it has an owner.")
				return false
			end
		else
			-- If the description doesn't match the expected weight format, deny trade as a safeguard
			self:sendTextMessage(MESSAGE_STATUS_WARNING, "This item cannot be traded.")
			return false
		end
	end

	-- Default behavior: if there’s an event callback, run it
	if hasEventCallback(EVENT_CALLBACK_ONTRADEREQUEST) then
		return EventCallback(EVENT_CALLBACK_ONTRADEREQUEST, self, target, item)
	end

	-- Allow trade if none of the conditions above prevented it
	return true
end


function Player:onTradeAccept(target, item, targetItem)
	if hasEventCallback(EVENT_CALLBACK_ONTRADEACCEPT) then
		return EventCallback(EVENT_CALLBACK_ONTRADEACCEPT, self, target, item, targetItem)
	end
	return true
end

function Player:onTradeCompleted(target, item, targetItem, isSuccess)
	if hasEventCallback(EVENT_CALLBACK_ONTRADECOMPLETED) then
		EventCallback(EVENT_CALLBACK_ONTRADECOMPLETED, self, target, item, targetItem, isSuccess)
	end
end

local soulCondition = Condition(CONDITION_SOUL, CONDITIONID_DEFAULT)
soulCondition:setTicks(4 * 60 * 1000)
soulCondition:setParameter(CONDITION_PARAM_SOULGAIN, 1)

local function useStamina(player)
	local staminaMinutes = player:getStamina()
	if staminaMinutes == 0 then
		return
	end

	local playerId = player:getId()
	local currentTime = os.time()
	local timePassed = currentTime - nextUseStaminaTime[playerId]
	if timePassed <= 0 then
		return
	end

	if timePassed > 60 then
		if staminaMinutes > 2 then
			staminaMinutes = staminaMinutes - 2
		else
			staminaMinutes = 0
		end
		nextUseStaminaTime[playerId] = currentTime + 120
	else
		staminaMinutes = staminaMinutes - 1
		nextUseStaminaTime[playerId] = currentTime + 60
	end
	player:setStamina(staminaMinutes)
end

function Player:onGainExperience(source, exp, rawExp)
	if not source or source:isPlayer() then
		return exp
	end

	-- Soul regeneration
	local vocation = self:getVocation()
	if self:getSoul() < vocation:getMaxSoul() and exp >= self:getLevel() then
		soulCondition:setParameter(CONDITION_PARAM_SOULTICKS, vocation:getSoulGainTicks() * 1000)
		self:addCondition(soulCondition)
	end

	-- Apply experience stage multiplier
	exp = exp * Game.getExperienceStage(self:getLevel())

	-- Stamina modifier
	if configManager.getBoolean(configKeys.STAMINA_SYSTEM) then
		useStamina(self)

		local staminaMinutes = self:getStamina()
		if staminaMinutes > 2400 and self:isPremium() then
			exp = exp * 1.5
		elseif staminaMinutes <= 840 then
			exp = exp * 0.5
		end
	end

	return hasEventCallback(EVENT_CALLBACK_ONGAINEXPERIENCE) and EventCallback(EVENT_CALLBACK_ONGAINEXPERIENCE, self, source, exp, rawExp) or exp
end

function Player:onLoseExperience(exp)
	return hasEventCallback(EVENT_CALLBACK_ONLOSEEXPERIENCE) and EventCallback(EVENT_CALLBACK_ONLOSEEXPERIENCE, self, exp) or exp
end

function Player:onGainSkillTries(skill, tries)
	if APPLY_SKILL_MULTIPLIER == false then
		return hasEventCallback(EVENT_CALLBACK_ONGAINSKILLTRIES) and EventCallback(EVENT_CALLBACK_ONGAINSKILLTRIES, self, skill, tries) or tries
	end

	if skill == SKILL_MAGLEVEL then
		tries = tries * configManager.getNumber(configKeys.RATE_MAGIC)
		return hasEventCallback(EVENT_CALLBACK_ONGAINSKILLTRIES) and EventCallback(EVENT_CALLBACK_ONGAINSKILLTRIES, self, skill, tries) or tries
	end
	tries = tries * configManager.getNumber(configKeys.RATE_SKILL)
	return hasEventCallback(EVENT_CALLBACK_ONGAINSKILLTRIES) and EventCallback(EVENT_CALLBACK_ONGAINSKILLTRIES, self, skill, tries) or tries
end
