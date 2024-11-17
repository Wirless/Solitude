local talkaction = TalkAction("!lootbag")

function talkaction.onSay(player, words, param)
    -- Get item in the player's left or right slot
    local itemLeft = player:getSlotItem(CONST_SLOT_LEFT)
    local itemRight = player:getSlotItem(CONST_SLOT_RIGHT)

    -- Check if either left or right slot has item 1987
    local item = itemLeft and itemLeft:getId() == 1987 and itemLeft or (itemRight and itemRight:getId() == 1987 and itemRight)
	print(item)
    -- If the player doesn't have the item in either slot, show a message
    if not item then
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "You need to have item 1987 in either the left or right slot to use this command.")
        return
    end

    -- Get the item description
    local description = item:getDescription():lower()  -- Convert description to lowercase
    local playerName = player:getName()  -- Get the player's name in lowercase

    -- Pattern to match "It weighs X.XX oz."
    local weightPattern = "it weighs %d+%.%d%d oz%."

    -- Check if description matches the weight pattern
    if string.find(description, weightPattern) then
        -- Find the part of the description after the weight pattern
        local postWeightText = description:match(weightPattern .. "(.*)"):gsub("^%s*(.-)%s*$", "%1")  -- Trim whitespace

        -- If there's no text after "oz.", add the player's name in the description
        if postWeightText == "" then
            -- Update the description with the player's name
            local newDescription = playerName
            item:setAttribute("description", newDescription)
            player:sendTextMessage(MESSAGE_STATUS_WARNING, "You are now protecting this bag.")
        elseif postWeightText == playerName then
            -- If the name matches the description, allow the item move (e.g., for looting or another action)
            player:sendTextMessage(MESSAGE_STATUS_INFO, "You are already a owner of this lootbag.")
        else
            -- If the name does not match the description, show a warning
            player:sendTextMessage(MESSAGE_STATUS_WARNING, "You cannot loot this item because the description does not match your name.")
        end
    else
        -- If the description doesn't match the pattern, show a warning
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "The item description doesn't have a valid weight pattern.")
    end
end

talkaction:register()
