-- Variables
local addonName = ...
local debugmode = false

local voices = {
    { label = "AOL You Got Mail", path = "YouGotMail.ogg" },
    { label = "Illidan (voiced by Scooba)", path = "voices\\_illidan_1_scooba.ogg", contributor = "Scooba" },
    { label = "Blood Elf male #1 (voiced by Rufphus)", path = "voices\\blood_elf_male_1_rufphus.ogg", contributor = "Rufphus" },
    { label = "Blood Elf male #2 (voiced by Saenokda)", path = "voices\\blood_elf_male_2_saenokda.ogg", contributor = "Saenokda" },
    { label = "Draenei male #1 (voiced by Saenokda)", path = "voices\\draenei_male_1_saenokda.ogg", contributor = "Saenokda" },
    { label = "Dwarf male #1 (voiced by Toady)", path = "voices\\dwarf_male_1_toady.ogg", contributor = "Toady" },
    { label = "Gnome male #1 (voiced by Toady)", path = "voices\\gnome_male_1_toady.ogg", contributor = "Toady" },
    { label = "Gnome male #2 (voiced by Scooba)", path = "voices\\gnome_male_2_scooba.ogg", contributor = "Scooba" },
    { label = "Goblin male #1 (voiced by Toady)", path = "voices\\goblin_male_1_toady.ogg", contributor = "Toady" },
    { label = "Goblin male #2 (voiced by Toady)", path = "voices\\goblin_male_2_toady.ogg", contributor = "Toady" },
    { label = "Human male #1 (voiced by Saenokda)", path = "voices\\human_male_1_saenokda.ogg", contributor = "Saenokda" },
    { label = "Human male #2 (voiced by Saenokda)", path = "voices\\human_male_2_saenokda.ogg", contributor = "Saenokda" },
    { label = "Tauren male #1 (voiced by Rufphus)", path = "voices\\tauren_male_1_rufphus.ogg", contributor = "Rufphus" },
    { label = "Tauren male #2 (voiced by Rufphus)", path = "voices\\tauren_male_2_rufphus.ogg", contributor = "Rufphus" },
    { label = "Troll male #1 (voiced by Zuljawa)", path = "voices\\troll_male_1_zuljawa.ogg", contributor = "Zuljawa" },
    { label = "Troll male #2 (voiced by Zuljawa)", path = "voices\\troll_male_2_zuljawa.ogg", contributor = "Zuljawa" },
    { label = "Troll male #3 (voiced by Zuljawa)", path = "voices\\troll_male_3_zuljawa.ogg", contributor = "Zuljawa" },
    { label = "Troll male #4 (voiced by Zuljawa)", path = "voices\\troll_male_4_zuljawa.ogg", contributor = "Zuljawa" },
    { label = "Undead male #1 (voiced by Rufphus)", path = "voices\\undead_male_1_rufphus.ogg", contributor = "Rufphus" },
    { label = "Undead male #2 (voiced by Saenokda)", path = "voices\\undead_male_2_saenokda.ogg", contributor = "Saenokda" },
    { label = "I got mail, YAY! (from Crank Yankers)", path = "voices\\i_got_mail_yay_i_got_mail_yay.ogg" },
}

local addonPath = "Interface\\AddOns\\" .. addonName .. "\\"

-- Saved variables
if type(YouGotMail_SavedVars) ~= "table" then
    YouGotMail_SavedVars = {}
end

if type(YouGotMail_SavedVars.voice) ~= "number"
    or YouGotMail_SavedVars.voice % 1 ~= 0
    or not voices[YouGotMail_SavedVars.voice] then
    YouGotMail_SavedVars.voice = 1
end

if type(YouGotMail_SavedVars.mail) ~= "boolean" then
    YouGotMail_SavedVars.mail = false
end

if type(YouGotMail_SavedVars.time) ~= "number" or YouGotMail_SavedVars.time < 0 then
    YouGotMail_SavedVars.time = 0
end

local category = Settings.RegisterVerticalLayoutCategory("YouGotMail")

-- Functions
local function GetOptions()
    local container = Settings.CreateControlTextContainer()
    for index, voice in ipairs(voices) do
        container:Add(index, voice.label)
    end
    return container:GetData()
end

local function Debug(text)
    if debugmode then print(text) end
end

local function PlayTrack(n)
    local voice = voices[tonumber(n)]
    if not voice then
        YouGotMail_SavedVars.voice = 1
        voice = voices[1]
    end

    PlaySoundFile(addonPath .. voice.path)
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

        return
    end

    if event == "PLAYER_LOGIN" or event == "UPDATE_PENDING_MAIL" then
        CheckTheMail()
    end
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
