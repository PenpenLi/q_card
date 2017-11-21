GuildFlagSettingsView = class("GuildFlagSettingsView",BaseView)
function GuildFlagSettingsView:ctor()
  GuildFlagSettingsView.super.ctor(self)
   --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,190), display.width, display.height)
  self:addChild(layerColor)
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeFlagAll","CCNode")
  pkg:addProperty("labelPreView","CCLabelTTF")
  pkg:addProperty("menuBtns","CCMenu")
  pkg:addProperty("btnPre1","CCMenuItemImage")
  pkg:addProperty("btnPre2","CCMenuItemImage")
  pkg:addProperty("btnPre3","CCMenuItemImage")
  pkg:addProperty("btnNext1","CCMenuItemImage")
  pkg:addProperty("btnNext2","CCMenuItemImage")
  pkg:addProperty("btnNext3","CCMenuItemImage")
  pkg:addProperty("label1","CCLabelTTF")
  pkg:addProperty("label2","CCLabelTTF")
  pkg:addProperty("label3","CCLabelTTF")

  pkg:addFunc("setFlagHandler",GuildFlagSettingsView.setFlagHandler)
  pkg:addFunc("closeHandler",GuildFlagSettingsView.closeHandler)
  
  local node,owner = ccbHelper.load("guildLogoSettingView.ccbi","guildLogoSettingView","CCLayer",pkg)
  self:addChild(node)
  
  self.labelPreView:setString(_tr("icon_preview"))
  
  local selectBtns = {self.btnPre1,self.btnPre2,self.btnPre3,self.btnNext1,self.btnNext2,self.btnNext3}
  
  local type1 = {}
  local type2 = {}
  local type3 = {}
  local count1 = 1
  local count2 = 1
  local count3 = 1
  
  local myGuildBase = Guild:Instance():getSelfGuildBase()
  local guildFlagId = Guild:Instance():getTempFlagId()
  if myGuildBase ~= nil then
    guildFlagId = myGuildBase:getFlag()
  end
  
  local flagIcon,idx_1,idx_2,idx_3 = Guild:Instance():getFlagIconByInt(guildFlagId)
  for key, var in pairs(AllConfig.guild_flag) do
    var._id = key
  	if var.type == 1 then
  	 table.insert(type1,var)
  	 if idx_1 == key then
  	   count1 = #type1
  	 end
  	elseif var.type == 2 then
  	 table.insert(type2,var)
  	 if idx_2 == key then
       count2 = #type2
     end
  	elseif var.type == 3 then
  	 table.insert(type3,var)
  	 if idx_3 == key then
       count3 = #type3
     end
  	end
  end
  
  self.label1:setString(type1[count1].name)
  self.label2:setString(type2[count2].name)
  self.label3:setString(type3[count3].name)
  
  local updateFlagId = function()
    local totalInt = string.format("%02d",type1[count1]._id)..string.format("%02d",type2[count2]._id)..string.format("%02d",type3[count3]._id)
--    print(string.sub(totalInt,1,2))
--    print(string.sub(totalInt,3,4))
--    print(string.sub(totalInt,5,6))
    totalInt = toint(totalInt)
    print(totalInt)
    print(string.format("%06d",totalInt))
    
    self.nodeFlagAll:removeAllChildrenWithCleanup(true)
    local flagIcon = Guild:Instance():getFlagIconByInt(totalInt)
    flagIcon:setScale(0.8)
    self.nodeFlagAll:addChild(flagIcon)
    self._flag = totalInt
  end
  
  updateFlagId()
  
  local function selectChangeHandler(_,target)
    if target:getTag() == 1 then
      count1 = count1 - 1
      if count1 < 1 then
        count1 = #type1
      end
      self.label1:setString(type1[count1].name)
    elseif target:getTag() == 2 then
      count1 = count1 + 1
      if count1 > #type1 then
        count1 = 1
      end
      self.label1:setString(type1[count1].name)
    elseif target:getTag() == 3 then
      count2 = count2 - 1
      if count2 < 1 then
        count2 = #type2
      end
      self.label2:setString(type2[count2].name)
    elseif target:getTag() == 4 then
      count2 = count2 + 1
      if count2 > #type2 then
        count2 = 1
      end
      self.label2:setString(type2[count2].name)
    elseif target:getTag() == 5 then
      count3 = count3 - 1
      if count3 < 1 then
        count3 = #type3
      end
      self.label3:setString(type3[count3].name)
    elseif target:getTag() == 6 then
      count3 = count3 + 1
      if count3 > #type3 then
        count3 = 1
      end
      self.label3:setString(type3[count3].name)
    end
    
    updateFlagId()
  end
  
  for key, btn in pairs(selectBtns) do
  	btn:registerScriptTapHandler(selectChangeHandler)
  end
  self.menuBtns:setTouchPriority(-256)
  self:setTouchEnabled(true)
  self:addTouchEventListener(function() return true end,false, -256, true)
end

function GuildFlagSettingsView:setFlagHandler()
  Guild:Instance():setTempFlagId(self._flag)

  local myGuildBase = Guild:Instance():getSelfGuildBase()
  if myGuildBase ~= nil and self._flag ~= nil then
    Guild:Instance():reqGuildChangeBaseC2S(myGuildBase:getNotice(),self._flag,myGuildBase:getApplyLevel()) --guild_notice,guild_flag,apply_level
  end
  
  if self:getDelegate() ~= nil then
    self:getDelegate():updateView()
  end
  
  self:removeFromParentAndCleanup(true)
end

function GuildFlagSettingsView:closeHandler()
  self:removeFromParentAndCleanup(true)
end


return GuildFlagSettingsView