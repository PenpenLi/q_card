require("view.BaseView")
require("view.component.CardHeadView")
require("view.enhance.LevelUpView")
require("view.component.TipPic")
require("model.mail.MailBox")
require("model.home.Home")
require("view.component.PopupView")
require("view.home.HomeTop")
require("view.home.LivenessView")
require("model.ServerError")
require("view.home.DaySurpriseView")
require("view.home.FestivalGiftView")
require("view.home.HomeActView")
require("view.home.HomeRankView")
require("view.home.ActivityMissionView")
require("view.home.RechargeTopView")
require("view.home.HomeActFirstCharge")

require("model.arena.ArenaConfig")


HomeView = class("HomeView", BaseView)

--user config
function HomeView:ctor()
  HomeView.super.ctor(self)
  local pkg = ccbRegisterPkg.new(self)

  pkg:addFunc("wujiangCallback",HomeView.wujiangCallback)
  pkg:addFunc("mailCallback",HomeView.mailCallback)
  pkg:addFunc("taskCallback",HomeView.taskCallback)
  pkg:addFunc("livenessCallback",HomeView.livenessCallback)
  pkg:addFunc("signCallback",HomeView.signCallback)
  pkg:addFunc("bossCallback",HomeView.bossCallback)
  pkg:addFunc("gotoPlaystatesHandler",HomeView.gotoPlaystatesHandler)
  pkg:addFunc("arenaCallback",HomeView.arenaCallback)
  pkg:addFunc("actListCallback",HomeView.actListCallback)
  pkg:addFunc("serverOpenCallback",HomeView.serverOpenCallback)
  pkg:addFunc("chatCallback",HomeView.chatCallback)

  pkg:addProperty("node_bg","CCNode")
  pkg:addProperty("node_fg","CCNode")
  pkg:addProperty("node_cloud","CCNode")
  pkg:addProperty("node_mail","CCNode")
  pkg:addProperty("node_task","CCNode")
  pkg:addProperty("node_liveness","CCNode")
  pkg:addProperty("node_sign","CCNode")
  pkg:addProperty("node_birds","CCNode")
  pkg:addProperty("node_talent_icon","CCNode")
  pkg:addProperty("node_boss","CCNode")
  pkg:addProperty("node_arena","CCNode")
  pkg:addProperty("anim_talent","CCNode")
  pkg:addProperty("node_allIcons","CCNode")
  pkg:addProperty("node_actlist","CCNode")
  pkg:addProperty("node_tbview","CCNode")
  pkg:addProperty("node_actListContainer","CCNode")
  pkg:addProperty("node_vipshop","CCNode")
  pkg:addProperty("node_walking","CCNode")
  pkg:addProperty("node_playState","CCNode")
  pkg:addProperty("node_chat","CCNode")

  pkg:addProperty("sprite_bg","CCSprite")
  pkg:addProperty("sprite_fg","CCSprite")
  pkg:addProperty("sprite_haoyou0","CCSprite")
  pkg:addProperty("sprite_xingnang0","CCSprite")
  pkg:addProperty("sprite_kuangchang0","CCSprite")
  pkg:addProperty("sprite_vipshop0","CCSprite")
  pkg:addProperty("sprite_dianjiangtai0","CCSprite")
  pkg:addProperty("sprite_chengjiu0","CCSprite")
  pkg:addProperty("sprite_lianhun0","CCSprite")
  pkg:addProperty("sprite_kapai0","CCSprite")
  pkg:addProperty("sprite_tianfu0","CCSprite")
  pkg:addProperty("sprite_huodongfuben0","CCSprite")
  pkg:addProperty("sprite_rank0","CCSprite")
  pkg:addProperty("sprite_jingjichang0","CCSprite")
  pkg:addProperty("vip_shadow","CCSprite")
  pkg:addProperty("sprite_tuhao0","CCSprite")
  pkg:addProperty("sprite_gonghui0","CCSprite")
  pkg:addProperty("sprite_tongtianta0","CCSprite")

  --name
  pkg:addProperty("name_haoyou","CCSprite")
  pkg:addProperty("name_cangku","CCSprite")
  pkg:addProperty("name_vipshop","CCSprite")
  pkg:addProperty("name_kuangchang","CCSprite")
  pkg:addProperty("name_dianjiangtai","CCSprite")
  pkg:addProperty("name_chengjiu","CCSprite")
  pkg:addProperty("name_kapai","CCSprite")
  pkg:addProperty("name_tianfu","CCSprite")
  pkg:addProperty("name_fuben","CCSprite")
  pkg:addProperty("name_rank","CCSprite")
  pkg:addProperty("name_lianhun","CCSprite")
  pkg:addProperty("name_jingjichang","CCSprite")
  -- pkg:addProperty("name_zhuangbei","CCSprite")
  pkg:addProperty("name_tuhao","CCSprite")
  pkg:addProperty("name_gonghui","CCSprite")
  pkg:addProperty("name_tongtianta","CCSprite")

  pkg:addProperty("sprite9_btnListBg","CCScale9Sprite")
  pkg:addProperty("sprite_actArrowUp","CCSprite")

  pkg:addProperty("menu_mail","CCMenu")
  pkg:addProperty("menu_task","CCMenu")
  pkg:addProperty("menu_liveness","CCMenu")
  pkg:addProperty("menu_sign","CCMenu")
  pkg:addProperty("menu_boss","CCMenu")
  pkg:addProperty("menu_arena","CCMenu")
  pkg:addProperty("menu_chat","CCMenu")

  -- pkg:addProperty("btnPlaystate","CCMenu")
  pkg:addProperty("bn_actlist","CCControlButton")
  pkg:addProperty("bn_serverOpen","CCControlButton")
  pkg:addProperty("mAnimationManager","CCBAnimationManager") --default for animation property

  
  
     


  local layer, homeOwner = ccbHelper.load("HomeView.ccbi","HomeViewCCB","CCLayer",pkg)
  self:addChild(layer)

  self.onAnimFinishCallback = handler(self,self.talentAnimFinishCallback)
  ccb["HomeViewTalentIconCCB"]={}
  self.layer_talentaward = tolua.cast(CCBuilderReaderLoad("HomeView_TalentIcon.ccbi",CCBProxy:create(),self),"CCLayer")
  self.layer_talentaward:setVisible(true)
  self.sprite_talent_award:setVisible(false)

  self.node_talent_icon:addChild(self.layer_talentaward)
  self.mAnimationManagerIcon = tolua.cast( ccb["HomeViewTalentIconCCB"]["mAnimationManager"] ,"CCBAnimationManager")
  self.anim_talent:setVisible(false)


  -- play bgm
  _playBgm(BGM_MAIN)
end


function HomeView:init()
  echo("---- HomeView init ---")

  --variables
  self.deaccScheduleId = 0
  self.headerScheduler = 0
  self.countDownScheduler = 0
  self.ScrollDeaccelRate = 0.95 
  self.ScrollDeaccelDist = 1.0 

  -- self.node_actlist:setVisible(false)
  self.isVipShopOpen, _ = Shop:instance():checkShopOpen(ShopCurViewType.VIP)

  --menus {obj0, obj1, callfunc, guide}
  self.menusArray = {
      {self.sprite_haoyou0,       nil, HomeView.friendsCallback,102001},
      {self.sprite_xingnang0,     nil, HomeView.bagCallback,102002},
      {self.sprite_kuangchang0,   nil, HomeView.mineCallback,102003},
      {self.sprite_vipshop0,      nil, HomeView.vipShopCallback,102004},
      {self.sprite_dianjiangtai0, nil, HomeView.lotteryCallback,102005},      
      {self.sprite_chengjiu0,     nil, HomeView.achievementCallback,102006},
      {self.sprite_lianhun0,      nil, HomeView.lianhunCallback,102007},     
      {self.sprite_kapai0,        nil, HomeView.cardBagCallback,102008},
      {self.sprite_tianfu0,       nil, HomeView.talentCallback,102009},
      {self.sprite_huodongfuben0, nil, HomeView.activityStageCallback,102010},
      {self.sprite_rank0,         nil, HomeView.rankCallback, -1},
      {self.sprite_jingjichang0,  nil, HomeView.jingjiCallback, 102014},
      {self.sprite_tuhao0,        nil, HomeView.tuhaoCallback, -1},
      {self.sprite_gonghui0,      nil, HomeView.gongHuiCallback, 102015},
      {self.sprite_tongtianta0,   nil, HomeView.tongtiantaCallback, 102016},
      
      -- {self.sprite_zhuangbei0,    nil, HomeView.equipmentCallback,102011}            
    }

  --show vip shop or not
  self.node_vipshop:setVisible(self.isVipShopOpen)
  self.vip_shadow:setVisible(self.isVipShopOpen)

  --regist new bird component
  for i = 1, #self.menusArray do
  	_registNewBirdComponent(self.menusArray[i][4],self.menusArray[i][1])
  end
  
  -- other components
  _registNewBirdComponent(102012,self.node_task)
  _registNewBirdComponent(102013,self.node_playState)
  
  self.Act = enum({"ChargeBonus","RebateCard", "DaySurprise", "FestivalGift","Rebate", "Exchange", 
                    "VipInfo", "ActList", "BonusLevelUp","MoneyConsume", "BigWheel", "FirstCharge", "QuickMoney", "CardReplace"})
  --首页下拉菜单项
  self.actListArray = {
      {self.Act.VipInfo,      "#bn_vip0.png",            "#bn_vip1.png",            handler(self,HomeView.vipinfoCallback)},     --VIP特权
      {self.Act.ChargeBonus,  "#bn_leijichongzhi0.png",  "#bn_leijichongzhi1.png",  handler(self,HomeView.chargeBonusCallback)}, --累计充值
      {self.Act.RebateCard,   "#bn_chongzhihaoli0.png",  "#bn_chongzhihaoli1.png",  handler(self,HomeView.rebateCardCallback)},  --充值豪礼
      {self.Act.DaySurprise,  "#bn_meirijingxi0.png",    "#bn_meirijingxi1.png",    handler(self,HomeView.daySurpriseCallback)}, --每日惊喜
      {self.Act.FestivalGift, "img/home/bn_festivalGift0.png", "img/home/bn_festivalGift1.png", handler(self,HomeView.festivalGiftCallback)},--节日领奖
      {self.Act.Rebate,       "#bn_miandan0.png",        "#bn_miandan1.png",        handler(self,HomeView.rebateCallback)},       --全民免单
      {self.Act.Exchange,     "#bn_duihuanhuodong0.png", "#bn_duihuanhuodong1.png", handler(self,HomeView.exchangeCallback)},     --兑换活动
      {self.Act.MoneyConsume, "#bn_money_consume0.png",  "#bn_money_consume1.png",  handler(self,HomeView.moneyConsumeCallback)}, --消耗活动      
      {self.Act.ActList,      "#bn_act_list0.png",       "#bn_act_list1.png",       handler(self,HomeView.ActsCallback)},         --活动列表
      {self.Act.FirstCharge,  "#bn_shou_chong0.png",     "#bn_shou_chong1.png",     handler(self,HomeView.FirstChargeCallback)},  --首充活动
      {self.Act.CardReplace,  "#bn_replaceCard0.png",    "#bn_replaceCard1.png",    handler(self,HomeView.CardReplaceCallback)},  --交换卡牌
      {self.Act.BigWheel,     "#bn_dazhuanpan0.png",     "#bn_dazhuanpan1.png",     handler(self,HomeView.bigWheelCallback)},     --大转盘
      {self.Act.QuickMoney,   "#bn_caiyuangungun0.png",  "#bn_caiyuangungun1.png",  handler(self,HomeView.quickMoneyCallback)},   --摇元宝
      {self.Act.BonusLevelUp, "#bn_bonusLv_10.png",      "#bn_bonusLv_10.png",      handler(self,HomeView.BonusLevelUpCallback)}  --升级领奖
    }

  self.actMenuPriority = -130 
  self.actMenusItems = self:getValidActItems()

  --if self:getDelegate():getShowNotice() == false then --no need to show notice view
    self:addMaskLayer()     
    self:delayTrigger()
  --end


  --计算屏幕移动范围
  local imgSize = self.sprite_bg:getContentSize() 
  local imgPosX = self.sprite_bg:getPositionX()
  self.offsetMinX = - (imgSize.width+imgPosX-display.width)
  self.offsetMaxX = -imgPosX
  self.offsetMinY = self:getDelegate():getScene():getBottomContentSize().height
  echo("=== offsetMinX, offsetMaxX", self.offsetMinX, self.offsetMaxX)

  --返回上次记录屏幕位置
  self.orgBgPosX = self.node_bg:getPositionX()
  self.orgFgPosX = self.node_fg:getPositionX()

  local x_fg, x_bg = Home:instance():getPreViewPositionX() 
  self.preBgPosX = x_bg or self.orgBgPosX
  self:setBgImgPosition(x_fg)  

  --设置7天开服活动菜单位置
  local leftSec,_ = Activity:instance():getIsServerOpenActValid() 
  self.bn_serverOpen:setPosition(ccp(display.cx-260, 170))
  self.bn_serverOpen:setVisible(leftSec > 0)
end

function HomeView:onEnter()
  echo("---HomeView:onEnter---")
  net.registMsgCallback(PbMsgId.AskForOnlineRewardResult, self, HomeView.AskForOnlineRewardResult)
  net.registMsgCallback(PbMsgId.InstanceRefresh,self,HomeView.systomRefresh)    --零点更新
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,HomeView.updateMenuTips),EventType.UPDATE_TIP)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,HomeView.enterBackground),"APP_ENTER_BACKGROUND")
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,HomeView.enterForeground),"APP_WILL_ENTER_FOREGROUND")  
 
  self:init()

  --show topbar
  self.homeTop = HomeTop.new()
  self:addChild( self.homeTop)
  self:setMenuGrayIfNeed()
  GameData:Instance():pushViewType(ViewType.home)

  --online bonus
  -- self:showCountDownTime()
  self:rejustExtMenuPosition(false)
  self:playBgAnimEffect()
  
  --on battle cardHeaders
  self:setCardHeaderListScrollEnable(true)
  self.isCardHeaderShowing = GameData:Instance():getHomeHeaderVisible()
  -- self:showOnBattleCardHeader()
  
  MessageBox.Help.LayerClick(self.layer_talentaward,self.sprite_talent_award,handler(self, self.talentAwardCallback ),nil,-129,false)
  self.layer_talentaward:setTouchEnabled(false)

  Talent.Instance().SetEvent("TALENT_GETPOINT", function(self,msg)
	Toast:showIconNum("+"..msg.point, msg.double_point and "#talent_crit.png" or "#talent_talent.png",nil,nil, ccp(display.cx, display.height*0.4))
  end, self)
  --Talent.Instance().SetEvent("TALENT_GETPOINT", handler(self,HomeView.talentEffect), self.homeTop)
  Talent.Instance().SetEvent("TALENT_LEVELUP",  HomeView.Talnet_updating,self)
  Talent.Instance().SetEvent("BANK_LEVELUP",  HomeView.Talnet_updating,self)
  Talent.Instance().SetEvent("TALENT_PRODUCE_CHANGED",HomeView.updateTalentData,self)

  self.bankShowed = {}
  local talentShowed={}
  Talent.Instance().SetEvent("TALENT_LEVELUP_CAN_END", function(self,list,bank)
      if (bank[1] == Talent.BankStatus.BANK_LEVELUP_DONE) then
        self:Talent_updateDone()
        --return true
      end
      for n,v in pairs(list) do
        self:Talent_updateDone(n)
      end
    end,self)

  Talent.Instance():RecallTimer()
 end

function HomeView:onExit()
	echo("---HomeView:onExit---")

  Home:instance():setPreViewPositionX(self.node_fg:getPositionX(), self.node_bg:getPositionX())

	Talent.Instance().SetEvent("TALENT_GETPOINT", nil, self.homeTop)
	Talent.Instance().SetEvent("TALENT_LEVELUP",  nil,self)
	Talent.Instance().SetEvent("BANK_LEVELUP",  nil,self)
	Talent.Instance().SetEvent("TALENT_LEVELUP_CAN_END",nil,self)
	Talent.Instance().SetEvent("TALENT_PRODUCE_CHANGED",nil,self)

	if self.deaccScheduleId > 0 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.deaccScheduleId)
		self.deaccScheduleId = 0
	end

	if self.countDownScheduler > 0 then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.countDownScheduler)
		self.countDownScheduler = 0
	end

	if self.headerScheduler > 0 then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.headerScheduler)
		self.headerScheduler = 0
	end

	net.unregistAllCallback(self)
	CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, EventType.UPDATE_TIP)
	CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, "APP_ENTER_BACKGROUND")
	CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, "APP_WILL_ENTER_FOREGROUND")
 end 

function HomeView:delayTrigger()
  self:performWithDelay(function ()
                          self:triggerNewBird()

                          --regist touch event
                          self:addTouchEventListener(handler(self,self.onTouch))
                          self:setTouchEnabled(true)

                          self:removeMaskLayer()
                                                    
                          self:getDelegate():getScene():getBottomBlock():updateBottomTip()
                          self:rejustExtMenuPosition(true)
                          self:updateMenuTips()  

                          local isActPopShow = false 
                          if Guide:Instance():getGuideLayer() == nil then
                            Quest:Instance():alertMainTaskAwardPop()
                            isActPopShow = self:showActivityPop()
                          else 
                            echo("=== has new guide...")
                          end 
                          if self:getDelegate():getLivenessShowFlag() == true then 
                            self:getDelegate():setLivenessShowFlag(false)
                            self:livenessCallback()
                          elseif self:getDelegate():getActMissionShowFlag() == true then 
                            self:getDelegate():setActMissionShowFlag(false)
                            self:serverOpenCallback()
                          end 
                          Activity:instance():checkEatPartyTime()

                          if isActPopShow == false then 
                            GameData:Instance():setInitSysComplete(true) 
                          end                                    
                        end,
                      1.0)
end

function HomeView:gotoPlaystatesHandler()
  self:getDelegate():enterPlaystates(1)
end

function HomeView:arenaCallback()
  local ret,hitstr = Arena:Instance():CanOpenCheck()
  if(not ret) then
    Toast:showString(GameData:Instance():getCurrentScene(), hitstr, ccp(display.cx, display.cy))
    return
  end

  if(Arena:Instance():getSeverState() == "ARENA_OPEN") then
    local controller = ControllerFactory:Instance():create(ControllerType.ARENA_CONTROLLER)
    controller:enter()
  else
    Activity:instance():entryActView(ActMenu.ARENA, false)
  end 
end 

function HomeView:chargeBonusCallback()
  Activity:instance():entryActView(ActMenu.CHARGE_BONUS, false)
end 

function HomeView:moneyConsumeCallback()
  Activity:instance():entryActView(ActMenu.MONEY_CONSUME, false)
end 

function HomeView:bigWheelCallback()
  Activity:instance():entryActView(ActMenu.BIG_WHEEL, false)
end 

function HomeView:quickMoneyCallback()
  Activity:instance():entryActView(ActMenu.QUICK_MONEY, false)
end 

function HomeView:FirstChargeCallback()
  local view = HomeActFirstCharge.new()
  GameData:Instance():getCurrentScene():addChildView(view) 
end 

function HomeView:CardReplaceCallback()
  Activity:instance():entryActView(ActMenu.CARD_REPLACE, false)
end 

function HomeView:triggerNewBird()
  local triggered, step = _executeNewBird()
  if triggered then 
    if step:getComponentId() > 0 then
      self:scrollToMenu(step:getComponentId())
    end
  end 
end

function HomeView:Talnet_updating(tb)
	if(not self._anim_Talent_Update) then
		local anim,offsetX,offsetY,duration = _res(5020197)
		self.node_talent_icon:addChild(anim)
		anim:getAnimation():play("default")
		self._anim_Talent_Update = anim
		anim:setPosition(ccp(-100,0))
	end
	self._anim_Talent_Update_count = (self._anim_Talent_Update_count and self._anim_Talent_Update_count or 0)+1
end

function HomeView:Talent_updateDone(tb)
	self._anim_Talent_Update_count = self._anim_Talent_Update_count and (self._anim_Talent_Update_count-1) or 0
	if(self._anim_Talent_Update_count ==0 and self._anim_Talent_Update) then
		self._anim_Talent_Update:removeFromParentAndCleanup(true)
		self._anim_Talent_Update=nil
	end

	self.anim_talent:setVisible(true)
end

function HomeView:Talent_BankNormal()
	self.bankShowed={}
end


function HomeView:onTouch(event, x,y)
  local function deaccelerateScrolling()
    -- echo("deaccelerateScrolling")
    if self.isDraging then 
      if self.deaccScheduleId > 0 then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.deaccScheduleId)
        self.deaccScheduleId = 0
      end
      return 
    end 

    self:setBgImgPosition(self.node_fg:getPositionX()+self.moveOffsetX)

    self.moveOffsetX = self.moveOffsetX * self.ScrollDeaccelRate
    local newX = self.node_fg:getPositionX()+self.moveOffsetX

    if (math.abs(self.moveOffsetX) <= self.ScrollDeaccelDist) or newX > self.offsetMaxX or newX < self.offsetMinX then 
      if self.deaccScheduleId > 0 then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.deaccScheduleId)
        self.deaccScheduleId = 0
      end

      self:setBgImgPosition(newX)
    end 
  end 


  if event == "began" then
    self.isDraging = false 
    self.touch_x = x
    self.beginX = x 
    --bottom rect
    if y < self.offsetMinY then 
      return false
    end

    --highlight menu
    self.menuIndex = self:checkMenuTouch(self.menusArray, x, y)
    -- echo("====menu:", self.menuIndex)
    if self.menuIndex > 0 then 
      self:hightlighMenu(self.menuIndex)
    end 

    return true

  elseif event == "moved" then
    if Guide:Instance():getGuideLayer() ~= nil then --新手引导界面下不允许滑动
      return 
    end

    self.moveOffsetX = x - self.touch_x
    self.touch_x = x

    local newX = self.node_fg:getPositionX()+self.moveOffsetX
    self:setBgImgPosition(newX)

    if self.menuIndex > 0 then 
      if math.abs(self.beginX - x) > 20 then
        echo("==== cancel touch")
        self:unhightlighMenu(self.menuIndex, false)
        self.menuIndex = 0
        self.isDraging = true 
      end
    else 
      self.isDraging = true 
    end

  elseif event == "ended" then
    if self.isDraging then 
      self.isDraging = false 
      if self.deaccScheduleId > 0 then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.deaccScheduleId)
        self.deaccScheduleId = 0
      end
      self.deaccScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(deaccelerateScrolling, 0, false)
    else 
      --unhighlight menu 
      if self.menuIndex > 0 then 
        self:unhightlighMenu(self.menuIndex, true)
        self.menuIndex = 0
      end       
    end 
  end
end 

function HomeView:setBgImgPosition(fg_posX)
  if fg_posX == nil then 
    return 
  end 

  if fg_posX > self.offsetMaxX then 
    fg_posX = self.offsetMaxX
  end
  
  if fg_posX < self.offsetMinX then
    fg_posX = self.offsetMinX
  end
  
  self.node_fg:setPositionX(fg_posX)
  
  local deltaX2 = (fg_posX - self.preBgPosX)*0.25
  self.node_bg:setPositionX(self.preBgPosX+deltaX2)
end 


function HomeView:checkMenuTouch(menusArray,x,y)
  for k,v in pairs(menusArray) do
    local size = v[1]:getContentSize()
    local ap = tolua.cast(v[1]:getAnchorPoint(), "CCPoint")
    local pos = v[1]:convertToNodeSpace(ccp(x, y))
    if pos.x > 0 and pos.x < size.width and pos.y > 0 and pos.y < size.height then
      return k 
    end 
  end

  return 0
end

function HomeView:hightlighMenu(idx)
  echo(" hightlighMenu:",idx)
end 

function HomeView:unhightlighMenu(idx, isAnim)
  echo(" unhightlighMenu:",idx,isAnim)
  if idx > 0 then
    self.menusArray[idx][1]:stopAllActions()
    self.menusArray[idx][1]:setPosition(ccp(0,0))
    self.menusArray[idx][1]:setScale(1.0)
    if isAnim == true then 
      local duration = 0.08
      local moveby = CCEaseIn:create(CCMoveBy:create(duration, ccp(0, 20)), 3)
      local scaleto = CCScaleTo:create(duration, 1.1)
      local action1 = CCSpawn:createWithTwoActions(moveby, scaleto)

      local moveby2 = CCEaseIn:create(CCMoveBy:create(duration, ccp(0, -20)), 3)
      local scaleto2 = CCScaleTo:create(duration, 1.0)
      local action2 = CCSpawn:createWithTwoActions(moveby2, scaleto2)

      local array = CCArray:create()
      array:addObject(action1)
      array:addObject(action2)
      array:addObject(CCCallFunc:create(handler(self,self.menusArray[idx][3])))
      local seq = CCSequence:create(array)
      self.menusArray[idx][1]:runAction(seq)
    end
  end 
end 


function HomeView:AskForOnlineRewardResult(action,msgId,msg)
  echo("Ask For Online Reward Result =", msg.state)

  if msg.state == "Ok" then
    --show gained bonus
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i=1,table.getn(gainItems) do
      echo("----gained:", gainItems[i].configId, gainItems[i].count)
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
    end
    
    local player = GameData:Instance():getCurrentPlayer()
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)

    --start next count down
    -- self:showCountDownTime()
  elseif  msg.state == "NoMoreReward" then
    Toast:showString(self, _tr("has award all"), ccp(display.width/2, display.height*0.4))
  elseif  msg.state == "NeedConditions" then
    Toast:showString(self, _tr("pls_try_later"), ccp(display.width/2, display.height*0.4))
  elseif  msg.state == "UnknowConditions" then

  end
end 

function HomeView:systomRefresh(action,msgId,msg)
  echo("=== HomeView:systomRefresh")
  --横向菜单
  self:rejustExtMenuPosition(true)

  --下拉菜单
  self.actMenusItems = self:getValidActItems()
  self.node_actlist:setVisible(#self.actMenusItems > 0)
  self:showActMenuList()

  --更新tips
  self:updateMenuTips()   
end 

function HomeView:libaoCallback()
  echo("libaoCallback")

  local function startToGetBonus(isOk)
    echo("startToGetBonus")
    if isOk == true then
      local isEnough = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1) 
      if isEnough == false then 
        Toast:showString(self, _tr("bag is full"), ccp(display.width/2, display.height*0.4))
        return
      end
      net.sendMessage(PbMsgId.AskForOnlineReward)
    end
  end


  local bonusInfo = GameData:Instance():getOnlineBonusArray()
  local curRecvIdx = GameData:Instance():getCurrentPlayer():getOnlineRewardCount() + 1
  if curRecvIdx > table.getn(bonusInfo) then 
    Toast:showString(self, _tr("award_all_today"), ccp(display.width/2, display.height*0.4))
    return
  end

  local pop = PopupView:createBonusPopup(bonusInfo[curRecvIdx].bonus, startToGetBonus)
  self:addChild(pop)
end

function HomeView:taskCallback()
  self:getDelegate():dispTaskView()
end

function HomeView:livenessCallback()
  local view = LivenessView.new()
  view:setScale(0.2)
  view:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))  
  self:addChild(view)
end

function HomeView:signCallback()
  Activity:instance():entryActView(ActMenu.DAILY_SIGNIN, false)
end

function HomeView:rebateCallback()
  Activity:instance():entryActView(ActMenu.REBATE_TEN, false)
end 

function HomeView:exchangeCallback()
  Activity:instance():entryActView(ActMenu.EXCHANGE, false)
end 

function HomeView:ActsCallback()
  local view = HomeActView.new()
  view:setScale(0.2)
  view:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))  
  GameData:Instance():getCurrentScene():addChildView(view)
end 

function HomeView:BonusLevelUpCallback()
  if GameData:Instance():checkSystemOpenCondition(28, true) == false then 
    return false 
  end
  Activity:instance():entryActView(ActMenu.LEVELUP_BONUS, false)
end 

function HomeView:bossCallback()
  if Activity:instance():entryActView(ActMenu.BOSS, false) == false then 
    ControllerFactory:Instance():setCurrentControllerType(ControllerType.NONE)
  end 
end 

function HomeView:daySurpriseCallback()  
  local view = DaySurpriseView:create()
  view:setScale(0.2)
  view:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))    
  self:addChild(view)
end 

function HomeView:festivalGiftCallback() 
  local view = FestivalGiftView:create()
  view:setScale(0.2)
  view:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))    
  self:addChild(view)
end 

function HomeView:rebateCardCallback()  --充值送张飞
  Activity:instance():entryActView(ActMenu.CHARGE_REBATE, false)
end 

function HomeView:talentAnimFinishCallback()
  if self.layer_talentaward:isVisible() then
    self.mAnimationManagerIcon:runAnimationsForSequenceNamed("income")
  end
end 

function HomeView:getTipByIndex(idx)
  local tip = nil 
  local nodeParent = nil 
  local package = GameData:Instance():getCurrentPackage()

  if idx == 1 then  --card
    local isEnough = package:checkCardBagEnoughSpace(1)
    local isEnough2 = package:checkEquipBagEnoughSpace(1)
    if (isEnough == false) or (isEnough2 == false) then 
      tip = TipPic.new("#tipFull.png")
    end
    nodeParent = self.name_kapai
  elseif idx == 2 then --bag
    if package:checkItemBagEnoughSpace(1) == false then
      tip = TipPic.new("#tipFull.png")
    elseif package:getIsBoxQCardValid() == true then 
      tip = TipPic.new() 
    end 
    nodeParent = self.name_cangku
  elseif idx == 3 then --friend
    if Friend:Instance():hasNewEvent() == true  then 
      tip = TipPic.new() 
    end
    nodeParent = self.name_haoyou
  elseif idx == 4 then --task
    local hasNewAward = Quest:Instance():hasNewAward()
    if hasNewAward == true then
      tip = TipPic.new() 
    end
    nodeParent = self.node_task
  elseif idx == 5 then --mail
    local hasNewSysMail = MailBox:instance():getHasNewMailForSys()
    local hasNewPrivMail = MailBox:instance():getHasNewMailForPriv()
    if hasNewSysMail == true or hasNewPrivMail == true then
      tip = TipPic.new() 
    end
    nodeParent = self.node_mail
  elseif idx == 6 then --achievement
    if Achievement:instance():hasNewEvent() == true  then
      tip = TipPic.new() 
    end
    nodeParent = self.name_chengjiu
  elseif idx == 7 then --lottery 
    if Mall:Instance():getHasLotteryNewEvent() == true then 
      tip = TipPic.new() 
    end 
    nodeParent = self.name_dianjiangtai
  elseif idx == 8 then --liveness
    local flag = Liveness:instance():canFetchLivenessAwards()
    if flag == false then 
      flag = Liveness:instance():hasNewItemToFinish()
    end 
    if flag == true then
      tip = TipPic.new() 
    end
    nodeParent = self.node_liveness
  elseif idx == 9 then --sign
    if self.node_sign:isVisible() == true then 
      local signFlag = Activity:instance():getIsAlreadySigned()
      if signFlag == false then
        tip = TipPic.new() 
      end 
    end 
    nodeParent = self.node_sign
  elseif idx == 10 then --activity stage
    local canAward = ActivityStages:Instance():hasStageToChallenge()
    if canAward == true then
       tip = TipPic.new() 
    end
    nodeParent = self.name_fuben
  elseif idx == 11 then --mine 
    local canWork = Mining:Instance():hasNewEvent()
    if canWork == true then
      tip = TipPic.new() 
    end
    nodeParent = self.name_kuangchang
  elseif idx == 12 then --talent
    if Talent:Instance():hasAnyoneCanUpdate() == true then 
      tip = TipPic.new() 
    end 
    nodeParent = self.name_tianfu

  elseif idx == 13 then --act menu list 
    if self:getActMenuTipsFlag() == true then 
      tip = TipPic.new() 
    end 
    nodeParent = self.node_actlist

    if Home:instance():getIsHomeActListVisible() and self.actTblview ~= nil then 
      echo("=== update act table view list..")
      self.actTblview:reloadData()
    end 

  elseif idx == 14 then -- play state
    local cards = GameData:Instance():getCurrentPackage():getBattleCards()
    for key, card in pairs(cards) do
    	local enabledTip = GameData:Instance():getCurrentPackage():checkCardHasTip(card)
    	if enabledTip == true then
    	  tip = TipPic.new() 
    	  break
    	end
    end
    nodeParent = self.node_playState
  
  elseif idx == 15 then -- card soul shop 
    if Shop:instance():getTipsFlag(ShopCurViewType.Soul) then 
      tip = TipPic.new() 
    end 
    nodeParent = self.name_lianhun 

  elseif idx == 16 then -- vip shop 
    if Shop:instance():getTipsFlag(ShopCurViewType.VIP) then 
      tip = TipPic.new() 
    end 
    nodeParent = self.name_vipshop 

  elseif idx == 17 then -- boss 
    local boss = Activity:instance():getCurActiveBoss()
    if boss ~= nil and boss:getBossState()==BossState.FIGHTING then 
      local leftSec = boss:getFrozenTime()  - Clock:Instance():getCurServerUtcTime()
      if leftSec <= 0 then 
        tip = TipPic.new() 
      else 
        self:performWithDelay(function()
                                self:updateMenuTips()
                              end,  
          leftSec)
      end 
      nodeParent = self.node_boss 
    end 

  elseif idx == 18 then -- y day's activity mission 
    local _, hasTips = Activity:instance():getActMissionTipsState()
    if hasTips then 
      tip = TipPic.new() 
    end 
    nodeParent = self.bn_serverOpen 

  elseif idx == 19 then --通天塔
    if Bable:instance():hasBonusForFetch() then 
      tip = TipPic.new() 
    end 
    nodeParent = self.name_tongtianta

  elseif idx == 20 then --聊天
    if Chat:Instance():getHasNewMessage() then 
      tip = TipPic.new() 
    end 
    nodeParent = self.node_chat    
  end

  --remove tips
  if tip == nil and nodeParent ~= nil then 
    if nodeParent:getChildByTag(200) then 
      nodeParent:removeChildByTag(200,true)
    end 
  end 

  return tip, nodeParent
end

function HomeView:updateMenuTips()
  echo("---updateTips---")
  -- for i = 1, 20 do 
  --   local tipImg, node = self:getTipByIndex(i)
  --   if tipImg ~= nil and node ~= nil then 
  --     local img = node:getChildByTag(200)
  --     if img ~= nil then 
  --       node:removeChildByTag(200,true)
  --     end 
  --     local size = node:getContentSize()
  --     tipImg:setPosition(ccp(size.width-5, size.height-5))
  --     node:addChild(tipImg, 10, 200)
  --   end 
  -- end
end 

function HomeView:updateTalentData()
	if(not Talent.CanOpenCheck() or not GameData:Instance():getCurrentPlayer():isTalentInited()) then
		return
	end

	local currentProduct,_,isProduceFull = Talent.getCurrentProduct()
	local currentTalentPoint = GameData:Instance():getCurrentPlayer():getTalentBankPoints()
	if(currentTalentPoint ~= self.oldTalentValue ) then
		self.homeTop.scrollTelentPoint:setNumberExt(currentTalentPoint, _tr("wan"))
		self.oldTalentValue = currentTalentPoint
	end
	--if(isBankFull) then
		--self:_ShowTalentAward(false)
	--else
		local file = isProduceFull and "#talent_income_full.png" or "#talent_income.png"
		MessageBox.Help.changeSpriteImage(self.sprite_talent_award,file)
		self:_ShowTalentAward(currentProduct ~= 0)
	--end
end

function HomeView:_ShowTalentAward(b)
	self.sprite_talent_award:setVisible(b)
	self.layer_talentaward:setTouchEnabled(b)
	if (b) then
		self.mAnimationManagerIcon:runAnimationsForSequenceNamed("income")
	end
end

function HomeView:enterBackground()
  echo("---enterBackground---")
  if self.countDownScheduler > 0 then 
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.countDownScheduler)
    self.countDownScheduler = 0
  end 


  self:stopBgAnimEffect()
end

function HomeView:enterForeground()
  echo("---enterForeground---")
  -- self:showCountDownTime()
  --从后台进入前台时需要延时播放序列帧/粒子特效,否则会崩溃
  self:performWithDelay(function ()
                          echo("delay playBgAnimEffect")
                          self:playBgAnimEffect()
                        end,
                        1.2)
end

function HomeView:keyBackClicked()

  local scene = GameData:Instance():getCurrentScene()
  local function ExitGameCallBack()
    local guideLayer = GuideLayer:createGuideLayer()
    guideLayer:skip()
  end
  if scene~= nil then
    scene:removeChildByTag(123321)
  end
  local str = _tr("confirm_quit")
  local pop = PopupView:createTextPopup(str,ExitGameCallBack)
  pop:setTouchPriority(-999999)
  scene:addChild(pop,999999,123321)
end

function HomeView:illustratedCallback()
  echo("illustratedCallback")
  if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.CARD_ILLUSTRATED_CONTROLLER then
     return
  end

  local controller = ControllerFactory:Instance():create(ControllerType.CARD_ILLUSTRATED_CONTROLLER)
  controller:enter()
end 

function HomeView:activityCallback()
  echo("activityCallback")
  if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.ACTIVITY_CONTROLLER then
     return
  end

  Activity:instance():entryActView(ActMenu.ARMY, false)
end 

function HomeView:friendsCallback()
  echo("friendsCallback")
  if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.FRIEND_CONTROLLER then
     return
  end

  if GameData:Instance():checkSystemOpenCondition(11, true) == false then 
    return 
  end 

  local friendController =  ControllerFactory:Instance():create(ControllerType.FRIEND_CONTROLLER)
  friendController:enter()
end 


function HomeView:bagCallback()
  echo("bagCallback")
  local controller = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  controller:enter() 
end 

function HomeView:mineCallback()
  echo("mineCallback")

  if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.MINING_CONTROLLER then
    return
  end 

  if GameData:Instance():checkSystemOpenCondition(3, true) == false then 
    return 
  end 

  local controller = ControllerFactory:Instance():create(ControllerType.MINING_CONTROLLER)
  controller:enter() 
end 

function HomeView:vipShopCallback() 
  echo("vipShopCallback") 
  if self.isVipShopOpen then 
    local controller = ControllerFactory:Instance():create(ControllerType.SHOP_VIP_CONTROLLER)
    controller:enter() 
  end 
end 

function HomeView:equipmentCallback()
  local ret, hit = Equipment.CanOpenCheck(viewIdx)
	if(not ret) then
		Toast:showString(GameData:Instance():getCurrentScene(), hit, ccp(display.cx, display.height*0.4))
		return 
	end

  if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.EQUIPMENT_CONTROLLER then
     return
  end

  if GameData:Instance():checkSystemOpenCondition(23, true) == false then 
    return 
  end 

  local levelUpController = ControllerFactory:Instance():create(ControllerType.EQUIPMENT_CONTROLLER)
  levelUpController:enter(1,nil)
end

function HomeView:lotteryCallback()
  echo("lotteryCallback")
  if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.LOTTERY_CONTROLLER then
     return
  end

  local controller = ControllerFactory:Instance():create(ControllerType.LOTTERY_CONTROLLER)
  controller:enter()
end 

function HomeView:achievementCallback()
  echo("achievementCallback")
  if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.ACHIEVEMENT_CONTROLLER then
     return
  end

  --成就模块开启条件
  if GameData:Instance():checkSystemOpenCondition(39, true) == false then 
    return 
  end 

  local controller = ControllerFactory:Instance():create(ControllerType.ACHIEVEMENT_CONTROLLER)
  if GameData:Instance():checkSystemOpenCondition(17, false) == true then --官职未开启则进入综合成就项
    controller:enter(AchievementType.Official)
  else 
    controller:enter(AchievementType.Comprehensive)
  end 
end 

function HomeView:mailCallback()
  echo("mailCallback")
  if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.MAIL_CONTROLLER then
     return
  end

  local mailController = ControllerFactory:Instance():create(ControllerType.MAIL_CONTROLLER)
  mailController:enter(1)
end 

function HomeView:cardBagCallback()
  echo("cardBagCallback")
  if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.CARDBAG_CONTROLLER then
     return
  end

  local controller = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  controller:enter()
end

function HomeView:lianhunCallback()
  if GameData:Instance():checkSystemOpenCondition(27, true) == false then 
    return 
  end 

  local controller = ControllerFactory:Instance():create(ControllerType.CARD_SOUL_CONTROLLER)
  controller:enter(CardSoulMenu.SHOP)
end 

function HomeView:talentAwardCallback()
	net.sendMessage(PbMsgId.TalentGetPointC2S)
end

function HomeView:talentCallback()

  if ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.TALENT_CONTROLLER then
     return
  end
  local ret,hit = Talent.CanOpenCheck()
  if not ret then
    Toast:showString(GameData:Instance():getCurrentScene(), hit, ccp(display.cx, display.height*0.4))
    return
  end

  local controller = ControllerFactory:Instance():create(ControllerType.TALENT_CONTROLLER)
  controller:enter()
end 

function HomeView:activityStageCallback()
  if GameData:Instance():checkSystemOpenCondition(19, true) == false then 
    return 
  end 

  local controller = ControllerFactory:Instance():create(ControllerType.ACTIVITY_STAGE_CONTROLLER)
  controller:enter() 
end 

function HomeView:rankCallback()
  local view = HomeRankView.new()
  self:getDelegate():getScene():addChild(view, 1000)
end 

function HomeView:jingjiCallback()
  if GameData:Instance():checkSystemOpenCondition(41, true) == false then 
    return 
  end 
  local controller = ControllerFactory:Instance():create(ControllerType.PVP_RANK_MATCH_CONTROLLER)
  controller:enter()
end 

function HomeView:tuhaoCallback()
  if Home:instance():hasRechargeTopData() == false then 
    Toast:showString(GameData:Instance():getCurrentScene(), _tr("open_torrow"), ccp(display.cx, display.cy))
    return 
  end 
  
  local view = RechargeTopView.new()
  GameData:Instance():getCurrentScene():addChildView(view) 
end 

function HomeView:gongHuiCallback()

  if GameData:Instance():getLanguageType() == LanguageType.JPN then 
    if GameData:Instance():checkSystemOpenCondition(43, false) == false then 
      Toast:showString(self, _tr("not_open2"), ccp(display.cx, display.cy))
      return 
    end 
  else 
    if GameData:Instance():checkSystemOpenCondition(43, true) == false then 
      return 
    end 
  end 

  local controller = ControllerFactory:Instance():create(ControllerType.GUILD_CONTROLLER)
  controller:enter()
end 

function HomeView:tongtiantaCallback()
  if GameData:Instance():checkSystemOpenCondition(44, true) == false then 
    return 
  end 
  
  local controller = ControllerFactory:Instance():create(ControllerType.BABEL_CONTROLLER)
  controller:enter()  
end 

function HomeView:getMenuSprite(index)
  if index <= #self.menusArray then 
    return self.menusArray[index][1]
  end
  return nil 
end

function HomeView:scrollToMenu(guideId)
  if guideId == nil then 
    return 
  end 

  Home:instance():setPreViewPositionX(self.orgFgPosX, self.orgBgPosX) 
  self.preBgPosX = self.orgBgPosX 

  for k, v in pairs(self.menusArray) do 
    if guideId == v[4] then 
      local posx = v[1]:getParent():getPositionX() 
      local centerX = self.orgFgPosX - posx 
      echo("====centerX", centerX)
      self:setBgImgPosition(centerX)
      break 
    end 
  end 
end 

function HomeView:addMaskLayer()
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)
end 

function HomeView:removeMaskLayer()
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 

function HomeView:setCardHeaderListScrollEnable(isEnable)
  if isEnable == false then
     self._lastY = self.tableView:getContainer():getPositionY()
  end
  self._cardListScrollEnable = isEnable
end 

function HomeView:getCardHeaderListScrollEnable()
  return self._cardListScrollEnable
end 

function HomeView:playCloudAnim()
  echo("=== HomeView:playCloudAnim")
  self.node_cloud:stopAllActions()
  local function resetcloudPos()
    self.node_cloud:setPosition(ccp(display.width+100, display.height))
  end 
  local act1 = CCCallFunc:create(resetcloudPos)
  local act2 = CCMoveTo:create(40, ccp(-600,display.height))
  local action3 = CCRepeatForever:create(CCSequence:createWithTwoActions(act1, act2))
  self.node_cloud:runAction(action3)
end 

function HomeView:rejustExtMenuPosition(bSignMenuUpdate)
  echo("===rejustExtMenuPosition")

  self.node_allIcons:setPositionY(display.height-180)
  self.menu_mail:setTouchPriority(self.actMenuPriority)
  self.menu_task:setTouchPriority(self.actMenuPriority)
  self.menu_liveness:setTouchPriority(self.actMenuPriority)
  self.menu_sign:setTouchPriority(self.actMenuPriority)
  self.menu_boss:setTouchPriority(self.actMenuPriority)
  self.menu_arena:setTouchPriority(self.actMenuPriority)
  self.bn_actlist:setTouchPriority(self.actMenuPriority)
  self.bn_serverOpen:setTouchPriority(self.actMenuPriority)
  self.menu_chat:setTouchPriority(self.actMenuPriority)
  
  self.node_chat:setPosition(ccp(display.cx+250, 180))


  if bSignMenuUpdate ~= nil and bSignMenuUpdate == true then 
    local offset = 83

    --task
    local pos_x = self.node_mail:getPositionX()+offset
    self.node_task:setPositionX(pos_x)
    pos_x = pos_x + offset

    --liveness 
    self.node_liveness:setPositionX(pos_x)
    pos_x = pos_x + offset

    --sign 
    if Activity:instance():getIsAlreadySigned() == true then 
      self.node_sign:setVisible(false)
    else 
      self.node_sign:setVisible(true)
      self.node_sign:setPositionX(pos_x)
      pos_x = pos_x + offset
    end 

    --Boss
    if Activity:instance():getBossTipFlag() == true then --boss
      self.node_boss:setVisible(true)
      self.node_boss:setPositionX(pos_x)
      pos_x = pos_x + offset 

      self.node_boss:removeChildByTag(101)
      local fire,offsetX,offsetY,duration = _res(5020189)
      if fire ~= nil then
        fire:setPosition(ccp(5, 2))
        self.node_boss:addChild(fire, 10, 101)
        fire:getAnimation():play("default")
      end
    end 

    --arena 武斗大会
    local _, state = Arena:Instance():getLeftTime()
    if state == 2 then 
      self.node_arena:setVisible(true)
      self.node_arena:setPositionX(pos_x)
      pos_x = pos_x + offset 
    end 

    --活动列表菜单
    self.node_actlist:setVisible(#self.actMenusItems > 0)
    self:showActMenuList() 
  end 
end 

--下拉菜单tips
function HomeView:getActMenuTipsFlag(menuType)
  
  local function getTipFlagForMenuType(menuType)
    local flag = false 

    if menuType == self.Act.DaySurprise then        --每日惊喜
      flag = Activity:instance():getCanFetchSurpriseBonus()

    elseif menuType == self.Act.FestivalGift then   --节日领奖
      flag = Activity:instance():isFestivalGiftValid()

    elseif menuType == self.Act.Rebate then         --十抽返利(全民免单)
      flag = Mall:Instance():hasTenLotteryRebateReward()

    elseif menuType == self.Act.BonusLevelUp then   --升级领奖
      flag = Activity:instance():getHasBonusForLevelup()
    end 

    return flag
  end 

  local hasTip = false 
  if menuType ~= nil then --只检查指定菜单类型tips
    hasTip = getTipFlagForMenuType(menuType)

  else --检查所有菜单类型tips
    for k, v in pairs(self.actMenusItems) do 
      if getTipFlagForMenuType(v[1]) then 
        hasTip = true 
        break 
      end 
    end 
  end 
  
  return hasTip
end 

--获取有效的下拉菜单项
function HomeView:getValidActItems()
  local tbl = {}

  for k, v in pairs(self.actListArray) do 
    local flag = false 
    if v[1] == self.Act.VipInfo then --VIP特权
      if GameData:Instance():getLanguageType() == LanguageType.JPN then 
        flag = false 
      else 
        flag = true 
      end 
      
    elseif v[1] == self.Act.ActList then --活动列表
      local listData = Activity:instance():getHomeActData() 
      flag = #listData > 0 

    elseif v[1] == self.Act.BonusLevelUp then --升级领奖
      --根据奖励的等级来更新数组内的 icon 图片名
      local _, bonusLevel, isFinish = Activity:instance():getHasBonusForLevelup() 
      if isFinish then 
        flag = false 
      else 
        v[2] = string.format("#bn_bonusLv_%d.png", bonusLevel)
        v[3] = v[2]
        flag = true 
      end 
    elseif v[1] == self.Act.Rebate then         --十抽返利
      if GameData:Instance():getLanguageType() == LanguageType.JPN then 
        flag = false 
      else 
        flag = Mall:Instance():isShowRebateView(2)
      end 

    elseif v[1] == self.Act.Exchange then       --兑换活动
      flag = Activity:instance():getActivityLeftTime(ACI_ID_EXCHANGE) > 0

    elseif v[1] == self.Act.DaySurprise then    --每日惊喜
      flag = Activity:instance():isDaySurpriseValid()

    elseif v[1] == self.Act.FestivalGift then   --节日领奖
      flag = Activity:instance():isFestivalGiftValid()

    elseif v[1] == self.Act.RebateCard then     --充值豪礼
      flag = Activity:instance():getActivityLeftTime(ACI_ID_CHARGE_REBATE) > 0

    elseif v[1] == self.Act.ChargeBonus then    --累计充值
      flag = Activity:instance():getActivityLeftTime(ACI_ID_CHARGE_BONUS) > 0

    elseif v[1] == self.Act.MoneyConsume then   --元宝消耗
      flag = Activity:instance():getActivityLeftTime(ACI_ID_CONSUME_MONEY) > 0

    elseif v[1] == self.Act.BigWheel then       --大转盘
      flag = Activity:instance():getActivityLeftTime(ACT_ID_BIG_WHEEL) > 0

    elseif v[1] == self.Act.FirstCharge then    --首冲
      flag = GameData:Instance():getCurrentPlayer():getRechargeMoneyCount() < 1 

    elseif v[1] == self.Act.QuickMoney then     --摇元宝
      flag = Activity:instance():getActivityLeftTime(ACT_ID_QUICK_MONEY) > 0

    elseif v[1] == self.Act.CardReplace then    --交换卡牌
      flag = Activity:instance():getActivityLeftTime(ACT_ID_CARD_REPLACE) > 0
      
    end 

    if flag then 
      table.insert(tbl, v)
    end 
  end 

  return tbl 
end 

--下拉活动列表
function HomeView:showActMenuList()
  local function tableCellTouched(tblView,cell)
    if Home:instance():getIsHomeActListVisible() then 
      local idx = cell:getIdx()
      self.actMenusItems[idx+1][4]()
    end 
  end

  local function tableCellHighLight(table, cell)
    local idx = cell:getIdx()
    local img = self.cellItemsImg[idx+1]
    if img ~= nil then 
      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.actMenusItems[idx+1][3])
      if frame ~= nil then 
        img:setDisplayFrame(frame)
      end 
      img:setScale(1.1)
    end 
  end 

  local function tableCellUnhighLight(table, cell)
    local idx = cell:getIdx()
    local img = self.cellItemsImg[idx+1]
    if img ~= nil then 
      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.actMenusItems[idx+1][2])
      if frame ~= nil then 
        img:setDisplayFrame(frame)        
      end 
      img:setScale(1.0)
    end 
  end

  local function tableCellAtIndex(tblView, idx)
    local cell = tblView:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local node = display.newNode()
    local item = self.actMenusItems[idx+1] 
    local img = display.newSprite(item[2]) 
    node:addChild(img)

    if self:getActMenuTipsFlag(item[1]) then 
      local tip = TipPic.new()
      tip:setPosition(ccp(30, 28))
      node:addChild(tip)
    end 
    node:setPosition(ccp(self.actCellWidth/2, self.actCellHeight/2))
    cell:addChild(node)
    self.cellItemsImg[idx+1] = img 

    return cell
  end
  
  local function cellSizeForTable(tblView,idx)
    return self.actCellHeight,self.actCellWidth
  end

  local function numberOfCellsInTableView(tblview)
    return self.actTotalCells
  end

  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/home/home_icons.plist")

  self.cellItemsImg = {}
  self.actCellWidth = self.node_actListContainer:getContentSize().width
  self.actCellHeight = 95
  self.actTotalCells = #self.actMenusItems
  echo("=== act menu count:", self.actTotalCells)

  self.node_actListContainer:removeAllChildrenWithCleanup(true)

  --create mask layer 
  local layer = CCLayer:create()
  self.node_actListContainer:addChild(layer)
  layer:addTouchEventListener(function(event, x, y)
                              if event == "began" then
                                if Home:instance():getIsHomeActListVisible() then 
                                  local pos = self.sprite9_btnListBg:convertToNodeSpace(ccp(x, y))
                                  local size = self.sprite9_btnListBg:getContentSize()
                                  if pos.x > 0 and pos.x < size.width and pos.y > 0  and pos.y < size.height then 
                                    echo(" touch on btn menu list...")
                                    return true
                                  end
                                end                  
                                return false
                              end
                          end,
                false, self.actMenuPriority+1, true)
  layer:setTouchEnabled(true)  

  --create table view , default hide 
  local viewSize = CCSizeMake(self.actCellWidth, math.min(5,self.actTotalCells)*self.actCellHeight+30)
  self.node_actListContainer:setContentSize(viewSize)
  self.node_actListContainer:setPositionY(-viewSize.height-40)
  self.sprite9_btnListBg:setContentSize(CCSizeMake(viewSize.width, viewSize.height+50))

  self.actTblview = CCTableView:create(viewSize)
  self.actTblview:setDirection(kCCScrollViewDirectionVertical)
  self.actTblview:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.actTblview:setTouchPriority(self.actMenuPriority)
  self.node_actListContainer:addChild(self.actTblview)

  -- self.actTblview:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.actTblview:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.actTblview:registerScriptHandler(tableCellHighLight,CCTableView.kTableCellHighLight)
  self.actTblview:registerScriptHandler(tableCellUnhighLight,CCTableView.kTableCellUnhighLight)   
  self.actTblview:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.actTblview:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.actTblview:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  self.actTblview:reloadData()

  --当有新手引导时收起下拉菜单
  self.bn_actlist:setZOrder(self.sprite9_btnListBg:getZOrder()+1)
  if Guide:Instance():getGuideLayer() == nil and Home:instance():getIsHomeActListVisible() == true then
    self.node_tbview:setVisible(true) 
  else 
    self.node_tbview:setVisible(false)
  end 
end 

--下拉活动列表
function HomeView:actListCallback()

  if self.actTblview == nil then 
    return
  end

  local isActMenuListShowing = Home:instance():getIsHomeActListVisible()
  isActMenuListShowing = not isActMenuListShowing 
  Home:instance():setIsHomeActListVisible(isActMenuListShowing)
  self.sprite_actArrowUp:setVisible(isActMenuListShowing)

  local function updateViewSize()
    local viewSize = self.actTblview:getViewSize()
    local scrollOffset = 30
    local targetViewSize = CCSizeMake(self.actCellWidth, math.min(5,self.actTotalCells)*self.actCellHeight+30)

    if isActMenuListShowing == true then
      --upToDown
      if viewSize.height > targetViewSize.height - scrollOffset then 
        viewSize.height = targetViewSize.height
        if self.actMenuScheduler ~= nil then 
          self:unschedule(self.actMenuScheduler)
          self.actMenuScheduler = nil 
        end
      else 
        viewSize.height = viewSize.height + scrollOffset
      end 
      self.node_tbview:setVisible(true)
      self.actTblview:setViewSize(viewSize)
      self.actTblview:setPositionY(targetViewSize.height-viewSize.height)
      self.sprite9_btnListBg:setContentSize(CCSizeMake(viewSize.width, viewSize.height+50))
    else 
      --downToUp
      if viewSize.height < scrollOffset then 
        viewSize.height = scrollOffset

        if self.actMenuScheduler ~= nil then 
          self:unschedule(self.actMenuScheduler)
          self.actMenuScheduler = nil 
        end
        self.node_tbview:setVisible(false)
      else 
        viewSize.height = viewSize.height - scrollOffset     
      end

      self.actTblview:setViewSize(viewSize)
      self.actTblview:setPositionY(targetViewSize.height-viewSize.height)
      self.sprite9_btnListBg:setContentSize(CCSizeMake(viewSize.width, viewSize.height+50))
    end
  end 


  if self.actMenuScheduler ~= nil then 
    self:unschedule(self.actMenuScheduler)
    self.actMenuScheduler = nil 
  end
  self.actMenuScheduler = self:schedule(updateViewSize, 0)
end 

--7天活动
function HomeView:serverOpenCallback()
  if self.bn_serverOpen:isVisible() then 
    local layer = ActivityMissionView.new()
    self:addChild(layer)
  end 
end 


function HomeView:vipinfoCallback()
  Activity:instance():entryActView(ActMenu.VIP_PRIVILEGE, false)
end 

function HomeView:chatCallback()
  echo("chatCallback")
  local chatView = ChatView.new(Chat.ChannelWorld)
  GameData:Instance():getCurrentScene():addChildView(chatView)  
end 

function HomeView:playBgAnimEffect()
  echo("=== playBgAnimEffect")
  self:playCloudAnim()


  --1. frame anim

  --flag for cardBag 
  self.sprite_kapai0:removeAllChildrenWithCleanup(true)
  local flag2,offsetX,offsetY,duration = _res(5020165)
  if flag2 ~= nil then
    flag2:setPosition(ccp(94, 150))
    self.sprite_kapai0:addChild(flag2, -1)
    flag2:getAnimation():play("default")
  end

  -- light for lianhun
  self.sprite_lianhun0:removeAllChildrenWithCleanup(true)
  local light,offsetX,offsetY,duration = _res(5020205)
  if light ~= nil then
    light:setPosition(ccp(100, 98))
    self.sprite_lianhun0:addChild(light)
    light:getAnimation():play("default")
  end  

  --circle for lottery 
  self.sprite_dianjiangtai0:removeAllChildrenWithCleanup(true)
  local circle,offsetX,offsetY,duration = _res(5020160)
  if circle ~= nil then
    circle:setPosition(ccp(95, 90))
    self.sprite_dianjiangtai0:addChild(circle)
    circle:getAnimation():play("default")
  end   

  --shining for activity stage 
  self.sprite_huodongfuben0:removeAllChildrenWithCleanup(true)
  local shining,offsetX,offsetY,duration = _res(5020172)
  if shining ~= nil then
    shining:setPosition(ccp(98, 108))
    self.sprite_huodongfuben0:addChild(shining)
    shining:getAnimation():play("default")
  end

  --smoke for equipment 
  -- self.sprite_zhuangbei0:removeAllChildrenWithCleanup(true)
  -- local e_light,offsetX,offsetY,duration = _res(5020200)
  -- if e_light ~= nil then
  --   e_light:setPosition(ccp(93, 88))
  --   self.sprite_zhuangbei0:addChild(e_light)
  --   e_light:getAnimation():play("default")
  -- end 

  --mine
  self.sprite_kuangchang0:removeAllChildrenWithCleanup(true)
  local m_light,offsetX,offsetY,duration = _res(5020206)
  if m_light ~= nil then
    m_light:setPosition(ccp(107, 95))
    self.sprite_kuangchang0:addChild(m_light)
    m_light:getAnimation():play("default")
  end 

  --tu hao 
  self.sprite_tuhao0:removeAllChildrenWithCleanup(true)
  local m_tuhao,offsetX,offsetY,duration = _res(5020211)
  if m_tuhao ~= nil then
    m_tuhao:setPosition(ccp(73, 105))
    self.sprite_tuhao0:addChild(m_tuhao)
    m_tuhao:getAnimation():play("default")
  end 

  --vip shop 
  local action = CCMoveBy:create(1.5, ccp(0, 30))
  local action2 = CCMoveBy:create(1.5, ccp(0, -30))
  local seq = CCSequence:createWithTwoActions(action,action2)
  self.node_vipshop:runAction(CCRepeatForever:create(seq))

  local sp1 = CCSpawn:createWithTwoActions(CCMoveBy:create(1.5, ccp(0, 20)), CCScaleTo:create(1.5, 0.8))
  local sp2 = CCSpawn:createWithTwoActions(CCMoveBy:create(1.5, ccp(0, -20)), CCScaleTo:create(1.5, 1.2))
  local seq2 = CCSequence:createWithTwoActions(sp1,sp2)
  self.vip_shadow:runAction(CCRepeatForever:create(seq2))

  self.sprite_vipshop0:removeAllChildrenWithCleanup(true)
  local m_vip,offsetX,offsetY,duration = _res(5020208)
  if m_vip ~= nil then
    m_vip:setPosition(ccp(82, 143))
    self.sprite_vipshop0:addChild(m_vip)
    m_vip:getAnimation():play("default")
  end 


  --little man walking
  self.node_walking:removeAllChildrenWithCleanup(true)
  local velocity = 32 
  local route1 = {ccp(-360, 266), ccp(-190, 160), ccp(200, 130), ccp(300, 135),ccp(730, -30)}
  local route2 = {ccp(-575, -180), ccp(-240, -97), ccp(-100, 5), ccp(230, 160), ccp(314, 331)}
  local a_walking1,offsetX,offsetY,duration = _res(5020192)
  if a_walking1 then 
    self.node_walking:addChild(a_walking1)
    a_walking1:getAnimation():play("default")

    local array = CCArray:create()
    local resetFunc1 = CCCallFunc:create(function() a_walking1:setPosition(route1[1]); a_walking1:setFlipX(false) end)
    array:addObject(resetFunc1)
    for i=1, #route1-1 do 
      array:addObject(CCMoveTo:create(route1[i]:getDistance(route1[i+1])/velocity , route1[i+1]))
    end 
    local resetFunc2 = CCCallFunc:create(function() a_walking1:setPosition(route2[#route2]); a_walking1:setFlipX(true) end)
    array:addObject(resetFunc2)
    for i=#route2, 2, -1 do 
      array:addObject(CCMoveTo:create(route2[i]:getDistance(route2[i-1])/velocity , route2[i-1]))
    end 
    local seq = CCSequence:create(array)
    a_walking1:runAction(CCRepeatForever:create(seq))
  end 

  local a_walking2,offsetX,offsetY,duration = _res(5020191)
  if a_walking2 then 
    self.node_walking:addChild(a_walking2)
    a_walking2:getAnimation():play("default")

    local array = CCArray:create()
    local resetFunc1 = CCCallFunc:create(function() a_walking2:setPosition(route2[1]); a_walking2:setFlipX(true) end)
    array:addObject(resetFunc1)
    for i=1, #route2-1 do 
      array:addObject(CCMoveTo:create(route2[i]:getDistance(route2[i+1])/velocity , route2[i+1]))
    end 
    local resetFunc2 = CCCallFunc:create(function() a_walking2:setPosition(route1[#route1]); a_walking2:setFlipX(false) end)
    array:addObject(resetFunc2)
    for i=#route1, 2, -1 do 
      array:addObject(CCMoveTo:create(route1[i]:getDistance(route1[i-1])/velocity , route1[i-1]))
    end 
    local seq = CCSequence:create(array)
    a_walking2:runAction(CCRepeatForever:create(seq))
  end 

  --flying birds
  self.node_birds:removeAllChildrenWithCleanup(true)
  self.node_birds:setPosition(ccp(0, 0))

  local flydura = math.sqrt(0.36*display.width*display.width+ 0.36*display.height*display.height)/77
  local bird1,offsetX,offsetY,duration = _res(5020164)
  if bird1 ~= nil then
    bird1:setPosition(ccp(display.width*0.6, -60))
    self.node_birds:addChild(bird1)
    bird1:getAnimation():play("default")
    local moveTo = CCMoveTo:create(flydura, ccp(-100, 0.62*display.height))
    local flyEnd1 = CCCallFunc:create(function() bird1:setPosition(ccp(display.width*0.6, -60)) end )
    local seq = CCSequence:createWithTwoActions(moveTo,flyEnd1)
    bird1:runAction(CCRepeatForever:create(seq))
  end
  local bird2,offsetX,offsetY,duration = _res(5020164)
  if bird2 ~= nil then
    bird2:setPosition(ccp(display.width*0.6+56, -78))
    self.node_birds:addChild(bird2)
    bird2:getAnimation():play("default")
    local moveTo2 = CCMoveTo:create(flydura, ccp(-100, 0.62*display.height))
    local flyEnd2 = CCCallFunc:create(function() bird2:setPosition(ccp(display.width*0.6+56, -78)) end )
    local seq2 = CCSequence:createWithTwoActions(moveTo2,flyEnd2)
    bird2:runAction(CCRepeatForever:create(seq2)) 
  end
  local bird3,offsetX,offsetY,duration = _res(5020164)
  if bird3 ~= nil then
    bird3:setPosition(ccp(display.width*0.6+70, -10))
    self.node_birds:addChild(bird3)
    bird3:getAnimation():play("default")
    local moveTo3 = CCMoveTo:create(flydura, ccp(-100, 0.62*display.height+60))
    local flyEnd3 = CCCallFunc:create(function() bird3:setPosition(ccp(display.width*0.6+70, -10)) end )
    local seq3 = CCSequence:createWithTwoActions(moveTo3,flyEnd3)
    bird3:runAction(CCRepeatForever:create(seq3))
  end
  local bird4,offsetX,offsetY,duration = _res(5020164)
  if bird4 ~= nil then
    bird4:setPosition(ccp(display.width*0.6+440, 0.3*display.height))
    self.node_birds:addChild(bird4)
    bird4:getAnimation():play("default")

    local moveTo4 = CCMoveTo:create(flydura, ccp(-100, 0.9*display.height))
    local flyEnd4 = CCCallFunc:create(function() bird4:setPosition(ccp(display.width*0.6+440, 0.3*display.height)) end )
    local seq4 = CCSequence:createWithTwoActions(moveTo4,flyEnd4)
    bird4:runAction(CCRepeatForever:create(seq4))
  end

  --2.particle effects:
  --flower anim
  -- self.sprite_fg:removeAllChildrenWithCleanup(true)
  -- local flower = _res(6010023)
  -- if flower ~= nil then
  --   flower:setPosition(ccp(630, 390))
  --   self.sprite_fg:addChild(flower)
  -- end
  -- local flower2 = _res(6010023)
  -- if flower2 ~= nil then
  --   flower2:setPosition(ccp(920, 490))
  --   self.sprite_fg:addChild(flower2)
  -- end

  --water wave
  local wave1 = _res(6010019)
  if wave1 ~= nil then
    wave1:setPosition(ccp(95, 447))
    self.sprite_fg:addChild(wave1)
  end
  local wave2 = _res(6010019)
  if wave2 ~= nil then
    wave2:setPosition(ccp(580, 330))
    self.sprite_fg:addChild(wave2)
  end
  -- local wave3 = _res(6010019)
  -- if wave3 ~= nil then
  --   wave3:setPosition(ccp(1325, 704))
  --   self.sprite_fg:addChild(wave3)
  -- end 

  --snow 
  -- if self.snowAnim ~= nil then 
  --   self.snowAnim:removeFromParentAndCleanup(true)
  --   self.snowAnim = nil 
  -- end 
  -- self.snowAnim = _res(6010009)
  -- if self.snowAnim ~= nil then 
  --   self:addChild(self.snowAnim)
  -- end 
end 

function HomeView:stopBgAnimEffect()
  echo("=== stopBgAnimEffect")
  self.node_cloud:stopAllActions()
  self.sprite_vipshop0:removeAllChildrenWithCleanup(true)
  self.sprite_kapai0:removeAllChildrenWithCleanup(true)
  self.sprite_lianhun0:removeAllChildrenWithCleanup(true)
  self.sprite_dianjiangtai0:removeAllChildrenWithCleanup(true)
  self.sprite_huodongfuben0:removeAllChildrenWithCleanup(true)
  self.node_birds:removeAllChildrenWithCleanup(true)

  self.sprite_kuangchang0:removeAllChildrenWithCleanup(true)
  self.sprite_fg:removeAllChildrenWithCleanup(true)
  -- self.sprite_zhuangbei0:removeAllChildrenWithCleanup(true)
  -- if self.snowAnim ~= nil then 
  --   self.snowAnim:removeFromParentAndCleanup(true)
  --   self.snowAnim = nil 
  -- end   
end 

--活动
function HomeView:showActivityPop()
  if GameData:Instance():getInitSysComplete() == true then   
    return false 
  end 

  local actCount = table.getn(Activity:instance():getActivityPopList())
  if actCount > 0 then 
    require("view.home.ActivityPopList")
    local actlist = ActivityPopList:create(true)
    GameData:Instance():getCurrentScene():addChildView(actlist)
    return true 
  end 

  return false 
end 

function HomeView:setMenuGrayIfNeed()

  local function setImgGray(imgObj, name)
    local index = nil 
    for k, v in pairs(self.menusArray) do 
      if v[1] == imgObj then 
        index = k 
        break 
      end 
    end 

    local pos = ccp(imgObj:getPosition())
    local zorder = imgObj:getZOrder()
    local parentNode = imgObj:getParent()
    imgObj:removeFromParentAndCleanup(true)
    imgObj = GraySprite:createWithSpriteFrameName(name)
    -- imgObj:setOpacity(50)
    parentNode:addChild(imgObj, -1)

    if index ~= nil then 
      self.menusArray[index][1] = imgObj
    end 

    return imgObj
  end 

  --friend
  if GameData:Instance():checkSystemOpenCondition(11, false) == false then 
    self.sprite_haoyou0 = setImgGray(self.sprite_haoyou0,"home_haoyou0.png")
  end

  --mine
  if GameData:Instance():checkSystemOpenCondition(3, false) == false then 
    self.sprite_kuangchang0 = setImgGray(self.sprite_kuangchang0, "home_kuangchang0.png")
  end

  --enhance
  -- if GameData:Instance():checkSystemOpenCondition(6, false) == false then 
  --   return 
  -- end 

  --talent
  if GameData:Instance():checkSystemOpenCondition(20, false) == false then 
    self.sprite_tianfu0 = setImgGray(self.sprite_tianfu0, "home_tianfu0.png")
  end

  --activity stage
  if GameData:Instance():checkSystemOpenCondition(19, false) == false then 
    self.sprite_huodongfuben0 = setImgGray(self.sprite_huodongfuben0,"home_huodongfuben0.png")
  end

  --equipment
  -- if GameData:Instance():checkSystemOpenCondition(11, false) == false then 
  --   self.sprite_zhuangbei0 = setImgGray(self.sprite_zhuangbei0, "home_tiejiangpu0.png")
  -- end 

  --soul
  if GameData:Instance():checkSystemOpenCondition(27, false) == false then 
    self.sprite_lianhun0 = setImgGray(self.sprite_lianhun0, "home_lianhun.png")
  end 
  
  --achievement
  if GameData:Instance():checkSystemOpenCondition(39, false) == false then 
    self.sprite_chengjiu0 = setImgGray(self.sprite_chengjiu0, "home_chengjiu0.png")
  end 

  --jingjichang
  if GameData:Instance():checkSystemOpenCondition(41, false) == false then 
    self.sprite_jingjichang0 = setImgGray(self.sprite_jingjichang0, "home_jingjichang0.png")
  end 

  --gonghui
  if GameData:Instance():checkSystemOpenCondition(43, false) == false then 
    self.sprite_gonghui0 = setImgGray(self.sprite_gonghui0, "home_gonghui0.png")
  end 

  if GameData:Instance():checkSystemOpenCondition(44, false) == false then 
    self.sprite_tongtianta0 = setImgGray(self.sprite_tongtianta0, "home_tongtianta.png")
  end 

  if GameData:Instance():getLanguageType() == LanguageType.JPN then --土豪雕像去掉, 中军帐移至土豪位置
    local nodeTuhao = self.sprite_tuhao0:getParent()
    nodeTuhao:setVisible(false)
  end 
end 

return HomeView 
