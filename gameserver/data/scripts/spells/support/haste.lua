local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_GREEN)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local condition = Condition(CONDITION_HASTE)
condition:setParameter(CONDITION_PARAM_TICKS, 30000)
condition:setParameter(CONDITION_PARAM_SPEED, 30)
combat:addCondition(condition)

local spell = Spell(SPELL_INSTANT)

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:isSelfTarget(true)
spell:mana(60)
spell:level(14)
spell:isPremium(true)
spell:isAggressive(false)
spell:name("Haste")
spell:vocation("Sorcerer", "Master Sorcerer", "Druid", "Elder Druid", "Paladin", "Royal Paladin", "Knight", "Elite knight")
spell:words("ut,ani, hur")
spell:register()