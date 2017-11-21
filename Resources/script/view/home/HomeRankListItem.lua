
require("view.BaseView")
require("model.pvp_rank_match.RankMatchPlayer")

HomeRankListItem = class("HomeRankListItem", BaseView)

local function isRobot(pid) 
    return pid >= 0x7FFFFFFF  -  3000
end
  
function HomeRankListItem:ctor()
  HomeRankListItem.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("onFightDetail",HomeRankListItem.onFightDetail)
  pkg:addProperty("node_card","CCNode") 
  pkg:addProperty("label_rank","CCLabelBMFont") 
  pkg:addProperty("label_name","CCLabelTTF") 
  pkg:addProperty("label_level","CCLabelTTF") 
  pkg:addProperty("sprite_rank","CCSprite")
  pkg:addProperty("menu_detail","CCMenu")


  local layer,owner = ccbHelper.load("HomeRankListItem.ccbi","HomeRankListItemCCB","CCLayer",pkg)
  self:addChild(layer)
end

function HomeRankListItem:onEnter()
  self:updateInfos()
end

function HomeRankListItem:onExit()

end

function HomeRankListItem:setData(playerInfo)
  self._playerInfo = playerInfo 
end 

function HomeRankListItem:updateInfos()
  if self._playerInfo == nil then 
    return 
  end 

  --set rank number 
  if self._playerInfo.rank <= 3 then 
    self.sprite_rank:setVisible(true)
    self.label_rank:setVisible(false) 
    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(string.format("home_rank_%d.png", self._playerInfo.rank))
    self.sprite_rank:setDisplayFrame(frame)
  else 
    self.sprite_rank:setVisible(false)
    self.label_rank:setVisible(true)
    self.label_rank:setString(string.format("%d", self._playerInfo.rank))
  end 

  --set icon 
  if self._playerInfo.avatar == 1 then 
    self._playerInfo.avatar = 120502 
  end 
  local cardConfigId = self._playerInfo.avatar*100+1

  
  if AllConfig.unit[cardConfigId] ~= nil then 
    local resId = AllConfig.unit[cardConfigId].unit_head_pic
    local icon = _res(resId)
    if icon ~= nil then 
      icon:setScale(85/icon:getContentSize().width)
      self.node_card:addChild(icon)
    end 
  end 
  
  self:setDetailBtnVisible(not isRobot(self._playerInfo.id))

  --name & level 
  self.label_name:setString(self._playerInfo.name)
  self.label_level:setString("Lv."..self._playerInfo.level)
end 


function HomeRankListItem:onFightDetail()
  echo("===onFightDetail")
  
  if self._playerInfo == nil or self._playerInfo.id == nil then
    return
  end
  
 
  
  if isRobot(self._playerInfo.id) then
    return
  end
  
  local resultHandler = function(action,msgId,msg)
    printf("resultHandler")
    
    --[[
    BattleFormation.BATTLE_INDEX_NORMAL_1
    BattleFormation.BATTLE_INDEX_NORMAL_2
    BattleFormation.BATTLE_INDEX_NORMAL_3
    BattleFormation.BATTLE_INDEX_PVP
    BattleFormation.BATTLE_INDEX_RANK_MATCH
    BattleFormation.BATTLE_INDEX_BABLE
    ]]
    
    local targetPlayer = RankMatchPlayer.new()
    local battleFormationType = BattleFormation.BATTLE_INDEX_NORMAL_1
    if self:getRankType() == RankEnum.Level then
      battleFormationType = BattleFormation.BATTLE_INDEX_NORMAL_1
    elseif self:getRankType() == RankEnum.Match then
      battleFormationType = BattleFormation.BATTLE_INDEX_RANK_MATCH
    end
    
    targetPlayer:parse(msg,battleFormationType)
    local detailView = PvpRankMatchPlayerDetailView.new(targetPlayer,true)
    GameData:Instance():getCurrentScene():addChildView(detailView)
    detailView:setPosition(display.cx,display.cy)
  end
  
  local player = GameData:Instance():getCurrentPlayer()
  player:reqQueryPlayerShowC2S(self._playerInfo.id,resultHandler)
  
end 

-- rankType: RankEnum.Level / RankEnum.Match
function HomeRankListItem:setRankType(rankType)
  self._rankType = rankType
end 

function HomeRankListItem:getRankType()
  return self._rankType
end 

function HomeRankListItem:setDetailBtnVisible(isVisible)
  self.menu_detail:setVisible(isVisible)
end 
