require("view.component.RoleHeadView")
GuildApplyPlayerItemView = class("GuildApplyPlayerItemView",BaseView)
function GuildApplyPlayerItemView:ctor(data)
  GuildApplyPlayerItemView.super.ctor(self)
  self:setNodeEventEnabled(true)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("labelName","CCLabelTTF")
  pkg:addProperty("nodeHead","CCNode")
  pkg:addProperty("menu","CCMenu")
  pkg:addFunc("rejectHandler",GuildApplyPlayerItemView.rejectHandler)
  pkg:addFunc("permitHandler",GuildApplyPlayerItemView.permitHandler)
  
  local node,owner = ccbHelper.load("guild_apply_playeritem.ccbi","guild_apply_playeritem","CCNode",pkg)
  self:addChild(node)
  self.menu:setTouchPriority(-256)
  self:setData(data)
end

------
--  Getter & Setter for
--      GuildApplyPlayerItemView._Data 
-----
function GuildApplyPlayerItemView:setData(Data)
	self._Data = Data
	if Data == nil then
	  return
	end
	self.labelName:setString("LV."..Data:getLevel().." "..Data:getName())
	
	self.nodeHead:removeAllChildrenWithCleanup(true)
	local head = RoleHeadView.new(Data)
	self.nodeHead:addChild(head)
	head:setScale(0.7)
end

function GuildApplyPlayerItemView:getData()
	return self._Data
end

function GuildApplyPlayerItemView:rejectHandler()
  Guild:Instance():reqGuildChangeMemberC2S(self:getData():getId(),GuildConfig.ActionApply,0,self)
end

function GuildApplyPlayerItemView:permitHandler()
  Guild:Instance():reqGuildChangeMemberC2S(self:getData():getId(),GuildConfig.ActionApply,1,self)
end

function GuildApplyPlayerItemView:onExit()
	self:setDelegate(nil)
end

function GuildApplyPlayerItemView:updateView()
  if self:getDelegate() ~= nil then
    self:getDelegate():reloadData()
  end
end

return GuildApplyPlayerItemView