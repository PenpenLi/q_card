PvpRankMatchReportListItem = class("PvpRankMatchReportListItem",function()
  return display.newNode()
end)
function PvpRankMatchReportListItem:ctor(rankMatchReport)
  self:setNodeEventEnabled(true)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("spriteBg","CCSprite")
  pkg:addProperty("spriteLose","CCSprite")
  pkg:addProperty("spriteWin","CCSprite")
  pkg:addProperty("spriteUp","CCSprite")
  pkg:addProperty("spriteDown","CCSprite")
  
  pkg:addProperty("nodeHead","CCNode")
  
  pkg:addProperty("btnReview","CCMenuItemImage")
  
  pkg:addProperty("lableScore","CCLabelTTF")
  pkg:addProperty("labelName","CCLabelTTF")
  pkg:addProperty("labelTime","CCLabelTTF")
  
  pkg:addFunc("reviewHandler",PvpRankMatchReportListItem.reviewHandler)
  pkg:addFunc("shareHandler",PvpRankMatchReportListItem.shareHandler)
  
  

  local layer,owner = ccbHelper.load("pvp_rank_match_list.ccbi","pvp_rank_match_list","CCNode",pkg)
  self:addChild(layer)
  
  local size = self:getContentSize()
  layer:setPosition(size.width/2,size.height/2)
  
  self:setData(rankMatchReport)
end

function PvpRankMatchReportListItem:shareHandler()
  BattleReportShare:Instance():reqShareBattleReportShare(self:getData():getId(),"PVP_RANK_MATCH")
end

function PvpRankMatchReportListItem:reviewHandler()
  local contentOffset = self:getTableView():getContentOffset()
  PvpRankMatch:Instance():setReportListContentOffset(contentOffset)
  BattleReportShare:Instance():reqBattleReview(self:getData():getReviewId(),"PVP_RANK_MATCH")
end

function PvpRankMatchReportListItem:getContentSize()
	return self.spriteBg:getContentSize()
end

------
--  Getter & Setter for
--      PvpRankMatchReportListItem._TableView 
-----
function PvpRankMatchReportListItem:setTableView(TableView)
	self._TableView = TableView
end

function PvpRankMatchReportListItem:getTableView()
	return self._TableView
end

------
--  Getter & Setter for
--      PvpRankMatchView._Data 
-----
function PvpRankMatchReportListItem:setData(Data)
  self._Data = Data
  if Data == nil then
    return
  end
  self:update()
end


function PvpRankMatchReportListItem:getData()
  return self._Data
end

function PvpRankMatchReportListItem:update()
    
  --self is attacker
  if self:getIsSelfIsAttacker() == true then
    self.labelName:setString(_tr("you_challenge%{name}",{name = self._Data:getDefender():getName()}))
  else
    self.labelName:setString(_tr("%{name}_challenge_you",{name = self._Data:getAttacker():getName()}))
  end
  
  self.spriteLose:setVisible(false)
  self.spriteWin:setVisible(false)
  self.spriteUp:setVisible(false)
  self.spriteDown:setVisible(false)
  
  self.nodeHead:removeAllChildrenWithCleanup(true)
  local resId = 0
  if self:getIsSelfIsAttacker() == true then
    resId = self._Data:getDefender():getHead()
  else
    resId = self._Data:getAttacker():getHead()
  end
  if resId > 0 then
    local head = _res(resId)
    self.nodeHead:addChild(head)
    head:setScale(0.5)
  end
  
  
  local result = self._Data:getResult()
  assert(result > 0,"unexpected result:"..result)
  
  if self:getIsSelfIsAttacker() == true then
    if result == 2 or result == 3 or result == 4 then
      self.spriteWin:setVisible(true)
      self.spriteUp:setVisible(true)
      self.lableScore:setColor(sgGREEN)
      self.lableScore:setString(math.abs(self._Data:getAttackerRank() - self._Data:getDefenderRank()).."")
    else
      self.spriteLose:setVisible(true)
      self.spriteDown:setVisible(true)
      self.lableScore:setColor(sgRED)
      self.lableScore:setString("")
      self.spriteUp:setVisible(false)
      self.spriteDown:setVisible(false)
    end
  else
    if result == 5 or result == 6 or result == 7 then
      self.spriteWin:setVisible(true)
      self.spriteUp:setVisible(true)
      self.lableScore:setColor(sgGREEN)
      self.lableScore:setString("")
      self.spriteUp:setVisible(false)
      self.spriteDown:setVisible(false)

    else
      self.spriteLose:setVisible(true)
      self.spriteDown:setVisible(true)
      self.lableScore:setColor(sgRED)
      self.lableScore:setString(math.abs(self._Data:getAttackerRank() - self._Data:getDefenderRank()).."")
    end
  
  end
  
  
--  if result == 2 or result == 3 or result == 4 then
--    self.spriteWin:setVisible(true)
--    self.spriteUp:setVisible(true)
--    self.lableScore:setColor(sgGREEN)
--    if self:getIsSelfIsAttacker() == true then
--      self.lableScore:setString(math.abs(self._Data:getAttackerRank() - self._Data:getDefenderRank()).."")
--    else
--      self.lableScore:setString("")
--      self.spriteUp:setVisible(false)
--      self.spriteDown:setVisible(false)
--    end
--  
--  else
--    self.spriteLose:setVisible(true)
--    self.spriteDown:setVisible(true)
--    self.lableScore:setColor(sgRED)
--    if self:getIsSelfIsAttacker() == true then
--      self.lableScore:setString("")
--      self.spriteUp:setVisible(false)
--      self.spriteDown:setVisible(false)
--    else
--      self.lableScore:setString(math.abs(self._Data:getAttackerRank() - self._Data:getDefenderRank()).."")
--    end
--  end
  
  
  if self._Data:getFightTime() ~= nil then
    local nowTime = Clock:Instance():getCurServerUtcTime()
    local reportTime = self._Data:getFightTime()
    local miniutes = math.ceil((nowTime - self._Data:getFightTime())/60)
    local timeShowStr = ""
    if miniutes < 60 then
      timeShowStr = _tr("%{miniute}ago",{miniute = miniutes})
    elseif miniutes >= 60 and miniutes < 1440 then
      timeShowStr =  _tr("%{hour}hour_ago",{hour = math.floor(miniutes/60)})
    else
      timeShowStr = _tr("%{day}day_ago",{day = math.floor(miniutes/1440)})
    end
    self.labelTime:setString(timeShowStr)
  end
  
      
  if self:getData():getReviewId() > 0 then
     self.btnReview:setEnabled(true)
  else
     self.btnReview:setEnabled(false)
  end
  
end

function PvpRankMatchReportListItem:getIsSelfIsAttacker()
	return self._Data:getAttacker():getId() == GameData:Instance():getCurrentPlayer():getId()
end

return PvpRankMatchReportListItem