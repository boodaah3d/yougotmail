local f = CreateFrame("Frame")

if (YouGotMailDB == nil) then
    YouGotMailDB = {}
end

f:RegisterEvent("UPDATE_PENDING_MAIL")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent",
    function(self,event,...)
        if (event == "PLAYER_LOGIN") then
            ResetMailFlags()
        end
        if (HasNewMail()) then
            if (YouGotMailDB.mail == false or time() > YouGotMailDB.time + 3600) then
                YouGotMailDB.mail = true
                YouGotMailDB.time = time()
                PlaySoundFile("Interface\\AddOns\\YouGotMail\\YouGotMail.ogg")
            end
        else
            ResetMailFlags()
        end
    end
)

function ResetMailFlags()
    YouGotMailDB.mail = false
    YouGotMailDB.time = nil
end


-- Note:
-- The announcement is made when a user logs on or reloads.
-- Additional announcements will be made once per hour when
-- a player does anything that creates a load screen, such as
-- going thru a portal, or entering or leaving an instance.

-- Program note:
-- This is the code that controls that behavior.
-- time() > YouGotMailDB.time + 3600
