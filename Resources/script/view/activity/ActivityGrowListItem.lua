
require("view.BaseView")


ActivityGrowListItem = class("ActivityGrowListItem", BaseView)

function ActivityGrowListItem:ctor()

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("fetchCallback",ActivityGrowListItem.fetchCallback)
  pkg:addProperty("node_money","CCNode")
  pkg:addProperty("label_name","CCLabelTTF")  
  pkg:addProperty("label_desc","CCLabelTTF")
  pkg:addProperty("bn_fetch","CCControlButton")

  local layer,owner = ccbHelper.load("ActivityGrowListItem.ccbi","ActivityGrowListItemCCB","CCLayer",pkg)
  self:addChild(layer)

  self:initOutLineLabel()
end

function ActivityGrowListItem:initOutLineLabel()
  --coint name
  self.label_name:setString("")
  self.pOutLineName = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = self.label_name:getFontName(),
                                            size = self.label_name:getFontSize(),
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
  self.pOutLineName:setPosition(ccp(self.label_name:getPosition()))
  self.label_name:getParent():addChild(self.pOutLineName)
end

function ActivityGrowListItem:onEnter()
  echo("ActivityGrowListItem:onEnter")
end

function ActivityGrowListItem:onExit()
  echo("ActivityGrowListItem:onExit")
end

function ActivityGrowListItem:fetchCallback()
  echo("fetchCallback")
  _playSnd(SFX_CLICK)

  if self:getDelegate() ~= nil then 
    self:getDelegate():fetchGrowthBonus(self:getIndex())
  end
end

function ActivityGrowListItem:setPlan(planItem)
  local strName = _tr("grow_bonus%{lv}", {lv=planItem.level})
  local strDesc = _tr("grow_desc%{lv}%{count}", {lv=planItem.level, count=planItem.money})
  --self.label_name:setString(strName)
  self.pOutLineName:setString( strName)
  self.label_desc:setDimensions(CCSizeMake(286, 0))
  self.label_desc:setString(strDesc)
  self.node_money:removeAllChildrenWithCleanup(true)
  local img = _res(planItem.iconId)
  if img ~= nil then 
    self.node_money:addChild(img)
  end

    if GameData:Instance():getCurrentPlayer():getGrowPlanBuyFlag() <= 0 then
      self:setIsFetched(false, true)
    else 
      if planItem.hasFetched then 
        self:setIsFetched(true, false)
      else 
        self:setIsFetched(false, true)
      end 
    end
end

function ActivityGrowListItem:setIndex(idx)
  self.index = idx
end 

function ActivityGrowListItem:getIndex()
  return self.index
end

function ActivityGrowListItem:setIsFetched(fteched, enableMenu)
  self.fteched = fteched
  if fteched == true then 
    local disFrame = display.newSpriteFrame("bn_act_yilingqu.png")
    self.bn_fetch:setBackgroundSpriteFrameForState(disFrame,CCControlStateDisabled)
    self.bn_fetch:setEnabled(false)
  else 
    local disFrame = display.newSpriteFrame("bn_act_lingqu2.png")
    self.bn_fetch:setBackgroundSpriteFrameForState(disFrame,CCControlStateDisabled)
    if enableMenu == true then 
      self.bn_fetch:setEnabled(true)
    else 
      self.bn_fetch:setEnabled(false)
    end 
  end
end

