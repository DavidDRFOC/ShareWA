local LibStub = _G.LibStub
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0")
local ComeBack = AceAddon:NewAddon("ComeBackMinimap", "AceConsole-3.0")

local dbDefaults = {
    profile = {
        minimap = {
            hide = false,
        },
    },
}

-- Fonction pour centrer la bossFrame
local function CenterBossFrame()
    MyAddonBossFrame:ClearAllPoints()
    MyAddonBossFrame:SetPoint("CENTER")
end

local ComeBackLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Share", {
    type = "data source",
    text = "Share",
    icon = "Interface\\AddOns\\Share\\Icons\\Share",
    OnClick = function(_, button)
        if button == "LeftButton" then
            if MyAddonMainFrame:IsVisible() then
                MyAddonMainFrame:Hide()
            else
                MyAddonMainFrame:Show()
            end
        elseif button == "RightButton" then
            if MyAddonBossFrame:IsVisible() then
                MyAddonBossFrame:Hide()
            else
                CenterBossFrame() -- Ajoutez cette ligne pour centrer la bossFrame avant de l'afficher
                MyAddonBossFrame:Show()
            end
        end
    end,
})




ComeBackLDB.OnEnter = function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:SetText("Share\r|cffffffffLeftClick:|r Open/Hide frame\r|cffffffffRightClick:|r Open boss infos")
    GameTooltip:Show()
end

ComeBackLDB.OnLeave = function(self)
    GameTooltip:Hide()
end

function ComeBack:OnInitialize()
    self.db = AceDB:New("ComeBackDB", dbDefaults)
    LibDBIcon:Register("Share", ComeBackLDB, {minimapPos = 160})
    LibDBIcon:Show("Share")
end
