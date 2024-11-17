local lootbag = Action()

function lootbag.onUse(player, item, fromPosition, target, toPosition)
	-- Check if the item is the specific loot bag with ID 1987
	if item:getId() == 1987 then
		-- Get the item description
		local description = item:getDescription():lower()  -- Convert to lowercase for case-insensitive matching
		local playerName = player:getName():lower()  -- Get player's name in lowercase
		
		-- Pattern to match "It weighs X.XX oz." with optional player name after
		local weightPattern = "it weighs %d+%.%d%d oz%."

		-- Check if description matches the weight pattern
		if string.find(description, weightPattern) then
			-- Extract any text after "oz."
			local postWeightText = description:match(weightPattern .. "(.*)"):gsub("^%s*(.-)%s*$", "%1")  -- Trim any whitespace

			-- If there's no text after "oz.", allow anyone to use the bag
			if postWeightText == "" then
				return false
			elseif postWeightText == playerName then
				-- If text after "oz." matches the player's name, allow use
				return false
			else
				-- Player is not the owner, deny access
				player:sendTextMessage(MESSAGE_STATUS_WARNING, "This is not your lootbag.")
				return true
			end
		else
			-- If the description does not match the expected weight format, deny access as a safeguard
			player:sendTextMessage(MESSAGE_STATUS_WARNING, "This lootbag cannot be used.")
			return false
		end
	end
	
	-- If item is not the lootbag, allow interaction
	return true
end

lootbag:id(1987)
lootbag:register()
