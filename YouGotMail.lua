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

local soundChannels = {
    { label = "Master", value = "Master" },
    { label = "Sound Effects", value = "SFX" },
    { label = "Dialog", value = "Dialog" },
    { label = "Music", value = "Music" },
    { label = "Ambience", value = "Ambience" },
}

local validSoundChannels = {}
for _, soundChannel in ipairs(soundChannels) do
    validSoundChannels[soundChannel.value] = true
end

local addonPath = "Interface\\AddOns\\" .. addonName .. "\\"

local category

-- Saved variables
-- SavedVariables are loaded after this file runs (just before ADDON_LOADED),
-- so defaults must be applied from the ADDON_LOADED handler, not at file scope.
local function InitSavedVars()
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

    if type(YouGotMail_SavedVars.enabled) ~= "boolean" then
        YouGotMail_SavedVars.enabled = true
    end

    if type(YouGotMail_SavedVars.soundChannel) ~= "string"
        or not validSoundChannels[YouGotMail_SavedVars.soundChannel] then
        YouGotMail_SavedVars.soundChannel = "Master"
    end
end

-- Functions
local function GetOptions()
    local container = Settings.CreateControlTextContainer()
    for index, voice in ipairs(voices) do
        container:Add(index, voice.label)
    end
    return container:GetData()
end

local function GetSoundChannelOptions()
    local container = Settings.CreateControlTextContainer()
    for _, soundChannel in ipairs(soundChannels) do
        container:Add(soundChannel.value, soundChannel.label)
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

    local willPlay = PlaySoundFile(addonPath .. voice.path, YouGotMail_SavedVars.soundChannel)
    return willPlay, voice
end

local function CheckTheMail()
    if not category then return end -- not initialized yet (before ADDON_LOADED)

    if (HasNewMail()) then
        Debug("Mail detected.")
        if not YouGotMail_SavedVars.enabled then
            Debug("Notifications are disabled.")
        elseif (YouGotMail_SavedVars.mail == false or time() > YouGotMail_SavedVars.time + 3600) then
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

-- Plays the notification as if new mail had arrived, without touching the
-- once-per-hour spam timer, so it can be repeated and works without real mail.
local function TestNotification()
    local willPlay, voice = PlayTrack(YouGotMail_SavedVars.voice)
    local channel = YouGotMail_SavedVars.soundChannel

    if willPlay then
        print(("YouGotMail: test notification played \"%s\" on the %s channel."):format(voice.label, channel))
    else
        print(("YouGotMail: could not play \"%s\" on the %s channel. Check that sound and that channel are enabled."):format(voice.label, channel))
    end

    if not YouGotMail_SavedVars.enabled then
        print("YouGotMail: note that notifications are currently disabled, so real mail will not play a sound.")
    end
end

local function SlashCommand(msg)
    local command = strtrim(msg or ""):lower()

    if command == "test" then
        TestNotification()
    elseif command == "" then
        Debug("Opening YouGotMail options.")
        Settings.OpenToCategory(category:GetID())
    else
        print("YouGotMail commands:")
        print("  /ygm - open the options")
        print("  /ygm test - play the mail notification now")
    end
end

-- Settings
local function RegisterSettings()
    category = Settings.RegisterVerticalLayoutCategory("YouGotMail")

    local enabledSetting = Settings.RegisterAddOnSetting(
        category,
        "YouGotMail_Enabled",
        "enabled",
        YouGotMail_SavedVars,
        Settings.VarType.Boolean,
        "Enable Notifications",
        true
    )
    Settings.CreateCheckbox(category, enabledSetting, "Play a voice notification when new mail is detected.")

    local voiceSetting = Settings.RegisterAddOnSetting(
        category,
        "YouGotMail_Voice",
        "voice",
        YouGotMail_SavedVars,
        Settings.VarType.Number,
        "Voice",
        1
    )
    Settings.CreateDropdown(category, voiceSetting, GetOptions, "Select the voice used for mail notifications.")

    local soundChannelSetting = Settings.RegisterAddOnSetting(
        category,
        "YouGotMail_SoundChannel",
        "soundChannel",
        YouGotMail_SavedVars,
        Settings.VarType.String,
        "Sound Channel",
        "Master"
    )
    Settings.CreateDropdown(
        category,
        soundChannelSetting,
        GetSoundChannelOptions,
        "Use the selected in-game sound channel and its volume setting."
    )

    local previewInitializer = CreateSettingsButtonInitializer(
        "Preview Voice",
        "Play",
        function()
            PlayTrack(YouGotMail_SavedVars.voice)
        end,
        "Play the selected voice through the selected sound channel.",
        true
    )
    Settings.RegisterInitializer(category, previewInitializer)

    Settings.RegisterAddOnCategory(category)
end

-- Event handling frame
local eventFrame = CreateFrame("Frame")

-- Event handler function
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddonName = ...
        if loadedAddonName == addonName then
            InitSavedVars()
            RegisterSettings()
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
