local dashingDismount = CreateFrame("Frame")
dashingDismount:RegisterEvent("UI_ERROR_MESSAGE")
dashingDismount:SetScript("OnEvent", function(self, event, messageType)
	local errorName = GetGameMessageInfo(messageType)
	
	print(errorName)
	
	if errorName == "ERR_SPELL_FAILED_S" or errorName == "ERR_ATTACK_MOUNTED" then
		Dismount()
	end
end)