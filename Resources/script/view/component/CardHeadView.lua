require("model.battle.BattleConfig")
CardHeadView = class("CardHeadView", BaseView)

function CardHeadView:ctor(card,type)

  local spriteArray = { "marshalIcon",
    "spritePortrait",
    "jiaSprite",
    "spriteLock" }
  
  local pkg = ccbRegisterPkg.new(self)
  
  local numSprites = table.getn(spriteArray)
  for i = numSprites,1,-1 do
     pkg:addProperty(spriteArray[i],"CCSprite")
  end
  pkg:addProperty("headContainer","CCNode")
  pkg:addProperty("nodeLevelContainer","CCNode")
  pkg:addProperty("portraitNode","CCNode")
  pkg:addProperty("nodeBorder","CCNode")
  pkg:addProperty("nodeJobPlace","CCNode")
  pkg:addProperty("spriteLv","CCSprite")
  pkg:addProperty("labelLevel","CCLabelTTF")
  pkg:addProperty("isSelectedIcon","CCScale9Sprite")
  pkg:addProperty("clickHeadMenu","CCMenu")
  pkg:addProperty("clickHeadMenuItem","CCMenuItemImage")



  pkg:addFunc("clickHeadCallBack",CardHeadView.onClickHeadCallBack)
  local layer,owner = ccbHelper.load("CardHeadView.ccbi","CardHeadViewCCB","CCNode",pkg)

  self.clickHeadMenu:setTouchPriority(-1128)
  self:addChild(layer)
  self._isEnableClick = false
  self.clickHeadMenu:setEnabled(false)
  
  self.nodeJobPlace:setPosition(ccp(self.nodeJobPlace:getPositionX()-5,self.nodeJobPlace:getPositionY()+5))
  self.marshalIcon:setPosition(ccp(self.marshalIcon:getPositionX()+10,self.marshalIcon:getPositionY()-10))
  
  
  self.nodeLevelCon = display.newNode()
  self.nodeLevelCon:setCascadeOpacityEnabled(true)
  self.nodeLevelContainer:addChild(self.nodeLevelCon)
  
  self.labelLevel:removeFromParentAndCleanup(false)
  self.spriteLv:removeFromParentAndCleanup(false)
  
  self.nodeLevelCon:addChild(self.labelLevel)
  self.nodeLevelCon:addChild(self.spriteLv)
  self:setLvFadeEnabled(true)
  
--  self._labelLevel = ui.newTTFLabelWithOutline( {
--                                          text = "1",
--                                          font = "Courier-Bold.ttf",
--                                          size = 20,
--                                          x = 0,
--                                          y = 0,
--                                          color = ccc3(255, 255, 255),
--                                          align = ui.TEXT_ALIGN_CENTER,
--                                          --valign = ui.TEXT_VALIGN_TOP,
--                                          --dimensions = CCSize(200, 30),
--                                          outlineColor =ccc3(0,0,0),
--                                          pixel = 2
--                                          }
--                                        )

  self._labelLevel = CCLabelBMFont:create("1", "client/widget/words/card_name/number_skillup.fnt")
  self._labelLevel:setCascadeOpacityEnabled(true)
  self.nodeLevelCon:addChild(self._labelLevel,100)
  self._labelLevel:setPosition(ccpAdd(ccp(self.labelLevel:getPositionX(),self.labelLevel:getPositionY()),ccp(0,8)))
  self.labelLevel:setString("")
  self.spriteLv:setPosition(ccp(self.spriteLv:getPositionX(),self.spriteLv:getPositionY()+11))

--  local sequence = CCSequence:createWithTwoActions(CCDelayTime:create(1), CCFadeOut:create(1.5))
--  local seq = CCSequence:createWithTwoActions(CCFadeIn:create(1.5), sequence)
--  self.nodeLevelCon:runAction(CCRepeatForever:create(seq))
  
  self.isSelectedIcon:setVisible(false)
  if card ~= nil then
    self:setCard(card)
  end
  self:setLocked(false)
end

------
--  Getter & Setter for
--      CardHeadView._isSelected 
-----
function CardHeadView:setSelected(isSelected)
	self._isSelected = isSelected
	self.isSelectedIcon:setVisible(isSelected)
end

function CardHeadView:getSelected()
	return self._isSelected
end

------
--  Getter & Setter for
--      CardHeadView._LvFadeEnabled 
-----
function CardHeadView:setLvFadeEnabled(LvFadeEnabled)
	self._LvFadeEnabled = LvFadeEnabled
	self.nodeLevelCon:stopAllActions()
	if self:getLvVisible() == true then
	 if LvFadeEnabled == false then
	   self.nodeLevelCon:runAction(CCFadeIn:create(0.25))
	 elseif LvFadeEnabled == true then
	   local sequence = CCSequence:createWithTwoActions(CCDelayTime:create(1), CCFadeOut:create(1.5))
     local seq = CCSequence:createWithTwoActions(CCFadeIn:create(1.5), sequence)
     self.nodeLevelCon:runAction(CCRepeatForever:create(seq))
	 end
	end
end

function CardHeadView:getLvFadeEnabled()
	return self._LvFadeEnabled
end

function CardHeadView:hideCardDetails()
     self.spritePortrait:setVisible(true)
     self.portraitNode:setVisible(true)
     self.marshalIcon:setVisible(false)
     self.isSelectedIcon:setVisible(false)
     self.nodeJobPlace:setVisible(false)
     self.jiaSprite:setVisible(false)
     self.spriteLock:setVisible(false)
     if self._LvVisible == false then
        self.spriteLv:setVisible(false)
        self.labelLevel:setString("")
        self._labelLevel:setString("")
     end
end

function CardHeadView:setLvVisible(LvVisible)
	self._LvVisible = LvVisible
	if self._LvVisible == false then
      self.spriteLv:setVisible(false)
      self.labelLevel:setString("")
      self._labelLevel:setString("")
      --self.nodeLevelCon:stopAllActions()
  else
      
      self._labelLevel:setString(self._cardModel:getLevel().."")
      
--      if self.spriteLv:isVisible() == false then
--          local sequence = CCSequence:createWithTwoActions(CCDelayTime:create(1), CCFadeOut:create(1.5))
--          local seq = CCSequence:createWithTwoActions(CCFadeIn:create(1.5), sequence)
--          self.nodeLevelCon:runAction(CCRepeatForever:create(seq))
--      end
      
      self.spriteLv:setVisible(true)
      
--      local seq = CCSequence:createWithTwoActions(CCFadeIn:create(1.5), CCFadeOut:create(1.5))
--      self.nodeLevelCon:runAction(CCRepeatForever:create(seq))
  end
end

function CardHeadView:getLvVisible()
	return self._LvVisible
end

function CardHeadView:setLvStr(str)
  if str ~= nil then
    self._labelLevel:setString(str)
  end
end

function CardHeadView:setIsHideBoard(isHideBoard)
    self._isHideBoard = isHideBoard
    
    if self._isHideBoard == true then
        self.nodeBorder:setVisible(false)
    else
        self.nodeBorder:setVisible(true)
    end
end

function CardHeadView:getIsHideBoard()
   return self._isHideBoard
end

------
--  Getter & Setter for
--      CardHeadView._Locked 
-----
function CardHeadView:setLocked(Locked)
	self._Locked = Locked
	self.spriteLock:setVisible(self._Locked)
	 if self._Locked == true then
	  self.jiaSprite:setVisible(false)
	 end
end

function CardHeadView:getLocked()
	return self._Locked
end


function CardHeadView:setScale(scale)
	self.headContainer:setScale(scale)
end


function CardHeadView:getScale()
	return self.headContainer:getScale()
end

function CardHeadView:setWidth(width)
	self.headContainer:setContentSize(CCSizeMake(width,self.headContainer:getContentSize().height))
end

function CardHeadView:getWidth()
	return self.headContainer:getContentSize().width
end

function CardHeadView:setContentSize(cSize)
  self.headContainer:setContentSize(cSize)
end

function CardHeadView:getContentSize()
  return self.headContainer:getContentSize()
end

function CardHeadView:getHeadContainer()
  return self.headContainer
end

function CardHeadView:setHeight(height)
	self.headContainer:setContentSize(CCSizeMake(self.headContainer:getContentSize().width,height))
end

function CardHeadView:getHeight()
	return self.headContainer:getContentSize().height
end 

function CardHeadView:setCardByConfigId(configId)
  self._configId =  configId
  local card = Card.new()
  card:initAttrById(configId)
  card:setIsBoss(false)
  card:setExperience(0)
  card:setIsOnBattle(false)

  self:setCard(card)
end 

function CardHeadView:setCard(cardModel)
  self._cardModel = cardModel
  if cardModel ~= nil then  
    -- add troop icon
    local sptIcon = _res(PbTroopSpt[cardModel:getSpecies()])
    if sptIcon ~= nil then
      sptIcon:setScale(0.4)
      self.nodeJobPlace:removeAllChildrenWithCleanup(true)
      self.nodeJobPlace:addChild(sptIcon)

      local sptFrameCorner = _res(3022010 +  cardModel:getGrade())
      if sptFrameCorner ~= nil then 
        self.nodeJobPlace:addChild(sptFrameCorner,-1)
      end 
    end  
      
    self._configId = cardModel:getConfigId()
    
    if self._LvVisible == false then
      --self.spriteLv:setVisible(false)
      --self.labelLevel:setString("")
      self._labelLevel:setString("")
      --self.nodeLevelCon:stopAllActions()
    else
      --self.labelLevel:setString(cardModel:getLevel().."")
      self._labelLevel:setString(cardModel:getLevel().."")
      
      if self:getLvFadeEnabled() == true then
        if self.nodeLevelCon:getNumberOfRunningActions() < 1 then
          local sequence = CCSequence:createWithTwoActions(CCDelayTime:create(1), CCFadeOut:create(1.5))
          local seq = CCSequence:createWithTwoActions(CCFadeIn:create(1.5), sequence)
          self.nodeLevelCon:runAction(CCRepeatForever:create(seq))
        end
      end
      --self.spriteLv:setVisible(true)
    end

   -- local coulorBoader = _res(3021040 + cardModel:getGrade())
   local grade = cardModel:getGrade() 
   local subGrade = cardModel:getImproveGrade()
   local resId = 3021051 + math.max(0, (grade-3)*3) + grade-1 + subGrade 
   local coulorBoader = _res(resId)
   if coulorBoader ~= nil then
      self.nodeBorder:removeAllChildrenWithCleanup(true)
      self.nodeBorder:addChild(coulorBoader)
   end

   self.spritePortrait:setVisible(true)
   self.portraitNode:setVisible(true)
   self.nodeJobPlace:setVisible(true)
   self.jiaSprite:setVisible(false)

    --update Portrait
  	local unitHeadPic = cardModel:getUnitHeadPic()
  	if unitHeadPic ~= nil then
  		self:setIconWithUnitHeadPicId(unitHeadPic)
  	end
    self.marshalIcon:setVisible(cardModel:getIsBoss())
  else

     self.spritePortrait:setVisible(false)
     self.portraitNode:setVisible(false)
     self.marshalIcon:setVisible(false)
     self.isSelectedIcon:setVisible(false)
     self.nodeJobPlace:setVisible(false)
     self.jiaSprite:setVisible(true)
     self.labelLevel:setString("")
     self._labelLevel:setString("")
     self.spriteLv:setVisible(false)
   end
   
end

function CardHeadView:getCard()
	return self._cardModel
end

function CardHeadView:setThumbnailTextureName(textureName)
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(textureName)
	self.spritePortrait:setDisplayFrame(frame)
end

function CardHeadView:setIconWithConfigId(configId)
	if configId == 0 then
		local posX,posY = self.spritePortrait:getPosition()
		if self.spritePortrait~= nil then
			local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("playstates-image-wenhao.png")
			self.spritePortrait:setDisplayFrame(frame)
		end
	else
		local unitTable = AllConfig.unit[configId]
		if unitTable ~= nil then
			local unitHheadPic = AllConfig.unit[configId].unit_head_pic
			local img = _res(unitHheadPic)
			self.portraitNode:removeAllChildrenWithCleanup(true)
			self.portraitNode:addChild(img)
			local showSpriteConsize = img:getContentSize()
			--local spriteConsize = self.spritePortrait:getContentSize()
			img:setScaleX(95/showSpriteConsize.width)
			img:setScaleY(95/showSpriteConsize.height)
		else
			print("ERROR CardHeadView.lua<CardHeadView:setIconWithConfigId: can not find this configId",configId  )
		end

	end
end

function CardHeadView:enableClick(isEnable)
  self._isEnableClick = isEnable
  if isEnable == true then
    self.clickHeadMenu:setEnabled(true)
  end
end

function CardHeadView:onClickHeadCallBack()
  print("===onClickHeadCallBack")
  if self._isEnableClick == true then
    if self:getClickCallback() then 
      self:getClickCallback()(self:getCard())
    else 
    	local orbitCard = OrbitCard.new({configId =  self._configId })
    	orbitCard:show()
    end 
  end
end

function CardHeadView:setClickCallback(userCallback)
  self._clickCallback = userCallback
end 

function CardHeadView:getClickCallback()
  return self._clickCallback
end 

function CardHeadView:setIconWithUnitHeadPicId(unitHeadPicId)
  self.portraitNode:removeAllChildrenWithCleanup(true)
	local img = _res(unitHeadPicId)
	self.portraitNode:addChild(img)
	local showSpriteConsize = img:getContentSize()
	--local spriteConsize = self.spritePortrait:getContentSize()
	img:setScaleX(95/showSpriteConsize.width)
	img:setScaleY(95/showSpriteConsize.height)
end

function CardHeadView:setHeadClickPriority(priority)
	self.clickHeadMenu:setTouchPriority(priority)
end

return CardHeadView