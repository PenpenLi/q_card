require("model.equipment_reinforce.EquipmentReinforceConfig")
EquipmentReinforce = class("EquipmentReinforce")
function EquipmentReinforce:ctor()
  net.registMsgCallback(PbMsgId.EquipXiLianResult, self, EquipmentReinforce.onEquipXiLianResult)
  net.registMsgCallback(PbMsgId.EquipTurnbackResult, self, EquipmentReinforce.onEquipTurnbackResult)
  net.registMsgCallback(PbMsgId.EquipXiLianReplaceResult, self, EquipmentReinforce.onEquipXiLianReplaceResult)
  net.registMsgCallback(PbMsgId.EquipXiLianReplaceResult, self, EquipmentReinforce.onEquipXiLianReplaceResult)
  net.registMsgCallback(PbMsgId.EquipStrengthenResult, self, EquipmentReinforce.onEquipStrengthenResult)
  net.registMsgCallback(PbMsgId.EquipTurnExclusiveResult, self, EquipmentReinforce.onEquipTurnExclusiveResult)
  net.registMsgCallback(PbMsgId.ChangeCardEquipmentResultS2C,self,EquipmentReinforce.onChangeCardEquipmentResultS2C)
end

function EquipmentReinforce:Instance() 
  if EquipmentReinforce._Instance == nil then
    EquipmentReinforce._Instance = EquipmentReinforce.new()
  end
  return EquipmentReinforce._Instance
end

--[[

-- PbMsgId.EquipTurnback   = 10045
PbRegist.registMessage(10045,"EquipTurnback")

-- PbMsgId.EquipTurnbackResult  = 10046
PbRegist.registMessage(10046,"EquipTurnbackResult")

---- PbMsgId.SmeltEquip   = 10040
--PbRegist.registMessage(10040,"SmeltEquip")
--
---- PbMsgId.SmeltEquipResult  = 10041
--PbRegist.registMessage(10041,"SmeltEquipResult")

---- PbMsgId.EatEquip   = 10042
--PbRegist.registMessage(10042,"EatEquip")
--
---- PbMsgId.EatEquipResult  = 10043
--PbRegist.registMessage(10043,"EatEquipResult")

-- PbMsgId.EquipXiLian   = 10047
PbRegist.registMessage(10047,"EquipXiLian")

-- PbMsgId.EquipXiLianResult  = 10048
PbRegist.registMessage(10048,"EquipXiLianResult")

-- PbMsgId.EquipXiLianReplace   = 10050
PbRegist.registMessage(10050,"EquipXiLianReplace")

-- PbMsgId.EquipXiLianReplaceResult  = 10051
PbRegist.registMessage(10051,"EquipXiLianReplaceResult")

-- PbMsgId.EquipStrengthen = 10057
PbRegist.registMessage(10057,"EquipStrengthen")

-- PbMsgId.EquipStrengthenResult = 10058
PbRegist.registMessage(10058,"EquipStrengthenResult")

-- PbMsgId.EquipTurnExclusive = 10059
PbRegist.registMessage(10059,"EquipTurnExclusive")

-- PbMsgId.EquipTurnExclusiveResult  = 10060
PbRegist.registMessage(10060,"EquipTurnExclusiveResult")

]]

------
--  Getter & Setter for
--      EquipmentReinforce._EquipmentSelectListView 
-----
function EquipmentReinforce:setEquipmentSelectListView(EquipmentSelectListView)
	self._EquipmentSelectListView = EquipmentSelectListView
end

function EquipmentReinforce:getEquipmentSelectListView()
	return self._EquipmentSelectListView
end

------
--  Getter & Setter for
--      EquipmentReinforce._PrePlaystatesView 
-----
function EquipmentReinforce:setPrePlaystatesView(PrePlaystatesView)
	self._PrePlaystatesView = PrePlaystatesView
end

function EquipmentReinforce:getPrePlaystatesView()
	return self._PrePlaystatesView
end

------
--  Getter & Setter for
--      EquipmentReinforce._PlaystatesView 
-----
function EquipmentReinforce:setPlaystatesView(PlaystatesView)
	self._PlaystatesView = PlaystatesView
end

function EquipmentReinforce:getPlaystatesView()
	return self._PlaystatesView
end

------
--  Getter & Setter for
--      EquipmentReinforce._TargetEquipment 
-----
function EquipmentReinforce:setTargetEquipment(TargetEquipment)
	self._TargetEquipment = TargetEquipment
end

function EquipmentReinforce:getTargetEquipment()
	return self._TargetEquipment
end

function EquipmentReinforce:getEquipLvUpEnabledAndCost(equipmentData,maxLevelUpEnabled,nowHasCoin)
   local equipmentType = equipmentData:getEquipType()
   local equipmentLevel = equipmentData:getLevel()
   local totalCost = 0
   local lvUpEnabled = false
   local targetLevel = 0
   
   if equipmentData == nil then
    return lvUpEnabled,totalCost,targetLevel
   end
   
   local getCostByLevelAndType = function(equipmentType,equipmentLevel)
     local cost = -1
     if AllConfig.equipmentimprovecost[equipmentLevel] == nil then
       return cost
     end
     
     if equipmentType == EquipmentReinforceConfig.EquipmentTypeWeapon then
      cost = AllConfig.equipmentimprovecost[equipmentLevel].weapon_cost
     elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeArmor then
      cost = AllConfig.equipmentimprovecost[equipmentLevel].armor_cost
     elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeAccessory then
      cost = AllConfig.equipmentimprovecost[equipmentLevel].decoration_cost
     end
     
     return cost
   end
   
   totalCost = getCostByLevelAndType(equipmentType,equipmentLevel)
   local currentCoin = nowHasCoin or GameData:Instance():getCurrentPlayer():getCoin()
   
   if totalCost <= currentCoin and totalCost >= 0 then
     lvUpEnabled = true
   else
     lvUpEnabled = false
   end
   
   targetLevel = equipmentLevel + 1
   local card = equipmentData:getCard()
   local playerLevel = GameData:Instance():getCurrentPlayer():getLevel()
   
   if targetLevel <= playerLevel then --first check
     if maxLevelUpEnabled == true and totalCost < currentCoin then
        for i = equipmentLevel, #AllConfig.equipmentimprovecost do
          local tempTargetLevel = i+1
          local nextLevelCost = getCostByLevelAndType(equipmentType,tempTargetLevel)
          local tmpTotalCost = totalCost + nextLevelCost
          if tempTargetLevel + 1 <= playerLevel and nextLevelCost >= 0 then
             if currentCoin >= tmpTotalCost then
               totalCost = tmpTotalCost 
               targetLevel = tempTargetLevel
               print("targetLevel:",targetLevel)
--               self.labelCoinCost:setColor(sgGREEN)
--               local oldPropValue = equipmentData:getBaseAttr() + equipmentData:getImproveAttr() * (equipmentData:getLevel() - 1)
--               local newPropValue = equipmentData:getBaseAttr() + equipmentData:getImproveAttr() * targetLevel
--               --local addProp = equipmentData:getBaseAttr() + equipmentData:getImproveAttr() * targetLevel
--               self.bmLabelLevelUpPerBaseValuePlus:setString("+"..(newPropValue - oldPropValue))
               targetLevel = targetLevel + 1
             else
               break
             end
          else
             print("maxLevel:",playerLevel)
             break
          end
        end
     end
   else
--     self.btnLevelUp:setEnabled(false)
--     self.spriteTipLevelUp:setVisible(true)
--     self.nodeCoinCost:setVisible(false)
     lvUpEnabled = false
   end

   return lvUpEnabled,totalCost,targetLevel

end

function EquipmentReinforce:reqChangeEquipment(dressOrUndress,card_ids,equipment_id)
   assert((dressOrUndress == "Dress" or dressOrUndress == "UnDress"))
   _showLoading()
   self._dressOrUndress = dressOrUndress
   local data = PbRegist.pack(PbMsgId.ChangeCardEquipmentC2S,{ action = dressOrUndress,card_id = card_ids,equipment_id = equipment_id  })
   net.sendMessage(PbMsgId.ChangeCardEquipmentC2S,data)
end

function EquipmentReinforce:onChangeCardEquipmentResultS2C(action,msgId,msg)
--  enum ErrorCode{
--    NO_ERROR_CODE = 1;
--    NOT_FOUND_EQUIPMENT = 2;
--    NOT_FOUND_CARD = 3;
--    CARD_NOT_HAVE_EQUIPMENT = 5;
--    CARD_IS_DRESS_EQUIPMENT = 6;
--    SYSTEM_ERROR = 4;
--  }
--  required ErrorCode error = 1;
--  optional ClientSync client_sync = 2;
  _hideLoading()
  _executeNewBird()
  print("EquipmentReinforce:onChangeCardEquipmentResultS2C",msg.error)
  if msg.error == "NO_ERROR_CODE" then
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    if self:getEquipmentSelectListView() ~= nil then
      self:getEquipmentSelectListView():removeFromParentAndCleanup(true)
      self:setEquipmentSelectListView(nil)
    end
    
    if self:getTargetEquipment() ~= nil then
      local targetCard = self:getTargetEquipment():getCard()
      local enabledTurnExclusive = (targetCard:getActiveEquipId() > 0 and targetCard:getActiveEquipId() ~= self:getTargetEquipment():getRootId())
      
      local containerView = self:getContainerView()
      if containerView ~= nil then
        containerView:hideSideComponent(not enabledTurnExclusive)
        containerView:setEquipmentData(self:getTargetEquipment())
      end
      
      self:updateView()
      
      --[[if enabledTurnExclusive == true then
        if containerView ~= nil and self:getTargetEquipment():getEquipType() == EquipmentReinforceConfig.EquipmentTypeWeapon then
          containerView:showSideComponentByType(EquipmentReinforceConfig.ComponentTypeSideTurnExclusive)
        end
      end]]
      
      local playstatesView = self:getPlaystatesView()
      if playstatesView ~= nil then
        playstatesView:setCurrentShowCard(targetCard)
      end
    end
    
    if self._dressOrUndress == "UnDress" then
      local playstatesView = EquipmentReinforce:Instance():getPlaystatesView()
      if playstatesView ~= nil then
        playstatesView:updateView()
      end
      EquipmentReinforce:Instance():getContainerView():removeFromParentAndCleanup(true)
    end
    
    local playstatesView = self:getPrePlaystatesView()
    if playstatesView ~= nil then
      playstatesView:updateView()
    end
    
  elseif msg.error == "CARD_IS_DRESS_EQUIPMENT" then
    Toast:showString(GameData:Instance():getCurrentScene(),_tr("card_has_dress_equip"), ccp(display.cx, display.cy))
  else
    print("Error Code:",msg.error)
    Toast:showString(GameData:Instance():getCurrentScene(),_tr("equip_dress_fail"), ccp(display.cx, display.cy))
  end
  self:setTargetEquipment(nil)
  self._dressOrUndress = nil
end

------
--  Getter & Setter for
--      EquipmentReinforce._SideComponent 
-----
function EquipmentReinforce:setSideComponent(SideComponent)
	self._SideComponent = SideComponent
end

function EquipmentReinforce:getSideComponent()
	return self._SideComponent
end

------
--  Getter & Setter for
--      EquipmentReinforce._MainComponent 
-----
function EquipmentReinforce:setMainComponent(MainComponent)
	self._MainComponent = MainComponent
end

function EquipmentReinforce:getMainComponent()
	return self._MainComponent
end


function EquipmentReinforce:reqEquipXiLian(equipmentData,prop_infos)
  --[[
  message EquipXiLian {
  enum traits { value = 10047;}
  required int32 equip_id = 1;
  repeated int32 prop_info = 2;
  }
  ]]
  
  assert(equipmentData ~= nil,"reqEquipXiLian:equipmentData can not be nil")
  print("reqEquipXiLian,equip_id =",equipmentData:getId(),",equip_configid ="..equipmentData:getConfigId())
  --dump(prop_infos)
  _showLoading()
  local data = PbRegist.pack(PbMsgId.EquipXiLian,{equip_id = equipmentData:getId(),prop_info = prop_infos})
  net.sendMessage(PbMsgId.EquipXiLian,data)
end

function EquipmentReinforce:onEquipXiLianResult(action,msgId,msg)
  --[[
  message EquipXiLianResult {
  enum traits { value = 10048;}
  enum State {
    Ok = 0;
    NoSuchEquip = 1;    //没有该装备
    NeedMoreItem = 2;   //需要更多的材料
    NotEnoughCurrency = 3;  //没有足够的金钱
    NoSuchConfigId = 4;   //没有找到配置
  CanNotAllLocked = 5;    //不能所有的属性都锁定，至少要留一个随机属性来洗练
  CanNotXiLian = 6;     //该装备不能洗练（没有随机属性）
  PropIndexError = 7;     //属性INDEX错误 
  }
  required State state = 1;
  optional ClientSync client_sync = 2;
  }
  ]]
  _hideLoading()
  print("onEquipXiLianResult:",msg.state)
  if msg.state == "Ok" then
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    local sideView = self:getSideComponent()
    if sideView ~= nil then
      sideView:updateView(true)
    end
    local str = _tr("equipment_refresh_success")
    Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
  else
    self:toastErrorInfo(msg)
  end
end

function EquipmentReinforce:toastErrorInfo(msg)
  local resultStr = ""
  if msg.state == "NoSuchEquip" then
    resultStr = _tr("ERROR_EQUIPMENT_NOSUCHEQUIP")
  elseif msg.state == "NeedMoreItem" then
    resultStr = _tr("ERROR_EQUIPMENT_NEEDMOREITEM")
  elseif msg.state == "NotEnoughCurrency" then
    resultStr = _tr("not enough coin")
  elseif msg.state == "CanNotXiLian" then
    resultStr = _tr("ERROR_EQUIPMENT_CANNOTXILIAN")
  elseif msg.state == "CanNotAllLocked" then
    resultStr = _tr("ERROR_EQUIPMENT_CANNOTALLLOCKED")
  elseif msg.state == "PropIndexError" then
    resultStr = _tr("ERROR_EQUIPMENT_PROPINDEXERROR")
  elseif msg.state == "NoSuchConfigId" then
    resultStr = _tr("ERROR_EQUIPMENT_NOSUCHCONFIGID")
  elseif msg.state == "ExpNotEnough" then 
    resultStr = _tr("ERROR_EQUIPMENT_EXPNOTENOUGH")
  elseif msg.state == "QualityLimit" then 
    resultStr = _tr("ERROR_EQUIPMENT_QUALITYLIMIT")
  elseif msg.state == "EquipLevelMax" then 
    resultStr = _tr("equipment_level_max")
  end
  Toast:showString(GameData:Instance():getCurrentScene(),resultStr, ccp(display.cx, display.cy))
end

function EquipmentReinforce:getEquipmentsLvUpEnabled(card,equipmentType)
  
  if GameData:Instance():checkSystemOpenCondition(29,false) == false then
    return false
  end

  local enabled = true
  local equipmentData = nil
  if equipmentType == EquipmentReinforceConfig.EquipmentTypeWeapon then
    equipmentData = card:getWeapon()
  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeArmor then
    equipmentData = card:getArmor()
  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeAccessory then
    equipmentData = card:getAccessory()
  end
  
  if equipmentData == nil then
    return false
  end
  
  --local targetLevel = math.min(startEquipment:getMaxLevel(),GameData:Instance():getCurrentPlayer():getLevel())
  local targetLevel = GameData:Instance():getCurrentPlayer():getLevel()
  if equipmentData:getLevel() >= targetLevel then
     return  false
  end
  
  local equipmentType = equipmentData:getEquipType()
  local equipmentLevel = equipmentData:getLevel()
  local totalCost = 0
 
  local getCostByLevelAndType = function(equipmentType,equipmentLevel)
   local cost = -1
   if AllConfig.equipmentimprovecost[equipmentLevel] == nil then
     return cost
   end
   
   if equipmentType == EquipmentReinforceConfig.EquipmentTypeWeapon then
    cost = AllConfig.equipmentimprovecost[equipmentLevel].weapon_cost
   elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeArmor then
    cost = AllConfig.equipmentimprovecost[equipmentLevel].armor_cost
   elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeAccessory then
    cost = AllConfig.equipmentimprovecost[equipmentLevel].decoration_cost
   end
   
   return cost
  end
 
  totalCost = getCostByLevelAndType(equipmentType,equipmentLevel)
  local currentCoin = GameData:Instance():getCurrentPlayer():getCoin()
  if totalCost <= currentCoin and totalCost >= 0 then
   enabled = true
  else
   enabled = false
  end
  
  return enabled
end

function EquipmentReinforce:getEquipmentsGradeUpEnabled(card,equipmentType)
  
  if GameData:Instance():checkSystemOpenCondition(24,false) == false then
    return false
  end

  local equipmentData = nil
  local enabled = true
  if equipmentType == EquipmentReinforceConfig.EquipmentTypeWeapon then
    equipmentData = card:getWeapon()
  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeArmor then
    equipmentData = card:getArmor()
  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeAccessory then
    equipmentData = card:getAccessory()
  end
  
  if equipmentData == nil then
    return false
  end
  
  if equipmentData:getGrade() < 5 then
      local equipConfigId = equipmentData:getConfigId()
      assert(AllConfig.equipmentcombine[equipConfigId] ~= nil,"equipment combine id not found:"..equipmentData:getConfigId())
      for key, m_costGroup in pairs(AllConfig.equipmentcombine[equipConfigId].consume) do
        local costType = m_costGroup.array[1]
        local costConfigId = m_costGroup.array[2]
        local costCount = m_costGroup.array[3]
        if costType ~= 4 then
          local hasCount = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(costConfigId)
          if hasCount < costCount then
            enabled = false 
            break
          end
        end
      end
   else
      enabled = false
   end
    
   return enabled
end

function EquipmentReinforce:getEquipmentsByCardAndEquipmentType(card,equipmentType)
  local allEquipments = {}
  if equipmentType == EquipmentReinforceConfig.EquipmentTypeWeapon then
    allEquipments = GameData:Instance():getCurrentPackage():getAllWeapons()
  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeArmor then
    allEquipments = GameData:Instance():getCurrentPackage():getAllArmors()
  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeAccessory then
    allEquipments = GameData:Instance():getCurrentPackage():getAllAccessories()
  end
  
  local equipments = {} --equipments to show at list
  
  local startEquipment = nil
  if equipmentType == EquipmentReinforceConfig.EquipmentTypeWeapon then
    startEquipment = card:getWeapon()
  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeArmor then
    startEquipment = card:getArmor()
  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeAccessory then
    startEquipment = card:getAccessory()
  end
  
  if startEquipment ~= nil then
    for key, equipData in pairs(allEquipments) do
      if equipData:getId() ~= startEquipment:getId()
      and equipData:getCard() == nil
      then
        table.insert(equipments,equipData)
      end
    end
  else
    for key, equipData in pairs(allEquipments) do
      if equipData:getCard() == nil then
        table.insert(equipments,equipData)
      end
    end
  end
  
  GameData:Instance():getCurrentPackage():sortEquipments(equipments,false,card:getActiveEquipId(),true)
  
  return equipments,startEquipment
end

function EquipmentReinforce:reqEquipTurnback(equipmentData)
  --[[
  package DianShiTech.Protocal;
  message EquipTurnback {
  enum traits { value = 10045;}
  required int32 equip_id = 1;
  }
  ]]
  
  assert(equipmentData ~= nil,"reqEquipTurnback:equipmentData can not be nil")
  print("reqEquipTurnback,equip_id =",equipmentData:getId(),",equip_configid ="..equipmentData:getConfigId())
  _showLoading()
  local data = PbRegist.pack(PbMsgId.EquipTurnback,{equip_id = equipmentData:getId()})
  net.sendMessage(PbMsgId.EquipTurnback,data)
  
end

function EquipmentReinforce:onEquipTurnbackResult(action,msgId,msg)
  --[[
  message EquipTurnbackResult {
  enum traits { value = 10046;}
  enum State {
    Ok = 0;
    NoSuchEquip = 1;    //没有该装备
    NeedMoreItem = 2;   //需要更多的材料
    NotEnoughCurrency = 3;  //没有足够的金钱
    NoSuchConfigId = 4;   //没有找到配置
  ExpNotEnough = 5;   //经验没有升满
  QualityLimit = 6;     //已经达到最高品质了，不能再升品质了
  }
  required State state = 1;
  optional ClientSync client_sync = 2;
  ]]
  
  print("onEquipTurnbackResult:",msg.state)
  _hideLoading()
  if msg.state == "Ok" then
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    self:updateView(true)
    local sideView = self:getSideComponent()
    if sideView ~= nil then
      sideView:onCardTurnbackResult(msg)
    end
    --local str = "装备进阶成功"
    --Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
  else
    self:toastErrorInfo(msg)
  end
  
end

function EquipmentReinforce:reqEquipXiLianReplace(equipmentData)
  --[[
    message EquipXiLianReplace {
    enum traits { value = 10050;}
    required int32 equip_id = 1;
  }
  ]]
  assert(equipmentData ~= nil,"reqEquipXiLianReplace:equipmentData can not be nil")
  print("reqEquipXiLianReplace,equip_id =",equipmentData:getId(),",equip_configid ="..equipmentData:getConfigId())
  _showLoading()
  local data = PbRegist.pack(PbMsgId.EquipXiLianReplace,{equip_id = equipmentData:getId()})
  net.sendMessage(PbMsgId.EquipXiLianReplace,data)
  
end
function EquipmentReinforce:onEquipXiLianReplaceResult(action,msgId,msg)
  --[[
  message EquipXiLianReplaceResult {
  enum traits { value = 10051;}
  enum State {
    Ok = 0;
    NoSuchEquip = 1;    //没有该装备
  }
  required State state = 1;
  optional ClientSync client_sync = 2;
  }
  ]]
  print("onEquipXiLianReplaceResult:",msg.state)
  _hideLoading()
  local str =  ""
  if msg.state == "Ok" then
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    self:updateView(false)
    --str = "装备属性替换成功"
    --Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
  else
    self:toastErrorInfo(msg)
  end
  --Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
end

function EquipmentReinforce:reqEquipStrengthen(equipmentDataOrCardData,op_type)
  --[[
  message EquipStrengthen {
  enum traits { value = 10057;}
  enum OpType{
    StrengthenOnce = 1;
    StrengthenNoLimit =2;
  }
  required int32 equip_id = 1;
  optional int32 op_type = 2;
  }
  ]]
  
  assert(equipmentDataOrCardData ~= nil,"equipmentDataOrCardData can not be nil")
  assert(op_type == EquipmentReinforceConfig.StrengthenOnce
  or op_type == EquipmentReinforceConfig.StrengthenNoLimit
  or op_type == EquipmentReinforceConfig.StrengthenCardEquipment,"unexpected type:"..op_type)
  
  if op_type == EquipmentReinforceConfig.StrengthenCardEquipment then
    self._strengthenCard = equipmentDataOrCardData
  end
  
  local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
  self._preAbility = GameData:Instance():getBattleAbilityForCards(battleCards)
  
  print("reqEquipStrengthen,id =",equipmentDataOrCardData:getId(),"op_type =",op_type)
  _showLoading()
  local data = PbRegist.pack(PbMsgId.EquipStrengthen,{target_id = equipmentDataOrCardData:getId(),op_type = op_type})
  net.sendMessage(PbMsgId.EquipStrengthen,data)
  
end

function EquipmentReinforce:onEquipStrengthenResult(action,msgId,msg)
  --[[
  message EquipStrengthenResult {
  enum traits { value = 10058;}
  enum Result{
    Ok = 0;
    NoSuchEquip = 1;    //没有该装备
  NotEquiped = 2;     //装备没有装备到卡牌上不允许执行该操作
  CardLevelLimit = 3;     //装备等级必须小于卡牌等级才允许执行该操作
  EquipLevelMax = 4;    //装备等级已经满级
  ConfigError = 5;    //装备升级表里没有该等级段的配置
  NotEnoughCurrency = 6;  //没有足够的货币
  NotFoundCard = 7;   //没有找到卡牌
  NotExclusiveEquip =8;   //不是专属武器
  }
  required Result state = 1;
  optional ClientSync client_sync = 2;
  optional int32 crtical_times = 3;
  }
  ]]
  _hideLoading()
  print("onEquipStrengthenResult:",msg.state)
  local str =  ""
  if msg.state == "Ok" then
    if msg.crtical_times ~= nil and msg.crtical_times > 0 then
      local img = display.newSprite("common/icon_baoji.png")
      if img ~= nil then 
        img:setAnchorPoint(ccp(0.5, 0.2))
        img:setPosition(display.cx,display.cy + 100)
        GameData:Instance():getCurrentScene():addChildView(img,1000)
        img:setScale(0.2)
        local array = CCArray:create()
        local action1 = CCEaseElasticOut:create(CCScaleTo:create(0.5, 2.0), 0.6)
        local action2 = CCEaseElasticOut:create(CCMoveBy:create(0.5, ccp(0, 80)), 0.6)
        local spawn = CCSpawn:createWithTwoActions(action1, action2)

        local action3 = CCMoveBy:create(2.0, ccp(0, -100))
        local action4 = CCFadeOut:create(1.6)
        local spawn2 = CCSpawn:createWithTwoActions(action3, action4)

        local seq = CCSequence:createWithTwoActions(spawn, spawn2)
        array:addObject(seq)
        array:addObject(CCRemoveSelf:create())
        local action = CCSequence:create(array)
        img:runAction(action)
      end 
    end 
    
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    --str = "装备强化成功"
    --Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
    self:updateView(true)
  else
    --str =  msg.state
    self:toastErrorInfo(msg)
  end
  --Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
  
end

function EquipmentReinforce:updateView(isSuccessState)
  GameData:Instance():getCurrentPlayer():toastBattleAbility(self._preAbility)
  
  local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
  self._preAbility = GameData:Instance():getBattleAbilityForCards(battleCards)
  
  local mainView = self:getMainComponent()
  if mainView ~= nil then
    mainView:updateView()
    local targetCard = mainView:getEquipmentData():getCard()
    local playstatesView = self:getPlaystatesView()
    if playstatesView ~= nil then
      playstatesView:setCurrentShowCard(targetCard)
    end
  end
  
  if self._strengthenCard ~= nil then
    local playstatesView = self:getPlaystatesView()
    if playstatesView ~= nil then
      playstatesView:setCurrentShowCard(self._strengthenCard)
    end
  end
  
  local sideView = self:getSideComponent()
  if sideView ~= nil then
    sideView:updateView(isSuccessState)
  end
  
  self._strengthenCard = nil
  

end

------
--  Getter & Setter for
--      EquipmentReinforce._ContainerView 
-----
function EquipmentReinforce:setContainerView(ContainerView)
	self._ContainerView = ContainerView
	if ContainerView ~= nil then
     local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
     self._preAbility = GameData:Instance():getBattleAbilityForCards(battleCards)
	end
end

function EquipmentReinforce:getContainerView()
	return self._ContainerView
end

function EquipmentReinforce:reqEquipTurnExclusive(equipmentData)
  --[[
  message EquipTurnExclusive {
  enum traits { value = 10059;}
  required int32 equip_id = 1;
  }
  
  ]]
  
  assert(equipmentData ~= nil,"reqEquipTurnExclusive:equipmentData can not be nil")
  _showLoading()
  print("reqEquipTurnExclusive,equip_id =",equipmentData:getId())
  local data = PbRegist.pack(PbMsgId.EquipTurnExclusive,{equip_id = equipmentData:getId()})
  net.sendMessage(PbMsgId.EquipTurnExclusive,data)
  
end

function EquipmentReinforce:onEquipTurnExclusiveResult(action,msgId,msg)
  --[[
  message EquipTurnExclusiveResult{
  enum traits { value = 10060;}
  enum Result {
    Ok = 0;
    NoSuchEquip = 1;    //没有该装备
  NotEquiped = 2;     //装备没有装备到卡牌上不允许执行该操作
  ConfigError = 3;    //装备升级表里没有该等级段的配置
  IsAlreadyExclusive = 4; //已经是这张卡牌的专属，不可再转
  }
  required int32 equip_id = 1;
  required Result state = 2;
  optional ClientSync client_sync = 3;
  }
  ]]
  
  print("onEquipTurnExclusiveResult:",msg.state)
  _hideLoading()
  local str =  ""
  if msg.state == "Ok" then
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    self:updateView(true)
    local mainView = self:getMainComponent()
    if mainView ~= nil then
      mainView:setIsLockedControllButtons(false)
    end
    --str = "装备专属化成功"
    --Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
  else
    --str =  msg.state
    self:toastErrorInfo(msg)
  end
  --Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
end

function EquipmentReinforce:destory()
  net.unregistAllCallback(self)
end



return EquipmentReinforce