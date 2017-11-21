EquipmentHeadLargeView = class("EquipmentHeadLargeView", BaseView)

local cardFrameTag = 615
local cardJobPlacetag = 241
function EquipmentHeadLargeView:ctor(card)

	local frontArray = {
		"cardAvatarBg" ,
		"cardAvatar",
		"cardBottomBg",
	}
	local frontPkg = ccbRegisterPkg.new(self)
	local numSprites = table.getn(frontArray)
	for i = numSprites,1,-1 do
		frontPkg:addProperty(frontArray[i],"CCSprite")
	end

	frontPkg:addProperty("cardNameNode", "CCNode")
	--frontPkg:addProperty("defaultName", "CCLabelTTF")
	frontPkg:addProperty("cardName", "CCLabelBMFont")
	--frontPkg:addProperty("lbl_quality", "CCLabelTTF")
	frontPkg:addProperty("quality", "CCSprite")

	local layer,owner = ccbHelper.load("EquipmentHeadLargeView.ccbi","EquipmentHeadLargeViewCCB","CCLayer",frontPkg)
	layer:ignoreAnchorPointForPosition(false)
	self:addChild(layer)
	self._cardLayer = layer
	self:setContentSize(layer:getContentSize())

	if card ~= nil then
		self._card = card
		self:setCardStatic(card:getConfigId())
	end
end

function EquipmentHeadLargeView:getStarPosition(starIndex)
	local array = {self.starBg1, self.starBg2, self.starBg3, self.starBg4, self.starBg5}

	local pos = ccp(0,0)
	if starIndex >= 1 and starIndex <= 5 then 
		pos = array[starIndex]:getParent():convertToWorldSpace(ccp(array[starIndex]:getPosition()))
	end
	return pos
end

function EquipmentHeadLargeView:setScale(scale)
	self._cardLayer:setScale(scale)
end

function EquipmentHeadLargeView:getScale()
	return self.headContainer:getScale()
end

function EquipmentHeadLargeView:setWidth(width)
	self.headContainer:setContentSize(ccp(width,self._headContainer:getContentSize().height))
end

function EquipmentHeadLargeView:getWidth()
	return  self.cardAvatarBg:getContentSize().width
end

function EquipmentHeadLargeView:setHeight(height)
	self.headContainer:setContentSize(ccp(self._headContainer:getContentSize().width,height))
end

function EquipmentHeadLargeView:getHeight()
	return self.cardAvatarBg:getContentSize().height
end

local function drawStar(self,curRank,maxRank)

	self._starArray = {}
	local startBgIconId = {3022001,3022002,3022003,3022004,3022005 }
	local starBgLayer = CCLayerColor:create(ccc4(0,0,0,0))  -- 30,30  +10
	starBgLayer:ignoreAnchorPointForPosition(false)
	local forntBgSize = self._cardLayer:getContentSize()
	starBgLayer:setPosition(ccp(forntBgSize.width/2.0,forntBgSize.height-40))
	self._cardLayer:addChild(starBgLayer,100)

	for i = 1, maxRank, 1 do
		local starId = 0
		if i<= curRank then
			starId = 3022006 --亮星星
			local start = _res(starId)
			start:setAnchorPoint(ccp(0,0.5))
			start:setPosition(ccp((i-1)*40,start:getContentSize().height/2.0))
			starBgLayer:addChild(start)
			table.insert(self._starArray,start)
		else
			starId = startBgIconId[curRank]
			local startBg = _res(starId)
			startBg:setAnchorPoint(ccp(0,0.5))
			startBg:setPosition(ccp((i-1)*40,startBg:getContentSize().height/2.0))
			starBgLayer:addChild(startBg)

			starId = 3022006 --亮星星
			local start = _res(starId)
			-- start:setAnchorPoint(ccp(0,0.5))
			start:setPosition(ccp(startBg:getContentSize().width/2.0,startBg:getContentSize().height/2.0))
			startBg:addChild(start)
			table.insert(self._starArray,start)
			start:setVisible(false)
		end
	end
	starBgLayer:setContentSize(CCSizeMake(maxRank*30+(maxRank-1)*10,30))
end

function EquipmentHeadLargeView:getCard()
	return self._card
end
function EquipmentHeadLargeView:setCardStatic(configId)
  self._configId = configId
  if configId ~= 0 then

	  local BgIconId = {3021006,3021007,3021008,3021009,3021010 }   -- 卡牌正面背景+框
	  local bottomBg = {3021016,3021017,3021018,3021019,3021020} -- 卡框的下边条
	  local startBgIconId = {3022001,3022002,3022003,3022004,3022005 }

	  local function drawStarAndFrame(curRank,maxrank)
		  --drawStar(self,curRank,maxrank)

		  -- avatar Bg
		  local BgImg = _res(BgIconId[curRank])
		  local spriteConsize = self.cardAvatar:getContentSize()
		  local posX,posY = self.cardAvatarBg:getPosition()
		  --		print(posX,posY)
		  local parent = self.cardAvatarBg:getParent()
		  if parent ~= nil and BgImg ~= nil then
			  self.cardAvatarBg:removeFromParentAndCleanup(true)
			  BgImg:setPosition(ccp(posX,posY))
			  parent:addChild(BgImg)
			  self.cardAvatarBg = BgImg
		  end

		  -- bottomBg
		  local bottomBgIcon = _res(bottomBg[curRank])
		  local parent = self.cardBottomBg:getParent()

		  if parent ~= nil and bottomBgIcon ~= nil then
			  local posX,posY =  self.cardBottomBg:getPosition()
			  self.cardBottomBg:removeFromParentAndCleanup(true)
			  bottomBgIcon:setPosition(ccp( posX, posY))
			  parent:addChild(bottomBgIcon)
			  self.cardBottomBg = bottomBgIcon
		  end

	  end

	  local function drawAvatar(unitPic)
		  local img = _res(unitPic)
		  local posX,posY = self.cardAvatar:getPosition()
		  local parent = self.cardAvatar:getParent()
		  if parent~=nil and img~=nil and  self.cardAvatar~= nil then
			  self.cardAvatar:removeFromParentAndCleanup(true)
			  img:setPosition(ccp(posX,posY))
			  parent:addChild(img)
			  self.cardAvatar = img
		  end
	  end

	  local function drawNameWithNameStr(strName)
		  self.cardName:setString(strName)
	  end

		local configId =  self._configId
		local curRank = AllConfig.equipment[configId].equip_rank+1
		--local unitType =  AllConfig.equipment[configId].equip_type 
		local unitPic = AllConfig.equipment[configId].equip_pic
		local strCardName = AllConfig.equipment[configId].name
		local quality =  AllConfig.equipment[configId].quality 
		MessageBox.Help.changeSpriteImage(self.quality,Equipment.QualityNameImg(quality,true))

		drawStarAndFrame(curRank,maxRank)
		drawNameWithNameStr(strCardName)
		drawAvatar(unitPic)
   end
end


function EquipmentHeadLargeView:setStar(starIndex)
	if starIndex >= 1 and starIndex <= 5 then 
		local array = {self.star1, self.star2, self.star3, self.star4, self.star5}
		array[starIndex]:setVisible(true)
		--array[starIndex]:setScale(1.5)
		local act = CCScaleBy:create(0.3, 1.5)
		local act2 = act:reverse()
		local seq = CCSequence:createWithTwoActions(act, act2)
		array[starIndex]:runAction(seq)
	end
end

function EquipmentHeadLargeView:getStarObj(starIndex)
	if starIndex < 1 or starIndex > 5 then 
		return nil
	end
	return self._starArray[starIndex]
end

function EquipmentHeadLargeView:updataCardViewWithConfigId(configId)

	local curRank = AllConfig.unit[configId].card_rank+1    -- 代表 当前星级
	local maxRank = AllConfig.unit[configId].card_max_rank+1

	local leadCost = AllConfig.unit[configId].lead_cost
	for i=1,5 do 	-- first set 5 stars is invisible
		self["starBg"..i]:setVisible(false)
		self["star"..i]:setVisible(false)
	end
	for i=1,maxRank do	-- display stars by grade
		self["starBg"..i]:setVisible(true)
	end
	for i=1,curRank do	-- display stars by grade
		self["star"..i]:setVisible(true)
	end

	local str = string.format("%d",leadCost)
	--  print(str)
	self.cardLv:setString(str)
end

return EquipmentHeadLargeView