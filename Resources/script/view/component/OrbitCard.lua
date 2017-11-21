

OrbitCard = class("OrbitCard",function()  return display.newLayer() end)

local eCardState = enum({"eFront","eBack"})

local frontLayer = nil
local frontOwner = nil
local backLayer = nil
local backOwner = nil
local backLayerInfo = nil
local backLayerOwner = nil

local function showFrontCardLastHalfRight(self)
	local  flip =  CCOrbitCamera:create(0.2, 0.1, 0.0, -270.0, -90.0, 0, 0)
	local array = CCArray:create()
	array:addObject(flip)
	self:runAction( CCSequence:create(array))
end

local function showBackCardLastHalfRight(self)
	local  flip =  CCOrbitCamera:create(0.2, 0.1, 0.0, -270.0, -90.0, 0, 0)
	local array = CCArray:create()
	array:addObject(flip)
	self:runAction( CCSequence:create(array))
end

local function showFrontCardLastHalf(self)
	local  flip =  CCOrbitCamera:create(0.2, 0.1, 0.0, 270.0, 90.0, 0, 0)
	local array = CCArray:create()
	array:addObject(flip)
	self:runAction( CCSequence:create(array))
end

local function showBackCardLastHalf(self)
	local  flip =  CCOrbitCamera:create(0.2, 0.1, 0.0, 270, 90.0, 0, 0)
	local array = CCArray:create()
	array:addObject(flip)
	self:runAction( CCSequence:create(array))
end

local function setFrontCardShowRight(self)
	showFrontCardLastHalfRight(self);
	frontLayer:setVisible(true);
	backLayer:setVisible(false);
end

local function setBackCardShowRight(self)
	showBackCardLastHalfRight(self)
	frontLayer:setVisible(false)
	backLayer:setVisible(true)

end

local function setFrontCardShow(self)
	showFrontCardLastHalf(self)
	frontLayer:setVisible(true)
	backLayer:setVisible(false)
end

local function setBackCardShow(self)
	showBackCardLastHalf(self);
	frontLayer:setVisible(false);
	backLayer:setVisible(true);
end

local function showFrontCardFirstHalfRight(self)
	self._cardState = eCardState.eFront
	local flip = CCOrbitCamera:create(0.2, 0.1, 0.0, 0, -90.0, 0, 0)
	local array = CCArray:create()
	array:addObject(flip)
	array:addObject(CCCallFunc:create(handler(self,setFrontCardShowRight)))
	self:runAction( CCSequence:create(array))
end

local function showBackCardFirstHalfRight(self)
	self._cardState = eCardState.eBack
	local flip = CCOrbitCamera:create(0.2, 0.1, 0.0, 0, -90.0, 0, 0)
	local array = CCArray:create()
	array:addObject(flip)
	array:addObject(CCCallFunc:create(handler(self,setBackCardShowRight)))
	self:runAction( CCSequence:create(array))
end

local function showFrontCardFirstHalf(self)
	self._cardState = eCardState.eFront
	local flip = CCOrbitCamera:create(0.2, 0.1, 0.0, 0, 90.0, 0, 0)
	local array = CCArray:create()
	array:addObject(flip)
	array:addObject(CCCallFunc:create(handler(self,setFrontCardShow)))
	self:runAction( CCSequence:create(array))
end

local function showBackCardFirstHalf(self)
	self._cardState = eCardState.eBack
	local  flip =  CCOrbitCamera:create(0.2, 0.1, 0.0, 0, 90.0, 0, 0)
	local array = CCArray:create()
	array:addObject(flip)
	array:addObject(CCCallFunc:create(handler(self,setBackCardShow)))
	self:runAction( CCSequence:create(array) )
end

local function getLeftRange(object)
	local x = object:getPositionX()
	local y = object:getPositionY()

	local parent = object:getParent()
	if parent then
		x = x + parent:getPositionX()
		y = y + parent:getPositionY()
		while parent:getParent() do
			parent = parent:getParent()
			x = x + parent:getPositionX()
			y = y + parent:getPositionY()
		end
	end

	local w = object:getContentSize().width * object:getParent():getScaleX()
	local h = object:getContentSize().height * object:getParent():getScaleY() 

	return CCRectMake(x-w/2.0, y-h/2.0, w/2, h)
end

local function getRightRange(object)
	local x = object:getPositionX()
	local y = object:getPositionY()

	local parent = object:getParent()
	if parent then
		x = x + parent:getPositionX()
		y = y + parent:getPositionY()
		while parent:getParent() do
			parent = parent:getParent()
			x = x + parent:getPositionX()
			y = y + parent:getPositionY()
		end
	end

	local w = object:getContentSize().width * object:getParent():getScaleX()
	local h = object:getContentSize().height * object:getParent():getScaleY() 
	
	return CCRectMake(x, y-h/2, w/2, h)
end

local function containsTouchLocationLeft(x,y)
	local isTouch =  getLeftRange(frontLayer):containsPoint(ccp(x,y))
	print("left is ",isTouch)
	return isTouch
end

local function containsTouchLocationRight(x,y)
	local isTouch = getRightRange(frontLayer):containsPoint(ccp(x,y))
	print("right is ",isTouch)
	return isTouch
end

local touchBeginX = 0
local touchBeginY = 0
local function ccTouchBegan(self,x,y)
	touchBeginX = x
	touchBeginY = y
	if  containsTouchLocationLeft(x,y) then
		if self._cardState == eCardState.eFront then
			return true
		elseif self._cardState == eCardState.eBack then
			return true
		end
	elseif containsTouchLocationRight(x,y) then
		if self._cardState == eCardState.eFront then
			return true
		elseif self._cardState == eCardState.eBack then
			return true
		end
	end

	local curScene = GameData:Instance():getCurrentScene()
	local popupNode = curScene:getChildByTag(POPUP_NODE_ZORDER)
	if popupNode ~= nil then
		popupNode:removeAllChildrenWithCleanup(true)
	 _executeNewBird()
	end

	return false
end

local function ccTouchEnded(self,x, y)

	local length = (x-touchBeginX)*(x-touchBeginX)+(y-touchBeginY)*(y- touchBeginY)
	if length >= 0 then
		if  containsTouchLocationLeft(x,y) then
			if self._cardState == eCardState.eFront then
				showBackCardFirstHalf(self)
			elseif self._cardState == eCardState.eBack then
				showFrontCardFirstHalf(self)
			end
		elseif containsTouchLocationRight(x,y) then
			if self._cardState == eCardState.eFront then
				showBackCardFirstHalfRight(self)
			elseif self._cardState == eCardState.eBack then
				showFrontCardFirstHalfRight(self)
			end
		end
		return
	end
end

local function  ccTouchMoved(self,x,y)
	--print("ccTouchMoved x =,y=",x,y)
end

local function onTouch(self,eventType, x, y)
	if eventType == "began" then
		return ccTouchBegan(self,x,y)
	elseif eventType == "moved" then
		return ccTouchMoved(self,x,y)
	elseif eventType == "ended" then
		return ccTouchEnded(self,x, y)
	end
	return false
end


local function drawStar(self,curRank,maxRank)

	local startBgIconId = {3022001,3022002,3022003,3022004,3022005 }

	local starBgLayer = CCLayerColor:create(ccc4(0,0,0,0))  -- 30,30  +10
	starBgLayer:ignoreAnchorPointForPosition(false)
	local forntBgSize = frontLayer:getContentSize()

	starBgLayer:setPosition(ccp(forntBgSize.width/2.0,forntBgSize.height-40))
	frontLayer:addChild(starBgLayer,100)

	for i = 1, maxRank, 1 do

		local starId = 0
		if i<= curRank then
			starId = 3022006 --亮星星
		else
				starId = startBgIconId[curRank]
		end
		local startBg = _res(starId)
		startBg:setAnchorPoint(ccp(0,0.5))
		startBg:setPosition(ccp((i-1)*40,startBg:getContentSize().height/2.0))
		starBgLayer:addChild(startBg)
	end
	starBgLayer:setContentSize(CCSizeMake(maxRank*30+(maxRank-1)*10,30))
end

local function updataFrontAndBackCardInfo(self)


	local BgIconId = {3021006,3021007,3021008,3021009,3021010 }   -- 卡牌正面背景+框
	local bottomBg = {3021016,3021017,3021018,3021019,3021020} -- 卡框的下边条
	local startBgIconId = {3022001,3022002,3022003,3022004,3022005}

	local function drawStarAndFrame(curRank,maxrank)

		drawStar(self,curRank,maxrank)

		 -- avatar Bg
		local BgIconId = _res(BgIconId[curRank])
		local spriteConsize = self.cardAvatar:getContentSize()
		local posX,posY = self.cardAvatarBg:getPosition()
--		print(posX,posY)
		local parent = self.cardAvatarBg:getParent()
		if parent ~= nil and BgIconId ~= nil and  self.cardAvatarBg~= nil then
			self.cardAvatarBg:removeFromParentAndCleanup(true)
			BgIconId:setPosition(ccp(posX,posY))
			parent:addChild(BgIconId)
		end

		-- bottomBg
		local bottomBgIcon = _res(bottomBg[curRank])
		local parent = self.cardBottomBg:getParent()

		if parent ~= nil and bottomBgIcon ~= nil and  self.cardBottomBg~= nil then
			local posX,posY = self.cardBottomBg:getPosition()
			self.cardBottomBg:removeFromParentAndCleanup(true)
			bottomBgIcon:setPosition(ccp(posX,posY))
			parent:addChild(bottomBgIcon)
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
		elseif countryId == 4 then    -- qun
			self.weiGuo:setVisible(false)
			self.shuGuo:setVisible(false)
			self.wuGuo:setVisible(false)
			self.qunGuo:setVisible(true)
		else
			self.weiGuo:setVisible(false)
			self.shuGuo:setVisible(false)
			self.wuGuo:setVisible(false)
			self.qunGuo:setVisible(false)

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

	local function drawAvatar(unitPic,curRank)
		local img = _res(unitPic)
		local spriteConsize = self.cardAvatar:getContentSize()
		local posX,posY = self.cardAvatar:getPosition()
		local parent = self.cardAvatar:getParent()
		if parent~=nil and img~=nil and  self.cardAvatar~= nil then
			self.cardAvatar:removeFromParentAndCleanup(true)
			img:setPosition(ccp(posX,posY))

			local anim = nil
			if curRank == 5 then
				anim = _res(5020175)
			elseif curRank == 4 then
				anim = _res(5020173)
			end

			if anim ~= nil then
				anim:setPosition(ccp(spriteConsize.width/2,spriteConsize.height/2-53.0))
				img:addChild(anim,-1)
				anim:getAnimation():setIsLoop(1)
				anim:getAnimation():play("default")
				self._anim = anim
			end

			parent:addChild(img)
		end
	end

	local function drawNameWithNameStr(strName)
--		local pNameLabel
--		if self.defaultName ~= nil and self.cardNameNode~= nil then
--			local posX,posY = self.defaultName:getPosition()
--			local pNameLabel = ui.newTTFLabelWithOutline( {
--				text = strName,
--				font ="fzjzjt.ttf",
--				size = 26,
--				x =0,-- posX-4,
--			    y = 10,-- posY-6,
--				color = ccc3(255, 255, 0), -- 原字体纯黄色
--				align = ui.TEXT_ALIGN_GIGHT,
----				valign = ui.TEXT_VALIGN_TOP,
--				dimensions = CCSize(0, 0),
--				outlineColor =ccc3(0,0,0) } --黑色描边
--			)
--			--print(posX,posY)
--			self.defaultName:setString(" ")
--			pNameLabel:setPosition(ccp(-pNameLabel:getContentSize().width,18))
--			self.defaultName:addChild(pNameLabel,2)
--		end
		self.cardName:setString(strName)
	end

	local configId =  self._configId
	print("configId =====",configId)
	local curRank = AllConfig.unit[configId].card_rank+1    -- 代表 当前星级
	local maxRank = AllConfig.unit[configId].card_max_rank+1
	local subRank = AllConfig.unit[configId].card_improve
	local unitType =  AllConfig.unit[configId].unit_type
	local unitPic = AllConfig.unit[configId].unit_pic
	local strCardName = AllConfig.unit[configId].unit_cardname
--	local cradNameIconId = AllConfig.unit[configId].unit_name_pic
	local country = AllConfig.unit[configId].country1
	print("configId",configId)
	print("country",country)
	print("unitPic",unitPic)
	drawStarAndFrame(curRank,maxRank)
	drawCountry(country)               --@@@@@ 要修改

	drawNameWithNameStr(strCardName)
	drawJob(curRank,unitType)
	drawAvatar(unitPic,curRank)

	print("=== card rank, subRank=", curRank, subRank)
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

local function updataBackAndBackCardInfo(self)

	self.tipBtnShowStr = {}
	local function utf8_length(str)
		local len = 0
		local pos = 1
		local length = string.len(str)
		while true do
			local char = string.sub(str , pos , pos)
			local b = string.byte(char)
			if b >= 128 then
				pos = pos + 3
			else
				pos = pos + 1
			end
			len = len + 1
			-- print(word)
			-- print("pos: " .. pos)
			if pos > length then
				break
			end
		end

		return len
	end

	local function utf8_sub(str , s , e)
		local t = {}
		local length = string.len(str)
		local pos = 1
		local offset = 1

		while true do
			local word = nil
			local char = string.sub(str , pos , pos)
			local b = string.byte(char)

			if b >= 128 then
				if offset >= s then
					word = string.sub(str , pos , pos + 2)
					table.insert(t , word)
				end

				pos = pos + 3
			else
				if offset >= s then
					word = char
					table.insert(t , word)
				end

				pos = pos + 1
			end
			offset = offset + 1
			-- print(word)
			-- print("pos: " .. pos)
			if offset > e or pos > length then
				break
			end
		end

		return table.concat(t)
	end
--	print("congifId",self._configId)
	local configId =  self._configId
	local  framebackBgId ={3022016,3022017,3022018,	3022019,3022020}    --背景框   3021011

	local curRank = AllConfig.unit[configId].card_rank+1    -- 代表 当前星级
	local maxRank = AllConfig.unit[configId].card_max_rank+1
	local unitType =  AllConfig.unit[configId].unit_type
	local unitPic = AllConfig.unit[configId].unit_pic

	-- 显示背面卡牌的背景框
	local img = _res(framebackBgId[curRank])
	local posX,posY = self.frameBackBg:getPosition()
	local parent = self.frameBackBg:getParent()
	if parent~=nil and img~=nil then
		self.frameBackBg:removeFromParentAndCleanup(true)
		img:setPosition(ccp(posX,posY))
		--img:setScale(1.15)
		parent:addChild(img)
	end


	-- 命
	local hpStr = string.format("%d", self._card:getHp())
	self.mingNum:setString(hpStr)

	-- 攻
	local attackStr = string.format("%d", self._card:getAttack())
	self.gongNum:setString(attackStr)

	--武
	local wushuStr = string.format("%d",self._card:getStrength())
	self.wuNum:setString(wushuStr)
	--智
	local zhiStr = string.format("%d",self._card:getIntelligence())
	self.zhiNum:setString(zhiStr)

	--统
	local tongStr = string.format("%d",self._card:getDominance())
	self.tongNum:setString(tongStr)

	-- 获得途径
	self.cardRewardLabel:setString("")
	local rewardStr = AllConfig.unit[configId].card_pathway
	self.cardRewardLabel:setString(rewardStr)


	-- 技能名称 & 技能描述 &	-- SkillLv

	local skillCurLv =  self._card:getSkill():getLevel() 
	local skillMaxLv = self._card:getSkill():getMaxLevel() 
	local skillLvstr = string.format("%d/%d",skillCurLv,skillMaxLv)
	self.skillLv:setString(skillLvstr)

	self.skillName:setString("")
	self.skillInfo:setString("")
	local skillBaseId =  AllConfig.unit[configId].skill 
	local skillName = AllConfig.cardskill[skillBaseId].skill_name
	self.skillName:setString(skillName)
	local skillInfoStr = GameData:Instance():formatSkillDesc(self._card)
	table.insert(self.tipBtnShowStr,skillInfoStr)

	local pDispInfo = RichLabel:create(skillInfoStr,"Courier-Bold",20,CCSizeMake(359, 121),false,false)

	if utf8_length(pDispInfo:getString()) < 68 then
		pDispInfo = RichLabel:create(skillInfoStr,"Courier-Bold",20,CCSizeMake(359, 121),false,false)
		self.tipBtn1:setVisible(false)
	else
		--函数 utf8_sub 有问题！！！！
		local liteSkillInfo = skillInfoStr --utf8_sub(skillInfoStr,1,68).." ..."
		pDispInfo = RichLabel:create(liteSkillInfo,"Courier-Bold",20,CCSizeMake(359, 121),false,false)
	end
	self.skillInfo:addChild(pDispInfo)

	-- 特长和组合技能初始化为空值
	self.specialitySkillName:setString("")
	self.specialitySkillInfo:setString("")
	self.comboSkillName:setString("")
	self.comboSkillInfo:setString("")
	--特长  & 特长描述
	local specialitySkillId =  AllConfig.unit[configId].talent -- 数组
	if specialitySkillId > 0 then
		local specialitySkillName =  AllConfig.unit[configId].equip_name -- 特长名字
		local specialitySkillInfoStr = AllConfig.cardskill[specialitySkillId].skill_description
		table.insert(self.tipBtnShowStr,specialitySkillInfoStr)
		self.specialitySkillName:setString(specialitySkillName)

		if utf8_length(specialitySkillInfoStr) < 32 then
			self.specialitySkillInfo:setString(specialitySkillInfoStr)
			self.tipBtn2:setVisible(false)
		else
			local liteSpecialitySkillInfo = utf8_sub(specialitySkillInfoStr,1,32).." ..."
			self.specialitySkillInfo:setString(liteSpecialitySkillInfo)
		end
	else
		table.insert(self.tipBtnShowStr," ")
		self.tipBtn2:setVisible(false)
	end
	-- 组合技 & 组合技描述
	local comboSkillId = AllConfig.unit[configId].combined_skill
	if comboSkillId > 0 then
		local comboSkillName =  AllConfig.cardskill[comboSkillId].skill_name
		local comboSkillInfoStr = AllConfig.cardskill[comboSkillId].skill_description
		local n = {"n1","n2","n3","n4","n5" }
		local name = {"name1","name2","name3","name4","name5"}
		n[1] = AllConfig.cardskill[comboSkillId].n1 or 0
		n[2] = AllConfig.cardskill[comboSkillId].n2 or 0
		n[3] = AllConfig.cardskill[comboSkillId].n3 or 0
		n[4] = AllConfig.cardskill[comboSkillId].n4 or 0
		n[5] = AllConfig.cardskill[comboSkillId].n5 or 0
		for i = 1, 5 do
			if n[i] >0 then
				local configId = n[i]*100+1
				name[i] = AllConfig.unit[configId].unit_name
			else
				name[i] = "a"
			end
			echo("name==", i, name[i])
		end

		comboSkillInfoStr = string.format(comboSkillInfoStr,name[1],name[2],name[3],name[4],name[5])
		table.insert(self.tipBtnShowStr,comboSkillInfoStr)
		self.comboSkillName:setString(comboSkillName)

    local pDispInfo = RichLabel:create(comboSkillInfoStr,"Courier-Bold",20,CCSizeMake(359, 121),false,false)
    comboSkillInfoStr = pDispInfo:getString()

		if utf8_length(comboSkillInfoStr) < 32 then
			self.comboSkillInfo:setString(comboSkillInfoStr)
			self.tipBtn3:setVisible(false)
		else
			local liteComboSkillInfo = utf8_sub(comboSkillInfoStr,1,32).." ..."
			self.comboSkillInfo:setString(liteComboSkillInfo)
		end
	else
		table.insert(self.tipBtnShowStr," ")
		self.tipBtn3:setVisible(false)
	end

	--卡牌描述
	self.CardInfo:setString("")
	local descriptionStr = AllConfig.unit[configId].description
	table.insert(self.tipBtnShowStr,descriptionStr)

	if utf8_length(descriptionStr) < 32 then
		self.CardInfo:setString(descriptionStr)
		self.tipBtn4:setVisible(false)
	else
		local liteDescription = utf8_sub(descriptionStr,1,32).." ..."
		self.CardInfo:setString(liteDescription)
	end
end

local function showBackInfo(self)

	local function scrollViewDidScroll(view)

	end

	local function scrollViewDidZoom(view)

	end

	local function tableCellTouched(table,cell)
		print("sel index",cell:getIdx())
	end

	local function cellSizeForTable(table,idx)
		if idx == 0 then
			return 250,275
		else
			return 190,275
		end

		 -- old size  (h,w) = 250 275
	end

	local function tableCellAtIndex(table, idx)

		local cc = table:getVerticalFillOrder()
		local cell = table:dequeueCell()
		if nil == cell then
			cell = CCTableViewCell:new()
		else
			cell:removeChild(cell:getChildByTag(123),true)
			cell:reset()
		end
		if idx == 0 then
			local infoCell =  backLayerInfo
			infoCell:setTag(123)
			cell:addChild(infoCell)
		else
			 local node = CCNode:create()
			 node:setTag(123)
			 cell:addChild(node)
		end

		return cell
	end

	local function numberOfCellsInTableView(val)
		return 2
	end

	self._infoTableView = CCTableView:create(CCSizeMake(self.listContain:getContentSize().width,self.listContain:getContentSize().height))
	self._infoTableView:setDirection(kCCScrollViewDirectionVertical)
	self.listContain:addChild(self._infoTableView)
	self._infoTableView:setPosition(ccp(0,0))
	self._infoTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	--registerScriptHandler functions must be before the reloadData function
	self._infoTableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	self._infoTableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
	self._infoTableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	self._infoTableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	self._infoTableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	self._infoTableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	self._infoTableView:reloadData()
	self._infoTableView:setTouchPriority(-131)

end

local function init(self)
	-- 正面
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
		"archer",    -- 弓兵
		"fighter",   -- 武术家
		"gongqi",    -- 弓骑兵
		"adviser",   --策士
		"taoist",       -- 道士
		"fengshuishi",  --风水师
		"dancer",       -- 舞娘
		"demolisher",  -- 投石车

	}

	local backArray = {
		"mingNum" ,
		"gongNum",
		"wuNum",
		"zhiNum",
		"tongNum",
	}
	--   反面的信息界面
	local backInfoArray = {     -----
		"CardInfo",
		"cardRewardLabel" ,
		"skillName",
		"skillInfo",
		"skillLv" ,
		"specialitySkillName",
		"specialitySkillInfo",
		"comboSkillName" ,
		"comboSkillInfo" ,
		"comboSkillFont",
		"specialitySkillFont",
		"skill_font",
		"lv_font",
		"cardRewardFont",
	}

	local backInfoShowBtn =
	{
		"tipBtn1",
		"tipBtn2",
		"tipBtn3",
		"tipBtn4"
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

	local backPkg = ccbRegisterPkg.new(self)
	local numLabels = table.getn(backArray)
	for i = numLabels,1,-1 do
		backPkg:addProperty(backArray[i],"CCLabelTTF")
	end
	backPkg:addProperty("frameBackBg","CCSprite")
	backPkg:addProperty("listContain","CCNode")
	--backPkg:addProperty("backCardInfoCCBFile","CCBFile")
  
  backPkg:addProperty("tipMenu","CCMenu")
	for i = 1, table.getn(backInfoShowBtn),1 do
		backPkg:addProperty(backInfoShowBtn[i],"CCMenuItemImage")
	end
	--local backInfoPkg = ccbRegisterPkg.new(self)
	local backInfoNumLabels = table.getn(backInfoArray)
	for i = backInfoNumLabels,1,-1 do
		backPkg:addProperty(backInfoArray[i],"CCLabelTTF")
	end
	backPkg:addFunc("tipBtn1CallBack",OrbitCard.tipBtn1CallBack)
	backPkg:addFunc("tipBtn2CallBack",OrbitCard.tipBtn2CallBack)
	backPkg:addFunc("tipBtn3CallBack",OrbitCard.tipBtn3CallBack)
	backPkg:addFunc("tipBtn4CallBack",OrbitCard.tipBtn4CallBack)

	frontLayer,frontOwner = ccbHelper.load("OrbitCard.ccbi","OrbitCardCCB","CCLayer",frontPkg)

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

	self.cardAvatarBgParent = self.cardAvatarBg:getParent()
	self.cardBottomBgParent = self.cardBottomBg:getParent()
	updataFrontAndBackCardInfo(self)
	--反面的信息
	--backLayerInfo ,backLayerOwner = ccbHelper.load("BackCardInfo.ccbi","BackCardInfoCCB","CCNode",backInfoPkg)

	--反面
	backLayer ,backOwner = ccbHelper.load("OrbitBackCard.ccbi","OrbitBackCardCCB","CCSprite",backPkg)
	self.frameBackBgParent =  self.frameBackBg:getParent()
	--backLayerInfo:ignoreAnchorPointForPosition(false)
	--backLayerInfo:setAnchorPoint(ccp(0.5,1))
	--backLayerInfo:setPosition(ccp(self.listContain:getContentSize().width/2+3,self.listContain:getContentSize().height-5))
	self.comboSkillFont:setString(_tr("comboSkillFont"))
	self.specialitySkillFont:setString(_tr("specialitySkillFont"))
	self.skill_font:setString(_tr("skill_font"))
	self.cardRewardFont:setString(_tr("cardRewardFont"))
	self.lv_font:setString(_tr("lv_font"))
--	for i = 1, 4, 1 do
--		self["tipBtn"..i]:setTouchPriority(-1132)
--	end
  self.tipMenu:setTouchPriority(-1132)

	updataBackAndBackCardInfo(self)
--	showBackInfo(self)

	--local bg = CCSprite:createWithSpriteFrameName("cardBg.png")
	local forntBg = self.cardAvatarBg
	local forntBgSize = forntBg:getContentSize()
	self:addChild(frontLayer,2,2)
	frontLayer:ignoreAnchorPointForPosition(false)

	--frontLayer:setPosition(ccp(display.cx,display.cy ))

	local backBg = self.frameBackBg
	local backBgSize = backBg:getContentSize()
	self:addChild(backLayer,2,2)
	backLayer:setPosition(ccp(backBgSize.width/2,backBgSize.height/2))
	backLayer:setVisible(false)
	frontLayer:setPosition(ccp(backBgSize.width/2 , backBgSize.height/2 ))

	self:setContentSize(backBgSize)
end

function OrbitCard:tipBtn1CallBack()
	local str = self.tipBtnShowStr[1]
	TipsInfo:showStringTip(str,CCSizeMake(200, 0), nil, self, ccp(280, 320), -1132,true,TipDir.LeftLeftDown)
end

function OrbitCard:tipBtn2CallBack()
	local str = self.tipBtnShowStr[2]
	TipsInfo:showStringTip(str,CCSizeMake(200, 0), nil, self, ccp(280, 215), -1132,true,TipDir.LeftLeftDown)
end

function OrbitCard:tipBtn3CallBack()
	local str = self.tipBtnShowStr[3]
	TipsInfo:showStringTip(str,CCSizeMake(200, 0), nil, self, ccp(280, 130), -1132,true,TipDir.LeftLeftDown)
end

function OrbitCard:tipBtn4CallBack()
	local str = self.tipBtnShowStr[4]
	TipsInfo:showStringTip(str,CCSizeMake(200, 0), nil, self, ccp(280.0, 55.0), -1132,true,TipDir.LeftLeftDown)
end


function OrbitCard:ctor(args)
	local args = args or {}
	self._configId = args.configId or 0
	self._card = args.card or 0
	self.parentNode = args.node or nil

	if self._configId == 0 and self._card ~= 0 then
		 self._configId = self._card:getConfigId()
	end

	if self._card == 0 and self._configId ~= 0 then
		self._card = Card.new()
		self._card:initAttrById(self._configId)
	end
	self:setNodeEventEnabled(true)

	self._cardState = eCardState.eFront
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/oribitCard/OribitCard.plist")
	init(self)

	self:setTouchEnabled(true)
	self:addTouchEventListener(handler(self,onTouch) ,false, -1131, true)
end

--local function remove(self)
--	--self:removeFromParentAndCleanup(true)
--
--	self.view:remove()
--end

function OrbitCard:guideLayerRemove()
	Guide:Instcane():removeGuideLayer()
end

function OrbitCard:show()

	if self.parentNode == nil then
		local winSize = CCDirector:sharedDirector():getWinSize()
		local posX = winSize.width/2 - self:getContentSize().width/2
		local posY = winSize.height/2- self:getContentSize().height/2
		self:setPosition(ccp(posX,posY))

		self.view = Mask.new({opacity = 180,priority = -1130})
		self.view:addChild(self)

		local function remove()
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("img/oribitCard/OribitCard.plist")
			self.view:remove()
		end

		local frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("orbit_guanbi0.png")
		local frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("orbit_guanbi1.png")
		local pBackgroundButton = CCScale9Sprite:createWithSpriteFrame(frame1)
		local pBackgroundHighlightedButton = CCScale9Sprite:createWithSpriteFrame(frame2)

		local pButton = CCControlButton:create(pBackgroundButton)
		pButton:setBackgroundSpriteForState(pBackgroundHighlightedButton, CCControlStateHighlighted)
		pButton:setTitleColorForState(ccc3(255,255,255), CCControlStateHighlighted)
		pButton:addHandleOfControlEvent(remove,CCControlEventTouchDown)
		pButton:setPosition(ccp(display.cx,80.0))
		self.view:addChild(pButton,0)
		pButton:setTouchPriority(-1132)
		pButton:setPreferredSize(CCSizeMake(132, 61))


		local str = _tr("click_to_rollover")
		local pLabel = ui.newTTFLabelWithOutline( {
		text = str,
		font = "Courier-Bold",
		size = 30,
		x = 0,
		y = 0,
		color = ccc3(255, 255, 0), -- 使用纯黄色
		align = ui.TEXT_ALIGN_LEFT,
		valign = ui.TEXT_VALIGN_TOP,
		-- dimensions = CCSize(400, 35),
		outlineColor =ccc3(0,0,0) }
		)

		local x = display.cx - pLabel:getContentSize().width/2
		pLabel:setPosition(ccp(x, 130))
		self.view:addChild(pLabel,2)
		self.view:show()
	else
		--print("aaaaa",self:getContentSize().width,self:getContentSize().height)
		self:setPosition(ccp(-self:getContentSize().width/2.0,-self:getContentSize().height/2.0+100))
		self.parentNode:addChild(self)
	end
end

function  OrbitCard:showMaxStar()
	local maxRank = AllConfig.unit[self._configId].card_max_rank+1

	local BgIconId = {3021006,3021007,3021008,3021009,3021010 }   -- 卡牌正面背景+框
	local bottomBg = {3021016,3021017,3021018,3021019,3021020} -- 卡框的下边条
	local startBgIconId = {3022001,3022002,3022003,3022004,3022005}
	local  framebackBgId ={3022016,3022017,3022018,	3022019,3022020}    --背景框   3021011

	local function drawStarAndFrame(curRank,maxrank)
		print("cur,max",curRank,maxRank)
		print(self.starBg1:getPositionY(),self.star1:getPositionY())
		for i=1,5 do 	-- first set 5 stars is invisible
			self["starBg"..i]:setVisible(false)
			self["star"..i]:setVisible(false)
		end
		for i=1,maxrank do	-- display stars by grade
			local parent = self["starBg"..i]:getParent()
			local startBg = _res(startBgIconId[curRank])
			if parent ~= nil and startBg ~= nil then
				local posX,posY =  self["starBg"..i]:getPosition()
				parent:removeAllChildrenWithCleanup(true)
				startBg:setPosition(ccp(posX,posY))
				parent:addChild(startBg)
			end
		end
		for i=1,curRank do	-- display stars by grade
			self["star"..i]:setVisible(true)
		end

		-- avatar Bg
		local BgIconId = _res(BgIconId[curRank])
		local spriteConsize = self.cardAvatar:getContentSize()
		local posX,posY = self.cardAvatarBg:getPosition()
		--		print(posX,posY)
		local parent = self.cardAvatarBgParent
		if parent ~= nil and BgIconId ~= nil and  self.cardAvatarBg~= nil then
			self.cardAvatarBg:removeFromParentAndCleanup(true)
			BgIconId:setPosition(ccp(posX,posY))
			parent:addChild(BgIconId)
		end

		-- bottomBg
		local bottomBgIcon = _res(bottomBg[curRank])
		local parent = self.cardBottomBgParent
		if parent ~= nil and bottomBgIcon ~= nil and  self.cardBottomBg~= nil then
			self.cardBottomBg:removeFromParentAndCleanup(true)
			bottomBgIcon:setPosition(ccp(posX,posY))
			parent:addChild(bottomBgIcon)
		end
	end
	drawStarAndFrame(maxRank,maxRank)
	local img = _res(framebackBgId[maxRank])
	local posX,posY = self.frameBackBg:getPosition()
	local parent = self.frameBackBgParent
	if parent~=nil and img~=nil then
		self.frameBackBg:removeFromParentAndCleanup(true)
		img:setPosition(ccp(posX,posY))
		--img:setScale(1.15)
		parent:addChild(img)
	end

end

function OrbitCard:onExit()
end

function OrbitCard:remove()
	self:onExit()
	--self:removeFromParentAndCleanup(true)
	self.view:remove()
end









