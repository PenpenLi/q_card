
require("view.BaseView")


VipInfoItem = class("VipInfoItem", BaseView)

function VipInfoItem:ctor(bgIndex)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("gotoCallback",VipInfoItem.gotoCallback)
  pkg:addProperty("node_desc","CCNode") 
  pkg:addProperty("label_title","CCLabelTTF")

  pkg:addProperty("sprite9_bg1","CCScale9Sprite")
  pkg:addProperty("sprite9_bg2","CCScale9Sprite")
  pkg:addProperty("bn_chakan","CCControlButton")

  local layer,owner = ccbHelper.load("VipInfoItem.ccbi","VipInfoItemCCB","CCLayer",pkg)
  self:addChild(layer)

  if bgIndex == nil or bgIndex == 1 then 
    self.sprite9_bg1:setVisible(true)
    self.sprite9_bg2:setVisible(false)
  else 
    self.sprite9_bg1:setVisible(false)
    self.sprite9_bg2:setVisible(true)
  end 

  self:initOutLineLabel()
end

function VipInfoItem:initOutLineLabel()
  self.label_title:setString("")
  self.pOutLineName = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = self.label_title:getFontName(),
                                            size = self.label_title:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 234, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = CCSize(200, 30),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  self.pOutLineName:setPosition(ccp(self.label_title:getPosition()))
  self.label_title:getParent():addChild(self.pOutLineName)
end 

-- function VipInfoItem:onEnter()
--   echo("VipInfoItem:onEnter")
-- end

-- function VipInfoItem:onExit()
--   echo("VipInfoItem:onExit")
-- end

function VipInfoItem:gotoCallback()
  _playSnd(SFX_CLICK)
  echo(" VipInfoItem:gotoCallback ")
  if self:getDelegate() ~= nil then
    self:getDelegate():gotoViewByVipInfoIdx(self:getIdx())
  end
end

function VipInfoItem:setBonus(planItem)
  self:showItemsList(planItem)
end

function VipInfoItem:setIdx(idx)
  self.index = idx
end 

function VipInfoItem:getIdx()
  return self.index
end

function VipInfoItem:setTitle(str)
  if str ~= nil then 
    -- self.label_title:setString(str)
    self.pOutLineName:setString(str)
  end
end

function VipInfoItem:setDescString(str)
  --local str = "本月累计签到<font><fontname>fzjzjt</><color><value>13839616</>".. 3 .. "</></>次"

  if str ~= nil then 
    local size = self.node_desc:getContentSize()
    local pDispInfo = RichLabel:create(str,"Courier-Bold",20, size,true,false)
    pDispInfo:setColor(ccc3(69,20,1))
    self.node_desc:addChild(pDispInfo)
  end
end

function VipInfoItem:setBtnPriority(priority)
  self.bn_chakan:setTouchPriority(priority)
end 