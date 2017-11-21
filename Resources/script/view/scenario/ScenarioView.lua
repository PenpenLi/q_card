require("view.component.ViewWithEave")
require("view.Common")
require("view.scenario.component.ScenarioMapView")
require("view.scenario.component.ScenarioPopQuickFight")
require("view.scenario.component.ScenarioPopCheckPoint")
require("view.scenario.ChapterAwardView")

ScenarioView = class("ScenarioView", ViewWithEave)

function ScenarioView:ctor(scenario,controller)
  ScenarioView.super.ctor(self)
  Guide:Instance():removeGuideLayer()
  self:showMask()
 
  self.scenario = scenario
  self:setDelegate(controller)
  self._chapterId = 1
  self._dropCardsTip = {}

  GameData:Instance():pushViewType(ViewType.scenario)

  local scrollView = CCScrollView:create()
  self.scrollView = scrollView
  self:addChild(self.scrollView)

  self.scrollView:setViewSize(CCSizeMake(640,self:getCanvasContentSize().height + GameData:Instance():getCurrentScene():getBottomContentSize().height))
  self.scrollView:setPositionX((display.width - 640)/2)
  self.scrollView:setDirection(kCCScrollViewDirectionHorizontal)
  self.scrollView:setClippingToBounds(true)
  self.scrollView:setBounceable(false)
  self.scrollView:setDelegate(self)
  self:setScrollView(self.scrollView)
  
  local effectNode = display.newNode()
  self:addChild(effectNode,100)
  self._effectNode = effectNode
  
  display.addSpriteFramesWithFile("scenario/scenario0.plist", "scenario/scenario0.png")
  self:setTitleTextureName("#scenario-image-paibian3.png")
  local menuArray = {
      {"#nor-huangjinzhiluan.png","#sel-huangjinzhiluan.png"},
      {"#nor-dongzeijinjing.png","#sel-dongzeijinjing.png"},
      {"#nor-yuanshuchengdi.png","#sel-yuanshuchengdi.png"},
      {"#nor-qunxionggeju.png","#sel-qunxionggeju.png"},
      {"#nor-dongwujueqi.png","#sel-dongwujueqi.png"},
      {"#nor-xiandichutao.png","#sel-xiandichutao.png"},
      {"#nor-caolvzhizheng.png","#sel-caolvzhizheng.png"},
      {"#nor-hebeizhengxiong.png","#sel-hebeizhengxiong.png"},
      {"#nor-yuanshisanzi.png","#sel-yuanshisanzi.png"},
      {"#nor-chibizhizhan.png","#scenario-button-sel-chibizhizhan.png"},
      {"#nor-yuliangzhizheng.png","#sel-yuliangzhizheng.png"},
      {"#nor-xiliangbingbian.png","#sel-xiliangbingbian.png"}
   }
   
  local chapterId = self.scenario:getCurrentChapter():getId()
  self._chapterId = chapterId
  self._currentCheckPointIsElite = self.scenario:getCurrentStage():getIsElite()
    
   if self.scenario:getUnPassedLastStage():getIsPassed() == true and 
      self.scenario:getUnPassedLastStage():getEnabledAutoNextChapter() == true
   then
   
   else
      chapterId = self.scenario:getUnPassedLastStage():getStageChapterId()
      self._chapterId = chapterId
      self._currentCheckPointIsElite = self.scenario:getUnPassedLastStage():getIsElite()
   end
  
   local onSwitch = function()
    if self._currentCheckPointIsElite == false then 
       self._currentCheckPointIsElite = true
       self:goToChapter(self.scenario:getChapterById(self._chapterId),true)
       
       self._btnHookElite:setVisible(true)
       
       _executeNewBird()
       
       --for test
       --self:alertHookEliteChapter(self.scenario:getChapterById(self._chapterId))
    else
       self._currentCheckPointIsElite = false
       self:goToChapter(self.scenario:getChapterById(self._chapterId),false)
       self._btnHookElite:setVisible(false)
    end
  end
  
  local yPos = display.height - (controller:getScene():getTopContentSize().height + 165 + 65) +10
  local xPos = (display.width - 640)/2 + 80 
  
  --create  normal menu
  self._btnGotoElite = CCMenu:create()
  self._btnGotoElite:setTouchPriority(-128)
  self._btnGotoElite:setAnchorPoint(ccp(0.5,0.5))
  local menuItem = CCMenuItemImage:create()
  local frame =  display.newSpriteFrame("scenario-image-jingying.png")
  menuItem:setNormalSpriteFrame(frame)
  menuItem:setSelectedSpriteFrame(frame)
  menuItem:registerScriptTapHandler(onSwitch)
  self._btnGotoElite:addChild(menuItem)
  
  --self._btnGotoElite:setContentSize(CCSizeMake(130,100))
  _registNewBirdComponent(108003,menuItem)
  
  -- create elite menu
  self._btnGotoElite:setPosition(xPos,yPos)
  self:addChild(self._btnGotoElite,888)
  self._btnGotoElite:setVisible(false)
  
  local tip = TipPic.new() 
  tip:setPosition(ccp(100,80))
  menuItem:addChild(tip)
  self._eliteTip = tip
  
  self._btnGotoNormal = CCMenu:create()
  self._btnGotoNormal:setTouchPriority(-200)
  self._btnGotoNormal:setAnchorPoint(ccp(0.5,0.5))
  menuItem = CCMenuItemImage:create()
  local frame =  display.newSpriteFrame("scenario-image-putong.png")
  menuItem:setNormalSpriteFrame(frame)
  menuItem:setSelectedSpriteFrame(frame)
  menuItem:registerScriptTapHandler(onSwitch)
  self._btnGotoNormal:addChild(menuItem)
 
  self._btnGotoNormal:setPosition(xPos,yPos)
  self:addChild(self._btnGotoNormal,900)
  self._btnGotoNormal:setVisible(false)
  
  local hookEliteStagesHandler = function()
    self:alertHookEliteChapter(self.scenario:getChapterById(self._chapterId))
  end
  
  --create elite hook menu
  self._btnHookElite = CCMenu:create()
  self._btnHookElite:setTouchPriority(-128)
  self._btnHookElite:setAnchorPoint(ccp(0.5,0.5))
  local menuItem = CCMenuItemImage:create()
  local frame =  display.newSpriteFrame("scenario_btn_hook_nor.png")
  local frame_sel =  display.newSpriteFrame("scenario_btn_hook_sel.png")
  menuItem:setNormalSpriteFrame(frame)
  menuItem:setSelectedSpriteFrame(frame_sel)
  menuItem:registerScriptTapHandler(hookEliteStagesHandler)
  self._btnHookElite:addChild(menuItem)
  
  self._btnHookElite:setPosition(xPos + 135,yPos)
  self:addChild(self._btnHookElite,900)
  self._btnHookElite:setVisible(false)
  
  local menuShow = {}
  for i = 1, self.scenario:getMaxChapterId() do
     table.insert(menuShow,menuArray[i])
  end
  self:setMenuArray(menuShow)
  
  self:refreshChapterTip()
  
  --hide stage open tip
  local tip_icon = display.newSprite("#scenario_hide_stage_tip.png")
  self:addChild(tip_icon,900)
  tip_icon:setAnchorPoint(ccp(0.5,0.5))
  tip_icon:setPosition(ccp(display.width - tip_icon:getContentSize().width/2,yPos + 20))
  self._tip_icon = tip_icon
  table.insert(self._dropCardsTip,tip_icon)

  local cardHead = CardHeadView.new()
  tip_icon:addChild(cardHead)
  cardHead:setLvVisible(false)
  cardHead:enableClick(true)
  cardHead:setPosition(10,35)
  cardHead:setScale(0.7)
  self._dropCard = cardHead
  
  self:goToChapter(self.scenario:getChapterById(self._chapterId),self._currentCheckPointIsElite)
  self:getTabMenu():setItemSelectedByIndex(chapterId)
  
  local ccMenu = self:getEaveView().btnHelp:getParent()
  local helpPos = ccp(self:getEaveView().btnHelp:getPosition())
  self:getEaveView().btnHelp:removeFromParentAndCleanup(true)
  
  --task btn
  local taskMenuItem = CCMenuItemImage:create()
  local frame =  display.newSpriteFrame("scenario_btn_renwu0.png")
  taskMenuItem:setNormalSpriteFrame(frame)
  frame =  display.newSpriteFrame("scenario_btn_renwu1.png")
  taskMenuItem:setSelectedSpriteFrame(frame)
  --self:getEaveView().btnBack:getParent():addChild(taskMenuItem)
  ccMenu:addChild(taskMenuItem)
  taskMenuItem:setPosition(helpPos)
  self._taskMenuItem = taskMenuItem
  taskMenuItem:registerScriptTapHandler(function()
     self:getDelegate():enterQuest()
  end)
  
  
  --cards btn
  local cardMenuItem = CCMenuItemImage:create()
  local frame =  display.newSpriteFrame("btn_wujiang_nor.png")
  cardMenuItem:setNormalSpriteFrame(frame)
  frame =  display.newSpriteFrame("btn_wujiang_sel.png")
  cardMenuItem:setSelectedSpriteFrame(frame)
  ccMenu:addChild(cardMenuItem)
  cardMenuItem:setPosition(helpPos.x + 100,helpPos.y)
  self._cardMenuItem = cardMenuItem
  cardMenuItem:registerScriptTapHandler(function()
     local playstatesController  = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
     playstatesController:enter(1)
  end)
  _registNewBirdComponent(108501,cardMenuItem)
  
  --update tip
  self:refreshTaskTip()
  
  --self:getEaveView().btnBack:setVisible(true)
  self:setMapDragEnabled(true)
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch))

  self.levelTriggerTime = 0 
  
  local tabMenu = self:getTabMenu():getTableView()
  for i = 1, 10 do
    local targetCell = tabMenu:cellAtIndex(i-1)
    if targetCell ~= nil then
      targetCell:setContentSize(CCSizeMake(135,60))
  	  _registNewBirdComponent(108200 + i,targetCell)
  	end
  end
  
  CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self,handler(self,ScenarioView.initGuides),GuideConfig.GuideTrigger)
end

function ScenarioView:refreshChapterTip()
  for i = 1, self.scenario:getMaxChapterId() do
     local chapter = Scenario:Instance():getChapterById(i)
     if GameData:Instance():getLanguageType() ~= LanguageType.JPN then 
       self:getTabMenu():setTipImgVisible(i,Scenario:Instance():checkHasAwardOnChapter(i))
       self:getTabMenu():setNewTipImgVisible(i,chapter:isNewChapter())
     end
  end

  --print("self.scenario:getMaxChapterId()",self.scenario:getMaxChapterId())
  --[[for i = 1, self.scenario:getMaxChapterId() do
     local chapter = self.scenario:getChapterById(i)
     local chapter = Scenario:Instance():getChapterById(i)
     local stagesToFight = Scenario:Instance():getEliteStagesToHookByChapter(chapter)
     
     if GameData:Instance():getLanguageType() == LanguageType.JPN then 
       self:getTabMenu():setTipImgVisible(i,false)
       self:getTabMenu():setNewTipImgVisible(i,false)
     else
       self:getTabMenu():setTipImgVisible(i,#stagesToFight > 0)
       self:getTabMenu():setNewTipImgVisible(i,chapter:isNewChapter())
     end
  end]]
end

function ScenarioView:refreshTaskTip()

  local enabledTip = false
  local cards = GameData:Instance():getCurrentPackage():getBattleCards()
  for key, card in pairs(cards) do
    enabledTip = GameData:Instance():getCurrentPackage():checkCardHasTip(card)
    if enabledTip == true then
      break
    end
  end
  
  if enabledTip == true then
    if self._cardTip == nil then
      local tip = TipPic.new() 
      tip:setPosition(ccp(66,66))
      self._cardMenuItem:addChild(tip)
      self._cardTip = tip
    end
  else
    if self._cardTip ~= nil then
       self._cardTip:removeFromParentAndCleanup(true)
       self._cardTip = nil
    end
  end

   
  local hasNewAward = Quest:Instance():hasNewAward()
  if hasNewAward == true then
     if self._taskTip == nil then
       local tip = TipPic.new()
       tip:setPosition(ccp(76,66))
       self._taskMenuItem:addChild(tip)
       self._taskTip = tip
     end
  else
     if self._taskTip ~= nil then
       self._taskTip:removeFromParentAndCleanup(true)
       self._taskTip = nil
     end
  end
end

function ScenarioView:showMask()
  if self._loadingshow == nil then
     self._loadingshow = Mask.new({opacity = 80,priority = -140})
     self:addChild(self._loadingshow)
  end
end

function ScenarioView:removeMask()
  if self._loadingshow ~= nil then
    self._loadingshow:removeFromParentAndCleanup(true)
    self._loadingshow = nil 
  end
end

function ScenarioView:onTouch(event,x,y)
  if event == "began" then
     if self:getScrollView() ~= nil then
        if y < 135 or self:getMapDragEnabled() == false 
        or Guide:Instance():getGuideLayer() ~= nil
        then
           self:getScrollView():setTouchEnabled(false)
        end
     end
     return true
  elseif event == "ended" then
     if self:getScrollView() ~= nil and self:getMapDragEnabled() == true then
        self:getScrollView():setTouchEnabled(true)
     end
     
     local targetCard = UIHelper.getTouchedNode(self._dropCardsTip,x,y,ccp(0,0))
     if targetCard ~= nil and self._dropCard ~= nil and self._tip_icon:isVisible() == true then
        self._dropCard:onClickHeadCallBack()
     end
  end
end

function ScenarioView:onExit()
    self:stopAllActions()
    CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,GuideConfig.GuideTrigger)
   -- CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self,GuideConfig.GuideLayerRemoved)
end


function ScenarioView:initGuides()
  self:removeMask()
  local currentChapter = self:getCurrentShowChapter()
  if currentChapter:isNewChapter() == true then
    local stage = currentChapter:getNormalCheckPoints()[1]:getStages()[1]
    self.map:lookAtMapFlagByStage(stage)
  else
    _executeNewBird()
  end
  --self:triggerGuides(false)
end

function ScenarioView:onHelpHandler()
    local help = HelpView.new()
    help:addHelpBox(1001,nil,true)
    --help:addHelpItem(1025, self._currentView.btnRefresh, ccp(100,80), ArrowDir.RightRightDown)
    self:getDelegate():getScene():addChildView(help, 1000)
    ScenarioView.super:onHelpHandler()
end

function ScenarioView:updateView()
    if self.map ~= nil then
       self.map:updateMapFlags()
    end
end

------
--  Getter & Setter for
--      ScenarioView._ScrollView 
-----
function ScenarioView:setScrollView(ScrollView)
	self._ScrollView = ScrollView
end

function ScenarioView:getScrollView()
	return self._ScrollView
end

function ScenarioView:updateBoxStateByChapterId(chapterId)

  self:refreshChapterTip()

  if self._boxAnim ~= nil then
    self._boxAnim:removeFromParentAndCleanup(true)
    self._boxAnim = nil
  end

  if self._boxIcon == nil then
    return
  end
  
  self._boxIcon:stopAllActions()
  self._boxIcon:setRotation(0)
  if self.scenario:checkHasAwardOnChapter(chapterId) == false then
    return
  end

  local array = CCArray:create()
  array:addObject(CCRotateBy:create(0.1, -10))
  array:addObject(CCRotateBy:create(0.2, 20))
  array:addObject(CCRotateBy:create(0.1, -10))
  local seq = CCSequence:create(array)
  self._boxIcon:runAction(CCRepeatForever:create(seq))
  
  
  if self._starAwardMenu ~= nil then
    local anim,offsetX,offsetY = _res(6010003)
    anim:setPosition(ccp(0,0))
    anim:setScale(0.5)
    self._starAwardMenu:addChild(anim,-1)
    self._boxAnim = anim
  end
  
  

  
  
end

function ScenarioView:goToChapter(chapter,isElite,showEffect,isAutoAlert,lookAtNewestStage)
  
  self:setCurrentShowChapter(chapter)
  
  local openStarAward = function()
    local awardView = ChapterAwardView.new(self:getCurrentShowChapter():getId(),self._passedCount,self._maxCount)
    awardView:setDelegate(self)
    awardView:setScale(0.5)
    awardView:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))
    GameData:Instance():getCurrentScene():addChildView(awardView)
  end
  
  if self._starAwardMenu == nil then
    local starAwardMenuCon = display.newNode()
    self:addChild(starAwardMenuCon,900)
    starAwardMenuCon:setPosition((display.width-640)/2 + 45,140)
    self._starAwardMenu = starAwardMenuCon
    
    local boaderBg = display.newSprite("#current_star_count_bg.png")
    starAwardMenuCon:addChild(boaderBg)
    boaderBg:setAnchorPoint(ccp(0,0.5))
    boaderBg:setPosition(ccp(-10,0))
    
    local label = CCLabelBMFont:create("", "client/widget/words/card_name/number_skillup.fnt")
    boaderBg:addChild(label)
    label:setPosition(ccp(131,24))
    self._starProgressLabel = label
    
    local nor = display.newSprite("#current_star_count.png")
    local sel = display.newSprite("#current_star_count.png")
    local dis = display.newSprite("#current_star_count.png")
    
    local starAwardMenu,menuitem = UIHelper.ccMenuWithSprite(nor,sel,dis,openStarAward)
    starAwardMenu:setPosition(ccp(0,10))
    starAwardMenuCon:addChild(starAwardMenu)
    self._boxIcon = menuitem
  end
  
  if isElite == false then
    local passedCount = 0
    local maxCount = 0
    for key, checkPoint in pairs(chapter:getNormalCheckPoints()) do
    	for key, stage in pairs(checkPoint:getStages()) do
    	  if stage:getStageType() == StageConfig.StageTypeNormal then
      		if stage:getIsPassed() == true then
      		  passedCount = passedCount + 1
      		end
      		maxCount = maxCount + 1
      	end
    	end
    end
    self._passedCount = passedCount
    self._maxCount = maxCount
    self._starProgressLabel:setString(passedCount.."/"..maxCount)
    self:updateBoxStateByChapterId(chapter:getId())
  end
  
  
  self._starAwardMenu:setVisible(not isElite)
  
  
  if self._tip_icon ~= nil then
     self._tip_icon:setVisible(chapter:getId() > 1)
     --self._dropCard
  end
  
  if chapter:getId() > 1 then
    local normalHideStage = nil
    for key, checkPoint in pairs(chapter:getNormalCheckPoints()) do
    	if checkPoint:getStageType() == StageConfig.StageTypeNormalHide then
    	   normalHideStage = checkPoint:getStages()[1]
    	   break
    	end
    end
    assert(normalHideStage ~= nil,"normal hide stage not found")
    local stageId = normalHideStage:getStageId()
    local firstDropArr = AllConfig.stage[stageId].first_drop
    local dropConfigId = 0
    for key, dropId in pairs(firstDropArr) do
      local findCard = false
    	local dropGroup = AllConfig.drop[dropId].drop_data
    	for key, groupArray in pairs(dropGroup) do
    		if groupArray.array[1] == 8 then
    		  dropConfigId = groupArray.array[2]
    		  findCard = true
    		  break
    		end
    	end
    	
    	if findCard == true then
    	  break
    	end
    end
    
    if dropConfigId > 0 then
      self._dropCard:setVisible(true)
      self._dropCard:setCardByConfigId(dropConfigId)
    else
      self._dropCard:setVisible(false)
    end
  end
  
  
  local stagesToFight = Scenario:Instance():getEliteStagesToHookByChapter(chapter)
  --self._eliteTip:setVisible((#stagesToFight > 0 and GameData:Instance():getLanguageType() ~= LanguageType.JPN))
  self._eliteTip:setVisible(false)
  
  if self._lastEffectType ~= chapter:getEffectType() then
     self._effectNode:removeAllChildrenWithCleanup(true)
     if chapter:getEffectType() == StageConfig.Chapter_Effect_Cloud then
          local pkg = ccbRegisterPkg.new(self)
          pkg:addFunc("anim_end",function() end)
          pkg:addProperty("mAnimationManager","CCBAnimationManager")
          local layer,owner = ccbHelper.load("anim_MapCloud.ccbi","AnimMapCloudCCB","CCLayer",pkg)
          self._effectNode:addChild(layer)
     elseif chapter:getEffectType() == StageConfig.Chapter_Effect_Thunder then
          local pkg = ccbRegisterPkg.new(self)
          pkg:addFunc("anim_end",function() end)
          pkg:addProperty("mAnimationManager","CCBAnimationManager")
          local layer,owner = ccbHelper.load("anim_MapLightning.ccbi","AnimMapLightCCB","CCLayer",pkg)
          self._effectNode:addChild(layer)
     
     elseif chapter:getEffectType() == StageConfig.Chapter_Effect_Rain then
          local pkg = ccbRegisterPkg.new(self)
          pkg:addProperty("mAnimationManager","CCBAnimationManager")
          pkg:addFunc("anim_end",function() end)
          local layer,owner = ccbHelper.load("anim_MapRain.ccbi","AnimMapRainCCB","CCLayer",pkg)
          self._effectNode:addChild(layer)
     elseif chapter:getEffectType() == StageConfig.Chapter_Effect_Snow then
          local pkg = ccbRegisterPkg.new(self)
          pkg:addProperty("mAnimationManager","CCBAnimationManager")
          pkg:addFunc("anim_end",function() end)
          local layer,owner = ccbHelper.load("anim_MapSnow.ccbi","AnimMapSnowCCB","CCLayer",pkg)
          self._effectNode:addChild(layer)
     end
  end
  self._lastEffectType = chapter:getEffectType()

  self:getTabMenu():setItemSelectedByIndex(chapter:getId())
  self._currentCheckPointIsElite = isElite
  self._chapterId = chapter:getId()
  if self.map ~= nil then
     self.map:removeFromParentAndCleanup(true)
     self.map = nil
  end
  
  CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
  CCTextureCache:sharedTextureCache():removeUnusedTextures()
  display.addSpriteFramesWithFile("top_bottom/top_bottom.plist", "top_bottom/top_bottom.png")
  display.addSpriteFramesWithFile("common/common.plist", "common/common.png")
  display.addSpriteFramesWithFile("scenario/scenario0.plist", "scenario/scenario0.png")
  
  if chapter:checkEliteOpend() == false then
     self._btnGotoNormal:setVisible(false)
     self._btnGotoElite:setVisible(false)
     self._btnHookElite:setVisible(false)
  elseif chapter:checkEliteOpend() == true then
      if isElite == false then
         self._btnGotoNormal:setVisible(false)
         if GameData:Instance():checkSystemOpenCondition(38,false) == true then
          self._btnGotoElite:setVisible(true)
         end
         self._btnHookElite:setVisible(false)
      else
         self._btnGotoElite:setVisible(false)
         self._btnGotoNormal:setVisible(true)
         self._btnHookElite:setVisible(true)
      end
  end
  
  echo("chapter",chapter:getId(),self.scenario:getCurrentChapter():getId())
  self.map = ScenarioMapView.new(self,chapter,isElite)
  self.scrollView:setContainer(self.map)
  self.scrollView:setContentSize(self.map:getContentSize())

  --self.map:lookAtMapFlagByStage(self.scenario:getCurrentStage(),false,showEffect,isAutoAlert)
  
  local lookAtStage = self.scenario:getCurrentStage()
  if lookAtNewestStage == true then
    local newestCheckPoint = chapter:getNewestCheckPointByIsElite(isElite)
    lookAtStage = newestCheckPoint:getStages()[1]
  end
  
  
  self.map:lookAtMapFlagByStage(lookAtStage,false,showEffect,isAutoAlert)
  
  local function showDialogue()
     assert(AllConfig.worldview ~= nil,"dialogue config is nil")
     if AllConfig.worldview[chapter:getId()] ~= nil then
         local text = AllConfig.worldview[chapter:getId()].desc
         local resId = AllConfig.worldview[chapter:getId()].illustration_pic
         
         if self._dialogueNode == nil then
           self._dialogueNode = display.newNode()
           self:addChild(self._dialogueNode,999)
         else
           self._dialogueNode:removeAllChildrenWithCleanup(true)
         end
         
         local scenarioDialog = ScenarioDialogView.new(text,resId,StageConfig.DialogueTypeChapter)
         scenarioDialog:setDelegate(self)
         self._dialogueNode:addChild(scenarioDialog)
         local stage = chapter:getNormalCheckPoints()[1]:getStages()[1]
         self.map:lookAtMapFlagByStage(stage)
     else
        _executeNewBird()
     end
  end
  
  local function performWithDelay(node, callback, delay)
      local delay = CCDelayTime:create(delay)
      local callfunc = CCCallFunc:create(callback)
      local sequence = CCSequence:createWithTwoActions(delay, callfunc)
      node:runAction(sequence)
      return sequence
  end
  
  if chapter:isNewChapter() == true then
    performWithDelay(self,showDialogue,0.25)
  end
  
  if self._btnGotoElite ~= nil then
     self._btnGotoElite:setTouchPriority(-128) 
  end
    
end

------
--  Getter & Setter for
--      ScenarioView._CurrentShowChapter 
-----
function ScenarioView:setCurrentShowChapter(CurrentShowChapter)
	self._CurrentShowChapter = CurrentShowChapter
end

function ScenarioView:getCurrentShowChapter()
	return self._CurrentShowChapter
end

------
--  Getter & Setter for
--      ScenarioView._MapDragEnabled 
-----
function ScenarioView:setMapDragEnabled(MapDragEnabled)
	self._MapDragEnabled = MapDragEnabled
end

function ScenarioView:getMapDragEnabled()
	return self._MapDragEnabled
end

function ScenarioView:popCheckPoint(checkPoint,defultDifficulty)

  if ScenarioPopCheckPoint.isPoping == true then
    return
  end
  
  local pop = ScenarioPopCheckPoint.new(checkPoint,self)
  self:addChild(pop,2000)
  self:setPopView(pop)
  pop:setScale(0.5)
  pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
  pop:selectDifficultyType(defultDifficulty)
  self:setMapDragEnabled(true)
  if self:getScrollView() ~= nil then
     self:getScrollView():setTouchEnabled(true)
  end
end

------
--  Getter & Setter for
--      ScenarioView._popView 
-----
function ScenarioView:setPopView(popView)
	self._popView = popView
end

function ScenarioView:getPopView()
	return self._popView
end



--[[function ScenarioView:alertBuyVip()
    local isVip = GameData:Instance():getCurrentPlayer():isVipState()
    if isVip == false then
       local pop = PopupView:createTextPopupWithPath({leftNorBtn = "goumai.png",leftSelBtn = "goumai1.png",
                                                 text = _tr("tip_buy_vip_to_hook_stage"),
                        leftCallBack = function() return self:getDelegate():goToShopCollectView() end})
       self:getDelegate():getScene():addChildView(pop,100)
    end
    
end]]

--elite stages hook
function ScenarioView:alertHookEliteChapter(chapter)
    local stagesToFight = self.scenario:getEliteStagesToHookByChapter(chapter)
    local pop = nil
    if #stagesToFight <= 0 then

      local stagesToBuy = self.scenario:getEliteStagesToBuyByChapter(chapter)
      if #stagesToBuy <= 0 then
        pop = PopupView:createTextPopup(_tr("no_elite_to_saodang"),nil,true)
        GameData:Instance():getCurrentScene():addChildView(pop)
        return
      else
        local totalCost = 0
        for key, stageToBuy in pairs(stagesToBuy) do
        	local cost = stageToBuy:getBuyPriceNow()
        	totalCost = totalCost + cost
        end
        
        --local strTip = "是否花费"..totalCost.."元宝购买当前章节"..#stagesToBuy.."个关卡各1次？"
        local strTip = _tr("cost_%{money}_buy_%{count}_chapter_elite",{money = totalCost,count = #stagesToBuy})
        pop = PopupView:createTextPopup(strTip,function()
          self.scenario:reqForcibleBuyMultiStages(stagesToBuy)
        end)
        GameData:Instance():getCurrentScene():addChildView(pop)
        return
      end
    end
    
    local currentSpirit = GameData:Instance():getCurrentPlayer():getSpirit()
    if currentSpirit < stagesToFight[1]:getCost() then
      --pop = PopupView:createTextPopup(_tr("no_spirite_to_saodang"),nil,true)
      --GameData:Instance():getCurrentScene():addChildView(pop)
	    Common.CommonFastBuySpirit()
      return
    end
    
    pop = ScenarioPopQuickFight.new(stagesToFight)
    pop:setDelegate(self:getDelegate())
    self:addChild(pop,999)
    pop:setScale(0.2)
    pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
    self:setPopQuickFightView(pop)
    
end

-- normal stage hook
function ScenarioView:alertQuickFight(stage)
   --today's hook count  
  --[[if Scenario:Instance():getQuickFightCount() >= AllConfig.vipinitdata[2].quick_stage then
--     print(Scenario:Instance():getQuickFightCount(),AllConfig.vipinitdata[2].quick_stage)
--     local pop = PopupView:createTextPopup("今日扫荡次数已用完！", function() return   end,true)
--     self:getDelegate():getScene():addChild(pop,100)
--     return
  end
  
  local vipLevelId = GameData:Instance():getCurrentPlayer():getVipLevelId()
  if GameData:Instance():getCurrentPlayer():isVipState() == false
  or Scenario:Instance():getQuickFightCount() >= AllConfig.vipinitdata[vipLevelId].quick_stage then
     local prop = GameData:Instance():getCurrentPackage():getPropsByConfigId(StageConfig.HookTicketConfigId)

     if prop ~= nil and prop:getCount() > 0 then
        print("prop:",prop)
        print("propCount:",prop:getCount())
     else
        self:alertBuyVip()
        return
     end
  end]]
  
  local pop = nil
  if stage:getIsPassed() == false then
     pop = PopupView:createTextPopup(_tr("can_saodang_after_pass_curstage"), function() return   end,true)
     self:getDelegate():getScene():addChildView(pop,100)
     return
  end
  
  if GameData:Instance():getCurrentPlayer():getSpirit() < stage:getCost() then
	   Common.CommonFastBuySpirit()
     --pop = PopupView:createTextPopup(_tr("not_enough_engergy"), function() return end,true)
     --GameData:Instance():getCurrentScene():addChildView(pop)
     return
  end
  
  
  pop = ScenarioPopQuickFight.new({stage})
  pop:setDelegate(self:getDelegate())
  self:addChild(pop,999)
  pop:setScale(0.2)
  pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
  self:setPopQuickFightView(pop)
end

------
--  Getter & Setter for
--      ScenarioView._PopQuickFight 
-----
function ScenarioView:setPopQuickFightView(PopQuickFight)
	self._PopQuickFight = PopQuickFight
end

function ScenarioView:getPopQuickFightView()
	return self._PopQuickFight
end


function ScenarioView:onBackHandler()
  ScenarioView.super:onBackHandler()
  
  GameData:Instance():gotoPreView()
end

function ScenarioView:tabControlOnClick(idx)
  
  ScenarioView.super:tabControlOnClick(idx)
  --reset btn
  self._btnGotoNormal:setVisible(false)
  self._btnGotoElite:setVisible(false)
  self._btnHookElite:setVisible(false)
  
  self._currentCheckPointIsElite = false
  self._chapterId = idx+1
  local chapter = self.scenario:getChapterById(self._chapterId)
  local stage = chapter:getNormalCheckPoints()[1]:getStages()[1]
  self.scenario:setCurrentStage(stage)
  self:goToChapter(chapter,self._currentCheckPointIsElite,nil,nil,true)
  
  _executeNewBird()
end



return ScenarioView