local talkaction = TalkAction("!share","/share")

function talkaction.onSay(player, words, param)
	local party = player:getParty()
	if not party then
		player:sendCancelMessage("You are not part of a party.")
		return false
	end
	
	if party:getLeader() ~= player then
		player:sendCancelMessage("You are not the leader of the party.")
		return false
	end
	
	if party:isSharedExperienceActive() then
			party:setSharedExperience(false)
	else
			party:setSharedExperience(true)
	end
		
	return false
end

talkaction:separator(" ")
talkaction:register()