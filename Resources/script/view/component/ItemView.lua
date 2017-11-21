ItemView = class("ItemView",BaseView)
function ItemView:ctor()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeContainer","CCNode")
  pkg:addProperty("isSelectedIcon","CCScale9Sprite")
  
  local layer,owner = ccbHelper.load("ItemView.ccbi","ItemViewCCB","CCNode",pkg)
  self:addChild(layer)
  self.isSelectedIcon:setVisible(false)
end

function ItemView:setData(Data)
	self._Data = Data
end

function ItemView:getData()
	return self._Data
end
return ItemView