LoginNoticeDetailView = class("LoginNoticeDetailView",BaseView)
function LoginNoticeDetailView:ctor()
    --create background frame
    local frame = display.newSpriteFrame("login_notice_bg.png")
    local bg =  CCScale9Sprite:createWithSpriteFrame(frame)
    self:addChild(bg)
    self._bg = bg
    self._labelCon = display.newNode()
    self:addChild(self._labelCon)
    self:setContentSize(bg:getContentSize())
end

------
--  Getter & Setter for
--      LoginNoticeDetailView._ContentSize 
-----
function LoginNoticeDetailView:setContentSize(ContentSize)
	self._ContentSize = CCSizeMake(ContentSize.width,ContentSize.height +60)
	self._bg:setContentSize(CCSizeMake(430,self._ContentSize.height))
	--self:setContentSize(ContentSize)
end

function LoginNoticeDetailView:getContentSize()
	return self._ContentSize
end

------
--  Getter & Setter for
--      LoginNoticeDetailView._LabelText 
-----
function LoginNoticeDetailView:setLabelText(LabelText)
  self._LabelText = LabelText
  self._labelCon:removeAllChildrenWithCleanup(true)
  if self._LabelText ~= nil then
    local label = RichLabel:create(self._LabelText,"Courier-Bold",22, CCSizeMake(430-50, 0),true,false)
    label:setColor(ccc3(0,0,0))
    local size = label:getTextSize()
    self._labelCon:addChild(label)
    label:setPosition(ccp(-size.width/2,size.height/2))
    self:setContentSize(CCSizeMake(528,size.height))
  end
end

function LoginNoticeDetailView:getLabelText()
  return self._LabelText
end



return LoginNoticeDetailView