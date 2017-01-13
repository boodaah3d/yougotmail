-----------------
-- Variables
-----------------
local addonName, addonTable = ...
local debugmode = false
local _G = _G

local Options = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)

local items = {
    "AOL You Got Mail",
    "Illidan (voiced by Scooba)",
    "Blood Elf male #1 (voiced by Rufphus)",
    "Blood Elf male #2 (voiced by Saenokda)",
    "Draenei male #1 (voiced by Saenokda)",
    "Dwarf male #1 (voiced by Toady)",
    "Gnome male #1 (voiced by Toady)",
    "Gnome male #2 (voiced by Scooba)",
    "Goblin male #1 (voiced by Toady)",
    "Goblin male #2 (voiced by Toady)",
    "Human male #1 (voiced by Saenokda)",
    "Human male #2 (voiced by Saenokda)",
    "Tauren male #1 (voiced by Rufphus)",
    "Tauren male #2 (voiced by Rufphus)",
    "Troll male #1 (voiced by Zuljawa)",
    "Troll male #2 (voiced by Zuljawa)",
    "Troll male #3 (voiced by Zuljawa)",
    "Troll male #4 (voiced by Zuljawa)",
    "Undead male #1 (voiced by Rufphus)",
    "Undead male #2 (voiced by Saenokda)"
}

local voices = {}
tinsert(voices, "Interface\\AddOns\\YouGotMail\\YouGotMail.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\_illidan_1_scooba.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\blood_elf_male_1_rufphus.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\blood_elf_male_2_saenokda.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\draenei_male_1_saenokda.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\dwarf_male_1_toady.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\gnome_male_1_toady.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\gnome_male_2_scooba.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\goblin_male_1_toady.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\goblin_male_2_toady.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\human_male_1_saenokda.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\human_male_2_saenokda.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\tauren_male_1_rufphus.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\tauren_male_2_rufphus.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\troll_male_1_zuljawa.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\troll_male_2_zuljawa.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\troll_male_3_zuljawa.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\troll_male_4_zuljawa.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\undead_male_1_rufphus.ogg")
tinsert(voices, "Interface\\Addons\\YouGotMail\\voices\\undead_male_2_saenokda.ogg")

local count = 0
for _ in pairs(voices) do count = count + 1 end

-----------------
-- Functions
-----------------
function CheckTheMail()
    if (HasNewMail()) then
        Debug(CurrentMailStatus())
        Debug(CurrentMailTime())
        Debug(CurrentVoice())
        if (YouGotMailOptions.mail == false or time() > YouGotMailOptions.time + 3600) then
            YouGotMailOptions.mail = true
            YouGotMailOptions.time = time()
            PlayNotification()
        else
            Debug("YGM spam filtered: " .. time())
        end
    else
        Debug(CurrentMailStatus())
        ResetMailFlags()
    end
end

function Debug(text)
    if debugmode then print(text) end
end

function ChangeTrack(n)
    YouGotMailOptions.voice = tonumber(n)
end

function PlayNotification()
    PlayTrack(YouGotMailOptions.voice)
end

function PlayTrack(n)
    PlaySoundFile(voices[tonumber(n)])
end

function RandomTrack()
    PlayTrack(random(count))
end

function CurrentMailStatus()
    if YouGotMailOptions.mail then return("YGM mail: true") else return("YGM mail: false") end
end

function CurrentMailTime()
    if YouGotMailOptions.time then return("YGM time: " .. YouGotMailOptions.time) end
end

function CurrentVoice()
    if YouGotMailOptions.voice then return("YGM voice: " .. YouGotMailOptions.voice) end
end

function ResetMailFlags()
    YouGotMailOptions.mail = false
    YouGotMailOptions.time = nil
end

-----------------
-- Initialize
-----------------
function Initialize()
    if not YouGotMailOptions then
        YouGotMailOptions = {}
    end
    if not YouGotMailOptions.voice then
        YouGotMailOptions.voice = 1
    end
end

-----------------
-- Slash Commands
-----------------
function SlashCommand()
    InterfaceOptionsFrame:Show()
    InterfaceOptionsFrameTab2:Click()
    InterfaceOptionsFrameAddOnsListScrollBar:SetValue(0)

    local buttonHeight = InterfaceOptionsFrameAddOnsButton1:GetHeight()
    local buttons = InterfaceOptionsFrameAddOns.buttons;
    local buttonClicked = false
    local firstButton = nil

    while InterfaceOptionsFrameAddOnsButton1:GetText() ~= firstButton do
        firstButton = InterfaceOptionsFrameAddOnsButton1:GetText()
        for i = 1, #buttons do
            local button = _G["InterfaceOptionsFrameAddOnsButton" .. i]
            if button:GetText() == "YouGotMail" then
                button:Click()
                buttonClicked = true
                break
            end
        end
        if buttonClicked then break end
        InterfaceOptionsFrameAddOnsListScrollBar:SetValue(#buttons * buttonHeight)
    end
end


-----------------
-- Options
-----------------

local function UncheckAllRadios()
    local frame = EnumerateFrames()
    while frame do
        if frame:GetName() and string.find(frame:GetName(), "ygmRadio") then
            frame:SetChecked(false)
        end
        frame = EnumerateFrames(frame)
    end
end

local function CreateOptionsPanel()
    Options:Hide()
    Options.name = "YouGotMail"

    local panelWidth = InterfaceOptionsFramePanelContainer:GetWidth() -- ~623
    local wideWidth = panelWidth - 40

    local title = Options:CreateFontString(nil, "BACKGROUND", "GameFontNormalLarge")
    title:SetJustifyH("LEFT")
    title:SetJustifyV("BOTTOM")
    title:SetText(GetAddOnMetadata(addonName, "Title"))
    title:SetPoint("TOPLEFT", 16, -16)

    local version = Options:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
    version:SetJustifyH("LEFT")
    version:SetJustifyV("BOTTOM")
    version:SetText("version " .. GetAddOnMetadata(addonName, "Version"))
    version:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 4, 2)

    local author = Options:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
    author:SetJustifyH("LEFT")
    author:SetJustifyV("BOTTOM")
    author:SetText("by " .. GetAddOnMetadata(addonName, "Author"))
    author:SetPoint("BOTTOMLEFT", version, "BOTTOMRIGHT", 4, 0)

    local desc = Options:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
    desc:SetJustifyH("LEFT")
    desc:SetJustifyV("BOTTOM")
    -- desc:SetTextColor(255, 255, 255, 1)
    desc:SetSize(wideWidth, 40)
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, 20)
    desc:SetText("An addon that notifies you when you have mail.")

    for k,v in pairs(items) do
        radioName = "ygmRadio" .. k
        yoffset = -50 - (k*20)
        local frame = CreateFrame("CheckButton", radioName, Options, "UIRadioButtonTemplate")
        frame:SetHeight(20)
        frame:SetWidth(20)
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", 50, yoffset)
        _G[frame:GetName() .. "Text"]:SetText(v)
        if k == YouGotMailOptions.voice then
            frame:SetChecked(true)
        else
            frame:SetChecked(false)
        end
        frame:SetScript("OnClick", function(self)
            UncheckAllRadios()
            self:SetChecked(true)
            ChangeTrack(k)
        end)
    end

    local playVoice = CreateFrame("Button", nil, Options, "UIPanelButtonTemplate")
    playVoice:SetWidth(175)
    playVoice:SetHeight(24)
    playVoice:SetPoint("BOTTOM", 0, 20)
    playVoice:SetText("Play Voice")
    playVoice:RegisterForClicks("AnyUp")
    playVoice:SetScript("OnClick", function()
        PlayNotification()
    end)

    -- Add the options panel to the Blizzard list
    InterfaceOptions_AddCategory(Options)
end


-----------------
-- Events
-----------------
local f = CreateFrame("Frame")

f:RegisterEvent("UPDATE_PENDING_MAIL")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent",
    function (self, event, arg1, ...)
        if event == "ADDON_LOADED" and arg1 == addonName then
            SLASH_YOUGOTMAIL1 = "/ygm"
            SlashCmdList["YOUGOTMAIL"] = SlashCommand
            Initialize()
            CreateOptionsPanel()
            Debug("YGM initialized.")
            self:UnregisterEvent("ADDON_LOADED")
            return
        end
        Debug("YGM: " .. event)
        CheckTheMail()
    end
)


-- Notes:
-- If a player already has been notified that they have mail, we do not
-- to spam them with notices. So we record the time at which they have
-- been notified, and then check that it's been at least an hour before
-- we notify them again.

-- The code that controls that behavior is
-- time() > YouGotMailOptions.time + 3600
