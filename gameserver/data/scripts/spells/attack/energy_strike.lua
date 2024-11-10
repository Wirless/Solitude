local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_TELEPORT)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, true)

function onGetFormulaValues(player, level, magicLevel)
	return player:computeDamage(45, 10)
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell(SPELL_INSTANT)

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:mana(20)
spell:level(12)
spell:isPremium(true)
spell:isAggressive(true)
spell:isBlockingWalls(true)
spell:needDirection(true)
spell:cooldown(1000)
spell:name("Energy Strike")
spell:vocation("Sorcerer", "Master Sorcerer", "Druid", "Elder Druid")
spell:words("ex,ori, vis")
spell:register()