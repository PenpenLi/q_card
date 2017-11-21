GuildDonateView = class("GuildDonateView",BaseView)
local touchPriority = -256
function GuildDonateView:ctor()
  GuildDonateView.super.ctor(self)
  
  --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,190), display.width, display.height)
  self:addChild(layerColor)
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("spriteSelected1","CCSprite")
  pkg:addProperty("spriteSelected2","CCSprite")
  pkg:addProperty("spriteSelected3","CCSprite")
  pkg:addProperty("spriteCoin","CCSprite")
  pkg:addProperty("spriteMoney1","CCSprite")
  pkg:addProperty("spriteMoney2","CCSprite")

  pkg:addProperty("labelCoin","CCLabelTTF")
  pkg:addProperty("labelMoney1","CCLabelTTF")
  pkg:addProperty("labelMoney2","CCLabelTTF")
  
  pkg:addProperty("labelExp","CCLabelTTF")
  pkg:addProperty("labelPoint","CCLabelTTF")
  
  
  pkg:addProperty("labelCurrentHave","CCLabelTTF")
  pkg:addProperty("labelPlayerCoin","CCLabelTTF")
  pkg:addProperty("labelPlayerMoney","CCLabelTTF")
  
  pkg:addProperty("labelGuildCoin","CCLabelTTF")
  pkg:addProperty("labelGuildMoney","CCLabelTTF")
  
  pkg:addProperty("closeMenu","CCMenu")
  pkg:addProperty("denoteMenu","CCMenu")
  pkg:addProperty("iconsMenu","CCMenu")
  

  pkg:addFunc("denoteHandler",GuildDonateView.denoteHandler)
  pkg:addFunc("denoteCoinHandler",GuildDonateView.denoteCoinHandler)
  pkg:addFunc("denoteMoney1Handler",GuildDonateView.denoteMoney1Handler)
  pkg:addFunc("denoteMoney2Handler",GuildDonateView.denoteMoney2Handler)
  pkg:addFunc("onCloseHandler",function() self:removeFromParentAndCleanup(true) end)
  
  
  local node,owner = ccbHelper.load("guild_noticeView.ccbi","guild_noticeView","CCLayer",pkg)
  self:addChild(node)
  
  self.labelCurrentHave:setString(_tr("current_have")..":")
  
  local coin = AllConfig.guild_donate[1].currency
  local coinPoint = AllConfig.guild_donate[1].point
  local coinGuildExp = AllConfig.guild_donate[1].exp
  self.labelCoin:setString(_tr("donate_%{count}_coin",{count = coin}))
  
  local money = AllConfig.guild_donate[2].currency
  local moneyPoint = AllConfig.guild_donate[2].point
  local moneyGuildExp = AllConfig.guild_donate[2].exp
  self.labelMoney1:setString(_tr("donate_%{count}_money",{count = money}))
  
  local money1 = AllConfig.guild_donate[3].currency
  local money1Point = AllConfig.guild_donate[3].point
  local money1GuildExp = AllConfig.guild_donate[3].exp
  self.labelMoney2:setString(_tr("donate_%{count}_money",{count = money1}))
  
  self._iconsSelect = {self.spriteSelected1,self.spriteSelected2,self.spriteSelected3}
  self:selectButtonByIdx(1)
  self:updateView()
  
  self:setTouchEnabled(true)
  self:addTouchEventListener(function() return true end,false, touchPriority, true)
  
  self.closeMenu:setTouchPriority(touchPriority)
  self.denoteMenu:setTouchPriority(touchPriority)
  self.iconsMenu:setTouchPriority(touchPriority)
end

function GuildDonateView:updateView()
  local player = GameData:Instance():getCurrentPlayer()
  self.labelPlayerCoin:setString(player:getCoin().."")
  self.labelPlayerMoney:setString(player:getMoney().."")
  self:selectButtonByIdx(self._selectedIdx)
end

function GuildDonateView:denoteHandler()
  local myGuildBase = Guild:Instance():getSelfGuildBase()
  local selfMember = myGuildBase:getMemberById(GameData:Instance():getCurrentPlayer():getId())
  local lastDonateTime = selfMember:getDonateTime()
  local curTime = Clock:Instance():getCurServerUtcTime() 
  local time = toint(os.date("%H",lastDonateTime))*3600+ toint(os.date("%M",lastDonateTime))*60+toint(os.date("%S",lastDonateTime))
  local DIFTimes = curTime - lastDonateTime 
  
  local canDonate = (time + DIFTimes > 86400)
  
  if canDonate ~= true then
    Toast:showString(GameData:Instance():getCurrentScene(),_tr("NEED_JOIN_TIME"), ccp(display.cx, display.cy))
    return
  end

  if self._selectedIdx == 1 then
    local coin = AllConfig.guild_donate[1].currency
    if GameData:Instance():getCurrentPlayer():getCoin() < coin then
      Toast:showString(GameData:Instance():getCurrentScene(),_tr("not enough coin"), ccp(display.cx, display.cy))
      return
    end
  elseif self._selectedIdx == 2 then
    local money = AllConfig.guild_donate[2].currency
    if GameData:Instance():getCurrentPlayer():getMoney() < money then
      GameData:Instance():notifyForPoorMoney()
      return
    end
  elseif self._selectedIdx == 3 then
    local money1 = AllConfig.guild_donate[3].currency
    if GameData:Instance():getCurrentPlayer():getMoney() < money1 then
      GameData:Instance():notifyForPoorMoney()
      return
    end
  end


  Guild:Instance():reqGuildDonateC2S(self._selectedIdx,self)
end

function GuildDonateView:selectButtonByIdx(idx)
  self:unSelectAllButtons()
  if idx == 1 then
    self.spriteSelected1:setVisible(true)
  elseif idx == 2 then
    self.spriteSelected2:setVisible(true)
  elseif idx == 3 then
    self.spriteSelected3:setVisible(true)
  end
  self._selectedIdx = idx
  self.labelExp:setString("+"..AllConfig.guild_donate[idx].exp)
  self.labelPoint:setString("+"..AllConfig.guild_donate[idx].point)
  self.labelGuildCoin:setString("+"..AllConfig.guild_donate[idx].coin)
  self.labelGuildMoney:setString("+"..AllConfig.guild_donate[idx].money)
end

function GuildDonateView:unSelectAllButtons()
  for key, select in pairs(self._iconsSelect) do
  	select:setVisible(false)
  end
end

function GuildDonateView:denoteCoinHandler()
  self:selectButtonByIdx(1)
end

function GuildDonateView:denoteMoney1Handler()
  self:selectButtonByIdx(2)
end

function GuildDonateView:denoteMoney2Handler()
  self:selectButtonByIdx(3)
end

return GuildDonateView