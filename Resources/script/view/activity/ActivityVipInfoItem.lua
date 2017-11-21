
require("view.BaseView")

ActivityVipInfoItem = class("ActivityVipInfoItem", BaseView)

function ActivityVipInfoItem:ctor(height)

  ActivityVipInfoItem.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("buyCallback",ActivityVipInfoItem.buyCallback)
  pkg:addProperty("node_all","CCNode")
  pkg:addProperty("node_ttf","CCNode")
  pkg:addProperty("node_baner","CCNode")
  pkg:addProperty("node_ttfHead","CCNode")
  pkg:addProperty("node_desc","CCNode")
  pkg:addProperty("node_gift","CCNode")
  pkg:addProperty("node_giftHead","CCNode")
  pkg:addProperty("node_giftContainer","CCNode")
  pkg:addProperty("node_buy","CCNode")
  pkg:addProperty("sprite9_ttfBg","CCScale9Sprite")
  pkg:addProperty("sprite9_giftBg","CCScale9Sprite")
  pkg:addProperty("sprite9_frame","CCScale9Sprite")  

  pkg:addProperty("label_infoTitle","CCLabelTTF") 
  pkg:addProperty("label_giftTitle","CCLabelTTF") 
  pkg:addProperty("label_ttfVip","CCLabelBMFont") 
  pkg:addProperty("label_giftVip","CCLabelBMFont") 
  pkg:addProperty("label_oldPrice","CCLabelTTF") 
  pkg:addProperty("label_newPrice","CCLabelTTF") 
  pkg:addProperty("sprite_money1","CCSprite") 
  pkg:addProperty("sprite_money2","CCSprite") 
  pkg:addProperty("sprite_del","CCSprite") 


  pkg:addProperty("bn_buy","CCControlButton")

  local layer,owner = ccbHelper.load("ActivityVipInfoItem.ccbi","ActivityVipInfoItemCCB","CCLayer",pkg)
  self:addChild(layer)

  --自适应分辨率，调整高度  
  local frameSize = self.sprite9_frame:getContentSize()
  self.sprite9_frame:setContentSize(CCSizeMake(frameSize.width, height+10))
  self.viewRect = CCSizeMake(self.node_all:getContentSize().width, height-25)

  --先创建scrollview
  local parent = self.node_all:getParent()
  local oldPos = ccp(self.node_all:getPosition())
  self.scrollView = CCScrollView:create()
  self.scrollView:setContentSize(self.node_all:getContentSize())
  self.scrollView:setViewSize(self.viewRect)
  self.scrollView:setDirection(kCCScrollViewDirectionVertical)
  self.scrollView:setClippingToBounds(true)
  self.scrollView:setBounceable(true)
  self.node_all:removeFromParentAndCleanup(false)
  self.scrollView:setContainer(self.node_all)
  self.scrollView:setPosition(oldPos)
  parent:addChild(self.scrollView)

  self:initOutLineLabel()
end 


function ActivityVipInfoItem:onEnter()
  -- echo("---ActivityVipInfoItem:onEnter---")
end

function ActivityVipInfoItem:onExit()
  -- echo("---ActivityVipInfoItem:onExit---")
end

function ActivityVipInfoItem:buyCallback()
  echo("buyCallback")
  _playSnd(SFX_CLICK)

  self:getDelegate():buyVipGift(self:getIndex(), self._itemData.vip_level, self.MaterialData)
end 

function ActivityVipInfoItem:setPriority(priority)
  self._touchPriority = priority
end 

function ActivityVipInfoItem:getPriority()
  return self._touchPriority or 0 
end 

function ActivityVipInfoItem:setIndex(idx)
  self._idx = idx
end 

function ActivityVipInfoItem:getIndex()
  return self._idx
end 

function ActivityVipInfoItem:setData(itemData)
  self._itemData = itemData

  local dropId = self._itemData.vip_gift
  self.MaterialData = {}
  if dropId > 0 then 
    echo("=== id, dropId", self._itemData.id, dropId)
    self.MaterialData = AllConfig.drop[dropId].drop_data
  end 
  self:updateInfos()
end 

function ActivityVipInfoItem:setIsTouchOnLeftSide(bFlag)
  self._touchOnLeftSide = bFlag
end 

function ActivityVipInfoItem:getIsTouchOnLeftSide()
  return self._touchOnLeftSide
end 

function ActivityVipInfoItem:updateInfos()
  if self._itemData == nil then 
    return 
  end 

  if self._preUpdateIdx == self:getIndex() then 
    echo(" no need to update same idx")
    return 
  end 
  self._preUpdateIdx = self:getIndex()

  self.label_ttfVip:setString(""..self._itemData.vip_level)
  self.label_giftVip:setString(""..self._itemData.vip_level)
  
  --ttf 
  local banner_h, head_h, desc_h
  local ttfHeight
  self.node_baner:removeAllChildrenWithCleanup(true)
  self.node_desc:removeAllChildrenWithCleanup(true)

  local baner = display.newSprite(string.format("img/activity/act_vip%d.png", self._itemData.vip_level))
  if baner then 
    baner:setAnchorPoint(ccp(0.5, 0))
    self.node_baner:addChild(baner)
    self.node_baner:setContentSize(CCSizeMake(baner:getContentSize().width, baner:getContentSize().height))
  end 
  banner_h = self.node_baner:getContentSize().height 
  head_h = self.node_ttfHead:getContentSize().height

  --desc, 计算一行显示不完时当换行后缩进的宽度
  local tmplabel = CCLabelTTF:create("1.", "Courier-Bold", 22)
  local alignWidth = tmplabel:getContentSize().width
  local labelDesc = RichText.new(self._itemData.directions, self.node_desc:getContentSize().width, 0, "Courier-Bold", 22, 0x4d1b02, alignWidth)
  labelDesc:setPosition(ccp(0, 20))
  self.node_desc:addChild(labelDesc)
  desc_h = labelDesc:getTextSize().height + 20  

  self.sprite9_ttfBg:setContentSize(CCSizeMake(self.sprite9_ttfBg:getContentSize().width, head_h+desc_h))
  self.node_desc:setPositionY(0)
  self.node_ttfHead:setPositionY(desc_h)
  self.node_baner:setPositionY(desc_h+head_h)
  echo("====banner_h,head_h,desc_h", banner_h,head_h,desc_h)

  -- gift 
  local head_h2, gift_h, buy_h  
  head_h2 = self.node_giftHead:getContentSize().height 

  --show bonus icons
  self.node_giftContainer:removeAllChildrenWithCleanup(true)
  local iconSize = 95
  local gap = 10 
  local rows = math.ceil(#self.MaterialData/5)
  gift_h = rows * iconSize + (rows-1)*gap
  local package = GameData:Instance():getCurrentPackage()
  local offsetY = gift_h - iconSize/2
  local icon, pos, itemInfo 

  local function tipsCallback(obj, configId, pos)
    if self:getDelegate() and self:getDelegate():getIsValidTouch() == true then 
      TipsInfo:showTip(obj, configId, nil, pos, nil, true)
    end 
  end 

  for i=1, #self.MaterialData do 
    itemInfo = self.MaterialData[i].array 
    local tipArgs = {callbackFunc=tipsCallback, priority = self:getPriority()}
    icon = package:getItemSprite(nil, itemInfo[1], itemInfo[2], itemInfo[3], nil, tipArgs)
    if icon then 
      pos = ccp(((i-1)%5)*(iconSize+gap) + iconSize/2, offsetY - math.floor((i-1)/5)*(iconSize+gap))
      icon:setScale(iconSize/icon:getContentSize().width)
      icon:setPosition(pos)
      self.node_giftContainer:addChild(icon)
    end 
  end 

  buy_h = self.node_buy:getContentSize().height 

  self.sprite9_giftBg:setContentSize(CCSizeMake(self.sprite9_giftBg:getContentSize().width, head_h2+gift_h+buy_h))
  self.node_buy:setPositionY(0)
  self.node_giftContainer:setPositionY(buy_h)
  self.node_giftHead:setPositionY(buy_h+gift_h)

  self.node_gift:setPositionY(10)
  self.node_ttf:setPositionY(head_h2+gift_h+buy_h+10)

  local allHeight = banner_h+head_h+desc_h+head_h2+gift_h+buy_h 
  self.node_all:setContentSize(CCSizeMake(self.node_all:getContentSize().width, allHeight+15))

  if self.scrollView then 
    self.scrollView:setContentSize(self.node_all:getContentSize())
    self.node_all:setPosition(ccp(0, self.scrollView:getViewSize().height - self.node_all:getContentSize().height))
  end 

  --set buy button state
  local player = GameData:Instance():getCurrentPlayer()
  local curLevel = player:getVipLevel()
  local buyFlag = player:getVipBuyRecord(self._itemData.vip_level)
  echo("=== curLevel, vip_level, buyFlag", curLevel, self._itemData.vip_level, buyFlag)
  if #self.MaterialData > 0 and self._itemData.vip_level <= curLevel and buyFlag==false then 
    self.bn_buy:setEnabled(true)
  else 
    self.bn_buy:setEnabled(false)
  end 
  
  self.label_oldPrice:setString(_tr("old_price_%{num}", {num=self._itemData.vip_gift_original}))
  self.label_newPrice:setString(_tr("new_price_%{num}", {num=self._itemData.vip_gift_price}))

  local w1 = self.label_oldPrice:getContentSize().width 
  local x1 = self.label_oldPrice:getPositionX()
  local w2 = self.label_newPrice:getContentSize().width 
  local x2 = self.label_newPrice:getPositionX()
  local w3 = self.sprite_del:getContentSize().width 
  self.sprite_del:setPositionX(x1+w1/2)
  if w1 > w3 then 
    self.sprite_del:setScaleX((w1+6)/w3)
  end 
  self.sprite_money1:setPositionX(x1+w1+30)
  self.sprite_money2:setPositionX(x2+w2+30)
end 

function ActivityVipInfoItem:initOutLineLabel()
  self.label_infoTitle:setString("")
  local outline1 = ui.newTTFLabelWithOutline( {
                                            text = _tr("vip_privilege"),
                                            font = self.label_infoTitle:getFontName(),
                                            size = self.label_infoTitle:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 255, 255),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  -- local x = self.label_infoTitle:getPositionX() - outline1:getContentSize().width 
  -- local y = self.label_infoTitle:getPositionY()
  -- outline1:setPosition(ccp(x, y))
  outline1:setPosition(ccp(self.label_infoTitle:getPosition()))
  self.label_infoTitle:getParent():addChild(outline1) 

  self.label_giftTitle:setString("")
  local outline2 = ui.newTTFLabelWithOutline( {
                                            text = _tr("vip_gift"),
                                            font = self.label_giftTitle:getFontName(),
                                            size = self.label_giftTitle:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 255, 255),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  outline2:setPosition(ccp(self.label_giftTitle:getPosition()))
  self.label_giftTitle:getParent():addChild(outline2) 
end 


