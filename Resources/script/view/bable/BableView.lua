
require("view.component.ViewWithEave")
require("model.bable.Bable")
require("view.card_soul.PopShopListView")

local BablePop = require("view.bable.BablePop")
local BableView = class("BableView", ViewWithEave)

function BableView:ctor()
  BableView.super.ctor(self)
  self:setTabControlEnabled(false)
  -- self:setScrollBgVisible(false)

  local pkg = ccbRegisterPkg.new(self)

  pkg:addFunc("bonusCallback",BableView.bonusCallback)
  pkg:addFunc("assistCallback",BableView.assistCallback)
  pkg:addFunc("shopCallback",BableView.shopCallback)
  pkg:addFunc("resetCallback",BableView.resetCallback)
  pkg:addFunc("battleCallback",BableView.battleCallback)
  pkg:addFunc("reviveCallback",BableView.reviveCallback)
  pkg:addFunc("fetchPassBonus",BableView.fetchPassBonus) 

  pkg:addProperty("node_cardInfo","CCNode")
  pkg:addProperty("node_card","CCNode")
  pkg:addProperty("node_progress","CCNode")
  pkg:addProperty("node_bonus","CCNode")

  pkg:addProperty("menuItem_award","CCMenuItemSprite")
  pkg:addProperty("menu_reset","CCMenuItemSprite")
  pkg:addProperty("menu_battle","CCMenuItemSprite")
  pkg:addProperty("menu_revive","CCMenuItemSprite")
  pkg:addProperty("menu_assist","CCMenuItemSprite")

  pkg:addProperty("sprite_box_frame","CCSprite")
  pkg:addProperty("sprite_finish_tip","CCSprite")

  pkg:addProperty("label_layerIndex","CCLabelBMFont")
  pkg:addProperty("label_name","CCLabelTTF")
  pkg:addProperty("label_leftResetCount","CCLabelTTF")
  

  local layer,owner = ccbHelper.load("BableView.ccbi","BableViewCCB","CCLayer",pkg)
  self:getEaveView():getNodeContainer():addChild(layer)

  self.org_y = self.node_cardInfo:getPositionY()
end


function BableView:onEnter()
  self.leftCount = 0 
  self.layerMax = #AllConfig.bable 
  print("===bable id Max", self.layerMax)
  self:setTitleTextureName("bable_title.png")

  net.registMsgCallback(PbMsgId.ReqBableResetResultS2C, self, BableView.resetResult)
  net.registMsgCallback(PbMsgId.ReqBableReliveResultS2C, self, BableView.reviveResult)

  self:initStageInfo()

  _registNewBirdComponent(125001, self.menu_assist)
  _executeNewBird()

end 

function BableView:onExit()
  net.unregistAllCallback(self)
end 

function BableView:onHelpHandler()
  local help = HelpView.new()
  help:addHelpBox(1061,nil,true)
  self:getDelegate():getScene():addChild(help, 1000)
end 

function BableView:onBackHandler()
  self:getDelegate():goBackView()
end 

function BableView:bonusCallback()
  local view = BablePop.new(1)
  view:setDelegate(self:getDelegate())
  view:setCallbackWhenExit(handler(self,BableView.updateBonusFetchTips))
  view:setScale(0.2)
  view:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))
  self:addChild(view)
end 

function BableView:assistCallback(disAbleAnim)
  local view = BablePop.new(2)
  view:setDelegate(self:getDelegate())
  if disAbleAnim ~= true then 
    view:setScale(0.2)
    view:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))
  end 
  self:addChild(view)
end 

function BableView:shopCallback()
  local view = PopShopListView.new(ShopCurViewType.Bable)
  self:addChild(view) 
end 

--重置
function BableView:resetCallback()
  local function reqToReset()
    net.sendMessage(PbMsgId.ReqBableResetC2S) 
    _showLoading()
  end 


  if self.leftCount <= 0 then 
    local pop = PopupView:createTextPopup(_tr("times_used_out"), nil, true)
    self:addChild(pop)    
  else 
    local strTip = ""
    local bableInfo = Bable:instance():getBableInfo()
    if bableInfo then 
      if bableInfo.bable_id > self.layerMax then 
        return 
      end 

      local pass, awarded = Bable:instance():getAwardInfoById(bableInfo.bable_id-1) 
      if pass and awarded == false then --通关未领取
        strTip = _tr("reset_when_has_bonus")
      else       
        strTip = _tr("reset_bable_tips")
      end 
      local pop = PopupView:createTextPopupWithPath({text = strTip, leftCallBack = function() return reqToReset() end})
      self:addChild(pop,100)  
    end 
  end 
end 

function BableView:resetResult(action,msgId,msg)
  echo("=== resetResult:", msg.state)

  _hideLoading()
  if msg.state == "Success" then 
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)

    self:initStageInfo()
  else 
    Bable:instance():handleErrorCode(msg.state)
  end 
end 

--战斗
function BableView:battleCallback()
  local bableInfo = Bable:instance():getBableInfo()
  if bableInfo.bable_id > self.layerMax then 
    return 
  end 

  local stageId = AllConfig.bable[bableInfo.bable_id].stage_id
  Bable:instance():reqFightCheck(stageId)
end 

--复活
function BableView:reviveCallback()
  local function reqToRevive()
    net.sendMessage(PbMsgId.ReqBableReliveC2S) 
    _showLoading()
  end 

  local function useMoneyToRevie(needMoney, ownMoney)
    if ownMoney >= needMoney then 
      reqToRevive()
    else 
      GameData:Instance():notifyForPoorMoney()  
    end
  end 

  --当前没有可复活的武将
  if Bable:instance():hasCardToRelived() == false then 
    Toast:showString(curScene, _tr("no_card_for_revive"), ccp(display.cx, display.cy)) 
    return 
  end 

  local ownCount = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(22401013)
  if ownCount > 0 then --使用道具复活
    local strTip = _tr("use_%{name}_to_revive", {name=AllConfig.item[22401013].item_name})
    local pop = PopupView:createTextPopupWithPath({text = strTip, leftCallBack = function() return reqToRevive() end})
    self:addChild(pop,100)    
  else 
    local needMoney = AllConfig.bable_init[1].cost 
    local ownMoney = GameData:Instance():getCurrentPlayer():getMoney()
    local strTip = _tr("use_money_to_revive_%{name}_%{count}", {name=AllConfig.item[22401013].item_name, count=needMoney})
    local pop = PopupView:createTextPopupWithPath({text = strTip, leftCallBack = function() return useMoneyToRevie(needMoney, ownMoney) end})
    self:addChild(pop,100)  
  end 
end 

function BableView:reviveResult(action,msgId,msg)
  echo("=== reviveResult:", msg.state)

  _hideLoading()
  if msg.state == "Success" then 
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
  else 
    Bable:instance():handleErrorCode(msg.state)
  end 
end 

function BableView:initStageInfo()
  local bableInfo = Bable:instance():getBableInfo()
  echo("===initStageInfo:", bableInfo)  
  self.sprite_finish_tip:setVisible(false)

  if bableInfo then 
    local pass, awarded = Bable:instance():getAwardInfoById(bableInfo.bable_id-1) 
    echo("=== bable_id, pass, awarded:", bableInfo.bable_id-1, pass, awarded)

    self:updateBonusFetchTips()

    if pass and awarded == false then --通关未领取
      self.node_cardInfo:setVisible(false)
      self.label_layerIndex:setString(string.format("%d", bableInfo.bable_id-1))

      self:showStagePassAnim()
    else 

      self.label_layerIndex:setString(string.format("%d", math.min(bableInfo.bable_id, self.layerMax)))

      if bableInfo.bable_id <= self.layerMax then 
        local stageId = AllConfig.bable[bableInfo.bable_id].stage_id 
        self.node_cardInfo:setVisible(true)
        self:showCardImg(bableInfo.bable_id)
        self:updateProgress(bableInfo.bable_id)
        self:updateResetCount() 
        self.label_name:setString(AllConfig.stage[stageId].stage_name)
      else 
        self.sprite_finish_tip:setVisible(true)
        self.node_cardInfo:setVisible(false)
      end 
    end 
  end 
end 

function BableView:fetchPassBonus()
  local bableInfo = Bable:instance():getBableInfo()
  local pass, awarded = Bable:instance():getAwardInfoById(bableInfo.bable_id-1) 
  echo("===fetchPassBonus: bable_id, pass, awarded:", bableInfo.bable_id-1, pass, awarded)

  if pass and awarded == false and bableInfo.bable_id > 1 then --通关未领取
    GameData:Instance():getCurrentPlayer():reqQueryAwardC2S(bableInfo.bable_id-1, "BABLE_AWARD", handler(self, BableView.fetchPassBonusResult))
  else 
    echo("===invalid state to fetch bonus...")
  end 
end 

function BableView:fetchPassBonusResult(state)
  echo("=== fetchPassBonusResult:", state)
  if state == "NO_ERROR_CODE" then
    self:performWithDelay(function () self:playCardInfoDownAnim() end, 1.0)
  end 
end 

function BableView:showCardImg(bableId)
  self.node_card:removeAllChildrenWithCleanup(true)

  local item = AllConfig.bable[bableId]
  if item then 
    local stage = AllConfig.stage[item.stage_id]
    if stage then 
      local img = _res(stage.unit_head_pic)
      if img then 
        img:setAnchorPoint(ccp(0.5, 0))
        img:setScale(550/img:getContentSize().height)
        self.node_card:addChild(img)

        local action = CCMoveBy:create(1.5, ccp(0, 30))
        local action2 = CCMoveBy:create(1.5, ccp(0, -30))
        local seq = CCSequence:createWithTwoActions(action,action2)
        img:runAction(CCRepeatForever:create(seq))        
      end 
    end 
  end 
end 

function BableView:updateProgress(bableId)
  if self.progresser == nil then 
    local bg = CCSprite:createWithSpriteFrameName("bable_progress_bg.png")
    local fg1 = CCSprite:createWithSpriteFrameName("bable_progress_fg.png")
    self.progresser = ProgressBarView.new(bg, fg1)
    self.node_progress:addChild(self.progresser)
  end 

  local percent = Bable:instance():getHpPercent(bableId)
  self.progresser:setPercent(percent)
end 


function BableView:updateResetCount()
  local viplevel = GameData:Instance():getCurrentPlayer():getVipLevel()
  local maxCount = AllConfig.vipinitdata[viplevel+1].vip_bable_reset 
  local usedCount = Bable:instance():getResetTimes()
  self.leftCount = math.max(0, maxCount-usedCount)
  echo("===reset count, used, max", usedCount, maxCount)
  self.label_leftResetCount:setString(_tr("left_reset_%{count}", {count=self.leftCount}))
end 

function BableView:playCardInfoDownAnim()
  echo("===playCardInfoDownAnim")
  self.node_bonus:setVisible(false)
  self.node_cardInfo:setVisible(true)

  self.node_cardInfo:setPositionY(display.height)
  self:initStageInfo()
  self.node_cardInfo:runAction(CCEaseElasticOut:create(CCMoveBy:create(1.5, ccp(0, self.org_y-display.height)),0.6))
end 

function BableView:showStagePassAnim()
  self.node_bonus:setVisible(true)
  self.node_cardInfo:setVisible(false)

  local action = CCSequence:createWithTwoActions(CCFadeTo:create(1.0, 100),CCFadeTo:create(1.0, 255))
  self.sprite_box_frame:runAction(CCRepeatForever:create(action))  

  --star shinning effect
  if self.shinning1 then 
    self.shinning1:removeFromParentAndCleanup(true)
    self.shinning1 = nil 
  end 
  if self.shinning2 then 
    self.shinning2:removeFromParentAndCleanup(true)
    self.shinning2 = nil 
  end 
  self.shinning1 = _res(6010011)
  if self.shinning1 ~= nil then     
    self.shinning1:setPosition(ccp(-15, -140))
    self.node_bonus:addChild(self.shinning1)
  end

  self.shinning2 = _res(6010011)
  if self.shinning2 ~= nil then     
    self.shinning2:setPosition(ccp(15, -140))
    self.node_bonus:addChild(self.shinning2)
  end
end 

function BableView:updateBonusFetchTips()
  echo("=== updateBonusFetchTips")
  if self.menuItem_award:getChildByTag(123) then 
    self.menuItem_award:removeChildByTag(123)
  end 
  if Bable:instance():hasBonusForFetch() then 
    local tip = TipPic.new() 
    local size = self.menuItem_award:getContentSize()
    tip:setTag(123)
    tip:setPosition(ccp(size.width, size.height))
    self.menuItem_award:addChild(tip)
  end 
end 

return BableView
