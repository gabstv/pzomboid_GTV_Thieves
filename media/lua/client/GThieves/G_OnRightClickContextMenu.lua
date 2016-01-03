require "GThieves/G_OnDismantleTimedAction"
require "GThieves/G_OnPickLockTimedAction"

G_OnRightClickContextMenu = {};

G_OnRightClickContextMenu.doMenu = function(player, context, worldobjects)

	for i,v in ipairs(worldobjects) do

		local checkObject = nil;

		local ojects = v:getSquare():getObjects();

		if ojects:size() > 0 then

			for i2=0, ojects:size()-1 do

				checkObject = v:getSquare():getObjects():get(i2);
				
				local spr = checkObject:getSprite();
				local sprn = spr:getName();

				if string.find(sprn, "appliances_telev") then -- appliances_television
					G_OnRightClickContextMenu._ctxa_Dismantle(context, checkObject, player, "tv")
				elseif string.find(sprn, "appliances_laundry") then
					G_OnRightClickContextMenu._ctxa_Dismantle(context, checkObject, player, "laundry")
				elseif string.find(sprn, "location_shop_accessories_01") then
					G_OnRightClickContextMenu._ctxa_Dismantle(context, checkObject, player, "cashreg")
				elseif instanceof(checkObject, "IsoDoor") or (instanceof(checkObject, "IsoThumpable") and v:isDoor()) then
					G_OnRightClickContextMenu._ctxa_PickLock(context, checkObject, player)
				end

			end
		end
	end
	
end

G_OnRightClickContextMenu.onDismantleObject = function(object, player, kind)
	local playerObj = getSpecificPlayer(player);

	if luautils.walkToObject(playerObj, object, false) then
		ISTimedActionQueue.add(G_OnDismantleTimedAction:new(playerObj, object, kind));
	end
end

G_OnRightClickContextMenu.onPickLock = function(object, player)
	local playerObj = getSpecificPlayer(player);

	local perkLvl = playerObj:getPerkLevel(Perks.Lightfoot)

	if luautils.walkAdj(playerObj, object:getSquare()) then
		local time0 = 350 - 300 * (perkLvl / 10)
		if playerObj:getDescriptor():getProfession() == "burglar" and time0 > 80 then
			time0 = 80
		end
		ISTimedActionQueue.add(G_OnPickLockTimedAction:new(playerObj, object, time0));
	end
end

G_OnRightClickContextMenu._ctxa_Dismantle = function(context, object, playerId, kind)
	
	local label = "Hardware"
	
	if kind == "laundry" then
		label = "Laundry Machine"
	elseif kind == "tv" then
		label = "TV"
	elseif kind == "cashreg" then
		label = "Cash Register"
	end

	local addedOption = context:addOption("Dismantle " .. label, object, G_OnRightClickContextMenu.onDismantleObject, playerId, kind);
	if addedOption and not getSpecificPlayer(playerId):getInventory():contains("Screwdriver") then
		addedOption.onSelect = nil;
		addedOption.notAvailable = true;
	end
end

G_OnRightClickContextMenu._ctxa_PickLock = function(context, object, playerId)

	local doorKeyId = nil

	if instanceof(object, "IsoDoor") then
		doorKeyId = object:checkKeyId()
		if doorKeyId == -1 then doorKeyId = nil end
	elseif instanceof(v, "IsoThumpable") then
		doorKeyId = object:getKeyId()
	end

	if doorKeyId == nil then return end

	local character = getSpecificPlayer(playerId)

	if not object:IsOpen() and not character:getInventory():haveThisKeyId(doorKeyId) and object:isLocked() then
		-- player doesn't have a key
		local addedOption = context:addOption("Pick Lock", object, G_OnRightClickContextMenu.onPickLock, playerId);
		if not character:getDescriptor():getProfession() == "burglar" and not character:getKnownRecipes():contains("PickLock") then
			addedOption.onSelect = nil;
			addedOption.notAvailable = true;
		end
		if not character:getInventory():contains("Paperclip") or not character:getInventory():contains("Screwdriver") then
			addedOption.onSelect = nil;
			addedOption.notAvailable = true;
		end
	end

end

Events.OnFillWorldObjectContextMenu.Add(G_OnRightClickContextMenu.doMenu);