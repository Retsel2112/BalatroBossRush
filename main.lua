local backup_reset_blinds = reset_blinds
local backup_shop = ease_background_colour_blind
local backup_ease_ante = ease_ante
local backup_end_round = end_round
local backup_gfunc_skip_blind = G.FUNCS.skip_blind
local bcount = 0
G.redo_blinds = true
local in_shop = false
local mod_name = "BossRushMod"

function hook_reset_blinds ()
    --[[]
    G.GAME.round_resets.blind_states = G.GAME.round_resets.blind_states or {Small = 'Select', Big = 'Upcoming', Boss = 'Upcoming'}
    if G.GAME.round_resets.blind_states.Boss == 'Defeated' then
        G.GAME.round_resets.blind_states.Small = 'Upcoming'
        G.GAME.round_resets.blind_states.Big = 'Upcoming'
        G.GAME.round_resets.blind_states.Boss = 'Upcoming'
        G.GAME.blind_on_deck = 'Small'
        G.GAME.round_resets.blind_choices.Boss = get_new_boss()
        G.GAME.round_resets.boss_rerolled = false
    end
    ]]--
    backup_reset_blinds()
    sendInfoMessage("reset blind test...", mod_name)
    if G.redo_blinds then
        sendInfoMessage("Futzing with blind_choices", mod_name)
        --would be nice to log what state the game is in here
        G.GAME.round_resets.blind_choices.Small = get_new_boss()
        G.GAME.round_resets.blind_choices.Big = get_new_boss()
        --G.GAME.round_resets.blind_choices.Boss = get_new_boss()
        G.redo_blinds = false
    end
end

function hook_ante_change (mod)
    -- when the ante changes from a voucher, we need to reset the blind count
    -- when the ante changes from beating the 3rd blind, this fires before the bcount increment
    if mod > 0 then
        -- will hit an increment call when leaving the shop it's about to enter
        bcount = -1
    else
        -- negative ante changes come from vouchers which do not exit through the gift shop
        bcount = 0
    end
    G.redo_blinds = true
    sendInfoMessage(string.format("%s: %d", "Will redo blinds next call. Ante changing by", mod), mod_name)
    backup_ease_ante(mod)
end

function hook_blind_get_type ()
    sendInfoMessage(string.format("Get Blind Type: %d", bcount), mod_name)
    if bcount == 0 then
        sendInfoMessage("small", mod_name)
        return 'Small'
    elseif bcount == 1 then 
        sendInfoMessage("big", mod_name)
        return 'Big'
    elseif bcount == 2 then
        sendInfoMessage("boss", mod_name)
        return 'Boss'
    end
end

function hook_color_transitions (state_change, override)
    sendInfoMessage("State Change:", mod_name)
    sendInfoMessage(state_change, mod_name)
    if state_change == G.STATES.GAME_OVER then
        -- Set the globals back to the default state
        bcount = 0
        G.redo_blinds = true
    end
    if state_change == G.STATES.SHOP then
        if not in_shop then
            sendInfoMessage(string.format("Incrementing Blind Count (CAUSE: BGSTATE SHOP) %d to %d", bcount, bcount+1), mod_name)
            sendInfoMessage(bcount, mod_name)
            bcount = bcount + 1
            sendInfoMessage(bcount, mod_name)
            if bcount > 2 then
                sendInfoMessage("ERROR! BLIND COUNT TOO HIGH!", mod_name)
            end
        end
        sendInfoMessage("STATE: IN SHOP", mod_name)
        in_shop = true
    end
    if state_change == G.STATES.BLIND_SELECT then
        sendInfoMessage("STATE: SELECTING BLIND (removing in-shop status)", mod_name)
        in_shop = false
    end
    if state_change == G.STATES.ROUND_EVAL then
        sendInfoMessage("STATE: ROUND EVAL", mod_name)
        --[[if G.GAME.round_resets.blind == G.P_BLINDS.bl_small then
            G.GAME.round_resets.blind_states.Small = 'Defeated'
        elseif G.GAME.round_resets.blind == G.P_BLINDS.bl_big then
            G.GAME.round_resets.blind_states.Big = 'Defeated'
        else]]
        if bcount == 0 then
            G.GAME.blind_on_deck = 'Small'
        elseif bcount == 1 then 
            G.GAME.blind_on_deck = 'Big'
            G.GAME.round_resets.blind_states.Small = 'Defeated'
        elseif bcount == 2 then
            G.GAME.blind_on_deck = 'Boss'
            G.GAME.round_resets.blind_states.Big = 'Defeated'
        end
    end
    sendInfoMessage("Calling backup background color easing function", mod_name)
    -- hm...
    backup_shop(state_change, override)
end

function hook_skip_blind (e)
    sendInfoMessage("Incrementing Blind Count (CAUSE: SKIP_BLIND)", mod_name)
            sendInfoMessage(bcount, mod_name)
            bcount = bcount + 1
            sendInfoMessage(bcount, mod_name)
            if bcount > 2 then
                sendInfoMessage("ERROR! BLIND COUNT TOO HIGH!", mod_name)
            end
    backup_gfunc_skip_blind(e)
end

sendInfoMessage("Making everything bosses...", mod_name)
reset_blinds = hook_reset_blinds
sendInfoMessage("Hooking ante ease function...", mod_name)
ease_ante = hook_ante_change
sendInfoMessage("Recalculating what a blind is...", mod_name)
Blind.get_type = hook_blind_get_type


sendInfoMessage("Figuring out when to add to blind count...", mod_name)
ease_background_colour_blind = hook_color_transitions

G.FUNCS.skip_blind = hook_skip_blind

sendInfoMessage("Boss Rush loaded", mod_name)