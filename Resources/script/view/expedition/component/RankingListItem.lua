RankingListItem = class("RankingListItem",BaseView)

function RankingListItem:ctor(data)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("isSelectedHightLight","CCScale9Sprite")
  pkg:addProperty("lablePlayerName","CCLabelTTF")
  pkg:addProperty("lableLevel","CCLabelBMFont")
  pkg:addProperty("labelPreLevel","CCLabelTTF")
  pkg:addProperty("lablePreWinTimes","CCLabelTTF")
  pkg:addProperty("lableWinTimes","CCLabelTTF")
  pkg:addProperty("lableRanking","CCLabelBMFont")
  pkg:addProperty("spriteRankingFirst","CCSprite")
  pkg:addProperty("spriteRankingSecond","CCSprite")
  pkg:addProperty("spriteRankingThird","CCSprite")
  pkg:addProperty("nodePreviewContainer","CCNode")
  pkg:addProperty("btnChallenge","CCControlButton")
  pkg:addFunc("challengeHandler",RankingListItem.challengeHandler)
  local layer,owner = ccbHelper.load("ExpeditionRankingListItem.ccbi","RankingListItemCCB","CCLayer",pkg)
  self:addChild(layer)
  self.isSelectedHightLight:setVisible(false)
  self.spriteRankingFirst:setVisible(false)
  self.spriteRankingSecond:setVisible(false)
  self.spriteRankingThird:setVisible(false)
  self:setData(data)
  
  self.labelPreLevel:setString(_tr("pre_level_str"))
  self.lablePreWinTimes:setString(_tr("battle_max_win"))
  
  -- don't show btnChallenge on self player list
  if data:getPlayerId() == GameData:Instance():getExpeditionInstance():getSelfPvpBaseData():getPlayerId() then
     self.btnChallenge:setVisible(false)
  end
  self.btnChallenge:setTouchPriority(-200)
end

function RankingListItem:setSelected(Selected)
  self._Selected = Selected
  if self._Selected == true then
  end
end

function RankingListItem:challengeHandler()
  self:getDelegate():checkPvpFight(self:getData():getPlayerId(),true)
end

------
--  Getter & Setter for
--      RankingListItem._PreWinTimesStr 
-----
function RankingListItem:setPreWinTimesStr(PreWinTimesStr)
	self._PreWinTimesStr = PreWinTimesStr
	self.lablePreWinTimes:setString(PreWinTimesStr)
end

function RankingListItem:getPreWinTimesStr()
	return self._PreWinTimesStr
end

function RankingListItem:setData(player)
  self._data = player
  if player == nil then
    self:setVisible(false)
    return
  end
  
  self:setVisible(true)
  
  local pName = "-"
  if player:getPlayerName() ~= nil then
     pName = player:getPlayerName()
  end
  self.lablePlayerName:setString(pName)
  
  local pLevel = "1"
  if player:getExp() ~= nil then
     pLevel = player:getExp()..""
  end
  self.lableLevel:setString(pLevel)
  
  local pNowKeepWin = "x0"
  
  if player:getKeepWin() ~= nil then
    pNowKeepWin = "x"..player:getKeepWin()..""
  end
  self.lableWinTimes:setString(pNowKeepWin)
  
  if player:getScore() ~= nil then
    self:setRankLabel(player:getScore().."")
  end
  
  self.nodePreviewContainer:removeAllChildrenWithCleanup(true)
  if player:getHeadId() ~= nil then
     local headIcon = nil
     if player:getHeadId() > 1 then
        headIcon = _res(player:getHeadId())
     else
        headIcon = _res(3012502)
     end
     if headIcon ~= nil then
        headIcon:setScale(0.575)
        self.nodePreviewContainer:addChild(headIcon)
     end
     
  end
  
end

function RankingListItem:getData()
  return self._data
end


function RankingListItem:setRank(rank)
  self._rank = rank
  self.spriteRankingFirst:setVisible(false)
  self.spriteRankingSecond:setVisible(false)
  self.spriteRankingThird:setVisible(false)
  if rank == 1 then
     self.spriteRankingFirst:setVisible(true)
  elseif rank == 2 then
     self.spriteRankingSecond:setVisible(true)
  elseif rank == 3 then
     self.spriteRankingThird:setVisible(true)
  end
  self.lableRanking:setString(_tr("ranking%{rank}",{rank = self._rank}))
end

function RankingListItem:getRank()
  return self._rank
end

function RankingListItem:setRankLabel(RankLabel)
  if RankLabel ~= nil then
  	self._RankLabel = RankLabel
  	self.lableRanking:setString(self._RankLabel.."")
  end
	
end

------
--  Getter & Setter for
--      RankingListItem._MaxKeepWinLabel 
-----
function RankingListItem:setMaxKeepWinLabel(MaxKeepWinLabel)
	self._MaxKeepWinLabel = MaxKeepWinLabel
	self.lableWinTimes:setString(MaxKeepWinLabel)
end

function RankingListItem:getMaxKeepWinLabel()
	return self._MaxKeepWinLabel
end

function RankingListItem:getRankLabel()
	return self._RankLabel
end


function RankingListItem:getSelected()
  return self._Selected
end

return RankingListItem