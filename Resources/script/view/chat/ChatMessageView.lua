ChatMessageView = class("ChatMessageView",BaseView)
function ChatMessageView:ctor(data)
  ChatMessageView.super.ctor(self)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeHead","CCNode")
  pkg:addProperty("nodeAllCon","CCNode")
  pkg:addProperty("nodeMessageContent","CCNode")
  pkg:addProperty("nodeVipInfo","CCNode")
  pkg:addProperty("labelVipLevel","CCLabelBMFont")
  pkg:addProperty("spriteBg","CCScale9Sprite")
  pkg:addProperty("labelNameLeft","CCLabelTTF")
  pkg:addProperty("labelContent","CCLabelTTF")
  pkg:addProperty("menuReview","CCMenu")
  
  pkg:addFunc("reviewHandler",ChatMessageView.reviewHandler)
  
  local node,owner = ccbHelper.load("chat_message.ccbi","chat_message","CCNode",pkg)
  self:addChild(node)
  self.nodeHead:setScale(0.75)
  self.menuReview:setVisible(false)
  
  self._orgBgSize = self.spriteBg:getContentSize()
  
  
  --self.labelContent:setDimensions(CCSizeMake(440,0))
  self.labelContent:setString("")
  
  self.menuReview:setTouchPriority(-256)
  
  self:setData(data)
end

------
--  Getter & Setter for
--      ChatMessageView._Data 
-----
function ChatMessageView:setData(Data)
	self._Data = Data
	if self._Data ~= nil then
	 self:updateView()
	end
end

function ChatMessageView:getData()
	return self._Data
end

function ChatMessageView:reviewHandler()
  local data = self:getData()
  local reportInfo = data:getShareInfo()
  if reportInfo ~= nil then
    BattleReportShare:Instance():reqBattleReview(reportInfo.view,reportInfo.ft)
    BattleReportShare:Instance():setIsFromChat(true)
  end
end

function ChatMessageView:updateView()
  local data = self:getData()
  
  self.menuReview:setVisible(false)
  
  local unit_head_pic = 3012502
  local avatar = data:getPlayer():getAvatar()
  if avatar == nil or avatar < 100000 then
    avatar = 120502
  end
  local cardConfigId = avatar *100 + 1
  local head = nil
  if AllConfig.unit[cardConfigId] ~= nil then
    if AllConfig.unit[cardConfigId].unit_head_pic ~= nil then
      unit_head_pic = AllConfig.unit[cardConfigId].unit_head_pic
    end
  end
  
  head = _res(unit_head_pic)
  
  if head ~= nil then
     self.nodeHead:removeAllChildrenWithCleanup(true)
     --local boader = display.newSprite("#chat_head_bg.png")
     --self.nodeHead:addChild(boader)
     --boader:setScale(0.95)
     head:setScale(0.70)
     self.nodeHead:addChild(head)
--     local mask = DrawCricleMask:create(46,head)
--     self.nodeHead:addChild(mask)
  end
  
  
  local strTime = ""
  if data:getTime() ~= nil then 
      local sec = os.time() - data:getTime()
      if sec >= 0 then 
        if sec < 60 then
          strTime = _tr("just_now")
        elseif sec < 3600 then  --1小时内 
          strTime = _tr("%{miniute}ago", {miniute=math.max(1, math.floor(sec/60))})
        elseif sec < 24*3600 then --今天
          strTime = _tr("%{hour}hour_ago", {hour=math.floor(sec/3660)})
        elseif sec < 48*3600 then --昨天
          strTime = _tr("yesterday")
        elseif sec < 72*3600 then --前天
          strTime = _tr("before_yesterday")
        else 
          strTime = _tr("%{day}day_ago", {day=math.min(7, math.ceil(sec/(24*3660)))}) 
        end 
      end 
   end 
   
  local extentStr = "  "
   
   
  if data:getShareInfo() ~= nil then
    self.menuReview:setVisible(true)
    extentStr = "分享了".._tr(data:getShareInfo().ft).."   "
  end
   
  self.labelNameLeft:setString("LV."..data:getPlayer():getLevel().." "..data:getPlayer():getName()..extentStr..strTime)
  
  self.nodeVipInfo:setVisible(data:getPlayer():getVipLevel() > 0)
  self.labelVipLevel:setString(data:getPlayer():getVipLevel().."")
  
  local showStr = data:getContent() or ""
  --self.labelContent:setString(showStr)
  
  self.nodeMessageContent:removeAllChildrenWithCleanup(true)
  
  local labelWidth = 430
  local defaultColor = 0xffffff
  if data:getShareInfo() ~= nil then
    labelWidth = 370
    defaultColor = 0xf8bf02
  end
  local labelDesc = RichText.new(showStr, labelWidth, 0, "Courier-Bold", 24, defaultColor, 0)
  local textHeight = labelDesc:getTextSize().height
  labelDesc:setPosition(ccp(0,-textHeight))
  self.nodeMessageContent:addChild(labelDesc)
  
  local moreHeight = textHeight - 80
  if moreHeight > 0 then
    self.spriteBg:setContentSize(CCSizeMake(self._orgBgSize.width,self._orgBgSize.height + moreHeight))
  else
    self.spriteBg:setContentSize(self._orgBgSize)
  end
  
  self.nodeAllCon:setPositionY(self.spriteBg:getContentSize().height)

end

return ChatMessageView