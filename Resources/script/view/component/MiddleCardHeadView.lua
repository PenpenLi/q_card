
MiddleCardHeadView =  class("MiddleCardHeadView",function()  return display.newLayer() end)

local function init(self)

	self._jobType =
	{
		"infantry",  --步兵
		"cavalry",   -- 骑兵
		"archer",    -- 弓兵
		"fighter",   -- 武术家
		"gongqi",    -- 弓骑兵
		"adviser",   --策士
		"taoist",       -- 道士
		"fengshuishi",  --风水师
		"dancer",       -- 舞娘
		"demolisher",  -- 投石车
	}

	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("cardAvatarBg","CCSprite")
	pkg:addProperty("avatarNode","CCNode")
	pkg:addProperty("cardAvatar","CCSprite")
	pkg:addProperty("jobBg","CCSprite")
	pkg:addProperty("cardName","CCLabelTTF")
	pkg:addProperty("maskLayer","CCLayer")
	pkg:addProperty("jobNode","CCNode")

	local jobTypeSprites = table.getn(self._jobType)
	for i = jobTypeSprites,1,-1 do
		pkg:addProperty(self._jobType[i],"CCSprite")
	end

	local layer,owner = ccbHelper.load("MiddleCardHeadView.ccbi","MiddleCardHeadViewCCB","CCLayer",pkg)

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
	self:addChild(layer,2,2)

	self.width,self.height = self.cardAvatarBg:getContentSize()

	-- self:setCard(self.args)
end



function MiddleCardHeadView:drawAvatarBg(curRank)
	local BgIconId = {3021036,3021037,3021038,3021039,3021040 }   -- middle 卡牌背景+框
	-- avatar Bg
	local bgIcon = _res(BgIconId[curRank])
	local spriteConsize = self.cardAvatar:getContentSize()
	local posX,posY = self.cardAvatarBg:getPosition()
	local parent = self.cardAvatarBg:getParent()
	if parent ~= nil and bgIcon ~= nil and  self.cardAvatarBg~= nil then
		self.cardAvatarBg:removeFromParentAndCleanup(true)
		bgIcon:setPosition(ccp(posX,posY))
		parent:addChild(bgIcon)
		self.cardAvatarBg = bgIcon
	end
end

function MiddleCardHeadView:setCard(args)

	self.args = args or {}
	self._configId = args.configId or 0
	self._card = args.card or 0

	if self._configId == 0 and self._card ~= 0 then
		self._configId = self._card:getConfigId()
	end

	if self._card == 0 and self._configId ~= 0 then
		self._card = Card.new()
		self._card:initAttrById(self._configId)
	end

	local function drawAvatar(unitPic,curRank)

		local img = _res(unitPic)
		img:setScale(0.33)

		local posX,posY = self.cardAvatar:getPosition()
		if img~=nil  then
			local spriteConsize = img:getContentSize()
			self.cardAvatar:removeFromParentAndCleanup(true)
			img:setPosition(ccp(posX,posY))

			local anim = nil
			if curRank == 5 then
				anim = _res(5020176) -- 5020173  5020156
			elseif curRank == 4 then  -- 5020174
				anim = _res(5020174)
			end
			if anim ~= nil then
				anim:setPosition(ccp(spriteConsize.width/2,spriteConsize.height/2-60.0))
				anim:setScale(100/35)
				img:addChild(anim,-1)
				anim:getAnimation():setIsLoop(1)
				anim:getAnimation():play("default")
			end

			local avatarMaskLayer = DSMask:createMask( self.maskLayer:getContentSize(),img)
			avatarMaskLayer:setPosition(self.maskLayer:getPosition())
			self.avatarNode:addChild(avatarMaskLayer,2)
			self.cardAvatar = img
		end
	end

	local function drawNameWithNameStr(strName)
		self.cardName:setString(strName)
	end

	local function drawJob(curRank,jobTypeId)

		local jobBgIconId = {3021046,3021047,3021048,3021049,3021050 }
		local jobBgSprite = _res(jobBgIconId[curRank])
		local parent = self.jobBg:getParent()

		if parent ~= nil and jobBgSprite ~= nil  then
			local posX,posY = self.jobBg:getPosition()
			self.jobBg:removeFromParentAndCleanup(true)
			jobBgSprite:setPosition(ccp(posX,posY))
			parent:addChild(jobBgSprite)
			self.jobBg = jobBgSprite
		end

		print("jobTypeId",jobTypeId)
		local jobTypeCountSprites = table.getn(self._jobType)
		for i = jobTypeCountSprites,1,-1 do
			local key = self._jobType[i]
			if i == jobTypeId then
				print(self._job[i])
				self._job[i]:setVisible(true)
			else
				self._job[i]:setVisible(false)
			end
		end
	end

	local configId =  self._configId
	local curRank = AllConfig.unit[configId].card_rank+1    -- 代表 当前星级
	local unitType =  AllConfig.unit[configId].unit_type
	local unitPic = AllConfig.unit[configId].unit_pic
	local strCardName = AllConfig.unit[configId].unit_name

	self:drawAvatarBg(curRank)
	drawAvatar(unitPic,curRank)
	drawNameWithNameStr(strCardName)
	drawJob(curRank,unitType)
end

function MiddleCardHeadView:ctor()

	init(self)
end

function MiddleCardHeadView:getContentSize()
	return self.width,self.height
end

function MiddleCardHeadView:setNameVisible(isVisible)
	self.cardName:setVisible(isVisible)
end 	

return MiddleCardHeadView