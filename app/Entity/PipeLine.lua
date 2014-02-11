--
-- Author: Your Name
-- Date: 2014-02-10 20:47:48
--

local PipeLine = class("PipeLine", function()
    return display.newNode()
end)

function PipeLine:ctor(bird, direction, index)
	local index_ = index or ""
	local direction_ = direction or "up"
	self.pipe = display.newSprite("pipe"..index_.."_"..direction_..".png")
	self:addChild(self.pipe)
	self.bird = bird
	self:scheduleUpdate(function ()
		local rectOne = self:getBirdBoundingBox()
		local rectTwo = self:getPipeBoundingBox()
   		if rectOne:intersectsRect(rectTwo) then	
   		end	
   	end)
end

function PipeLine:getBirdBoundingBox()
	local  parent = self.bird.bird_:getParent()
    local  pt = parent:convertToWorldSpace(ccp(self.bird.bird_:getPositionX(), self.bird.bird_:getPositionY()))
    self.rectBird = self.bird.bird_:getBoundingBox()
    self.rectBird.origin = ccpAdd(self.rectBird.origin, pt)
    self.rectBird.size = CCSizeMake(self.rectBird.size.width - 10, self.rectBird.size.height)
    return self.rectBird
end

function PipeLine:getPipeBoundingBox()
 	local  parent = self.pipe:getParent()
    local  pt = parent:convertToWorldSpace(ccp(self.pipe:getPositionX(), self.pipe:getPositionY()))
    self.rectPipe = self.pipe:getBoundingBox()
    self.rectPipe.origin = ccpAdd(self.rectPipe.origin, pt)
    self.rectPipe.size = CCSizeMake(self.rectPipe.size.width, self.rectPipe.size.height)
    return self.rectPipe
end

return PipeLine


