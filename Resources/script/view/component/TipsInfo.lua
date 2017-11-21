

TipsInfo = class("TipsInfo", function()  return CCLayer:create() end)

TipDir = enum({"LeftDown", "RightDown", "LeftUp", "RightUp", "LeftLeftUp", "LeftLeftDown", "RightRightUp", "RightRightDown"})

function TipsInfo:ctor()

end

function TipsInfo:regTouchEvent(priority, bSwallow)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
        	-- echo("=== touch remove ===")
        	local function endAnim()
        		self:removeFromParentAndCleanup(true)
        	end 
        	if self._img ~= nil then 
	        	local act = CCScaleTo:create(0.1, 0.1)
	        	local callfunc = CCCallFunc:create(endAnim)
	        	local seq = CCSequence:createWithTwoActions(act,callfunc)
	        	self._img:runAction(seq)

	        	if bSwallow ~= nil and bSwallow == true then 
	        		return true 
	        	end
        	end

          	return false
        end
    end
    if priority == nil then 
    	priority = -300
    end 

	self:setTouchEnabled(true)
	self:addTouchEventListener(onTouch,false, priority, true)
end


function TipsInfo:initArrowDirection(tipImg, direction)
	if tipImg == nil then 
		return 
	end

	direction =  direction or TipDir.LeftDown

	local arrow = CCSprite:create("img/common/tip-arrow.png")
	if arrow ~= nil then 
		local bgSize = tipImg:getContentSize()
		local arrSize = arrow:getContentSize()
		local x = 2
		local y = 2 
		if direction == TipDir.LeftLeftDown then 
			arrow:setAnchorPoint(ccp(1, 0))
			if bgSize.height > arrSize.height + 20 then 
				y = 20
			end 
		elseif direction == TipDir.LeftLeftUp then 
			arrow:setFlipY(true)
			arrow:setAnchorPoint(ccp(1, 1))
			if bgSize.height > arrSize.height + 20 then 
				y = bgSize.height - 20
			end 
		elseif direction == TipDir.RightRightDown then 
			arrow:setFlipX(true)
			arrow:setAnchorPoint(ccp(0, 0))
			x = bgSize.width - 2
			if bgSize.height > arrSize.height + 20 then 
				y = 20
			end 
		elseif direction == TipDir.RightRightUp then 
			arrow:setAnchorPoint(ccp(1, 0))
			arrow:setRotation(180)
			x = bgSize.width - 2
			if bgSize.height > arrSize.height + 20 then 
				y = bgSize.height - 20
			end 
		elseif direction == TipDir.LeftDown then 
			arrow:setFlipX(true)
			arrow:setAnchorPoint(ccp(0, 0))
			arrow:setRotation(90)
			if bgSize.width > arrSize.width + 20 then 
				x = 20
			end
		elseif direction == TipDir.LeftUp then 
			arrow:setAnchorPoint(ccp(1, 0))
			arrow:setRotation(90)
			y = bgSize.height-2
			if bgSize.width > arrSize.width + 20 then 
				x = 20
			end				
		elseif direction == TipDir.RightDown then 
			arrow:setAnchorPoint(ccp(1, 0))
			arrow:setRotation(-90)
			if bgSize.width > arrSize.width + 20 then 
				x = bgSize.width - 20
			end
		elseif direction == TipDir.RightUp then 
			arrow:setFlipX(true)
			arrow:setAnchorPoint(ccp(0, 0))
			arrow:setRotation(-90)
			
			y = bgSize.height-2
			if bgSize.width > arrSize.width + 20 then 
				x = bgSize.width - 20
			end	
		else 
			--default: LeftDown
			arrow:setFlipX(true)
			arrow:setAnchorPoint(ccp(0, 0))
			arrow:setRotation(90)
			if bgSize.width > arrSize.width + 20 then 
				x = 20
			end								
		end

		arrow:setPosition(ccp(x, y))
		tipImg:addChild(arrow, 1)
	end 
end 

function TipsInfo:initRichLabelTip(descStr, pos, tipDir)
	if descStr == nil then 
		return false
	end 

	if tipDir == nil then 
		if pos.x > display.width/2 then 
			tipDir = TipDir.RightDown
		else 
			tipDir = TipDir.LeftDown
		end
	end 

	self._img = CCScale9Sprite:create("img/common/tip-kuang.png")
	if self._img ~= nil then 
		if tipDir == TipDir.LeftDown or tipDir == TipDir.LeftLeftDown then 
			pos.x = pos.x - 20
			self._img:setAnchorPoint(ccp(0, 0))
		elseif tipDir == TipDir.RightDown or tipDir == TipDir.RightRightDown then 
			pos.x = pos.x + 20
			self._img:setAnchorPoint(ccp(1, 0))
		elseif tipDir == TipDir.LeftUp or tipDir == TipDir.LeftLeftUp then 
			pos.x = pos.x - 20
			self._img:setAnchorPoint(ccp(0, 1))
		elseif tipDir == TipDir.RightUp or tipDir == TipDir.RightRightUp then 	
			pos.x = pos.x - 20
			self._img:setAnchorPoint(ccp(1, 1))
		end

		self._img:setPosition(pos)
		self:addChild(self._img)

	    local label = RichLabel:create(descStr,"Courier-Bold",18, CCSizeMake(220, 0),true,false)
	    label:setColor(ccc3(255,255,255)) --默认颜色
	    local size = label:getTextSize()
	    local w = size.width
	    local h = size.height
	    self._img:setContentSize(CCSizeMake(w+16, h+20))
	    label:setPosition(ccp(10, h+10))

	    self:initArrowDirection(self._img, tipDir)

	    self._img:addChild(label, 5)
		self._img:setScale(0.5)
		self._img:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5, 1.0),0.4))	

		-- self._img:runAction(CCScaleTo:create(0.25, 1.0))
		return true
	end

	return false
end 

function TipsInfo:initLabelTip(str, pos, dimension, color, tipDir)
	if str == nil then 
		return false
	end 

	tipDir = tipDir or TipDir.LeftDown

	self._img = CCScale9Sprite:create("img/common/tip-kuang.png")
	if self._img ~= nil then 
		if tipDir == TipDir.LeftDown or tipDir == TipDir.LeftLeftDown then 
			pos.x = pos.x - 20
			self._img:setAnchorPoint(ccp(0, 0))
		elseif tipDir == TipDir.RightDown or tipDir == TipDir.RightRightDown then 
			pos.x = pos.x + 20
			self._img:setAnchorPoint(ccp(1, 0))
		elseif tipDir == TipDir.LeftUp or tipDir == TipDir.LeftLeftUp then 
			pos.x = pos.x - 20
			self._img:setAnchorPoint(ccp(0, 1))
		elseif tipDir == TipDir.RightUp or tipDir == TipDir.RightRightUp then 	
			pos.x = pos.x - 20
			self._img:setAnchorPoint(ccp(1, 1))
		end

		self._img:setPosition(pos)
		self:addChild(self._img)

		-- show tip str 

		local dim  = dimension or CCSizeMake(640, 100)
		local color = color or ccc3(255, 255, 255)

	    local label = RichLabel:create(str,"Courier-Bold",18, dim, true,false)
	    label:setColor(color)
	    local labelSize = label:getTextSize()
	    -- echo("=========labelSize", labelSize.width, labelSize.height, dim.height)
	    self._img:setContentSize(CCSizeMake(labelSize.width+16, labelSize.height+20))
	    local pos_y = 10
	    if dim.height == 0 then 
	    	pos_y = pos_y + labelSize.height
	    elseif dim.height > labelSize.height then 
	    	pos_y = pos_y - (dim.height - labelSize.height)
	    end 

	    label:setPosition(ccp(10, pos_y))
		
	    self:initArrowDirection(self._img, tipDir)

	    self._img:addChild(label)
		self._img:setScale(0.5)
		self._img:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5, 1.0),0.4))  
		return true
	end

	return false
end 

--object & offset: fot calc position，如果为nil, 则添加到scene， 否则加到object上
--configId: for regonize item/equip/card
--objMode: cardMode/equip mode for orbit
--isOrgInfo: 显示卡牌/装备升级前的原始信息
function TipsInfo:showTip(object, configId, objMode, offset, arrowDirection, isOrgInfo)
	if configId == nil then 
		echo("nil configId")
		return 
	end 

	self.arrowDir = arrowDirection or TipDir.LeftDown

	local flag = math.floor(configId/10000000)
	if configId >= 1 and configId <= 100 then
	  flag = 2
	end
	
	echo("showTip: configId, flag =", configId, flag)
	if flag == 2 then --item

		if object == nil then 
			echo(" nil object or position")
			return
		end

		local item = AllConfig.item[configId]
		if item ~= nil then
			local x, y

			--calc pos to display tip
			local pos = ccp(object:getPosition())
			if object:getParent() ~= nil then
				pos = object:getParent():convertToWorldSpace(pos)
			end

			if offset ~= nil then 
				x = pos.x + offset.x 
				y = pos.y + offset.y
			else 
				local objectSize = object:getContentSize()
				local ap = object:getAnchorPoint()
				x = pos.x - objectSize.width*ap.x + objectSize.width/2
				y = pos.y - objectSize.height*ap.y + objectSize.height + 20
			end

			--create tip
			local tip = TipsInfo.new()
			tip:regTouchEvent(-1130)

			local rareColor = {13027014, 11003904, 45284,14549503,16768782} --白绿蓝紫橙
			local nameColor = rareColor[item.rare]
			local str = "<font><fontname>Courier-Bold</><color><value>"..nameColor.."</>"..item.item_name.."</></>".."<n/>"
			local str2 = item.tips_desc
			local tipStr = str..str2			
			if tip:initRichLabelTip(tipStr, ccp(x, y), arrowDirection) == true then
				GameData:Instance():getCurrentScene():addChildView(tip)
			end
		end
		
	elseif flag == 3 then --equipment
		if objMode ~= nil then 
			local equipOrbit =  EquipOrbitCard.new({equipData = objMode})
			equipOrbit:show()
		else 

			if isOrgInfo == true then 
				--for new equipment
				echo("====equip configI=", configId)
				local equip = Equipment.new()
				equip:setConfigId(configId)	
				local equipOrbit =  EquipOrbitCard.new({equipData = equip})
				equipOrbit:show()	
			else 
				local equips = GameData:Instance():getCurrentPackage():getAllEquipments()
				for k, v in pairs(equips) do 
					if v:getConfigId() == configId then 
						local equipOrbit =  EquipOrbitCard.new({equipData = v})
						equipOrbit:show()
						return 
					end
				end 

				--for new equipment
				echo("====equip configI=", configId)
				local equip = Equipment.new()
				equip:setConfigId(configId)	
				local equipOrbit =  EquipOrbitCard.new({equipData = equip})
				equipOrbit:show()					
			end 
		end

	elseif flag == 1 then --card
		if objMode ~= nil then 
	    local cardOrbit =  OrbitCard.new({card = objMode})
	    cardOrbit:show()	
		else 
			if isOrgInfo == true then 
				--for new card
				local cardOrbit =  OrbitCard.new({configId = configId})
				cardOrbit:show()	
			else 
				local cards = GameData:Instance():getCurrentPackage():getAllCards()
				for k, v in pairs(cards) do 
					if v:getConfigId() == configId then 
				    local cardOrbit =  OrbitCard.new({card = v})
				    cardOrbit:show() 
				    return 
					end
				end	

				--for new card
				local cardOrbit =  OrbitCard.new({configId = configId})
				cardOrbit:show()					
			end 
		end	
	end
end

function TipsInfo:showStringTip(str,dimension, color, object, offset, priority, bSwallow, arrowDir, bAddToScene)

	local x = 0
	local y = 0
	if bAddToScene ~= nil and bAddToScene == true then 
		--calc pos to display tip
		local pos = ccp(object:getPosition())
		if object:getParent() ~= nil then
			pos = object:getParent():convertToWorldSpace(pos)
		end

		if offset ~= nil then 
			x = pos.x + offset.x 
			y = pos.y + offset.y
		else 
			local objectSize = object:getContentSize()
			local ap = object:getAnchorPoint()
			x = pos.x - objectSize.width*ap.x + objectSize.width/2
			y = pos.y - objectSize.height*ap.y + objectSize.height + 10
		end
	else 
		if offset ~= nil then 
			x = offset.x
			y = offset.y 
		end
	end 


	--create tip
	local tip = TipsInfo.new()
	tip:regTouchEvent(priority, bSwallow)
		
	if tip:initLabelTip(str, ccp(x, y), dimension, color, arrowDir) == true then
		if bAddToScene ~= nil and bAddToScene == true then 

			GameData:Instance():getCurrentScene():addChild(tip, 200)
		else 
			object:addChild(tip, 200)
		end
	end
end
