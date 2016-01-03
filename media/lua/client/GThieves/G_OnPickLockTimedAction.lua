
require "TimedActions/ISBaseTimedAction"

G_OnPickLockTimedAction = ISBaseTimedAction:derive("G_OnPickLockTimedAction");

function G_OnPickLockTimedAction:isValid()
	return self.character:getInventory():contains("Paperclip") and self.character:getInventory():contains("Screwdriver")
end

function G_OnPickLockTimedAction:start()
	getSoundManager():PlayWorldSoundWav("gtv_picklock", self.object:getSquare(), 0, 7, 1, true);
end

function G_OnPickLockTimedAction:update()
	self.character:faceThisObject(self.object)
end

function G_OnPickLockTimedAction:stop()
	ISBaseTimedAction.stop(self)
end

function G_OnPickLockTimedAction:perform()
	
	local perkLvl = self.character:getPerkLevel(Perks.Lightfoot)

	self.character:getXp():AddXP(Perks.Lightfoot, 2);

	if perkLvl < 1 then
    	local pup = ZombRand(10);
    	if pup == 0 then
    		getSoundManager():PlayWorldSoundWav("PZ_MetalSnap", self.object:getSquare(), 0.5, 5, 1, true);
    		self.character:getInventory():RemoveOneOf("Paperclip")
    		ISBaseTimedAction.perform(self)
    		return
    	end
	end

	if perkLvl < 8 then
    	local pup = ZombRand(5);
    	if pup == 0 then
    		getSoundManager():PlayWorldSoundWav("PZ_MetalSnap", self.object:getSquare(), 0.5, 5, 1, true);
    		self.character:getInventory():RemoveOneOf("Paperclip")
    	end
	end

	self.object:setLockedByKey(false);
    getSoundManager():PlayWorldSound("unlockDoor", self.object:getSquare(), 0, 10, 0.7, true);
	
	ISBaseTimedAction.perform(self)
end

function G_OnPickLockTimedAction:new(character, object, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.stopOnWalk = true
	o.stopOnRun = true
	o.maxTime = time
	o.character = character;
	o.object = object
	return o
end