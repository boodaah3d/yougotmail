-- Saved variables
if not YouGotMail_SavedVars then
    YouGotMail_SavedVars = {}
end

if not YouGotMail_SavedVars.voice then
    YouGotMail_SavedVars.voice = 1
end

if not YouGotMail_SavedVars.mail then
    YouGotMail_SavedVars.mail = false
end

if not YouGotMail_SavedVars.time or YouGotMail_SavedVars.time == nil then
    YouGotMail_SavedVars.time = 0
end

-- Variables
local addonName, addonTable = ...
local debugmode = false
local _G = _G

local category = Settings.RegisterVerticalLayoutCategory("YouGotMail")

local voices = {
    "Interface\\AddOns\\YouGotMail\\YouGotMail.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\_illidan_1_scooba.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\blood_elf_male_1_rufphus.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\blood_elf_male_2_saenokda.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\draenei_male_1_saenokda.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\dwarf_male_1_toady.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\gnome_male_1_toady.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\gnome_male_2_scooba.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\goblin_male_1_toady.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\goblin_male_2_toady.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\human_male_1_saenokda.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\human_male_2_saenokda.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\tauren_male_1_rufphus.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\tauren_male_2_rufphus.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\troll_male_1_zuljawa.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\troll_male_2_zuljawa.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\troll_male_3_zuljawa.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\troll_male_4_zuljawa.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\undead_male_1_rufphus.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\undead_male_2_saenokda.ogg",
    "Interface\\Addons\\YouGotMail\\voices\\i_got_mail_yay_i_got_mail_yay.ogg"
}

-- Functions
local function GetOptions()
    local container = Settings.CreateControlTextContainer()
    container:Add(1, "AOL You Got Mail")
    container:Add(2, "Illidan (voiced by Scooba)")
    container:Add(3, "Blood Elf male #1 (voiced by Rufphus)")
    container:Add(4, "Blood Elf male #2 (voiced by Saenokda)")
    container:Add(5, "Draenei male #1 (voiced by Saenokda)")
    container:Add(6, "Dwarf male #1 (voiced by Toady)")
    container:Add(7, "Gnome male #1 (voiced by Toady)")
    container:Add(8, "Gnome male #2 (voiced by Scooba)")
    container:Add(9, "Goblin male #1 (voiced by Toady)")
    container:Add(10, "Goblin male #2 (voiced by Toady)")
    container:Add(11, "Human male #1 (voiced by Saenokda)")
    container:Add(12, "Human male #2 (voiced by Saenokda)")
    container:Add(13, "Tauren male #1 (voiced by Rufphus)")
    container:Add(14, "Tauren male #2 (voiced by Rufphus)")
    container:Add(15, "Troll male #1 (voiced by Zuljawa)")
    container:Add(16, "Troll male #2 (voiced by Zuljawa)")
    container:Add(17, "Troll male #3 (voiced by Zuljawa)")
    container:Add(18, "Troll male #4 (voiced by Zuljawa)")
    container:Add(19, "Undead male #1 (voiced by Rufphus)")
    container:Add(20, "Undead male #2 (voiced by Saenokda)")
    container:Add(21, "I got mail, YAY! (from Crank Yankers)")
    return container:GetData()
end

function Debug(text)
    if debugmode then print(text) end
end

local function PlayTrack(n)
    PlaySoundFile(voices[tonumber(n)])
end

local function CheckTheMail()
    if (HasNewMail()) then
        Debug("Mail detected.")
        if (YouGotMail_SavedVars.mail == false or time() > YouGotMail_SavedVars.time + 3600) then
            YouGotMail_SavedVars.mail = true
            YouGotMail_SavedVars.time = time()
            PlayTrack(YouGotMail_SavedVars.voice)
        else
            Debug("YGM spam prevented: " .. time())
        end
    else
        YouGotMail_SavedVars.mail = false
        YouGotMail_SavedVars.time = 0
    end
end

local function OnVoiceOptionChanged(newVoice)
    if type(newVoice) ~= "number" then
        Debug("Invalid voice setting: " .. tostring(newVoice))
        return
    end
    YouGotMail_SavedVars.voice = newVoice
    PlayTrack(YouGotMail_SavedVars.voice)
    Debug("Voice setting updated to: " .. newVoice)
end

local function SlashCommand()
    Debug("Opening YouGotMail options.")
    Settings.OpenToCategory(category:GetID())
end

-- Settings
do
    local name = "Select Voice"
    local variable = "selectedVoice"
    local variableKey = "voice"
    local variableTbl = YouGotMail_SavedVars
    local defaultValue = 1

    if not variableTbl[variableKey] then
        variableTbl[variableKey] = defaultValue
    end

    local setting = Settings.RegisterAddOnSetting(category, variable, variableKey, variableTbl, Settings.VarType.Number, name, defaultValue)

    setting:SetValueChangedCallback(function()
        OnVoiceOptionChanged(setting:GetValue())
    end)

    local tooltip = "Select the voice to use."
    Settings.CreateDropdown(category, setting, GetOptions, tooltip)
end

Settings.RegisterAddOnCategory(category)

-- Event handling frame
local eventFrame = CreateFrame("Frame")

-- Event handler function
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddonName = ...
        if loadedAddonName == addonName then
            SLASH_YOUGOTMAIL1 = "/ygm"
            SlashCmdList["YOUGOTMAIL"] = SlashCommand
            self:UnregisterEvent("ADDON_LOADED")
        end
    end

    CheckTheMail()
end)

-- Register the events
eventFrame:RegisterEvent("UPDATE_PENDING_MAIL")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ADDON_LOADED")

-- Notes:
-- If a player already has been notified that they have mail, we do not
-- want to spam them with notices. So we record the time at which they
-- have been notified, and then check that it's been at least an hour
-- before we notify them again.

-- The code that controls that behavior is
-- time() > YouGotMail_SavedVars.time + 3600
