require("view.component.RoleHeadView")
GuildMemberItemView = class("GuildMemberItemView",function()
  return display.newNode()
end)
function GuildMemberItemView:ctor(data)
  self:setNodeEventEnabled(true)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeHead","CCNode")
  pkg:addProperty("labelName","CCLabelTTF")
  pkg:addProperty("labelJobPlace","CCLabelTTF")
  pkg:addProperty("labelContributionPoint","CCLabelTTF")
  pkg:addProperty("labelContributionPointValue","CCLabelTTF")
  pkg:addProperty("lastLoginTime","CCLabelTTF")
  
  local node,owner = ccbHelper.load("guild_member_item_small.ccbi","guild_member_item_small","CCNode",pkg)
  self:addChild(node)
  self:setData(data)
end

function GuildMemberItemView:onEnter()
  
end

function GuildMemberItemView:onExit()
  
end

function GuildMemberItemView:updateView()
  local data = self:getData()
  self.labelName:setString("LV."..data:getLevel().." "..data:getName())
  self.labelJobPlace:setString(_tr(data:getJob()))
  self.labelContributionPoint:setString(_tr("contribution_point")..":")
  self.labelContributionPointValue:setString(""..data:getPoint())
  local lastLogoutTime = data:getLastLogoutTime()
  local isOnLine = data:getIsOnLine()
  local strTime = ""
  if isOnLine == true then
    strTime = _tr("last_logout_time").._tr("current_online")
  else
    if lastLogoutTime ~= nil then 
      local sec = Clock:Instance():getCurServerUtcTime() - lastLogoutTime 
      if sec >= 0 then 
        if sec < 3600 then  --1小时内 
          strTime = _tr("last_logout_time").._tr("%{miniute}ago", {miniute=math.max(1, math.floor(sec/60))})
        elseif sec < 24*3600 then --今天
          strTime = _tr("last_logout_time").._tr("%{hour}hour_ago", {hour=math.floor(sec/3660)})
        elseif sec < 48*3600 then --昨天
          strTime = _tr("last_logout_time").._tr("yesterday")
        elseif sec < 72*3600 then --前天
          strTime = _tr("last_logout_time").._tr("before_yesterday")
        else 
          strTime = _tr("last_logout_time").._tr("%{day}day_ago", {day=math.min(7, math.ceil(sec/(24*3660)))}) 
        end 
      end 
    end 
  end
  
  self.lastLoginTime:setString(strTime)
  self.nodeHead:removeAllChildrenWithCleanup(true)
  local head = RoleHeadView.new(data)
  self.nodeHead:addChild(head)
  head:setScale(0.7)
end

------
--  Getter & Setter for
--      GuildMemberItemView._Data 
-----
function GuildMemberItemView:setData(Data)
	self._Data = Data
	if Data ~= nil then
	 self:updateView()
	end
end

function GuildMemberItemView:getData()
	return self._Data
end

return GuildMemberItemView