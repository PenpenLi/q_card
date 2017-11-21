PvpRankMatchPlayerDetailView = class("PvpRankMatchPlayerDetailView",function()
  return display.newLayer()
end)

function PvpRankMatchPlayerDetailView:ctor(player,isAlert)
  self:setNodeEventEnabled(true)
  if isAlert == true then
    self:setTouchEnabled(true)
    self:addTouchEventListener(function(event,x,y)
       if event == "began" then
         return true 
       elseif event == "ended" then
         self:removeFromParentAndCleanup(true)
       end
    end,false, -256, true)
  end
  self:setPlayer(player)
end

function PvpRankMatchPlayerDetailView:onEnter()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeHead","CCNode")
  pkg:addProperty("labelLevel","CCLabelBMFont")
  pkg:addProperty("nodeCards","CCNode")
  pkg:addProperty("labelFight","CCLabelTTF")
  pkg:addProperty("labelName","CCLabelTTF")
  pkg:addProperty("labelRank","CCLabelTTF")
  pkg:addProperty("labelWinTimes","CCLabelTTF")
  local layer,owner = ccbHelper.load("pvp_rank_match_player_info.ccbi","pvp_rank_match_player_info","CCNode",pkg)
  self:addChild(layer)
  self._ccbiLoaded = true
  
  self.nodeCards:setScale(0.6)
  
  self:updateView()
end

function PvpRankMatchPlayerDetailView:updateView()
  if self._ccbiLoaded ~= true then
    return
  end

  local player = self:getPlayer()
  if player == nil then
    return
  end
  
  self.nodeHead:removeAllChildrenWithCleanup(true)
  local head = _res(player:getHead())
  head:setScale(0.4)
  self.nodeHead:addChild(head)
  
  self.labelName:setString(player:getName())
  self.labelLevel:setString("Lv."..player:getLevel())
  self.labelFight:setString(_tr("fight_number_%{num}",{num = player:getFightNumber()}))
  self.labelRank:setString(_tr("rank_number%{num}",{num = player:getRank()}))
  self.labelWinTimes:setString(_tr("win_number%{num}",{num = player:getTotalWin()}))
  
  if player:getIsCommontype() == true then
    self.labelFight:setString("")
    self.labelRank:setString("")
    self.labelWinTimes:setString("")
  end
  
  self.nodeCards:removeAllChildrenWithCleanup(true)
  --[[message FightCardPosition{
  required int32 card = 1;
  required int32 pos = 2;
  optional int32 config = 3;
  optional int32 monster = 4;
  optional int32 level = 5;
  repeated Equipment equip = 6;
  }
  message FightCards{
    repeated FightCardPosition card_pos = 1;
  }]]
  
  local cards = player:getFightCards()
  
  --assert(#cards > 0,#cards)
  
  for key, cardInfo in pairs(cards) do
  	local cardHead = CardHeadView.new()
    self.nodeCards:addChild(cardHead)
    cardHead:setLvFadeEnabled(false)
    --cardHead:setLvVisible(false)
    --cardHead:enableClick(true)
    cardHead:setCardByConfigId(cardInfo.config)
    cardHead:setLvStr(cardInfo.level.."")
    if key > 4 then
     cardHead:setPositionX((key - 4)*cardHead:getContentSize().width - 285)
     cardHead:setPositionY(-cardHead:getContentSize().height/2)
    else
     cardHead:setPositionX(key*cardHead:getContentSize().width - 285)
     cardHead:setPositionY(cardHead:getContentSize().height/2)
    end
    
  end
end

------
--  Getter & Setter for
--      PvpRankMatchPlayerDetailView._Player 
-----
function PvpRankMatchPlayerDetailView:setPlayer(Player)
	self._Player = Player
	self:updateView()
end

function PvpRankMatchPlayerDetailView:getPlayer()
	return self._Player
end

function PvpRankMatchPlayerDetailView:onExit()
  
end

return PvpRankMatchPlayerDetailView