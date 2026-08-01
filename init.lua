announce_deaths = {}
--general death from a player punching another player with x item
local playerpunchfunctions = {}
--functions that will return a string as a death message only for certain items
local customitempunchfunctions = {}
--general death from an object, like a mob
local objectpunchfunctions = {}
--death from specific objects, like a mob
local customobjectpunchfunctions = {}
--general deaths from falling
local fallfunctions = {}
--general deaths from node damage
local nodefunctions = {}
--custom deaths from specific nodes, like lava
local customnodes = {}
--general drowning deaths
local drownfunctions = {}
--custom drowning deaths from specific nodes, like water
local customdrownnodes = {}
--custom deaths from specific reasons, like hunger or thirst
local customreasons = {}

--helper functions
local function get_random_index_in_table(table)
    local len = #table
    if len > 0 then
        local random_index = math.random(len)
        return random_index
    else
        return nil
    end
end

local function get_object_title(name)
    local parts = string.split(name, ":")
    local technicalname = parts[#parts]
    local namewithoutunderscore = string.gsub(technicalname, "_", " ")
    return namewithoutunderscore
end

--all in one big table
announce_deaths.deathmessages = {
    ["punch"] = function(player, reason)
        local puncher = reason.object or nil
        if puncher then
            if puncher:is_player() then
                local punchername = puncher:get_player_name()
                local wieldeditem = puncher:get_wielded_item()
                local wieldname = wieldeditem:get_name()
                if customitempunchfunctions[wieldname] then
                    return customitempunchfunctions[wieldname](player, punchername, wieldeditem)
                else
                    local itemdesc = core.registered_items[wieldname] and core.registered_items[wieldname].description or "Unknown Item"
                    return playerpunchfunctions[get_random_index_in_table(playerpunchfunctions)](player, punchername, itemdesc)
                end
            else
                local entity = puncher:get_luaentity()
                local objectname = entity and entity.name or "Unknown Being"              
                if customobjectpunchfunctions[objectname] then
                    local title = get_object_title(objectname)
                    return customobjectpunchfunctions[objectname](player, title)
                else
                    local title = get_object_title(objectname)
                    return objectpunchfunctions[get_random_index_in_table(objectpunchfunctions)](player, title)
                end
            end
        end
    end,

    ["fall"] = function(player, reason)
        return fallfunctions[get_random_index_in_table(fallfunctions)](player)
    end,

    ["node_damage"] = function(player, reason)
        local node = reason.node or nil
        if not customnodes[node] then
            local nodename = core.registered_nodes[node] and core.registered_nodes[node].description or "Unknown Node"
            return nodefunctions[get_random_index_in_table(nodefunctions)](player, nodename)
        else
            return customnodes[node](player, reason)
        end
    end,

    ["drown"] = function(player, reason)
        local node = reason.node
        if node and customdrownnodes[node] then
            return customdrownnodes[node](player, reason)
        else
            local nodename = core.registered_nodes[node] and core.registered_nodes[node].description or "Unknown Node"
            return drownfunctions[get_random_index_in_table(drownfunctions)](player, nodename)
        end
    end,

    ["set_hp"] = function(player, reason)
        local customreason = reason.custom_type or nil
        if customreasons[customreason] then
            return customreasons[customreason](player, reason)
        else
            return player .. " has evaporated"
        end
    end,
}


core.register_on_dieplayer(function(player, reason)
    local message
    local playername = player:get_player_name()
    local why = reason.type
    if why then
        message = announce_deaths.deathmessages[why] and announce_deaths.deathmessages[why](playername, reason)
    end
    if message then
        core.chat_send_all(message)
    end
end)


--function must return the string if it is a function.
function announce_deaths.register_player_punch_death(message)
    if type(message) == "string" then
        local text = message
        local func = function(player, puncher, itemdesc)
            return player .. text .. puncher .. " with " .. itemdesc
        end
        table.insert(playerpunchfunctions, func)
    elseif type(message) == "function" then
        table.insert(playerpunchfunctions, message)
    else
        error("Player punch function must be a string or a function")
    end
end

function announce_deaths.register_custom_item_punch_death(itemname, message)
    if type(message) == "string" then
        local text = message
        local func = function(player, puncher, itemdesc)
            return player .. text .. puncher .. " with " .. itemdesc
        end
        customitempunchfunctions[itemname] = func
    elseif type(message) == "function" then
        customitempunchfunctions[itemname] = message
    else
        error("Custom item punch function must be a string or a function")
    end
end

function announce_deaths.register_object_punch_death(message)
    if type(message) == "string" then
        local text = message
        local func = function(player, objectname)
            return player .. text .. objectname
        end
        table.insert(objectpunchfunctions, func)
    elseif type(message) == "function" then
        table.insert(objectpunchfunctions, message)
    else
        error("Object punch function must be a string or a function")
    end
end

function announce_deaths.register_custom_object_punch_death(objectname, message)
    if type(message) == "string" then
        local text = message
        local func = function(player, objectname)
            return player .. text .. objectname
        end
        customobjectpunchfunctions[objectname] = func
    elseif type(message) == "function" then
        customobjectpunchfunctions[objectname] = message
    else
        error("Custom object punch function must be a string or a function")
    end
end

function announce_deaths.register_fall_death(message)
    if type(message) == "string" then
        local text = message
        local func = function(player)
            return player .. text
        end
        table.insert(fallfunctions, func)
    elseif type(message) == "function" then
        table.insert(fallfunctions, message)
    else
        error("Fall function must be a string or a function")
    end
end

function announce_deaths.register_node_death(message)
    if type(message) == "string" then
        local text = message
        local func = function(player, nodename)
            return player .. text .. nodename
        end
        table.insert(nodefunctions, func)
    elseif type(message) == "function" then
        table.insert(nodefunctions, message)
    else
        error("Node function must be a string or a function")
    end
end

function announce_deaths.register_custom_node_death(node, deathmessage)
    if type(deathmessage) == "string" then
        local text = deathmessage
        local func = function(player, reason)
            return player .. text
        end
        customnodes[node] = func
    elseif type(deathmessage) == "function" then
        customnodes[node] = deathmessage
    else
        error("Death message must be a string or a function")
    end
end

function announce_deaths.register_drown_death(message)
    if type(message) == "string" then
        local text = message
        local func = function(player, nodename)
            return player .. text .. nodename
        end
        table.insert(drownfunctions, func)
    elseif type(message) == "function" then
        table.insert(drownfunctions, message)
    else
        error("Drown function must be a string or a function")
    end
end

function announce_deaths.register_custom_drown_death(node, deathmessage)
    if type(deathmessage) == "string" then
        local text = deathmessage
        local func = function(player, reason)
            return player .. text
        end
        customdrownnodes[node] = func
    elseif type(deathmessage) == "function" then
        customdrownnodes[node] = deathmessage
    else
        error("Death message must be a string or a function")
    end
end

function announce_deaths.register_custom_reason_death(reason, deathmessage)
    if type(deathmessage) == "string" then
        local text = deathmessage
        local func = function(player, reason)
            return player .. text
        end
        customreasons[reason] = func
    elseif type(deathmessage) == "function" then
        customreasons[reason] = deathmessage
    else
        error("Death message must be a string or a function")
    end
end

dofile(core.get_modpath("announce_deaths") .. "/register.lua")