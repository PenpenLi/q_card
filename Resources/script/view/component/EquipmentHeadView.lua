
EquipmentHeadView =  class("EquipmentHeadView",function()  return display.newLayer() end)

local function init(self)

	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("cardAvatarBg","CCSprite")
	pkg:addProperty("avatarNode","CCNode")
	pkg:addProperty("cardAvatar","CCSprite")
	pkg:addProperty("jobBg","CCSprite")
	pkg:addProperty("cardName","CCLabelTTF")
	pkg:addProperty("maskLayer","CCLayer")
	pkg:addProperty("jobNode","CCNode")


	local layer,owner = ccbHelper.load("EquipmentHeadView.ccbi","EquipmentHeadViewCCB","CCLayer",pkg)

	self:addChild(layer,2,2)

	self.width,self.height = self.cardAvatarBg:getContentSize()

end

function EquipmentHeadView:setCard(args)

	self.args = args or {}
	self._configId = args.configId or 0
	self._card = args.card or 0

	if self._configId == 0 and self._card ~= 0 then
		self._configId = self._card:getConfigId()
	end

	if self._card == 0 and self._configId ~= 0 then
		self._card = Equipment.new()
		self._card:setConfigId(self._configId)
	end

	local BgIconId = {3021036,3021037,3021038,3021039,3021040 }   -- middle 卡牌背景+框
	local function drawAvatarBg(curRank)
		-- avatar Bg
		local bgIcon = _res(BgIconId[curRank])

		if(bgIcon) then
			MessageBox.Help.changeSpriteObj(self.cardAvatarBg,bgIcon)
		end
	end

	local function drawAvatar(unitPic,curRank)

		local img = _res(unitPic)
		img:setScale(0.33)

		local posX,posY = self.cardAvatar:getPosition()
		if img~=nil  then
			self.cardAvatar:removeAllChildrenWithCleanup(true)
			MessageBox.Help.changeSpriteObj(self.cardAvatar,img)
			local anim = nil
			if curRank == 5 then
				anim = _res(5020176) -- 5020173  5020156
			elseif curRank == 4 then  -- 5020174
				anim = _res(5020174)
			end
			if anim ~= nil then
				local spriteConsize = img:getContentSize()
				anim:setPosition(ccp(spriteConsize.width/2,spriteConsize.height/2-60.0))
				anim:setScale(100/35)
				self.cardAvatar:addChild(anim,-1)
				anim:getAnimation():setIsLoop(1)
				anim:getAnimation():play("default")
			end
		end
	end

	local function drawNameWithNameStr(strName)
		self.cardName:setString(strName)
	end


	local configId =  self._configId
	local curRank = AllConfig.equipment[configId].equip_rank+1    -- 代表 当前星级
	--local unitType =  AllConfig.equipment[configId].equip_type --1-武器 2-防具 3-饰品
	local unitPic = AllConfig.equipment[configId].equip_pic --unit_pic
	local strCardName = AllConfig.equipment[configId].name --unit_cardname

	drawAvatarBg(curRank)
	drawAvatar(unitPic,curRank)
	drawNameWithNameStr(strCardName)
end

function EquipmentHeadView:ctor()

	init(self)
end

function EquipmentHeadView:getContentSize()
	return self.width,self.height
end

return EquipmentHeadView