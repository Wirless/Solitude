local spell = Spell(SPELL_INSTANT)

spell:mana(200)
spell:level(21)
spell:soul(3)
spell:isAggressive(false)
spell:name("Desintegrate")
spell:vocation("Druid", "Elder Druid", "Paladin", "Royal Paladin", "Sorcerer", "Master Sorcerer")
spell:words("ad,ito, tera")

function spell.onCastSpell(creature, variant)
	return creature:conjureItem(200, 2260, 2310, 3)
end

spell:register()

local rune = Spell(SPELL_RUNE)

function rune.onCastSpell(creature, variant)
	local position = variant:getPosition()
	local tile = Tile(position)
	if tile then
		local items = tile:getItems()
		if items then
			for i, item in ipairs(items) do
				if item:getType():isMovable() and item:getUniqueId() > 65535 and item:getActionId() == 0 and not table.contains(corpseIds, item:getId()) then
					
					-- If the item is a loot bag (ID 1987), check if it has the caster's name in the description
					if item:getId() == 1987 then
						local description = item:getDescription():lower()
						local casterName = creature:getName():lower()
						
						-- Only remove if the description contains the caster's name
						if string.find(description, casterName) then
							item:remove()
						end
					else
						-- Remove other eligible items
						item:remove()
					end
				end

				
			
				if i == 500 then
					break
				end
			end
		end
	end

	position:sendMagicEffect(CONST_ME_POFF)
	return true
end

rune:runeMagicLevel(4)
rune:runeId(2310)
rune:charges(3)
rune:allowFarUse(false)
rune:range(1)
rune:checkFloor(true)
rune:isBlocking(true)
rune:cooldownSpellTime(false)
rune:isAggressive(true)
rune:register()
