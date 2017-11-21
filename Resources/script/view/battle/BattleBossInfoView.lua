require("model.battle.BattleBoss")
require("model.battle.Battle")
require("view.battle.BattleCardDamageView")

BattleBossInfoView = class("BattleBossInfoView",function()
  return display.newNode()
end)

function BattleBossInfoView:ctor(battle)
  self:setNodeEventEnabled(true)
  -- hp bar
  local pos = ccp(0,20)
  local sptHpBarBg = _res(3025004)
  self:addChild(sptHpBarBg,3)
  sptHpBarBg:setPosition(pos)
  pos.x = pos.x - 65
  local sptHpBar = _res(3025005)
  self:addChild(sptHpBar,3)
  sptHpBar:setPosition(pos)
  sptHpBar:setAnchorPoint(ccp(0.0,0.5))
  self:setScaleX(2)
  self:setScaleY(1.25)
  self._sptHpBar = sptHpBar
  
  self._boss = battle:getBoss()
  --self._totalHp = battle:getBossFromActivity():getTotalHp()
  --print("BossHP:",self._boss:getHp(),self._boss:getMaxHp())
  --print(battle:getBossFromActivity():getHp(),battle:getBossFromActivity():getTotalHp())
  --assert(false)
  self:updateView()
end

function BattleBossInfoView:updateView()
  
  local percent = (self._boss:getHp()/self._boss:getMaxHp())
  printf("percent:%f,hp:%f,max hp:%f",percent,self._boss:getHp(),self._boss:getMaxHp())
  self._sptHpBar:setScaleX(percent)
end

