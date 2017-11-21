require("view.guild.GuildProposersView")
require("view.guild.GuildSettingsView")
require("view.guild.GuildNoticeSettingsView")
require("view.mail.MailPopup")
GuildMenusView = class("GuildMenusView",BaseView)
local touchPriority = -256
function GuildMenusView:ctor(menuType,data)
  GuildMenusView.super.ctor(self)
  
  self._data = data
  
  --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,190), display.width, display.height)
  self:addChild(layerColor)
  
  self:setTouchEnabled(true)
  self:addTouchEventListener(function() return true end,false, touchPriority, true)
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("bgSprite","CCScale9Sprite")
  pkg:addProperty("spriteTilte","CCSprite")
  pkg:addProperty("listContainer","CCNode")
  
  pkg:addProperty("btnClose","CCMenu")
  pkg:addFunc("closeHandler",GuildMenusView.closeHandler)
  
  local node,owner = ccbHelper.load("guild_menus.ccbi","guild_menus","CCLayer",pkg)
  self:addChild(node)
  
  self.btnClose:setTouchPriority(touchPriority)
  local menus = {}
  
  if menuType == 0 then
    local openApplyListHandler = function()
      local guildProposersView = GuildProposersView.new()
      GameData:Instance():getCurrentScene():addChildView(guildProposersView)
    end
    
    
    local function mailHandler()
      local pop = MailPopup.new(2,-256)
      pop:setDelegate(self:getDelegate())
      pop:showGuildWriteView(_tr("all_guild_members"))
      GameData:Instance():getCurrentScene():addChildView(pop)
    end
    
    local function editGuildNoticeHandler()
      local guildNoticeSettingsView = GuildNoticeSettingsView.new()
      GameData:Instance():getCurrentScene():addChildView(guildNoticeSettingsView)
    end
    
    local function guildSettingHandler()
      local guildSettingsView = GuildSettingsView.new()
      GameData:Instance():getCurrentScene():addChildView(guildSettingsView)
    end
    
    local selfMember = Guild:Instance():getSelfGuildBase():getMemberById(GameData:Instance():getCurrentPlayer():getId())
  
    local meun1 = {"#guild_btn_ruhuishenqing.png","#guild_btn_ruhuishenqing_1.png",openApplyListHandler}
    local meun2 = {"#guild_btn_xiugaigonggao.png","#guild_btn_xiugaigonggao_1.png",editGuildNoticeHandler}
    local meun3 = {"#guild_btn_gonghuishezhi.png","#guild_btn_gonghuishezhi_1.png",guildSettingHandler}
    local meun4 = {"#guild_btn_quanyuanyoujian.png","#guild_btn_quanyuanyoujian_1.png",mailHandler}
    menus = {meun1,meun2,meun3}
    if selfMember:getJob() == GuildConfig.MemberTypeChairman then
      table.insert(menus,meun4)
    end
  else
    local posX,posY = self.spriteTilte:getPosition()
     
    local title = display.newSprite("#guild_chengyuanpeizhi.png")
    self.spriteTilte:getParent():addChild(title)
    title:setPosition(ccp(posX,posY))
   
    self.spriteTilte:removeFromParentAndCleanup(true)
  
    local memberInfoHandler = function()
      --Guild:Instance():reqQueryPlayerShowC2S(self._data:getPlayerId())
      
      local callback = function(action,msgId,msg)
        printf("msg.pvpbase.maxSource:"..msg.pvpbase.maxSource)
        printf("msg.pvpbase.source:"..msg.pvpbase.source)
        local friendData = FriendData.new()
        friendData:setFriendId(msg.id)
        friendData:setName(msg.nick_name)
        friendData:setLevel(msg.common.level)
        friendData:setAvatar(msg.common.avatar)
        friendData:setVipLevel(msg.common.vip_level)
        friendData:setAchievement(toint(msg.achievement_point))
        friendData:setScore(msg.pvpbase.source or 0)
        friendData:setMaxScore(msg.pvpbase.maxSource or 0)
        friendData:setRankId(msg.pvpbase.rank)
        
        local pop = PopupView:createFriendInfoPopup(friendData,function()  end,true)
        GameData:Instance():getCurrentScene():addChildView(pop)
      end
      GameData:Instance():getCurrentPlayer():reqQueryPlayerShowC2S(self._data:getPlayerId(),callback)
    end
    
    local beFriendHandler = function()
    
    end
    
    local moveOutHandler = function()
      local pop = PopupView:createTextPopup(_tr("make_sure_move_out%{name}",{name = self._data:getName()}), function()
        Guild:Instance():reqGuildChangeMemberC2S(self._data:getPlayerId(), GuildConfig.ActionKick,0)
        self:removeFromParentAndCleanup(true)
      end)
      GameData:Instance():getCurrentScene():addChildView(pop)
    end
    
    local beNormalMember = function()
      --Guild:reqGuildChangeMemberC2S(playerId,action,args,viewDelegate)
      --[[
      CHAIRMAN  = 1;      //会长
      VICE_CHAIRMAN = 2;    //副会长
      ELITE = 3;        //精英
      ORDINARY = 4; 
      ]]
      
      local pop = PopupView:createTextPopup(_tr("make_sure_change%{name}to_normal",{name = self._data:getName()}), function()
        Guild:Instance():reqGuildChangeMemberC2S(self._data:getPlayerId(),GuildConfig.ActionChange,4)
        self:removeFromParentAndCleanup(true)
      end)
      GameData:Instance():getCurrentScene():addChildView(pop)
    end
    
    local beManager = function()
       local pop = PopupView:createTextPopup(_tr("make_sure_change%{name}to_vice_chairman",{name = self._data:getName()}), function()
        Guild:Instance():reqGuildChangeMemberC2S(self._data:getPlayerId(),GuildConfig.ActionChange,2)
        self:removeFromParentAndCleanup(true)
      end)
      GameData:Instance():getCurrentScene():addChildView(pop)
    end
    
    local exitGuildHandler = function()
      local pop = PopupView:createTextPopup(_tr("make_sure_exit_guild%{time}",{time = AllConfig.guild[1].reapply_time}), function()
        Guild:Instance():reqGuildQuitC2S(self)
      end)
      GameData:Instance():getCurrentScene():addChildView(pop)
    end
    
    local turnChairmanHandler = function()
      local pop = PopupView:createTextPopup(_tr("make_sure_change%{name}to_chairman",{name = self._data:getName()}), function()
        Guild:Instance():reqGuildChangeMemberC2S(self._data:getPlayerId(),GuildConfig.ActionChange,1)
        self:removeFromParentAndCleanup(true)
      end)
      GameData:Instance():getCurrentScene():addChildView(pop)
    end
    
    local meun1 = {"#guild_btn_chengyuanxinxi.png","#guild_btn_chengyuanxinxi_1.png",memberInfoHandler}
    local meun2 = {"#guild_btn_tianjiahaoyou.png","#guild_btn_tianjiahaoyou_1.png",beFriendHandler}
    local meun3 = {"#guild_btn_tichugonghui.png","#guild_btn_tichugonghui_1.png",moveOutHandler}
    local meun4 = {"#guild_btn_renmingfuhuizhang.png","#guild_btn_renmingfuhuizhang_1.png",beManager}
    local meun5 = {"#guild_btn_jiechufuhuizhang.png","#guild_btn_jiechufuhuizhang_1.png",beNormalMember}
    local meun6 = {"#guild_btn_exit_guild.png","#guild_btn_exit_guild1.png",exitGuildHandler}
    local meun7 = {"#guild_zhuanranghuizhang_1.png","#guild_zhuanranghuizhang.png",turnChairmanHandler}
    local selfMember = Guild:Instance():getSelfGuildBase():getMemberById(GameData:Instance():getCurrentPlayer():getId())
    local isManager = Guild:Instance():getIsManagerByMember(selfMember)
    menus = {meun1}
    
    if isManager == true then
      if Guild:Instance():getIsManagerByMember(self._data) ~= true then
        if selfMember:getJob() == GuildConfig.MemberTypeChairman then
          table.insert(menus,meun4)
        end
        table.insert(menus,meun3)
      else
        if self._data:getJob() ~= GuildConfig.MemberTypeChairman
        and selfMember:getJob() == GuildConfig.MemberTypeChairman
        then
          table.insert(menus,meun5)
        end
      end
    end
    
    if selfMember:getJob() == GuildConfig.MemberTypeChairman then
      if selfMember:getPlayerId() ~= self._data:getPlayerId() then
        table.insert(menus,meun7)
      end
    end
    
    
    if selfMember:getPlayerId() == self._data:getPlayerId() then
      table.insert(menus,meun6)
    end
  end
  
  self:buildTableView(menus)
 
end

function GuildMenusView:buildTableView(menus)
  
  local cellWidth = 535
  local cellHeight = 100
  local function tableCellTouched(table,cell)
      printf("cell touched at index: " .. cell:getIdx())
   end
  
   local function cellSizeForTable(table,idx) 
      return cellHeight,cellWidth
   end
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil ~= cell then
        cell:removeFromParentAndCleanup(true)
      end
      
      local menuIdx = idx + 1
      cell = CCTableViewCell:new()
      local item = UIHelper.ccMenuWithSprite(display.newSprite(menus[menuIdx][1]),display.newSprite(menus[menuIdx][2]),display.newSprite(menus[menuIdx][2]),menus[menuIdx][3])
      item:setTouchPriority(touchPriority)
      cell:addChild(item)
      item:setPosition(ccp(cellWidth*0.5 - 50,cellHeight*0.5))
      cell:setIdx(idx)
      return cell
  end
   
  local function numberOfCellsInTableView(val)
     return #menus
  end
  local mSize = self.listContainer:getContentSize()
  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  self.listContainer:addChild(tableView)
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  --tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:setTouchPriority(touchPriority)
  tableView:reloadData()
  self.tableView = tableView
end


function GuildMenusView:closeHandler()
  self:removeFromParentAndCleanup(true)
end

------
--  Getter & Setter for
--      GuildMenusView._TitleWithSprite 
-----
function GuildMenusView:setTitleWithSprite(TitleWithSprite)
	self._TitleWithSprite = TitleWithSprite
end

function GuildMenusView:getTitleWithSprite()
	return self._TitleWithSprite
end

return GuildMenusView