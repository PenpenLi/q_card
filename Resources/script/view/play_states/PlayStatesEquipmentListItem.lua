require("view.component.EquipOrbitCard")

PlayStatesEquipmentListItem = class("PlayStatesEquipmentListItem", BaseView)

function PlayStatesEquipmentListItem:ctor(actEquRootId)

   local pkg = ccbRegisterPkg.new(self)
  -- regist handler
  pkg:addFunc("iconTouchCallback",PlayStatesEquipmentListItem.iconTouchCallback)
  -- regist property
  pkg:addProperty("previewContainer","CCNode")
  pkg:addProperty("suo1","CCNode")
  pkg:addProperty("suo2","CCNode")
  pkg:addProperty("suo3","CCNode")
  pkg:addProperty("suo4","CCNode")
  pkg:addProperty("node_star","CCNode")
  pkg:addProperty("node_progress","CCNode")
  pkg:addProperty("isSelectedHightLight","CCScale9Sprite")
  pkg:addProperty("listNormalBoader","CCScale9Sprite")
  pkg:addProperty("bn_selected","CCControlButton")
  pkg:addProperty("bn_pic","CCControlButton")
  
  
  local spriteNameArray = { "star1",
  "star2","star3","star4",
  "star5","isSelectedIcon"}
  
  local numLables = table.getn(spriteNameArray)
  for i = numLables,1,-1 do
     pkg:addProperty(spriteNameArray[i],"CCSprite")
  end

  pkg:addProperty("sprite_coin","CCSprite")
  pkg:addProperty("lableName","CCLabelTTF")
  pkg:addProperty("lableAtkPre","CCLabelTTF")
  pkg:addProperty("lableAtk","CCLabelTTF")
  pkg:addProperty("lableInfo","CCLabelTTF")
  pkg:addProperty("descPre1","CCLabelTTF")
  pkg:addProperty("descPre2","CCLabelTTF")
  pkg:addProperty("descPre3","CCLabelTTF")
  pkg:addProperty("descPre4","CCLabelTTF")
  pkg:addProperty("desc1","CCLabelTTF")
  pkg:addProperty("desc2","CCLabelTTF")
  pkg:addProperty("desc3","CCLabelTTF")
  pkg:addProperty("desc4","CCLabelTTF")
  
  pkg:addProperty("labelEmpty1","CCLabelTTF")
  pkg:addProperty("labelEmpty2","CCLabelTTF")
  pkg:addProperty("labelEmpty3","CCLabelTTF")
  pkg:addProperty("labelEmpty4","CCLabelTTF")

  local layer,owner = ccbHelper.load("PlayStatesEquipmentListItem.ccbi","PlayStatesEquipmentListItemCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.isSelectedHightLight:setVisible(false)
  
  self._starArray = { self.star1,self.star2,self.star3,self.star4,self.star5 }
  self:setSelected(false)
  
  self.bn_pic:setTouchPriority(-126)

  self:initOutLineLabel()
  self:setActEquipRootId(actEquRootId)
end



function PlayStatesEquipmentListItem:initOutLineLabel()
  --coint name
  -- self.lableName:setString("")
  -- self.pOutLineName = ui.newTTFLabelWithOutline( {
  --                                           text = " ",
  --                                           font = "fzcyjt.ttf",
  --                                           size = 24,
  --                                           x = 0,
  --                                           y = 0,
  --                                           color = ccc3(247, 255, 17),
  --                                           align = ui.TEXT_ALIGN_LEFT,
  --                                           --valign = ui.TEXT_VALIGN_TOP,
  --                                           --dimensions = CCSize(200, 30),
  --                                           outlineColor =ccc3(0,0,0),
  --                                           pixel = 2
  --                                           }
  --                                         )
  -- -- self.lableName:addChild(self.pOutLineName)
  -- self.pOutLineName:setPosition(ccp(self.lableName:getPosition()))
  -- self.lableName:getParent():addChild(self.pOutLineName)

  self.lableAtkPre:setString("")
  self.pOutLineAtkPre = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = self.lableAtkPre:getFontName(),
                                            size = self.lableAtkPre:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(0, 255, 16),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = CCSize(200, 30),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  -- self.lableAtkPre:addChild(self.pOutLineAtkPre)
  self.pOutLineAtkPre:setPosition(ccp(self.lableAtkPre:getPosition()))
  self.lableAtkPre:getParent():addChild(self.pOutLineAtkPre)

  self.lableInfo:setString("")
  self.pOutLineInfo = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = self.lableInfo:getFontName(),
                                            size = self.lableInfo:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 239, 165),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = CCSize(200, 30),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )

  self.pOutLineInfo:setPosition(ccp(self.lableInfo:getPosition()))
  self.lableInfo:getParent():addChild(self.pOutLineInfo)
end

------
--  Getter & Setter for
--      PlayStatesEquipmentListItem._equimentData 
-----
function PlayStatesEquipmentListItem:setEquipmentData(equimentData, bShowPrice)
	self._equimentData = equimentData
	self:setGrade(self._equimentData:getGrade())
	self.lableName:setString(self._equimentData:getName())
	-- self.pOutLineName:setString( self._equimentData:getName())
  self:setExpProgressVisible(false)

	if self._equimentData:getCard() ~= nil then
		 -- self.lableInfo:setString(self._equimentData:getCard():getName().."佩戴")
	   self.pOutLineInfo:setString(self._equimentData:getCard():getName().._tr("dressing"))
	   local x = self.lableInfo:getPositionX() - self.pOutLineInfo:getContentSize().width 
	   self.pOutLineInfo:setPositionX(x)
	else
	   self.pOutLineInfo:setString(" ")
	end
	
  local attrTbl = self._equimentData:getSkillAttrExt()
  local attrCount = 0

  local nameArr = {self.descPre1, self.descPre2, self.descPre3, self.descPre4}
  local valArr = {self.desc1, self.desc2, self.desc3, self.desc4}

  for i=1, 4 do 
    nameArr[i]:removeAllChildrenWithCleanup(true)
  end

  --show equipment attr info
  for i=1, table.getn(attrTbl) do 

    if attrTbl[i].genType == 1 then --base

      --self.lableAtkPre:setString(attrTbl[i].name)
      -- self.pOutLineAtkPre:setString(attrTbl[i].name)
      --  self.lableAtk:setString(attrTbl[i].data)
      local str = attrTbl[i].name..attrTbl[i].data
      self.pOutLineAtkPre:setString(str)
      self.lableAtk:setString("")

      -- local w = self.pOutLineName:getContentSize().width
      -- local org_x1 = self.pOutLineName:getPositionX()
      local w = self.lableName:getContentSize().width
      local org_x1 = self.lableName:getPositionX()
      local org_x2 = self.lableAtkPre:getPositionX()
      
      if w > (org_x2 - org_x1)  then 
        self.pOutLineAtkPre:setPositionX(org_x1+w+20)
      else 
        self.pOutLineAtkPre:setPositionX(org_x2)
      end

      if bShowPrice ~= nil and bShowPrice == true then 
        local x = self.pOutLineAtkPre:getPositionX() + self.pOutLineAtkPre:getContentSize().width + 10
        self.sprite_coin:setPositionX(x)
        self.lableAtk:setPositionX(x+self.sprite_coin:getContentSize().width)
        self.sprite_coin:setVisible(true)
        self.lableAtk:setString(string.format("%d", self._equimentData:getSalePrice()))
      end

    else  --random

      attrCount = attrCount + 1     
      if attrCount <= 4 then 
        if attrTbl[i].attrIconId == nil then 
          nameArr[attrCount]:setString(attrTbl[i].name)
        else 
          nameArr[attrCount]:setString("")
          local img = _res(attrTbl[i].attrIconId)
          if img ~= nil then 
            img:setAnchorPoint(ccp(0, 0.5))
            nameArr[attrCount]:addChild(img, 1)
          end
        end

        valArr[attrCount]:setString(attrTbl[i].data)
          
        local x = nameArr[attrCount]:getPositionX() + nameArr[attrCount]:getContentSize().width
        if x > valArr[attrCount]:getPositionX() then 
          valArr[attrCount]:setPositionX(x + 5)
        end
      end
    end
  end


  local arr = {self.labelEmpty1, self.labelEmpty2, self.labelEmpty3, self.labelEmpty4}
  for i=1, 4 do
    if i <= attrCount then 
      arr[i]:setString("")
    else 
      arr[i]:setString("- -")
      nameArr[i]:setString("")
      valArr[i]:setString("")
    end 
  end 

  --show equip icon
  self.previewContainer:removeAllChildrenWithCleanup(true)

  local node = GameData:Instance():getCurrentPackage():getItemSprite(nil, 7, self._equimentData:getConfigId(), 0)
  if self:getActEquipRootId() == self._equimentData:getRootId() then 
    local icon = CCSprite:createWithSpriteFrameName("list_actEquip.png")
    local nodeSize = node:getContentSize()
    icon:setAnchorPoint(ccp(0, 1))
    icon:setPosition(ccp(-nodeSize.width/2+7, nodeSize.height/2-6))
    node:addChild(icon)
    --play breath effect
    local action = CCSequence:createWithTwoActions(CCFadeTo:create(0.8, 100),CCFadeTo:create(1.0, 255))
    icon:runAction(CCRepeatForever:create(action))    
  end 

  local size = node:getContentSize()
  local pos = ccp(26-size.width/2, 20-size.height/2)
  local preLv = CCSprite:createWithSpriteFrameName("playstates-image-lv.png")
  if preLv ~= nil then 
    preLv:setPosition(pos)
    node:addChild(preLv)

    local label = CCLabelBMFont:create(""..self._equimentData:getLevel(), "client/widget/words/card_name/number_skillup.fnt")
    if label ~= nil then 
      label:setPosition(ccp(pos.x+preLv:getContentSize().width/2+label:getContentSize().width/2+4, pos.y))
      node:addChild(label)
    end 
  end 


  self.previewContainer:addChild(node)
end

function PlayStatesEquipmentListItem:getEquipmentData()
	return self._equimentData
end


function PlayStatesEquipmentListItem:setSelected(isSelected)
  self.isSelectedIcon:setVisible(isSelected)
  --self.isSelectedHightLight:setVisible(isSelected)
--  if isSelected == true then
--    self.listNormalBoader:setVisible(false)
--  else
--    self.listNormalBoader:setVisible(true)
--  end
end

function PlayStatesEquipmentListItem:getSelected()
  return self.isSelectedIcon:isVisible()
end

function PlayStatesEquipmentListItem:setGrade(starGrade)
  
    self._starGrade = starGrade
    local starW = self.star1:getContentSize().width-2
    local posx = self.previewContainer:getPositionX()
    posx = posx - (self._starGrade-1)*starW/2

    for i = 1, 5 do 
      if i <= self._starGrade then 
        self._starArray[i]:setVisible(true)
        self._starArray[i]:setPositionX(posx + (i-1)*starW)
      else 
        self._starArray[i]:setVisible(false)
      end 
    end
end

function PlayStatesEquipmentListItem:getGrade()
  return self._starGrade
end




----below add by hlb
function PlayStatesEquipmentListItem:setSelectedVisible(isSelected)
  self.bn_selected:setVisible(isSelected)
end

function PlayStatesEquipmentListItem:setSelectedIconVisible(isSelected)
  self.isSelectedIcon:setVisible(isSelected)
end 

function PlayStatesEquipmentListItem:setSelectedHighlight(isSelected)
  self.isSelectedHightLight:setVisible(isSelected)
end 

function PlayStatesEquipmentListItem:iconTouchCallback()
  if self._isBnEanbleDelegate ~= nil then 
    if self._isBnEanbleDelegate() == false then
      echo("invalid bn delegate...")
      return
    end
  end

  local equipData = self:getEquipmentData()
  if equipData ~= nil then
    echo("eqip configid=", equipData:getConfigId())
	  self.card =  EquipOrbitCard.new({equipData = equipData})
	  self.card:show()
  end
end

function PlayStatesEquipmentListItem:setButtonEnableDelegate(delegate)
  self._isBnEanbleDelegate = delegate
end

function PlayStatesEquipmentListItem:setExpProgressVisible(isVisible)

  if isVisible and self._equimentData ~= nil then 
    self.node_star:setPositionY(25)
    self.node_progress:setVisible(true)
    self.node_progress:removeAllChildrenWithCleanup(true)

    local expImg = CCSprite:createWithSpriteFrameName("EXP2.png")
    local percent = 100*self._equimentData:getExperience()/self._equimentData:getMaxExperience()
    local bg = CCSprite:createWithSpriteFrameName("list_progress_bg.png")
    local fg1 = CCSprite:createWithSpriteFrameName("list_progress_fg.png")
    local progressor = ProgressBarView.new(bg, fg1, nil)
    progressor:setPercent(percent, 1)

    local w1 = expImg:getContentSize().width 
    local w2 = bg:getContentSize().width 
    expImg:setPositionX(w1/2)
    progressor:setPositionX(w1+w2/2)
    self.node_progress:addChild(expImg)
    self.node_progress:addChild(progressor)
  else 
    self.node_star:setPositionY(0)
    self.node_progress:setVisible(false)
  end 
end 

function PlayStatesEquipmentListItem:setActEquipRootId(id)
  self._actRootId = id 
end 

function PlayStatesEquipmentListItem:getActEquipRootId()
  return self._actRootId
end 

