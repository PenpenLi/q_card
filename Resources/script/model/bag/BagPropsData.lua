
require("common.Consts")

BagPropsData = class("BagPropsData")


function BagPropsData:ctor(viewDelegate)
  net.registMsgCallback(PbMsgId.SellItemToSystemResult, self, BagPropsData.sellToSystemResult)
  net.registMsgCallback(PbMsgId.OpenItemCellResult, self, BagPropsData.buyItemCellResult)
  net.registMsgCallback(PbMsgId.ItemCombineToItemResult, self, BagPropsData.combineResult)
  net.registMsgCallback(PbMsgId.ItemCombineToEquipmentResult, self, BagPropsData.combineResult)
  net.registMsgCallback(PbMsgId.ItemCombineToCardResult, self, BagPropsData.combineResult)
  net.registMsgCallback(PbMsgId.UseItemResultS2C, self, BagPropsData.useItemResult)
  net.registMsgCallback(PbMsgId.EatCardResult, self, BagPropsData.useExpPropResult)

  self:setViewDelegate(viewDelegate)

  self.allProps = GameData:Instance():getCurrentPackage():getPropsArray()
  GameData:Instance():getCurrentPackage():sortProps(self.allProps)
  
  self:setCoinEnough(false)
end


function BagPropsData:enter()
  echo("---BagPropsData:enter---")
  -- net.registMsgCallback(PbMsgId.SellItemToSystemResult, self, BagPropsDataPropsView.sellToSystemResult)
  -- net.registMsgCallback(PbMsgId.ItemCombineToItemResult, self, BagPropsDataPropsView.combineResult)
end

function BagPropsData:exit()
  echo("---BagPropsData:exit---")
  net.unregistAllCallback(self)

  -- BagPropsDataPropsView.target = nil
  -- BagPropsDataMergeView.target = nil
end

function BagPropsData:setViewDelegate(delegate)
  self._viewDelegate = delegate
end

function BagPropsData:getViewDelegate()
  return self._viewDelegate
end


function BagPropsData:getPropsData()
  local tbl = {}
  for k, v in pairs(self.allProps) do 
    if v:getItemType() ~= iType_CardChip and v:getItemType() ~= iType_EquipChip then
      table.insert(tbl, v) 
    end
  end
  
  return tbl
end

function BagPropsData:getCardChipData()
  local tbl = {}
  for i=1, #self.allProps do 
    if self.allProps[i]:getItemType() == iType_CardChip then
      table.insert(tbl, self.allProps[i]) 
    end
  end

  return tbl
end

function BagPropsData:getEquipChipData()
  --if self.equipChipArray == nil then 
    self.equipChipArray = {}
    for i=1, #self.allProps do 
      if self.allProps[i]:getItemType() == iType_EquipChip then
        table.insert(self.equipChipArray, self.allProps[i]) 
      end
    end
  -- end

  return self.equipChipArray
end
 
function BagPropsData:getMergeData()
  return GameData:Instance():getCurrentPackage():getMergedPropsArray() 
end

function BagPropsData:setCoinEnough(isEnough)
  self._isCoinEnough = isEnough
end

function BagPropsData:getCoinEnough()
  return self._isCoinEnough
end

function BagPropsData:setMergedCountMax(num)
  self._mergedNumMax = num
end

function BagPropsData:getMergedCountMax()
  return self._mergedNumMax
end

function BagPropsData:setCombineCost(needCoin)
  self._combineCost = needCoin
end 

function BagPropsData:getCombineCost()
  return self._combineCost or 0 
end

function BagPropsData:getItemIconId(configId)
  local iconId = nil   
  local frameId = nil
  local iconBgId = nil 
  local itype = math.floor(configId/10000000)

  if itype == 2 then --props
    local item = AllConfig.item[configId]
    iconId = item.item_resource
    frameId = 3021041+item.rare - 1
    if item.item_type == 4 then --equip chip 
      iconBgId = 3059009 + item.rare - 1
    end 
  elseif itype == 3 then --equip
    iconId = AllConfig.equipment[configId].equip_icon
    frameId = 3021041 + AllConfig.equipment[configId].equip_rank
    iconBgId = 3059009 + AllConfig.equipment[configId].equip_rank
  elseif itype == 1 then --card
    iconId = AllConfig.unit[configId].unit_head_pic
    frameId = 3021041 + AllConfig.unit[configId].card_rank
  end 

  return iconId, frameId, iconBgId
end 

function BagPropsData:useExpProp(items,cardId,viewToUpdate)
  --[[message EatCard {
  enum traits { value = 1088;}
  message CardExpItem{
  required int32 id = 1;    //道具ID
  required int32 count = 2;   //道具数量
  }
  required int32 card = 1;       //要升级的卡牌
  repeated CardExpItem items = 2;  //经验药水
  }]]

  self._useExpPropView = viewToUpdate
  
  assert(items ~= nil and cardId ~= nil)
  print("EatCard: cardId = "..cardId.."")
  dump(items)
  _showLoading()
  local data = PbRegist.pack(PbMsgId.EatCard,{card = cardId,items = items})
  net.sendMessage(PbMsgId.EatCard,data)
end

function BagPropsData:useExpPropResult(action,msgId,msg)
  --[[message EatCardResult {
  enum traits { value = 1089;}
  enum ErrorCode {
    NO_ERROR_CODE = 1;
  NOT_HAS_ENOUGH_ITEM = 2;  //道具数量有误
  CARD_LEVEL_MAX = 3;     //卡牌已经到达等级上限
  NEED_MORE_COIN = 4;     //需要更多的铜钱
  NOT_CARD_EXP_ITEM = 5;    //不是经验药水
  NOT_FOUND_CARD = 6;     //没有找到要升级的卡片
  SYSTEM_ERROR = 50;
  }
  required ErrorCode error = 1;
  optional ClientSync client_sync = 2;
  }]]
  
  print("EatCardResult:",msg.error)
  _hideLoading()
  if msg.error == "NO_ERROR_CODE" then
    local clientSync = msg.client_sync
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(clientSync)
    
    assert(#clientSync.card == 1)
    -- dump(clientSync.card)
    
    local cardInfo = clientSync.card[1]
    assert(cardInfo.action == "Update")
    local cardId = cardInfo.object.id
    if self._useExpPropView ~= nil then
     self._useExpPropView:updateCardView(cardId)
    end
    
  else
    local str = ""
    if msg.error == "NOT_HAS_ENOUGH_ITEM" then
      str = _tr("not enough material")
    elseif msg.error == "CARD_LEVEL_MAX" then
      str = _tr("can_not_beyond_player_lv")
    elseif msg.error == "NEED_MORE_COIN" then
      str = _tr("not enough coin")
    elseif msg.error == "NOT_FOUND_CARD" then
      str = ""
    end
    Toast:showString(self,str, ccp(display.cx, display.cy))
  end
  self._useExpPropView = nil
end

function BagPropsData:buyItemCell(num, startCell, endCell)
  echo("BagPropsData:buyItemCell: num=",num)
  if num > 0 then 
    self.buyStartCelIndex = startCell
    self.buyEndCellIndex = endCell
    
    _showLoading()
    local data = PbRegist.pack(PbMsgId.OpenItemCell, {count = num})
    net.sendMessage(PbMsgId.OpenItemCell, data)
    --show waiting
    --self.loading = Loading:show()
    
  end
end

function BagPropsData:buyItemCellResult(action,msgId,msg)
  echo("=== BagPropsData:buyItemCellResult:", msg.state)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end 
  _hideLoading()

  if msg.state == "Ok" then 
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    echo("buy bag cell begin, end =", self.buyStartCelIndex, self.buyEndCellIndex)
    for i= self.buyStartCelIndex, self.buyEndCellIndex do 
      self:getViewDelegate():updateCell(i, true)
    end
  elseif msg.state == "TooMuchCellCount" then 
    Toast:showString(self, _tr("cells number exceed"), ccp(display.cx, display.cy))
  elseif msg.state == "NotEnoughCurrency" then 
    -- Toast:showString(self, _tr("not enough money"), ccp(display.cx, display.cy))
    GameData:Instance():notifyForPoorMoney()
  end
end

function BagPropsData:UseVipItemSuccess(msg)
  GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
  
  local leftDays = 0
  local curTime = Clock:Instance():getCurServerUtcTime()
  local endTime = GameData:Instance():getCurrentPlayer():getVipEndTime()
  if curTime < endTime then 
    leftDays = (endTime - curTime)/(3600*24)
  end
  leftDays = math.round(leftDays)

  local str = _tr("been vip %{day}", {day=leftDays})
  local pop = PopupView:createTextPopup(str, nil, true)
  self:getViewDelegate():addChild(pop)
  self:getViewDelegate():updateList()
end

function BagPropsData:useProtectItemSuccess(msg)
  local configid = self.curItem:getConfigId()
  local bonusArray = AllConfig.item[configid].bonus 
  local str = _tr("get protected time %{hour}", {hour=bonusArray[3]})
  local pop = PopupView:createTextPopup(str, nil, true)
  self:getViewDelegate():addChild(pop)

  GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
  self:getViewDelegate():updateList()
end 

function BagPropsData:useItem(item)

  local function okCallback(n)
    echo("okCallback, used num = ",n)
    self.selectedNum = n

    local data = PbRegist.pack(PbMsgId.UseItemC2S, {item = item:getId(), count = n})
    net.sendMessage(PbMsgId.UseItemC2S, data) 

--    if self.loading ~= nil then 
--      self.loading:remove()
--      self.loading = nil
--    end    
--    self.loading = Loading:show()
    _showLoading()
  end 

  
  local itemCount = item:getCount()
  local itemType = item:getItemType()
  echo("item type,configId = ", itemType, item:getConfigId())
  self.curItem = item

  --虎符、钥匙、技能书、锦囊、兑换物、挂机券
  if itemType == iType_HuFu or itemType == iType_BoxKey or itemType == iType_SkillBook 
    or itemType == iType_HunShi or itemType == iType_JunLingZhuang or itemType == iType_Bable 
    or itemType == iType_JinNang or itemType == iType_GuaJiQuan or itemType == iType_Exchange 
    or itemType == iType_ExpeditionMedicine or itemType == iType_ArenaMedicine or itemType == iType_JingjiMedicine 
    then 
    Toast:showString(self, _tr("cannot be used"), ccp(display.cx, display.cy))
    return  
  end 

  --检查背包空间是否足够
  local require_bag_slot = AllConfig.item[item:getConfigId()].require_bag_slot
  local require_card_slot = AllConfig.item[item:getConfigId()].require_card_slot
  local require_equip_slot = AllConfig.item[item:getConfigId()].require_equip_slot
  local hasEnoughSpace = true 
  local str 
  if require_bag_slot > 0 then
    hasEnoughSpace = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(require_bag_slot) 
    if hasEnoughSpace == false then 
      str = _tr("bag is full")
    end
  end 
  if hasEnoughSpace and require_card_slot > 0 then 
    local hasEnoughSpace = GameData:Instance():getCurrentPackage():checkCardBagEnoughSpace(require_card_slot) 
    if hasEnoughSpace == false then 
      str = _tr("card bag is full")
    end
  end 
  if hasEnoughSpace and require_equip_slot > 0 then 
    local hasEnoughSpace = GameData:Instance():getCurrentPackage():checkEquipBagEnoughSpace(require_equip_slot) 
    if hasEnoughSpace == false then 
      str = _tr("equip bag is full")
    end
  end
  if hasEnoughSpace == false then 
    Toast:showString(self, str, ccp(display.cx, display.cy))
    return 
  end 

  if itemCount >= 2 and (itemType ~= iType_VipCard) and (itemType ~= iType_MianZhanPai) then 
    if itemType == iType_Box then -- 宝箱需要根据钥匙数量来确定最大个数
      itemCount = GameData:Instance():getCurrentPackage():getBoxNumByKey(item:getConfigId(), itemCount)
      if itemCount < 1 then 
        Toast:showString(self, _tr("no key"), ccp(display.cx, display.cy))
        return
      end
    end

    itemCount = math.min(itemCount, 100) --使用物品上限为100个
    local pop = PopupView:createInputPopup(PopupType.INPUT_NUMBER_USE, item:getName(),item:getSalePrice(), itemCount, okCallback)                 
    self:getViewDelegate():addChild(pop)
    pop:setScale(0.2)
    pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )             
  else
    okCallback(1)
  end
end

function BagPropsData:useItemResult(action,msgId,msg)
  echo("useItemResult:", msg.error)
  
  _hideLoading()

  if msg.error == "NO_ERROR_CODE" then 
    local itemType = self.curItem:getItemType()
    if itemType == iType_VipCard then --VIP card
      self:UseVipItemSuccess(msg)

    elseif itemType == iType_MianZhanPai then --protected card
      self:useProtectItemSuccess(msg)

    else 
      local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client)
      local center = self:getViewDelegate():getTableViewCenterPos()

        --show toast
      if table.getn(gainItems) == 1 then 
        local center = self:getViewDelegate():getTableViewCenterPos()
        local numStr = string.format("+%d", gainItems[1].count)
        Toast:showIconNum(numStr, gainItems[1].iconId, gainItems[1].iType, gainItems[1].configId, center)

      elseif table.getn(gainItems) >= 2 then
        local pop = PopupView:createRewardPopup(gainItems)
        self:getViewDelegate():addChild(pop)
      end 

      _playSnd(SFX_ITEM_ACQUIRED)
      
      GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
      self:getViewDelegate():resortChip()
    end 

    if itemType ~= iType_Box and itemType ~= iType_ItemBox and itemType ~= iType_ItemBoxQKa and self.curItem:getCount() > self.selectedNum then 
      self:getViewDelegate():updateCell(nil)
    else 
      self:getViewDelegate():updateList()
    end 

  else
    local str
    if msg.error == "NOT_HAS_ENOUGH_ITEM" then 
      str = _tr("wrong number")
    elseif msg.error == "ERROR_ITEM" then 
      str = _tr("no such item")
    elseif msg.error == "NOT_FOUND_ITEM" then 
      str = _tr("no such item")
    elseif msg.error == "ITEM_TYPE_NOT_ALLOW" then 
      str = _tr("wrong item type") 
    elseif msg.error == "NO_TALENT_LEVEL_UP" then 
      str = _tr("no talent levelup")
    elseif msg.error == "TANLENT_BANK_FULL" then 
      str = string._tran(Consts.Strings.ERROR_BANK_FULL)
    elseif msg.error == "PLAYER_LEVEL_LIMIT" then 
      str = _tr("player_level_limit")
    elseif msg.error == "NOT_HAS_ENOUGH_KEY" then
      str = _tr("no key")
    else
      str = _tr("system error")
    end 
    Toast:showString(self, str, ccp(display.cx, display.cy))
  end 
end 

function BagPropsData:sellToSystemResult(action,msgId,msg)
  echo("sell result:", msg.state)
--  if self.loading ~= nil then
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  if msg.state == "Ok" then
    local preCoin = GameData:Instance():getCurrentPlayer():getCoin()
    local configId = self.curItem:getConfigId()
    local count = self.curItem:getCount()
    local resId = self.curItem:getIconId()

    local package = GameData:Instance():getCurrentPackage()
    package:parseClientSyncMsg(msg.client_sync)
    local leftNum = package:getPropsNumByConfigId(configId)
    echo("sell leftNum=", leftNum)
    if leftNum > 0 then
      if self.curItem:getItemType() == iType_CardChip or self.curItem:getItemType() == iType_EquipChip then
        self:getViewDelegate():resortChip()
      end
      self:getViewDelegate():updateCell(nil)
    else 
      self:getViewDelegate():updateList()
    end

    local curCoin = GameData:Instance():getCurrentPlayer():getCoin()
    local gainCoinStr = string.format("+%d", curCoin-preCoin)

    --show toast
    local center = self:getViewDelegate():getTableViewCenterPos()
    Toast:showIconNum(gainCoinStr, 3059002, nil, nil, center)
  elseif msg.state == "NoSuchItem" then
    Toast:showString(self, _tr("no such item"), ccp(display.cx, display.cy))
  elseif msg.state == "NotSellItem" then
    Toast:showString(self, _tr("ITEM_SALE_FORBID"), ccp(display.cx, display.cy))
  else
    Toast:showString(self, _tr("fail to sale"), ccp(display.cx, display.cy))
  end
end

function BagPropsData:sellToSystem(item)
  if GameData:Instance():checkSystemOpenCondition(18, true) == false then 
    return 
  end 

  self.curItem = item

  local function popOkCallback(n)
    echo("okCallback, to sale num="..n)
    self.selectedNum = n

    local function sellToSystem()
      _showLoading()
      local data = PbRegist.pack(PbMsgId.SellItemToSystem, {item_id = item:getId(), count = n})
      net.sendMessage(PbMsgId.SellItemToSystem, data)
      --show waiting
      --self.loading = Loading:show()
    end

    if item:getMaxGrade() >= 3 then 
      local str = _tr("confire to sale %{rank} star?", {rank = item:getMaxGrade()})
      local pop = PopupView:createTextPopup(str, sellToSystem)
      self:getViewDelegate():addChild(pop)
    else
      sellToSystem()
    end
  end

  if item:getItemType() == iType_VipCard then -- VIP卡
    Toast:showString(self, _tr("can not sale vip item"), ccp(display.cx, display.cy))
    return
  end

  if item:getCount() >= 2 then 
    local pop = PopupView:createInputPopup(PopupType.INPUT_NUMBER_SALE, item:getName(),item:getSalePrice(), item:getCount(), popOkCallback, 1)      
    self:getViewDelegate():addChild(pop)
    pop:setScale(0.2)
    pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))
  else 
    popOkCallback(1)
  end
end 




function BagPropsData:combineResult(action,msgId,msg)
  echo("=== combineResult:", msg.state)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  if msg.state == "Ok" then 
    
    _playSnd(SFX_ITEM_ACQUIRED)

    local numStr = string.format("+%d",self.combinedNum)
    local configId = AllConfig.combinesummary[self.curItem:getConfigId()].target_item
    local itemType = AllConfig.combinesummary[self.curItem:getConfigId()].target_type
    Toast:showIconNum(numStr, nil, itemType, configId, ccp(display.cx, display.cy))

    local package = GameData:Instance():getCurrentPackage()
    package:parseClientSyncMsg(msg.client_sync)

    --get newest data 
    self:getViewDelegate():resortChip()
    self:getViewDelegate():updateList()
  elseif msg.state == "NotEnoughItems" then 
    Toast:showString(self, _tr("not enough material"), ccp(display.cx, display.cy))
  elseif msg.state == "NeedMoreBagCell" then 
    Toast:showString(self, _tr("need more bag cell"), ccp(display.cx, display.cy))
  elseif msg.state == "NotEnoughCurrency" then 
    Toast:showString(self, _tr("not enough coin"), ccp(display.cx, display.cy))
  elseif msg.state == "NotEnoughLeaderPower" then 
    Toast:showString(self, _tr("not enough leadship"), ccp(display.cx, display.cy))
  elseif msg.state == "NotFoundTargetCard" then 
    Toast:showString(self, _tr("no such card"), ccp(display.cx, display.cy))
  elseif msg.state == "HasSameCard" then 
    Toast:showString(self, _tr("no_need_combine_card_again"), ccp(display.cx, display.cy))    
  else
    Toast:showString(self, msg.state, ccp(display.cx, display.cy))
  end
end 


function BagPropsData:startMerge(item)
  self.curItem = item

  local function okCallback(n)  
    echo("combine num =",n)
    self.combinedNum = n
    
    _showLoading()
    
    local targetType = AllConfig.combinesummary[item:getConfigId()].target_type
    if targetType == 6 then --props
      local data = PbRegist.pack(PbMsgId.ItemCombineToItem, {table_id=item:getConfigId(), count=self.combinedNum})
      net.sendMessage(PbMsgId.ItemCombineToItem, data)
    elseif targetType == 7 then --equipment
      local data = PbRegist.pack(PbMsgId.ItemCombineToEquipment, {config_id=item:getConfigId(), count=self.combinedNum})
      net.sendMessage(PbMsgId.ItemCombineToEquipment, data)   
    elseif targetType == 8 then --card  
      local data = PbRegist.pack(PbMsgId.ItemCombineToCard, {config_id=item:getConfigId(), count=self.combinedNum})
      net.sendMessage(PbMsgId.ItemCombineToCard, data)  
    end
    --show waiting
    --self.loading = Loading:show()
  end

  --when has same card, then do noting 
  local combineSummary = AllConfig.combinesummary[item:getConfigId()]
  if item:getItemType() == 3 then --card chip 
    local rootId = AllConfig.unit[combineSummary.target_item].unit_root 
    local allCards = GameData:Instance():getCurrentPackage():getAllCards()
    for k, v in pairs(allCards) do 
      if v:getUnitRoot() == rootId then         
        Toast:showString(self, _tr("no_need_combine_card_again"), ccp(display.cx, display.cy)) 
        return 
      end 
    end 
  end 

  if item:getCount() >= 10 and item:getItemType() ~= 3 then --卡牌碎片最多只允许合成一张整卡
    local name = ""    
    if combineSummary.target_type == 6 then --props
      name = AllConfig.item[combineSummary.target_item].item_name
    elseif combineSummary.target_type == 7 then --equip
      name = AllConfig.equipment[combineSummary.target_item].name
    elseif combineSummary.target_type == 8 then --card
      name = AllConfig.unit[combineSummary.target_item].unit_name
    end 

    local needCoins = self:getCombineCost()
    local myCoins = GameData:Instance():getCurrentPlayer():getCoin()
    local maxNum = math.min(self:getMergedCountMax(), math.floor(myCoins/needCoins))

    local pop = PopupView:createInputPopup(PopupType.INPUT_NUMBER_MERGE, name, needCoins, maxNum, okCallback, 1)    
    self:getViewDelegate():addChild(pop)
    pop:setScale(0.2)
    pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )       
  else
    okCallback(1)
  end
end
