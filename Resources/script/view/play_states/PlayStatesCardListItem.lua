require("view.BaseView")
require("view.component.OrbitCard")

PlayStatesCardListItem = class("PlayStatesCardListItem", BaseView)

function PlayStatesCardListItem:ctor()
  
  local spriteNameArray = { "star1","star2","star3","star4","star5","star6","star7","star8","star9","star10","isSelectedIcon" }
  local pkg = ccbRegisterPkg.new(self)
  local num = table.getn(spriteNameArray)
  for i = num,1,-1 do
     pkg:addProperty(spriteNameArray[i],"CCSprite")
  end
  pkg:addProperty("cardContainer","CCNode")
  pkg:addProperty("label_levelPre","CCLabelTTF")
  pkg:addProperty("lableLevel","CCLabelTTF")
  pkg:addProperty("lableName","CCLabelTTF")
  -- pkg:addProperty("label_atkPre","CCLabelTTF")
  pkg:addProperty("label_atk","CCLabelTTF")
  -- pkg:addProperty("label_hpPre","CCLabelTTF")
  pkg:addProperty("label_HP","CCLabelTTF")
  pkg:addProperty("label_zhandouli","CCLabelTTF")
  pkg:addProperty("sprite_shangzhen","CCSprite")
  pkg:addProperty("sprite_mining","CCSprite")
  pkg:addProperty("sprite_coin","CCSprite")
  pkg:addProperty("isSelectedHightLight","CCScale9Sprite")
  pkg:addProperty("listNormalBoader","CCScale9Sprite")
  pkg:addProperty("bn_selected","CCControlButton")
  pkg:addProperty("bn_header","CCControlButton")
  pkg:addFunc("headerCallback",PlayStatesCardListItem.headerCallback)


  local layer,owner = ccbHelper.load("PlayStatesCardListItem.ccbi","PlayStatesCardListItemCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self._starArray = { self.star1,self.star2,self.star3,self.star4,self.star5,self.star6,self.star7,self.star8,self.star9,self.star10}
  
  self.isSelectedHightLight:setVisible(false)
  self:setSelected(false)
  
  self.bn_header:setTouchPriority(-126)
  
  local cardHead = CardHeadView.new()
  --cardHead:setScale(0.7)
  self._cardView = cardHead
  self.cardContainer:addChild(self._cardView)
  self.cardContainer:setPositionY(self.cardContainer:getPositionY()+10)

  local pos = self.label_levelPre:getParent():convertToWorldSpace(ccp(self.label_levelPre:getPosition()))
  self.labelInfoPosX = pos.x

  self:initOutLineLabel()
end


function PlayStatesCardListItem:initOutLineLabel()
  -- name
  -- self.lableName:setString("")
  -- self.pOutLineName = ui.newTTFLabelWithOutline( {
  --                                           text = " ",
  --                                           font = "Courier-Bold",
  --                                           size = 30,
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

  --level pre
  self.label_levelPre:setString("")
  self.pOutLineLevelPre = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = "Courier-Bold",
                                            size = 24,
                                            x = 0,
                                            y = 0,
                                            color = ccc3(32, 143, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = CCSize(200, 30),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  -- self.label_levelPre:addChild(self.pOutLineLevelPre)
  self.pOutLineLevelPre:setPosition(ccp(self.label_levelPre:getPosition()))
  self.label_levelPre:getParent():addChild(self.pOutLineLevelPre)

  --hp pre
  -- self.label_hpPre:setString("")
  -- local hpPre = ui.newTTFLabelWithOutline( {
  --                                           text = "生命值",
  --                                           font = "fzcyjt.ttf",
  --                                           size = 20,
  --                                           x = 0,
  --                                           y = 0,
  --                                           color = ccc3(66, 255, 99),
  --                                           align = ui.TEXT_ALIGN_LEFT,
  --                                           --valign = ui.TEXT_VALIGN_TOP,
  --                                           --dimensions = CCSize(200, 30),
  --                                           outlineColor =ccc3(0,0,0),
  --                                           pixel = 2
  --                                           }
  --                                         )
  -- -- self.label_hpPre:addChild(hpPre)
  -- hpPre:setPosition(ccp(self.label_hpPre:getPosition()))
  -- self.label_hpPre:getParent():addChild(hpPre)

  --atk pre
  -- self.label_atkPre:setString("")
  -- local atkPre = ui.newTTFLabelWithOutline( {
  --                                           text = "攻击力",
  --                                           font = "fzcyjt.ttf",
  --                                           size = 20,
  --                                           x = 0,
  --                                           y = 0,
  --                                           color = ccc3(250, 101, 61),
  --                                           align = ui.TEXT_ALIGN_LEFT,
  --                                           --valign = ui.TEXT_VALIGN_TOP,
  --                                           --dimensions = CCSize(200, 30),
  --                                           outlineColor =ccc3(0,0,0),
  --                                           pixel = 2
  --                                           }
  --                                         )
  -- -- self.label_atkPre:addChild(atkPre)
  -- atkPre:setPosition(ccp(self.label_atkPre:getPosition()))
  -- self.label_atkPre:getParent():addChild(atkPre)
end 

function PlayStatesCardListItem:setSelected(isSelected)
	self.isSelectedIcon:setVisible(isSelected)
	--self.isSelectedHightLight:setVisible(isSelected)
--  if isSelected == true then
--    self.listNormalBoader:setVisible(false)
--  else
--    self.listNormalBoader:setVisible(true)
--  end
end

function PlayStatesCardListItem:getSelected()
	return self.isSelectedIcon:isVisible()
end

function PlayStatesCardListItem:setCard(card)
	self._card = card
  local curLevel = self._card:getLevel()
	self:setGrade(self._card:getGrade())
	self._cardView:setCard(card)
  -- self:setLevelString(curLevel.."/"..self._card:getMaxLevel())
	self.lableName:setString(self._card:getName())
	-- self.pOutLineName:setString( self._card:getName())
	self:setSelected(self._card:getIsOnBattle())
  self.label_atk:setString(string.format("%d", card:getAttackByLevel(curLevel)))
  self.label_HP:setString(string.format("%d", card:getHpByLevel(curLevel)))

  self:setLeaderImgVisible(card:getIsOnBattle())
  self:setMiningImgVisible(card:getCradIsWorkState())

  local val = GameData:Instance():getBattleAbilityForCards({card})
  self.label_zhandouli:setString(string.format("%d", val))
end

function PlayStatesCardListItem:getCard()
	return self._card
end

function PlayStatesCardListItem:setGrade(starGrade)

	self._starGrade = starGrade
  local starW = self.star1:getContentSize().width 
  local posx = self.cardContainer:getPositionX()

  if self._card ~= nil then
    local maxGrade = self._card:getMaxGrade()  or 0
    --print("maxGrade",maxGrade)
    posx = posx - (maxGrade-1)*starW/2
    for i = 1, 5 do 
      if i <= maxGrade then 
        if i <= self._starGrade then 
          self._starArray[i]:setVisible(true)
          self._starArray[i]:setPositionX(posx + (i-1)*starW)
          self._starArray[5+i]:setVisible(false)
        else 
          self._starArray[5+i]:setVisible(true)
          self._starArray[5+i]:setPositionX(posx + (i-1)*starW)
          self._starArray[i]:setVisible(false)
        end
      else 
        self._starArray[i]:setVisible(false)
        self._starArray[5+i]:setVisible(false)
      end
    end
  end
end

function PlayStatesCardListItem:getGrade()
	return self._starGrade
end


----below add by hlb
function PlayStatesCardListItem:setSelectedVisible(isSelected)
  self.bn_selected:setVisible(isSelected)
  --self.isSelectedIcon:setVisible(isSelected)
  --self.isSelectedHightLight:setVisible(isSelected)
end

function PlayStatesCardListItem:setSelectedIconVisible(isSelected)
  self.isSelectedIcon:setVisible(isSelected)
end 


function PlayStatesCardListItem:setLeaderImgVisible(isOnAnyBattle, isOnBattle, typeEnum)
  if isOnAnyBattle == true then 
    local x = self.lableName:getPositionX() + self.lableName:getContentSize().width+6
    -- local x = self.lableName:getPositionX() + self.pOutLineName:getContentSize().width+6
    self.sprite_shangzhen:setPositionX(x)
  end 
  self.sprite_shangzhen:setVisible(isOnAnyBattle)

  if isOnAnyBattle and typeEnum then 
    local frame 
    if typeEnum[1] == BattleFormation.BATTLE_INDEX_NORMAL_1 then 
      frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("list_gong1.png")
    elseif typeEnum[1] == BattleFormation.BATTLE_INDEX_NORMAL_2 then 
      frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("list_gong2.png")
    elseif typeEnum[1] == BattleFormation.BATTLE_INDEX_NORMAL_3 then 
      frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("list_gong3.png")
    elseif typeEnum[1] == BattleFormation.BATTLE_INDEX_PVP then 
      frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("list_zheng.png")
    elseif typeEnum[1] == BattleFormation.BATTLE_INDEX_RANK_MATCH then 
      frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("list_jing.png")
    elseif typeEnum[1] == BattleFormation.BATTLE_INDEX_BABLE then 
    end 
    
    if frame then 
      self.sprite_shangzhen:setDisplayFrame(frame)
    end 
  end 
end

function PlayStatesCardListItem:setMiningImgVisible(isVisible)
  if isVisible == true then 
    local x = self.lableName:getPositionX() + self.lableName:getContentSize().width+6
    self.sprite_mining:setPositionX(x)
  end 
  self.sprite_mining:setVisible(isVisible)
end

function PlayStatesCardListItem:setLevelPreName(strName, color)
  --self.label_levelPre:setString(strName)
  --local w = self.label_levelPre:getContentSize().width
  -- if w > 165 then 
  --   self.label_levelPre:setPositionX(self.labelInfoPosX-(w-165))
  -- else 
  --   self.label_levelPre:setPositionX(self.labelInfoPosX)
  -- end

  local org_x = self.label_levelPre:getPositionX()
  
  self.pOutLineLevelPre:setString(strName)
  local w = self.pOutLineLevelPre:getContentSize().width
  if w > 185 then 
    -- self.pOutLineLevelPre:setPositionX(org_x-(w-185))
    local x = self.lableName:getPositionX() + self.lableName:getContentSize().width+30
    self.pOutLineLevelPre:setPositionX(x)
  else 
    self.pOutLineLevelPre:setPositionX(org_x)
  end



  local pos_x = 0
  if self.sprite_coin:isVisible() == true then 
    pos_x = self.labelInfoPosX + w + self.sprite_coin:getContentSize().width + 5
  else
    pos_x = self.labelInfoPosX + w + 5
  end
  
  self.lableLevel:setPositionX(pos_x)
  if color ~= nil then
    self.label_levelPre:setColor(color)
    self.pOutLineLevelPre:setColor( color)
  end
end

function PlayStatesCardListItem:getCointSprite()
  return self.sprite_coin
end

function PlayStatesCardListItem:setLevelString(str)
  if str ~= nil then
    self.lableLevel:setString(str)
  end
end

function PlayStatesCardListItem:setSelectedHighlight(isSelected)
  self.isSelectedHightLight:setVisible(isSelected)
end 

function PlayStatesCardListItem:headerCallback()

  if self._isBnEanbleDelegate ~= nil then 
    if self._isBnEanbleDelegate() == false then
      echo("invalid bn delegate...")
      return
    end
  end

  if self._clickHeadEnable ~= nil and self._clickHeadEnable == false then
	return
  end


  
  local headerCard = self:getCard()
  if headerCard ~= nil then 
    self.card =  OrbitCard.new({card = headerCard})
    self.card:show()
  end
end

function PlayStatesCardListItem:setButtonEnableDelegate(delegate)
  self._isBnEanbleDelegate = delegate
end

function PlayStatesCardListItem:setHeadClickEnable(isEnable)
	self._clickHeadEnable = isEnable
end


return PlayStatesCardListItem
