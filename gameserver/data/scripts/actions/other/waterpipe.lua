local action = Action()

function action.onUse(player, item, fromPosition, target, toPosition)
	if math.random(3) == 1 then
		item:getPosition():sendMagicEffect(CONST_ME_POFF)
	else
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end
	return true
end

action:id(2093)
action:id(2099)
action:register()
