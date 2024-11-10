local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                          npcHandler:onThink()                        end

local voices = { {text = "Runes, wands, rods, health and mana fluids! Have a look!"} }
npcHandler:addModule(VoiceModule:new(voices))

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

keywordHandler:addKeyword({'name'}, StdModule.say, {npcHandler = npcHandler, text = "I'm Xodet, the owner of this shop."})

keywordHandler:addKeyword({'job'}, StdModule.say, {npcHandler = npcHandler, text = "I'm a sorcerer and trade with all kinds of magic items."})

keywordHandler:addKeyword({'sorcerer'}, StdModule.say, {npcHandler = npcHandler, text = "There is a sorcerer guild in Thais. Just go in the east of the town, it is easily to find."})
keywordHandler:addKeyword({'offer'}, StdModule.say, {npcHandler = npcHandler, text = "I'm selling life and mana fluids, runes, wands, rods and spellbooks."})
-- Adding keywords and their responses
keywordHandler:addKeyword({'spell runes'}, StdModule.say, {npcHandler = npcHandler, text = "I sell missile runes, explosive runes, field runes, wall runes, bomb runes, healing runes, convince creature runes, and chameleon runes."})
keywordHandler:addKeyword({'missile runes'}, StdModule.say, {npcHandler = npcHandler, text = "I can offer you light magic missile runes, heavy magic missile runes, and sudden death runes."})
keywordHandler:addKeyword({'explosive runes'}, StdModule.say, {npcHandler = npcHandler, text = "I can offer you fireball runes, great fireball runes, and explosion runes."})
keywordHandler:addKeyword({'field runes'}, StdModule.say, {npcHandler = npcHandler, text = "I can offer you fire field runes, energy field runes, poison field runes, and destroy field runes."})
keywordHandler:addKeyword({'wall runes'}, StdModule.say, {npcHandler = npcHandler, text = "I can offer you fire wall runes, energy wall runes, and poison wall runes."})
keywordHandler:addKeyword({'bomb runes'}, StdModule.say, {npcHandler = npcHandler, text = "I can offer you fire bomb, energy bomb or poison bomb runes."})
keywordHandler:addKeyword({'healing runes'}, StdModule.say, {npcHandler = npcHandler, text = "I can offer you antidote runes, intense healing runes, and ultimate healing runes."})
keywordHandler:addKeyword({'runes'}, StdModule.say, {npcHandler = npcHandler, text = "I sell blank runes and spell runes."})


shopModule:addBuyableItem({'spellbook'}, 2175, 150, 'spellbook')
shopModule:addBuyableItem({'magic lightwand'}, 2162, 400, 'magic lightwand')

shopModule:addBuyableItem({'spellbook'}, 2175, 150, 'spellbook')
shopModule:addBuyableItem({'magic lightwand'}, 2163, 400, 'magic lightwand')

shopModule:addBuyableItem({'mana fluid', 'manafluid'}, 2006, 50, 7, 'mana fluid')
shopModule:addBuyableItem({'life fluid', 'lifefluid'}, 2006, 50, 2, 'life fluid')

shopModule:addBuyableItem({'animate dead'}, 2316, 375, 1, 'animate dead rune')
shopModule:addBuyableItem({'blank rune'}, 2260, 10, 1, 'blank rune')
shopModule:addBuyableItem({'desintegrate'}, 2310, 26, 1, 'desintegrate rune')
shopModule:addBuyableItem({'energy bomb'}, 2262, 203, 1, 'energy bomb rune')
shopModule:addBuyableItem({'great fireball rune'}, 2304, 180, 1, 'great fireball rune')
shopModule:addBuyableItem({'fireball rune'}, 2302, 95, 1, 'fireball rune')
shopModule:addBuyableItem({'magic wall'}, 2293, 116, 1, 'magic wall rune')
shopModule:addBuyableItem({'paralyze'}, 2278, 700, 1, 'paralyze rune')
shopModule:addBuyableItem({'poison bomb'}, 2286, 85, 1, 'poison bomb rune')
shopModule:addBuyableItem({'soulfire'}, 2308, 46, 1, 'soulfire rune')
shopModule:addBuyableItem({'wild growth'}, 2269, 160, 1, 'wild growth rune')

shopModule:addSellableItem({'vial', 'flask'}, 2006, 5, 'empty vial', 0)

shopModule:addBuyableItem({'antidote'}, 2266, 65, 1, 'antidote rune')
shopModule:addBuyableItem({'chameleon'}, 2291, 210, 1, 'chameleon rune')
shopModule:addBuyableItem({'convince creature'}, 2290, 80, 1, 'convince creature rune')
shopModule:addBuyableItem({'destroy field'}, 2261, 45, 1, 'destroy field rune')
shopModule:addBuyableItem({'energy field'}, 2277, 115, 1, 'energy field rune')
shopModule:addBuyableItem({'energy wall'}, 2279, 340, 4, 'energy wall rune')
shopModule:addBuyableItem({'explosion'}, 2313, 250, 1, 'explosion rune')
shopModule:addBuyableItem({'fire bomb'}, 2305, 235, 1, 'fire bomb rune')
shopModule:addBuyableItem({'fire field'}, 2301, 85, 1, 'fire field rune')
shopModule:addBuyableItem({'fire wall'}, 2303, 245, 1, 'fire wall rune')
shopModule:addBuyableItem({'heavy magic missile'}, 2311, 125, 1, 'heavy magic missile rune')
shopModule:addBuyableItem({'intense healing'}, 2265, 95, 1, 'intense healing rune')
shopModule:addBuyableItem({'light magic missile'}, 2287, 40, 1, 'light magic missile rune')
shopModule:addBuyableItem({'poison field'}, 2285, 65, 1, 'poison field rune')
shopModule:addBuyableItem({'poison wall'}, 2289, 210, 1, 'poison wall rune')
shopModule:addBuyableItem({'envenom'}, 2292, 125, 1, 'envenom rune')
shopModule:addBuyableItem({'sudden death'}, 2268, 325, 1, 'sudden death rune')

shopModule:addBuyableItem({'ultimate healing'}, 2273, 175, 1, 'ultimate healing rune')
--wand and rod
shopModule:addBuyableItem({'wand of vortex'}, 2190, 500, 1, 'wand of vortex')
shopModule:addBuyableItem({'snakebite rod'}, 2182, 500, 1, 'snakebite rod')
shopModule:addBuyableItem({'moonlight rod'}, 2186, 1000, 1, 'moonlight rod')
shopModule:addBuyableItem({'wand of dragonbreath'}, 2191, 1000, 1, 'wand of dragonbreath')
shopModule:addBuyableItem({'volcanic rod'}, 2185, 5000, 1, 'volcanic rod')
shopModule:addBuyableItem({'wand of plague'}, 2188, 5000, 1, 'wand of plague')
shopModule:addBuyableItem({'quagmire rod'}, 2181, 0, 1, 'quagmire rod') -- Assuming this is free or another price
shopModule:addBuyableItem({'wand of cosmic energy'}, 2189, 10000, 1, 'wand of cosmic energy')

local capacityCheck = true  -- Set to 'false' to disable capacity check



function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)
	
	  -- Define the rune data
    local runes = {
    {name = 'antidote', id = 2266, count = 1, price = 65},
    {name = 'chameleon', id = 2291, count = 1, price = 210},
    {name = 'convince creature', id = 2290, count = 1, price = 80},
    {name = 'destroy field', id = 2261, count = 3, price = 45},
    {name = 'energy field', id = 2277, count = 3, price = 115},
    {name = 'energy wall', id = 2279, count = 4, price = 340},
    {name = 'explosion', id = 2313, count = 3, price = 250},
    {name = 'fire bomb', id = 2305, count = 2, price = 235},
    {name = 'fire field', id = 2301, count = 3, price = 85},
    {name = 'fire wall', id = 2303, count = 4, price = 245},
    {name = 'heavy magic missile', id = 2311, count = 5, price = 125},
    {name = 'intense healing', id = 2265, count = 1, price = 95},
    {name = 'light magic missile', id = 2287, count = 5, price = 40},
    {name = 'poison field', id = 2285, count = 3, price = 65},
    {name = 'poison wall', id = 2289, count = 4, price = 210},
    {name = 'stalagmite', id = 2292, count = 1, price = 125},
    {name = 'sudden death', id = 2268, count = 1, price = 325},
    {name = 'ultimate healing', id = 2273, count = 1, price = 175},
    -- Additional runes
    {name = 'animate dead', id = 2316, count = 1, price = 375},
    {name = 'blank rune', id = 2260, count = 1, price = 10},
    {name = 'desintegrate', id = 2310, count = 1, price = 26},
    {name = 'energy bomb', id = 2262, count = 1, price = 203},
    {name = 'great fireball rune', id = 2304, count = 2, price = 180},
    {name = 'fireball rune', id = 2302, count = 2, price = 95},
    {name = 'magic wall', id = 2293, count = 1, price = 116},
    {name = 'paralyze', id = 2278, count = 1, price = 700},
    {name = 'poison bomb', id = 2286, count = 1, price = 85},
    {name = 'soulfire', id = 2308, count = 1, price = 46},
    {name = 'wild growth', id = 2269, count = 1, price = 160},
	{name = 'mana fluid', id = 2006, count = 10, price = 55}
}





    -- Check for backpack requests
    for _, rune in ipairs(runes) do
        -- Check if the message contains 'backpack of <rune name>' or 'bp <rune name>'
        if msgcontains(msg, 'backpack of ' .. rune.name) or msgcontains(msg, 'bp of ' .. rune.name) or msgcontains(msg, 'bp ' .. rune.name) or msgcontains(msg, 'backpack ' .. rune.name) then
            -- Calculate the price for a backpack with 20 of the requested rune
            local backpackPrice = 20 + rune.price * 20 -- 20 gold for the backpack + rune price * 20 for the 20 runes
            
            -- Special check for mana fluid
            if rune.name == 'mana fluid' then
                if player:getMoney() >= backpackPrice then
                    -- Ask the player if they want to buy the backpack
                    npcHandler:say('Do you want to buy a backpack of ' .. rune.name .. ' for ' .. backpackPrice .. ' gold?', cid)
                    npcHandler.topic[cid] = {rune = rune, price = backpackPrice}  -- Store rune and price for later use
                else
                    npcHandler:say('You don\'t have enough gold for a backpack of ' .. rune.name .. ' (' .. backpackPrice .. ' gold).', cid)
                end
            else
                -- Check if the player has enough money
                if player:getMoney() >= backpackPrice then
                    -- Ask the player if they want to buy the backpack
                    npcHandler:say('Do you want to buy a backpack of ' .. rune.name .. ' runes for ' .. backpackPrice .. ' gold?', cid)
                    npcHandler.topic[cid] = {rune = rune, price = backpackPrice}  -- Store rune and price for later use
                else
                    npcHandler:say('You don\'t have enough gold for a backpack of ' .. rune.name .. ' runes (' .. backpackPrice .. ' gold).', cid)
                end
            end
            return true
        end
    end

    -- Handling player's response
    if msgcontains(msg, 'yes') and npcHandler.topic[cid] then
        local rune = npcHandler.topic[cid].rune
        local price = npcHandler.topic[cid].price
        
        -- Check for capacity if enabled
        if capacityCheck then
            local backpack = player:addItem(1988, 1)  -- Add 1 backpack (ID 1988)
            local totalWeight = 0

            for i = 1, 20 do  -- Calculate the weight of the 20 runes
                totalWeight = totalWeight + ItemType(rune.id):getWeight()
            end

            -- Check if the player has enough capacity
            if player:getFreeCapacity() >= totalWeight then
                -- Proceed with the sale
                player:removeMoney(price)
                for i = 1, 20 do  -- Fill the backpack with 20 of the requested rune
                    backpack:addItem(rune.id, rune.count)
                end
				if rune.name == 'mana fluid' then
				selfSay('Here is your backpack of ' .. rune.name .. '.', cid)
				else
				selfSay('Here is your backpack of ' .. rune.name .. ' runes.', cid)
				end
				
                
            else
                -- Inform the player they don't have enough capacity
                selfSay('You don\'t have enough capacity to carry a backpack of ' .. rune.name .. ' runes.', cid)
            end
        else
            -- Proceed without capacity check
            local backpack = player:addItem(1988, 1)  -- Add 1 backpack (ID 1988)
            for i = 1, 20 do  -- Fill the backpack with 20 of the requested rune
                backpack:addItem(rune.id, 1)
            end
            player:removeMoney(price)
            selfSay('Here is your backpack of ' .. rune.name .. ' runes.', cid)
        end

        npcHandler.topic[cid] = nil  -- Clear the topic
        return true
    elseif msgcontains(msg, 'no') and npcHandler.topic[cid] then
        selfSay('Alright, maybe next time.', cid)
        npcHandler.topic[cid] = nil  -- Clear the topic
        return true
    end
	

	
	
	local vocationId = player:getVocation():getId()
	local items = {
		[1] = 2190,
		[2] = 2182,
		[5] = 2190,
		[6] = 2182
	}

	if msgcontains(msg, 'first wand') or msgcontains(msg, 'first rod') or msgcontains(msg, 'wand of vortex') or msgcontains(msg, 'snakebite rod') then
		if table.contains({1, 2, 5, 6}, vocationId) then
			if player:getStorageValue(PlayerStorageKeys.firstRod) == -1 then
				selfSay('So you ask me for a ' .. ItemType(items[vocationId]):getName() .. ' to begin your adventure?', cid)
				npcHandler.topic[cid] = 1
			else
				selfSay('What? I have already gave you one ' .. ItemType(items[vocationId]):getName() .. '!', cid)
			end
		else
			selfSay('Sorry, you aren\'t a druid either a sorcerer.', cid)
		end
	elseif msgcontains(msg, 'yes') then
		if npcHandler.topic[cid] == 1 then
			player:addItem(items[vocationId], 1)
			selfSay('Here you are young adept, take care yourself.', cid)
			player:setStorageValue(PlayerStorageKeys.firstRod, 1)
		end
		npcHandler.topic[cid] = 0
	elseif msgcontains(msg, 'no') and npcHandler.topic[cid] == 1 then
		selfSay('Ok then.', cid)
		npcHandler.topic[cid] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
