local moveevent = MoveEvent()

function moveevent.onStepIn(creature, item, position, fromPosition)
	if creature:isPlayer() and creature:getPlayer():getStorageValue(4) == -1 and Game.isItemInPosition({x = 32243, y = 31892, z = 14},2016) then 
		Game.removeItemInPosition({x = 32243, y = 31892, z = 14}, 2016)
		Game.sendMagicEffect({x = 32243, y = 31892, z = 14}, 14)
		creature:getPlayer():setStorageValue(4,1)
		doRelocate(item:getPosition(),{x = 32261, y = 31849, z = 15})
		Game.sendMagicEffect({x = 32261, y = 31849, z = 15}, 14)
	else
		doRelocate(item:getPosition(),{x = 32249, y = 31892, z = 14})
		Game.sendMagicEffect({x = 32249, y = 31892, z = 14}, 1)
		doTargetCombatHealth(0, creature, COMBAT_FIREDAMAGE, -55, -55)
	end
end

moveevent:aid(3099)
moveevent:register()