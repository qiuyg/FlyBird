local Bird = import("..Entity.Bird")
local PipeLine = import("..Entity.PipeLine")

local GameScene = class("GameScene", function()
    return display.newScene("GameScene")
end)

function GameScene:ctor()
    cc.GameObject.extend(self)
    -- 绑定状态机组件
    self:addComponent("components.behavior.StateMachine")
    -- 由于状态机仅供内部使用，所以不应该调用组件的 exportMethods() 方法，改为用内部属性保存状态机组件对象
    self.fsm__ = self:getComponent("components.behavior.StateMachine")

    -- 设定状态机的默认事件
    local defaultEvents = {
        -- 初始化后，游戏处于 idle 状态
        {name = "start",  from = "none",    to = "idle" },
        -- 第一次点击后，游戏处于 game 状态
        {name = "first_tap", from = "idle", to = "game" },
        -- 撞到地面或则撞到柱子
        {name = "hit", from = "game", to = "end" }
    }
    -- 设定状态机的默认回调
    local defaultCallbacks = {
        onchangestate = handler(self, self.onChangeState_),
        onfirst_tap   = handler(self, self.onFirst_tap_),
        onhit         = handler(self, self.onHit_)
    }

    self.fsm__:setupState({
        events = defaultEvents,
        callbacks = defaultCallbacks
    })

    self.fsm__:doEvent("start") -- 启动状态机

    display.newSprite("res/bg_day.png", display.cx, display.cy)
        :addTo(self)

    -- touchLayer 用于接收触摸事件
    self.touchLayer = display.newLayer()
    self:addChild(self.touchLayer)

    self.touchLayer:setTouchEnabled(true)


    self.tutorial = display.newSprite("res/tutorial.png", display.cx, display.cy)
    self:addChild(self.tutorial)

    self.text_ready =  display.newSprite("res/text_ready.png", display.cx, display.cy + 100)
    self:addChild(self.text_ready)

    --越过的柱子数量
    self.passGateCount = 0

    self.LabelPassGateCount = CCLabelAtlas:create("0", "res/num_24_44.png", 24, 44, string.byte("0"))
    self.LabelPassGateCount:setAnchorPoint(ccp(0.5, 0.5))
    self.LabelPassGateCount:setPosition(ccp(display.cx, display.height - 60))
    self:addChild(self.LabelPassGateCount,20)

    self.land = display.newSprite("res/land.png", display.left, display.bottom)
    self.land:setAnchorPoint(ccp(0,0.3))
    self:addChild(self.land, 10)
    local size = self.land:getContentSize()
    self.land:runAction(CCRepeatForever:create(transition.sequence({
         CCMoveBy:create(0.5, ccp(display.width - size.width, 0)),
         CCCallFunc:create(function()
            --陆地回复初始位置
            self.land:setPosition(ccp(display.left, display.bottom))
         end)
    })))
    self.moveSpeed = (display.width - size.width) * 2
    
    print("speed:"..self.moveSpeed)

    self.flappyBird = Bird.new(self, 2)
    self:addChild(self.flappyBird)
    self.flappyBird:setPosition(ccp(display.cx - 50 , display.cy + 15))
end

function GameScene:hideTips()
    self.tutorial:runAction(CCFadeOut:create(0.3))
    self.text_ready:runAction(CCFadeOut:create(0.3))
end

function GameScene:onHit_(event)

end

function GameScene:onChangeState_(event)
   printf("state change from %s to %s", event.from, event.to)
end

function GameScene:onFirst_tap_(event)

end

function GameScene:onEnter()
    if device.platform == "android" then
        -- avoid unmeant back
        self:performWithDelay(function()
            -- keypad layer, for android
            local layer = display.newLayer()
            layer:addKeypadEventListener(function(event)
                if event == "back" then app.exit() end
            end)
            self:addChild(layer)

            layer:setKeypadEnabled(true)
        end, 0.5)
    end

    self.touchLayer:addTouchEventListener(function(event, x, y, prevX, prevY)
        if event == "began" then
            if self.fsm__:getState() == "idle" then
                self:hideTips()
                -- scheduler.performWithDelayGlobal(function()
                --     self:producePipeLine()
                -- end, 1.0)
                self.fsm__:doEvent("first_tap")
                self.flappyBird:setVy(4.0)
                self.flappyBird:resetAngle()
                --MainScene.flappyBird:setPosition(ccp(MainScene.flappyBird:getPositionX(), MainScene.flappyBird:getPositionY() + 80))
            elseif self.fsm__:getState() == "game" then
                self.flappyBird:setVy(4.0)
                self.flappyBird:resetAngle()
            elseif self.fsm__:getState() == "end" then 

            end
            -- return cc.TOUCH_BEGAN -- stop event dispatching
            return cc.TOUCH_BEGAN_NO_SWALLOWS -- continue event dispatching
        end
    end, cc.MULTI_TOUCHES_ON)
end

function GameScene:onExit()
end

function GameScene:producePipeLine()
    scheduler.scheduleGlobal(
        function()
            local diff = math.random(90)
           
            local pipeUp = PipeLine.new(MainScene.flappyBird, "up")
            pipeUp:setPosition(ccp(display.width + 60, display.bottom + 30 + diff))
            self:addChild(pipeUp)
            pipeUp:runAction(
                CCSequence:createWithTwoActions(
                    CCMoveBy:create(-400/self.moveSpeed, ccp(-400,0)),
                    CCRemoveSelf:create(true)))
    

            local pipeDown = PipeLine.new(MainScene.flappyBird, "down")
            pipeDown:setPosition(ccp(display.width + 60, display.top - 30 - diff))
            self:addChild(pipeDown)
            pipeDown:runAction(
                CCSequence:createWithTwoActions(
                                CCMoveBy:create(-400/self.moveSpeed, ccp(-400,0)),
                                CCRemoveSelf:create(true)))

            --collectgarbage("collect")
         end, -display.width/(2*self.moveSpeed))
end


return GameScene
