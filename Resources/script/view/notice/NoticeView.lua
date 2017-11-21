 NoticeView = class("NoticeView",BaseView)
 function NoticeView:ctor()
    
   self:setNodeEventEnabled(true)
   self:setEnabledLocalNotice(false)
   
   local bg = display.newSprite("#common_top_bottom_glod_block.png")
   bg:setAnchorPoint(ccp(0,0))
   bg:setPositionX(display.cx - bg:getContentSize().width/2)
   self:addChild(bg)
   
   -- system notice
   self._messageArray = GameData:Instance():getNoticeInstance():getNotices()
   self._messageLength = table.getn(self._messageArray)
   self._messageCount = 1
   
    local str = self._messageArray[self._messageCount]
    self.pDispInfo = nil
    local showStr = ""
    local strWidth = 0
    
    local ttf = CCLabelTTF:create("", "Arial", 22)
    ttf:setString(showStr)
    self:addChild(ttf)
    ttf:setVisible(false)
    
    local mask = DSMask:createMask(CCSizeMake(500,100))
    self:addChild(mask)
    mask:setPositionX(display.cx - 250)
    
    local updateMessagePos = function()
       if self.pDispInfo == nil then
          if ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.BATTLE_CONTROLLER
          and ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.REGIST_CONTROLLER
          then
             self:setVisible(true)
          end
          if #self._messageArray <= 0 then
             self._messageArray = GameData:Instance():getNoticeInstance():getNotices()
             if self:getEnabledLocalNotice() == true and #self._messageArray <= 0 then
                self._messageArray[1] = GameData:Instance():getNoticeInstance():getRandomLocalNotice()
             else
                self:setVisible(false)
                return
             end
          end
          str = self._messageArray[1]
          self.pDispInfo = RichLabel:create(str,"Arial",22,CCSizeMake(1280, 125),false,true)
          self.pDispInfo:setColor(ccc3(0,0,0))
          showStr = self.pDispInfo:getString()
          ttf:setString(showStr)
          strWidth = ttf:getContentSize().width
          self.pDispInfo:setPosition(ccp(display.size.width,-90))
          mask:addChild(self.pDispInfo)
       end
       
       if self.pDispInfo ~= nil then
           self.pDispInfo:setPositionX(self.pDispInfo:getPositionX()-4)
           if self.pDispInfo:getPositionX() < -strWidth then
              self.pDispInfo:setPositionX(display.size.width)
              self.pDispInfo:removeFromParentAndCleanup(true)
              self.pDispInfo = nil
              table.remove( self._messageArray, 1)
              self._messageArray = GameData:Instance():getNoticeInstance():getNotices()
           end
       end
       
       
    end
    
    -- render notice position
    self:schedule(updateMessagePos,1/30)
 
 end
 
 ------
 --  Getter & Setter for
 --      NoticeView._EnabledLocalNotice 
 -----
 function NoticeView:setEnabledLocalNotice(EnabledLocalNotice)
 	self._EnabledLocalNotice = EnabledLocalNotice
 end
 
 function NoticeView:getEnabledLocalNotice()
 	return self._EnabledLocalNotice
 end 
 
 return NoticeView
 