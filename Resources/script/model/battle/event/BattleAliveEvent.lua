require("model.battle.event.BattleBaseEvent")

BattleAliveEvent = class("BattleAliveEvent",BattleBaseEvent)

function BattleAliveEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("CardAliveEvent",infomation))
end

function BattleAliveEvent:execute(battle,battleView)
  printf("BattleAliveEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    local card = battle:getCardByIndex(info.card_index)
    local cardView = battleView:getCardByIndex(info.card_index)
    cardView:execAlivekEvent(battle,battleView,info)
    print(card:getIsPrimary(),info.canRevive,info.state,info.isChangeGroup)
    
    if card:getIsPrimary() == true 
    and info.canRevive == false 
    and info.state == "CardAliveStateDead" 
    and info.isDownGroupAngry == true
    then
      battleView:showAngryLow(card:getOriginalGroup())
    end
    
    if info.isChangeGroup == true then
      if card:getIsPrimary() == true then
         battleView:showAngryLow(card:getOriginalGroup())
      end
      --[[local lastGroup = card:getGroup()
      print("lastGroup:",lastGroup,"changedGroup:",info.changedGroup)
      assert(lastGroup ~= info.changedGroup)
      card:setGroup(info.changedGroup)
      cardView:setGroupView(card:getGroup())]]
    end
   
    if info.isGhost == 1 then
      cardView:showAsGhost()
    end
  else
    printf("battle has been canceled.")
  end

end
