GuildItemView = class("GuildItemView",BaseView)
function GuildItemView:ctor(data)
  GuildItemView.super.ctor(self)
  self:setIndex(0)
  self:setData(data,false)
end

------
--  Getter & Setter for
--      GuildItemView._Data 
-----
function GuildItemView:setData(Data,update)
	self._Data = Data
	if update == nil then
	 update = true
	end
	if update == true then
	 self:updateView()
	end
end

function GuildItemView:getData()
	return self._Data
end

function GuildItemView:onEnter()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("spriteRank","CCSprite")
  pkg:addProperty("nodeFlag","CCNode")
  pkg:addProperty("labelRank","CCLabelBMFont")
  pkg:addProperty("labelGuildName","CCLabelTTF")
  pkg:addProperty("labelPoint","CCLabelTTF")
  pkg:addProperty("labelLevel","CCLabelTTF")
  pkg:addProperty("labelNotice","CCLabelTTF")
  pkg:addProperty("labelGuildId","CCLabelTTF")
  pkg:addProperty("labelMembers","CCLabelTTF")
  pkg:addProperty("labelApplyState","CCLabelTTF")
  pkg:addProperty("btnJoin","CCMenuItemImage")
  pkg:addFunc("joinGuildHandler",GuildItemView.joinGuildHandler)
  
  local node,owner = ccbHelper.load("guild_base_listitem.ccbi","guild_base_listitem","CCNode",pkg)
  self:addChild(node)
  
  self:updateView()
end

function GuildItemView:onExit()
end

------
--  Getter & Setter for
--      GuildItemView._Index 
-----
function GuildItemView:setIndex(Index)
	self._Index = Index
end

function GuildItemView:getIndex()
	return self._Index
end

function GuildItemView:updateView()
  local haveGuide = Guild:Instance():getSelfHaveGuild()
  self.btnJoin:setVisible(not haveGuide)
  self.nodeFlag:removeAllChildrenWithCleanup(true)
  local data = self:getData()
  if data ~= nil then
    
    local flagIcon = Guild:Instance():getFlagIconByInt(data:getFlag())
    if flagIcon ~= nil then
      flagIcon:setScale(0.75)
      self.nodeFlag:addChild(flagIcon)
    end
    
    
--    if self:getIndex() > 0 and self:getIndex() <= 3 then
--      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(string.format("guild_rank_%d.png", self:getIndex()))
--      self.spriteRank:setDisplayFrame(frame)
--    end
    self.labelRank:setString(self:getIndex().."")
    --self.spriteRank:setVisible(self:getIndex() <= 3)
    self.spriteRank:setVisible(false)

    self.labelGuildName:setString("LV."..data:getLevel().." "..data:getName())
    --self.labelPoint:setString("贡献度:"..data:getExp())
    self.labelPoint:setString("")
    local applyLevel = data:getApplyLevel()
    if applyLevel < AllConfig.guild[1].apply_level then
      applyLevel = AllConfig.guild[1].apply_level
    end
    local maxMembers = AllConfig.guild_level[data:getLevel()].max_member
    --self.labelMembers:setString("成员:"..#data:getMembersCount().."/"..maxMembers)
    self.labelMembers:setString("")
    self.labelGuildId:setString("ID:"..data:getId())
    self.labelLevel:setString(_tr("need_player_level%{level}",{level = applyLevel}))
    self.labelNotice:setString("")
    local applyList = Guild:Instance():getAppliedGuildsList()
    local applyStateStr =  ""
    if haveGuide == false then
      for key, guildId in pairs(applyList) do
      	if guildId == data:getId() then
      	  applyStateStr = _tr("has_applyed").."..."
      	  self.btnJoin:setVisible(false)
      	  break
      	end
      end
    end
    self.labelApplyState:setString(applyStateStr)
  end
end

function GuildItemView:joinGuildHandler()
  local data = self:getData()
  if data ~= nil then
    if GameData:Instance():getCurrentPlayer():getLevel() < data:getApplyLevel() then
      Toast:showString(GameData:Instance():getCurrentScene(),_tr("poor level"), ccp(display.cx, display.cy))
      return
    end
    Guild:Instance():reqGuildCreateApplyC2S(data:getId(),self)
  end
end

return GuildItemView