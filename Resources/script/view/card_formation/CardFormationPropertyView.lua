CardFormationPropertyView = class("CardFormationPropertyView",PopModule)
function CardFormationPropertyView:ctor(card)
  local size = CCSizeMake(625,615)
  CardFormationListView.super.ctor(self,size)
  self:setAutoDisposeEnabled(false)
  self._propertiesList = {
  k_property_hp_fix,k_property_atk_fix,
  k_property_str_fix,k_property_int_fix,
  k_property_dom_fix,kCriticalDamageIncAddPercent,
  k_property_cri,k_property_tough,
  k_property_hit,k_property_evade,
  k_property_precision,k_property_block,
  k_property_damage_increase,k_property_damage_reduce
  }
  self:setCard(card)
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false,-256,true)
end

function CardFormationPropertyView:onTouch(event,x,y)
  local size = self:getPopSize()
  local pos = self:getPopBg():convertToNodeSpace(ccp(x, y))
  if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
    self:onCloseHandler()
  end
  return true 
                                        
end

------
--  Getter & Setter for
--      CardFormationPropertyView._Card 
-----
function CardFormationPropertyView:setCard(Card)
	self._Card = Card
end

function CardFormationPropertyView:getCard()
	return self._Card
end

function CardFormationPropertyView:getPropertyNameByType(type)
  local keyStr = ""
  if type == k_property_hp_fix then
    keyStr = "k_property_hp_fix"
  elseif type == k_property_atk_fix then
    keyStr = "k_property_atk_fix"
  elseif type == k_property_str_fix then
    keyStr = "k_property_str_fix"
  elseif type == kCriticalDamageIncAddPercent then
    keyStr = "kCriticalDamageIncAddPercent"
  elseif type == k_property_int_fix then
    keyStr = "k_property_int_fix"
  elseif type == k_property_dom_fix then
    keyStr = "k_property_dom_fix"
  elseif type == k_property_cri then
    keyStr = "k_property_cri"
  elseif type == k_property_evade then
    keyStr = "k_property_evade"
  elseif type == k_property_tough then
    keyStr = "k_property_tough"
  elseif type == k_property_hit then
    keyStr = "k_property_hit"
  elseif type == k_property_precision then
    keyStr = "k_property_precision"
  elseif type == k_property_block then
    keyStr = "k_property_block"
  elseif type == k_property_damage_reduce then
    keyStr = "k_property_damage_reduce"
  elseif type == k_property_damage_increase then
    keyStr = "k_property_damage_increase"
  end
  if keyStr ~= "" then
    keyStr = _tr(keyStr)
  end
  return keyStr
end

function CardFormationPropertyView:onEnter()
  CardFormationPropertyView.super.onEnter(self)
  
  self:setTitleWithSprite(display.newSprite("#shangzhen_attribute.png"))
  
  local fontSize = 30
  local infoNode = display.newNode()
  self:addChild(infoNode)
  infoNode:setPosition(ccp(display.cx,display.cy + 195))
  
  local card = self:getCard()
  local locationStr = ""
  if AllConfig.unitgrown[card:getConfigId()] ~= nil then
    local location = AllConfig.unitgrown[card:getConfigId()].location
    if location == 1 then
      locationStr = _tr("location_type_1")
    elseif location == 2 then
      locationStr = _tr("location_type_2")
    elseif location == 3 then
      locationStr = _tr("location_type_3")
    else
      locationStr = ""
    end
  end
  
  local finalStr = _tr("location_type%{type}",{type = locationStr})
  
  local labelUnitJob = CCLabelTTF:create(finalStr, "Courier-Bold",fontSize)
  labelUnitJob:setColor(sgYELLOW)
  infoNode:addChild(labelUnitJob)
  labelUnitJob:setPositionX(-135)
  
  local labelUnitSkillType = CCLabelTTF:create(_tr("main_property")..":", "Courier-Bold",fontSize)
  labelUnitSkillType:setColor(sgYELLOW)
  labelUnitSkillType:setAnchorPoint(ccp(1,0.5))
  labelUnitSkillType:setPositionX(155)
  infoNode:addChild(labelUnitSkillType)
  
  
  local skilltyperes = nil
  if AllConfig.unit[card:getConfigId()].config%2 == 0 then
      skilltyperes = _res(3042002)
  else
      skilltyperes = _res(3042001)
  end
  
  if skilltyperes ~= nil then
     skilltyperes:setScale(0.9)
     labelUnitSkillType:addChild(skilltyperes)
     skilltyperes:setPosition(ccp(labelUnitSkillType:getContentSize().width + 30,fontSize/2))
  end
  
  
  local board = display.newNode()
  self:addChild(board)
  board:setPosition(ccp(display.cx - 235,display.cy - 260))
  local numX = 2
  local idx = 1
  local maxLine = math.ceil(#self._propertiesList/numX)
  local lineIdx = maxLine
  for i = 1, maxLine do
    for j = 1, numX do
    	local item = self:buildPropertyItem(self._propertiesList[idx])
    	board:addChild(item,maxLine - lineIdx)
    	local px = 0
    	if j > 1 then
    	 px = 300
    	end
    	local py = 55 * lineIdx
    	item:setPosition(px,py)
    	
    	idx = idx + 1
    end
    lineIdx = lineIdx - 1
  end
  
  local tip_pic = display.newSprite("#shangzhen_txt.png")
  self:addChild(tip_pic)
  tip_pic:setPosition(display.cx,display.cy - self:getPopSize().height/2 + 45)
 
end

function CardFormationPropertyView:onExit()
  CardFormationPropertyView.super.onExit(self)
end

function CardFormationPropertyView:buildPropertyItem(propertyType)
  local callBack = function(pb,target)
    if AllConfig.attributetips[propertyType] ~= nil then
      local desc = AllConfig.attributetips[propertyType].tips
      TipsInfo:showStringTip(desc,CCSizeMake(250, 0),ccc3(255,255,255),target,ccp(52,57),nil,true)
    end
  end
  local item = display.newNode()
  local normal = display.newSprite("#shangzhen_attributebtn.png")
  local highted = display.newSprite("#shangzhen_attributebtn.png")
  local disabled = display.newSprite("#shangzhen_attributebtn.png")
  local button = UIHelper.ccMenuWithSprite(normal,highted,disabled,callBack)
  button:setPositionY(-4)
  button:setTouchPriority(-258)
  item:addChild(button)
  
  local labelPropertyName = CCLabelTTF:create(self:getPropertyNameByType(propertyType), "Courier-Bold",22)
  labelPropertyName:setColor( ccc3(0,0,0))
  item:addChild(labelPropertyName)
  
  if GameData:Instance():getLanguageType() == LanguageType.JPN then
    if propertyType == k_property_damage_reduce or propertyType == k_property_damage_increase then
      labelPropertyName:setScale(0.8)
    end
  end
  
  local valueBg = display.newSprite("#shangzhen_attribute_box.png")
  item:addChild(valueBg)
  valueBg:setPositionX(145)
  
  local propertyValue = ""
  
  local card = self:getCard()
  if card ~= nil then
    local config = card:getConfigId()
    if AllConfig.unitgrown[config] ~= nil then
      local recommends = AllConfig.unitgrown[config].recommend_attribute 
      for key, type in pairs(recommends) do
      	if type == propertyType then
      	  local recommendIcon = display.newSprite("#shangzhen_recommend.png")
      	  item:addChild(recommendIcon)
      	  recommendIcon:setPosition(ccp(-32,4))
      	  break
      	end
      end
    end
  
    local isPer = false
    propertyValue,isPer = card:getPropertyByType(propertyType)
    if isPer == true then
      if k_property_hit == propertyType then
        propertyValue = propertyValue - 10000
      elseif kCriticalDamageIncAddPercent == propertyType then
        propertyValue = propertyValue + 5000
      end
      propertyValue = "+"..((propertyValue/10000)*100).."%"
    end
  end
  
  local labelPropertyValue = CCLabelTTF:create(tostring(propertyValue), "Courier-Bold",22)
  labelPropertyValue:setColor( ccc3(255,255,255))
  labelPropertyValue:setAnchorPoint(ccp(0,0.5))
  labelPropertyValue:setPosition(8,19)
  valueBg:addChild(labelPropertyValue)
  
  --talent info
  local talentTypeConvert = propertyType
  local talentProperties = GameData:Instance():getCurrentPlayer():getTalentProperties()
  if propertyType == k_property_hp_fix then
    talentTypeConvert = k_property_hp_per
  elseif propertyType == k_property_atk_fix then
    talentTypeConvert = k_property_atk_per
  elseif propertyType == k_property_str_fix then
    talentTypeConvert = k_property_str_per
  elseif propertyType == k_property_int_fix then
    talentTypeConvert = k_property_int_per
  elseif propertyType == k_property_dom_fix then
    talentTypeConvert = k_property_dom_per
  end
    
  if talentProperties[talentTypeConvert] ~= nil then
    local type = talentProperties[talentTypeConvert].type
    local value = talentProperties[talentTypeConvert].value
    local str = ""
    if type == 0 then --per
      str = "+"..((value/10000)*100).."%"
      
      --to show fix value
--      local propertyValue = 0
--      if talentTypeConvert == k_property_hp_per then
--        propertyValue = card:getPropertyByType(k_property_hp_fix)*(value/10000)
--        str = "+"..toint(propertyValue)
--      elseif talentTypeConvert == k_property_atk_per then
--        propertyValue = card:getPropertyByType(k_property_atk_fix)*(value/10000)
--        str = "+"..toint(propertyValue)
--      elseif talentTypeConvert == k_property_str_per then
--        propertyValue = card:getPropertyByType(k_property_str_fix)*(value/10000)
--        str = "+"..toint(propertyValue)
--      elseif talentTypeConvert == k_property_int_per then
--        propertyValue = card:getPropertyByType(k_property_int_fix)*(value/10000)
--        str = "+"..toint(propertyValue)
--      elseif talentTypeConvert == k_property_dom_per then
--        propertyValue = card:getPropertyByType(k_property_dom_fix)*(value/10000)
--        str = "+"..toint(propertyValue)
--      end
  
    elseif type == 1 then --fix
      str = "+"..value
    end
  
    local labelTalentPropertyValue = CCLabelTTF:create(str, "Courier-Bold",22)
    labelTalentPropertyValue:setColor(sgGREEN)
    labelTalentPropertyValue:setAnchorPoint(ccp(1,0.5))
    labelTalentPropertyValue:setPosition(152,19)
    valueBg:addChild(labelTalentPropertyValue)
  
  end
  
  return item
end

return CardFormationPropertyView