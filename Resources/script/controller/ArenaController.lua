require("model.arena.Arena")
require("view.arena.ArenaView")
require("view.arena.ArenaEnterEffectAnimation")
require("view.arena.ArenaPreview")
ArenaController = class("ArenaController",BaseController)
function ArenaController:ctor()
  ArenaController.super.ctor(self,"ArenaController")
end

function ArenaController:enter()
  ArenaController.super.enter(self)
  
  self:getScene():setTopVisible(false)

  local leftTime,state = Arena:Instance():getLeftTime()
  print("ArenaController:leftTime:~~~~~~~",leftTime,state)
  
  if state == 1 or state == 3 then
    self:enterPreview()
  elseif state == 2 then
    self:enterArenaView()
  end
  
  Arena:Instance():setDelegate(self)
  --self:getScene():setBottomVisible(false)
end

function ArenaController:enterPreview()
  self.view = nil
  self.view = ArenaPreview.new()
  self.view:setDelegate(self)
  Arena:Instance():setArenaView(self.view)
  self:getScene():replaceView(self.view)
end

function ArenaController:enterArenaView()
  self.view = nil
  self.view = ArenaView.new()
  self.view:setDelegate(self)
  Arena:Instance():setArenaView(self.view)
  self:getScene():replaceView(self.view,true)
  --self.view:updateView(Arena:Instance())
  Arena:Instance():reqPVPArenaQueryC2S()
end

function ArenaController:enterArenaBattle(msg)
   
    --[[  msg:
    enum traits{value = 5130;}
    enum ErrorCode{
      NO_ERROR_CODE = 1;  //
      NOT_OPEN_TIME = 2;  //时间没到
      LEVEL_LIMIT   = 3;  //等级不够
      LIMIT_SEARCH  = 5;  //搜索次数没了
      NOT_IN_SEARCH = 6;  //不在搜索
      WAIT_RESULT   = 7;  //等待战斗结算结果
      SYSTEM_ERROR  = 4;  //其他错误
    }
    required ErrorCode error = 1;     
    optional PVPArenaTarget target = 2;  //对手数据
    optional PVPArenaData self = 3;    //自己数据
    ]]
    
   local battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
   battleController:enter()
   battleController:startArenaBattle(msg)
end



function ArenaController:exit()
   Arena:Instance():setArenaView(nil)
   Arena:Instance():setDelegate(nil)
   --Arena:Instance():destory()
   self.view = nil
   ArenaController.super.exit(self)
end

return ArenaController