local moveevent = MoveEvent()

function moveevent.onStepIn(creature, item, position, fromPosition)
	if creature:isPlayer() then 
		doRelocate(item:getPosition(),{x = 33217, y = 31814, z = 08})
		creature:getPlayer():setTown(Town("Edron"))
		Game.sendMagicEffect({x = 33217, y = 31814, z = 08}, 13)
	end
end

moveevent:aid(3106)
moveevent:register()

local moveevent = MoveEvent()

function moveevent.onAddItem(item, tileitem, position)
	doRelocate(item:getPosition(),{x = 33210, y = 31806, z = 08})
	Game.sendMagicEffect({x = 33210, y = 31806, z = 08}, 14)
end

moveevent:aid(3106)
moveevent:tileItem(true)
moveevent:register()