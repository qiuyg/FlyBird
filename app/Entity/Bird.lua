--
-- Author: Your Name
-- Date: 2014-02-10 17:01:42
--

local Bird = class("Bird", function()
    return display.newNode()
end)

function Bird:ctor(world,index)
	display.addSpriteFramesWithFile(BIRD_TEXTURE_DATA_FILENAME, BIRD_TEXTURE_IMAGE_FILENAME)
    local _index = index or 0
	local birdFrames = display.newFrames("bird".._index.."_%d.png", 0, 3)
    
    self.birdAnimation = display.newAnimation(birdFrames, 0.15)
    self.birdAnimation:retain()

    self.bird_ = display.newSprite(birdFrames[1])
    self.bird_:runAction(CCRepeatForever:create(
        CCSpawn:createWithTwoActions(transition.sequence({CCMoveBy:create(0.5 , ccp(0, 10)), 
                                                          CCMoveBy:create(0.4 , ccp(0, -10))}),
                                     CCRepeat:create(CCAnimate:create(self.birdAnimation), 2)
    )))
    self:addChild(self.bird_)

    self.land = world.land
    self.fsm  = world.fsm__

    self.angle = 0
    self.deltaAngle = 0
    self.r = 0.05

    self.vy = 0
    self.g = -0.15

    self.bird_:setAnchorPoint(ccp(0.7,0.5))

    self:scheduleUpdate(function()
    	if self.fsm:getState() == "game" then
    		-- 调整小鸟旋转角度
	    	if self.angle < 90 then
				  self.deltaAngle = self.deltaAngle + self.r * math.pow(1.2, 1 + self.r)
          self.angle = self.angle + self.deltaAngle 
				  self.bird_:setRotation(self.angle)
			  end

			  self.vy = self.vy + self.g
			  self:setPosition(ccp(self:getPositionX(), self:getPositionY() + self.vy))
   			if self.land:getBoundingBox():containsPoint(self:getBirdPos()) then
   				self:unscheduleUpdate()
   				self.bird_:stopAllActions()
   				self.land:stopAllActions()

          self.bird_:runAction(CCRotateTo:create(0.2, 90))
   			end
		  end
    end)
end

function Bird:setVy(vy)
    self.vy = vy
end

function Bird:resetAngle()
	self.angle = -45
  self.deltaAngle = 0
end

function Bird:getBirdPos()
  local  parent = self.bird_:getParent()
  local  pt = parent:convertToWorldSpace(ccp(self.bird_:getPositionX(), self.bird_:getPositionY()))
  return pt
end

-- function Bird:getBirdBoundingBox()
--  	local  parent = self.bird_:getParent()
--     local  pt = parent:convertToWorldSpace(ccp(self.bird_:getPositionX(), self.bird_:getPositionY()))
--     self.rectBird = self.bird_:getBoundingBox()
--     self.rectBird.origin = ccpAdd(self.rectBird.origin, ccp(pt.x + 4 , pt.y + 10))
--     self.rectBird.size = CCSizeMake(self.rectBird.size.width - 8, self.rectBird.size.height - 12)
--     return self.rectBird
-- end

function Bird:onExit()
    self.birdAnimation:release()
end

return Bird