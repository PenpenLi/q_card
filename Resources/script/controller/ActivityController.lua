require("controller.BaseController")
require("view.activity.ActivityBaseView")
require("view.activity.ActivityBonusArmyView")
require("view.activity.ActivityBonusLevelupView")
require("view.activity.ActivitySignInView")
require("view.activity.ActivityBossListView")
require("view.activity.ActivityBossBattleView")
require("view.activity.ActivityGrowView")
require("view.activity.ActivityVipView")
require("view.activity.ActivityMoneyTree")
require("view.activity.ActivityFreeRebate")
require("view.activity.ActivityExchangeView")
require("view.activity.ActivityRebateCardView")
require("view.activity.ActivityChargeBonusView")
require("view.activity.ActivityVipInfoView")
require("view.activity.ActivityShootView")
require("view.activity.CardReplace")
require("view.activity.ActivityMoneyView")
require("view.arena.ArenaPreview")
require("model.Activity")

ActivityController = class("ActivityController",BaseController)


function ActivityController:ctor()
	ActivityController.super.ctor(self)
	Activity:instance():setDelegate(self)
	Activity:instance():askForBossFight()	
end

function ActivityController:enter()
  ActivityController.super.enter(self)
	local index
	local view = nil 
	if self:getBackToBossFightView() == true then  --back BossFightView from battle fight
		self:setBackToBossFightView(false)
		local boss = Activity:instance():getTargetBoss()
		view = ActivityBossBattleView.new(boss)
		index = ActMenu.BOSS
	else 
		view = ActivityBonusArmyView.new()
	end 
	view:setDelegate(self)

	if self.baseview == nil then 
		self.baseview = ActivityBaseView.new(index)
		self.baseview:setDelegate(self)
	end 
	self.baseview:addChild(view, -1)
	self:getScene():replaceView(self.baseview)
	self:getScene():setTopVisible(false)
	self._preView = view 
end

function ActivityController:enterViewByIndex(viewIndex, isSubView)
	echo("=== ActivityController:enterViewByIndex =", viewIndex)
	
	GameData:Instance():pushViewType(ViewType.activity, {viewIndex, isSubView})
	
	local view = nil 
	if viewIndex == ActMenu.ARMY then 
		view = ActivityBonusArmyView.new()
	elseif viewIndex == ActMenu.LEVELUP_BONUS then 
		if GameData:Instance():checkSystemOpenCondition(28, true) == false then 
			return false 
		end
		view = ActivityBonusLevelupView.new()

	elseif viewIndex == ActMenu.DAILY_SIGNIN then 
		if GameData:Instance():checkSystemOpenCondition(7, true) == false then 
			return false 
		end 
		view = ActivitySignInView.new()

	elseif viewIndex == ActMenu.BOSS then 
		if GameData:Instance():checkSystemOpenCondition(5, true) == false then 
			return false 
		end 
		if isSubView ~= nil and  isSubView == true then 
			local boss = Activity:instance():getTargetBoss()
			view = ActivityBossBattleView.new(boss) 
		else
			view = ActivityBossListView.new()
		end 
	elseif viewIndex == ActMenu.GROW_PLAN then 
		view = ActivityGrowView.new(boss)

	elseif viewIndex == ActMenu.VIP_SIGNIN then 
		view = ActivityVipView.new(boss)
        
	elseif viewIndex == ActMenu.MONEY_TREE then 
		view = ActivityMoneyTree.new()

	elseif viewIndex == ActMenu.REBATE_ONE then 
		view = ActivityFreeRebate.new(8)

	elseif viewIndex == ActMenu.REBATE_TEN then 
		view = ActivityFreeRebate.new(9)

	elseif viewIndex == ActMenu.EXCHANGE or viewIndex == ActMenu.ZHONG_QIU then 
		view = ActivityExchangeView.new(viewIndex)

	elseif viewIndex == ActMenu.CHARGE_REBATE then 
		view = ActivityRebateCardView:new()

	elseif viewIndex == ActMenu.ARENA then 
		-- local ret,hitstr = Arena:Instance():CanOpenCheck()
		-- if ret == false then
		-- 	if GameData:Instance():getLanguageType() == LanguageType.JPN then 
		-- 		hitstr = _tr("not_open")
		-- 	end 
		-- 	Toast:showString(GameData:Instance():getCurrentScene(), hitstr, ccp(display.cx, display.height*0.4))

		-- 	return false 
		-- end
		if GameData:Instance():checkSystemOpenCondition(22, true) == false then 
			return false 
		end 		
		view = ArenaPreview.new()

	elseif viewIndex == ActMenu.CHARGE_BONUS or viewIndex == ActMenu.MONEY_CONSUME then 
		view = ActivityChargeBonusView.new(viewIndex)

	elseif viewIndex == ActMenu.VIP_PRIVILEGE then 
		view = ActivityVipInfoView.new()

	elseif viewIndex == ActMenu.BIG_WHEEL then
		view = ActivityShootView.new()

	elseif viewIndex == ActMenu.CARD_REPLACE then
		view = CardReplace.new()
	elseif viewIndex == ActMenu.QUICK_MONEY then
		view = ActivityMoneyView.new()
	else 
		echo(" === invalid menu index !!!!!")
	end

	if view ~= nil then 
		view:setDelegate(self)
		--remove last view
		if self._preView ~= nil then 
			self._preView:removeFromParentAndCleanup(true)
		end
		self._preView = view

		if self.baseview == nil then 
			self.baseview = ActivityBaseView.new(viewIndex)
			self.baseview:setDelegate(self)
			self:getScene():replaceView(self.baseview)
			self:getScene():setTopVisible(false) 
		end 
		self.baseview:addChild(view, -1)

		return true 
	end 

	return false 
end 

function ActivityController:scrollToIndex(index)
	if self.baseview ~= nil then
		self.baseview:scrollToIndex(index)
	end 
end 

function ActivityController:getTopMenuSize()
	if self.baseview ~= nil then 
		return self.baseview:getContentSize()
	end
	return CCSizeMake(0,0)
end 

function ActivityController:reqBattle(boss,isQuickFight)
	echo("ActivityController:reqBattle")
	if GameData:Instance():getCurrentPlayer():isEnabledEnterBattle() == true then
		Activity:instance():reqBossFight(boss,isQuickFight)
	end
end

function ActivityController:startBattle(msg,boss,isQuickFight)
	if msg.error == "NO_ERROR_CODE" then
		if msg.info.fightType == "PVE_BOSS" then
			echo("PVE_BOSS OK")
			local battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
			battleController:enter()
			battleController:startBossBattle(msg,boss,isQuickFight)
		end
			
	elseif msg.error == "IS_IN_CD_TIME" then
		Toast:showString(self, _tr("invalid_time"), ccp(display.width/2, display.height*0.4))
	elseif msg.error == "BOSS_IS_DEAD" then
		Toast:showString(self, _tr("boss_is_killed"), ccp(display.width/2, display.height*0.4))
	elseif msg.error == "STAGE_CLOSE" then
		Toast:showString(self, _tr("boss_is_close"), ccp(display.width/2, display.height*0.4))
	else
		--Toast:showString(self, msg.error, ccp(display.width/2, display.height*0.4))
	end
end

function ActivityController:exit()
  ActivityController.super.exit(self)
	echo("---ActivityController:exit---")
	--self.data:exit()
end

-- function ActivityController:dataInstance()
--   return self.data
-- end

function ActivityController:setBackToBossFightView(isBack)
	self._isBack = isBack
end 

function ActivityController:getBackToBossFightView()
	return self._isBack
end 

function ActivityController:displayHomeView()
	echo("ActivityController:displayHomeView")
	local homeController = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
	homeController:enter()
end

function ActivityController:goToItemView() -- 跳到行囊界面
	local bagController = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
	bagController:enter()
end

function ActivityController:goToCardBagView() -- 跳到卡牌背包界面
	local cardBagController = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
	cardBagController:enter(false)
end

function ActivityController:goToEquipBagView() -- 跳到装备背包界面
	local cardBagController = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
	cardBagController:enter(true)
end

function ActivityController:goToShopPayView() -- 跳到商城充值界面
	local shopController = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
	shopController:enter(ShopCurViewType.PAY)
end 


function ActivityController:getBaseView()
	return self.baseview
end 

function ActivityController:goBackView()
	GameData:Instance():gotoPreView()
end 

function ActivityController:gotoVipPrivilegeView()
	Activity:instance():entryActView(ActMenu.VIP_PRIVILEGE, false)
end 