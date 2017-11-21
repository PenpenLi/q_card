require("model.activity_stage.ActivityStages")
require("view.activity.ActivityStagesView")
ActivityStageController = class("ActivityStageController",BaseController)
function ActivityStageController:ctor()
   ActivityStageController.super.ctor(self,"ActivityStageController")
end

function ActivityStageController:enter()
  ActivityStageController.super.enter(self)
  
  GameData:Instance():pushViewType(ViewType.activity_stage)
  
  self:setScene(GameData:Instance():getCurrentScene())
  self.activityStages = ActivityStages:Instance()
  --self.activityStages:registNetSever()
  self.activityStages:updateCheckPoints()
  
  self.stageView = ActivityStagesView.new()
  self.stageView:setDelegate(self)
  self.activityStages:setActivityStageView(self.stageView)
  self:getScene():replaceView(self.stageView)
end

function ActivityStageController:reqActivityStageFightCheck(activity_id,stage)
   self._stage = stage
   if GameData:Instance():getCurrentPlayer():isEnabledEnterBattle() == true then
     self.activityStages:reqActivityStageFightCheck(activity_id,stage)
   end
end

function ActivityStageController:startLastStage()
  self.stageView:goToStageHandler()
end

function ActivityStageController:startActivityBattle(msg,stage)
----  enum FightReqError{
----    NO_ERROR_CODE = 0;
----  ..........
--    ACTIVITY_STAGE_NOT_OPEN = 23;
--    ENTER_CD = 24;
----  }
----  required FightReqError  error = 1;
----  optional FightMapInfo   info = 2;
--  
    if msg.error == "NO_ERROR_CODE" then
       echo("ActivityStageController: ActivityStage OK")
       local battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
       battleController:enter()
       battleController:startPVEActivityStageBattle(msg,stage)
    else
       echo("ActivityStageController:",msg.error)
    end
end
function ActivityStageController:reqForcibleBuyActivityStage(activityId,stageId,rightFight)
   self.activityStages:reqForcibleBuyActivityStage(activityId,stageId,rightFight)
end

function ActivityStageController:enterPlaystates()
  local playstatesController  = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
  playstatesController:enter()
end

function ActivityStageController:exit()
   ActivityStageController.super.exit(self)
   --self.activityStages:unregistNetSever()
   self.activityStages:setActivityStageView(nil)
   self.activityStages = nil
   self.stageView = nil
end

return ActivityStageController