
require("view.BaseView")
require("view.component.Loading")
require("view.component.PopupView")

ActivityMoneyTree = class("ActivityMoneyTree", BaseView)

function ActivityMoneyTree:ctor()

  ActivityMoneyTree.super.ctor(self)
 
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("startCharge",ActivityMoneyTree.startCharge)
  pkg:addFunc("playFinishCallback",ActivityMoneyTree.playFinishCallback)

  pkg:addProperty("node_coinAnim","CCNode")
  pkg:addProperty("label_costMoney","CCLabelTTF")
  pkg:addProperty("label_gainCoin","CCLabelTTF")
  pkg:addProperty("label_count","CCLabelTTF")
  pkg:addProperty("label_curCost","CCLabelTTF")
  pkg:addProperty("label_gained","CCLabelTTF")
  pkg:addProperty("label_montryDesc","CCLabelTTF")
  pkg:addProperty("label_times","CCLabelTTF")
  pkg:addProperty("label_preHitRate","CCLabelTTF")
  pkg:addProperty("label_hitRate","CCLabelTTF")
  pkg:addProperty("bn_charge","CCControlButton")
  pkg:addProperty("sprite_bg2","CCSprite")
  pkg:addProperty("mAnimationManager","CCBAnimationManager") --default for animation property

  local layer,owner = ccbHelper.load("ActivityMoneyTree.ccbi","ActivityMoneyTreeCCB","CCLayer",pkg)
  self:addChild(layer)
end
  
function ActivityMoneyTree:init()
  echo("---ActivityMoneyTree:init---")
  self.label_curCost:setString(_tr("current_cost"))
  self.label_gained:setString(_tr("gain")..":")
  self.label_montryDesc:setString(_tr("moneytree_desc"))
  self.label_times:setString(_tr("times"))
  self.label_preHitRate:setString(_tr("NEXT_HIT_RATE"))

  local shinning1 = _res(6010011)
  if shinning1 ~= nil then     
    shinning1:setPosition(ccp(140, 300))
    self.sprite_bg2:addChild(shinning1, 1)
  end

  local shinning2 = _res(6010011)
  if shinning2 ~= nil then     
    shinning2:setPosition(ccp(320, 300))
    self.sprite_bg2:addChild(shinning2, 1)
  end

  self:updateInfo()

  --添加返回按钮
  local backImg = CCSprite:createWithSpriteFrameName("playstates-image-fanhui.png")
  local backImg1 = CCSprite:createWithSpriteFrameName("playstates-image-fanhui1.png")
  if backImg ~= nil then 
    local topHeight = self:getDelegate():getTopMenuSize().height 
    local menuSize = backImg:getContentSize()
    local menu = CCMenu:create()
    local menuItem = CCMenuItemSprite:create(backImg, backImg1, nil)
    menuItem:registerScriptTapHandler(handler(self, ActivityMoneyTree.onBackHandler))
    menu:addChild(menuItem)
    menu:setPosition(ccp(display.cx + 320 - 50, display.height - topHeight - menuSize.height/2 - 20))
    self:addChild(menu)
  end 
end

function ActivityMoneyTree:updateInfo()
  local player = GameData:Instance():getCurrentPlayer()
  local count = player:getMoneyTreeUsedCount()
  local countMax = self:getCountsMax()
  local item = AllConfig.moneytree[player:getLevel()]
  
  self.label_count:setString(string.format("%d/%d", count, countMax))
  if count < countMax then 
    self.label_count:setColor(ccc3(32, 143, 0))
    -- self.bn_charge:setEnabled(true)

    for k, v in pairs(AllConfig.cost) do 
      if v.type == 13 and (count+1 >= v.min_count and count+1 <= v.max_count) then 
        --活动期间有折扣
        local discount = 1.0
        local leftTime, id = Activity:instance():getActivityLeftTime(ACI_ID_MONEY_TREE_DISCOUNT)
        if leftTime > 0 then          
          discount = AllConfig.activity[id].activity_drop[1]/10000
        end 
        self.label_costMoney:setString(string.format("%d", v.cost*discount))
        break
      end
    end

    local gainCount = item.base_currency_count
    self.label_gainCoin:setString(string.format("%d", gainCount))
  else 
    self.label_count:setColor(ccc3(201, 1, 1))
    -- self.bn_charge:setEnabled(false)
    self.label_costMoney:setString("")
    self.label_gainCoin:setString("")
  end

  --显示下次暴击率
  -- v->base_chance() + (today_use_times - hit_rating) * v->add_chance()
  local preHitIndex = player:getPreMoneyTreeHitRateIdx()
  local nextHitRate = toint(item.base_chance + (count+1-preHitIndex)*item.add_chance)/100
  self.label_hitRate:setString(nextHitRate.."%")
end 

function ActivityMoneyTree:onEnter()
  echo("---ActivityMoneyTree:onEnter---")
  net.registMsgCallback(PbMsgId.UseMoneyTreeResult, self, ActivityMoneyTree.chargeResult)
  self:init()
end

function ActivityMoneyTree:onExit()
  echo("---ActivityMoneyTree:onExit---")
  net.unregistAllCallback(self) 
end

function ActivityMoneyTree:onBackHandler()
  self:getDelegate():goBackView()
end 

function ActivityMoneyTree:startCharge()
  echo("=== ActivityMoneyTree:startCharge ===")
  _playSnd(SFX_CLICK)

  local player = GameData:Instance():getCurrentPlayer()
  local usedCount = player:getMoneyTreeUsedCount()
  local maxCount = self:getCountsMax()

  echo(" used , max count =", usedCount, maxCount)
  if usedCount >= maxCount then 
    if GameData:Instance():getLanguageType() == LanguageType.JPN then 
      Toast:showString(self, _tr("has no times"), ccp(display.width/2, display.height*0.4))
    else 
      local pop = PopupView:createTextPopupWithPath({leftNorBtn = "goumai.png",leftSelBtn = "goumai1.png",
                                                   text = _tr("add_buy_counts_after_vip_up"),
                                                   leftCallBack = function() 
                                                                    self:getDelegate():gotoVipPrivilegeView()
                                                                  end}) 
      self:getDelegate():getScene():addChild(pop,100) 
    end 
    return    
  end

  local costArray = Activity:instance():getAllMoneyTreeCost()
  local curMoney = player:getMoney()
  if curMoney <  costArray[usedCount+1] then 
    -- Toast:showString(self, _tr("not enough money"), ccp(display.width/2, display.height*0.4))
    GameData:Instance():notifyForPoorMoney()
    return
  end
  
  --start charging
  local data = PbRegist.pack(PbMsgId.UseMoneyTree)
  net.sendMessage(PbMsgId.UseMoneyTree, data)
end

function ActivityMoneyTree:chargeResult(action,msgId,msg)
  echo("===ActivityMoneyTree:chargeResult===", msg.result)

  -- if self.loading ~= nil then 
  --   self.loading:remove()
  --   self.loading = nil
  -- end

  if msg.result == "success" then 

    --show gained bonus
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i=1,table.getn(gainItems) do
      echo("----gained configId:", gainItems[i].configId)
      echo("----gained, count:", gainItems[i].count)
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
    end
    
    
    local player = GameData:Instance():getCurrentPlayer()
    local preCoin = player:getCoin()
    --update
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    local curCoin = player:getCoin()
    local expectedCoin = AllConfig.moneytree[player:getLevel()].base_currency_count
    local isBurstHit = false 
    echo("====precoin, curCoin:", preCoin, curCoin)
    if curCoin-preCoin > expectedCoin then --burst hit
      echo("########### burst hit !")
      isBurstHit = true 
    end 

    self:startPlayAnim(isBurstHit)
    self:updateInfo()

  elseif msg.result == "money_limit" then 
    -- Toast:showString(self, _tr("not enough money"), ccp(display.width/2, display.height*0.4))
    GameData:Instance():notifyForPoorMoney()
  elseif msg.result == "daily_times_limit" then 
    Toast:showString(self, _tr("has no times"), ccp(display.width/2, display.height*0.4))
  end
end

function ActivityMoneyTree:startPlayAnim(isBurstHit)
  echo("=== startPlayAnim: is playing=", self.isAnimPlaying)

  if isBurstHit == true then 
    self:stopPlayAnim()
  end 

  if self.isAnimPlaying == nil or self.isAnimPlaying == false then 
    self.isAnimPlaying = true 

    self.mAnimationManager:runAnimationsForSequenceNamed("treasure")

    local explosionAnim = _res(6010012)
    if explosionAnim ~= nil then
      explosionAnim:setPosition(ccp(0, 0))
      self.node_coinAnim:addChild(explosionAnim, 0)
    end  

    if isBurstHit == true then 

      local explosionAnim2 = _res(6010024)
      if explosionAnim2 ~= nil then
        explosionAnim2:setPosition(ccp(0, 360))
        self.node_coinAnim:addChild(explosionAnim2, 0)
      end 

      self.imgCircle = _res(3022057)
      if self.imgCircle ~= nil then
        local action = CCRotateBy:create(2.7, 360)
        self.imgCircle:runAction(CCRepeatForever:create(action))
        local size = self.sprite_bg2:getContentSize()
        self.imgCircle:setScale(1.6)
        self.imgCircle:setPosition(ccp(0, size.height/2))
        self.sprite_bg2:getParent():addChild(self.imgCircle, -1)
      end 

      local img = CCSprite:createWithSpriteFrameName("act_baoji.png")
      if img ~= nil then 
        img:setAnchorPoint(ccp(0.5, 0.2))
        img:setPositionY(-150)
        self.node_coinAnim:addChild(img)
        img:setScale(0.2)
        local action1 = CCEaseElasticOut:create(CCScaleTo:create(0.5, 2.0), 0.6)
        local action2 = CCEaseElasticOut:create(CCMoveBy:create(0.5, ccp(0, 80)), 0.6)
        local spawn = CCSpawn:createWithTwoActions(action1, action2)

        local action3 = CCMoveBy:create(2.0, ccp(0, -100))
        local action4 = CCFadeOut:create(1.6)
        local spawn2 = CCSpawn:createWithTwoActions(action3, action4)

        local seq = CCSequence:createWithTwoActions(spawn, spawn2)
        img:runAction(seq)
      end 
    end 
  end 



  local function actEnd()
    self:stopPlayAnim()
  end 

  self.node_coinAnim:stopAllActions()
  local act = CCDelayTime:create(1.0)
  local act2 = CCCallFunc:create(actEnd)
  self.node_coinAnim:runAction(CCSequence:createWithTwoActions(act, act2))
end 

function ActivityMoneyTree:stopPlayAnim()
  echo("=== stopPlayAnim ")
  self.isAnimPlaying = false 
  if self.imgCircle ~= nil then
    self.imgCircle:removeFromParentAndCleanup(true)
    self.imgCircle = nil 
  end 
  self.node_coinAnim:removeAllChildrenWithCleanup(true)
end 

function ActivityMoneyTree:playFinishCallback()
  echo("======== playFinishCallback ")
  if self.isAnimPlaying == true then 
    self.mAnimationManager:runAnimationsForSequenceNamed("treasure")
  end 
end 

function ActivityMoneyTree:getCountsMax()
  local countMax = 0 
  local viplevel = GameData:Instance():getCurrentPlayer():getVipLevel()
  for k, v in pairs(AllConfig.vipinitdata) do 
    if v.vip_level == viplevel then 
      countMax = v.Moneytree 
      break 
    end 
  end 

  return countMax
end 
