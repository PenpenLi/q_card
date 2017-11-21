require("model.quest.Quest")
require("view.quest.QuestView")
QuestController = class("QuestController",BaseController)
function QuestController:ctor()
   QuestController.super.ctor(self,"QuestController")
   self.quest =  Quest:Instance()
end

function QuestController:enter()
  QuestController.super.enter(self)

  --self.quest:registNetSever()
  self.questView = QuestView.new(self,self.quest)
  self.quest:setQuestView(self.questView)
  self.quest:reFreshTaskState()
  self:getScene():replaceView(self.questView)

  -- self.sourceViewType = sourceViewType
end

function QuestController:gotoDailyTask()
  --self.questView:tabControlOnClick(1)
end

function QuestController:askForTaskAward(task)
  self.quest:askForTaskAward(task)
end

function QuestController:refreshVipFreeDailyTaskTable()
  print("refreshVipFreeDailyTaskTable")
  self.quest:refreshVipFreeDailyTaskTable()
end

function QuestController:refreshFreeDailyTaskTable()
  self.quest:refreshFreeDailyTaskTable()
end

function QuestController:refreshMoneyDailyTaskTable()

   if GameData:Instance():getCurrentPlayer():getMoney() >= 10 then
      self.quest:refreshMoneyDailyTaskTable()
   else
      -- local pop = PopupView:createTextPopup(_tr("not enough money"), function() return end ,true)
      -- GameData:Instance():getCurrentScene():addChildView(pop,100)
      GameData:Instance():notifyForPoorMoney()
   end
end

function QuestController:reqForcibleDoneDailyTask(taskId)

  local makeSureMoneyEnough = function(needMoney)
     if GameData:Instance():getCurrentPlayer():getMoney() >= needMoney then
        self.quest:reqForcibleDoneDailyTask(taskId)
     else
        local pop = PopupView:createTextPopup(_tr("not enough money"), function() return end ,true)
        GameData:Instance():getCurrentScene():addChildView(pop,100)
     end
  
  end
  
  local forcibleCount = self.quest:getForcibleDoneDailyTaskCount()
  print(forcibleCount)
  local needMoney = 0
  for key, var in pairs(AllConfig.cost) do
  	 if var.type == 14 then
  	    --print(var.cost)
  	    if var.min_count == forcibleCount + 1 then
  	       needMoney = var.cost
  	       break
  	    end
  	 end
  end
  
  if needMoney <= 0 then
     return
  end
  
  local pop = PopupView:createTextPopup(_tr("cost%{needMoney}to_finish_task",{ needMoney = needMoney }), function() return makeSureMoneyEnough(needMoney) end )
  GameData:Instance():getCurrentScene():addChildView(pop,100)
      
  
end

function QuestController:askForDailyTaskTable()
  self.quest:askForDailyTaskTable()
end

function QuestController:dropDailyTask(dailyId)
  self.quest:dropDailyTask(dailyId)
end

function QuestController:receiveDailyTask(dailyId)
  self.quest:receiveDailyTask(dailyId)
end

function QuestController:backHandler()
  GameData:Instance():gotoPreView()
end

function QuestController:exit()
   --self.quest:destory()
   QuestController.super.exit(self)
   self.quest:setQuestView(nil)
end

return QuestController