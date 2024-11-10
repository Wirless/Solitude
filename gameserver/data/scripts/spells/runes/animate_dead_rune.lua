local spell = Spell(SPELL_INSTANT)

spell:mana(600)
spell:level(27)
spell:soul(4)
spell:isAggressive(false)
spell:name("Animate Dead")
spell:vocation("Sorcerer", "Master Sorcerer")
spell:words("ad,ana, mort")

function spell.onCastSpell(creature, variant)
	return creature:conjureItem(600, 2260, 2316, 1)
end

spell:register()

local rune = Spell(SPELL_RUNE)

function rune.onCastSpell(creature, variant)
	local position = variant:getPosition()
	local tile = Tile(position)
	if tile then
		local corpse = tile:getTopDownItem()
		if corpse then
			local itemType = corpse:getType()
			if itemType:isCorpse() and itemType:isMovable() and corpse:getActionId() == 0 then
				local monster = Game.createMonster("Skeleton", position)
				if monster then
					corpse:remove()
					creature:addSummon(monster)
					position:sendMagicEffect(CONST_ME_MAGIC_BLUE)
					return true
				end
			end
		end
	end

	creature:getPosition():sendMagicEffect(CONST_ME_POFF)
	creature:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
	return false
end

rune:runeMagicLevel(4)
rune:runeId(2316)
rune:charges(1)
rune:allowFarUse(true)
rune:blockWalls(true)
rune:checkFloor(true)
rune:isBlocking(true, true)
rune:isAggressive(false)
rune:register()
