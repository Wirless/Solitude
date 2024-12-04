local moveevent = MoveEvent()

function moveevent.onStepIn(creature, item, position, fromPosition)
    -- Check if the creature is a monster
    if creature:isMonster() then
        -- Convert the creature's name to lowercase and check if it matches "magical butterfly"
        if string.lower(creature:getName()) == "magical butterfly" then
            creature:teleportTo(fromPosition, true)
        end
    end
end

moveevent:aid(405)
moveevent:register()
