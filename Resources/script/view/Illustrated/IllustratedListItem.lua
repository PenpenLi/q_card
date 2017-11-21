IllustratedListItem = class("IllustratedListItem",BaseView)
function IllustratedListItem:ctor(listType)
  IllustratedListItem.super.ctor(self)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("enterHandler",IllustratedListItem.enterHandler)
  pkg:addProperty("spriteEquipment","CCSprite")
  pkg:addProperty("spriteCard","CCSprite")

  local node,owner = ccbHelper.load("GalleryListItem.ccbi","GalleryListCCB","CCNode",pkg)
  self:addChild(node)
  self:setListType(listType)
end

------
--  Getter & Setter for
--      IllustratedListItem._ListType 
-----
function IllustratedListItem:setListType(ListType)
	self._ListType = ListType
	self.spriteEquipment:setVisible(false)
	self.spriteCard:setVisible(false)
	if ListType == IllustratedType.CARD then
	   self.spriteCard:setVisible(true)
	elseif ListType == IllustratedType.EQUIPMENT then
	   self.spriteEquipment:setVisible(true)
	end
end

function IllustratedListItem:getListType()
	return self._ListType
end

function IllustratedListItem:enterHandler()
    self:getParent():enterGroups(self:getListType())
end

return IllustratedListItem