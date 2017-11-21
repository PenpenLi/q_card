
require("view.BaseView")
require("model.mail.Mail")

MailListItem = class("MailListItem", BaseView)

function MailListItem:ctor()

  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("node_card","CCNode")
  pkg:addProperty("sprite_unread","CCSprite")
  pkg:addProperty("label_name","CCLabelTTF")
  pkg:addProperty("label_attach","CCLabelTTF")
  pkg:addProperty("label_title","CCLabelTTF")
  pkg:addProperty("label_leftDays","CCLabelTTF")
  pkg:addProperty("sprite_hightlight","CCScale9Sprite")
  pkg:addProperty("sprite_normal","CCScale9Sprite")

  local layer,owner = ccbHelper.load("MailListItem.ccbi","MailListCCB","CCLayer",pkg)
  self:addChild(layer)

  self:init()
end

function MailListItem:init()
  -- local function onNodeEvent(event)
  --   if event == "enter" then
  --   elseif event == "exit" then
  --     if self.scheduler ~= nil then
  --       self:unschedule(self.scheduler)
  --       self.scheduler = nil
  --     end
  --   end
  -- end
  -- self:registerScriptHandler(onNodeEvent)

  self:initOutLineLabel()

  self.sprite_hightlight:setVisible(false)
end

function MailListItem:initOutLineLabel()
  --coint name
  self.label_name:setString("")
  self.pSenderName = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = "Courier-Bold",
                                            size = 24,
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 241, 185),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = CCSize(200, 30),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  -- self.label_name:addChild(self.pSenderName)
  self.pSenderName:setPosition(ccp(self.label_name:getPosition()))
  self.label_name:getParent():addChild(self.pSenderName)  

  self.label_attach:setString("")
  self.pAttachInfo = ui.newTTFLabelWithOutline( {
                                            text = _tr("has attach"),
                                            font = "Courier-Bold",
                                            size = 20,
                                            x = 0,
                                            y = 0,
                                            color = ccc3(10, 250, 10),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = CCSize(200, 30),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  self.pAttachInfo:setPosition(ccp(self.label_attach:getPosition()))
  self.label_attach:getParent():addChild(self.pAttachInfo)
end


-- function MailListItem:onEnter()
--   self.super:onEnter()
-- end

-- function MailListItem:onExit()

--   self.super:onExit()
-- end

function MailListItem:setDelegate(delegate)
  self._delegate = delegate
end 

function MailListItem:getDelegate()
  return self._delegate
end 

function MailListItem:setMail(mail)
  self._mail = mail 

  if mail == nil then
    return
  end

  --show header icon
  local img = _res(mail:getSenderIconId())
  if img ~= nil then 
    local w = img:getContentSize().width 
    if w > 95 then 
      img:setScale(95/w)
    end
    self.node_card:addChild(img)
  end

  --show name and mail title
  --self.label_name:setString(mail:getSenderName())
  self.pSenderName:setString(mail:getSenderName())

  self.label_title:setString(mail:getTitle())

  self.sprite_unread:setVisible(mail:getIsNew())
  if #mail:getAttachment() > 0 then 
    self.pAttachInfo:setVisible(true)
  else 
    self.pAttachInfo:setVisible(false)
  end
  if self:getLeftTimeVisibled() == true then 
    --calc left time
    local leftHours,_ = mail:getLeftHours()
    if leftHours >= 24 then 
      self.label_leftDays:setString(_tr("left days %{day}", {day=math.ceil(leftHours/24)}))
    else 
      self.label_leftDays:setString(_tr("left hours %{hour}", {hour=leftHours}))
    end
  else 
    self.label_leftDays:setString("")
  end
end

function MailListItem:setLeftTimeVisibled(isVisibled)
  self._showLeftTime = isVisibled
end

function MailListItem:getLeftTimeVisibled()
  return self._showLeftTime
end

function MailListItem:getMail()
  return self._mail
end


function MailListItem:showCountDownTime()

  if self:getLeftTimeVisibled() == false then 
    return
  end

  local _, leftSec = self:getMail():getLeftHours()

  local function timerCallback(dt)

    leftSec = leftSec - 5
    if leftSec <= 0 then
      if self.scheduler then 
        self:unschedule(self.scheduler)
        self.scheduler = nil
      end 
      
      if self:getDelegate() ~= nil then 
        self:getDelegate():deleteMail(self:getMail(), true)
      end
    end
  end
  
  self.scheduler = self:schedule(timerCallback, 5.0)
end

function MailListItem:setHighlight(isHighlight)
  self.sprite_hightlight:setVisible(isHighlight)
end