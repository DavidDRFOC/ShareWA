local addonPrefix = "ShareWA"
local addonVersion = "1.0.0" -- Version check
local checkInterval = 3600 

-- Fonction pour comparer les versions
local function CompareVersions(receivedVersion, currentVersion)
    local receivedMajor, receivedMinor, receivedPatch = strsplit(".", receivedVersion)
    local currentMajor, currentMinor, currentPatch = strsplit(".", currentVersion)

    receivedMajor, receivedMinor, receivedPatch = tonumber(receivedMajor), tonumber(receivedMinor), tonumber(receivedPatch)
    currentMajor, currentMinor, currentPatch = tonumber(currentMajor), tonumber(currentMinor), tonumber(currentPatch)

    if not (receivedMajor and receivedMinor and receivedPatch) or not (currentMajor and currentMinor and currentPatch) then
        return 0
    end

    -- Comparaison de version
    if receivedMajor > currentMajor then
        return 1
    elseif receivedMajor < currentMajor then
        return -1
    elseif receivedMinor > currentMinor then
        return 1
    elseif receivedMinor < currentMinor then
        return -1
    elseif receivedPatch > currentPatch then
        return 1
    elseif receivedPatch < currentPatch then
        return -1
    else
        return 0 -- Les versions sont identiques
    end
end

-- Fonction pour envoyer la version
local function SendAddonVersion()
    C_ChatInfo.SendAddonMessage(addonPrefix, addonVersion, "GUILD")
end

-- Fonction pour créer un popup
local function ShowPopup(receivedVersion)
    local popup = CreateFrame("Frame", "AddonUpdatePopup", UIParent, "BasicFrameTemplateWithInset")
    popup:SetSize(400, 200)
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 400)
    
    -- Titre du popup
    popup.title = popup:CreateFontString(nil, "OVERLAY")
    popup.title:SetFontObject("GameFontHighlight")
    popup.title:SetPoint("CENTER", popup.TitleBg, "CENTER", 0, 0)
    popup.title:SetText("Mise à jour nécessaire")

    -- Message du popup
    popup.text = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    popup.text:SetPoint("CENTER", 0, 0)
    popup.text:SetSize(150, 100)
    popup.text:SetText("Une version plus récente de ShareWA (" .. receivedVersion .. ") est disponible.")

    -- Bouton de fermeture
    local closeButton = CreateFrame("Button", nil, popup, "GameMenuButtonTemplate")
    closeButton:SetPoint("BOTTOM", 0, 10)
    closeButton:SetSize(120, 30)
    closeButton:SetText("Fermer")
    closeButton:SetNormalFontObject("GameFontNormalLarge")
    closeButton:SetHighlightFontObject("GameFontHighlightLarge")
    closeButton:SetScript("OnClick", function()
        popup:Hide()
    end)
end

-- Fonction de traitement des messages reçus
local function OnAddonMessage(prefix, receivedVersion, channel, sender)
    if prefix == addonPrefix and sender ~= UnitName("player") then
        local comparisonResult = CompareVersions(receivedVersion, addonVersion)
        if comparisonResult == 1 then
            ShowPopup(receivedVersion) -- Affiche le popup si la version est obsolète
        end
    end
end

-- Enregistrer l'événement de message d'addon
local function RegisterAddonMessageListener()
    C_ChatInfo.RegisterAddonMessagePrefix(addonPrefix)
    
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("CHAT_MSG_ADDON")
    eventFrame:SetScript("OnEvent", function(_, event, prefix, message, channel, sender)
        if event == "CHAT_MSG_ADDON" and prefix == addonPrefix then
            OnAddonMessage(prefix, message, channel, sender)
        end
    end)
end

-- Vérification régulière de la version
local function ScheduleVersionCheck()
    C_Timer.After(checkInterval, function()
        SendAddonVersion()
        ScheduleVersionCheck() -- Replanifier la vérification
    end)
end

-- Initialisation
local function InitVersionCheck()
    RegisterAddonMessageListener()
    SendAddonVersion() -- Envoyer la version au démarrage
    ScheduleVersionCheck() -- Planifier la vérification régulière
end

-- Lancement de l'initialisation au moment où l'addon est chargé
InitVersionCheck()
