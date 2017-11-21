LoginNoticeItem = class("LoginNoticeItem",BaseView)
function LoginNoticeItem:ctor()
  self:setNodeEventEnabled(true)
  local bg = display.newSprite("#login_notice_title_bar.png")
  --bg:setAnchorPoint(ccp(0,0))
  self:addChild(bg)
  
  local hot = display.newSprite("#login_notice_title_hot.png")
  self:addChild(hot)
  hot:setPositionX(-bg:getContentSize().width/2 + hot:getContentSize().width/2)
  self._hot = hot
  hot:setVisible(false)
  
  local new = display.newSprite("#login_notice_title_new.png")
  self:addChild(new)
  new:setPositionX(-bg:getContentSize().width/2 + new:getContentSize().width/2)
  self._new = new
  new:setVisible(false)
  
  
  
  
  self:setContentSize(bg:getContentSize())
  local label = CCLabelTTF:create("Notice Title","Courier-Bold",22)
  label:setColor(ccc3(0,66,121))
  label:setAnchorPoint(ccp(0.5,0.5))
  self:addChild(label)
  self._label = label
  --label:setPosition(ccp(bg:getContentSize().width/2,bg:getContentSize().height/2))
  self:setIsOpened(false)
end

------
--  Getter & Setter for
--      LoginNoticeItem._Index 
-----
function LoginNoticeItem:setIndex(Index)
	self._Index = Index
end

function LoginNoticeItem:getIndex()
	return self._Index
end

------
--  Getter & Setter for
--      LoginNoticeItem._State 
-----
function LoginNoticeItem:setState(State)
	self._State = State
	self._hot:setVisible(false)
	self._new:setVisible(false)
	if State == "new" then
	 self._new:setVisible(true)
	elseif State == "hot" then
	 self._hot:setVisible(true)
	end
end

function LoginNoticeItem:getState()
	return self._State
end

------
--  Getter & Setter for
--      LoginNoticeItem._IsHot 
-----
function LoginNoticeItem:setIsHot(IsHot)
	self._IsHot = IsHot
	self._hot:setVisible(IsHot)
end

function LoginNoticeItem:getIsHot()
	return self._IsHot
end

------
--  Getter & Setter for
--      LoginNoticeItem._IsOpened 
-----
function LoginNoticeItem:setIsOpened(IsOpened)
	self._IsOpened = IsOpened
end

function LoginNoticeItem:getIsOpened()
	return self._IsOpened
end

------
--  Getter & Setter for
--      LoginNoticeItem._LabelText 
-----
function LoginNoticeItem:setLabelText(LabelText)
	self._LabelText = LabelText
	if self._LabelText ~= nil then
	   self._label:setString(LabelText)
	else
	   self._label:setString("")
	end
end

function LoginNoticeItem:getLabelText()
	return self._LabelText
end

function LoginNoticeItem:onExit()
  
end

return LoginNoticeItem