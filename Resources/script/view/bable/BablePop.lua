
require("view.BaseView")


local BablePop = class("BablePop", BaseView)

function BablePop:ctor(popType)
  BablePop.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",BablePop.closeCallback)
  pkg:addFunc("fetchBonusForPassBabel",BablePop.fetchDailyFightBonus)
  pkg:addFunc("fetchBonusForAssist",BablePop.fetchAssistBonus)
  pkg:addFunc("confirmCallback",BablePop.confirmCallback)
  pkg:addFunc("selectCardCallback",BablePop.selectCardCallback)

  pkg:addProperty("node_bonus","CCNode") 
  pkg:addProperty("node_shareCard","CCNode") 
  pkg:addProperty("node_card","CCNode") 

  pkg:addProperty("sprite9_bg","CCScale9Sprite")
  pkg:addProperty("layer_mask","CCLayerColor")
  pkg:addProperty("menu_close","CCMenu")
  pkg:addProperty("menu_fetchForPass","CCMenu")
  pkg:addProperty("menu_fetchForAssist","CCMenu")
  pkg:addProperty("menu_confirm","CCMenu")
  pkg:addProperty("menu_card","CCMenu")
  pkg:addProperty("label_battleBonus","CCLabelTTF")
  pkg:addProperty("label_passBabelTip","CCLabelTTF")
  pkg:addProperty("label_preBonus1","CCLabelTTF")
  pkg:addProperty("label_bonus1","CCLabelTTF")
  pkg:addProperty("label_assistBonus","CCLabelTTF")
  pkg:addProperty("label_assistTip","CCLabelTTF")
  pkg:addProperty("label_preBonus2","CCLabelTTF")
  pkg:addProperty("label_bonus2","CCLabelTTF")
  pkg:addProperty("label_assistDesc","CCLabelTTF")
  pkg:addProperty("menuItem_pass","CCMenuItemSprite")
  pkg:addProperty("menuItem_assist","CCMenuItemSprite")
  pkg:addProperty("menuItem_confirm","CCMenuItemSprite")

  pkg:addProperty("sprite_coin1","CCSprite")
  pkg:addProperty("sprite_coin2","CCSprite")
  pkg:addProperty("sprite_add","CCSprite")
  pkg:addProperty("sprite_addTip","CCSprite")
  pkg:addProperty("sprite_yilingqu1","CCSprite")
  pkg:addProperty("sprite_star1","CCSprite")
  pkg:addProperty("sprite_star2","CCSprite")
  pkg:addProperty("sprite_star3","CCSprite")
  pkg:addProperty("sprite_star4","CCSprite")
  pkg:addProperty("sprite_star5","CCSprite")
  pkg:addProperty("sprite_star6","CCSprite")
  pkg:addProperty("sprite_star7","CCSprite")
  pkg:addProperty("sprite_star8","CCSprite")
  pkg:addProperty("sprite_star9","CCSprite")
  pkg:addProperty("sprite_star10","CCSprite")

 

  local layer,owner = ccbHelper.load("BablePop.ccbi","BablePopCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.priority = -200
  self.popType = popType or 1 
end

function BablePop:onEnter()
  self.menu_close:setTouchPriority(self.priority)
  self.menu_fetchForPass:setTouchPriority(self.priority)
  self.menu_fetchForAssist:setTouchPriority(self.priority)
  self.menu_confirm:setTouchPriority(self.priority)
  self.menu_card:setTouchPriority(self.priority)
  net.registMsgCallback(PbMsgId.BableSetHelpFriendCardResultS2C, self, BablePop.confirmResult)
  net.registMsgCallback(PbMsgId.ReqBableDailyAwardResultS2C, self, BablePop.fetchDailyFightBonusResult)
  net.registMsgCallback(PbMsgId.BableGetHelpFriendAwardResultS2C, self, BablePop.fetchAssistBonusResult)

  --reg touch event
  self:addTouchEventListener(function(event, x, y)
                                if event == "began" then
                                  self.preTouchFlag = self:checkTouchOutsideView(x, y)
                                  return true
                                elseif event == "ended" then
                                  local curFlag = self:checkTouchOutsideView(x, y)
                                  if self.preTouchFlag == true and curFlag == true then
                                    echo(" touch out of region: close popup") 
                                    self:closeCallback()
                                  end 
                                end
                            end,
              false, self.priority+1, true)
  self:setTouchEnabled(true)

  self:showPopByType(self.popType)

end 

function BablePop:onExit()
  net.unregistAllCallback(self)

  if self:getCallbackWhenExit() then 
    self:getCallbackWhenExit()()
  end 
end 

function BablePop:checkTouchOutsideView(x, y)
  local size = self.sprite9_bg:getContentSize()
  local pos = self.sprite9_bg:convertToNodeSpace(ccp(x, y))
  if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
    return true 
  end

  return false  
end 

function BablePop:closeCallback()
  self:removeFromParentAndCleanup(true)
end 

function BablePop:fetchDailyFightBonus()
  net.sendMessage(PbMsgId.ReqBableDailyAwardC2S) 
  _showLoading()
end 


function BablePop:fetchDailyFightBonusResult(action,msgId,msg)
  echo("===fetchDailyFightBonusResult:", msg.state)
  _hideLoading()

  if msg.state == "Success" then 
    self.menuItem_pass:setEnabled(false)
    self.sprite_yilingqu1:setVisible(true)

    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i = 1,table.getn(gainItems) do
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.cx, display.height*0.5-i*40), 0.3*(i-1))
    end

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    
  else 
    Bable:instance():handleErrorCode(msg.state)
  end 
end 


function BablePop:fetchAssistBonus()
  echo("===fetchAssistBonus")
  net.sendMessage(PbMsgId.BableGetHelpFriendAwardC2S) 
  _showLoading()  
end 

function BablePop:fetchAssistBonusResult(action,msgId,msg)
  echo("===fetchAssistBonusResult:", msg.state)

  _hideLoading()

  if msg.state == "Success" then 
    self.menuItem_assist:setEnabled(false)

    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i = 1,table.getn(gainItems) do
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.cx, display.height*0.5-i*40), 0.3*(i-1))
    end

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    
  else 
    Bable:instance():handleErrorCode(msg.state)
  end 
end 


function BablePop:confirmCallback()
  local card = Bable:instance():getSharedCard() 
  local helpCard = Bable:instance():getHelpCardMode()
  if card == nil and helpCard == nil then 
    Toast:showString(curScene, _tr("please select card"), ccp(display.cx, display.cy))
    return 
  end 
  
  if card == nil and helpCard then --用户未设置
    -- Toast:showString(curScene, _tr("same_help_card"), ccp(display.cx, display.cy))
    self:closeCallback()
    return 
  end 

  if card and helpCard and card:getConfigId()==helpCard:getConfigId() then --用户选择同一卡牌
    self:closeCallback()
    return     
  end 


  local data = PbRegist.pack(PbMsgId.BableSetHelpFriendCardC2S, {card_id=card:getId()})
  net.sendMessage(PbMsgId.BableSetHelpFriendCardC2S, data) 
  _showLoading()
end 

function BablePop:confirmResult(action,msgId,msg)
  echo("===confirmResult:", msg.state)
  _hideLoading()

  if msg.state == "Success" then 
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    self:closeCallback()
  else 
    Bable:instance():handleErrorCode(msg.state)
  end 
end 

function BablePop:selectCardCallback()
  self:getDelegate():disPlayCardListForBable()
end 


function BablePop:showPopByType(popType)
  
  if popType == 1 then -- 今日奖励
    self.node_bonus:setVisible(true)
    self.node_shareCard:setVisible(false)

    self.label_battleBonus:setString(_tr("battle_bonus"))
    self.label_passBabelTip:setString(_tr("pass_one_bable"))
    self.label_preBonus1:setString(_tr("bonus"))
    local dropId = AllConfig.bable_init[1].daily_award_bonus[1]
    if AllConfig.drop[dropId] then 
      local bonus = AllConfig.drop[dropId].drop_data[1].array
      self.label_bonus1:setString(string.format("%d", bonus[3]))
    end 

    local info = Bable:instance():getBableInfo()
    local assistMax = AllConfig.bable_init[1].friend_count 
    local curAssistCount = math.min(info.help_friend_count, assistMax) 
    self.label_assistBonus:setString(_tr("assist_bonus"))
    self.label_assistTip:setString(_tr("assist_friends_pass_bable_%{count}", {count = curAssistCount.."/"..assistMax}))
    self.label_preBonus2:setString(_tr("bonus"))

    self.menuItem_assist:setEnabled(info.help_friend_count>=assistMax)

    local coinBonus = AllConfig.bable_init[1].friend_award * info.help_friend_count 
    self.label_bonus2:setString(string.format("%d", coinBonus))

    -- 当日战斗过, 才可领取奖励
    local fightFlag = Bable:instance():getDailyFightFlag()
    local awardFlag = Bable:instance():getDailyAwardFlag()
    echo("====fightFlag, awardFlag", fightFlag, awardFlag)
    if fightFlag then 
      if not awardFlag then 
        self.menuItem_pass:setEnabled(true)
        self.sprite_yilingqu1:setVisible(false)
      else 
        self.menuItem_pass:setEnabled(false)
        self.sprite_yilingqu1:setVisible(true)
      end 
    else 
      self.menuItem_pass:setEnabled(false)
      self.sprite_yilingqu1:setVisible(false)
    end 

  else --助阵武将

    self.node_bonus:setVisible(false)
    self.node_shareCard:setVisible(true)
    self.label_assistDesc:setString(_tr("assisit_desc"))

    local sharedCard = Bable:instance():getSharedCard() --用户刚从列表选择的助阵卡
    local helpCard = Bable:instance():getHelpCardMode() --系统下发的助阵卡 
    echo("===sharedCard, helpCard", sharedCard, helpCard)
    self:showMidCard(sharedCard or helpCard)
    if sharedCard == nil and helpCard == nil then 
      local action = CCSequence:createWithTwoActions(CCFadeTo:create(0.8, 100),CCFadeTo:create(1.0, 255))
      self.sprite_add:runAction(CCRepeatForever:create(action))
    end 

    _executeNewBird()
  end 
end 

function BablePop:showMidCard(sharedCard)
  self.node_card:removeAllChildrenWithCleanup(true)

  if sharedCard then 
    local midCard = MiddleCardHeadView.new()
    midCard:setCard({card = sharedCard})
    local size = midCard:getContentSize()
    midCard:setScale(135/size.width)
    midCard:setPosition(ccp(-size.width/2, -size.height/2))

    self.node_card:addChild(midCard)

    self:showStarOrNot(true, sharedCard)
  else 
    self:showStarOrNot(false, nil)
  end 
end 

function BablePop:showStarOrNot(bShow, card)
  local starTbl = {self.sprite_star1, self.sprite_star2, self.sprite_star3, self.sprite_star4, self.sprite_star5,
                   self.sprite_star6, self.sprite_star7, self.sprite_star8, self.sprite_star9, self.sprite_star10}

  self.sprite_addTip:setVisible(not bShow)

  for k, v in pairs(starTbl) do 
    v:setVisible(false)
  end 
  
  if bShow and card then 
    local maxGrade = card:getMaxGrade()
    local curGrade = card:getGrade()

    local starW = starTbl[1]:getContentSize().width 
    local posx = self.sprite_addTip:getPositionX() - (maxGrade-1)*starW/2

    for i = 1, 5 do 
      if i <= maxGrade then 
        if i <= curGrade then 
          starTbl[i]:setVisible(true)
          starTbl[i]:setPositionX(posx + (i-1)*starW)
          starTbl[5+i]:setVisible(false)
        else 
          starTbl[5+i]:setVisible(true)
          starTbl[5+i]:setPositionX(posx + (i-1)*starW)
          starTbl[i]:setVisible(false)
        end
      else 
        starTbl[i]:setVisible(false)
        starTbl[5+i]:setVisible(false)
      end
    end
  end 
end 

function BablePop:setCallbackWhenExit(func)
  self._exitFunc = func
end 

function BablePop:getCallbackWhenExit()
  return self._exitFunc
end 

return BablePop
