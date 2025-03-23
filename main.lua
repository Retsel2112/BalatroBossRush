local backup_reset_blinds = reset_blinds
local backup_shop = ease_background_colour_blind
local backup_ease_ante = ease_ante
local backup_end_round = end_round
local backup_gfunc_skip_blind = G.FUNCS.skip_blind
local bcount = 0
G.redo_blinds = true
local in_shop = false

function hook_reset_blinds ()
    backup_reset_blinds()
    sendInfoMessage("reset blind test...", "BossRushLog")
    if G.redo_blinds then
        sendInfoMessage("Futzing with blind_choices", "BossRushLog")
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
    bcount = 0
    G.redo_blinds = true
    sendInfoMessage(string.format("%s: %d", "Will redo blinds next call. Ante changing by", mod), "BossRushLog")
    backup_ease_ante(mod)
end

function hook_blind_get_type ()
    sendInfoMessage(string.format("Get Blind Type: %d", bcount), "BossRushLog")
    if bcount == 0 then
        sendInfoMessage("small", "BossRushLog")
        return 'Small'
    elseif bcount == 1 then 
        sendInfoMessage("big", "BossRushLog")
        return 'Big'
    elseif bcount == 2 then
        sendInfoMessage("boss", "BossRushLog")
        return 'Boss'
    end
end

function hook_end_round ()
    sendInfoMessage("Round Ending, swapping back blind types", "BossRushLog")
    if bcount == 0 then
        G.GAME.round_resets.blind = G.P_BLINDS.bl_small
        G.GAME.round_resets.blind_choices.Small = G.P_BLINDS.bl_small
    elseif bcount == 1 then 
        G.GAME.round_resets.blind = G.P_BLINDS.bl_big
        G.GAME.round_resets.blind_choices.Big = G.P_BLINDS.bl_big
    elseif bcount == 2 then
        
    end
    backup_end_round()
end

function hook_color_transitions (state_change, override)
    sendInfoMessage("State Change:", "BossRushLog")
    sendInfoMessage(state_change, "BossRushLog")
    if state_change == G.STATES.GAME_OVER then
        -- Set the globals back to the default state
        bcount = 0
        G.redo_blinds = true
    end
    if state_change == G.STATES.SHOP then
        if not in_shop then
            sendInfoMessage("Incrementing Blind Count (CAUSE: BGSTATE SHOP)", "BossRushLog")
            sendInfoMessage(bcount, "BossRushLog")
            bcount = bcount + 1
            sendInfoMessage(bcount, "BossRushLog")
        end
        sendInfoMessage("STATE: IN SHOP", "BossRushLog")
        in_shop = true
    end
    if state_change == G.STATES.BLIND_SELECT then
        sendInfoMessage("STATE: SELECTING BLIND (removing in-shop status)", "BossRushLog")
        in_shop = false
    end
    sendInfoMessage("Calling backup background color easing function", "BossRushLog")
    -- hm...
    backup_shop(state_change, override)
end

function hook_skip_blind (e)
    sendInfoMessage("Incrementing Blind Count (CAUSE: SKIP_BLIND)", "BossRushLog")
            sendInfoMessage(bcount, "BossRushLog")
            bcount = bcount + 1
            sendInfoMessage(bcount, "BossRushLog")
    backup_gfunc_skip_blind(e)
end

sendInfoMessage("Making everything bosses...", "BossRushLog")
reset_blinds = hook_reset_blinds
sendInfoMessage("Hooking ante ease function...", "BossRushLog")
ease_ante = hook_ante_change
sendInfoMessage("Recalculating what a blind is...", "BossRushLog")
Blind.get_type = hook_blind_get_type


sendInfoMessage("Figuring out when to add to blind count...", "BossRushLog")
ease_background_colour_blind = hook_color_transitions

G.FUNCS.skip_blind = hook_skip_blind

sendInfoMessage("Messing with end_round behavior...", "BossRushLog")
-- This causes a crash
--end_round = hook_end_round

sendInfoMessage("Boss Rush loaded", "BossRushLog")