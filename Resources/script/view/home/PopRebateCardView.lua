
require("view.BaseView")



PopRebateCardView = class("PopRebateCardView", BaseView)

function PopRebateCardView:ctor()

  local pkg = ccbRegisterPkg.new(self)

  pkg:addFunc("closeCallback",PopRebateCardView.closeCallback)
  pkg:addFunc("chargeCallback",PopRebateCardView.chargeCallback)
  pkg:addProperty("node_content","CCNode")
  pkg:addProperty("bn_close","CCControlButton")
  pkg:addProperty("bn_charge","CCControlButton")
  pkg:addProperty("sprite_bg","CCSprite")
  pkg:addProperty("sprite_tip1","CCSprite")
  pkg:addProperty("sprite_tip2","CCSprite")

  local layer,owner = ccbHelper.load("PopRebateCardView.ccbi","PopRebateCardViewCCB","CCLayer",pkg)
  self:addChild(layer)
end

function PopRebateCardView:init(isAutoClose)
  local priority = -600
  self.bn_close:setTouchPriority(priority-1)
  self.bn_charge:setTouchPriority(priority-1)

  local downLoadChannel = ChannelManager:getCurrentDownloadChannel()
  if downLoadChannel ~= nil then 
    echo("=== charge platform =", downLoadChannel)
    if downLoadChannel == "appstore" or downLoadChannel == "googlePlay" then 
      self.sprite_tip1:setVisible(true)
      self.sprite_tip2:setVisible(false)
    else 
      self.sprite_tip1:setVisible(false)
      self.sprite_tip2:setVisible(true)
    end 
  end 
  
  if isAutoClose == true then 
    --touch region check
    self:addTouchEventListener(function(event, x, y)
                                  if event == "began" then
                                    self.preTouchFlag = self:checkTouchOutsideView(x, y)
                                    return true
                                  elseif event == "ended" then
                                    local curFlag = self:checkTouchOutsideView(x, y)
                                    if self.preTouchFlag == true and curFlag == true then
                                      echo(" touch out of region: close popup") 
                                      self:closeCallback()
                                    end 
                                  end
                              end,
                false, priority, true)
    self:setTouchEnabled(true)
  end 
end 

function PopRebateCardView:create(isAutoClose)
  local pop = PopRebateCardView.new()
  pop:init(isAutoClose)
  pop.node_content:setScale(0.2)
  pop.node_content:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )

  return pop 
end 

function PopRebateCardView:closeCallback()
  self:removeFromParentAndCleanup(true)
end 

function PopRebateCardView:chargeCallback()
  self:closeCallback()
  local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
  controller:enter(ShopCurViewType.PAY)  
end 

function PopRebateCardView:checkTouchOutsideView(x, y)
  --outside check 
  local size2 = self.sprite_bg:getContentSize()
  local pos2 = self.sprite_bg:convertToNodeSpace(ccp(x, y))
  if pos2.x < 0 or pos2.x > size2.width or pos2.y < 0 or pos2.y > size2.height then 
    return true 
  end

  return false  
end 
