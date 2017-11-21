require("controller.LoginController")
require("controller.MainStageController")
require("controller.PlayStatesController")
require("controller.HomeController")
require("controller.ShopController")
require("controller.BattleController")
require("controller.ScenarioController")
require("controller.CreatePlayerNameController")
require("controller.ExpeditionController")
require("controller.BagController")
require("controller.CardBagController")
require("controller.LevelUpController")
require("controller.QuestController")
require("controller.CardIllustratedController")
require("controller.ActivityController")
require("controller.MailController")
require("controller.SystemController")
require("controller.MiningController")
require("controller.AchievementController")
require("controller.LotteryController")
require("controller.ActivityStageController")
require("controller.TalentController")
require("controller.ArenaController")
require("controller.CardSoulController")
require("controller.VipShopController")
require("controller.PvpRankMatchController")
require("controller.BattleFormationController")
require("controller.GuildController")
require("controller.GuildStagesController")
require("controller.BableController")
require("controller.CardFlashSaleController")

--notice:只能在最后追加新的ControllerType,不要删除已定义的,也不要改变已定义的顺序
local enumControllerType = { "NONE","REGIST_CONTROLLER","HOME_CONTROLLER",
"LEVELUP_CONTROLLER","MAIN_STAGE_CONTROLLER","BATTLE_CONTROLLER",
"PLAY_STATES_CONTROLLER","SHOP_CONTROLLER","SCENARIO_CONTROLLER",
"CREATE_PLAYER_NAME_CONTROLLER","EXPEDITION_CONTROLLER", 
"BAG_CONTROLLER", "CARDBAG_CONTROLLER","FRIEND_CONTROLLER",
"QUEST_CONTROLLER","CARD_ILLUSTRATED_CONTROLLER", "ACTIVITY_CONTROLLER",
"MAIL_CONTROLLER","SYSTEM_CONTROLLER","MINING_CONTROLLER","ACHIEVEMENT_CONTROLLER",
"LOTTERY_CONTROLLER","ACTIVITY_STAGE_CONTROLLER","TALENT_CONTROLLER","EQUIPMENT_CONTROLLER"--[[unused]],
"ARENA_CONTROLLER","CARD_SOUL_CONTROLLER", "SHOP_VIP_CONTROLLER","PVP_RANK_MATCH_CONTROLLER",
"BATTLE_FORMATION_CONTROLLER","GUILD_CONTROLLER","GUILD_STAGES_CONTROLLER", "BABEL_CONTROLLER","CARD_FLASH_SALE"}
ControllerType = enum(enumControllerType)


ControllerFactory = class("ControllerFactory")

ControllerFactory._Instance = nil                

--ControllerFactory.currentControllerType = nil

function ControllerFactory:Instance() 
  if ControllerFactory._Instance == nil then
    ControllerFactory._Instance = ControllerFactory.new()
    ControllerFactory._Instance:init()
  end
  return ControllerFactory._Instance
end

function ControllerFactory:init() 
  self._currentController = nil
  self:setControllerCount(#enumControllerType)
end

------
--  Getter & Setter for
--      ControllerFactory._ControllerCount 
-----
function ControllerFactory:setControllerCount(ControllerCount)
	self._ControllerCount = ControllerCount
end

function ControllerFactory:getControllerCount()
	return self._ControllerCount
end

function  ControllerFactory:create(type)
  local controller = nil
  CCDirector:sharedDirector():setAnimationInterval(1.0 /30)
  if type == ControllerType.REGIST_CONTROLLER then
    echo("create REGIST_CONTROLLER")
    controller = LoginController.new()
  elseif type == ControllerType.MAIN_STAGE_CONTROLLER then
    echo("create MAIN_STAGE_CONTROLLER")
    controller = MainStageController.new()
  elseif type == ControllerType.BATTLE_CONTROLLER then
    echo("create BATTLE_CONTROLLER")
    CCDirector:sharedDirector():setAnimationInterval(1.0 / 50)
    controller = BattleController.new()
  elseif type == ControllerType.PLAY_STATES_CONTROLLER then
    echo("create PLAY_STATES_CONTROLLER")
    controller = PlayStatesController.new()
  elseif type == ControllerType.HOME_CONTROLLER then
    echo("create HOME_CONTROLLER")
    controller = HomeController.new()
  elseif type == ControllerType.LEVELUP_CONTROLLER then
    echo("create LEVELUP_CONTROLLER")
    controller = LevelUpController.new()
  --[[elseif type == ControllerType.EQUIPMENT_CONTROLLER then
    echo("create EQUIPMENT_CONTROLLER")
    controller = EquipmentController.new()]]
  elseif type == ControllerType.SHOP_CONTROLLER then
    echo("create SHOP_STATES_CONTROLLER")
    controller = ShopController.new()
  elseif type == ControllerType.SCENARIO_CONTROLLER then
    controller = ScenarioController.new()
  elseif type == ControllerType.CREATE_PLAYER_NAME_CONTROLLER then
    controller = CreatePlayerNameController.new()
  elseif type == ControllerType.EXPEDITION_CONTROLLER then
    controller = ExpeditionController.new()
  elseif type == ControllerType.BAG_CONTROLLER then
    controller = BagController.new()
  elseif type == ControllerType.CARDBAG_CONTROLLER then
    controller = CardBagController.new()    
  elseif type == ControllerType.FRIEND_CONTROLLER then
    controller = FriendController.new()
  elseif type == ControllerType.QUEST_CONTROLLER then
    controller = QuestController.new()
  elseif type == ControllerType.CARD_ILLUSTRATED_CONTROLLER then
    controller = CardIllustratedController.new()
  elseif type == ControllerType.ACTIVITY_CONTROLLER then
    controller = ActivityController.new()
  elseif type == ControllerType.MAIL_CONTROLLER then
    controller = MailController.new()
  elseif type == ControllerType.SYSTEM_CONTROLLER then
    controller = SystemController.new()
  elseif type == ControllerType.MINING_CONTROLLER then
    controller = MiningController.new()
  elseif  type == ControllerType.ACHIEVEMENT_CONTROLLER then
	  controller = AchievementController.new()
  elseif type == ControllerType.LOTTERY_CONTROLLER then
	  controller = LotteryController.new()
	elseif type == ControllerType.ACTIVITY_STAGE_CONTROLLER then
	  controller = ActivityStageController.new()
  elseif type == ControllerType.TALENT_CONTROLLER then
    controller = TalentController.new()
  elseif type == ControllerType.ARENA_CONTROLLER then
    controller = ArenaController.new()
  elseif type == ControllerType.CARD_SOUL_CONTROLLER then 
    controller = CardSoulController.new()
  elseif type == ControllerType.SHOP_VIP_CONTROLLER then 
    controller = VipShopController.new()
  elseif type == ControllerType.PVP_RANK_MATCH_CONTROLLER then 
    controller = PvpRankMatchController.new()
  elseif type == ControllerType.BATTLE_FORMATION_CONTROLLER then 
    controller = BattleFormationController.new()
  elseif type == ControllerType.GUILD_CONTROLLER then 
    controller = GuildController.new()
  elseif type == ControllerType.GUILD_STAGES_CONTROLLER then
    controller = GuildStagesController.new()
  elseif type == ControllerType.BABEL_CONTROLLER then
    controller = BableController.new()
  elseif type == ControllerType.CARD_FLASH_SALE then
    controller = CardFlashSaleController.new()
  else
    echoError("Can not create NONE type controller")
  end
  
  if controller ~= nil then
  	self:setCurrentControllerType(type)
  	controller:setControllerType(type)
  	self:setCurController(controller)
  end

  return controller
end

------
--  Getter & Setter for
--      ControllerFactory._CurrentControllerType 
-----
function ControllerFactory:setCurrentControllerType(CurrentControllerType)
	self._CurrentControllerType = CurrentControllerType
end

function ControllerFactory:getCurrentControllerType()
	return self._CurrentControllerType
end

function ControllerFactory:setCurController(controller)
	self._curController = controller
end

function ControllerFactory:getCurController()
	return self._curController
end


return ControllerFactory