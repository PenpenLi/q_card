require("view.BaseView")

MapFlag = class("MapFlag", BaseView)

function MapFlag:ctor(checkPointData,touchIdx)
  self:setNodeEventEnabled(true)
  self:setCascadeOpacityEnabled(true)
  
  self:setAnchorPoint(ccp(0.5,0.5))
  
  local mapFlagCon = display.newNode()
  self:addChild(mapFlagCon)
  mapFlagCon:setCascadeOpacityEnabled(true)
  self._mapFlagCon = mapFlagCon
  self._mapFlagCon:setPositionY(40)
  
  self:setContentSize(CCSizeMake(200,200))

  local pkg = ccbRegisterPkg.new(self)
  -- regist property
  pkg:addProperty("star1","CCSprite")
  pkg:addProperty("star2","CCSprite")
  pkg:addProperty("star3","CCSprite")
  pkg:addProperty("greyStar1","CCSprite")
  pkg:addProperty("greyStar2","CCSprite")
  pkg:addProperty("greyStar3","CCSprite")
  pkg:addProperty("greyStars","CCNode")
  pkg:addProperty("btnMapFlag","CCControlButton")
  
  
  pkg:addProperty("labelFlagProgress","CCLabelBMFont")
  pkg:addFunc("onClickHandler",MapFlag.onClickHandler)
  
  local flagView,owner = ccbHelper.load("MapFlag.ccbi","MapFlagCCB","CCNode",pkg)
  self:addChild(flagView)
  
  if touchIdx ~= nil then
   self.btnMapFlag:setTouchPriority(touchIdx)
  end
  
  local icon_count_up = display.newSprite("#map_count_up.png")
  self:addChild(icon_count_up,10)
  icon_count_up:setPositionY(45)
  icon_count_up:setVisible(false)
  self._icon_count_up = icon_count_up
  
  local icon_can_buy = display.newSprite("#map_can_buy.png")
  self:addChild(icon_can_buy,10)
  icon_can_buy:setPositionY(45)
  icon_can_buy:setVisible(false)
  self._icon_can_buy = icon_can_buy
  
  if checkPointData ~= nil then
    self:setData(checkPointData)
  end

  self._dragged = false
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch))
end

function MapFlag:onTouch(event,x,y)
  if event == "began" then
     self._startX = x
     self._startY = y
     self._dragged = false
     return true
  elseif event == "ended" then
     if math.abs(self._startX - x) > 10 or math.abs(self._startY - y) > 10 then
        self._dragged = true
     end
  end
end

function MapFlag:alertPop(stage)
  if self:getData() ~= nil then
    local pop = nil
    if self:getData():getState() ~= StageConfig.CheckPointStateClose then
      if GameData:Instance():getCurrentPlayer():isEnabledEnterBattle() == true then
        local difficultyType = nil 
        if stage ~= nil then
           difficultyType = stage:getDifficultyType()
        end
        self:getDelegate():popCheckPoint(self._checkPointData,difficultyType)
      end
    else
       echo("locked")
       if self:getData():getReqLevel() > GameData:Instance():getCurrentPlayer():getLevel() then
          Toast:showString(GameData:Instance():getCurrentScene(), _tr("unlock_condition_%{lv}", {lv=self:getData():getStages()[1]:getRequiredCharLevel()}), ccp(display.cx, display.height*0.4))
       else
          local str = ""
          if self:getData():getStageType() == StageConfig.StageTypeGuild then

          else
            str = _tr("unlock_after_conplete_pre_stage")
            Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.height*0.4))
          end
       end
    end
  end
end

function MapFlag:onClickHandler()
  if self._dragged == true then
     return
  end
  
  if self:getParent().enabledAlert == false then
    return
  end
  
  self._mapFlagCon:stopAllActions()
--  local m_pos = ccp(self:getData():getPosition().x,self:getData():getPosition().y)
--  self:setPosition(m_pos)
  self._mapFlagCon:setScale(1.0)
  local duration = 0.07
  --local moveby = CCEaseIn:create(CCMoveBy:create(duration, ccp(0,20)), duration)
  --local scaleto = CCScaleTo:create(duration, 1.1)
  --local action1 = CCSpawn:createWithTwoActions(moveby, scaleto)
  local action1 = CCScaleTo:create(duration, 1.3)

--  local moveby2 = CCEaseIn:create(CCMoveBy:create(duration, ccp(0,-20)), duration)
--  local scaleto2 = CCScaleTo:create(duration, 1.0)
--  local action2 = CCSpawn:createWithTwoActions(moveby2, scaleto2)

  local action2 = CCScaleTo:create(duration, 1.0)

  local array = CCArray:create()
  array:addObject(action1)
  array:addObject(action2)
  array:addObject(CCCallFunc:create(function()
    self:alertPop()
  end))
  local seq = CCSequence:create(array)
  self._mapFlagCon:runAction(seq)
  
end

function MapFlag:forceShowMarkEffect()
  if self._checkPointData:getState() == StageConfig.CheckPointStateClose then
     return
  end
  
  if self._tipArrow == nil then
     local tipArrow = CCSprite:create("img/guide/guide_finger.png")
     tipArrow:setAnchorPoint(ccp(0,0.5))
     tipArrow:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleBy:create(0.3, 0.95),CCScaleTo:create(0.325, 1,1))))
     self:addChild(tipArrow,100)
  else
     self._tipArrow:setVisible(true)
  end
end

function MapFlag:setData(checkPointData)
  self._checkPointData = checkPointData
  self:setFlagType(self._checkPointData:getStageType())
  self:setGrade(self._checkPointData:getGrade())
  --self.greyStars:setVisible(false)
  self._icon_count_up:setVisible(false)
  self._icon_can_buy:setVisible(false)
  
  self._mapFlagCon:removeAllChildrenWithCleanup(true)
 
  local showGuildStageprogress = function()
    if self._checkPointData:getStageType() == StageConfig.StageTypeGuild then
      local progressBar_bg = display.newSprite("#map_flag_progress1.png")
      local progressBar_green = display.newSprite("#map_flag_progress.png")
      local progressBar = ProgressBarView.new(progressBar_bg, progressBar_green)
      progressBar:setPositionY(-58)
      progressBar:setPercent(0, 1)
      self._mapFlagCon:addChild(progressBar,9)
      
      local label = CCLabelBMFont:create("", "client/widget/words/card_name/number_skillup.fnt")
      local labelSize = tolua.cast(label:getContentSize(),"CCSize")  
      progressBar:addChild(label)
      label:setPosition(ccp(9,-2))
  
      local percent = math.floor((self._checkPointData:getStages()[1]:getProgress()/10000)*100)
      progressBar:setPercent(percent, 1)
      label:setString(percent.."%")
    end
  end
  
  local showGreyFlag = function()
     local grayIcon = nil
     if self._flagRes.filePath ~= nil then
      grayIcon = GraySprite:create(self._flagRes.filePath)
     elseif self._flagRes.frameName ~= nil then
      grayIcon = GraySprite:createWithSpriteFrameName(self._flagRes.frameName)
     end
     
     if grayIcon ~= nil then
       self._mapFlagCon:removeAllChildrenWithCleanup(true)
       self._mapFlagCon:addChild(grayIcon)
       self._flagRes = grayIcon
     end
    
     showGuildStageprogress()
     self._mapFlagCon:setOpacity(125)
  end
  
  showGuildStageprogress()
  
  if checkPointData:getPosition() ~= nil then
     self:setPosition(checkPointData:getPosition().x,checkPointData:getPosition().y)
  end
  
  local flagRes = _res(AllConfig.chapter[checkPointData:getChapter():getId()].checkpoint_icons[checkPointData:getIndex()])
  assert(flagRes ~= nil)
  self._flagRes = flagRes
  self._mapFlagCon:addChild(flagRes)
  
  if checkPointData:getIsElite() == true then
    local starbg = nil
    if checkPointData:getIndex() >= 10 then
       starbg = _res(3060654)
    else
       starbg = _res(3060653)
    end
    if starbg ~= nil then
      self._mapFlagCon:addChild(starbg)
    end
  end
  
  if self._checkPointData:getState() == StageConfig.CheckPointStateOpen then
     if self._anim == nil then
       local isElite = self._checkPointData:getIsElite()
       local resId = 5020158
       if isElite == true then
          resId = 5020203
       end
       local anim,offsetX,offsetY = _res(resId)
       --anim:setScale(1.5)
       anim:setPosition(ccp(offsetX,offsetY + 130))
       self:addChild(anim,100)
       anim:getAnimation():setIsLoop(1)
       anim:getAnimation():play("default")
       self._anim = anim
       
       resId = 5020159
       if isElite == true then
          resId = 5020204
       end
       local anim_bottom,offsetX_bottom,offsetY_bottom = _res(resId)
       --anim:setScale(1.5)
       anim_bottom:setPosition(ccp(offsetX_bottom,offsetY_bottom+47))
       self:addChild(anim_bottom,-100)
       anim_bottom:getAnimation():setIsLoop(1)
       anim_bottom:getAnimation():play("default")
       self._anim_bottom = anim_bottom
       self:setZOrder(99)
     else
       self._anim:setVisible(true)
       self._anim_bottom:setVisible(true)
     end
  else
     if self._anim ~= nil then
       self._anim:setVisible(false)
     end
     
     if self._checkPointData:getStageType() == StageConfig.StageTypeGuild then
      showGreyFlag()
     end
  end
  
  local proStr = self._checkPointData:getChapter():getId().."-"..self._checkPointData:getIndex()
  if self._checkPointData:getStageType() == StageConfig.StageTypeGuild then
    proStr = ""
  end
  self.labelFlagProgress:setString(proStr)
  
--  if self._checkPointData:getState() == StageConfig.CheckPointStateClose or self._checkPointData:getState() == StageConfig.CheckPointStateOpen then
--     --self:setFlagType(0)
--     --self.greyStars:setVisible(false)
--  else
     --if self._checkPointData:getGrade() > 0 then
       self.greyStars:setVisible(true)
       self.greyStar1:setVisible(false)
       self.greyStar2:setVisible(false)
       self.greyStar3:setVisible(false)
       for key, stage in pairs(self._checkPointData:getStages()) do
           self["greyStar"..key]:setVisible(true)
       end
       
       local stagesCount =  #self._checkPointData:getStages()
       self.greyStars:setPositionX(2)
       self.greyStars:setPositionY(-4)
       if stagesCount == 1 then
          --self.star1:setPositionX(0)
          --self.greyStar1:setPositionX(0)
          self.greyStars:setPositionX(25.0)
          self.greyStars:setPositionY(-6)
       elseif stagesCount == 2 then
          self.greyStars:setPositionX(10.0)
          self.greyStars:setPositionY(-5)
          --self.star1:setPositionX(-15)
          --self.greyStar1:setPositionX(-15)
          
          --self.star2:setPositionX(15)
          --self.greyStar2:setPositionX(15)
       end
       
       --getStages
       --if self.greyStar1
     --end
 -- end
 
  self.greyStars:setVisible(not (self._checkPointData:getStageType() == StageConfig.StageTypeGuild))
  
  
  
  
  local chapter = checkPointData:getChapter()
  local checkPoints = {}
  if checkPointData:getStageType() == StageConfig.StageTypeNormal 
  or checkPointData:getStageType() == StageConfig.StageTypeElite 
  or checkPointData:getStageType() == StageConfig.StageTypeGuild
  then
        local checkPoints = {}
        if checkPointData:getStageType() == StageConfig.StageTypeNormal
        or checkPointData:getStageType() == StageConfig.StageTypeGuild
        then
           checkPoints = chapter:getNormalCheckPoints()
        elseif checkPointData:getStageType() == StageConfig.StageTypeElite then
           checkPoints = chapter:getEliteCheckPoints()
        end
        
        if checkPointData:getStageType() ~= StageConfig.StageTypeGuild then
          if checkPoints[checkPointData:getIndex()-1] ~= nil then
             if checkPoints[checkPointData:getIndex()-1]:getState() ~= StageConfig.CheckPointStateClose
             and checkPoints[checkPointData:getIndex()-1]:getState() ~= StageConfig.CheckPointStateOpen
             then
               self:setVisible(true)
             else
               --self:setVisible(false)
               showGreyFlag()
             end
          else
             self:setVisible(true)
          end
        end
        
        self:showMapFlagState()
      
   elseif checkPointData:getStageType() == StageConfig.StageTypeNormalHide then

       checkPoints = chapter:getNormalCheckPoints()
       echo(table.getn(checkPoints))
       local shouldShowFlag = true
       for key, checkPoint in pairs(checkPoints) do
          
           if checkPoint:getStageType() == StageConfig.StageTypeNormal 
           or checkPoint:getStageType() == StageConfig.StageTypeGuild
           then
              if checkPoint:getState() ~= StageConfig.CheckPointStateFinished then
                 shouldShowFlag = false
                 break
              end
           end
       end
       
       if shouldShowFlag == true then
          self:setVisible(true)
       else
          self:setVisible(false)
          --self.menuFlag:setOpacity(125)
       end
       self:showMapFlagState()
   elseif checkPointData:getStageType() == StageConfig.StageTypeEliteHide then
       checkPoints = chapter:getEliteCheckPoints()
       local shouldShowFlag = true
       for key, checkPoint in pairs(checkPoints) do
           if checkPoint:getStageType() == StageConfig.StageTypeElite then
              if checkPoint:getState() ~= StageConfig.CheckPointStateFinished then
                 shouldShowFlag = false
                 break
              end
           end
       end
       
       if shouldShowFlag == true then
          self:setVisible(true)
       else
          self:setVisible(false)
          --self.menuFlag:setOpacity(125)
       end
       self:showMapFlagState()
   else
   end
end

function MapFlag:showMapFlagState()
  local stage = self._checkPointData:getStages()[1]
  
  if stage:getStageType() == StageConfig.StageTypeNormalHide then
    if self._anim_bottom ~= nil then
      self._anim_bottom:setVisible(false)
      self._anim:setVisible(false)
    end
  else
     if stage == nil or stage:getIsElite() == false then
       return
     end
  end
  
--  local vipLevelId = GameData:Instance():getCurrentPlayer():getVipLevelId()
--  local todayTotalCanBuy = -1
--  if stage:getBuyCountId() > 0 then
--    assert(AllConfig.vip_privilege[stage:getBuyCountId()] ~= nil,"AllConfig.vip_privilege["..stage:getBuyCountId().."]  error")
--    todayTotalCanBuy = AllConfig.vip_privilege[stage:getBuyCountId()].privilege[vipLevelId]
--    print("vipLevel:",vipLevelId - 1,"todayTotalCanBuy:",todayTotalCanBuy)
--  end
--  local todayTotalCanBuy = stage:getBuyCount()
--  local canBuy = (stage:getBoughtCountToday() < todayTotalCanBuy and stage:getPermitBuy() == true)
  --print(canBuy,Scenario:Instance():getBuyStageCount(),todayTotalCanBuy)
  
  local canBuy = stage:getIsCanBuyToday()
  if stage:getLeftTimesToday() ~= nil then
     if stage:getLeftTimesToday() < 0 then
        -- always open
     elseif stage:getLeftTimesToday() == 0 then
        if stage:getPermitBuy() == false then
            self._icon_count_up:setVisible(true)
            self._icon_can_buy:setVisible(false)
        else
           if canBuy == true then
             self._icon_count_up:setVisible(false)
           else
             self._icon_count_up:setVisible(true)
           end
           self._icon_can_buy:setVisible(canBuy)
        end
     else
        self._icon_count_up:setVisible(false)
        self._icon_can_buy:setVisible(false)
        
        if stage:getStageType() == StageConfig.StageTypeNormalHide then
          if self._anim_bottom == nil then
            local anim,offsetX,offsetY = _res(5020203)
            --anim:setScale(1.5)
            anim:setPosition(ccp(offsetX,offsetY + 130))
            self:addChild(anim,100)
            anim:getAnimation():setIsLoop(1)
            anim:getAnimation():play("default")
            self._anim = anim
          
            local anim_bottom,offsetX_bottom,offsetY_bottom = _res(5020204)
            anim_bottom:setPosition(ccp(offsetX_bottom,offsetY_bottom + 47))
            self:addChild(anim_bottom,-100)
            anim_bottom:getAnimation():setIsLoop(1)
            anim_bottom:getAnimation():play("default")
            self._anim_bottom = anim_bottom
            self:setZOrder(99)
          else
            self._anim_bottom:setVisible(true)
            self._anim:setVisible(true)
          end
        end
       
     end
  end
end

function MapFlag:getData()
  return self._checkPointData
end

------
--  Getter & Setter for
--      MapFlag._flagType  
--      
-----
function MapFlag:setFlagType(flagType)
  self._flagType = flagType
--  self.flagNormal:setVisible(false)
--  self.flagEliteNormal:setVisible(false)
--  self.flagNormalSmallBoss:setVisible(false)
--  self.flagEliteSmallBoss:setVisible(false)
--  self.flagNormalBoss:setVisible(false)
--  self.flagEliteBoss:setVisible(false)
--  self.flagNormalHide:setVisible(false)
--  self.flagEliteHide:setVisible(false)
--  local currentFlag = nil 
--  local chapterId = self:getData():getChapter():getId()
--  if self._flagType == StageConfig.StageTypeNormal then
--     currentFlag = self.flagNormal
--     if self:getData():getIndex() % 3 == 0 then
--        currentFlag = self.flagNormalSmallBoss
--     end
--  elseif self._flagType == StageConfig.StageTypeElite then
--     currentFlag = self.flagEliteNormal
--     if self:getData():getIndex() % 3 == 0 then
--        currentFlag = self.flagEliteSmallBoss
--     end
--  elseif self._flagType == StageConfig.StageTypeWorldBoss then
--     --currentFlag = self.flagNormalBigBoss
--  elseif self._flagType == StageConfig.StageTypeNormalHide then
--     currentFlag =  self.flagNormalHide
--  elseif self._flagType == StageConfig.StageTypeEliteHide then
--     currentFlag =  self.flagEliteHide
--  else
--  end
--  
--  -- then last checkpoint (hide checkpoint)
--  local bossCheckPointIdx = 10
--  if chapterId == 1 then
--     bossCheckPointIdx = 7
--  else
--     bossCheckPointIdx = 10
--  end
--  
--  if self:getData():getIndex() == bossCheckPointIdx then
--    self.flagNormal:setVisible(false)
--    self.flagEliteNormal:setVisible(false)
--    self.flagNormalSmallBoss:setVisible(false)
--    self.flagEliteSmallBoss:setVisible(false)
--    self.flagNormalBoss:setVisible(false)
--    self.flagEliteBoss:setVisible(false)
--    self.flagNormalHide:setVisible(false)
--    self.flagEliteHide:setVisible(false)
--
--    currentFlag = self.flagNormalBoss
--    if self:getData():getStageType() == StageConfig.StageTypeElite then
--        currentFlag = self.flagEliteBoss
--    end
--  end
--  
--  if currentFlag ~= nil then
--     currentFlag:setVisible(true)
--     if self:getData():getState() ~= StageConfig.CheckPointStateClose then
--        currentFlag:setEnabled(true)
--     else
--        currentFlag:setEnabled(false)
--     end
--  end
end

function MapFlag:getFlagType()
  return self._flagType
end

------
--  Getter & Setter for
--      MapFlag._grade 
-----
function MapFlag:setGrade(grade)
  self._grade = grade
  
  self.star1:setVisible(false)
  self.star2:setVisible(false)
  self.star3:setVisible(false)
  self.greyStars:setVisible(true)
  
  if self._grade == 1 then
   self.star1:setVisible(true)
  elseif self._grade == 2 then
   self.star1:setVisible(true)
   self.star2:setVisible(true)
  elseif self._grade == 3 then
   self.star1:setVisible(true)
   self.star2:setVisible(true)
   self.star3:setVisible(true)
  else
   --self.greyStars:setVisible(false)
  end
end

function MapFlag:getGrade()
  return self._grade
end

return MapFlag