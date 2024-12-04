local trainingBarrels = Action()

-- Table for cooldown tracking
local playerCooldowns = {}

-- Debug mode (set to true to enable debugging, false to disable it)
local debugMode = true

-- Reward logic
function trainingBarrels.onUse(player, item, fromPosition, target, toPosition)
    local vocation = player:getVocation()
    local playerId = player:getId()
    local now = os.time()
    local aid = item:getActionId()

    -- Initialize player cooldown if not present
    if not playerCooldowns[playerId] then
        playerCooldowns[playerId] = { lastClaim = {}, blankRuneCooldown = 0 }
    end

    -- Debug: Print player information
    if debugMode then
        print("Player ID: " .. playerId)
        print("Player Vocation: " .. vocation)
        print("Current Action ID: " .. aid)
        print("Current Time: " .. now)
    end

    -- Check for cooldown
    if aid == 406 or aid == 407 or aid == 408 then
        local lastClaim = playerCooldowns[playerId].lastClaim[aid] or 0
        if now - lastClaim < 86400 then -- 24 hours in seconds
            player:sendCancelMessage("You can only claim this reward once every 24 hours.")
            return true
        end
    end

    -- Handle specific barrel rewards
    if aid == 406 then
        -- Barrel for knights
        if debugMode then
            print("Checking vocation for barrel 406: Knight check")
        end
        if vocation == 4 or vocation == 8 or debugMode then -- Bypass check if debugMode is true
            player:addItem(2382, 1) -- Sword
            player:addItem(2403, 1) -- Shield
            player:addItem(2405, 1) -- Helmet
            player:sendTextMessage(MESSAGE_INFO_DESCR, "You received basic training items.")
            if debugMode then
                print("Knight items added.")
            end
        else
            player:sendCancelMessage("This barrel is for knights only.")
        end

    elseif aid == 407 then
        -- Barrel for paladins
        if debugMode then
            print("Checking vocation for barrel 407: Paladin check")
        end
        if vocation == 3 or vocation == 7 or debugMode then -- Bypass check if debugMode is true
            local stonesToGive = player:getLevel() * 20 -- Calculate stones based on player level

            -- Debug prints
            print("Player level: " .. player:getLevel())
            print("Stones to give: " .. stonesToGive)

            player:addItem(1294, stonesToGive) -- Add stones directly to the player's inventory
            player:sendTextMessage(MESSAGE_INFO_DESCR, "You received " .. stonesToGive .. " small stones.")
            if debugMode then
                print("Paladin stones added.")
            end
        else
            player:sendCancelMessage("This barrel is for paladins only.")
        end

    elseif aid == 408 then
        -- Barrel for mages
        if debugMode then
            print("Checking vocation for barrel 408: Mage check")
        end
        if vocation == 1 or vocation == 2 or vocation == 5 or vocation == 6 or debugMode then -- Bypass check if debugMode is true
            player:addItem(2789, 100) -- Brown mushrooms
            player:sendTextMessage(MESSAGE_INFO_DESCR, "You received 100 brown mushrooms.")
            if now - playerCooldowns[playerId].blankRuneCooldown >= 300 then -- 5 minutes in seconds
                player:addItem(2260, 1) -- Blank rune
                playerCooldowns[playerId].blankRuneCooldown = now
                player:sendTextMessage(MESSAGE_INFO_DESCR, "You received a blank rune.")
                if debugMode then
                    print("Blank rune given.")
                end
            else
                player:sendCancelMessage("You can only take one blank rune every 5 minutes.")
            end
        else
            player:sendCancelMessage("This barrel is for mages only.")
        end
    end

    -- Update cooldown for the specific aid
    playerCooldowns[playerId].lastClaim[aid] = now

    return true
end

-- Register barrels with action IDs
trainingBarrels:aid(406)
trainingBarrels:aid(407)
trainingBarrels:aid(408)

trainingBarrels:register()
