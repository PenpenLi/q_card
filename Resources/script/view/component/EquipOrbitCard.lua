

EquipOrbitCard = class("EquipOrbitCard",function()  return display.newLayer() end)

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
	return CCRectMake(x-object:getContentSize().width/2.0,y-object:getContentSize().height/2.0,object:getContentSize().width/2,object:getContentSize().height)
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
	return CCRectMake(x,y-object:getContentSize().height/2.0,object:getContentSize().width/2,object:getContentSize().height)
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
	--print("self._cardState",self._cardState)
	print("touchBeginX touchBeginY",x,y)
	touchBeginX = x
	touchBeginY = y
	if  containsTouchLocationLeft(x,y) then
		if self._cardState == eCardState.eFront then
			--	print("show back")
			--	showBackCardFirstHalf(self)
			return true
		elseif self._cardState == eCardState.eBack then
			--	print("show front")
			--	showFrontCardFirstHalf(self)
			return true
		end
	elseif containsTouchLocationRight(x,y) then
		if self._cardState == eCardState.eFront then
			--	print("show back")
			--	showBackCardFirstHalfRight(self)
			return true
		elseif self._cardState == eCardState.eBack then
			--	print("show front")
			--	showFrontCardFirstHalfRight(self)
			return true
		end
	end
	return false
end

local function ccTouchEnded(self,x, y)

	local length = (x-touchBeginX)*(x-touchBeginX)+(y-touchBeginY)*(y- touchBeginY)
	if length < 200 then
		if  containsTouchLocationLeft(x,y) then
			if self._cardState == eCardState.eFront then
				--	print("show back")
				showBackCardFirstHalf(self)

			elseif self._cardState == eCardState.eBack then
				--	print("show front")
				showFrontCardFirstHalf(self)

			end
		elseif containsTouchLocationRight(x,y) then
			if self._cardState == eCardState.eFront then
				--	print("show back")
				showBackCardFirstHalfRight(self)

			elseif self._cardState == eCardState.eBack then
				--	print("show front")
				showFrontCardFirstHalfRight(self)

			end
		end
		return
	end


end

local function  ccTouchMoved(x,y)
	--print("ccTouchMoved x =,y=",x,y)
end

local function onTouch(self,eventType, x, y)
	if eventType == "began" then
		return ccTouchBegan(self,x,y)
	elseif eventType == "moved" then
		return ccTouchMoved(x,y)
	elseif eventType == "ended" then
		return self,ccTouchEnded(self,x, y)
	end
	return false
end

local function updataFrontAndBackCardInfo(self)
	local BgIconId = {3021006,3021007,3021008,3021009,3021010  }   -- 卡牌正面背景+框
	local bottomBgId = {3021016,3021017,3021018,3021019,3021020} -- 卡框的下边条
	local startBgIconId = {3022001,3022002,3022003,3022004,3022005}  -- 背景星星


	local function drawStarAndFrame(equip_rank)
	--	print(self.starBg1:getPositionY(),self.star1:getPositionY())
		for i=1,5 do 	-- first set 5 stars is invisible
			self["starBg"..i]:setVisible(false)
			self["star"..i]:setVisible(false)
		end
		for i=1,equip_rank do	-- display stars by grade
			local parent = self["starBg"..i]:getParent()
			local startBg = _res(startBgIconId[equip_rank])
			if parent ~= nil and startBg ~= nil then
				local posX,posY =  self["starBg"..i]:getPosition()
				parent:removeAllChildrenWithCleanup(true)
				startBg:setPosition(ccp(posX,posY))
				parent:addChild(startBg)
			end
		end
		for i=1,equip_rank do	-- display stars by grade
			self["star"..i]:setVisible(true)
		end
		
		self.starNode:setPositionX(16 + 18*(5 - equip_rank ))

		-- equip Bg
		local pBgIcon = _res(BgIconId[equip_rank])
		local posX,posY = self.equipBg:getPosition()
		--		print(posX,posY)
		local parent = self.equipBg:getParent()
		if parent ~= nil and pBgIcon ~= nil and  self.equipBg~= nil then
			self.equipBg:removeFromParentAndCleanup(true)
			pBgIcon:setPosition(ccp(posX,posY))
			parent:addChild(pBgIcon)
		end

		-- bottomBg
		local bottomBgIcon = _res(bottomBgId[equip_rank])
		local parent = self.equipBottomBgIcon:getParent()
		if parent ~= nil and bottomBgIcon ~= nil then
			self.equipBottomBgIcon:removeFromParentAndCleanup(true)
			bottomBgIcon:setPosition(ccp(posX,posY))
			parent:addChild(bottomBgIcon)
		end
	end


	local function drawEquipIcon(unitPic)
		local img = _res(unitPic)
		local posX,posY = self.equipIcon:getPosition()
		local parent = self.equipIcon:getParent()
		if parent ~= nil and img~= nil then
			self.equipIcon:removeFromParentAndCleanup(true)
			img:setPosition(ccp(posX,posY))
			parent:addChild(img)
		end
	end

	local function drawNameWithNameStr(strName)
--		local pNameLabel
--		local pNameLabel = ui.newTTFLabelWithOutline( {
--			text = strName,
--			font ="fzjzjt.ttf",
--			size = 20,
--			x =0,-- posX-4,
--			y = 0,-- posY-6,
--			color = ccc3(255, 255, 0), -- 原字体纯黄色
--			align = ui.TEXT_ALIGN_CENTER,
--			valign = ui.TEXT_VALIGN_CENTER,
--			dimensions = CCSize(30, 180),
--			outlineColor =ccc3(0,0,0)} --黑色描边
--		)
--
--		pNameLabel:setPosition(self.equipNameBg:boundingBox().size.width/2.0,self.equipNameBg:getContentSize().height/2.0+5.0)
--		self.equipNameBg:addChild(pNameLabel,2)
		self.equipName:setString(strName)
	end

	local configId =  self._configId
	local equip_rank = AllConfig.equipment[configId].equip_rank+1    -- 代表 当前星级

	local equipPicId = AllConfig.equipment[configId].equip_pic

	local  strEquipName = ""
--	if self._isGallery == false then           -- 统一读card_name
--		strEquipName = AllConfig.equipment[configId].card_name
--	else
--		strEquipName = AllConfig.equipment[configId].card_name
--	end
	strEquipName = AllConfig.equipment[configId].card_name

	--	local cradNameIconId = AllConfig.unit[configId].unit_name_pic

	drawStarAndFrame(equip_rank)

	drawNameWithNameStr(strEquipName)
	drawEquipIcon(equipPicId)
end

local function updataBackAndBackCardInfo(self)
	--	print("congifId",self._configId)
	local configId =  self._configId

	local  framebackBgId ={3022016,3022017,3022018,	3022019,3022020}    --背景框   3021011
	-- equipName
	local strEquipName = ""
	strEquipName = AllConfig.equipment[configId].card_name
	self.equipNameTTF:setString(strEquipName)

	--local baseAttrIcon = {3022043,3022040,3022037,3022039,3022035 }
	local AttrIcon = {3022043,3022040,3022037,3022039,3022035,3022038,3022041,3022036,3022042,3022046,3022045}
	local defaultIcon = 3022044

	local function setEquipmentAttrInfo(equimentData)

		local attrIconArray = {self.attr1Icon, self.attr2Icon, self.attr3Icon, self.attr4Icon}
		local valArr = {self.desc1, self.desc2, self.desc3, self.desc4 }

		-- init attrNum
		self.lableBaseNum:setString("--")
		for i = 1,table.getn(valArr),1 do
			self["desc"..i]:setString("--")
		end

		local function initBaseIcon(attrTypeId)
			local attrBaseIcon
			if attrTypeId == nil then
				attrBaseIcon = _res(defaultIcon)
			else
			    attrBaseIcon = _res(attrTypeId)
			end

			local parent = self.baseAttrIcon:getParent()
			local posX,posY = self.baseAttrIcon:getPosition()
			local ap = tolua.cast(self.baseAttrIcon:getAnchorPoint(), "CCPoint")
			attrBaseIcon:setAnchorPoint(ap)
			attrBaseIcon:setPosition(ccp(posX,posY))
			self.baseAttrIcon:removeFromParentAndCleanup(true)
			if parent ~= nil then
			   parent:addChild(attrBaseIcon)
			end
		end
		if equimentData == nil then
			initBaseIcon()
	        return
		end

		local attrTbl = equimentData:getSkillAttrExt()

		if #attrTbl == 0 then
			initBaseIcon()
		end

		local attrCount = 0
		--show equipment attr info
		for i=1, table.getn(attrTbl) do
			local type = attrTbl[i].eType
			local iconId = attrTbl[i].attrIconId
			if attrTbl[i].genType == 1 then --base
			    initBaseIcon(iconId)
				self.lableBaseNum:setString(attrTbl[i].data)
			else  --random
				attrCount = attrCount + 1
				local attrRandomIcon = _res(iconId)

				if attrCount <= 4 then
					local parent = attrIconArray[attrCount]:getParent()
					local posX,posY = attrIconArray[attrCount]:getPosition()
					local ap = tolua.cast(attrIconArray[attrCount]:getAnchorPoint(), "CCPoint")
					attrRandomIcon:setAnchorPoint(ap)
					attrRandomIcon:setPosition(ccp(posX,posY))
					attrIconArray[attrCount]:removeFromParentAndCleanup(true)
					parent:addChild(attrRandomIcon)
					valArr[attrCount]:setString(attrTbl[i].data)
				end
			end
		end
	end

	setEquipmentAttrInfo(self._equip)  -- TODO:show Equip Attr info

	-- star lv
	local equipLv =  AllConfig.equipment[configId].equip_rank +1
	for i=1,5 do 	-- first set 5 stars is invisible
		self["backStar"..i]:setVisible(false)
	end
	for i=1,equipLv do	-- display stars by grade
		self["backStar"..i]:setVisible(true)
	end

	self.backStarNode:setPositionX(self.equipNameTTF:getPositionX()+ self.equipNameTTF:getContentSize().width + 30)

	-- backFrame
	local img = _res(framebackBgId[equipLv])
	local posX,posY = self.frameBackBg:getPosition()
	local parent = self.frameBackBg:getParent()
	if parent~=nil and img~=nil then
		self.frameBackBg:removeFromParentAndCleanup(true)
		img:setPosition(ccp(posX,posY))
	--	img:setScale(1.15)
		parent:addChild(img)
	end

	-- desp
--	dsfg
	self.equipInfo:setString("")      --jianjie
	self.equipSpecialtyInfo:setString("")        --techang
	self.cardRewardLabel:setString(AllConfig.equipment[configId].ralate_stage)          --获得途径
	local desp = AllConfig.equipment[configId].description  --jianjie
	local specialty = AllConfig.equipment[configId].relate_unit
	self.equipInfo:setString(desp)
	self.equipSpecialtyInfo:setString(specialty)
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
		"equipBg" ,
		"equipIcon",
		"equipBottomBgIcon",
		"starBg1" ,
		"star1" ,
		"starBg2" ,
		"star2" ,
		"starBg3" ,
		"star3" ,
		"starBg4" ,
		"star4" ,
		"starBg5" ,
		"star5" ,
	}

	local backArray = {
		"baseAttrIcon",
		"attr1Icon",
		"attr2Icon",
		"attr3Icon",
		"attr4Icon",
		"backStar1",
		"backStar2",
		"backStar3",
		"backStar4",
		"backStar5"
	}

	local backSttrLabel = {
		"lableBaseNum",
		"desc1",
		"desc2",
		"desc3",
		"desc4",
		"equipSpecialtyInfo",
		"equipInfo" ,    --简介
		"cardRewardLabel",
		"equipSpecialtyFont",
		"cardRewardFont",
	}

	local frontPkg = ccbRegisterPkg.new(self)
	local numSprites = table.getn(frontArray)
	for i = numSprites,1,-1 do
		frontPkg:addProperty(frontArray[i],"CCSprite")
	end
	frontPkg:addProperty("equipName", "CCLabelBMFont")
	frontPkg:addProperty("starNode","CCNode")


	local backInfoPkg = ccbRegisterPkg.new(self)
	local numStar = table.getn(backArray)
	for i = numStar,1,-1 do
		backInfoPkg:addProperty(backArray[i],"CCSprite")
	end

	local numAttrLabelNum = table.getn(backSttrLabel)
	for i = numAttrLabelNum,1,-1 do
		backInfoPkg:addProperty(backSttrLabel[i],"CCLabelTTF")
	end
	backInfoPkg:addProperty("equipNameTTF", "CCLabelBMFont")

	backInfoPkg:addProperty("frameBackBg","CCSprite")
	backInfoPkg:addProperty("attrNode","CCNode")  -- 属性的位置
	backInfoPkg:addProperty("backStarNode","CCNode")
	


	frontLayer,frontOwner = ccbHelper.load("EquipOrbitCard.ccbi","EquipOrbitCardCCB","CCLayer",frontPkg)
	self._frontLayer = frontLayer
	updataFrontAndBackCardInfo(self)

	--反面
	backLayer ,backOwner = ccbHelper.load("EquipOrbitBackCard.ccbi","EquipOrbitBackCardCCB","CCSprite",backInfoPkg)

	self.equipSpecialtyFont:setString(_tr("equipSpecialtyFont"))
	self.cardRewardFont:setString(_tr("cardRewardFont"))
	updataBackAndBackCardInfo(self)
	--showBackInfo(self)

	local bg = self.equipBg
	self:setContentSize(bg:getContentSize())

	self:addChild(frontLayer,2,2)
	frontLayer:ignoreAnchorPointForPosition(false)
	frontLayer:setPosition(ccp(bg:getContentSize().width/2 , bg:getContentSize().height/2 ))
	--frontLayer:setPosition(ccp(display.cx,display.cy ))

	self:addChild(backLayer,2,2)
	backLayer:setPosition(ccp(bg:getContentSize().width/2,bg:getContentSize().height/2))
	backLayer:setVisible(false)

end

function EquipOrbitCard:ctor(args)
	local args = args or {}
	self._configId = args.configId or 0
	self._equip = args.equipData or nil
	self._isGallery = args.isGallery or false
	self._touchPriority = args.priority or -1131

	if self._configId == 0 and self._equip ~= 0 then
		self._configId = self._equip:getConfigId()
	end

--	if self._equip == 0 and self._equip ~= 0 then
--		self._card = Card.new()
--		self._card:initAttrById(self._configId)
--	end

	self._cardState = eCardState.eFront
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/oribitCard/OribitCard.plist")
	init(self)
	--	print("width",self:getContentSize().width)
	--	print("height",self:getContentSize().height)
	self:setTouchEnabled(true)
	self:addTouchEventListener(handler(self,onTouch) ,false, self._touchPriority, true)
end

--local function remove(self)
--	--self:removeFromParentAndCleanup(true)
--	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("img/oribitCard/OribitCard.plist")
--	self.view:remove()
--end

function EquipOrbitCard:show()

	local winSize = CCDirector:sharedDirector():getWinSize()
	local posX = winSize.width/2 - self:getContentSize().width/2
	local posY = winSize.height*15/24 - self:getContentSize().height/2
	self:setPosition(ccp(posX,posY))

	self.view = Mask.new({opacity = 180,priority = self._touchPriority+1})
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
	pButton:setPosition(ccp(display.cx,140))
	self.view:addChild(pButton,0)
	pButton:setTouchPriority(self._touchPriority-1)
	pButton:setPreferredSize(CCSizeMake(132, 61))

	local str = _tr("click_to_rollover")
	-- local pLabel = ui.newTTFLabelWithOutline( {
	-- 	text = str,
	-- 	font = "Courier-Bold",
	-- 	size = 30,
	-- 	x = 0,--display.cx - self:getContentSize().width/4.0 -15,
	-- 	y = 0,--130.0  ,
	-- 	color = ccc3(255, 255, 0), -- 使用纯黄色
	-- 	align = ui.TEXT_ALIGN_LEFT,
	-- 	-- valign = ui.TEXT_VALIGN_TOP,
	-- 	dimensions = CCSize(400, 35),
	-- 	outlineColor =ccc3(0,0,0) }
	-- )
	-- pLabel:setPosition(ccp(display.cx - pLabel:getContentSize().width/2, 200) )
	local pLabel = CCLabelTTF:create(str,"Courier-Bold",30)
	pLabel:setColor(ccc3(255, 255, 0))
	pLabel:setPosition(ccp(display.cx, 200))

	self.view:addChild(pLabel,2)
	self.view:show()
end

function  EquipOrbitCard:showMaxStar()
	local maxRank = AllConfig.unit[self._configId].card_max_rank+1
	for i=1,5 do 	-- first set 5 stars is invisible
		self["starBg"..i]:setVisible(false)
		self["star"..i]:setVisible(false)
	end
	for i=1,maxRank do	-- display stars by grade
		self["starBg"..i]:setVisible(true)
	end
	for i=1,maxRank do	-- display stars by grade
		self["star"..i]:setVisible(true)
	end
end


function EquipOrbitCard:remove()
	--self:removeFromParentAndCleanup(true)
	self.view:remove()
end









