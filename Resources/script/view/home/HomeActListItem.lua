
require("view.BaseView")


HomeActListItem = class("HomeActListItem", BaseView)

function HomeActListItem:ctor()
  HomeActListItem.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("node_icon","CCNode") 
  pkg:addProperty("sprite_sel","CCSprite")
  pkg:addProperty("sprite_nor","CCSprite")
  pkg:addProperty("sprite_state","CCSprite")
  pkg:addProperty("label_name","CCLabelTTF") 

  local layer, owner = ccbHelper.load("HomeActListItem.ccbi","HomeActListItemCCB","CCLayer",pkg)
  self:addChild(layer)
end

function HomeActListItem:onEnter()
  self:updateInfos()
end

function HomeActListItem:onExit()

end

function HomeActListItem:setData(actItem)
  self.actItem = actItem 
end 

function HomeActListItem:setIdx(idx)
  self._idx = idx 
end 

function HomeActListItem:getIdx()
  return self._idx 
end 

function HomeActListItem:updateInfos()
  if self.actItem == nil then 
    return 
  end 
  --icon 
  local icon = _res(self.actItem.title_res)
  if icon ~= nil then 
    icon:setScale(78/icon:getContentSize().height)
    self.node_icon:addChild(icon)
  end 

  self.label_name:setString(self.actItem.activity_name)

  local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(string.format("act_state_%d.png", self.actItem.hot_type))
  if frame ~= nil then 
    self.sprite_state:setDisplayFrame(frame)
  end 
end 

function HomeActListItem:setSelected(isSelected)
  self.sprite_nor:setVisible(not isSelected)
  self.sprite_sel:setVisible(isSelected)
end 
