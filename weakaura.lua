local AceAddon = LibStub("AceAddon-3.0")
local AceComm = LibStub("AceComm-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local MyAddon = AceAddon:NewAddon("MyAddon", "AceComm-3.0")

-- Initialisation de la base de données
local db = AceDB:New("MyAddonDB", {
    profile = {
        montext = ""
    }
})
local imagePaths = {
    "Interface\\AddOns\\Share\\Icons\\CBCat",
    "Interface\\AddOns\\Share\\Icons\\BabyCB",
    "Interface\\AddOns\\Share\\Icons\\",
    "Interface\\AddOns\\Share\\Icons\\CBhamster",
    "Interface\\AddOns\\Share\\Icons\\CBOSS117",
    -- Ajouter ici d'autres images
}
function MyAddon:OnInitialize()
    -- Enregistrement du préfixe pour les messages envoyés par l'addon
    self:RegisterComm("MyAddonChannel", "OnCommReceived")
    -- Création du bouton pour enregistrer le texte
    local button = CreateFrame("Button", "MonAddonButton", MyAddonMainFrame, "UIPanelButtonTemplate")
    button:SetSize(125, 40)
    button:SetPoint("TOP", MyAddonMainFrame, "TOP", 0, -100)
    button:SetText("Send")
    -- Modifiez la fonction du bouton "Send"
    button:SetScript("OnClick", function(self)
        local editBox = MonAddonEditBox
        local text = editBox:GetText()  -- Récupère le texte de la chatbox
    
        -- Vérifie si le texte n'est pas vide
        if text and text ~= "" then
            -- Stocke le texte dans la base de données (si besoin)
            db.profile.montext = text
    
            -- Envoie le texte saisi aux autres joueurs de l'addon via AceComm
            MyAddon:SendCommMessage("MyAddonChannel", text, "RAID")  -- Envoie le WeakAura saisi
    
            -- Envoie l'image à tout le monde
            MyAddon:SendImageToEveryone()
        end
    end)
    

    local editBox = CreateFrame("EditBox", "MonAddonEditBox", MyAddonMainFrame, "InputBoxTemplate")
    editBox:SetPoint("TOP", MyAddonMainFrame, "TOP", 0, -50)
    editBox:SetSize(200, 50)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(0)
    
    editBox:SetScript("OnEscapePressed", function()
        editBox:ClearFocus()
    end)
    
    editBox:SetScript("OnEnterPressed", function()
        editBox:ClearFocus()
        montext = editBox:GetText()
    end)
  end

  -- Ajoutez cette fonction pour envoyer l'image à tout le monde
function MyAddon:SendImageToEveryone()
    local imagePath = imagePaths[math.random(1, #imagePaths)]
    MyAddon:SendCommMessage("MyAddonChannel", "IMAGE:" .. imagePath, "GUILD")
end
  

-- PANNEAU OPTIONS
local MyAddonSettings = { ShowButton = true, disablePopup = false }

local optionsPanel = CreateFrame("Frame", "MyAddonOptionsPanel", UIParent)
optionsPanel.name = "Addon Share"
optionsPanel:SetSize(300, 200)
optionsPanel:SetPoint("CENTER")
optionsPanel:Hide()
optionsPanel:SetMovable(true)
optionsPanel:SetResizable(true)
optionsPanel:EnableMouse(true)
optionsPanel:RegisterForDrag("LeftButton")
optionsPanel:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    elseif button == "RightButton" then
        self:StartSizing()
    end
    optionsPanel:SetScript("OnMouseUp", function(self, button)
        self:StopMovingOrSizing()
    end)
end)

local background = optionsPanel:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(optionsPanel)
background:SetColorTexture(0, 0, 0, 1)

local border = optionsPanel:CreateTexture(nil, "BORDER")
border:SetAllPoints(optionsPanel)
border:SetColorTexture(1, 1, 1, 1)
border:SetTexture("Interface/Tooltips/UI-Tooltip-Border")

local optionsTitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
optionsTitle:SetPoint("TOPLEFT", 16, -16)
optionsTitle:SetText("Options - Addon Share")

local disablePopupCheckbox = CreateFrame("CheckButton", "MyAddonDisablePopupCheckbox", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
disablePopupCheckbox:SetPoint("TOPLEFT", optionsPanel, "TOPLEFT", 10, -40)
disablePopupCheckbox.text = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
disablePopupCheckbox.text:SetPoint("LEFT", disablePopupCheckbox, "RIGHT", 5, 0)
disablePopupCheckbox.text:SetText("Disable popup")

function disablePopupCheckbox:OnClick()
    MyAddonSettings.disablePopup = self:GetChecked()
end

disablePopupCheckbox:SetScript("OnClick", disablePopupCheckbox.OnClick)
optionsPanel.default = function() MyAddonSettings.disablePopup = false end
optionsPanel.okay = RefreshOptionsPanel
optionsPanel.cancel = RefreshOptionsPanel

local closeButton = CreateFrame("Button", nil, optionsPanel, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", optionsPanel, "TOPRIGHT", -5, -5)

-- Enregistrer le panneau d'options pour l'utiliser dans le menu des options du jeu

-- Créez le bouton d'options dans la Main Frame
local optionsButton = CreateFrame("Button", "MyAddonOptionsButton", MyAddonMainFrame, "UIPanelButtonTemplate")
optionsButton:SetSize(120, 35)
optionsButton:SetPoint("BOTTOMLEFT", MyAddonMainFrame, "BOTTOMLEFT", 15, 15)
optionsButton:SetText("Options")

local function ShowOptionsPanel()
    optionsPanel:Show()
end

optionsButton:SetScript("OnClick", ShowOptionsPanel)


-- FIN PANNEAU OPTIONS 

function MyAddon:OnCommReceived(prefix, message, distribution, sender)
    if prefix == "MyAddonChannel" then
        local success, err = pcall(function()
            WeakAuras.Import(message)  -- Essaye d'importer le WeakAura reçu
        end)

        if not success then
            print("Erreur lors de l'importation : " .. err)  -- Affiche l'erreur
        end
        if message:find("^IMAGE:") then
            local imagePath = message:sub(7) -- Extrait le chemin de l'image du message

            -- Vérifier si l'option de désactivation est activée
            local disablePopup = MyAddonSettings.disablePopup or false
            if not disablePopup then
                -- Afficher le popup avec l'image choisie
                local popup = AceGUI:Create("Frame")
                popup:SetTitle("|cffffffffA WeakAura was sent !|r")
                popup:SetWidth(700)
                popup:SetHeight(500)

                local texture = popup.frame:CreateTexture(nil, "ARTWORK")
                texture:SetTexture(imagePath)
                texture:SetSize(600, 400)
                texture:SetPoint("CENTER", popup.frame, "CENTER")

                popup:Show()
            end
        else
            -- Stocker le texte reçu dans la base de données
            db.profile.montext = message
        end
    end
end