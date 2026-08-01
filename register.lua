--PLAYER KILLED BY PLAYER
local deaths = {
    function(player, punchername, itemdesc)
        return punchername .. "'s " .. itemdesc .. " has slain " .. player .. "."
    end,
    function(player, punchername, itemdesc)
        return player .. " has been slain by " .. punchername .. " using " .. itemdesc .. "."
    end,
    function(player, punchername, itemdesc)
        return player .. " has been murdered by " .. punchername .. " with " .. itemdesc .. "."
    end,
}

for _, func in ipairs(deaths) do
    announce_deaths.register_player_punch_death(func)
end

--PLAYER KILLED BY OBJECT
local deaths = {
    function(player, objectname)
        return player .. " has been killed by " .. objectname .. "."
    end,
    function(player, objectname)
        return player .. " has been slain by " .. objectname .. "."
    end,
    function(player, objectname)
        return player .. " has been murdered by " .. objectname .. "."
    end,
}

for _, func in ipairs(deaths) do
    announce_deaths.register_object_punch_death(func)
end
--PLAYER KILLED BY FALL DAMAGE
local deaths = {
    function(player)
        return player .. " has fallen to their death."
    end,
    --by LadyK
    function(player)
        return player .. " has successfuly discovered the floor was right where they left it."
    end,
    --by LadyK
    function(player)
        return "The fall didn't kill " .. player .. ", but the sudden stop at the end did."
    end,
    --by momhd
    function(player)
        return player .. " has realized they were not in a beacon's radius."
    end
}

for _, func in ipairs(deaths) do
    announce_deaths.register_fall_death(func)
end

--PLAYER KILLED BY NODE DAMAGE
local deaths = {
    function(player, nodename)
        return player .. " has been killed by a " .. nodename .. "."
    end,
}

for _, func in ipairs(deaths) do
    announce_deaths.register_node_death(func)
end

--PLAYER KILLED BY DROWNING
local deaths = {
    function(player, nodename)
        return player .. " has drowned in a " .. nodename .. "."
    end,
    function(player, nodename)
        return player .. " has been drowned in a " .. nodename .. "."
    end,
    function(player, nodename)
        return player .. " has been submerged in a " .. nodename .. " for too long."
    end,
}

for _, func in ipairs(deaths) do
    announce_deaths.register_drown_death(func)
end

--PLAYER ATTACKING WITH ITEMS(CUSTOM)
local punchmessages = {
    [1] = function(player, punchername)
        return punchername .. "has punched " .. player .. " one too many times."
    end,
    [2] = function(player, punchername, itemdesc)
        return player .. " has been beat to death by " .. punchername .. "."
    end,
    [3] = function(player, punchername, itemdesc)
        return player .. " has been murdered by " .. punchername .. "."
    end,
}

function announce_deaths.randompunchmessage(player, punchername, itemdesc)
    return punchmessages[math.random(#punchmessages)](player, punchername, itemdesc)
end

announce_deaths.register_custom_item_punch_death("", announce_deaths.randompunchmessage)

--NODE DAMAGE(CUSTOM)
--burn messages
local burnmessages = {
    [1] = function(player)
        return player .. " has been burnt to a crisp."
    end,
    [2] = function(player)
        return player .. " has been incinerated."
    end,
    [3] = function(player)
        return player .. " has been reduced to ashes."
    end,
    [4] = function(player)
        return player .. " has been roasted well-done."
    end,
    [5] = function(player)
        return player .. " has been charred beyond recognition."
    end,
}

function announce_deaths.randomburnedmessage(player)
    return burnmessages[math.random(#burnmessages)](player)
end
--node damage
--no optional dependency needed
if core.get_modpath("fire") then
    announce_deaths.register_custom_node_death("fire:basic_flame", announce_deaths.randomburnedmessage)
    announce_deaths.register_custom_node_death("fire:permanent_flame", announce_deaths.randomburnedmessage)
end
if core.get_modpath("default") then
    announce_deaths.register_custom_node_death("default:lava_source", announce_deaths.randomburnedmessage)
    announce_deaths.register_custom_node_death("default:lava_flowing", announce_deaths.randomburnedmessage)
end

--CUSTOM DROWNING DEATHS
local drownmessages = {
    [1] = function(player)
        return player .. " has drowned in a pool of water."
    end,
    [2] = function(player)
        return player .. " has been submerged in water for too long."
    end,
    [3] = function(player)
        return player .. " has learned that they can't breathe underwater."
    end,
    [4] = function(player)
        return player .. " has realized their lungs do not need water."
    end,
}

function announce_deaths.randomdrownmessage(player)
    return drownmessages[math.random(#drownmessages)](player)
end

if core.get_modpath("default") then
    announce_deaths.register_custom_drown_death("default:water_source", announce_deaths.randomdrownmessage)
    announce_deaths.register_custom_drown_death("default:water_flowing", announce_deaths.randomdrownmessage)
end