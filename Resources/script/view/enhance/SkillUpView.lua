require("view.BaseView")
require("view.component.ViewWithEave")
require("view.component.ProgressBarView")
require("view.component.Loading")
require("view.component.MiddleCardHeadView")


SkillUpView = class("SkillUpView", ViewWithEave)


function SkillUpView:ctor()

  SkillUpView.super.ctor(self)
  --self:setTabControlEnabled(false)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("selectHeroCallback",SkillUpView.selectHeroCallback)
  pkg:addFunc("startSkillUpCallback",SkillUpView.startSkillUpCallback)
  pkg:addFunc("reduceCallback1",SkillUpView.reduceCallback1)
  pkg:addFunc("reduceCallback2",SkillUpView.reduceCallback2)
  pkg:addFunc("reduceCallback3",SkillUpView.reduceCallback3)
  pkg:addFunc("reduceCallback4",SkillUpView.reduceCallback4)
  pkg:addFunc("reduceCallback5",SkillUpView.reduceCallback5)
  pkg:addFunc("sourceCallback",SkillUpView.sourceCallback)
  
  pkg:addProperty("sprite_selectHero","CCSprite")
  pkg:addProperty("sprite_book1","CCSprite")
  pkg:addProperty("sprite_book2","CCSprite")
  pkg:addProperty("sprite_book3","CCSprite")
  pkg:addProperty("sprite_book4","CCSprite")
  pkg:addProperty("sprite_book5","CCSprite")
  
  pkg:addProperty("node_progress","CCNode")
  pkg:addProperty("node_largeheader","CCNode")
  pkg:addProperty("node_readme","CCNode")
  pkg:addProperty("node_books","CCNode")
  -- pkg:addProperty("node_desc","CCNode")
  pkg:addProperty("node_skillInfo","CCNode")
  pkg:addProperty("node_level","CCNode")
  pkg:addProperty("node_bookContainer","CCNode")
  pkg:addProperty("node_skillDesc","CCNode")
  pkg:addProperty("label_skillName","CCLabelBMFont")
  pkg:addProperty("label_curLevel","CCLabelTTF")
  pkg:addProperty("label_nextLevel","CCLabelTTF")
  pkg:addProperty("label_coinCost","CCLabelTTF")
  pkg:addProperty("label_gainExperience","CCLabelTTF")
  pkg:addProperty("label_needExperience","CCLabelTTF")
  pkg:addProperty("label_nextHurt","CCLabelTTF")
  pkg:addProperty("label_leftNum1","CCLabelTTF")
  pkg:addProperty("label_leftNum2","CCLabelTTF")
  pkg:addProperty("label_leftNum3","CCLabelTTF")
  pkg:addProperty("label_leftNum4","CCLabelTTF")
  pkg:addProperty("label_leftNum5","CCLabelTTF")
  pkg:addProperty("label_selectedNum1","CCLabelBMFont")
  pkg:addProperty("label_selectedNum2","CCLabelBMFont")
  pkg:addProperty("label_selectedNum3","CCLabelBMFont")
  pkg:addProperty("label_selectedNum4","CCLabelBMFont")
  pkg:addProperty("label_selectedNum5","CCLabelBMFont")

  pkg:addProperty("bn_source","CCMenuItemSprite")
  pkg:addProperty("menu_startSkillUp","CCControlButton")
  pkg:addProperty("bn_reduce1","CCControlButton")
  pkg:addProperty("bn_reduce2","CCControlButton")
  pkg:addProperty("bn_reduce3","CCControlButton")
  pkg:addProperty("bn_reduce4","CCControlButton")
  pkg:addProperty("bn_reduce5","CCControlButton")
  pkg:addProperty("menu_selectHero","CCMenuItemSprite")

  --default label
  pkg:addProperty("label_readmeContent","CCLabelTTF")
  pkg:addProperty("label_preSkillName","CCLabelTTF")
  pkg:addProperty("label_preSkillLevel","CCLabelTTF")
  pkg:addProperty("label_curExp","CCLabelTTF")
  pkg:addProperty("label_preSkillDesc","CCLabelTTF")
  pkg:addProperty("label_tips1","CCLabelTTF")
  pkg:addProperty("label_tips2","CCLabelTTF")
  pkg:addProperty("label_left","CCLabelTTF")
  pkg:addProperty("label_gain","CCLabelTTF")
  pkg:addProperty("label_preCost","CCLabelTTF")
  pkg:addProperty("label_stillNeed","CCLabelTTF")

  local layer,owner = ccbHelper.load("SkillUpView.ccbi","SkillUpViewCCB","CCLayer",pkg)
  self:getEaveView():getNodeContainer():addChild(layer)
end


function SkillUpView:init()
  echo("---SkillUpView:init---")
  if self:getDelegate():getTabMenuVisible() == false then 
    self:setTitleTextureName("lv_title_xiuxing.png")
    self:setTabControlEnabled(false)
  else 
    self.bn_source:setVisible(false)
    self:setTitleTextureName("cardlvup-image-paibian.png")
    local menuArray = {
        {"#bn_levelup_0.png","#bn_levelup_1.png"},
        {"#bn_surmount_0.png","#bn_surmount_1.png"},
        {"#bn_dismantle_0.png","#bn_dismantle_1.png"},
        {"#bn_skillUp0.png","#bn_skillUp1.png"}
      }
    self:setMenuArray(menuArray)
    self:getTabMenu():setItemSelectedByIndex(4) 
  end 

  self.label_readmeContent:setString(_tr("skillupinfo"))
  self.label_preSkillName:setString(_tr("skill name"))
  self.label_preSkillLevel:setString(_tr("skill level"))
  self.label_curExp:setString(_tr("current exp"))
  self.label_preSkillDesc:setString(_tr("skill desc"))
  self.label_tips1:setString(_tr("skill tip1"))
  self.label_tips2:setString(_tr("skill tip2"))
  self.label_left:setString(_tr("left"))
  self.label_gain:setString(_tr("gain"))
  self.label_preCost:setString(_tr("cost"))
  self.label_stillNeed:setString(_tr("still_need_for_skillup"))

  self:setIsSkillUping(false)
  net.registMsgCallback(PbMsgId.UpdateCardSkillExperienceResult, self, SkillUpView.cardSkillUpResult)
  self:skillBooksInit()

  --init new guide 
  _registNewBirdComponent(103101,self.sprite_book1)
  _registNewBirdComponent(103102,self.sprite_book2)
  _registNewBirdComponent(103103,self.sprite_book3)
  _registNewBirdComponent(103104,self.sprite_book4)
  _registNewBirdComponent(103105,self.sprite_book5)
  
  _registNewBirdComponent(103002,self.menu_startSkillUp)
  _registNewBirdComponent(103003, self:getEaveView().btnBack)

  _executeNewBird()
  
  self.skillCard = self:getDelegate():dataInstance():getSkillCard()
  if self.skillCard == nil then
    self.node_readme:setVisible(true)
    self.node_skillInfo:setVisible(false)

    local action = CCSequence:createWithTwoActions(CCFadeTo:create(1.0, 100),CCFadeTo:create(1.0, 255))
    self.sprite_selectHero:runAction(CCRepeatForever:create(action))    
  else
    self.node_readme:setVisible(false)
    self.node_books:setVisible(true)
    --self.menu_startSkillUp:setEnabled(true)
    local largeCard = MiddleCardHeadView.new()
    largeCard:setCard({card = self.skillCard})

    local size = largeCard:getContentSize()
    local scale = self.menu_selectHero:getContentSize().width/size.width
    largeCard:setScale(scale)

    largeCard:setPosition(ccp(-size.width/2, -size.height/2))
    self.node_largeheader:addChild(largeCard)

    self:updateSkillInfo(true)
    self:initSelectBookHandler()
  end
end

function SkillUpView:skillBooksInit()

  self.selectedArr = {self.label_selectedNum1, self.label_selectedNum2, self.label_selectedNum3, self.label_selectedNum4, self.label_selectedNum5}
  self.leftArr = {self.label_leftNum1, self.label_leftNum2, self.label_leftNum3, self.label_leftNum4, self.label_leftNum5}
  self.btnDecArr = {self.bn_reduce1, self.bn_reduce2, self.bn_reduce3, self.bn_reduce4, self.bn_reduce5}
  self.spriteBookArr = {self.sprite_book1, self.sprite_book2, self.sprite_book3, self.sprite_book4, self.sprite_book5}
  local pos = ccp(self.spriteBookArr[1]:getContentSize().width/2, self.spriteBookArr[1]:getContentSize().height/2)
  for i = 1, 5 do 
    self.selectedArr[i]:setVisible(false)
    self.leftArr[i]:setString("0")
    self.btnDecArr[i]:setVisible(false)

    local book = _res(3050040+i-1)
    if book ~= nil then 
      book:setPosition(pos)
      self.spriteBookArr[i]:addChild(book, 1)
      local rarebg = _res(3021041+i-1)
      if rarebg ~= nil then 
        rarebg:setPosition(pos)
        self.spriteBookArr[i]:addChild(rarebg, 2)
      end
    end
  end

  self:resetBooksInfo()

  self.label_gainExperience:setString("0")
  self.label_needExperience:setString("0")
  self.label_coinCost:setString("0")
end

function SkillUpView:resetBooksInfo()

  for i=1, 5 do 
    self.selectedArr[i]:setVisible(false)
    self.leftArr[i]:setString("")
  end

  self.skillBooksArray = GameData:Instance():getCurrentPackage():getSkillBooks()
  local num = table.getn(self.skillBooksArray)
  for i=1, num do
    self.skillBooksArray[i].selectedNum = 0 
    local idx = self.skillBooksArray[i]:getGrade()
    self.leftArr[idx]:setString(string.format("%d", self.skillBooksArray[i]:getCount()))
  end
end 

function SkillUpView:updateSkillInfo(isUpdateAll)
  if self.skillCard == nil then 
    -- self.label_skillName:setString("")
    self.label_curLevel:setString("")
    -- self.node_desc:removeAllChildrenWithCleanup(true)
    return 
  end

  local skill = self.skillCard:getSkill()
  if skill == nil then 
    return
  end

  local curlevel = skill:getLevel()
  local nextLevel = curlevel

  if self.myprogresser == nil then
    local bg = CCSprite:createWithSpriteFrameName("pg_bg.png")
    local fg1 = CCSprite:createWithSpriteFrameName("pg_green.png")
    local fg2 = CCSprite:createWithSpriteFrameName("pg_yellow.png")
    self.myprogresser = ProgressBarView.new(bg, fg1, fg2)
    self.myprogresser:setPercent(0, 1)
    self.myprogresser:setPercent(0, 2)
    self.myprogresser:setBreathAnim(1)
    self.node_progress:addChild(self.myprogresser)
  end

  --calc exp and cost
  self.coinCost = 0
  self.gainedExp = 0
  for k,v in pairs(self.skillBooksArray) do
    local idx = v:getGrade()
    if v.selectedNum >= 1 then 
      self.gainedExp = self.gainedExp + v:getSkillExp() * v.selectedNum
      self.coinCost = self.coinCost + AllConfig.item[v:getConfigId()].skill_cost * v.selectedNum

      self.btnDecArr[idx]:setVisible(true)
      self.selectedArr[idx]:setVisible(true)
    else 
      self.btnDecArr[idx]:setVisible(false)
      self.selectedArr[idx]:setVisible(false)
    end
  end

  self.needExp = skill:getMaxLevelTotalExp() - skill:getExperience() - self.gainedExp 
  if self.needExp < 0 then 
    self.needExp = 0
  end

  local exp = skill:getExperience() + self.gainedExp
  if self.gainedExp > 0 then 
    nextLevel = skill:getLevelByExp(exp)
    self.node_level:setVisible(true)
    self.label_nextLevel:setString(string.format("%d", nextLevel))
    self.label_curLevel:setString(string.format("%d", curlevel))
  else 
    self.node_level:setVisible(false)

    self.label_curLevel:setString(string.format("%d/%d", curlevel, skill:getMaxLevel()))
    if curlevel==skill:getMaxLevel() then 
      self.label_curLevel:setColor(ccc3(32,143,0))
    end 
  end 
  

  --set progress percent
  if self.gainedExp > 0 then 
    local percent1 = 100
    if nextLevel == curlevel then 
      percent1 = skill:getExpPercentByLeve(nextLevel, exp)
    end

    self.myprogresser:setFgVisible(true, 1) --显示绿色进度条
    self.myprogresser:setPercent(percent1, 1)
  else 
    self.myprogresser:setFgVisible(false, 1) --显示绿色进度条
    self.myprogresser:setPercent(0, 1)
  end

  self.label_gainExperience:setString(string.format("%d", self.gainedExp))  
  self.label_needExperience:setString(string.format("%d", self.needExp))  
  self.label_coinCost:setString(string.format("%d", self.coinCost))

  --update desc
  self.node_skillDesc:removeAllChildrenWithCleanup(true)
  local dimensition = self.node_skillDesc:getContentSize()
  local skillInfoStr = GameData:Instance():formatSkillDesc(self.skillCard, true, false, nextLevel-curlevel)
  local label = RichLabel:create(skillInfoStr, "Courier-Bold",20,CCSizeMake(dimensition.width, 0),false,false)
  local textSize = label:getTextSize()
  if textSize.height <= dimensition.height then 
    label:setPosition(ccp(0, textSize.height+(dimensition.height-textSize.height)/2))
    self.node_skillDesc:addChild(label)
  else --超出范围则用scrollview显示文本
    local nodeDesc = CCNode:create()
    nodeDesc:setContentSize(textSize)
    label:setPosition(ccp(0, textSize.height))
    nodeDesc:addChild(label)      

    local scrollView = CCScrollView:create()
    scrollView:setContentSize(textSize)
    scrollView:setViewSize(dimensition)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    nodeDesc:setPosition(ccp(0, -(textSize.height-dimensition.height)))
    scrollView:setContainer(nodeDesc)
    -- scrollView:setTouchPriority(-301)
    self.node_skillDesc:addChild(scrollView)
  end 


  if isUpdateAll == nil or isUpdateAll == true then 
    self.label_skillName:setString(skill:getName())

    local percent = skill:getExpPercentByLeve(curlevel, skill:getExperience())
    self.myprogresser:setPercent(percent, 2)
  end
end


function SkillUpView:onEnter()
  echo("---SkillUpView:onEnter---")
  self:init()
end

function SkillUpView:onExit()
  echo("---SkillUpView:onExit---")
  net.unregistAllCallback(self)

  if self.myprogresser ~= nil then 
    self.myprogresser:stopProgressBar()
  end

  if self.scheduleId ~= nil then 
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
    self.scheduleId = nil 
  end
end 

function SkillUpView:onHelpHandler()
  echo("helpCallback.")
  local help = HelpView.new()
  help:addHelpBox(1014)
  help:addHelpItem(1015, self.node_largeheader, ccp(60,20), ArrowDir.LeftLeftUp)
  help:addHelpItem(1016, self.sprite_book2, ccp(40,-80), ArrowDir.RightUp)
  help:addHelpItem(1017, self.menu_startSkillUp, ccp(40,20), ArrowDir.RightDown)
  self:getDelegate():getScene():addChild(help, 1000)
end

function SkillUpView:onBackHandler()
  echo("SkillUpView:backCallback")
  SkillUpView.super:onBackHandler()
  _executeNewBird()
  self:getDelegate():goBackView()
end

function SkillUpView:tabControlOnClick(idx)
  _playSnd(SFX_CLICK)  

  local result = true
  if idx == 0 then
    result = self:getDelegate():displayLevelUpView()
  elseif idx == 1 then
    result = self:getDelegate():displaySurmountView()
  elseif idx == 2 then
    self:getDelegate():displayDismantleView()
  elseif idx == 3 then
  end

  return result
end

function SkillUpView:selectHeroCallback()
  echo("selectHeroCallback")
  if self:getIsSkillUping() == true then
    return 
  end

  if self:getDelegate():getTabMenuVisible() == false then 
    if self.skillCard ~= nil then 
      echo("disable selecte other card for playstate")
      return 
    end
  end 
  
  self:getDelegate():disPlayCardListForSkillUp()
end

function SkillUpView:initSelectBookHandler()
  self.touchIndex = -1
  self.touchBook = nil
  self.bookSelected = false
  

  local function selecteOneBook()
    _executeNewBird()
  
    echo("=== selecteOneBook, needExp=", self.needExp)
    self.bookSelected = true 

    if self.touchBook ~= nil then
      echo("==============book count", self.touchBook:getCount())
      if self.touchBook.selectedNum < self.touchBook:getCount() then 
        if self.needExp > 0 then
          self.touchBook.selectedNum = self.touchBook.selectedNum + 1
          local grade = self.touchBook:getGrade()
          self.selectedArr[grade]:setString(string.format("%d",self.touchBook.selectedNum))
          self.leftArr[grade]:setString(string.format("%d", self.touchBook:getCount()-self.touchBook.selectedNum))

          self:updateSkillInfo(false)
        end
      end 
    end
  end

  local function onTouch(event, x, y)

    local pos = self.node_bookContainer:convertToNodeSpace(ccp(x, y))

    if event == "began" then
      self.bookSelected = false      
      if self.booksRect:containsPoint(pos) then 
        self.touchIndex = math.floor(pos.x/(self.node_bookContainer:getContentSize().width/5))
        echo("=== touch began, index=", self.touchIndex)

        self.touchBook = nil
        for k, v in pairs(self.skillBooksArray) do 
          if v:getGrade() == self.touchIndex + 1 then 
            self.touchBook = v
          end
        end

        if self.scheduleId ~= nil then 
          CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
          self.scheduleId = nil 
        end        
        self.scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(selecteOneBook, 0.4, false)
        return true
      end

    elseif event == "moved" then
      echo("=== moving")
      local flag = false 
      if self.booksRect:containsPoint(pos) then
        local index = math.floor(pos.x/(self.node_bookContainer:getContentSize().width/5))
        if index == self.touchIndex then 
          flag = true 
        end
      end

      if flag == false then 
        if self.scheduleId ~= nil then 
          CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
          self.scheduleId = nil 
        end
        self.touchIndex = -1
      end 

    elseif event == "ended" then
      if self.booksRect:containsPoint(pos) then 
        if self.scheduleId ~= nil then 
          CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
          self.scheduleId = nil 
        end
        local index = math.floor(pos.x/(self.node_bookContainer:getContentSize().width/5))
        echo("=== touch ended, index=", self.touchIndex)
        if (index == self.touchIndex) and (self.bookSelected == false) then 
          selecteOneBook()
        end
      end 
    end

    return false
  end 

  local size = self.node_bookContainer:getContentSize()
  self.booksRect = CCRectMake(0, 0, size.width,size.height)
  self.touchIndex = 0


  self:addTouchEventListener(onTouch, false, 0, true)
  self:setTouchEnabled(true)
end 

function SkillUpView:cardSkillUpResult(action,msgId,msg)
  echo("---cardSkillUpResult---:", msg.state)

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading()

  if msg.state ~= "Ok" then
    self:setIsSkillUping(false)
  end

  if msg.state == "Ok" then
    
    self.isProgressFinish = false
    self:playSkillupAnim()
    
    local skill = self.skillCard:getSkill()

    local preExp = skill:getExperience()
    local preLevel = skill:getLevel()
    local levelCount = preLevel
    local startPercent = skill:getExpPercentByLeve(preLevel, skill:getExperience())
    --update props
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    local curLevel = skill:getLevel()
    local endPercent = skill:getExpPercentByLeve(curLevel, skill:getExperience())
    endPercent = endPercent + 100*(curLevel - preLevel)
    echo("---preLevel,curLevel, gainded Exp=", preLevel, curLevel, skill:getExperience()-preExp)
    echo("---startPercent,endPercent =",startPercent, endPercent)

    local function progressFinish()
      echo("progress finish")
      self.isProgressFinish = true      
      self:setIsSkillUping(false)
      -- self:updateSkillInfo(true)    
    end

    local function fullPercentComplete()
      levelCount = levelCount + 1
      echo("fullPercentComplete:level =", levelCount)
      self.label_curLevel:setString(string.format("%d", levelCount))
    end

    if self.myprogresser ~= nil then
      self.myprogresser:setFgVisible(false, 1) --隐藏绿色进度条
      self.myprogresser:startProgressing(progressFinish, startPercent, endPercent, 2)
      self.myprogresser:setFullPercentCallback(fullPercentComplete)
    else
      progressFinish()
    end
  elseif msg.state == "NoSuchCardId" then
     Toast:showString(self, _tr("no such card"), ccp(display.width/2, display.height*0.4))  
  elseif msg.state == "NoSuchItem" then
     Toast:showString(self, _tr("no such book"), ccp(display.width/2, display.height*0.4))         
  elseif msg.state == "SkillCouldNotGrowup" then
     Toast:showString(self, _tr("is max skill level"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NeedMoreItem" then
     Toast:showString(self, _tr("not enough books"), ccp(display.width/2, display.height*0.4))    
  elseif msg.state == "NeedMoreCoin" then
     Toast:showString(self, _tr("not enough coin"), ccp(display.width/2, display.height*0.4))       
  else
    Toast:showString(self, msg.state, ccp(display.width/2, display.height*0.4))
  end
end

function SkillUpView:startSkillUpCallback()
  echo("---startSkillUpCallback---")
  _playSnd(SFX_CLICK)

  if self:getIsSkillUping() == true then
    return 
  end
  
  _executeNewBird()

  if self.skillCard == nil then 
    Toast:showString(self, _tr("please select card"), ccp(display.width/2, display.height*0.4))
    return
  end

  local skill = self.skillCard:getSkill()
  if skill:getLevel() == skill:getMaxLevel() then 
    Toast:showString(self, _tr("is max skill level"), ccp(display.width/2, display.height*0.4))
    return 
  end

  local coin = GameData:Instance():getCurrentPlayer():getCoin()
  if self.coinCost > coin then
    Toast:showString(self, _tr("not enough coin"), ccp(display.width/2, display.height*0.4))
    return
  end

  local found = false
  local eatenBooks = {}
  local cardId = self.skillCard:getId()

  for k,v in pairs(self.skillBooksArray) do 
    echo("v.selectedNum=", v.selectedNum)
    if v.selectedNum >= 1 then 
      found = true
      echo("eaten books: id, count=", v:getId(),v.selectedNum)
      table.insert(eatenBooks, {id=v:getId(), count=v.selectedNum})
    end
  end

  if found == true then 
    --start to skill up
    _showLoading()
    local data = PbRegist.pack(PbMsgId.UpdateCardSkillExperience, {card_id=cardId, book=eatenBooks})
    net.sendMessage(PbMsgId.UpdateCardSkillExperience, data)
    --show waiting
    --self.loading = Loading:show()

    self:setIsSkillUping(true)

     --backup battle ability for toast
    local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
    self.preBattleAbility = GameData:Instance():getBattleAbilityForCards(battleCards)   
    
  else 
    echo(" has no books for skill up ")
    Toast:showString(self, _tr("no_skill_books"), ccp(display.width/2, display.height*0.4))
  end
end

function SkillUpView:unSelectOneBook(index)
  for k,v in pairs(self.skillBooksArray) do
    if index == v:getGrade() then
      if v.selectedNum > 0  then 
        v.selectedNum = v.selectedNum - 1
        self.selectedArr[index]:setString(string.format("%d", v.selectedNum))
        self.leftArr[index]:setString(string.format("%d", v:getCount()-v.selectedNum))
        self:updateSkillInfo(false)
      end
    end
  end
end 

function SkillUpView:reduceCallback1()
  self:unSelectOneBook(1)
end 

function SkillUpView:reduceCallback2()
  self:unSelectOneBook(2)
end 

function SkillUpView:reduceCallback3()
  self:unSelectOneBook(3)
end 

function SkillUpView:reduceCallback4()
  self:unSelectOneBook(4)
end 

function SkillUpView:reduceCallback5()
  self:unSelectOneBook(5)
end 

function SkillUpView:sourceCallback()
  -- if GameData:Instance():checkSystemOpenCondition(4, true) == false then 
  --   return 
  -- end 
  -- local controller = ControllerFactory:Instance():create(ControllerType.EXPEDITION_CONTROLLER)
  -- controller:enter(ViewType.enhance_skillup)  

  local stage = Scenario:Instance():getLastNormalStage()
  local controller = ControllerFactory:Instance():create(ControllerType.SCENARIO_CONTROLLER)
  controller:enter()
  controller:gotoStageById(stage:getStageId())  
end


function SkillUpView:setIsSkillUping(isSkillUping)
  self.isSkillUping = isSkillUping
end

function SkillUpView:getIsSkillUping()
  echo("...isSkillUping =", self.isSkillUping)
  return self.isSkillUping
end


function SkillUpView:playSkillupAnim()

  local function playAnimOk()
    local anim,offsetX,offsetY,duration = _res(5020146)
    if anim ~= nil then
      self.node_largeheader:addChild(anim)
      anim:getAnimation():play("default")
      self:performWithDelay(function ()
                              anim:removeFromParentAndCleanup(true)

                              --reset
                              self:setIsSkillUping(false)                
                              for k, v in pairs(self.skillBooksArray) do 
                                v.selectedNum = 0
                              end
                              self:updateSkillInfo(true)
                              self:resetBooksInfo()
                              self:removeMaskLayer()

                              GameData:Instance():getCurrentPlayer():toastBattleAbility(self.preBattleAbility)
                            end,
                            duration)
    else 
      self:removeMaskLayer()
    end
  end


  local function repeatCheck()
    if self.repeatAnim ~= nil then 
      echo("repeate")

      if self.isProgressFinish == true then 
        echo("---remove finish anim")
        self.repeatAnim:removeFromParentAndCleanup(true)
        self.repeatAnim = nil

        --setp 3. play finish anim
        playAnimOk()    
      else 
        self:performWithDelay(repeatCheck, 0.5)
      end
    end
  end


  --step 1. play eat anim
  local duration_time = 0
  for k, v in pairs(self.skillBooksArray) do 
    if v.selectedNum >= 1 then 
        local node = self.spriteBookArr[v:getGrade()]
        local anim,offsetX,offsetY,duration = _res(5020097)
        duration_time = duration
        anim:setPosition(ccp(node:getContentSize().width/2, node:getContentSize().height/2))
        node:addChild(anim, 2)
        anim:getAnimation():play("default")

        local action = CCSequence:createWithTwoActions(CCDelayTime:create(duration),
                          CCCallFunc:create(function () 
                                              anim:removeFromParentAndCleanup(true)
                                            end))        
        node:runAction(action)
    end
  end

  if duration_time > 0 then 
    self:addMaskLayer()
    self:performWithDelay(function ()
                            --step 2. play repeat anim
                            self.repeatAnim = _res(5020102)
                            if self.repeatAnim ~= nil then 
                              self.node_largeheader:addChild(self.repeatAnim, 2)
                              self.repeatAnim:getAnimation():play("default")
                            end

                            --start repeat check
                            self:performWithDelay(repeatCheck, 0.5)
                          end,
                          duration_time*0.8)
  end
end


function SkillUpView:addMaskLayer()
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self:performWithDelay(handler(self, SkillUpView.removeMaskLayer), 6.0)
end 

function SkillUpView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 