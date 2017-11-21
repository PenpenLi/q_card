

require("view.BaseView")


CreateRoleView = class("CreateRoleView", BaseView)

function CreateRoleView:ctor()
  CreateRoleView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("selectCallback",CreateRoleView.selectCallback)
  pkg:addFunc("skillDescCallback",CreateRoleView.skillDescCallback)

  pkg:addProperty("node_card","CCNode")
  pkg:addProperty("node_anim_redfire","CCNode")
  pkg:addProperty("node_anim_bluefire","CCNode")
  pkg:addProperty("node_anim_greenfire","CCNode")

  pkg:addProperty("sprite_bg","CCSprite")
  pkg:addProperty("sprite_arms","CCSprite")
  pkg:addProperty("sprite_cardName","CCSprite")
  pkg:addProperty("sprite_tips","CCSprite")
  pkg:addProperty("arrow_left","CCSprite")
  pkg:addProperty("arrow_right","CCSprite")
  
  pkg:addProperty("bn_select","CCControlButton")
  pkg:addProperty("bn_tips","CCControlButton")

  local layer,owner = ccbHelper.load("CreateRoleView.ccbi","CreateRoleViewCCB","CCLayer",pkg)
  self:addChild(layer)
end

function CreateRoleView:onEnter()
  echo("=== CreateRoleView:onEnter")
  net.registMsgCallback(PbMsgId.NewPlayerCardGiftResultS2C, self, CreateRoleView.selectCardResult)
  -- GameData:Instance():getCurrentScene():setTopVisible(false)
  GameData:Instance():getCurrentScene():setBottomVisible(false)
  self:init()
end 

function CreateRoleView:onExit()
  echo("=== CreateRoleView:onExit")
  net.unregistAllCallback(self)
  -- GameData:Instance():getCurrentScene():setTopVisible(true)
  GameData:Instance():getCurrentScene():setBottomVisible(true)

  --选卡前暂停了等级触发的新手引导，在退出时需要恢复检查(统一放到home处理)
  if GameData:Instance():getCurrentPlayer():getLevel() >= 10 then 
    GameData:Instance():setLevelTrigAtHome(true)
    -- GameData:Instance():getCurrentPlayer():updateNewPlayerGuide() 
  end 
end 

function CreateRoleView:init()
  local viewWidth  = 640
  local priority = -200

  self.bn_select:setTouchPriority(priority-1)
  self.bn_tips:setTouchPriority(priority-1)

  self.cardInfoArray = {
    {"Cr_pic_machao.png", "Cr_name_machao.png", "Cr_tip_machao.png", "Cr_qibin.png", nil, AllConfig.characterinitdata[25].data, self.node_anim_bluefire,3},
    {"Cr_pic_zhangliao.png", "Cr_name_zhangliao.png", "Cr_tip_zhangliao.png", "Cr_qibin.png", nil, AllConfig.characterinitdata[26].data, self.node_anim_greenfire,5},
    {"Cr_pic_taishici.png", "Cr_name_taishici.png", "Cr_tip_taishici.png", "Cr_qibin.png", nil,AllConfig.characterinitdata[27].data, self.node_anim_redfire,4}
  }


  --add cards img
  self.node = display.newNode()

  local ap = ccp(0.4, 0.4)
  for k, v in pairs(self.cardInfoArray) do 
    local img = CCSprite:create("img/Createrole/"..v[1])
    if img == nil then 
      return 
    end 
    
    img:setAnchorPoint(ap)
    self.node:addChild(img)
    self.cardInfoArray[k][5] = img
  end 

  self.imgsize = self.cardInfoArray[1][5]:getContentSize()
  self.curImgIdx = 1 
  self:setCardInfo(self.curImgIdx)
  self:rejustImgPosition(0, false)
  --clipping layer
  local maskLayer = DSMask:createMask(CCSizeMake(viewWidth, display.height))
  self.node:setPosition(ccp(self.imgsize.width*ap.x, self.imgsize.height*ap.y))
  maskLayer:addChild(self.node)
  maskLayer:setPosition(ccp(-viewWidth/2, -self.imgsize.height/2))
  self.node_card:addChild(maskLayer)

  maskLayer:addTouchEventListener(handler(self,self.onTouch), false, priority, true)
  maskLayer:setTouchEnabled(true) 

  --arrow animation
  local act1 = CCSequence:createWithTwoActions(CCFadeTo:create(1.0, 180),CCFadeTo:create(1.5, 255))
  self.arrow_left:runAction(CCRepeatForever:create(act1))
  local act2 = CCSequence:createWithTwoActions(CCFadeTo:create(1.0, 180),CCFadeTo:create(1.5, 255))
  self.arrow_right:runAction(CCRepeatForever:create(act2))

  --滚动提示大箭头
  self.colorLayer = CCLayerColor:create(ccc4(0,0,0,130))
  self:addChild(self.colorLayer)
  local tipArrow = CCSprite:create("img/Createrole/CreateRole_arrow.png")
  if tipArrow ~= nil then 
    tipArrow:setPosition(ccp(display.cx, display.cy+20))
    self.colorLayer:addChild(tipArrow)

    local hand = CCSprite:create("img/guide/guide_finger.png")
    if hand ~= nil then 
      hand:setPosition(ccp(display.cx+50, display.cy+50))
      self.colorLayer:addChild(hand)

      local act1 = CCEaseIn:create(CCMoveBy:create(1.2, ccp(-50, 0)), 1.2)
      local act2 = act1:reverse()--CCMoveBy:create(1.2, ccp(-50, 0))
      local seq = CCSequence:createWithTwoActions(act1,act2)
      hand:runAction(CCRepeatForever:create(seq))
    end 
  end 
  self.colorLayer:addTouchEventListener(function(event, x, y)
                                if event == "began" then
                                  if self.colorLayer ~= nil then 
                                    self.colorLayer:removeFromParentAndCleanup(true)
                                    self.colorLayer = nil 
                                    return true 
                                  end 
                                  return false 
                                end 
                              end,
      false, priority-2, true)
  self.colorLayer:setTouchEnabled(true)
end 

function CreateRoleView:onTouch(event, x,y)
  if event == "began" then
    self.isMoving = false 
    self.touchX = x 
    self.touchBeginX = x 
    return true 

  elseif event == "moved" then
      self.isMoving = true 
      self:rejustImgPosition(x-self.touchX, false)
      self.touchX = x 

  elseif event == "ended" then 
    if self.isMoving == true then 
      -- if math.abs(self.touchBeginX-x) > 30 then 
      self:rejustImgPosition(x-self.touchBeginX, true) 
      -- end 
    end 
  end 
end 


function CreateRoleView:getSortedImg(centerIdx)
  local imgArrLen = #self.cardInfoArray

  if centerIdx <= 0 then 
    centerIdx = imgArrLen
  elseif centerIdx > imgArrLen then 
    centerIdx = 1
  end 

  self.curImgIdx = centerIdx

  local leftIdx, rightIdx
  leftIdx = centerIdx - 1
  rightIdx = centerIdx + 1

  if leftIdx <= 0 then 
    leftIdx = imgArrLen
  end

  if rightIdx > imgArrLen then 
    rightIdx = 1
  end 

  return self.cardInfoArray[leftIdx][5], self.cardInfoArray[centerIdx][5], self.cardInfoArray[rightIdx][5]
end 

function CreateRoleView:rejustImgPosition(offsetX, bAnim)

  local Width = 320
  local c = Width*0.8

  if bAnim == false then 
    local leftImg, centImg, rightImg = self:getSortedImg(self.curImgIdx)

    local x_center = centImg:getPositionX()+offsetX
    x_center = math.min(x_center, c)
    x_center = math.max(x_center, -c)
    
    local s_center = 1.0-math.abs(x_center/Width)
    s_center = math.min(1.0, s_center)
    s_center = math.max(0.6, s_center)
    
    local s_left = 0
    local s_right = 0
    local x_left = 0
    local x_right = 0
    if x_center < 0 then -- center img on the left side
      leftImg:setZOrder(0)
      centImg:setZOrder(2)
      rightImg:setZOrder(1)

      s_left = 0.6
      s_right = 1.6 - s_center
      leftImg:setScale(s_left)
      rightImg:setScale(s_right)
      x_right = (x_center + Width)
      x_left = - x_right

      if x_left >= -c then 
        x_left = -x_center
      end 

    else --on the right side
      leftImg:setZOrder(1)
      centImg:setZOrder(2)
      rightImg:setZOrder(0)

      s_left = 1.6 - s_center
      s_right = 0.6
      leftImg:setScale(s_left)
      rightImg:setScale(s_right)
      x_left = x_center - Width
      x_right = - x_left
      if x_right <= c then 
        x_right = - x_center
      end 
    end 

    centImg:setScale(s_center)
    leftImg:setScale(s_left)
    rightImg:setScale(s_right)
    centImg:setPositionX(x_center)
    leftImg:setPositionX(x_left)
    rightImg:setPositionX(x_right)

    local op_center = (s_center > 0.6) and 255 or 118
    local op_left = (s_left > 0.6) and 255 or 118
    local op_right = (s_right > 0.6) and 255 or 118
    centImg:setOpacity(op_center)
    leftImg:setOpacity(op_left)
    rightImg:setOpacity(op_right)
  else 

    if offsetX > 30 then --goto pre page
      self.curImgIdx = self.curImgIdx - 1
    elseif offsetX < -30 then --goto next page
      self.curImgIdx = self.curImgIdx + 1
    end 

    local leftImg, centImg, rightImg = self:getSortedImg(self.curImgIdx)
    leftImg:stopAllActions()
    centImg:stopAllActions()
    rightImg:stopAllActions()
    leftImg:setZOrder(1)
    centImg:setZOrder(2)
    rightImg:setZOrder(1)
    centImg:setOpacity(255)
    leftImg:setOpacity(118)
    rightImg:setOpacity(118)

    --show move actions
    local duration = 0.3

    local act1 = CCSpawn:createWithTwoActions(CCMoveTo:create(duration, ccp(-c, 0)), CCScaleTo:create(duration, 0.6))
    leftImg:runAction(act1)
    local act2 = CCSpawn:createWithTwoActions(CCMoveTo:create(duration, ccp(c, 0)), CCScaleTo:create(duration, 0.6))
    rightImg:runAction(act2)
 
    local function actEnd()
      self:setCardInfo(self.curImgIdx)

      local act3 = CCMoveBy:create(1.5, ccp(0, 30))
      local act4 = CCMoveBy:create(1.5, ccp(0, -30))
      local seq = CCSequence:createWithTwoActions(act3,act4)
      centImg:runAction(CCRepeatForever:create(seq)) 
    end 
    local spawn = CCSpawn:createWithTwoActions(CCMoveTo:create(duration, ccp(0, 0)), CCScaleTo:create(duration, 1.0))
    local action = CCSequence:createWithTwoActions(spawn, CCCallFunc:create(actEnd))
    centImg:runAction(action)
  end 
end 

function CreateRoleView:setCardInfo(idx)
  if idx >= 1 and idx <= #self.cardInfoArray then 

    local img = self.cardInfoArray[idx][5]
    img:setPosition(ccp(0, 0))

    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.cardInfoArray[idx][2])
    if frame ~= nil then 
      self.sprite_cardName:setDisplayFrame(frame)
    end 

    local frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.cardInfoArray[idx][4])
    if frame1 ~= nil then 
      self.sprite_arms:setDisplayFrame(frame1)
    end 

    local frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.cardInfoArray[idx][3])
    if frame2 ~= nil then 
      self.sprite_tips:setDisplayFrame(frame2)
    end 
    --anim fire
    for k, v in pairs(self.cardInfoArray) do 
      if k == idx then 
        v[7]:setVisible(true)
      else 
        v[7]:setVisible(false)
      end
    end 
  end 
end 

function CreateRoleView:close()
  self:removeFromParentAndCleanup(true)

  local homeController = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
  homeController:enter(true)  
end 

function CreateRoleView:selectCallback()
  if self.curImgIdx >= 1 and self.curImgIdx <= #self.cardInfoArray then 
    local dropId = self.cardInfoArray[self.curImgIdx][6]
    echo("== dropid", dropId)
    --如果10级以下玩家含有该掉落卡，则不允许选择该卡
    local level = GameData:Instance():getCurrentPlayer():getLevel()
    if level <= 10 then 
      local dropdata = AllConfig.drop[dropId].drop_data
      local configId = nil 
      for k, v in pairs(dropdata) do 
        if v.array[1] == 8 then --is card 
          configId = v.array[2]
          break
        end 
      end 
      if configId ~= nil then 
        local unitroot = AllConfig.unit[configId].unit_root
        local battlecards = GameData:Instance():getCurrentPackage():getBattleCards()
        for k, v in pairs(battlecards) do 
          if v:getUnitRoot() == unitroot then 
            Toast:showString(self, _tr("has_same_battle_card"), ccp(display.width/2, display.height*0.4))
            return 
          end 
        end 
      end 
    end 
    _showLoading()
    local data = PbRegist.pack(PbMsgId.NewPlayerCardGiftC2S, {gift = dropId})
    net.sendMessage(PbMsgId.NewPlayerCardGiftC2S, data)

    --self.loading = Loading:show()
    self:addMaskLayer()
  end 
  -- self:close()
end 

function CreateRoleView:skillDescCallback()
  -- local configId = self.cardInfoArray[self.curImgIdx][8]
  -- if configId ~= nil then 
  --   local card = Card.new()
  --   card:initAttrById(configId)
  --   local skillInfoStr = GameData:Instance():formatSkillDesc(card)
  --   echo("==== skillInfoStr:", skillInfoStr)
  --   TipsInfo:showStringTip(skillInfoStr,CCSizeMake(200, 300), nil, self.bn_tips, ccp(35, 60), -300, true, TipDir.LeftDown)
  -- end 
  local skillId = self.cardInfoArray[self.curImgIdx][8]
  local str = AllConfig.cardskill[skillId].skill_description
  TipsInfo:showStringTip(str,CCSizeMake(200, 0), nil, self.bn_tips, ccp(35, 60), -300, true, TipDir.LeftDown)
end 

function CreateRoleView:selectCardResult(action,msgId,msg)
  echo("=== CreateRoleView:selectCardResult:", msg.state)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end 
  _hideLoading()
  self:removeMaskLayer()
  
  if msg.state == "NO_ERROR_CODE" then 

    self.bn_select:setEnabled(false)

    --show gained bonus
    -- local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    -- for i=1,table.getn(gainItems) do
    --   echo("----gained:", gainItems[i].configId, gainItems[i].count)
    --   local str = string.format("+%d", gainItems[i].count)
    --   Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*70), 0.3*(i-1))
    -- end
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)  

    -- self:performWithDelay(function() 
    --                         self:close()
    --                        end, 2.5)
    self:close()
    
  elseif msg.state == "HAS_GET_GIFT" then 
    Toast:showString(self, _tr("has award"), ccp(display.width/2, display.height*0.4))
    self.bn_select:setEnabled(false)
    self:performWithDelay(function() 
                            self:close()
                           end, 1.0)
  elseif msg.state == "GIFT_CODE_ERROR" then 
    Toast:showString(self, _tr("system error"), ccp(display.width/2, display.height*0.4))
  end 
end 

function CreateRoleView:addMaskLayer()
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self:performWithDelay(handler(self, CreateRoleView.removeMaskLayer), 6.0)
end 

function CreateRoleView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 

