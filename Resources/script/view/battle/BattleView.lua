require("view.BaseView")
require("view.battle.BattleFieldView")
require("view.battle.BattleCardView")
require("view.battle.BattleWallView")
require("view.battle.BattleBossInfoView")
require("view.battle.BattleResultView")
require("model.battle.Battle")
require("view.guide.GuideBattleView")
require("view.guide.TroopIntroductionView") 
require("view.skill_range.SkillRangeInfoView") 
require("view.component.MiddleCardHeadView")
require("view.arena.ArenaEnterEffectAnimation")
require("view.battle.BattleDamageCountView")

BattleView = class("BattleView", BaseView)

local function performWithDelay(node, callback, delay)
  local delay = CCDelayTime:create(delay)
  local callfunc = CCCallFunc:create(callback)
  local sequence = CCSequence:createWithTwoActions(delay, callfunc)
  node:runAction(sequence)
  return sequence
end

function BattleView:ctor(isLocalFight,isLocalPlay)
  self._touchEnabled = false
  self._posChangePreview = false
  self._isLocalFight = isLocalFight
  self._isLocalPlay = isLocalPlay
  self:setNodeEventEnabled(true)

  self._cardsView = {}
  self._fieldView = {}
  self._wallsView = {}
  
  self:setEnabledCardEnterEffect(true)
  self:setTouchEnabled(true)
  self._touchEnabled = true
  if isLocalFight == true then
     self._touchEnabled = false
  end
  self.isLocked = false
  self._targetGuidePos = 0
  self._timeLeft = 30
  self:addTouchEventListener(handler(self,self.onTouch))
  
end

function BattleView:resetView()
  self:setScale(1.0)
  self:setPosition(ccp(0,0))
  
  self:setLastCardView(nil)
  self._cardsView = {}
  self._fieldView = {}
  self._wallsView = {}
  self._battleResultView = nil
  self._effectEnterNode = nil
  self._lableSkipNode = nil
  self._lastMoveCardView = nil
  self._skillRangeInfo = nil
  self._btnCancel = nil
  self._startBtn = nil
  self:removeTimeCountDown()
  self:removeSkipButton()
  self:removeGreySkipButton()
  self:removeBattleAnimation()
  self:removeAllChildrenWithCleanup(true)
  
  
end

function BattleView:resetToTouch()
  self._touchEnabled = true
end

------
--  Getter & Setter for
--      BattleView._BattleData 
-----
function BattleView:setBattleData(BattleData)
	self._BattleData = BattleData
end

function BattleView:getBattleData()
	return self._BattleData
end

function BattleView:setupView(battle)
  self:stopAllActions()
  -- play bgm
  _playBgm(BGM_BATTLE_FAST)
  
  
  -- battle field

  self:setupBg(battle)
  self:setBattleData(battle)

  -- init position
  self._positions = {}
  local paddingX = (BattleConfig.BattleFieldWidth - BattleConfig.BattleFieldLen * BattleConfig.BattleFieldCol ) / (BattleConfig.BattleFieldCol - 1)
  local validRow = BattleConfig.BattleFieldRow - BattleConfig.BattleFieldWallCols * 2 -- the rows of the main battle fields without walls
  local paddingY = (BattleConfig.BattleFieldHeight - BattleConfig.BattleFieldLen * validRow ) / validRow
  printf("validRow:%d,paddingX:%f,paddingY:%f",validRow,paddingX,paddingY)
  local orinPos = ccp(display.cx,display.cy)
  orinPos.x = orinPos.x - paddingX * 0.5 - BattleConfig.BattleFieldLen * BattleConfig.BattleFieldCol * 0.5 - paddingX * (BattleConfig.BattleFieldCol * 0.5 - 1)
  orinPos.y = orinPos.y - validRow * 0.5 * (BattleConfig.BattleFieldLen + paddingY)
  orinPos.x = orinPos.x + (BattleConfig.BattleFieldLen) * 0.5
  orinPos.y = orinPos.y + (BattleConfig.BattleFieldLen) * 0.5
  for i=0, BattleConfig.BattleFieldCount - 1 do
    self._positions[i] = ccp(0,0)
  end
  local wallHeight = BattleConfig.BattleFieldWallLength/BattleConfig.BattleFieldRow
  for i = BattleConfig.BattleFieldBegin + BattleConfig.BattleFieldWallLength, BattleConfig.BattleFieldEnd - BattleConfig.BattleFieldWallLength - 1 do
    local index = i - BattleConfig.BattleFieldWallLength
    local row = math.floor(index/BattleConfig.BattleFieldCol)
    local col = index % BattleConfig.BattleFieldCol
    local pos = ccp(orinPos.x + BattleConfig.BattleFieldLen * col + paddingX * col,orinPos.y + BattleConfig.BattleFieldLen * row + paddingY * row)
    if row >= validRow * 0.5 then
      -- at the centre point,you should set the gap size
      pos.y = pos.y + 24
    end
    self._positions[i] = pos
    printf("pos[%d][index = %d,row = %d,col = %d,x = %f,y = %f]",i,index,row,col,pos.x,pos.y)
  end
  -- setup fields
  self:setupFields(battle)
  self:setupCard(battle)
  self:setupRoundBanner()
  --self:setupDropBanner()
  local  onExitBattleHandler = function(pSender)
      if battle:getFightType() == "PVE_NORMAL" then
         self:getDelegate():goToScenario()
      elseif battle:getFightType() == "PVE_ACTIVITY" then
         self:getDelegate():goToActivityStage()
      elseif battle:getFightType() == "PVP_NORMAL" then
         self:getDelegate():goToExpedition()
      elseif battle:getFightType() == "PVE_BOSS" then
         self:getDelegate():goToActivity()
      elseif battle:getFightType() == "PVP_REAL_TIME" then 
         self:getDelegate():goToArena()
      elseif battle:getFightType() == "PVE_GUILD" then 
         self:getDelegate():goToGuild()
      elseif battle:getFightType() == "PVE_BABLE" then 
         self:getDelegate():goToBable()
      end
  end
  
  local  onStartBattleHandler = function(pSender)
    self:onStartBattle(battle)
  end
  
  if self._isLocalPlay == true or battle:getIsPlayingReview() == true then
     self:onStartBattle(battle)
  end

  if self._isLocalFight == false and self._touchEnabled == true then
		  self._skillRangeInfo = nil
      --self._startBtn = UIHelper.normalBtn("Ok",ccp(display.cx,display.cy),function()
      
      local menuItem = UIHelper.ccMenuItemImageWithSprite(_res(3059020),_res(3059021),nil,onStartBattleHandler)
      self._startBtn = CCMenu:createWithItem(menuItem)  
      self._startBtn:setPosition(display.cx, 65)
      self:addChild(self._startBtn)
      self._startBtn:setZOrder(1999)
      
      if self._enabledCardEnterEffect == true or self._enabledCardEnterEffect == nil then
        self._startBtn:setVisible(false)
      end
      
      _registNewBirdComponent(105001,menuItem)
      
      self._backBtn =  UIHelper.ccMenuWithSprite(_res(3059016),_res(3059017),_res(3059017),onExitBattleHandler)
      self._backBtn:setPosition(display.size.width -100 , 60)
      --_backBtn:setPosition(display.cx ,display.cy)
      self:addChild(self._backBtn)
      self._backBtn:setZOrder(1998)
      self._backBtn:setVisible(false)   
      if battle:getFightType() == "PVE_NORMAL" 
      or battle:getFightType() == "PVE_ACTIVITY" 
      or battle:getFightType() == "PVE_GUILD" 
      or battle:getFightType() == "PVE_BABLE" 
      then
         self._backBtn:setVisible(true)
      elseif battle:getFightType() == "PVP_NORMAL" 
      or battle:getFightType() == "PVP_REAL_TIME"
      or battle:getFightType() == "PVP_RANK_MATCH" then
          local countLabeltop = ui.newTTFLabelWithOutline( {
                                          text = _tr("start_battle_time_left"),
                                          font = "Courier-Bold",
                                          size = 24,
                                          x = 0,
                                          y = 0,
                                          color = ccc3(255, 255, 255),
                                          align = ui.TEXT_ALIGN_CENTER,
                                          --valign = ui.TEXT_VALIGN_TOP,
                                          --dimensions = CCSize(200, 30),
                                          outlineColor =ccc3(0,0,0),
                                          pixel = 2
                                          }
                                        )
          GameData:Instance():getCurrentScene():addChildView(countLabeltop,3000)
          local offsetY = 0
          if battle:getFightType() == "PVP_REAL_TIME" then
            offsetY = display.cy - 45
      			self._startBtn:setVisible(false)
      			performWithDelay(self,function()
      				if(self._startBtn) then
      					self._startBtn:setVisible(true)
      				end
      			end,5)
          end
          
          countLabeltop:setPosition(display.width/2,display.height - (25 + offsetY))
          countLabeltop:setVisible(false)
          self._countLabeltop = countLabeltop
          
          local countLabel = ui.newTTFLabelWithOutline( {
                                          text = _tr("%{second}sceondleft", {second = self._timeLeft}),
                                          font = "Courier-Bold",
                                          size = 30,
                                          x = 0,
                                          y = 0,
                                          color = ccc3(0, 255, 48),
                                          align = ui.TEXT_ALIGN_CENTER,
                                          --valign = ui.TEXT_VALIGN_TOP,
                                          --dimensions = CCSize(200, 30),
                                          outlineColor =ccc3(0,0,0),
                                          pixel = 2
                                          }
                                        )
          GameData:Instance():getCurrentScene():addChildView(countLabel,3000)
          countLabel:setPosition(display.width/2,display.height - (65 + offsetY))
          --countLabel:setVisible(false)
          self._countLabel = countLabel
          
          self:startTimeCountDown()
--          if battle:getFightType() ~= "PVP_REAL_TIME" then
--            self:startTimeCountDown()
--          end
      end
      
      self._skillRangeInfo = SkillRangeInfoView.new(battle:getFightType(),self)
      --self._skillRangeInfo:setDelegate(self)
      self._skillRangeInfo:setPositionY(120)
      self:addChild(self._skillRangeInfo,1000)
      if self._enabledCardEnterEffect == true or self._enabledCardEnterEffect == nil then
        self._startBtn:setVisible(false)
      end

  else
     --if battle:getFightType() == "PVE_NORMAL" then
        if self._sptCount ~= nil then
           self._sptCount:setVisible(true)
        end
        
        if self._sptIcon ~= nil then
           self._sptIcon:setVisible(true)
        end
        
        if self._backBtn ~= nil then
           self:removeChild(self._backBtn,true)
           self._backBtn = nil 
        end 
     --end
     
     self:removeTimeCountDown()
     
     if self._isLocalPlay == true then
       CCDirector:sharedDirector():getScheduler():setTimeScale(CONFIG_BATTLE_SPEED_RATIO)
     else
       self:createSwitchSpeedButton()
     end
     
     local vipLevelId = 1
     if self._isLocalFight == false then
       vipLevelId = GameData:Instance():getCurrentPlayer():getVipLevelId() 
     end
     if self._isLocalPlay == true
     or self._isLocalFight == true
     or BATTLE_SKIP_ENABLED > 0 
     or battle:getIsPlayingReview() == true
     --or (battle:getFightType() == "PVE_NORMAL" and AllConfig.vipinitdata[vipLevelId].pve_skip_free > 0)
     or (battle:getFightType() == "PVP_NORMAL" and AllConfig.vipinitdata[vipLevelId].pvp_skip_free > 0)
     or (battle:getFightType() == "PVE_NORMAL" and self:getBattleData():getStage():getIsPassed() == true)
     or (battle:getFightType() == "PVE_BOSS"   and AllConfig.vipinitdata[vipLevelId].Boss_skip_free > 0)
     or (battle:getFightType() == "PVE_ACTIVITY" and AllConfig.vipinitdata[vipLevelId].pve_activity_skip_free > 0)
     or (battle:getFightType() == "PVE_GUILD" and AllConfig.vipinitdata[vipLevelId].pve_activity_skip_free > 0)
     or (battle:getFightType() == "PVP_NORMAL" and GameData:Instance():getLanguageType() == LanguageType.JPN)
     or (battle:getFightType() == "PVE_ACTIVITY" and GameData:Instance():getLanguageType() == LanguageType.JPN)
     or (battle:getFightType() == "PVE_BOSS" and GameData:Instance():getLanguageType() == LanguageType.JPN and GameData:Instance():getCurrentPlayer():getLevel() >= 35)
     then
       self:showSkipButton(0.01)
     else
       if battle:getFightType() ~= "PVP_REAL_TIME" 
       and battle:getFightType() ~= "PVP_RANK_MATCH"
       and battle:getFightType() ~= "PVE_BABLE" then
        local autoSkipWait = 0
        if battle:getFightType() == "PVP_NORMAL" then
          autoSkipWait = 20
        end
        self:showGreySkipButton(autoSkipWait)
        
--        if battle:getFightType() == "PVP_NORMAL" then
--          local timeLong = 30
--          local timeLabel = CCLabelBMFont:create(timeLong.."", "client/widget/words/card_name/number_skillup.fnt")
--          self:addChild(timeLabel,2000)
--          timeLabel:setPosition(self._btnCancelGrey:getPositionX() + 58,self._btnCancelGrey:getPositionY() - 15)
--          local timerCount = function()
--            timeLong = timeLong - 1
--            if timeLong < 0 then
--              timeLong = 0
--            end
--            timeLabel:setString(timeLong.."")
--          end
--          
--          local timer = self:schedule(timerCount,1.0)
--          self:performWithDelay(function()
--            self:unschedule(timer)
--            timeLabel:removeFromParentAndCleanup(true)
--            self:showSkipButton(0.01)
--          end,timeLong)
--        end
       end
     end
    
      
      -- battle wall
      self:setupWall(battle)
      if battle:getIsBossBattle() == true then
        self:setupBoss(battle)
      end
    end
    
    -- tips
    self._troopIntroductionView = TroopIntroductionView.new(self)
    self:addChild(self._troopIntroductionView,7)
    
    if self._touchEnabled == false then
      self:setAnchorPoint(ccp(0.5,0.5))
      self:setPosition(0,0)
      --self:setScale(1.25)
    end
    
end

function BattleView:cameraReset()
  if BATTLE_CAMERA_FOLLOW <= 0 then
      return
  end

  local duration = 1.0
  local stayDuration = 1.25 
  local scaleDuration = duration * 0.35 
  local scaleBackDuration = duration * 0.5
   --zoom out
  local zoomOutArray = CCArray:create()
  local scaleBack = CCEaseSineOut:create(CCScaleTo:create(scaleBackDuration,1.0))
  local moveBack = CCEaseSineOut:create(CCMoveTo:create(scaleBackDuration,ccp(0,0)))
  zoomOutArray:addObject(CCSpawn:createWithTwoActions(scaleBack,moveBack))
  local actionZoomOut = CCSequence:create(zoomOutArray)
  self:runAction(actionZoomOut)
end

function BattleView:cameraMove(targetCard)
    
    if BATTLE_CAMERA_FOLLOW <= 0 then
      return
    end

    local duration = 1.0
    local stayDuration = 1.25 
    local scaleDuration = duration * 0.35 
    local scaleBackDuration = duration * 0.5
    
--    28 29 30 31
--      
--    24 25 26 27
--    20 21 22 23
--    16 17 18 19

--    12 13 14 15
--    8   9 10 11
--    4   5  6  7

--    0   1  2  3
      
    local scale = 1.25
    assert(scale >= 1.0)
    local offset = ccp((display.width * scale - display.width) * 0.5,(display.height * scale - display.height) * 0.5)
    local toX = 0
    local toY = 0
    local targetPos = targetCard:getPos()
    if targetPos%4 == 0 or targetPos%4 == 1 then
      toX = offset.x
    elseif targetPos%4 == 3 or targetPos%4 == 2 then
      toX = -offset.x
    end
    
    if targetPos <= 8 then
      toY = offset.y
    elseif targetPos >= 24 then
      toY = -offset.y
    end
    
    if toX ~= 0 or toY ~= 0 then
      -- zoom in
      local zoomInArray = CCArray:create()
      --local to = ccp(display.cx - pos.x,display.cy - pos.y)
      local to = ccp(toX,toY)
      local scale = CCEaseSineInOut:create(CCScaleTo:create(scaleDuration,scale))
      local move = CCEaseSineInOut:create(CCMoveTo:create(scaleDuration,to))
      zoomInArray:addObject(CCSpawn:createWithTwoActions(move,scale))
      local actionZoomIn = CCSequence:create(zoomInArray)
      self:runAction(actionZoomIn)
      self:wait(scaleDuration)
    end
end

function BattleView:showGreySkipButton(delayToShowSkip)
  if delayToShowSkip == nil then
    delayToShowSkip = 0
  end

  self:removeGreySkipButton()
  self:removeSkipButton()
  if self._btnCancelGrey == nil then
    local battle = self:getBattleData()
    self._btnCancelGrey =  UIHelper.ccMenuWithSprite(_res(3059065),_res(3059018),_res(3059018),function ()
--      or (battle:getFightType() == "PVE_NORMAL" and AllConfig.vipinitdata[vipLevelId].pve_skip_free > 0)
--      or (battle:getFightType() == "PVP_NORMAL" and AllConfig.vipinitdata[vipLevelId].pvp_skip_free > 0)
--      or (battle:getFightType() == "PVE_NORMAL" and Scenario:Instance():getCurrentStage():getIsPassed() == true)
--      or (battle:getFightType() == "PVE_BOSS"   and AllConfig.vipinitdata[vipLevelId].Boss_skip_free > 0)
--      or (battle:getFightType() == "PVE_ACTIVITY" and GameData:Instance():getCurrentPlayer():isVipState() == true)
       
       if self._isLocalFight == false then
         local needLevel = 0
         local fightType = battle:getFightType() 
         if fightType == "PVE_NORMAL" then
           for i = 1, #AllConfig.vipinitdata do
             if AllConfig.vipinitdata[i].pve_skip_free > 0 then
               needLevel = AllConfig.vipinitdata[i].vip_level
               break
             end
           end
         elseif fightType == "PVP_NORMAL" then
           for i = 1, #AllConfig.vipinitdata do
             if AllConfig.vipinitdata[i].pvp_skip_free > 0 then
               needLevel = AllConfig.vipinitdata[i].vip_level
               break
             end
           end
         elseif fightType == "PVE_BOSS" then
           for i = 1, #AllConfig.vipinitdata do
             if AllConfig.vipinitdata[i].Boss_skip_free > 0 then
               needLevel = AllConfig.vipinitdata[i].vip_level
               break
             end
           end
         elseif fightType == "PVE_ACTIVITY" 
         or fightType == "PVE_GUILD"
         then
           for i = 1, #AllConfig.vipinitdata do
             if AllConfig.vipinitdata[i].pve_activity_skip_free > 0 then
               needLevel = AllConfig.vipinitdata[i].vip_level
               break
             end
           end
         end
         --local str = "到达VIP"..needLevel.."才能跳过".._tr(fightType)
         local str = _tr("vip%{viplv}_to_skip",{viplv = needLevel}).._tr(fightType)
         
         if fightType == "PVE_NORMAL" then
            str = _tr("pass_stage_to_skip")
         elseif fightType == "PVP_NORMAL" then
            --str = "成为VIP"..needLevel.."或等待20秒可直接跳过".._tr(fightType)
            str = _tr("vip%{viplv}_or_wait_to_skip",{viplv = needLevel}).._tr(fightType)
         end
         
         if GameData:Instance():getLanguageType() == LanguageType.JPN then
           if fightType == "PVE_BOSS" then
            str = _tr("level%{lv}_to_skip",{lv = 35}).._tr(fightType)
           end
         end
         
         Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
       end
     
      
    end)
    self._btnCancelGrey:setPosition(display.size.width -100 , 60)
    self:addChild(self._btnCancelGrey)
    self._btnCancelGrey:setZOrder(1999)
    
    if self._lableSkipNode == nil then
       self._lableSkipNode = display.newNode()
       self:addChild(self._lableSkipNode,2000)
       self._lableSkipNode:setPosition(self._btnCancelGrey:getPositionX() + 58,self._btnCancelGrey:getPositionY() - 15)
    else
       self._lableSkipNode:removeAllChildrenWithCleanup(true)
    end
    
    if delayToShowSkip > 0 then
      local timeLong = delayToShowSkip
      local timeLabel = CCLabelBMFont:create(timeLong.."", "client/widget/words/card_name/number_skillup.fnt")
      self._lableSkipNode:addChild(timeLabel)
      local timerCount = function()
        timeLong = timeLong - 1
        if timeLong < 0 then
          timeLong = 0
        end
        timeLabel:setString(timeLong.."")
      end
      
      
      local timerStep = CONFIG_BATTLE_SPEED_RATIO_LV1*(CONFIG_BATTLE_SPEED_RATIO/CONFIG_BATTLE_SPEED_RATIO_LV1)
      local timer = self:schedule(timerCount,timerStep)
      self:performWithDelay(function()
        self:unschedule(timer)
        timeLabel:removeFromParentAndCleanup(true)
        self:showSkipButton(0.01)
      end,timeLong * timerStep)
    end
  end
end

function BattleView:removeGreySkipButton()
  if self._btnCancelGrey ~= nil then
    self._btnCancelGrey:removeFromParentAndCleanup(true)
    self._btnCancelGrey = nil
  end
  
  if self._lableSkipNode ~= nil then
    self._lableSkipNode:removeAllChildrenWithCleanup(true)
  end
end

function BattleView:removeSkipButton()
  if self._btnCancel ~= nil then
    self._btnCancel:removeFromParentAndCleanup(true)
    self._btnCancel = nil
  end
end

function BattleView:showSkipButton(delay_time)
    local battle = self:getBattleData()
    self:removeSkipButton()
    self:removeGreySkipButton()
    if self._btnCancel == nil then
      self._btnCancel =  UIHelper.ccMenuWithSprite(_res(3059018),_res(3059019),_res(3059019),function ()
        self:removeSkipButton()
        battle:setIsFinish(true)
      end)
      self._btnCancel:setVisible(false)
      self._btnCancel:setPosition(display.size.width -100 , 60)
      self:addChild(self._btnCancel)
      self._btnCancel:setZOrder(1999)
    end
    
    if self._btnCancel:isVisible() ~= true then
      performWithDelay(self,function() self._btnCancel:setVisible(true) end,delay_time)
    end
    
end

function BattleView:showArenaCloud(selfIsAttacker)
  if self._arenaTip ~= nil then
      return
  end
  
  local tipLabel = ui.newTTFLabelWithOutline( {
                                          text = _tr("target_net_weak"),
                                          font = "Courier-Bold",
                                          size = 22,
                                          x = 0,
                                          y = 0,
                                          color = ccc3(0, 255, 48),
                                          align = ui.TEXT_ALIGN_CENTER,
                                          --valign = ui.TEXT_VALIGN_TOP,
                                          --dimensions = CCSize(200, 30),
                                          outlineColor =ccc3(0,0,0),
                                          pixel = 2
                                          }
                                        )
  
  

  local arenaTip = display.newSprite("img/battleui/arena_cloud.png")
  self:addChild(arenaTip,100)
  arenaTip:addChild(tipLabel,5)
  local size = arenaTip:getContentSize()
  tipLabel:setPosition(ccp(size.width/2,size.height/2))
  arenaTip:setVisible(false)
  
  arenaTip:setPositionX(display.cx)
  local posy = display.cy + 210
  if selfIsAttacker == false then
    posy = display.cy - 210
  end
  arenaTip:setPositionY(posy)
  self._arenaTip = arenaTip
  performWithDelay(self._arenaTip,function()
    if self._arenaTip ~= nil then
       self._arenaTip:setVisible(true)
       local arenaView = self:getArenaView()
       if arenaView ~= nil then
          arenaView:setVisible(false)
       end
    end
  end,8)
end

function BattleView:removeArenaCloud()
  if self._arenaTip ~= nil then
    self._arenaTip:removeFromParentAndCleanup(true)
    self._arenaTip = nil
  end
end


function BattleView:removeTimeCountDown()
  if self._countLabel ~= nil then
    self._countLabel:removeFromParentAndCleanup(true)
  end
  self._countLabel = nil
 
  if self._countLabeltop ~= nil then
    self._countLabeltop:removeFromParentAndCleanup(true)
  end
  self._countLabeltop = nil
end

function BattleView:setSelfCardsVisible(visible)
  if visible == nil then
    visible = true  
  end
  for key, cardView in pairs(self._cardsView) do
     if cardView:getData():getIsMySide() == true then
        cardView:setVisible(visible)
     end
   end
end

function BattleView:startTimeCountDown()
  
  if self._countLabeltop ~= nil then
    self._countLabeltop:setVisible(true)
  end

  local battle = self:getBattleData()
  self:schedule(function()
      if  self._touchEnabled == false and battle:getFightType() ~= "PVP_REAL_TIME" then
          return
      end
      self._timeLeft = self._timeLeft -1
      -- auto start fight
      if self._timeLeft <= 0 or self._isFinish then
         
         self:removeTimeCountDown()
    		 if( not self._isFinish) then
    		  if self._touchEnabled == true then
    		    echo("AUTO START FIGHT")
    			  self:onStartBattle(battle)
    			else
    			  if battle:getFightType() == "PVP_REAL_TIME" then
    			     self:showArenaCloud(battle:getSelfIsAttacker())
    			  end
    			end
    		 end
      else
  		  if self._countLabel ~= nil then
  			 self._countLabel:setVisible(true)
  			 self._countLabel:setString(_tr("%{second}sceondleft", {second = self._timeLeft}))
  		  end
      end
  end,1/1)
end

function BattleView:updateAreaView(arenaFightInfo)
  local arenaView = self:getArenaView()
  if arenaView == nil then 
    arenaView = ArenaEnterEffectAnimation.new(self:getBattleData():getSelfIsAttacker())
    arenaView:setDelegate(self)
    GameData:Instance():getCurrentScene():addChild(arenaView,2)
    self:setArenaView(arenaView)
  end
  arenaView:updateView(arenaFightInfo)
end

------
--  Getter & Setter for
--      BattleView._EnabledCardEnterEffect 
-----
function BattleView:setEnabledCardEnterEffect(EnabledCardEnterEffect)
	self._enabledCardEnterEffect = EnabledCardEnterEffect
end

function BattleView:getEnabledCardEnterEffect()
	return self._enabledCardEnterEffect
end

function BattleView:updateView()
--  self:resetView()
--  self:setupView(self:getBattleData())
  --self:setupCard(self:getBattleData())
  self:getBattleData():prepareBattle()
end

------
--  Getter & Setter for
--      BattleView._ArenaView 
-----
function BattleView:setArenaView(ArenaView)
	self._arenaView = ArenaView
end

function BattleView:getArenaView()
	return self._arenaView
end

function BattleView:createSwitchSpeedButton()
 
     --speed btn
     local changeBattleSpeedHandler = function(bp,target)
        
        local enabled = true
        local level = 1
        if self._isLocalFight == false then
          enabled = GameData:Instance():checkSystemOpenCondition(36,false)
          level = AllConfig.systemopen[36].type_value
        end
        
        if self._isLocalFight == false and enabled ~= true  then
           Toast:showString(GameData:Instance():getCurrentScene(), _tr("speed_up_on_battle%{level}",{level = level}), ccp(display.cx, display.cy))
           return
        end
     
        self._btnSpeed_1:setVisible(false)
        self._btnSpeed_2:setVisible(false)
        self._btnSpeed_3:setVisible(false)
        
        print("target:getTag():",target:getTag())
        
        -- for 3 speed level
--        if target:getTag() == 1 then
--           self._btnSpeed_2:setVisible(true)
--           CONFIG_BATTLE_SPEED_RATIO = BattleConfig.BattleSpeedLevel2
--        elseif target:getTag() == 2 then
--           self._btnSpeed_3:setVisible(true)
--           CONFIG_BATTLE_SPEED_RATIO = BattleConfig.BattleSpeedLevel3
--        elseif target:getTag() == 3 then
--           self._btnSpeed_1:setVisible(true)
--           CONFIG_BATTLE_SPEED_RATIO = BattleConfig.BattleSpeedLevel1
--        end

        -- for 2 speed level
        if target:getTag() == 1 then
           self._btnSpeed_2:setVisible(true)
           CONFIG_BATTLE_SPEED_RATIO = BattleConfig.BattleSpeedLevel2
        elseif target:getTag() == 2 then
           self._btnSpeed_1:setVisible(true)
           CONFIG_BATTLE_SPEED_RATIO = BattleConfig.BattleSpeedLevel1
        end
        
        CCDirector:sharedDirector():getScheduler():setTimeScale(CONFIG_BATTLE_SPEED_RATIO)
        --CONFIG_DEFAULT_ANIM_DELAY_RATIO = 1/CONFIG_BATTLE_SPEED_RATIO
     end
     
     local btnSpeed_1,menuItem1 =  UIHelper.ccMenuWithSprite(_res(3059037),_res(3059037),_res(3059037),changeBattleSpeedHandler)
     menuItem1:setTag(1)
     self._btnSpeed_1 = btnSpeed_1
     
     local btnSpeed_2,menuItem2 =  UIHelper.ccMenuWithSprite(_res(3059038),_res(3059038),_res(3059038),changeBattleSpeedHandler)
     menuItem2:setTag(2)
     self._btnSpeed_2 = btnSpeed_2
     
     local btnSpeed_3,menuItem3 =  UIHelper.ccMenuWithSprite(_res(3059039),_res(3059039),_res(3059039),changeBattleSpeedHandler)
     menuItem3:setTag(3)
     self._btnSpeed_3 = btnSpeed_3
     
     self:addChild(self._btnSpeed_1,2000)
     self:addChild(self._btnSpeed_2,2000)
     self:addChild(self._btnSpeed_3,2000)
     self._btnSpeed_1:setPosition(ccp(65,60))
     self._btnSpeed_2:setPosition(ccp(65,60))
     self._btnSpeed_3:setPosition(ccp(65,60))
     self._btnSpeed_1:setVisible(false)
     self._btnSpeed_2:setVisible(false)
     self._btnSpeed_3:setVisible(false)
     
     if CONFIG_BATTLE_SPEED_RATIO == BattleConfig.BattleSpeedLevel1 then
        self._btnSpeed_1:setVisible(true)
     elseif CONFIG_BATTLE_SPEED_RATIO == BattleConfig.BattleSpeedLevel2 then
        self._btnSpeed_2:setVisible(true)
     elseif CONFIG_BATTLE_SPEED_RATIO == BattleConfig.BattleSpeedLevel3 then
        self._btnSpeed_3:setVisible(true)
     end
      
     CCDirector:sharedDirector():getScheduler():setTimeScale(CONFIG_BATTLE_SPEED_RATIO)
     --CONFIG_DEFAULT_ANIM_DELAY_RATIO = 1/CONFIG_BATTLE_SPEED_RATIO
end

function BattleView:getIsStartedBattle()
  if self._touchEnabled == true then
    return false
  else
    return true
  end
end

function BattleView:setIsFinish(b)
	self._isFinish = b
end
function BattleView:onStartBattle(battle)
  if self._isMoving == true then
    return
  end
  
  echo("startBtn")
  self._touchEnabled = false
  self:removeChild(self._startBtn,true)
  self._startBtn = nil
  
  if self._guideAnimation ~= nil then
     self._guideAnimation:getParent():removeChild(self._guideAnimation,true)
     self._guideAnimation = nil
  end
  
  if self._backBtn ~= nil then
    local delay_time = 20
    if battle:getFightType() == "PVP_REAL_TIME" then
      delay_time = delay_time + self._timeLeft
    end
    self._backBtn:setVisible(false)
    performWithDelay(self._backBtn,function()
		if(not self._isFinish) then
			self._backBtn:setVisible(true)
		end
	 end,delay_time)
  end
  
  if self._skillRangeInfo ~= nil then
    self._skillRangeInfo:setVisible(false)
  end
      
  if self._countLabel ~= nil then
     if battle:getFightType() == "PVP_REAL_TIME" then
       if self._countLabeltop ~= nil then
          self._countLabeltop:setString(_tr("waiting_for_start_fight"))
       end
     else
       self:stopAllActions()
       self._countLabeltop:setString("")
       self._countLabel:setString("")
     end
  end

  
  Guide:Instance():removeGuideLayer()
  
  if self._isLocalPlay == true or battle:getIsPlayingReview() == true then
  else
		self._isStartPlayer = true
		self:getDelegate():startBattle()
  end
 
end
function BattleView:IsStartBattle()
	return self._isStartBattle
end
function BattleView:onBeginBattle(battle,battleView)
  for key, cardView in pairs(self._cardsView) do
    cardView:onBeginBattle(battle,battleView)
  end
  self._isStartBattle = true
end

function BattleView:onTouch(event, x,y)
  if self._touchEnabled == false then
    return true
  end
  
  if self.isLocked == true then
    return true
  end
  
  local battle = self:getBattleData()
  
  local startDragPos = 4
  local endDragPos = 15
  if battle:getFightType() == "PVP_REAL_TIME" and battle:getSelfIsAttacker() == false then
    startDragPos = 16
    endDragPos = 27
  end
  
  local function checkOverField()
   -- get an new Pos
    local touchOverFieldView = self:getTouchedNode(self._fieldView,x,y) -- touchover an fiedView
    if  touchOverFieldView ~= self._overFieldView then
      if touchOverFieldView ~= nil then -- touchover an new target fieldView
         if self._moveCardView ~= nil then
            --if touchOverFieldView:getData():getPos() >= 4 and touchOverFieldView:getData():getPos() <= 15 then
               local direction = 1
               if self._moveCardView:getData():getIsMySide() == false then
                  direction = -1
               end
               self._troopIntroductionView:areaWithUnitTypeAndPos(self._moveCardView:getData():getType(),touchOverFieldView:getData():getPos(),direction)
            --end
         end
      end
    end
    self._overFieldView = touchOverFieldView
  end

  if event == "began" then    
    --echo(event,x,y)
    self._moveCardView = nil
    local m_cardView = self:getTouchedNode(self._cardsView,x,y) --touchover an cardView
    if m_cardView ~= nil and m_cardView:getDragEnabled() == true then
       self._moveCardView = m_cardView
    end
    
    if self._moveCardView ~= nil then
      for key, cardView in pairs(self._cardsView) do
        cardView:showUnitEffect(false)
      end
    
      checkOverField()
      
      if self._skillRangeInfo:getCard() == nil then
        if battle:getFightType() ~= "PVP_REAL_TIME" then
           self._skillRangeInfo:runAction(CCMoveTo:create(0.3,ccp(0,0)))
           if self._countLabel ~= nil then
             self._countLabel:runAction(CCMoveTo:create(0.3,ccp(self._countLabel:getPositionX(),self._countLabel:getPositionY()-115)))
           end
         
           if self._countLabeltop ~= nil then
            self._countLabeltop:runAction(CCMoveTo:create(0.3,ccp(self._countLabeltop:getPositionX(),self._countLabeltop:getPositionY()-115)))
           end
        end
      end
      self._skillRangeInfo:setVisible(self._startBtn:isVisible())
      self._skillRangeInfo:setCard(self._moveCardView:getData())
      local duration = 0.08 
      local action1 = CCScaleTo:create(duration, 1.25)
      local action2 =  CCScaleTo:create(duration, 1.0)
      local array = CCArray:create()
      array:addObject(action1)
      array:addObject(action2)
      local seq = CCSequence:create(array)
      self._moveCardView:runAction(seq)
      
      local cardData = self._moveCardView:getData()
      for key, unitEffectInfo in pairs(AllConfig.uniteffect) do
        if cardData:getType() == unitEffectInfo.attack_unit then
          if unitEffectInfo.atk_rate > 10000 then
            for key, cardView in pairs(self._cardsView) do
              if cardView:getData():getGroup() ~= cardData:getGroup()
              and cardView:getData():getType() == unitEffectInfo.target_unit 
              then
                cardView:showUnitEffect(true)
              end
            end
          end
        end
      end
      
      if self._lastMoveCardView ~= nil and self._lastMoveCardView ~= self._moveCardView then
         self._lastMoveCardView:stopAllActions()
         self._lastMoveCardView:setOpacity(255)
      end
      
      if self._moveCardView ~= nil and self._moveCardView:getData():getPos() >= startDragPos and self._moveCardView:getData():getPos() <= endDragPos  then
         if self._moveCardView ~= self._lastMoveCardView then
            GameData:Instance():playDubbingByCard(self._moveCardView:getData())
         end
      end
      
      self._lastMoveCardView  = self._moveCardView
      
      if self._moveCardView:getData():getPos() >= startDragPos and self._moveCardView:getData():getPos() <= endDragPos then
        self._moveCardView:setZOrder(99)
        self._startPos =  self:getPosByIndex(self._moveCardView:getData():getPos())
      else
        self._moveCardView = nil
      end
      
      return true
    else
      return false
    end

  elseif event == "moved" then
    --echo(event,x,y)
    if self._moveCardView ~= nil then
      if self._moveCardView:getData():getPos() >= startDragPos and self._moveCardView:getData():getPos() <= endDragPos then
         self._moveCardView:setPosition(ccp(x,y))
      end

      if  self._isMoving == true then
        return
      end
      
      checkOverField()
      
      if self._posChangePreview == true then
        self:autoChangePosition(x,y)
      end

    end
  elseif event == "ended" then
    --echo(event,x,y)
--    for key, cardView in pairs(self._cardsView) do
--        cardView:showUnitEffect(false)
--    end
    
    if self._moveCardView == nil then
      return
    end
    
    --clear over field
    self._overFieldView = nil

    self._touchEnabled = false
    self:autoChangePosition(x,y)
    
    if self._overFieldView ~= nil then
      print("if self._overFieldView ~= nil ")
       --if self._overFieldView:getData():getPos() >= disabledDragStartPos and  self._overFieldView:getData():getPos() <= disabledDragEndPos then
       if self._overFieldView:getData():getPos() < startDragPos or self._overFieldView:getData():getPos() > endDragPos then
          self._overFieldView = nil
       end
    end
    
    print("self._overFieldView: ",self._overFieldView)
 
    
    if self._overFieldView == nil or self._overFieldView:getIsLocked() == true then
      self._isMoving = true
      transition.execute(self._moveCardView, CCMoveTo:create(0.2,self._startPos),
        {
          --delay = 1.0,
          --easing = "backout",
          onComplete = function()
            self._troopIntroductionView:areaWithUnitTypeAndPos(self._moveCardView:getData():getType(),self._moveCardView:getData():getPos())
            self._moveCardView = nil
            self._touchEnabled = true
            self._overFieldView = nil
            self._isMoving = false
          end,
        })
    else
      self._isMoving = true
      self._moveCardView:stopAllActions() 
   
      transition.execute(self._moveCardView, CCMoveTo:create(0.2,self._targetPos),
        {
          --delay = 1.0,
          --easing = "backout",
          onComplete = function()
            --change card Pos
            if  self._overCardView ~= nil then
              self._overCardView:getData():setPos(self._moveCardView:getData():getPos())
            end
            --change card Pos
            self._moveCardView:getData():setPos(self._overFieldView:getData():getPos())
           
            echo("NowPos:",self._overFieldView:getData():getPos())
        	  if self._moveCardView:getData():getPos() == self._targetGuidePos then
        	     self._targetGuidePos = -1
        	     if self._startBtn ~= nil then
                 self._startBtn:setVisible(true)
               end
               if self._tipMove ~= nil then
                  self._tipMove:removeFromParentAndCleanup(true)
                  self._tipMove = nil
               end
               _executeNewBird()
        	  end
        	  
        	  self._moveCardView = nil
            self._touchEnabled = true
            self._overFieldView = nil
            self._isMoving = false
            
          end,
        })
    end
  end
   
  if self._moveCardView ~= nil then
    local action1 =  CCScaleTo:create(0.05, 1.0)
    --local action2 = CCSequence:createWithTwoActions(CCFadeTo:create(1.0,50), CCFadeTo:create(1.0,255))
    local action2 = CCFadeTo:create(1.0,50)
    local action3 = CCFadeTo:create(1.0,255)
    local array = CCArray:create()
    array:addObject(action1)
    array:addObject(action2)
    array:addObject(action3)
    local seq = CCSequence:create(array)
    self._moveCardView:runAction(CCRepeatForever:create(seq))
    
  end

end

function BattleView:autoChangePosition(x,y)
  
  local battle = self:getBattleData()
  local startDragPos = 4
  local endDragPos = 15
  if battle:getFightType() == "PVP_REAL_TIME" and battle:getSelfIsAttacker() == false then
    startDragPos = 16
    endDragPos = 27
  end
  
  local touchOverFieldView = self:getTouchedNode(self._fieldView,x,y) -- touchover an fiedView
  if  touchOverFieldView ~= self._overFieldView then
    if touchOverFieldView ~= nil then -- touchover an new target fieldView
      --self._targetPos = ccp(touchOverFieldView:getPositionX(),touchOverFieldView:getPositionY())
      self._targetPos = self:getPosByIndex(touchOverFieldView:getData():getPos())
      self._overCardView = self:getCardViewByCardPos(touchOverFieldView:getData():getPos())
      if self._overCardView ~= nil and self._overCardView:getData():getPos() >= startDragPos and self._overCardView:getData():getPos() <= endDragPos then
        self._lastOverCardView = self._overCardView
        self._isMoving = true
        transition.execute(self._overCardView, CCMoveTo:create(0.2,self._startPos),
          {
            onComplete = function()
              self._isMoving = false
            end,
          })

      end

    else -- out of any fieldView
      if self._lastOverCardView ~= nil then
        self._isMoving = true
        local backPos = self:getPosByIndex(self._lastOverCardView:getData():getPos())
        transition.execute(self._lastOverCardView, CCMoveTo:create(0.2,backPos),
          {
            onComplete = function()
              self._isMoving = false
              self._lastOverCardView = nil
              self._overCardView = nil
            end,
          })
      end
    end
    self._overFieldView = touchOverFieldView
  else
  -- touchOver at the same fieldView
  end
end

function BattleView:getTouchedNode(toTouchArray,x,y)
  local isGetedNode = false
  local touchedNode = nil
  for i = 1, table.getn(toTouchArray) do
    local contentSize = toTouchArray[i]:getContentSize()
    local position = toTouchArray[i]:getParent():convertToNodeSpace(ccp(x + contentSize.width/2,y + contentSize.height/2 ))  --鑾峰彇 x,y 鐩稿浜巘oTouchArray[i]:getParent()鍧愭爣绯荤殑鍧愭爣鐐�
    --if toTouchArray[i]:getData():getPos() >= 4 and toTouchArray[i]:getData():getPos() <= 15 then
      isGetedNode = toTouchArray[i]:boundingBox():containsPoint(position)
    --end

    if isGetedNode == true then
      touchedNode = toTouchArray[i]
      break
    end
  end
  return touchedNode
end

function BattleView:setupBg(battle)
  if self._animationNode == nil then
    self._animationNode = display.newNode()
    GameData:Instance():getCurrentScene():addChildView(self._animationNode)
  else
    self._animationNode:removeAllChildrenWithCleanup(true)
  end

  local bgPos = display.p_center
  local viewConfig = battle:getViewConfig()
  local bg = _res(viewConfig.bg)
  bg:setPosition(bgPos)
  self:addChild(bg)
  if viewConfig.effect > 1 then
     if self._animationNode ~= nil then
        local anim = _res(viewConfig.effect)
        self._animationNode:addChild(anim)
     end
  elseif viewConfig.effect == 0 then
    for i = 1, 2 do
  	  local anim,offsetX,offsetY,d,isFlipY = _res(5020148)
  	  if i == 1 then
        anim:setPosition(ccp(offsetX  + 40,offsetY + display.cy - 300))
      else
        anim:setPosition(ccp(offsetX  + display.width - 50,offsetY + display.cy + 160))
      end
      anim:setFlipY(isFlipY)  
      anim:getAnimation():play("default") 
      self._animationNode:addChild(anim)
    end
  elseif viewConfig.effect == 1 then
    local pkg = ccbRegisterPkg.new(self)
    pkg:addProperty("mAnimationManager","CCBAnimationManager")
    local layer,owner = ccbHelper.load("anim_Mist.ccbi","MistCCB","CCLayer",pkg)
    self._animationNode:addChild(layer)
  end
  
end

function BattleView:setupBoss(battle)
  local bossInfoView = BattleBossInfoView.new(battle)
  local pos = ccp(display.cx,display.cy)
  pos.y = pos.y + BattleConfig.BattleFieldHeight * 0.5
  bossInfoView:setPosition(pos.x,display.size.height + 100)
  self:addChild(bossInfoView,99)
  self:setBossInfoView(bossInfoView)
  
  transition.execute(bossInfoView, CCMoveTo:create(0.5,pos))
end

function BattleView:setupWall(battle)

  -- setup red wall
  if battle:getIsBossBattle() ~= true then
    local redWallPos = ccp(display.cx,display.cy)
    redWallPos.y = redWallPos.y + BattleConfig.BattleFieldHeight * 0.5
    printf("redWallPos[%f,%f]",redWallPos.x,redWallPos.y)
    local redWall = BattleWallView.new(battle:getWallByIndex(BattleConfig.BattleSide.Red),battle)
    redWall:setPosition(redWallPos.x,display.size.height + 100)
    self:addChild(redWall,99)
    self:addWallView(BattleConfig.BattleSide.Red,redWall)
    transition.execute(redWall, CCMoveTo:create(0.5,redWallPos))
  end
  -- setup blue wall
  local blueWallPos = ccp(display.cx,display.cy)
  blueWallPos.y = blueWallPos.y - BattleConfig.BattleFieldHeight * 0.5
  printf("blueWallPos[%f,%f]",blueWallPos.x,blueWallPos.y)
  local blueWall = BattleWallView.new(battle:getWallByIndex(BattleConfig.BattleSide.Blue),battle)
  blueWall:setPosition(blueWallPos.x,-100)
  self:addChild(blueWall,99)
  self:addWallView(BattleConfig.BattleSide.Blue,blueWall)
  transition.execute(blueWall, CCMoveTo:create(0.5,blueWallPos))

end

function BattleView:setupFields(battle)
  local fields = battle:getFields()
  for key, field in pairs(fields) do
    if field ~= "Wall" then
      --      printf("Valid field[%d]",field:getPos())
      local pos = self:getPosByIndex(field:getPos())
      local battleFieldView = BattleFieldView.new(field,battle)
      battleFieldView:setPosition(pos)
      self:addChild(battleFieldView,5)
      self:addFieldView(field:getIndex(),battleFieldView)
    else
      -- the wall field
    end
  end
end

function BattleView:addFieldView(index,fieldView)
  self._fieldView[index] = fieldView
end

function BattleView:getFieldView(index)
  return self._fieldView[index]
end

function BattleView:setupCard(battle)
  --clean up cardview
  
  for key, cardView in pairs(self._cardsView) do
  	cardView:removeFromParentAndCleanup(true)
  end
  self._cardsView = {}

  local cards = battle:getCards()
  battle:makeSureCardsPos()
  for key, card in pairs(cards) do
    printf("added card,pos:%d",card:getPos())
    echo("card type:",card:getType())
    local pos = self:getPosByIndex(card:getPos())
    local cardView = BattleCardView.new()
    cardView:setPosition(pos)
    self:addChild(cardView,99)
    cardView:init(card)
    if self._isLocalFight == false 
    and self._touchEnabled == true
    and card:getIsMySide() == true 
    and self._isLocalPlay ~= true 
    and battle:getIsPlayingReview() == false 
    then
      if self._enabledCardEnterEffect == true or self._enabledCardEnterEffect == nil then
       cardView:setVisible(false)
      end
    end 
    self:addCardView(card:getIndex(),cardView)
  end
  
  if self._isLocalFight == false
  and self._touchEnabled == true
  and self._isLocalPlay ~= true 
  and battle:getIsPlayingReview() == false 
  and self._enabledCardEnterEffect == nil or self._enabledCardEnterEffect == true
  then
     self:playCardEnterEffect()
  end
  
end

function BattleView:playCardEnterEffect()
   if self._effectEnterNode == nil then
      self._effectEnterNode = display.newNode()
      self:addChild(self._effectEnterNode,999)
   else
      self._effectEnterNode:removeAllChildrenWithCleanup(true)
   end
   
   --my cards count
   local myCardsCount = 0
   for key, cardView in pairs(self._cardsView) do
     if cardView:getData():getIsMySide() == true then
        myCardsCount = myCardsCount + 1
     end
   end

   local posLine = {}
   local leaderCardView = nil
   local leaderCardMiddleView = nil
   local idx = 1
   local posIdx = 1
   local duration = 0.25
   local eachDelay = 0.15
   local startScale = 1
   
   local getRandomPos = function(pos)
      local random = math.random()
      if pos%4 == 0 then
         return  ccp(-300,-200)
      elseif pos%4 == 3 then --right
         return  ccp(display.width + 300,-200)
      elseif pos%4 == 1 or pos%4 == 2 then -- center
         return  ccp(math.random() * display.width*startScale,-300)
      end
      
   end
   
   local startEventFunc = function(middleCardView)
      middleCardView:setVisible(true)
   end
   
   local turnEventFunc = function(middleCardView)
      middleCardView:removeFromParentAndCleanup(true)
      local pos = posLine[posIdx]
      if pos ~= nil then
          print("Pos:",pos)
          local cardView = self:getCardViewByCardPos(pos)
          local cardViewX = 0
          local cardViewY = 0
          if cardView ~= nil then
             cardView:setVisible(true)
             cardViewX = cardView:getPositionX()
             cardViewY = cardView:getPositionY()
          end
          local m_sptAnim,offsetX,offsetY,d = _res(5020181)
          m_sptAnim:setPosition(ccp(offsetX + cardViewX,offsetY + cardViewY))
          self._effectEnterNode:addChild(m_sptAnim,99)
          m_sptAnim:getAnimation():play("default") 
      end
      posIdx = posIdx + 1
      
      if posIdx == myCardsCount then
          local cardView = leaderCardView
          if cardView == nil then
            return
          end
          local pos = self:getPosByIndex(cardView:getData():getPos())
          local middleCardView = MiddleCardHeadView.new()
          middleCardView:setAnchorPoint(ccp(0.5,0.5))
          middleCardView:setVisible(false)
          middleCardView:setCard({configId = cardView:getData():getConfigId()})
          middleCardView:setScale(startScale)
          middleCardView:setPosition(getRandomPos(cardView:getData():getPos()))
          self._effectEnterNode:addChild(middleCardView)
          posLine[idx] = cardView:getData():getPos()
          local array = CCArray:create()
          array:addObject(CCCallFuncN:create(startEventFunc)) 
          local scaleBack = CCEaseSineOut:create(CCScaleTo:create(duration,1.0))
          local moveBack = CCEaseSineOut:create(CCMoveTo:create(duration,ccp(pos.x - 135/2,pos.y - 150/2)))
          array:addObject(CCSpawn:createWithTwoActions(scaleBack,moveBack))
          local actionZoomOut = CCSequence:create(array)
          local moveTo = CCSequence:createWithTwoActions(CCDelayTime:create(eachDelay),actionZoomOut)
          middleCardView:runAction(moveTo)
          leaderCardMiddleView = middleCardView
      end
   end
   
    local function buildActionMiddleCard(cardView)
      local pos = self:getPosByIndex(cardView:getData():getPos())
      local middleCardView = MiddleCardHeadView.new()
      middleCardView:setAnchorPoint(ccp(0.5,0.5))
      middleCardView:setVisible(false)
      middleCardView:setCard({configId = cardView:getData():getConfigId()})
      middleCardView:setScale(startScale)
      middleCardView:setPosition(getRandomPos(cardView:getData():getPos()))
      self._effectEnterNode:addChild(middleCardView)
      local pos = self:getPosByIndex(cardView:getData():getPos())
      posLine[idx] = cardView:getData():getPos()
      local array = CCArray:create()
      array:addObject(CCCallFuncN:create(startEventFunc)) 
      local scaleBack = CCEaseSineOut:create(CCScaleTo:create(duration,1.0))
      local moveBack = CCEaseSineOut:create(CCMoveTo:create(duration,ccp(pos.x - 135/2,pos.y - 150/2)))
      array:addObject(CCSpawn:createWithTwoActions(scaleBack,moveBack))
      array:addObject(CCCallFuncN:create(turnEventFunc)) 
      local actionZoomOut = CCSequence:create(array)
      local moveTo = CCSequence:createWithTwoActions(CCDelayTime:create((idx-1)*eachDelay),actionZoomOut)
      middleCardView:runAction(moveTo)
   end
   
   for key, cardView in pairs(self._cardsView) do
     if cardView:getData():getIsMySide() == true then
        if cardView:getData():getIsPrimary() == false then
          buildActionMiddleCard(cardView)
          idx = idx + 1
        else
          leaderCardView = cardView
        end
     end
   end
   
   local leaderEffect = function()
      leaderCardView:setVisible(true)
      if leaderCardMiddleView ~= nil then
         leaderCardMiddleView:removeFromParentAndCleanup(true)
         leaderCardMiddleView = nil
      end
      self:shake()
      local m_sptAnimLeader,offsetX,offsetY,d = _res(5020180)
      m_sptAnimLeader:setPosition(ccp(offsetX + leaderCardView:getPositionX(),offsetY + leaderCardView:getPositionY()))
      self._effectEnterNode:addChild(m_sptAnimLeader,99)
      m_sptAnimLeader:getAnimation():play("default") 
      
      local m_sptAnim,offsetX,offsetY,d = _res(5020181)
      m_sptAnim:setPosition(ccp(offsetX + leaderCardView:getPositionX(),offsetY + leaderCardView:getPositionY()))
      self._effectEnterNode:addChild(m_sptAnim,99)
      m_sptAnim:getAnimation():play("default") 
      
      for key, cardView in pairs(self._cardsView) do
       if cardView:getData():getIsMySide() == true then
          cardView:playShadow()
       end
      end
      
      if self:getEnabledCardEnterEffect() == false then
        self:setSelfCardsVisible(false)
      else
        if self._skillRangeInfo then
          self._skillRangeInfo:setVisible(true)
        end
        
        if self._startBtn then
          self._startBtn:setVisible(true)
        end
      end
      
--      performWithDelay(leaderCardView,function()
--         self:playRandomTip()
--      end,2)
      
      
      
   end
   
   local leaderDelayTime = eachDelay*(idx-1) + duration*2
   if leaderCardView ~= nil then
      performWithDelay(leaderCardView,leaderEffect,leaderDelayTime)
   end
   
end

function BattleView:playRandomTip()
   if self._touchEnabled == false or self:getBattleData():getFightType() == "PVP_REAL_TIME" then
     return false
   end
   
   --my cards count
   local myCardsCount = 0
   local myCards = {}
   for key, cardView in pairs(self._cardsView) do
      if cardView:getData():getIsMySide() == true then
         myCardsCount = myCardsCount + 1
         table.insert(myCards,cardView)
      end
   end
      
   local randomTips = function()
      if self._touchEnabled == false then
         return
      end
      
      for key, cardView in pairs(myCards) do
         cardView:hideTip()
      end
      local idx = math.random(1,#myCards)
      local tipCardView = myCards[idx]
      tipCardView:showTip()
--      local idx2 = math.random(1,#self._cardsView)
--      if idx2 ~= idx then
--        local cardView = self._cardsView[idx2]
--        if tipCardView:getData():getType() ~= cardView:getData():getType() then
--           cardView:showTip()
--        end
--      end
   end
   self:schedule(randomTips,5)
end


function BattleView:setupRoundBanner()

  local sptRound = ui.newTTFLabelWithOutline( {
                                            text = "",
                                            font = "Courier-Bold",
                                            size = 24,
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 255, 255),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = CCSize(200, 30),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
                                          
                                          
  sptRound:setPosition(ccp(15,display.top - 30))
  sptRound:setScale(1.0)
  sptRound:setZOrder(999)
  self:addChild(sptRound)
  self._sptRound = sptRound

end

function BattleView:setupDropBanner()
  
  local sptIcon = _res(3033010)
  self:addChild(sptIcon,999)
  sptIcon:setPosition(ccp(display.width - 115,display.top - 30))
  self._sptIcon = sptIcon
  self._sptIcon:setVisible(false)
  
  local sptCount = ui.newTTFLabelWithOutline( {
                                            text = "0",
                                            font = "Courier-Bold",
                                            size = 24,
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 255, 255),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = CCSize(200, 30),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
                                          
                                          
  sptCount:setPosition(ccp(display.width - 70,display.top - 30))
  sptCount:setScale(1.0)
  sptCount:setZOrder(999)
  self:addChild(sptCount)
  self._sptCount = sptCount
  self._sptCount:setVisible(false)

end

function BattleView:prepareBattleResultView(result,msg,fightType)
  self._battleResultView = BattleResultView.new(result,msg,fightType,self)
  --self._battleResultView:setBattleView(self)
  self._battleResultView:setDelegate(self:getDelegate())
  self:addChild(self._battleResultView,1999)
  self._battleResultView:setVisible(false)
  
   -- condition not match or lose
  local battle = self:getBattleData()
  local pve_lose = false
  if battle:getFightType() == "PVE_NORMAL" then
    local isWin,fightType,result_lv = self._battleResultView:checkIsWinByResult()
    if fightType == "PVE_NORMAL" then
       --[[if isWin == false or result_lv ~= "WIN_LEVEL_2" then
          pve_lose = true
       end]]

       if isWin == true and result_lv ~= "WIN_LEVEL_2" then
        self:showSkipButton(0.01)
       end
    end
  end
   
  --[[if pve_lose == true then
   self:showSkipButton(0.01)
  end]]
   
end

function BattleView:hideSpeedButtons()
   --hide speed btns
  if self._btnSpeed_1 ~= nil then
     self._btnSpeed_1:setVisible(false)
  end
  
  if self._btnSpeed_2 ~= nil then
     self._btnSpeed_2:setVisible(false)
  end
  
  if self._btnSpeed_3 ~= nil then
     self._btnSpeed_3:setVisible(false)
  end
end

function BattleView:showResult(isDisconnect)
  self:removeSkipButton()
  self:removeGreySkipButton()
  self:hideSpeedButtons()
  self:removeBattleAnimation()
  self:stopAllActions()
  if isDisconnect then
	  self:removeTimeCountDown()
  end
  self._battleResultView:setVisible(true)
  self._battleResultView:enter()
  self:cameraReset()
end

function BattleView:addCardView(index,cardView)
  echo("BattleView:addCardView:%d",index)
  self._cardsView[index] = cardView
end

function BattleView:getCardByIndex(index)
  return self._cardsView[index]
end

function BattleView:getCardViewByCardPos(posIndex)
  local mCardView = nil
  for key, cardView in pairs(self._cardsView) do
    if cardView:getData():getPos() == posIndex then
      mCardView = cardView
      break
    end
  end

  return mCardView
end

function BattleView:addWallView(group,wallView)
  printf("BattleView:addWallView:%d",group)
  self._wallsView[group] = wallView
end

function BattleView:getWallByIndex(group)
  return self._wallsView[group]
end

function BattleView:getPosByIndex(pos_index)
  local pos = self._positions[pos_index]
  return ccp(pos.x,pos.y)
end

function BattleView:getFieldViewByIndex(index)
  return self._fieldView[index]
end

function BattleView:getFieldViewByPos(pos)
  local fieldView = nil
  for key, field in pairs(self._fieldView) do
  	if field:getData():getPos() == pos then
  	   fieldView = field
  	   break
  	end
  end
  return fieldView
end

------
--  Getter & Setter for
--      BattleView._LastCardView
-----
function BattleView:setLastCardView(LastCardView)
  self._LastCardView = LastCardView
end

function BattleView:getLastCardView()
  return self._LastCardView
end

------
--  Getter & Setter for
--      BattleView._BossInfoView 
-----
function BattleView:setBossInfoView(BossInfoView)
	self._BossInfoView = BossInfoView
end

function BattleView:getBossInfoView()
	return self._BossInfoView
end

function BattleView:showAngryLow(group)
  for key, cardView in pairs(self._cardsView) do
    if cardView:getData():getOriginalGroup() == group then
      cardView:showAngryLow(group)
    end
  end
end

function BattleView:execCombineSkillEvent(battle,info)
  if self._combineSkillCount == nil then
    self._combineSkillCount = 1
  end
  local pos = ccp(display.cx,display.cy)
  if info.group == BattleConfig.BattleSide.Red then
    pos.y = pos.y + 300
  else
    pos.y = pos.y - 200
  end
  local skillInfo = AllConfig.cardskill[info.skill_id]
  assert(skillInfo)
  local combineInfo = AllConfig.combineskilleffect[skillInfo.combine_effect_id]
  assert(combineInfo)
  -- combine skill img
  --[[local spt = _res(combineInfo.img)
  local sptSize = spt:getContentSize()
  local sptPos = ccp(pos.x - sptSize.width * 0.5,pos.y )
  spt:setPosition(sptPos)
  self:addChild(spt,99)
  
  local anim_duration = 1.0
  local spt_distance = display.width * 0.5 + sptSize.width * 0.5
  local array = CCArray:create()
  local moveIn = CCMoveBy:create(anim_duration * 0.3,ccp(spt_distance,0))
  local fadeIn = CCFadeIn:create(anim_duration * 0.3)
  local anim1 = CCEaseOut:create(CCSpawn:createWithTwoActions(moveIn,fadeIn),0.2)
  array:addObject(anim1)
  local delay = CCDelayTime:create(anim_duration * 0.4)
  array:addObject(delay)
  local moveOut = CCMoveBy:create(anim_duration * 0.3,ccp(spt_distance,0))
  local fadeOut = CCFadeOut:create(anim_duration * 0.3)
  local anim2 = CCEaseOut:create(CCSpawn:createWithTwoActions(moveOut,fadeOut),0.2)
  array:addObject(anim2)
  local remove = CCRemoveSelf:create()
  array:addObject(remove)
  local action = CCSequence:create(array)
  spt:runAction(action)
  
  -- combine skill words
  local spt = _res(combineInfo.words)
  local sptSize = spt:getContentSize()
  local sptPos = ccp(pos.x + display.width + sptSize.width * 0.5,pos.y - 100)
  spt:setPosition(sptPos)
  self:addChild(spt,99)
  
  local seg1 = 200
  local seg2 = display.width - seg1
  local array = CCArray:create()
  local moveIn = CCMoveBy:create(anim_duration * 0.3,ccp(-sptSize.width * 0.5 - seg1,0))
  local fadeIn = CCFadeIn:create(anim_duration * 0.3)
  local anim1 = CCEaseOut:create(CCSpawn:createWithTwoActions(moveIn,fadeIn),0.2)
  array:addObject(anim1)
  local delay = CCDelayTime:create(anim_duration * 0.4)
  array:addObject(delay)
  local moveOut = CCMoveBy:create(anim_duration * 0.3,ccp(-sptSize.width * 0.5 - seg2,0))
  local fadeOut = CCFadeOut:create(anim_duration * 0.3)
  local anim2 = CCEaseOut:create(CCSpawn:createWithTwoActions(moveOut,fadeOut),0.2)
  array:addObject(anim2)
  local remove = CCRemoveSelf:create()
  array:addObject(remove)
  local action = CCSequence:create(array)
  spt:runAction(action)
  
  self:wait(anim_duration)]]
  
  local node = display.newNode()
  self:addChild(node,99)
  node:setPosition(pos)
  
  local str = skillInfo.skill_name
  local tab = {}
  local _, count = string.gsub(str, "[^\128-\193]", "")
  for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do 
    tab[#tab+1] = uchar 
  end
  
  local params = 
  {
    {
      name = "skill_name1",
      type = "CCLabelBMFont"
    },
    {
      name = "skill_name2",
      type = "CCLabelBMFont"
    },
    {
      name = "skill_name3",
      type = "CCLabelBMFont"
    },
    {
      name = "skill_name4",
      type = "CCLabelBMFont"
    }
  }
  
  local anim,offsetX,offsetY,d,isFlipY,params = _res(combineInfo.img,params)
  
  for key, pro in ipairs(params) do
    local labelName = pro.name
    local label = anim[labelName]
    assert(label ~= nil)
    label:setString(tab[key])
  end

  anim:setPosition(ccp(offsetX,offsetY))
  anim:setFlipY(isFlipY)  

  anim:getAnimation():play("default") 
  node:addChild(anim,999)

  self:performWithDelay(function ()
    node:removeFromParentAndCleanup(true)
  end,d)

  self:wait(d + 0.8)
  
  
  self._combineSkillCount = self._combineSkillCount + 1
end

function BattleView:updateRound(_round)
  _round = _round or 1
  if self._sptRound ~= nil then
      self._sptRound:setString(_tr("Round:%{round}/%{max_round}",{round = _round,max_round = BattleConfig.MaxRound}))
  end
end

function BattleView:updateDropCount(_count)
  _count = _count or 1
  if self._sptCount ~= nil then
      self._sptCount:setString(_count.."")
  end
end

function BattleView:shake(speed,times)
  speed = speed or 1.0
  times = times or 2
  local DefaultDuration = 0.25 * speed
  local duration = DefaultDuration * times / 2.0
  local gap = 0.5 * speed
  local strength = 8.0
  local target = self
  local array = CCArray:create()
  local s_duration = duration/(times * 2)
  local origin_x,origin_y = target:getPosition()
--  print("origin_x:"..origin_x..",origin_y:"..origin_y)
  for i=1, times do
    local s_x =  strength + math.random(strength * 100)/100.0
    local s_y =  strength + math.random(strength * 100)/100.0
    array:addObject(CCMoveBy:create(s_duration,ccp(s_x,s_y)))
    array:addObject(CCMoveBy:create(s_duration,ccp(-s_x,-s_y)))
  end
  local action = CCSequence:create(array)
  target:runAction(action)
  return duration + gap
end

function BattleView:wait(duration)
  local cur = coroutine.running()
  self:performWithDelay(function () 
  local success,error = coroutine.resume(cur)
    if not success then
      printf("coroutine error:"..error)
      print(debug.traceback(cur, error)) 
    end
  end,duration * CONFIG_DEFAULT_ANIM_DELAY_RATIO)
  coroutine.yield()

end

function BattleView:onEnter()
  printf("BattleView:onEnter")
  Guide:Instance():removeGuideLayer()
  --CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,BattleView.battleGuideTrggier),GuideConfig.GuideLayerRemoved)
end

function BattleView:removeBattleAnimation()
   if self._animationNode ~= nil then
     self._animationNode:removeFromParentAndCleanup(true)
     self._animationNode = nil
   end
end

function BattleView:onExit()
  printf("BattleView:onExit")
  self:removeBattleAnimation()
  
  local arenaView = self:getArenaView()
  if arenaView ~= nil then
     arenaView:removeFromParentAndCleanup(true)
     self:setArenaView(nil)
  end
  
  self:removeTimeCountDown()
  --CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,GuideConfig.GuideLayerRemoved)
  net.unregistAllCallback(self)
end

--[[function BattleView:removeGuideLayer()
  --CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,GuideConfig.GuideLayerRemoved)
  Guide:Instance():removeGuideLayer()
  --CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,BattleView.battleGuideTrggier),GuideConfig.GuideLayerRemoved)
end]]

function BattleView:showButtons(show)

    if show == nil then
       show = true
    end

    if self._startBtn ~= nil then
       self._startBtn:setVisible(show)
    end
    
    if self._backBtn ~= nil then
       self._backBtn:setVisible(show)
       if self:getBattleData():getFightType() ~= "PVE_NORMAL" 
       and self:getBattleData():getFightType() ~= "PVE_ACTIVITY" 
       and self:getBattleData():getFightType() ~= "PVE_GUILD"
       and self:getBattleData():getFightType() ~= "PVE_BABLE"
       then
         self._backBtn:setVisible(false)
       end
    end
    
    if self._skillRangeInfo ~= nil then
  		if not self._isStartPlayer 
  		or self:getBattleData():getFightType() ~= "PVP_REAL_TIME"  
  		then
  			self._skillRangeInfo:setVisible(show)
  		end
    end
end

function BattleView:battleGuideTrggier()
  self.isLocked = false
  Guide:Instance():removeGuideLayer()
  
  if self._enabledGuideAttackOrder == true then
     if self._guideAnimation == nil then
       local pkg = ccbRegisterPkg.new(self)
       pkg:addProperty("mAnimationManager","CCBAnimationManager")
       local layer,owner = ccbHelper.load("anim_AttackOrder.ccbi","anim_AttackOrderCCB","CCLayer",pkg)
       self._guideAnimation = layer
       self:addChild(self._guideAnimation,999)
     end
  end
  _executeNewBird()
	self:showButtons(true)
end

function BattleView:tipMoveCard(startPos,toPos)
      self._targetGuidePos = toPos
      local fieldViews = {}
      local fieldViewStart = nil
      local fieldViewTarget = nil
      if self._backBtn ~= nil then
        self._backBtn:removeFromParentAndCleanup(true)
        self._backBtn = nil 
      end
    
       fieldViewStart = self:getFieldViewByPos(startPos)
       fieldViewTarget = self:getFieldViewByPos(toPos)
       table.insert(fieldViews,fieldViewStart)
       table.insert(fieldViews,fieldViewTarget)
       
       self._fieldView = fieldViews
       
       local cardsViews = {}
       local moveEnabledCardViewStart = self:getCardViewByCardPos(startPos)
       local moveEnabledCardViewTarget = self:getCardViewByCardPos(toPos)
       
       if moveEnabledCardViewStart ~= nil then
          table.insert(cardsViews,moveEnabledCardViewStart)
       end
       
       if moveEnabledCardViewTarget ~= nil then
          moveEnabledCardViewTarget:setDragEnabled(false)
          table.insert(cardsViews,moveEnabledCardViewTarget)
       end
       
       self._cardsView = cardsViews
       
       self._tipMove = GuideBattleView.new()
       self:addChild(self._tipMove,9999)
       self._tipMove:startMove(self:getPosByIndex(startPos),self:getPosByIndex(toPos))
       --hideButtons()
       self:showButtons(false)
end

function BattleView:showReviewDamageCount(result)
  self:hideSpeedButtons()
  self:removeSkipButton()
  self:removeGreySkipButton()
  self._battleDamageCount = BattleDamageCountView.new(result,true,self._isLocalFight)
  self:addChild(self._battleDamageCount,1000)
end 
