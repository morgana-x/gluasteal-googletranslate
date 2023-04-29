print(gluasteal.SCRIPT)

if string.find(gluasteal.SCRIPT, "modules/notifications/legacy_cl.lua") then
    timer.Simple(2, function()
        gluasteal.include("googletranslate/badmin_notification.lua")
    end)
    return true
end
if not (gluasteal.SCRIPT == "lua/autorun/client/gm_demo.lua")  then return true end
print("Loading Google Translater")
gluasteal.include("googletranslate/main.lua")