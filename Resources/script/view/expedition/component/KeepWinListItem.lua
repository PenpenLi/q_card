KeepWinListItem = class("KeepWinListItem",BaseView)
function KeepWinListItem:ctor(data,rank)
  local pkg = ccbRegisterPkg.new(self)
  --pkg:addProperty("isSelectedHightLight","CCScale9Sprite")
  pkg:addProperty("lablePlayerName","CCLabelTTF")
  pkg:addProperty("lableLevel","CCLabelBMFont")
  pkg:addProperty("lablePreWinTimes","CCLabelTTF")
  pkg:addProperty("lablePreLevel","CCLabelTTF")
  pkg:addProperty("labelPreCost","CCLabelTTF")
  pkg:addProperty("lableWinTimes","CCLabelTTF")
  pkg:addProperty("lableRanking","CCLabelTTF")
  pkg:addProperty("labelStopKeepWinAward","CCLabelTTF")
--  pkg:addProperty("spriteRankingFirst","CCSprite")
--  pkg:addProperty("spriteRankingSecond","CCSprite")
--  pkg:addProperty("spriteRankingThird","CCSprite")
  pkg:addProperty("nodePreviewContainer","CCNode")
  pkg:addProperty("nodeChallenge","CCNode")
  pkg:addProperty("btnChallenge","CCControlButton")
  pkg:addProperty("labelCostToken","CCLabelTTF")
  pkg:addProperty("nodeProtect","CCLabelTTF")
  pkg:addProperty("lablePreWinAward","CCLabelTTF")
  pkg:addProperty("labelProtectInfo","CCLabelTTF")
  
  
  
  
  pkg:addFunc("challengeHandler",KeepWinListItem.challengeHandler)
  local layer,owner = ccbHelper.load("ExpeditionKeepWinListItem.ccbi","KeepWinListItemCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.lablePreWinAward:setString(_tr("stop_keep_win_award"))
  self.lablePreWinTimes:setString(_tr("battle_cur_win_times"))
  self.lablePreLevel:setString(_tr("pre_level_str"))
  self.labelPreCost:setString(_tr("pre_cost_desc"))
  self.labelProtectInfo:setString(_tr("battle_protecting"))
  
  self.btnChallenge:setTouchPriority(-200)
  
  self:setRank(rank)
  
  --self.isSelectedHightLight:setVisible(false)
--  self.spriteRankingFirst:setVisible(false)
--  self.spriteRankingSecond:setVisible(false)
--  self.spriteRankingThird:setVisible(false)
  self.nodeProtect:setVisible(false)
  self:setData(data)
  
  self.labelCostToken:setString("x"..AllConfig.battleinitdata[1].challenge)
  
  -- don't show btnChallenge on self player list
  if data:getPlayerId() == GameData:Instance():getExpeditionInstance():getSelfPvpBaseData():getPlayerId() then
     self.nodeChallenge:setVisible(false)
  else
     local currentTime = Clock:Instance():getCurServerUtcTime()
     if data:getProtectTime() > currentTime then
        self.nodeChallenge:setVisible(false)
        self.nodeProtect:setVisible(true)
     else
        if rank > 3 then
          if self._data:getKeepWin() < 10 then
            self.nodeChallenge:setVisible(false)
          end
        else
          self.nodeChallenge:setVisible(true)
        end
     end
  end
end

function KeepWinListItem:challengeHandler()
  local currentTime = Clock:Instance():getCurServerUtcTime()
  if GameData:Instance():getExpeditionInstance():getSelfPvpBaseData():getProtectTime() > currentTime then
     local pop = PopupView:createTextPopup(_tr("challenge_protect_will_invalid"), function() 
        self:getDelegate():checkPvpFight(self:getData():getPlayerId(),true)
        return
     end)
     GameData:Instance():getCurrentScene():addChildView(pop)
     return
  end
  self:getDelegate():checkPvpFight(self:getData():getPlayerId(),ExpeditionConfig.challengeTypeRank)
end

function KeepWinListItem:setData(player)
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
  
  local stopKeepWin = player:getKeepWin()
  local stopKeepWinCoin = 0
  for i = 1, #AllConfig.stopwinbonus do
     if stopKeepWin >= AllConfig.stopwinbonus[i].min_win and stopKeepWin <= AllConfig.stopwinbonus[i].max_win then
        for key, drop in pairs(AllConfig.stopwinbonus[i].bonus) do
          local type = drop.array[1]
          if type == 4 then
             local num = drop.array[3]
             stopKeepWinCoin = num
             break
          end
        end
        break
     end
  end
  
  self.labelStopKeepWinAward:setString(stopKeepWinCoin.."")
  
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

function KeepWinListItem:getData()
  return self._data
end

function KeepWinListItem:setRank(rank)
  self._rank = rank
--  self.spriteRankingFirst:setVisible(false)
--  self.spriteRankingSecond:setVisible(false)
--  self.spriteRankingThird:setVisible(false)
--  if rank == 1 then
--     self.spriteRankingFirst:setVisible(true)
--  elseif rank == 2 then
--     self.spriteRankingSecond:setVisible(true)
--  elseif rank == 3 then
--     self.spriteRankingThird:setVisible(true)
--  end
  --self.lableRanking:setString(_tr("ranking%{rank}",{rank = self._rank}))
  
  
  
  self.lableRanking:setString(self._rank.."")
end

function KeepWinListItem:getRank()
  return self._rank
end


return KeepWinListItem