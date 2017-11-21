RoleHeadView = class("RoleHeadView", BaseView)
function RoleHeadView:ctor(relationData)
	RoleHeadView.super.ctor(self)
	local headLayerPkg = ccbRegisterPkg.new(self)
	headLayerPkg:addProperty("avatorNode","CCNode")
	headLayerPkg:addProperty("nodeAvatorContainer","CCNode")
	headLayerPkg:addProperty("node_vip","CCNode")
	headLayerPkg:addProperty("label_level","CCLabelBMFont")

	local roleHeadLayer,headlayerOwner = ccbHelper.load("RoleHeadView.ccbi","RoleHeadViewCCB","CCNode",headLayerPkg)
	self:addChild(roleHeadLayer)
	self.avatorNode:setScale(0.9)
	self.label_level:setScale(0.8) 
	self:setRelationData(relationData)
	self._roleHeadLayer = roleHeadLayer
end

------
--  Getter & Setter for
--      RoleHeadView._RelationData 
-----
function RoleHeadView:setRelationData(RelationData)
	self._RelationData = RelationData
	if RelationData == nil then
	  return
	end
	
	local unitRoot = RelationData:getAvatar()
  local unit_head_pic = 0
  if unitRoot <= 1 then
    unit_head_pic = 3012502
  else
    local cardConfigId = tonumber(unitRoot.."01")
    unit_head_pic = AllConfig.unit[cardConfigId].unit_head_pic
  end
  self:setAvatorIcon(unit_head_pic)
	
	self:setVipLevel(RelationData:getVipLevel())
end

function RoleHeadView:getRelationData()
	return self._RelationData
end

------
--  Getter & Setter for
--      RoleHeadView._Scale 
-----
function RoleHeadView:setScale(Scale)
	self._Scale = Scale
	self._roleHeadLayer:setScale(self._Scale)
end

function RoleHeadView:getScale()
	return self._Scale or 1.0
end

function RoleHeadView:getContentSize()
  return CCSizeMake(self.avatorNode:getContentSize().width * self:getScale(),self.avatorNode:getContentSize().height * self:getScale())
end

function RoleHeadView:setAvatorIcon(AvatorIconId)
	local head = _res(AvatorIconId)
	if head ~= nil then
		self.nodeAvatorContainer:removeAllChildrenWithCleanup(true)
		self.nodeAvatorContainer:addChild(head)
		head:setScale(0.8)
	end
end

function RoleHeadView:getAvatorIcon()
	return self._AvatorIcon
end

function RoleHeadView:getContent()
	return self.avatorNode:getContentSize()
end

function RoleHeadView:setVipLevel(level)
	self.node_vip:setVisible(level > 0)

	if self.node_vip:isVisible() then 
		self.label_level:setString(""..level)
	end 
end 

return RoleHeadView

