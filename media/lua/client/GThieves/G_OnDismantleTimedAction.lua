
require "TimedActions/ISBaseTimedAction"

G_OnDismantleTimedAction = ISBaseTimedAction:derive("G_OnDismantleTimedAction");

function G_OnDismantleTimedAction:isValid()
	return self.character:getInventory():contains("Screwdriver")
end

function G_OnDismantleTimedAction:start()
	if self.maxTime < 201 then
		getSoundManager():PlayWorldSoundWav("gtv_dismantle_fast", self.object:getSquare(), 0, 11, 1, true);
	else
		getSoundManager():PlayWorldSoundWav("gtv_dismantle", self.object:getSquare(), 0, 11, 1, true);
	end
end

function G_OnDismantleTimedAction:update()
	self.character:faceThisObject(self.object)
end

function G_OnDismantleTimedAction:stop()
	ISBaseTimedAction.stop(self)
end

function G_OnDismantleTimedAction:perform()

	if self.kind == "tv" then
		self:dotv();
	elseif self.kind == "laundry" then
		self:dolaundry();
	elseif self.kind == "cashreg" then
		self:docashreg();
	end
	
	self:destroyObj();
	ISBaseTimedAction.perform(self)
end

function G_OnDismantleTimedAction:docashreg()
	local perkLvl = self.character:getPerkLevel(Perks.Electricity)

	self.character:getInventory():AddItem("Base.Screws");
	self.character:getXp():AddXP(Perks.Electricity, 2);

	if ZombRand(6) == 0 then
		self.character:getXp():AddXP(Perks.Electricity, 4);
	end

	if ZombRand(4) == 0 or perkLvl > 5 then
		self.character:getInventory():AddItem("Base.ElectronicsScrap");
	end

	if ZombRand(12) == 0 or perkLvl > 8 then
		self.character:getInventory():AddItem("Base.ScrapMetal");
	end
end

function G_OnDismantleTimedAction:dotv()
	local perkLvl = self.character:getPerkLevel(Perks.Electricity)

	self.character:getInventory():AddItem("Base.Screws");
	self.character:getXp():AddXP(Perks.Electricity, 2);

	if perkLvl < 1 then
		--self.character:Say("I'm not sure I can do this correctly!");
		local pup = ZombRand(3);
    	if pup == 0 then
    		self.character:getInventory():AddItem("Base.ElectronicsScrap");
    	else
    		-- learn from mistakes
    		self.character:getXp():AddXP(Perks.Electricity, 3);
    		-- name, origin, pitchv, radius, maxgain, ignoreoutside
    		getSoundManager():PlayWorldSound("breakdoor", self.object:getSquare(), 0.5, 7, 1, true);
    	end
    	return;
	end
	self.character:getXp():AddXP(Perks.Electricity, 1);

	self.character:getInventory():AddItem("Base.Screws");
	self.character:getInventory():AddItem("Base.ElectronicsScrap");

	if perkLvl > 1 and ZombRand(4) == 0 then
		self.character:getInventory():AddItem("Base.ElectronicsScrap");
	end

	if perkLvl > 3 and ZombRand(3) == 0 then
		self.character:getInventory():AddItem("Base.ElectronicsScrap");
	end

	if perkLvl > 5 and ZombRand(2) == 0 then
		self.character:getInventory():AddItem("Base.ElectronicsScrap");
	end

	if perkLvl > 7 and ZombRand(2) == 0 then
		self.character:getInventory():AddItem("Base.Amplifier");
	end
end

function G_OnDismantleTimedAction:dolaundry()
	local electricityLvl = self.character:getPerkLevel(Perks.Electricity);
	--local carpentryLvl = self.character:getPerkLevel(Perks.Woodwork);

	self.character:getInventory():AddItem("Base.Screws");
	self.character:getXp():AddXP(Perks.Electricity, 2);

	if electricityLvl < 1 then

		local pup = ZombRand(3);
    	if pup == 0 then
    		self.character:getInventory():AddItem("Base.ScrapMetal");
    		self.character:getXp():AddXP(Perks.Electricity, 2);
    	else
    		-- learn from mistakes
    		self.character:getXp():AddXP(Perks.Electricity, 6);
    		getSoundManager():PlayWorldSound("breakdoor", self.object:getSquare(), 0.2, 15, 1, true);
    	end
    	return;
	end

	if electricityLvl > 2 then
		self.character:getInventory():AddItem("Base.ElectronicsScrap");
	end

	self.character:getXp():AddXP(Perks.Electricity, 1);

	self.character:getInventory():AddItem("Base.Screws");
	self.character:getInventory():AddItem("Base.ScrapMetal");


	if electricityLvl > 3 then
		self.character:getInventory():AddItem("Base.RubberBand");
	end

	local rz = ZombRand(5);
	if rz == 0 then
		self.character:getInventory():AddItem("Base.ElectricWire");
	end

	rz = ZombRand(100);
	if rz == 0 then
		self.character:getInventory():AddItem("Base.DeadMouse");
	end

end

function G_OnDismantleTimedAction:new(character, object, kind)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.stopOnWalk = true
	o.stopOnRun = true
	o.maxTime = 200
	o.character = character;
	o.object = object
	o.kind = kind

	if kind == "tv" then
		o.maxTime = 300
	elseif kind == "laundry" then
		o.maxTime = 500
	end

	if character:HasTrait("Handy") then
		o.maxTime = o.maxTime / 2;
	end

	return o
end

function G_OnDismantleTimedAction:destroyObj()
	if isClient() then
		sledgeDestroy(self.object);
	else
		self.object:getSquare():transmitRemoveItemFromSquare(self.object)
		self.object:getSquare():RemoveTileObject(self.object)
	end
end