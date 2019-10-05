local frame = CreateFrame('Frame')
local frameSetCVar = CreateFrame('Frame')
local actionButtons = {}
local stanceButtons = {}
local protectedSkills = {}
local dismountTypes = {
    spell = true,
    item = true,
    companion = true,
    macro = false,
}

for i, spell in ipairs({
	---------------------------------------------------
	'Alchemy', 'Cooking', 'Enchanting', 'Engineering',
	'Blacksmithing', 'Tailoring', 'First Aid', 'Find Herbs',
	'Find Minerals', 'Shadowform', 'Battle Stance', 'Defensive Stance',
	'Berserker Stance'
	---------------------------------------------------
}) do
	local spellID = select(7, GetSpellInfo(spell))
	if spellID then
		protectedSkills[spellID] = spell
	end
end

for i, button in ipairs(StanceBarFrame.StanceButtons) do
	stanceButtons['SHAPESHIFTBUTTON' .. i] = button
end
 
for i=1, 12 do
	actionButtons['ACTIONBUTTON' .. i] = _G['ActionButton' .. i]
end
 
for i, button in ipairs(ActionBarButtonEventsFrame.frames) do
	local barID = button.buttonType
	local buttonID  = button:GetID()
	local identifier = buttonID and barID and ( barID .. buttonID )
	if identifier then
		actionButtons[identifier] = button
	end
end

local keyState = GetCVarBool("ActionButtonUseKeyDown")
 
frame:EnableKeyboard(true)
frame:SetPropagateKeyboardInput(true)
frame:SetScript('OnKeyDown', function(self, key, ...)	
	if IsMounted() then
        local prefix = SecureButton_GetModifierPrefix()
        local binding = GetBindingAction(prefix .. key)
      
		local button = actionButtons[binding]
        if button then
            local action = ActionButton_CalculateAction(button)
			
            if HasAction(action) then
                local actionType, spellID = GetActionInfo(action)
				
                if dismountTypes[actionType] and not protectedSkills[spellID] then
                    Dismount()
				elseif actionType == "macro" then
					spellID, _ = GetMacroSpell(spellID)
					if spellID ~= nil and not protectedSkills[spellID] then
						Dismount()
					end
				end
            end
			return
        end
 
        local button = stanceButtons[binding]
        if button and not button:GetChecked() then
			local actionType, spellID = GetActionInfo(action)
			
			if spellID ~= nil and not protectedSkills[spellID] then
				Dismount()
			end
        end
	end
end)

frameSetCVar:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
frameSetCVar:SetScript("OnEvent", function(self, event, ...)
	if IsMounted() then
		SetCVar("ActionButtonUseKeyDown", 0)
	elseif keyState then
		SetCVar("ActionButtonUseKeyDown", 1)
	end
end)

frame:RegisterEvent("UI_ERROR_MESSAGE")
frame:SetScript("OnEvent", function(self, event, messageType)
	local errorName = GetGameMessageInfo(messageType)

	if errorName == "ERR_SPELL_FAILED_S" or errorName == "ERR_ATTACK_MOUNTED" then
		Dismount()
		UIErrorsFrame:Clear()
	end
end)