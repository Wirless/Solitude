local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

function onGetFormulaValues(player, level, magicLevel)
	return player:computeHealing(120, 40, true)
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell(SPELL_INSTANT)

function spell.onCastSpell(creature, variant)
	local target = Creature(variant.number)
	if not target then
		return false
	end

	local fromPos = creature:getPosition()
	local toPos = target:getPosition()
	local positionDifference = {
		x = math.abs(fromPos.x - toPos.x),
		y = math.abs(fromPos.y - toPos.y),
		z = math.abs(fromPos.z - toPos.z)
	}

	-- Check if the target is within the maximum allowed range
	if positionDifference.x > 7 or positionDifference.y > 5 then
		creature:sendCancelMessage(RETURNVALUE_DESTINATIONOUTOFREACH)
		return false
	end
	
    local casterIsTarget = target == creature
    local magicEffect = casterIsTarget and CONST_ME_MAGIC_BLUE or CONST_ME_MAGIC_GREEN

    if combat:execute(creature, variant) then
        creature:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        if not casterIsTarget then
            target:getPosition():sendMagicEffect(magicEffect)
        end
        return true
    end

    return false
end

spell:mana(70)
spell:level(18)
spell:isPremium(true)
spell:isAggressive(false)
spell:hasPlayerNameParam(true)
spell:hasParams(true)
spell:needTarget(true)
spell:name("Heal Friend")
spell:vocation("Druid", "Elder Druid")
spell:words("ex,ura, sio")
spell:register()
