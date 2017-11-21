require("view.battle_formation.BattleFormationView")
require("model.battle.BattleFormation")

BattleFormationController = class("BattleFormationController",BaseController)

function BattleFormationController:ctor()
  BattleFormationController.super.ctor(self)
end

function BattleFormationController:enter(isAttacker,battleFormationIdx)
  BattleFormationController.super.enter(self)
  local battleFormationView = BattleFormationView.new(isAttacker,battleFormationIdx,false)
  self:getScene():replaceView(battleFormationView,true)
end

return BattleFormationController