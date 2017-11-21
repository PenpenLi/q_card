require("view.BaseView")
require("view.component.Loading")
require("view.component.PopupView")
require("view.component.ProgressBarView")


ActivityBossBattleView = class("ActivityBossBattleView", BaseView)

function ActivityBossBattleView:ctor(boss)
  ActivityBossBattleView.super.ctor(self)
  
  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("speedupCallback",ActivityBossBattleView.speedupCallback)
  pkg:addFunc("rankListCallback",ActivityBossBattleView.rankListCallback)
  pkg:addFunc("startBattleCallback",ActivityBossBattleView.startBattleCallback)
  pkg:addFunc("quickBattleCallback",ActivityBossBattleView.quickBattleCallback)
  pkg:addFunc("plusCallback",ActivityBossBattleView.plusCallback)
  pkg:addFunc("helpCallback",ActivityBossBattleView.helpCallback)
  pkg:addFunc("backCallback",ActivityBossBattleView.backCallback)

  pkg:addProperty("node_boss","CCNode")
  pkg:addProperty("node_listInfo","CCNode")
  pkg:addProperty("node_plusContainer","CCNode")
  pkg:addProperty("node_arrow","CCNode")
  pkg:addProperty("node_progressBar","CCNode")

  pkg:addProperty("label_preCoolTime","CCLabelTTF")
  pkg:addProperty("label_coolTime","CCLabelTTF")
  pkg:addProperty("label_top1","CCLabelTTF")
  pkg:addProperty("label_top2","CCLabelTTF")
  pkg:addProperty("label_top3","CCLabelTTF")
  pkg:addProperty("sprite_gray","CCSprite")
  pkg:addProperty("sprite_red","CCSprite")
  pkg:addProperty("sprite_green","CCSprite")
  pkg:addProperty("sprite9_bg","CCScale9Sprite")
  
  pkg:addProperty("menu_speedUp","CCMenuItemSprite")
  pkg:addProperty("bn_battle","CCControlButton")
  pkg:addProperty("bn_quickBattle","CCControlButton")
  pkg:addProperty("bn_rank","CCControlButton")
  pkg:addProperty("bn_plusCard","CCControlButton")

  local layer,owner = ccbHelper.load("ActivityBossBattleView.ccbi","ActivityBossBattleViewCCB","CCLayer",pkg)
  self:addChild(layer)

  self.boss = boss
end

function ActivityBossBattleView:init()
  echo("---ActivityBossBattleView:init---")

  if self.boss == nil then 
    echo("empty boss !!!!")
    return 
  end

  self.isAnimPlaying = false 
  
  self:getDelegate():getBaseView():updateTopTip(ActMenu.BOSS)

  net.registMsgCallback(PbMsgId.BossFightClearTimeResultS2C, self, ActivityBossBattleView.clearFrozenTimeResult)
  net.registMsgCallback(PbMsgId.BossQueryRankResultS2C, self, ActivityBossBattleView.queryRankResult)
  net.registMsgCallback(PbMsgId.BossDamageNoticeS2C, self, ActivityBossBattleView.updateBossDamageResp)
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,ActivityBossBattleView.enterBackground),"APP_ENTER_BACKGROUND")
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,ActivityBossBattleView.enterForeground),"APP_WILL_ENTER_FOREGROUND")  
  self:initOutLineLabel()

  --boss image
  self:showBossImg(self.boss:getUnitPicId())

  --show plusCards
  self.isPlusCardsShowing = Activity:instance():getPlusCardVisible()
  self.plusCardsArray = self.boss:getExtPlusCards()
  self:showPlusCardHeader(self.plusCardsArray)

  --frozen time
  self:showFrozenTime()

  --show top 3 player's rank
  self:showTopRank()

  --show progressorBar
  self:initProgressorBar()


end

function ActivityBossBattleView:onEnter()
  echo("---ActivityBossBattleView:onEnter---")
  self:init()
end

function ActivityBossBattleView:onExit()
  echo("---ActivityBossBattleView:onExit---")

  Activity:instance():setPlusCardVisible(self.isPlusCardsShowing)

  net.unregistAllCallback(self)
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, "APP_ENTER_BACKGROUND")
  CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, "APP_WILL_ENTER_FOREGROUND")

  if self.scheduler ~= nil then 
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
    self.scheduler = nil
  end

  if self.plusCardScheduler ~= nil then 
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.plusCardScheduler)
    self.plusCardScheduler = nil
  end

  if self.progresser ~= nil then 
    self.progresser:stopProgressBar()
  end  
end

function ActivityBossBattleView:enterBackground()
  echo("=== ActivityBossBattleView:enterBackground")
  if self.scheduler ~= nil then 
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
    self.scheduler = nil
  end  
end 

function ActivityBossBattleView:enterForeground()
  echo("=== ActivityBossBattleView:enterForeground")
  self:showFrozenTime()
end

function ActivityBossBattleView:initOutLineLabel()
  self.label_preCoolTime:setString("")
  local preTime = ui.newTTFLabelWithOutline( {
                                            text = _tr("frozen_time"),
                                            font = self.label_preCoolTime:getFontName(),
                                            size = self.label_preCoolTime:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(32, 143, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            -- dimensions = self.label_preCoolTime:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  preTime:setPosition(ccp(self.label_preCoolTime:getPosition()))
  self.label_preCoolTime:getParent():addChild(preTime)

  self.label_coolTime:setString("")
  self.pOutLineCoolTime = ui.newTTFLabelWithOutline( {
                                            text = "00:00",
                                            font = self.label_coolTime:getFontName(),
                                            size = self.label_coolTime:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(32, 143, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            -- dimensions = self.label_coolTime:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  self.pOutLineCoolTime:setPosition(ccp(self.label_coolTime:getPosition()))
  self.label_coolTime:getParent():addChild(self.pOutLineCoolTime)

  self.label_top1:setString("")
  self.pTopName1 = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = self.label_top1:getFontName(),
                                            size = self.label_top1:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 255, 255),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            -- dimensions = self.label_top1:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  self.pTopName1:setPosition(ccp(self.label_top1:getPosition()))
  self.label_top1:getParent():addChild(self.pTopName1)

  self.label_top2:setString("")
  self.pTopName2 = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = self.label_top1:getFontName(),
                                            size = self.label_top1:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 255, 255),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            -- dimensions = self.label_top1:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  self.pTopName2:setPosition(ccp(self.label_top2:getPosition()))
  self.label_top2:getParent():addChild(self.pTopName2)

  self.label_top3:setString("")
  self.pTopName3 = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = self.label_top1:getFontName(),
                                            size = self.label_top1:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 255, 255),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            -- dimensions = self.label_top1:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  self.pTopName3:setPosition(ccp(self.label_top3:getPosition()))
  self.label_top3:getParent():addChild(self.pTopName3)
end 

function ActivityBossBattleView:speedupCallback()
  echo("speedupCallback")
  _playSnd(SFX_CLICK)

  if self.boss ~= nil then

    local function startToSpeedUp()
      local data = PbRegist.pack(PbMsgId.BossFightClearTimeC2S, {boss = self.boss:getId()})
      net.sendMessage(PbMsgId.BossFightClearTimeC2S, data)
    end

    echo("---has relive times=", self.boss:getSpeedUpCount())
    local index = self.boss:getSpeedUpCount() + 1
    local cost = Activity:instance():getReliveCost(index)
    local str = _tr("revive_will_cost_%{count}_money?", {count=cost})
    local pop = PopupView:createTextPopup(str, startToSpeedUp)
    self:addChild(pop)
  end
end

function ActivityBossBattleView:rankListCallback()
  echo("rankListCallback")
  _playSnd(SFX_CLICK)

  if self.boss ~= nil then
    local data = PbRegist.pack(PbMsgId.BossQueryRankC2S, {boss=self.boss:getId()})
    net.sendMessage(PbMsgId.BossQueryRankC2S, data)
  end
end

function ActivityBossBattleView:startBattleCallback()
  echo("startBattleCallback")
  _playSnd(SFX_CLICK)
  
  if self.boss ~= nil then
     self:getDelegate():reqBattle(self.boss,false)
  end
end

function ActivityBossBattleView:quickBattleCallback()
  echo("quickBattleCallback")
  _playSnd(SFX_CLICK)
  if self.boss ~= nil then
     self:getDelegate():reqBattle(self.boss,true)
  end
end

function ActivityBossBattleView:plusCallback()

  if self.tableView == nil then 
    return
  end

  self.isPlusCardsShowing = not self.isPlusCardsShowing 

  local function updateViewSize()
    -- echo("updateViewSize", self.tableView:getPositionY())

    local viewSize = self.tableView:getViewSize()
    local containerSize = self.node_plusContainer:getContentSize()
    local bgSize = self.sprite9_bg:getContentSize()
    local scrollOffset = 30

    self.node_listInfo:setVisible(true)

    if self.isPlusCardsShowing == true then
      --upToDown
      if viewSize.height > containerSize.height - scrollOffset then 
        viewSize.height = containerSize.height
        self.tableView:setViewSize(viewSize)
        self.tableView:setPositionY(0)

        if self.plusCardScheduler ~= nil then 
          CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.plusCardScheduler)
          self.plusCardScheduler = nil
        end
      else 
        viewSize.height = viewSize.height + scrollOffset
        self.tableView:setPositionY(containerSize.height-viewSize.height)
        self.tableView:setViewSize(viewSize)
      end 

      bgSize.height = viewSize.height + 160
      self.sprite9_bg:setContentSize(CCSizeMake(bgSize.width, bgSize.height))      
    else 
      --downToUp
      if viewSize.height < scrollOffset then 
        if self.plusCardScheduler ~= nil then 
          CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.plusCardScheduler)
          self.plusCardScheduler = nil
        end

        bgSize.height = 114
        self.sprite9_bg:setContentSize(CCSizeMake(bgSize.width, bgSize.height))   
        self.node_listInfo:setVisible(false)
      else 
        viewSize.height = viewSize.height - scrollOffset
        self.tableView:setPositionY(containerSize.height-viewSize.height)
        self.tableView:setViewSize(viewSize)

        bgSize.height = viewSize.height + 160
        self.sprite9_bg:setContentSize(CCSizeMake(bgSize.width, bgSize.height))        
      end
    end

    self.node_arrow:setPositionY(self.node_plusContainer:getPositionY()+self.tableView:getPositionY())
  end 

  if self.plusCardScheduler ~= nil then 
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.plusCardScheduler)
  end
  self.plusCardScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateViewSize, 0, false)
end 

function ActivityBossBattleView:helpCallback()
  echo("helpCallback")
  local help = HelpView.new()
  help:addHelpBox(1019, ccp(0, 50))
  help:addHelpItem(1020, self.bn_plusCard, ccp(30,-55), ArrowDir.LeftLeftUp)
  help:addHelpItem(1021, self.bn_rank, ccp(-20,-30), ArrowDir.RightUp)
  help:addHelpItem(1022, self.bn_quickBattle, ccp(-10,20), ArrowDir.CenterDown)
  help:addHelpItem(1023, self.bn_battle, ccp(30,20), ArrowDir.CenterDown)
  self:getDelegate():getScene():addChild(help, 1000)  
end 

function ActivityBossBattleView:backCallback()
  echo("backCallback")
  self:getDelegate():enterViewByIndex(ActMenu.BOSS, false) --back to boss list view
end 

function ActivityBossBattleView:clearFrozenTimeResult(action,msgId,msg)
  echo("clearFrozenTimeResult: ", msg.error)

  if msg.error == "NO_ERROR_CODE" then
    if self.scheduler ~= nil then
      CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
      self.scheduler = nil
    end

    echo("clear frozen times =",msg.data.relive)
    self.boss:setSpeedUpCount(msg.data.relive)
    self.boss:setFrozenTime(0)
    self.pOutLineCoolTime:setString("00:00")
    self.menu_speedUp:setEnabled(false)
    self.bn_battle:setEnabled(true)
    self.bn_quickBattle:setEnabled(true)

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)

  elseif msg.error == "NOT_NEED_CLEAR" then 
    Toast:showString(self, _tr("noneed_clear_again"), ccp(display.width/2, display.height*0.4))
  elseif msg.error == "NOT_ENABLE" then 
    Toast:showString(self, _tr("boss_not_open"), ccp(display.width/2, display.height*0.4))
  elseif msg.error == "SYSTEM_ERROR" then 
    Toast:showString(self, _tr("system error"), ccp(display.width/2, display.height*0.4))
  elseif msg.error == "NEED_MORE_MONEY" then
    -- Toast:showString(self, _tr("not enough money"), ccp(display.width/2, display.height*0.4))
    GameData:Instance():notifyForPoorMoney()
  end
end

function ActivityBossBattleView:queryRankResult(action,msgId,msg)
  echo("queryRankResult:")
  --dump(msg, "=====queryRankResult")

  local ranks = msg.rank.rank
  local count = table.getn(ranks)

  for i=1, count do 
    echo("==rank:", ranks[i].name, ranks[i].damage, ranks[i].id)
  end

  local playerName = GameData:Instance():getCurrentPlayer():getName()
  local playerDamage = self.boss:getDamageForPlayer()
  echo("=== player name, damage =",playerName, playerDamage)
  local playerItem = {name = playerName, hurt = playerDamage}

  local tbl = {}
  for i=1, count do 
    local tmp = {name = ranks[i].name, hurt = ranks[i].damage}
    table.insert(tbl, tmp)
  end

  if self.boss ~= nil then 
    self.boss:updateTopPlayerRank(ranks)
    --show top 3 player's rank
    self:showTopRank()   
  end

  local pop = PopupView:createRankListPopup(tbl, playerItem)
  self:addChild(pop)
end

function ActivityBossBattleView:updateBossDamageResp(action,msgId,msg)
  echo("ActivityBossBattleView:updateBossDamageResp:")
  self:showAtkBossAnim()
end

function ActivityBossBattleView:showTopRank()
  -- self.label_top1:setString("")
  -- self.label_top2:setString("")
  -- self.label_top3:setString("")
  self.pTopName1:setString("")
  self.pTopName2:setString("")
  self.pTopName3:setString("")

  if self.boss ~= nil then 
    local arr = {self.pTopName1, self.pTopName2, self.pTopName3}
    local ranks = self.boss:getTopPlayerRank()
    if ranks ~= nil then 
      for i=1, table.getn(ranks) do 
        arr[i]:setString(ranks[i].name)
      end
    end
  end
end

--card atk direction: 1:leftBottom; 2:midleBottom; 3:rightBottom
function ActivityBossBattleView:shakeBossByAtkDirection(direction)
  if self.bossImg ~= nil then
    local speed = 6.0
    local duration = 0.3 * speed
    local strength = 6.0
    local times = 2

    local array = CCArray:create()
    local s_duration = 0.3/(times * 2)

    for i=1, times do
      local s_x =  strength + math.random(strength * 100)/100.0
      local s_y =  strength + math.random(strength * 100)/100.0

      if direction == 1 then

      elseif direction == 2 then

      elseif direction == 3 then
        s_x = -s_x
      end

      array:addObject(CCMoveBy:create(s_duration,ccp(s_x,s_y)))
      array:addObject(CCMoveBy:create(s_duration,ccp(-s_x,-s_y)))
    end
    local action = CCSequence:create(array)
    self.bossImg:runAction(action)
  end
end

--card atk direction: 1:leftBottom; 2:midleBottom; 3:rightBottom
function ActivityBossBattleView:playCardAttackAnim(resId, direction,delayTime, bShowHpAnim)
  if self.bossImg == nil then
    return
  end
  
  local sprite = _res(resId)
  if sprite == nil then 
    echo("playCardAttackAnim: error res id !!!!")
    return
  end
  self:addChild(sprite)

  local scaleFator = 95/sprite:getContentSize().width
  sprite:setScale(scaleFator)

  local pos, size = self:getBossPosAndSize()
  local targetPos = nil
  local srcPos = nil
  local angle = nil
  local duration2 = 0.8

  if direction == 1 then --leftBottom
    srcPos = ccp(math.random(-30,300)+pos.x, math.random(-40,50)+pos.y)
    targetPos = ccp(pos.x+size.width/2-30, pos.y + size.height*0.65)
    sprite:setRotation(45)
    sprite:setSkewX(10)
    sprite:setSkewY(40)
    sprite:setPosition(srcPos)
    angle = -260

  elseif direction == 2 then --midleBottom
    srcPos = ccp(math.random(-30,30)+pos.x+size.width/2, math.random(-100,-10)+pos.y)
    targetPos = ccp(pos.x+size.width/2, pos.y + size.height*0.5)

    sprite:setScale(scaleFator*1.2)
    --sprite:setRotation(45)
    sprite:setSkewX(10)
    sprite:setSkewY(10)
    sprite:setPosition(srcPos)
    angle = -200

  elseif direction == 3 then --rightBottom
    srcPos = ccp(math.random(50,100)+pos.x+size.width, math.random(-40,20)+pos.y)
    targetPos = ccp(pos.x+size.width/2+30, pos.y + size.height*0.65)
    sprite:setRotation(-45)
    sprite:setSkewX(40)
    --sprite:setSkewY(50)
    sprite:setPosition(srcPos)
    angle = 220
  end

  local function moveEnd()
    self:shakeBossByAtkDirection(direction)
  end 

  local function atkEnd()
    sprite:removeFromParentAndCleanup(true)

    --toast hurt string
    local strPos = ccp(pos.x+size.height/2, pos.y+size.height*0.8)
    local lostHp = self.boss:getDamage()
    local str = string.format("-%d", lostHp)
    Toast:showStringNum(str,strPos)
    if bShowHpAnim then 
      self:showHpLost(lostHp)      
    end 
    self.isAnimPlaying = false
  end


  local flag = ((srcPos.x < targetPos.x) and 1 ) or (-1)

  --move to target
  local deltW = math.abs(targetPos.x - srcPos.x)
  local deltH = math.abs(targetPos.y-srcPos.y)  
  local r_bezier = ccBezierConfig()
  r_bezier.controlPoint_1 = ccp(flag*deltW*0.3, 0)
  r_bezier.controlPoint_2 = ccp(flag*deltW, deltH*0.8)
  r_bezier.endPosition = ccp(flag*deltW, deltH)
  local r_move = CCBezierBy:create(0.4, r_bezier)
  local r_anim = CCEaseIn:create(r_move, 3)
  local scaleMoveEase = CCSpawn:createWithTwoActions(r_anim, CCScaleTo:create(scaleFator*0.8, 0.5))

  --move to disapear
  local r_bezier2 = ccBezierConfig()
  r_bezier2.controlPoint_1 = ccp(0, deltH*0.2)
  r_bezier2.controlPoint_2 = ccp(-flag*deltW*0.2,  deltH*0.2)
  r_bezier2.endPosition = ccp(-flag*deltW*0.5,  -deltH*0.5)
  local r_move2 = CCBezierBy:create(duration2, r_bezier2)
  local r_anim2 = CCEaseOut:create(r_move2, 1.5)

  local arr = CCArray:create()
  local fadeout = CCEaseIn:create(CCFadeOut:create(duration2), 3)
  arr:addObject(fadeout)
  arr:addObject(CCRotateBy:create(duration2, angle))
  arr:addObject(r_anim2)
  arr:addObject(CCSkewTo:create(0.2, 0, 0))
  local rotateFadeMove = CCSpawn:create(arr)


  --start play anim
  local array = CCArray:create()
  if delayTime > 0 then 
    array:addObject(CCDelayTime:create(delayTime))
  end
  array:addObject(scaleMoveEase)
  array:addObject(CCCallFunc:create(moveEnd))
  array:addObject(rotateFadeMove)
  array:addObject(CCCallFunc:create(atkEnd))

  local seq = CCSequence:create(array)
  sprite:runAction(seq)
end


function ActivityBossBattleView:showAtkBossAnim()
  if self.isAnimPlaying == true then 
    echo("attack animation is playing...")
    return 
  end
  self.isAnimPlaying = true

  local picArray = Activity:instance():getAllCardHeaderPic()
  local num = table.getn(picArray)
  math.randomseed(os.time())

  local arr = {{1}, {2}, {3},{1,2},{1,3},{2,3}, {1,2,3}}
  local idx = math.floor(math.random()*table.getn(arr)) + 1
  local animCount = table.getn(arr[idx])
  for i=1, animCount do
    local direction = arr[idx][i]
    local delayTime = (i-1)*0.2
    local imgIndex = math.floor(math.random(1, num))
    local bShowHpAnim = false 
    if i == animCount then  --最后一次才播放血条动画
      bShowHpAnim = true 
    end 
    self:playCardAttackAnim(picArray[imgIndex], direction, delayTime, bShowHpAnim)
  end
end

function ActivityBossBattleView:showFrozenTime()
  --calc left time
  local frozenTime = self.boss:getFrozenTime()
  local curTime = Clock:Instance():getCurServerUtcTime()
  self.leftTime = frozenTime - curTime

  if self.boss:getBossState(true) == BossState.KILLED then 
    self.menu_speedUp:setEnabled(false)
    self.bn_battle:setEnabled(false)
    self.bn_quickBattle:setEnabled(false)  
  else 
    echo(" frozen leftSec = ", self.leftTime)
    if self.leftTime <= 0 then 
      self.menu_speedUp:setEnabled(false)
      self.bn_battle:setEnabled(true)
      self.bn_quickBattle:setEnabled(true)
    else 
      self.menu_speedUp:setEnabled(true)
      self.bn_battle:setEnabled(false)
      self.bn_quickBattle:setEnabled(false)
    end
  end

  --start count down time
  if self.leftTime < 0  then 
    self.leftTime = 0
  end

  local function timerCallback(dt)
    self.leftTime = self.leftTime - 1
    if self.leftTime <= 0 then
      if self.scheduler ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
        self.scheduler = nil
      end

      self.pOutLineCoolTime:setString("00:00")
      self.menu_speedUp:setEnabled(false)
      self.bn_battle:setEnabled(true)
      self.bn_quickBattle:setEnabled(true)
    else 
      local min = math.floor(self.leftTime/60.0)
      local sec = math.floor(self.leftTime%60.0)
      self.pOutLineCoolTime:setString(string.format("%02d:%02d", min,sec))
    end
  end

  local min = math.floor(self.leftTime/60.0)
  local sec = math.floor(self.leftTime%60.0)
  self.pOutLineCoolTime:setString(string.format("%02d:%02d", min,sec))

  if self.scheduler ~= nil then 
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
    self.scheduler = nil
  end

  if self.leftTime > 0 then
    self.scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timerCallback, 1.0, false)  
  end
end


function ActivityBossBattleView:initProgressorBar()
  local bg = CCSprite:createWithSpriteFrameName("progressBar_gray.png")
  local fg1 = CCSprite:createWithSpriteFrameName("progressBar_red.png")
  local fg2 = CCSprite:createWithSpriteFrameName("progressBar_green.png")
  fg1:setPosition(ccp(2, 28))
  self.progresser = ProgressBarView.new(bg, fg1, fg2)
  self.progresser:setPercent(0, 1)
  self.progresser:setPercent(0, 2)
  self.node_progressBar:addChild(self.progresser)

  if self.boss ~= nil then
    local percent = 100*self.boss:getHp()/self.boss:getTotalHp()
    echo(" --- boss hp , percent =", self.boss:getHp(), self.boss:getTotalHp(), percent)
    self.progresser:setPercent(percent, 1)
    self.progresser:setPercent(percent, 2)
  end
end 


function ActivityBossBattleView:showHpLost(lostHp)
  local startPercent = 100*self.boss:getHp()/self.boss:getTotalHp()
  local endPercent = 100*(self.boss:getHp()-lostHp)/self.boss:getTotalHp()

  if endPercent < 0 then 
    endPercent = 0
  end

  echo("===startPercent,endPercent = ", startPercent, endPercent)
  local function progressFinish()
    -- echo("====progressFinish")
    --show red fg
    self.progresser:startProgressing(nil, startPercent, endPercent, 1)
    
  end

  if self.progresser ~= nil then 
    --show green fg
    self.progresser:stopProgressBar()
    self.progresser:startProgressing(progressFinish, startPercent, endPercent, 2)
  end
end


function ActivityBossBattleView:setBossPosAndSize(pos,size)
  self.bossPos = pos
  self.bossSize = size
end

function ActivityBossBattleView:getBossPosAndSize()
  return self.bossPos, self.bossSize
end

function ActivityBossBattleView:showBossImg(resId)
  echo("showBossImg", resId)
  self.bossImg = _res(resId)
  if self.bossImg ~= nil then 
    self.node_boss:removeAllChildrenWithCleanup(true)

    local pos = self.node_progressBar:getParent():convertToWorldSpace(ccp(self.node_progressBar:getPosition()))
    self.node_boss:setPosition(ccp(0, pos.y))

    --show contry flag
    local picId = self.boss:getUnitPicId() --整数第四位代表国家
    local val =math.floor(picId/1000) - math.floor(picId/10000)*10
    local flag = nil 
    if val == 1 then --wei
      flag = CCSprite:create("img/activity/act_wei.png")
    elseif val == 2 then --shu
      flag = CCSprite:create("img/activity/act_shu.png")
    elseif val == 3 then --wu
      flag = CCSprite:create("img/activity/act_wu.png")
    elseif val == 4 then --qun
      flag = CCSprite:create("img/activity/act_qun.png")
    end 
    if flag ~= nil then 
      flag:setAnchorPoint(ccp(0, 1))
      flag:setPosition(ccp((display.width-640)/2+100, display.height-pos.y-50))
      self.node_boss:addChild(flag)
    end 

    --boss 显示在进度条以上，top菜单以下
    local maskHeight = display.height - pos.y - self:getDelegate():getTopMenuSize().height
    local maskLayer = DSMask:createMask(CCSizeMake(display.width, maskHeight))
    self.node_boss:addChild(maskLayer)

    self.bossImg:setScale((maskHeight+10)/self.bossImg:getContentSize().height)
    self.bossImg:setAnchorPoint(ccp(0.5,0))
    self.bossImg:setPosition(ccp(display.width/2, 0))
    maskLayer:addChild(self.bossImg)

    self:setBossPosAndSize(ccp(0, pos.y), CCSizeMake(display.width, maskHeight))

    --show dead image
    local state = self.boss:getBossState(true)
    if state == BossState.KILLED then --dead
      local sprite = CCSprite:create("img/activity/activity-image-yijisha1.png")
      if sprite ~= nil then 
        sprite:setPosition(ccp(display.width/2-30, maskHeight*0.5))
        self.node_boss:addChild(sprite)
      end
    else 
      local action = CCMoveBy:create(1.5, ccp(0, 30))
      local action2 = CCMoveBy:create(1.5, ccp(0, -30))
      local seq = CCSequence:createWithTwoActions(action,action2)
      self.bossImg:runAction(CCRepeatForever:create(seq))
    end
  end
end


function ActivityBossBattleView:showPlusCardHeader(cardTbl)
-- cardTbl = {{configId= 14050602, plus= 12.2}, {configId= 14050203, plus= 12.2}}

  if cardTbl == nil then
    echo("emtpy plus cards !!")
    return
  end

  if self.isPlusCardsShowing == false then 
    local bgSize = self.sprite9_bg:getContentSize()
    self.sprite9_bg:setContentSize(CCSizeMake(bgSize.width, 114))   
    self.node_listInfo:setVisible(false)    
  end


  local function tableCellTouched(tableview,cell)
    if self.isPlusCardsShowing == false then
      return
    end 
    local idx = cell:getIdx()
    --show tip
    local configId = cardTbl[idx+1].configId 
    local plus = cardTbl[idx+1].plus
    local plusStr = string.format("%d", plus).."％"
    if plus > math.floor(plus) then 
      plusStr = string.format("%.1f", plus).."％"
    end 
    local str = _tr("boss_plus_card_info_%{name}_%{str}", {name=AllConfig.unit[configId].unit_name, str=plusStr})
    TipsInfo:showStringTip(str,CCSizeMake(280, 0), nil, cell, ccp(130, 50), nil, false, TipDir.LeftLeftDown, true)
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    -- echo("tableCellAtIndex: idx= ", idx)

    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local cardHead = CardHeadView.new()
    cardHead:setCardByConfigId(cardTbl[idx+1].configId)
    cardHead:setPosition(ccp(self.cellWidth/2, self.cellHeight/2))
    cardHead:setLvVisible(false)
    cell:addChild(cardHead)

    local x = self.cellWidth/2 + cardHead:getWidth()/2
    local y = self.cellHeight/2 + cardHead:getHeight()/2
    local label = CCLabelBMFont:create(string.format("x%.1f", 1.0+cardTbl[idx+1].plus/100), "client/widget/words/card_name/number_skillup.fnt")
    label:setPosition(ccp(x-label:getContentSize().width/2-15, y-label:getContentSize().height/2-15))
    cell:addChild(label)    

    return cell
  end
  

  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end

  self.cellWidth = self.node_plusContainer:getContentSize().width
  self.cellHeight = 110
  self.totalCells = #cardTbl

  self.node_plusContainer:removeAllChildrenWithCleanup(true)

  self.tableView = CCTableView:create(self.node_plusContainer:getContentSize())
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.node_plusContainer:addChild(self.tableView)

  -- self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  self.tableView:reloadData()
end 
