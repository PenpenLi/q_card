
require("view.component.ViewWithEave")
require("view.card_soul.CardSoulRefineCardView")
require("view.card_soul.CardSoulRefineChipView")
require("view.card_soul.CardSoulShopView")

VipShopView = class("VipShopView", ViewWithEave)

function VipShopView:ctor()
  VipShopView.super.ctor(self)
  -- self:setTabControlEnabled(false)
  -- self:setScrollBgVisible(false)
  self:getEaveView().btnHelp:setVisible(false)

  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/cardSoul/cardSoul.plist")
end 

function VipShopView:onEnter()
  echo("=== VipShopView:onEnter=== ")

  local menuArray = {
      {"#bn_vip_shop0.png","#bn_vip_shop1.png"}
    }
  self:setMenuArray(menuArray)
  self:setTitleTextureName("vip_title.png")
  -- self:getTabMenu():setItemSelectedByIndex(toint(viewIndex))

  local view = CardSoulShopView.new(ShopCurViewType.VIP)
  if view ~= nil  then
    view:setDelegate(self:getDelegate())
    self:getEaveView():getNodeContainer():addChild(view)
    GameData:Instance():pushViewType(ViewType.shop_vip)
  end 
end 

function VipShopView:onExit()
  echo("=== VipShopView:onExit=== ")
  -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("img/cardSoul/cardSoul.plist")
end 

function VipShopView:onHelpHandler()
  
end 

function VipShopView:onBackHandler()
  echo("=== VipShopView:backCallback")
  VipShopView.super:onBackHandler()
  GameData:Instance():gotoPreView()
end
