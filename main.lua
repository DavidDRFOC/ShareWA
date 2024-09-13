local WeakAuras=WeakAuras
local LibStub = LibStub

-- Créer la fenêtre principale
local frame = CreateFrame("Frame", "MyAddonMainFrame", UIParent)
frame:SetSize(600, 500)
frame:SetPoint("CENTER")

-- Initialiser la variable globale MessageShown
if not MessageShown then
  MessageShown = false
end

-- Afficher un message lorsque l'utilisateur ouvre la fenêtre principale pour la première fois
local function OnMainFrameShow()
  if not MessageShown then
    MessageShown = true
    print("Share your WeakAura's to your guild")
  end
end

-- Enregistrer la fonction OnMainFrameShow en tant que gestionnaire d'événements pour l'événement OnShow de la fenêtre principale
frame:SetScript("OnShow", OnMainFrameShow)

-- Masquer la fenêtre principale lors de la connexion du joueur
local function OnPlayerLogin()
  if not MessageShown then
    frame:Hide()
  end
end

-- Ajout d'un script OnUpdate pour contrôler la taille minimale
local minWidth, minHeight = 400, 300
frame:SetScript("OnUpdate", function(self)
    local width, height = self:GetSize()

    if width < minWidth or height < minHeight then
        local newWidth = math.max(width, minWidth)
        local newHeight = math.max(height, minHeight)
        self:SetSize(newWidth, newHeight)
    end
end)

-- Enregistrer la fonction OnPlayerLogin en tant que gestionnaire d'événements pour l'événement PLAYER_LOGIN
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", OnPlayerLogin)

-- Création de la texture pour l'image
local logoTexture = MyAddonMainFrame:CreateTexture(nil, "ARTWORK")
logoTexture:SetTexture("Interface\\AddOns\\Share\\Icons\\Share") -- Chemin vers le fichier image
logoTexture:SetSize(80, 80)
logoTexture:SetPoint("TOPRIGHT", MyAddonMainFrame, "TOPRIGHT")

-- Création de la frame vide pour les informations du boss
local bossFrame = CreateFrame("Frame", "MyAddonBossFrame", nil, "BasicFrameTemplateWithInset")
bossFrame:SetSize(600, 400)
bossFrame:SetPoint("TOPLEFT", MyAddonMainFrame, "TOPLEFT")

-- Ajout d'un arrière-plan à la frame du boss
local bossFrameBg = bossFrame:CreateTexture(nil, "BACKGROUND")
bossFrameBg:SetAllPoints(bossFrame)
bossFrameBg:SetColorTexture(0, 0, 0, 1) -- Vous pouvez ajuster les valeurs RGBA (0 à 1) selon vos préférences

bossFrame:Hide()

bossFrame:SetMovable(true)
bossFrame:EnableMouse(true)
bossFrame:SetResizable(true)
bossFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    elseif button == "RightButton" then
        self:StartSizing()
    end
end)

bossFrame:SetScript("OnMouseUp", function(self, button)
    self:StopMovingOrSizing()
end)

-- Ajout d'un script OnUpdate pour contrôler la taille minimale
local minWidth, minHeight = 400, 300
bossFrame:SetScript("OnUpdate", function(self)
    local width, height = self:GetSize()

    if width < minWidth or height < minHeight then
        local newWidth = math.max(width, minWidth)
        local newHeight = math.max(height, minHeight)
        self:SetSize(newWidth, newHeight)
    end
end)

-- Création d'un bouton pour ouvrir la frame du boss
local bossButton = CreateFrame("Button", "MyAddonBossButton", MyAddonMainFrame, "UIPanelButtonTemplate")
bossButton:SetSize(120, 35)
bossButton:SetPoint("TOPLEFT", MyAddonMainFrame, "TOPLEFT", 15, -15)
bossButton:SetText("How to use")

-- Gestionnaire d'événement pour afficher/fermer la frame du boss
bossButton:SetScript("OnClick", function()
    bossFrame:SetPoint("BOTTOMLEFT", MyAddonMainFrame, "BOTTOMRIGHT") -- Ajoute le cadre sur la gauche de la main frame
    if bossFrame:IsShown() then
        bossFrame:Hide()
    else
        bossFrame:Show()
    end
end)

-- Ajustement du bouton de fermeture de la fenêtre principale
local closeButton = CreateFrame("Button", "MyAddonCloseButton", frame, "UIPanelButtonTemplate")
closeButton:SetSize(80, 22)
closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -105, 15) -- Positionner à droite du bouton de rechargement
closeButton:SetText("Close")
closeButton:SetScript("OnClick", function()
    frame:Hide()
end)

-- Ajustement du bouton pour recharger l'UI
local mainReloadUIButton = CreateFrame("Button", "MyAddonMainReloadUIButton", frame, "UIPanelButtonTemplate")
mainReloadUIButton:SetSize(100, 22)
mainReloadUIButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15) -- Positionner à gauche du bouton de fermeture
mainReloadUIButton:SetText("Reload UI")
mainReloadUIButton:SetScript("OnClick", function()
    ReloadUI()
end)

-- WEAKAURAS
function CBwa()
    local Maweakaura = ""
    WeakAuras.Import(Maweakaura)
end

-- Ajout d'un bouton pour afficher l'URL externe (wago.io) au centre de l'interface principale
local showURLButton = CreateFrame("Button", "MyAddonShowURLButton", frame, "UIPanelButtonTemplate")
showURLButton:SetSize(350, 40)
showURLButton:SetPoint("CENTER")
showURLButton:SetText("Share WeakAura")
showURLButton:SetScript("OnClick", CBwa)

frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetResizable(true)
frame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    elseif button == "RightButton" then
        self:StartSizing()
    end
end)

frame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" or button == "RightButton" then
        self:StopMovingOrSizing()
    end
end)

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetPoint("TOP", showURLButton, "BOTTOM", 0, 65) -- Modifier cette ligne pour ancrer le texte au bouton
text:SetSize(0, 20)
text:SetText("General WeakAura's")

local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
bg:SetPoint("TOPLEFT")
bg:SetPoint("BOTTOMRIGHT")
bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")

local title = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
title:SetPoint("TOP", 0, -15)
title:SetText("Share WeakAura")

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", OnEvent)

SlashCmdList["Share"] = function(msg)
    frame:Show()
end
SLASH_COMEBACK1 = "/share"
