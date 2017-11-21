CardHeadLargeView = class("CardHeadLargeView", function()
  return display.newNode()
end)

local cardFrameTag = 615
local cardJobPlacetag = 241
function CardHeadLargeView:ctor(card)

	local frontArray = {

		"cardAvatarBg" ,
		"cardAvatar",
		"cardBottomBg",
		"jobBg",
		"qunGuo",
		"shuGuo",
		"wuGuo",
		"weiGuo",
	}

	self._jobType =
	{
		"infantry",  --步兵
		"cavalry",   -- 骑兵
		"archer",    -- 工兵
		"fighter",   -- 武术家
		"gongqi",    -- 弓骑兵
		"adviser",   --策士
		"taoist",       -- 道士
		"fengshuishi",  --风水师
		"dancer",       -- 舞娘
		"demolisher",  -- 投石车
	}

	local frontPkg = ccbRegisterPkg.new(self)
	local numSprites = table.getn(frontArray)
	for i = numSprites,1,-1 do
		frontPkg:addProperty(frontArray[i],"CCSprite")
	end
	local jobTypeSprites = table.getn(self._jobType)
	for i = jobTypeSprites,1,-1 do
		frontPkg:addProperty(self._jobType[i],"CCSprite")
	end
	frontPkg:addProperty("cardNameNode", "CCNode")
	frontPkg:addProperty("defaultName", "CCLabelTTF")
	frontPkg:addProperty("cardName", "CCLabelBMFont")
	frontPkg:addProperty("label_subRank", "CCLabelBMFont")
	--pkg:addProperty("cardLv", "CCLabelBMFont")



	local layer,owner = ccbHelper.load("OrbitCard.ccbi","OrbitCardCCB","CCLayer",frontPkg)
	layer:ignoreAnchorPointForPosition(false)
	self:addChild(layer)
	self._cardLayer = layer
	self:setContentSize(layer:getContentSize())

	self._job ={
		self.infantry,  --步兵
		self.cavalry,   -- 骑兵
		self.archer,    -- 工兵
		self.fighter,   -- 武术家
		self.gongqi,    -- 弓骑兵
		self.adviser,   --策士
		self.taoist,       -- 道士
		self.fengshuishi,  --风水师
		self.dancer,       -- 舞娘
		self.demolisher,  -- 投石车
	}
--	local dstar1 = self.dstar1
	--print("dstar1:"..type(dstar1))
	if card ~= nil then
		self._card = card
		self:setCard(card:getConfigId())
	end
end

function CardHeadLargeView:getStarPosition(starIndex)
	local array = {self.starBg1, self.starBg2, self.starBg3, self.starBg4, self.starBg5}

	local pos = ccp(0,0)
	if starIndex >= 1 and starIndex <= 5 then 
		--pos = self:convertToWorldSpace(ccp(array[starIndex]:getPosition()))
		pos = array[starIndex]:getParent():convertToWorldSpace(ccp(array[starIndex]:getPosition()))
	end
	return pos
end

function CardHeadLargeView:setScale(scale)
	self._cardLayer:setScale(scale)
end

function CardHeadLargeView:getScale()
	return self._cardLayer:getScale()
end

function CardHeadLargeView:setWidth(width)
	self._cardLayer:setContentSize(ccp(width,self._cardLayer:getContentSize().height))
end

function CardHeadLargeView:getWidth()
	return  self.cardAvatarBg:getContentSize().width
end

function CardHeadLargeView:setHeight(height)
	self._cardLayer:setContentSize(ccp(self._cardLayer:getContentSize().width,height))
end

function CardHeadLargeView:getHeight()
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


function CardHeadLargeView:setCard(configId)
  self._configId = configId
  if configId ~= 0 then

	  local BgIconId = {3021006,3021007,3021008,3021009,3021010 }   -- 卡牌正面背景+框
	  local bottomBg = {3021016,3021017,3021018,3021019,3021020} -- 卡框的下边条
	  local startBgIconId = {3022001,3022002,3022003,3022004,3022005 }

	  local function drawStarAndFrame(curRank,maxrank)
--		  for i=1,5 do 	-- first set 5 stars is invisible
--			  self["starBg"..i]:setVisible(false)
--			  self["star"..i]:setVisible(false)
--		  end
--		  for i=1,maxrank do	-- display stars by grade
--			  local parent = self["starBg"..i]:getParent()
--			  local startBg = _res(startBgIconId[curRank])
--			  if parent ~= nil and startBg ~= nil then
--				  local posX,posY =  self["starBg"..i]:getPosition()
--				  parent:removeAllChildrenWithCleanup(true)
--				  startBg:setPosition(ccp(posX,posY))
--				  parent:addChild(startBg)
--			  end
--		  end
--		  for i=1,curRank do	-- display stars by grade
--			  self["star"..i]:setVisible(true)
--		  end
		  drawStar(self,curRank,maxrank)

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

	  local function drawCountry(countryId)
		  if countryId == 1  then -- wei
			  self.weiGuo:setVisible(true)
			  self.shuGuo:setVisible(false)
			  self.wuGuo:setVisible(false)
			  self.qunGuo:setVisible(false)
		  elseif countryId == 2 then --shu
			  self.weiGuo:setVisible(false)
			  self.shuGuo:setVisible(true)
			  self.wuGuo:setVisible(false)
			  self.qunGuo:setVisible(false)
		  elseif countryId == 3 then --wu
			  self.weiGuo:setVisible(false)
			  self.shuGuo:setVisible(false)
			  self.wuGuo:setVisible(true)
			  self.qunGuo:setVisible(false)
		  else     -- qun
			  self.weiGuo:setVisible(false)
			  self.shuGuo:setVisible(false)
			  self.wuGuo:setVisible(false)
			  self.qunGuo:setVisible(true)
		  end
	  end

	  local function drawJob(curRank,jobTypeId)

		  local jobBgIconId = {3021031,3021032,3021033,3021034,3021035 }
		  local jobBgSprite = _res(jobBgIconId[curRank])
		  local parent = self.jobBg:getParent()

		  if parent ~= nil and jobBgSprite ~= nil  then
			  local posX,posY = self.jobBg:getPosition()
			  self.jobBg:removeFromParentAndCleanup(true)
			  jobBgSprite:setPosition(ccp(posX,posY))
			  parent:addChild(jobBgSprite)
			  self.jobBg = jobBgSprite
		  end

		  local jobTypeCountSprites = table.getn(self._jobType)
		  for i = jobTypeCountSprites,1,-1 do
			  local key = self._jobType[i]
			  if i == jobTypeId then
				  self._job[i]:setVisible(true)
			  else
				  self._job[i]:setVisible(false)
			  end
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
--		  local pNameLabel
--		  if self.defaultName ~= nil and self.cardNameNode~= nil then
--			  local posX,posY = self.defaultName:getPosition()
--			  local pNameLabel = ui.newTTFLabelWithOutline( {
--				  text = strName,
--				  font ="fzjzjt.ttf",
--				  size = 26,
--				  x = 0,--posX-4,
--				  y = 10, --posY-6,
--				  color = ccc3(255, 255, 0), -- 原字体纯黄色
--				  align = ui.TEXT_ALIGN_GIGHT,
--			--	  valign = ui.TEXT_VALIGN_TOP,
--				  dimensions = CCSize(0, 0),
--				  outlineColor =ccc3(0,0,0) } --黑色描边
--			  )
--			  self.defaultName:setString(" ")
--			  pNameLabel:setPositionX(-pNameLabel:getContentSize().width)
--			  self.defaultName:addChild(pNameLabel,2)
	 -- end
	  self.cardName:setString(strName)
	  end

	  local configId =  self._configId
	  local curRank = AllConfig.unit[configId].card_rank+1    -- 代表 当前星级
	  local maxRank = AllConfig.unit[configId].card_max_rank+1	  
	  local unitType =  AllConfig.unit[configId].unit_type
	  local unitPic = AllConfig.unit[configId].unit_pic
	  local strCardName = AllConfig.unit[configId].unit_cardname
	  local country = AllConfig.unit[configId].country1

	  drawStarAndFrame(curRank,maxRank)
	  drawNameWithNameStr(strCardName)
	  drawCountry(country)               --@@@@@ 要修改
	  drawJob(curRank,unitType)
	  drawAvatar(unitPic)
	  
	  self:setSubRank(configId)
   end
end

function CardHeadLargeView:getCard()
	return self._card
end

function CardHeadLargeView:setStar(starIndex)
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

function CardHeadLargeView:setSubRank(configId)
	local curRank = AllConfig.unit[configId].card_rank+1 
	local subRank = AllConfig.unit[configId].card_improve

	echo("=== curRank,subRank", curRank, subRank)
	if curRank >= 3 and subRank > 0 then 
		local fntFileName
		if curRank < 4 then 
			fntFileName = "img/client/widget/words/change_number/change_number_blue.fnt"
		else 
			fntFileName = "img/client/widget/words/change_number/change_number_purple.fnt"
		end 
		self.label_subRank:setFntFile(fntFileName)
		self.label_subRank:setString(string.format("+%d", subRank))
	else 
		self.label_subRank:setString("")
	end 
end 

function CardHeadLargeView:getStarObj(starIndex)
	if starIndex < 1 or starIndex > 5 then 
		return nil
	end
	--	local array = {self.star1, self.star2, self.star3, self.star4, self.star5 }
	return self._starArray[starIndex]
	--return array[starIndex]
end

function CardHeadLargeView:getSubRankLabel()
	return self.label_subRank
end

function CardHeadLargeView:updataCardViewWithConfigId(configId)

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

	-- local frameBgIconId = {3021006,3021007,3021008,3021009,3021010 }
	-- local jobIconId = {3022001,3022002,3022003,3022004,3022005 }
	-- local kuangIcon = _res(frameBgIconId[curRank])
	-- local spriteConsize = self.cardAvatar:getContentSize()
	-- local posX,posY = self.cardFrame:getPosition()
	-- local parent = self.cardFrame:getParent()

	-- if parent ~= nil and kuangIcon ~= nil and  self.cardFrame~= nil then
	-- 	kuangIcon:setPosition(ccp(posX,posY))
	-- 	parent:removeChildByTag(cardFrameTag)
	-- 	parent:addChild(kuangIcon,1,cardFrameTag)
	-- end

	-- -- job place  jobIconId
	-- local jobIcon = _res(jobIconId[curRank])
	-- local posX,posY = self.jobPlace:getPosition()
	-- local parent = self.jobPlace:getParent()
	-- if parent ~= nil and jobIcon ~= nil and  self.jobPlace~= nil then
	-- 	self.jobPlace:removeFromParentAndCleanup(true)
	-- 	--parent:removeAllChildrenWithCleanup(true)
	-- 	jobIcon:setPosition(ccp(posX,posY))
	-- 	parent:removeChildByTag(cardJobPlacetag)
	-- 	parent:addChild(jobIcon,1,cardJobPlacetag)
	-- end

	local str = string.format("%d",leadCost)
	--  print(str)
	self.cardLv:setString(str)
end

return CardHeadLargeView