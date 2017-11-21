require("model.battle.event.BattleBaseEvent")

BattleCardTurnEvent = class("BattleCardTurnEvent",BattleBaseEvent)

function BattleCardTurnEvent:ctor(type,infomation)
  self:setType(type)
  self:setInfo(PbRegist.unpackStruct("CardTurnEvent",infomation))
end

function BattleCardTurnEvent:execute(battle,battleView)
  printf("BattleCardTurnEvent:execute")
  if self:checkContinueEvent(battle) == true then
    local info = self:getInfo()
    dump(info)
    -- update datas
    local targetCard = battle:getCardByIndex(info.card_index)
    -- update views
    local cardView = battleView:getCardByIndex(info.card_index)
    if cardView:getIsPlayedDialogueByActionType(BattleConfig.ActionTypeEnterTurn) ~= true then
       cardView:playActionDialogue(battle,battleView,BattleConfig.ActionTypeEnterTurn)
    end
    
    cardView:execEnterTurnEvent(battle,battleView,info)
    cardView:showOutFrame()
    
    local lastCardView = battleView:getLastCardView()
    if lastCardView ~= nil then
--      lastCardView:showAngryBarView(false)
      lastCardView:hideOutFrame()
    end
    battleView:setLastCardView(cardView)
    
    if info.cur_round ~= nil and info.cur_round ~= 0 then
      battleView:updateRound(info.cur_round)
    end
  else
    printf("battle has been canceled.")
  end

end