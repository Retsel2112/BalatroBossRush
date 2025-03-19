local backup = reset_blinds
local backup_shop = ease_background_colour_blind
local backup_ease_ante = ease_ante
local backup_end_round = end_round
local bcount = 0
local in_shop = false

function hook_blinds ()
    backup()
    sendInfoMessage("Futzing with blind_choices", "BossRushLog")
    G.GAME.round_resets.blind_choices.Small = get_new_boss()
    G.GAME.round_resets.blind_choices.Big = get_new_boss()
    --G.GAME.round_resets.blind_choices.Boss = get_new_boss()
end

function hook_ante_change (mod)
    bcount = 0
    sendInfoMessage("Ante changing:", "BossRushLog")
    sendInfoMessage(mod, "BossRushLog")
    backup_ease_ante(mod)
end

function hook_blind_get_type ()
    sendInfoMessage("Get Blind Type:", "BossRushLog")
    sendInfoMessage(bcount, "BossRushLog")
    if bcount == 0 then
        return 'Small'
    elseif bcount == 1 then 
        return 'Big'
    elseif bcount == 2 then
        return 'Boss'
    end
end

function hook_end_round ()
    sendInfoMessage("Round Ending, swapping back blind types", "BossRushLog")
    if bcount == 0 then
        G.GAME.round_resets.blind = G.P_BLINDS.bl_small
    elseif bcount == 1 then 
        G.GAME.round_resets.blind = G.P_BLINDS.bl_big
    elseif bcount == 2 then
        
    end
    backup_end_round()
end

function hook_shop (state_change)
    --sendInfoMessage("State Change:", "BossRushLog")
    --sendInfoMessage(state_change, "BossRushLog")
    if state_change == G.STATES.SHOP then
        if not in_shop then
            sendInfoMessage("Incrementing Blind Count", "BossRushLog")
            sendInfoMessage(bcount, "BossRushLog")
            bcount = bcount + 1
            sendInfoMessage(bcount, "BossRushLog")
        end
        in_shop = true
    end
    if state_change == G.STATES.BLIND_SELECT then
        in_shop = false
    end

    backup_shop(state_change)
end

sendInfoMessage("Making everything bosses...", "BossRushLog")
reset_blinds = hook_blinds
sendInfoMessage("Hooking ante ease function...", "BossRushLog")
ease_ante = hook_ante_change
sendInfoMessage("Recalculating what a blind is...", "BossRushLog")
Blind.get_type = hook_blind_get_type


sendInfoMessage("Figuring out when to add to blind count...", "BossRushLog")
ease_background_colour_blind = hook_shop

sendInfoMessage("Messing with end_round behavior...", "BossRushLog")
end_round = hook_end_round

sendInfoMessage("Boss Rush loaded", "BossRushLog")