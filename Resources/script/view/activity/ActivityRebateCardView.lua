
require("view.BaseView")



ActivityRebateCardView = class("ActivityRebateCardView", BaseView)

function ActivityRebateCardView:ctor()
  ActivityRebateCardView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("chargeCallback",ActivityRebateCardView.chargeCallback)
  pkg:addProperty("node_content","CCNode")
  pkg:addProperty("bn_charge","CCControlButton")
  pkg:addProperty("sprite_bg","CCSprite")
  pkg:addProperty("sprite_tip1","CCSprite")
  pkg:addProperty("sprite_tip2","CCSprite")

  local layer,owner = ccbHelper.load("ActivityRebateCardView.ccbi","ActivityRebateCardViewCCB","CCLayer",pkg)
  self:addChild(layer)
end

function ActivityRebateCardView:onEnter()
  self:init()
end 

function ActivityRebateCardView:onExit()

end 

function ActivityRebateCardView:init()
  local topHeight = self:getDelegate():getTopMenuSize().height
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height

  local pos_y = bottomHeight + (display.height-topHeight-bottomHeight)/2
  self.node_content:setPositionY(pos_y)

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
end 

function ActivityRebateCardView:chargeCallback()
  local controller = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
  controller:enter(ShopCurViewType.PAY)  
end 
