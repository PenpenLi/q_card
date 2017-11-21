
require("view.BaseView")
require("view.activity.CardListPop")

CardReplace = class("CardReplace", BaseView)

function CardReplace:ctor()

  CardReplace.super.ctor(self)
 
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("onSelectSrcCard",CardReplace.onSelectSrcCard)
  pkg:addFunc("onSelectDstCard",CardReplace.onSelectDstCard)
  pkg:addFunc("onCardDetail",CardReplace.onCardDetail)
  pkg:addFunc("onStartExchange",CardReplace.onStartExchange)

  pkg:addProperty("node_src","CCNode")
  pkg:addProperty("node_dst","CCNode")

  pkg:addProperty("label_preRule","CCLabelTTF")
  pkg:addProperty("label_rule","CCLabelTTF")
  pkg:addProperty("label_preCost","CCLabelTTF")
  pkg:addProperty("label_cost","CCLabelTTF")

  local layer,owner = ccbHelper.load("CardReplace.ccbi","CardReplaceCCB","CCLayer",pkg)
  self:addChild(layer)
end

function CardReplace:onEnter()
  echo("---CardReplace:onEnter---")
  net.registMsgCallback(PbMsgId.ReqExchangeActivityCardResult, self, CardReplace.onStartExchangeResult)

  self.label_preCost:setString(_tr("cost"))
  self.label_preRule:setString(_tr("relace_rule"))
  self.label_rule:setString(_tr("replace_rule_detail"))
end


function CardReplace:onExit()
  echo("---CardReplace:onExit---")
  net.unregistAllCallback(self) 
end

function CardReplace:getPopInfoByGroupData(tbl)
  local listData = {}
  if tbl then 
    if tbl[1] and #tbl[1] > 0 then 
      table.insert(listData, {menu={"#ex_bn_shenjiang0.png","#ex_bn_shenjiang1.png"}, data = tbl[1]})
    end 
    if tbl[2] and #tbl[2] > 0 then 
      table.insert(listData, {menu={"#ex_bn_mingjiang0.png","#ex_bn_mingjiang1.png"}, data = tbl[2]})
    end 
    if tbl[3] and #tbl[3] > 0 then 
      table.insert(listData, {menu={"#ex_bn_liangjiang0.png","#ex_bn_liangjiang1.png"}, data = tbl[3]})
    end 
  end 

  return listData 
end 

function CardReplace:onSelectSrcCard()

  local function selectResult1(card) 
    echo("+++selectResult1:")
    self.srcCard = card 
    self.dstCard = nil 
    self:showLargeCardImg(self.srcCard, nil)
  end 

  local tbl = Activity:instance():getCardsForReplaced()
  local listData = self:getPopInfoByGroupData(tbl)

  if #listData < 1 then 
    Toast:showString(self, _tr("no_exchangeble_card"), ccp(display.cx, display.cy))
    return 
  end 


  local pop = CardListPop.new(listData)
  pop:setUserCallback(selectResult1)
  GameData:Instance():getCurrentScene():addChild(pop, 9999)
end 

function CardReplace:onSelectDstCard()

  local function selectResult2(card) 
    echo("---selectResult2:")
    self.dstCard = card 
    self:showLargeCardImg(nil, self.dstCard)
  end 

  if self.srcCard == nil then 
    Toast:showString(self, _tr("select_replaced_card_firstly"), ccp(display.cx, display.cy))
    return 
  end 


  local tbl = Activity:instance():getCardReplaceTarget(self.srcCard)
  local listData = self:getPopInfoByGroupData(tbl)
  local pop = CardListPop.new(listData)
  pop:setUserCallback(selectResult2)
  GameData:Instance():getCurrentScene():addChild(pop, 9999) 
end 

function CardReplace:onCardDetail()
  local tbl = Activity:instance():getCardReplaceTarget()
  local listData = self:getPopInfoByGroupData(tbl)
  local pop = CardListPop.new(listData)
  -- pop:setUserCallback(selectResult1)
  GameData:Instance():getCurrentScene():addChild(pop, 9999)
end 

function CardReplace:onStartExchange()

  if self.srcCard and self.dstCard and self.cost then 
    local myMoney = GameData:Instance():getCurrentPlayer():getMoney()
    if myMoney < self.cost then 
      GameData:Instance():notifyForPoorMoney()
    else 
      --send msg to replayce card 
      local data = PbRegist.pack(PbMsgId.ReqExchangeActivityCard, {self_card_id=self.srcCard:getId(), target_card_root_id=self.dstCard:getUnitRoot()})
      net.sendMessage(PbMsgId.ReqExchangeActivityCard, data) 
      _showLoading()
    end 

  else 
    if self.srcCard == nil then 
      Toast:showString(self, _tr("select_replaced_card_firstly"), ccp(display.cx, display.cy))
    elseif self.dstCard == nil then 
      Toast:showString(self, _tr("select_target_card"), ccp(display.cx, display.cy))
    end 
  end 
end 

function CardReplace:onStartExchangeResult(action,msgId,msg)
  _hideLoading()

  echo("=== onStartExchangeResult", msg.state)

  if msg.state == "Success" then 
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i=1,table.getn(gainItems) do
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.cx,display.cy-i*50), 0.5*(i-1))
    end
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)

    self.node_src:removeAllChildrenWithCleanup(true)
    self.node_dst:removeAllChildrenWithCleanup(true)
    self.srcCard = nil 
    self.dstCard = nil     
    self.cost = 0
    self.label_cost:setString("") 
       
  elseif msg.state == "NotHaveEnoughMoney" then 
    GameData:Instance():notifyForPoorMoney()
  elseif msg.state == "CardGroupNotSame" or msg.state == "CardGroupError" then 
    Toast:showString(self, _tr("replace_card_group_error"), ccp(display.cx, display.cy))
  elseif msg.state == "ActivityNotOpen" then 
    Toast:showString(self, _tr("act_not_open"), ccp(display.cx, display.cy))
  elseif msg.state == "CardNotOpen" then 
    Toast:showString(self, _tr("card_not_open"), ccp(display.cx, display.cy))
  elseif msg.state == "CanNotExchangeSameCard" then 
    Toast:showString(self, _tr("can_not_replace_same_card"), ccp(display.cx, display.cy))
  end 
end 

function CardReplace:showLargeCardImg(srcCard, dstCard)
  self.node_dst:removeAllChildrenWithCleanup(true)

  if srcCard then 
    self.node_src:removeAllChildrenWithCleanup(true)

    local largeCard = CardHeadLargeView.new(srcCard)
    largeCard:setScale(350/largeCard:getHeight())
    self.node_src:addChild(largeCard)

    self.cost = 0
    self.label_cost:setString("")
  end 

  if dstCard and self.srcCard then 
    local configId = dstCard:getUnitRoot()*100+ self.srcCard:getGrade()
    if AllConfig.unit[configId] then 
      dstCard:setConfigId(configId)
    end 
    dstCard:setGrade(self.srcCard:getGrade())
    dstCard:setLevel(self.srcCard:getLevel())
    local largeCard = CardHeadLargeView.new(dstCard)
    largeCard:setScale(350/largeCard:getHeight())
    self.node_dst:addChild(largeCard)

    self.cost = Activity:instance():getCardReplaceCost(self.srcCard)
    self.label_cost:setString(string.format("%d", self.cost))
  end 
end 










