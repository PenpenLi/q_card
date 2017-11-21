--商城首页中抽奖通知的组件
require("view.BaseView")
require("view.component.OrbitCard")
require("view.component.PopupView")

CardAwardNotifyView = class("CardAwardNotifyView", BaseView)

--[[
function CardAwardNotifyView:ctor(cardConfigId , name, time)  --card 是 model.card ,time可用 local time =  os.date("%yyyy/mm/dd", os.time()) 获取时间字符串
	-- body
	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("cardNode","CCNode")	--放置card的Node
	for i=1,5 do
		pkg:addProperty("star"..i, "CCSprite")	--5个星星
	end
	pkg:addProperty("lblPlayer","CCLabelTTF")	-- 玩家XX 获得标签
	pkg:addProperty("lblPlayerReward","CCLabelTTF")	-- 玩家XX 获得标签
	pkg:addProperty("lblTime",	"CCLabelTTF")	-- 时间
	pkg:addProperty("headContainer","CCNode")	-- 总的父结点

	local layer,owner = ccbHelper.load("PanelPlayerAward.ccbi","PanelPlayerAwardViewCCB","CCNode",pkg)
	self:addChild(layer)

	self:setCardhead(cardConfigId)
	self:setStarWithConfigId(cardConfigId)
	self:setPlayerName(name)
	self:setTime(time)

end
--]]

function CardAwardNotifyView:ctor()
	local pkg = ccbRegisterPkg.new(self)
	pkg:addProperty("leftMainLayer","CCLayer")
	pkg:addProperty("leftHeadIcon","CCSprite")
	pkg:addProperty("leftHeadBtn","CCControlButton")
	pkg:addProperty("leftPlayerName","CCLabelTTF")
	pkg:addProperty("leftTime","CCLabelTTF")

	pkg:addProperty("rightMainLayer","CCLayer")
	pkg:addProperty("rightHeadIcon","CCSprite")
	pkg:addProperty("rightHeadBtn","CCControlButton")
	pkg:addProperty("rightPlayerName","CCLabelTTF")
	pkg:addProperty("rightTime","CCLabelTTF")

	pkg:addFunc("leftHeadClickCallBack",CardAwardNotifyView.onLeftHeadClickCallBack)
	pkg:addFunc("rightHeadClickCallBack",CardAwardNotifyView.onRightHeadClickCallBack)

	for i=1,5 do
		pkg:addProperty("leftStarBg"..i, "CCSprite")	--5个星星
	end
	for i=1,5 do
		pkg:addProperty("leftStar"..i, "CCSprite")	--5个星星
	end

	for i=1,5 do
		pkg:addProperty("rightStarBg"..i, "CCSprite")	--5个星星
	end
	for i=1,5 do
		pkg:addProperty("rightStar"..i, "CCSprite")	--5个星星
	end

	local layer,owner = ccbHelper.load("RewardNotifyLayer.ccbi","RewardMainLayerCCB","CCNode",pkg)
	self:addChild(layer)

	--self.leftHeadBtn:setOpacity(1)




end

function CardAwardNotifyView:initData(cardConfigId1 , name1, time1,cardConfigId2,name2,time2)
	self._configId1 = cardConfigId1
	self._configId2 = cardConfigId2

	if cardConfigId1 ~= 0 then
		self:setStarAndAvatarWithConfigId("LEFT",cardConfigId1)
		--	self:setCardhead(self._configId1)
	end
	self:setPlayerName("LEFT",name1)
	self:setTime("LEFT",time1)

	if cardConfigId2 ~= nil  then
		if cardConfigId2 ~= 0 then
			self:setStarAndAvatarWithConfigId("RIGHT",cardConfigId2)
			--		self:setCardhead(self._configId2)
		end
		self:setPlayerName("RIGHT",name2)
		self:setTime("RIGHT",time2)
	else
		self.rightMainLayer:removeAllChildrenWithCleanup(true)
	end


end

function CardAwardNotifyView:setCardhead(cardConfigId)

	local cardHead = CardHeadView.new()
	cardHead:setHeadClickPriority(-500)
	cardHead:setCardByConfigId(cardConfigId)
	cardHead:setLvVisible(false)
	--cardHead:setScale(0.85)
	cardHead:enableClick(true)
	return cardHead

end

function CardAwardNotifyView:setScale(scale)
	self.headContainer:setScale(scale)
end

function CardAwardNotifyView:getScale()
	return self.headContainer:getScale()
end

function CardAwardNotifyView:setWidth(width)
	self.headContainer:setContentSize(ccp(width,self._headContainer:getContentSize().height))
end

function CardAwardNotifyView:getWidth()
	return self.headContainer:getContentSize().width
end

function CardAwardNotifyView:setHeight(height)
	self.headContainer:setContentSize(ccp(self._headContainer:getContentSize().width,height))
end

function CardAwardNotifyView:getHeight()
	return self.headContainer:getContentSize().height
end 

function CardAwardNotifyView:setPlayerName(direction,name)

	if self._configId1 == 0 then
		self.leftPlayerName:setString(name)
		self.rightPlayerName:setString(name)
	else
		if direction == "LEFT" then
			self.leftPlayerName:setString(name .. _tr("reward_font"))
			--self.lblPlayerReward:setPositionX(self.lblPlayer:getPositionX()+self.lblPlayer:getContentSize().width )
		elseif direction == "RIGHT"    then
			self.rightPlayerName:setString(name .. _tr("reward_font"))
		end
	end

end

function CardAwardNotifyView:setTime(direction,time)

	if self._configId1 == 0 then
		self.leftTime:setString("")
		self.rightTime:setString("")
	else
		if direction == "LEFT" then
			self.leftTime:setString(time)
		elseif direction == "RIGHT" then
			self.rightTime:setString(time)
		end
	end

end

function CardAwardNotifyView:getPlayerName()
	return self._playerName
end

function CardAwardNotifyView:setStarAndAvatarWithConfigId(direction,configId)
	local maxStar =  AllConfig.unit[configId].card_max_rank + 1
	local curStar = AllConfig.unit[configId].card_rank + 1

	local cardView  = self:setCardhead(configId)
	cardView:setPositionY(cardView:getPositionY()-10)
	if direction == "LEFT" then
		for i=1,maxStar do 	-- first set 5 stars is invisible
			self["leftStarBg"..i]:setVisible(true)
		end

		for i=curStar+1,5 do	-- display stars by grade
			self["leftStar"..i]:setVisible(false)
		end
		local unitHheadPic = AllConfig.unit[configId].unit_head_pic
		--local avatarIconSprite = _res(unitHheadPic)
		local parent = self.leftHeadIcon:getParent()
		self.leftHeadIcon:removeFromParentAndCleanup(true)
		--parent:removeAllChildrenWithCleanup(true)
		--avatarIconSprite:setScale(0)
		if parent ~= nil then
			parent:addChild(cardView,12)
		end
	elseif direction == "RIGHT"   then
		for i=1,maxStar do 	-- first set 5 stars is invisible
			self["rightStarBg"..i]:setVisible(true)
		end

		for i=curStar+1,5 do	-- display stars by grade
			self["rightStar"..i]:setVisible(false)
		end

		local unitHheadPic = AllConfig.unit[configId].unit_head_pic
		local avatarIconSprite = _res(unitHheadPic)
		local parent = self.rightHeadIcon:getParent()
		self.leftHeadIcon:removeFromParentAndCleanup(true)
		if parent ~= nil then
			parent:addChild(cardView,12)
		end

	end


end

function CardAwardNotifyView:setCardView(card)
	self._cardView = card
end

function CardAwardNotifyView:getCardModel()
	return self._cardView
end

function CardAwardNotifyView:setCardModel(card)
 if card ~=nil then
        print("in cardModel  card ~=nil")
		if self._cardView == nil then
			self._cardView = CardHeadView.new()
			self._cardView:setPosition(ccp(0,0))
    		self:addChild(self._cardView)
		end
        print("began self._cardView:setCard(card)")
        print("CardAwardNotifyView:setCardModel 113 card's species:"..card:getSpecies())
    	self._cardView:setCard(card)
    --get star num
    local star = card:getGrade()
    print("CardAwardNotifyView 36:card star:"..star)
    for i=1,5 do 	-- first set 5 stars is invisible
    	self["star"..i]:setVisible(false)
    end
    for i=1,star do	-- display stars by grade
    	self["star"..i]:setVisible(true)
    end

 end
end

function CardAwardNotifyView:getCardModel()
	-- get card data
	if self._cardView ~= nil then
		return self._cardView.getCard()
	else
		return nil
	end
end

function CardAwardNotifyView:onLeftHeadClickCallBack()
	print("CardAwardNotifyView.lua<CardAwardNotifyView:: onLeftHeadClickCallBack"  )
	_playSnd(SFX_CLICK)

	--self._configId1
	-- local card = Card.new()
	if self._configId1~= 0 then
	    self.card =  OrbitCard.new({configId = self._configId1})
	    self.card:show()
	end
end

function CardAwardNotifyView:onRightHeadClickCallBack()
	print("CardAwardNotifyView.lua<CardAwardNotifyView:,onRightHeadClickCallBack")
	_playSnd(SFX_CLICK)
	--self._configId2
	if self._configId1 ~= 0 then
		self.card =  OrbitCard.new({configId = self._configId2})
		self.card:show()
	end
end

function CardAwardNotifyView:setStarAndTimeInvisible()
--	for i=1,5 do 	-- first set 5 stars is invisible
--		self["star"..i]:setVisible(false)
--	end
--	self.lblTime:setVisible(false)
--	self.lblPlayer:setString(self:getPlayerName())
end

return CardAwardNotifyView
