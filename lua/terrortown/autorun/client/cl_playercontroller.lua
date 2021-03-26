PlayerControl = PlayerControl or {}

net.Receive("playerControllerNet", function (len)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local tbl = net.ReadTable()

    -- START 
    if tbl.mode == PC_MODE_START then
        --MsgC(Color(255, 64, 64), "[PLAYER CONTROLLER] ", Color(198, 198, 198), tbl.log.."\n")

        -- Set the table to the player
        ply.controller = {}
        ply.controller["player"] = tbl.player
        
        print("Table Print:")
        PrintTable(tbl) 

        -- If controlling Player
        if tbl.controlling then
            print("Die ViewEntity:", GetViewEntity():GetName())
            
            ply:UseClientSideAnimation()

            hook.Add("DoAnimationEvent", "PlayerControler:DisableControllerAnimation", function(anim_ply, event, data)
                if ply == anim_ply then
                    return ACT_INVALID
                end
            end)
            -- ply.Move = function(slf, mv)
            --     return true
            -- end
        -- If the controlled Player
        else



        end


    -- END
    elseif tbl.mode == PC_MODE_END then



    -- MESSAGE FROM SERVER
    elseif tbl.mode == PC_MODE_MESSAGE then
        


    end
end)
