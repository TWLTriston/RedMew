local table = require 'utils.table'
local Game = require 'utils.game'
local Event = require 'utils.event'
local Global = require 'utils.global'
local Info = require 'features.gui.info'
local UserGroups  = require 'features.user_groups'

local get_random_weighted = table.get_random_weighted

local memory = {
    forces_initialized = {
        player = false, -- default force for everyone
    }
}

Global.register({
    memory = memory,
}, function (tbl)
    memory = tbl.memory
end)

local function player_created(event)
    local config = global.config.player_create
    local player = Game.get_player_by_index(event.player_index)

    if not player or not player.valid then
        return
    end

    local force = player.force

    -- ensure the top menu is correctly styled
    local gui = player.gui
    gui.top.style = 'slot_table_spacing_horizontal_flow'
    gui.left.style = 'slot_table_spacing_vertical_flow'

    local player_insert = player.insert

    for _, item in pairs(config.starting_items) do
        player_insert(item)
    end

    local p = player.print
    for _, message in pairs(config.join_messages) do
        p(message)
    end

    local random_messages = config.random_join_message_set
    if #random_messages > 0 then
        p(get_random_weighted(random_messages))
    end

    if config.show_info_at_start and not _DEBUG then
        if Info ~= nil then
            Info.show_info(player)
        end
    end

    if not game.is_multiplayer() and not _DEBUG then
        player.print('To change your name in single-player, open chat and type the following /c game.player.name = "your_name"')
    end

    if _DEBUG and player.admin then
        UserGroups.add_regular(player.name)
        if game.is_multiplayer then
            game.print("THIS MULTIPLAYER MAP IS IN DEBUG!!!")
        else
            game.print("DON'T LAUNCH THIS MAP! DEBUG MODE IS ENABLED!!!")
        end
    end

    if _CHEATS then
        player.cheat_mode = true
        local cheats = config.cheats

        if cheats.start_with_power_armor then
            player_insert({name = 'power-armor-mk2', count = 1})
            local armor_put = player.get_inventory(5)[1].grid.put
            armor_put({name = 'fusion-reactor-equipment'})
            armor_put({name = 'fusion-reactor-equipment'})
            armor_put({name = 'fusion-reactor-equipment'})
            armor_put({name = 'fusion-reactor-equipment'})
            armor_put({name = 'personal-roboport-mk2-equipment'})
            armor_put({name = 'personal-roboport-mk2-equipment'})
            armor_put({name = 'personal-laser-defense-equipment'})
            armor_put({name = 'personal-laser-defense-equipment'})
            armor_put({name = 'energy-shield-mk2-equipment'})
            armor_put({name = 'energy-shield-mk2-equipment'})
            armor_put({name = 'night-vision-equipment'})
            armor_put({name = 'battery-mk2-equipment'})
            armor_put({name = 'battery-mk2-equipment'})
            armor_put({name = 'battery-mk2-equipment'})
            armor_put({name = 'belt-immunity-equipment'})
            armor_put({name = 'solar-panel-equipment'})
        end
        for _, item in pairs(cheats.starting_items) do
            player_insert(item)
        end

        if not memory.forces_initialized[force.name] then
            force.manual_mining_speed_modifier = cheats.manual_mining_speed_modifier
            force.character_inventory_slots_bonus = cheats.character_inventory_slots_bonus
            force.character_running_speed_modifier = cheats.character_running_speed_modifier
            force.character_health_bonus = cheats.character_health_bonus
        end
    end

    memory.forces_initialized[force.name] = true
end

Event.add(defines.events.on_player_created, player_created)
