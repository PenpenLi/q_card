require("view.BaseView")
require("view.component.ProgressBarView")

CardSkillUpView = class("CardSkillUpView", BaseView)

function CardSkillUpView:ctor(card, priority)
  CardSkillUpView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("closeCallback",CardSkillUpView.closeCallback)
  pkg:addFunc("startSkillUp",CardSkillUpView.startSkillUp)
  pkg:addFunc("reduceCallback1",CardSkillUpView.reduceCallback1)
  pkg:addFunc("reduceCallback2",CardSkillUpView.reduceCallback2)
  pkg:addFunc("reduceCallback3",CardSkillUpView.reduceCallback3)
  pkg:addFunc("reduceCallback4",CardSkillUpView.reduceCallback4)
  pkg:addFunc("reduceCallback5",CardSkillUpView.reduceCallback5)

  pkg:addProperty("layer_mask","CCLayerColor")
  pkg:addProperty("node_curDesc","CCNode")
  pkg:addProperty("node_nextDesc","CCNode")
  pkg:addProperty("node_progress","CCNode")
  pkg:addProperty("node_bookContainer","CCNode")

  pkg:addProperty("bn_close","CCControlButton")
  pkg:addProperty("bn_skillup","CCControlButton")
  pkg:addProperty("bn_reduce1","CCControlButton")
  pkg:addProperty("bn_reduce2","CCControlButton")
  pkg:addProperty("bn_reduce3","CCControlButton")
  pkg:addProperty("bn_reduce4","CCControlButton")
  pkg:addProperty("bn_reduce5","CCControlButton")

  pkg:addProperty("sprite_attr","CCSprite")
  pkg:addProperty("sprite9_bg","CCScale9Sprite")
  pkg:addProperty("label_skillName","CCLabelTTF")
  pkg:addProperty("label_level","CCLabelTTF")
  pkg:addProperty("label_curLevel","CCLabelTTF")
  pkg:addProperty("label_nextLevel","CCLabelTTF")
  pkg:addProperty("label_pregGain","CCLabelTTF")
  pkg:addProperty("label_gain","CCLabelTTF")
  pkg:addProperty("label_preStillNeed","CCLabelTTF")
  pkg:addProperty("label_stillNeed","CCLabelTTF")  
  pkg:addProperty("label_preCost","CCLabelTTF")
  pkg:addProperty("label_cost","CCLabelTTF")


  local layer,owner = ccbHelper.load("CardSkillUpView.ccbi","CardSkillUpViewCCB","CCLayer",pkg)
  self:addChild(layer)

  self.skillCard = card 
  self.priority = priority or -128 

  net.registMsgCallback(PbMsgId.UpdateCardSkillExperienceResult, self, CardSkillUpView.cardSkillUpResult)
end

function CardSkillUpView:onEnter()
  if self.skillCard == nil then 
    return 
  end 
  
  self.enhanceChangeFlag = false 
  self:init()
  _executeNewBird()
end 

function CardSkillUpView:onExit()
  net.unregistAllCallback(self)
  if self.myprogresser ~= nil then 
    self.myprogresser:stopProgressBar()
  end  

  -- if self:getDelegate() then 
  --   if self.enhanceChangeFlag then 
  --     self:getDelegate():updateView()
  --   end 
  -- end   
end 

function CardSkillUpView:init()
  _registNewBirdComponent(106012, self.bn_skillup)
  _registNewBirdComponent(106017, self.bn_close)


  self.label_preStillNeed:setString(_tr("still_need_for_skillup"))
  self.label_pregGain:setString(_tr("gain"))
  self.label_preCost:setString(_tr("cost"))
  
  self.bn_close:setTouchPriority(-1001)
  self.bn_skillup:setTouchPriority(self.priority)
  self.bn_reduce1:setTouchPriority(self.priority)
  self.bn_reduce2:setTouchPriority(self.priority)
  self.bn_reduce3:setTouchPriority(self.priority)
  self.bn_reduce4:setTouchPriority(self.priority)
  self.bn_reduce5:setTouchPriority(self.priority)

  self.layer_mask:addTouchEventListener(function(event, x, y)
                                          local size = self.sprite9_bg:getContentSize()
                                          local pos = self.sprite9_bg:convertToNodeSpace(ccp(x, y))
                                          if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
                                            self:closeCallback()
                                          end
                                          return true 
                                        end,
                                        false, self.priority+1, true)
  self.layer_mask:setTouchEnabled(true)

  self:skillBooksInit() 
  self:initSelectBookHandler()
  self:updateSkillInfo() 
end 

function CardSkillUpView:skillBooksInit()

  self.selectedNumTbl = {}
  self.leftNumTbl = {}
  self.btnDecTbl = {self.bn_reduce1, self.bn_reduce2, self.bn_reduce3, self.bn_reduce4, self.bn_reduce5}

  local iconSize = 80 
  local gridSize = CCSizeMake(self.node_bookContainer:getContentSize().width/5, self.node_bookContainer:getContentSize().height)
  local pos, label 
  for i = 1, 5 do 
    self.btnDecTbl[i]:setVisible(false)

    local book = GameData:Instance():getCurrentPackage():getItemSprite(nil, 6, 21001001+i-1, 0, true, false)
    if book ~= nil then 
      pos = ccp(i*gridSize.width-gridSize.width/2,  gridSize.height/2)
      book:setScale(iconSize/book:getContentSize().width)
      book:setPosition(pos)
      self.node_bookContainer:addChild(book)
      self.leftNumTbl[i] = book:getChildByTag(100)

      label = CCLabelBMFont:create("", "client/widget/words/card_name/number_skillup.fnt")
      label:setPosition(ccp(pos.x+4, pos.y+gridSize.height/2+18))
      self.node_bookContainer:addChild(label)
      self.selectedNumTbl[i] = label 

      _registNewBirdComponent(106600+i, book)
    end
  end

  self:resetBooksInfo()
end

function CardSkillUpView:resetBooksInfo()
  self.label_gain:setString("0")
  self.label_stillNeed:setString("0")
  self.label_cost:setString("0")

  for i=1, 5 do 
    if self.selectedNumTbl[i] then 
      self.selectedNumTbl[i]:setString("")
    end 
    if self.leftNumTbl[i] then 
      self.leftNumTbl[i]:setString("")
    end 
  end

  self.skillBooksArray = GameData:Instance():getCurrentPackage():getSkillBooks()
  for i=1, #self.skillBooksArray do
    self.skillBooksArray[i].selectedNum = 0 
    local idx = self.skillBooksArray[i]:getGrade()
    if self.leftNumTbl[idx] then 
      self.leftNumTbl[idx]:setString(string.format("%d", self.skillBooksArray[i]:getCount()))
    end 
  end
end 

function CardSkillUpView:initSelectBookHandler()
  self.touchIndex = -1
  self.touchBook = nil
  self.bookSelected = false
  
  local function selecteOneBook()
    local skill = self.skillCard:getSkill()
    if skill:getLevel() == skill:getMaxLevel() then 
      Toast:showString(self, _tr("is max skill level"), ccp(display.cx, display.cy))
      return 
    end

    echo("=== selecteOneBook")
    self.bookSelected = true 

    if self.touchBook ~= nil then
      echo("=== book count", self.touchBook:getCount())
      if self.touchBook.selectedNum < self.touchBook:getCount() then 
        if self.needExp and self.needExp > 0 then
          self.touchBook.selectedNum = self.touchBook.selectedNum + 1
          local grade = self.touchBook:getGrade()
          if self.selectedNumTbl[grade] then 
            self.selectedNumTbl[grade]:setString(string.format("%d",self.touchBook.selectedNum))
          end 
          if self.leftNumTbl[grade] then 
            self.leftNumTbl[grade]:setString(string.format("%d", self.touchBook:getCount()-self.touchBook.selectedNum))
          end 
          self:updateSkillInfo()
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

        if self.bookTimer ~= nil then 
          self:stopAction(self.bookTimer)
          self.bookTimer = nil 
        end        
        self.bookTimer = self:schedule(selecteOneBook, 0.3) 
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
        if self.bookTimer ~= nil then 
          self:stopAction(self.bookTimer)
          self.bookTimer = nil 
        end 
        self.touchIndex = -1
      end 

    elseif event == "ended" then
      if self.booksRect:containsPoint(pos) then 
        if self.bookTimer ~= nil then 
          self:stopAction(self.bookTimer)
          self.bookTimer = nil 
        end 
        local index = math.floor(pos.x/(self.node_bookContainer:getContentSize().width/5))
        echo("=== touch ended, index=", self.touchIndex)
        if (index == self.touchIndex) and (self.bookSelected == false) then 
          selecteOneBook()
          _executeNewBird()
        end
      end 
    end

    return false
  end 

  local size = self.node_bookContainer:getContentSize()
  self.booksRect = CCRectMake(0, 0, size.width,size.height)
  self.touchIndex = 0


  self:addTouchEventListener(onTouch, false, self.priority, true)
  self:setTouchEnabled(true)
end 

function CardSkillUpView:unSelectOneBook(index)
  for k, v in pairs(self.skillBooksArray) do
    if index == v:getGrade() then
      if v.selectedNum > 0  then 
        v.selectedNum = v.selectedNum - 1
        if self.selectedNumTbl[index] then 
          self.selectedNumTbl[index]:setString(string.format("%d",v.selectedNum))
        end 

        if self.leftNumTbl[index] then 
          self.leftNumTbl[index]:setString(string.format("%d", v:getCount()-v.selectedNum))
        end 

        self:updateSkillInfo()
      end
    end
  end
end 

function CardSkillUpView:updateSkillInfo()
  local skill = self.skillCard:getSkill()
  if skill == nil then 
    return
  end

  self.label_skillName:setString(skill:getName())
  local curLevel = skill:getLevel()
  local maxLevel = skill:getMaxLevel()
  local nextLevel = math.min(curLevel+1, maxLevel)
  self.label_curLevel:setString("Lv. "..curLevel)
  self.label_nextLevel:setString("Lv. "..nextLevel)

  if self.tmpPreNextLevel == nil then --第一次创建并初始化
    self.tmpPreCurLevel = curLevel
    self.tmpPreNextLevel = nextLevel
    --update desc
    -- local strDesc1 = GameData:Instance():formatSkillDesc(self.skillCard, false, false)
    -- local strDesc2 = GameData:Instance():formatSkillDesc(self.skillCard, true, false)
    local strDesc1 = GameData:Instance():formatSkillDescExt(self.skillCard:getConfigId(), curLevel, self.skillCard:getAttack(), self.skillCard:getHp())
    local strDesc2 = GameData:Instance():formatSkillDescExt(self.skillCard:getConfigId(), nextLevel, self.skillCard:getAttack(), self.skillCard:getHp())
    self:initDesc(self.node_curDesc, strDesc1)
    self:initDesc(self.node_nextDesc, strDesc2)
  end 

  --calc exp and cost
  self.coinCost = 0
  self.gainedExp = 0
  for k,v in pairs(self.skillBooksArray) do
    local idx = v:getGrade()
    if v.selectedNum >= 1 then 
      self.gainedExp = self.gainedExp + v:getSkillExp() * v.selectedNum
      self.coinCost = self.coinCost + AllConfig.item[v:getConfigId()].skill_cost * v.selectedNum

      self.btnDecTbl[idx]:setVisible(true)
      self.selectedNumTbl[idx]:setVisible(true)
    else 
      self.btnDecTbl[idx]:setVisible(false)
      self.selectedNumTbl[idx]:setVisible(false)
    end
  end

  self.needExp = skill:getMaxLevelTotalExp() - skill:getExperience() - self.gainedExp 
  if self.needExp < 0 then 
    self.needExp = 0
  end


  self.label_gain:setString(string.format("%d", self.gainedExp))
  self.label_stillNeed:setString(string.format("%d", self.needExp))
  self.label_cost:setString(string.format("%d", self.coinCost))

  local exp = 0 
  if self.gainedExp > 0 then     
    exp = skill:getExperience() + self.gainedExp
    nextLevel = skill:getLevelByExp(exp)
    self.label_nextLevel:setString("Lv. "..nextLevel)
    echo("====update level:", self.tmpPreNextLevel, nextLevel)

    self.label_level:setString(string.format("%d/%d", nextLevel, maxLevel))
  else 
    self.label_level:setString(string.format("%d/%d", curLevel, maxLevel))
  end 

  if self.tmpPreCurLevel ~= curLevel then 
    self.tmpPreCurLevel = curLevel
    local strDesc1 = GameData:Instance():formatSkillDescExt(self.skillCard:getConfigId(), curLevel, self.skillCard:getAttack(), self.skillCard:getHp())
    self:initDesc(self.node_curDesc, strDesc1)
  end 

  if self.tmpPreNextLevel ~= nextLevel then 
    self.tmpPreNextLevel = nextLevel     
    -- local strDesc1 = GameData:Instance():formatSkillDescExt(self.skillCard:getConfigId(), curLevel, self.skillCard:getAttack(), self.skillCard:getHp())
    local strDesc2 = GameData:Instance():formatSkillDescExt(self.skillCard:getConfigId(), nextLevel, self.skillCard:getAttack(), self.skillCard:getHp())
    -- self:initDesc(self.node_curDesc, strDesc1)
    self:initDesc(self.node_nextDesc, strDesc2)
  end 
  
  --set progress percent
  if self.myprogresser == nil then
    local bg = CCSprite:createWithSpriteFrameName("pg_bg.png")
    local fg1 = CCSprite:createWithSpriteFrameName("pg_yellow.png")
    local fg2 = CCSprite:createWithSpriteFrameName("pg_green.png")
    self.myprogresser = ProgressBarView.new(bg, fg1, fg2)
    self.myprogresser:setPercent(0, 1)
    self.myprogresser:setPercent(0, 2)
    self.myprogresser:setBreathAnim(1)
    self.node_progress:addChild(self.myprogresser)
  end 

  local percent = 100 
  if self.gainedExp > 0 then    
    if nextLevel == curLevel then 
      percent = skill:getExpPercentByLeve(nextLevel, exp) 
    end 

    --显示黄色预览进度条
    self.myprogresser:setFgVisible(true, 1) 
    self.myprogresser:setPercent(percent, 1)
  else 
    percent = skill:getExpPercentByLeve(curLevel, skill:getExperience()) 
    self.myprogresser:setFgVisible(false, 1) --隐藏黄色预览进度条
    self.myprogresser:setPercent(percent, 2) 
  end
end 


function CardSkillUpView:initDesc(target, skillInfoStr)
  target:removeAllChildrenWithCleanup(true)

  local dimensition = target:getContentSize()
  local label = RichLabel:create(skillInfoStr, "Courier-Bold", 20, CCSizeMake(dimensition.width, 0),false,false)
  local textSize = label:getTextSize()
  if textSize.height <= dimensition.height then 
    label:setPosition(ccp(0, textSize.height+(dimensition.height-textSize.height)/2))
    target:addChild(label)
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
    scrollView:setTouchPriority(self.priority)
    target:addChild(scrollView)
  end 
end 


function CardSkillUpView:closeCallback()
  self:removeFromParentAndCleanup(true)
  _executeNewBird()
end 

function CardSkillUpView:startSkillUp()
  echo("startSkillUp")
  _playSnd(SFX_CLICK)
  _executeNewBird()
  local coin = GameData:Instance():getCurrentPlayer():getCoin()
  if self.coinCost > coin then
    Toast:showString(self, _tr("not enough coin"), ccp(display.cx, display.cy))
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

     --backup battle ability for toast
    local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
    self.preBattleAbility = GameData:Instance():getBattleAbilityForCards(battleCards)   
    
    self:addMaskLayer()
  else 
    echo(" has no books for skill up ")
    Toast:showString(self, _tr("no_skill_books"), ccp(display.cx, display.cy))
  end
end 

function CardSkillUpView:cardSkillUpResult(action,msgId,msg)
  echo("---cardSkillUpResult---:", msg.state)

  _hideLoading()
  
  self:removeMaskLayer()

  if msg.state == "Ok" then
    
    self.enhanceChangeFlag = true 
    
    self.isProgressFinish = false

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
      self:resetBooksInfo()
      self:updateSkillInfo() 
      GameData:Instance():getCurrentPlayer():toastBattleAbility(self.preBattleAbility)

      self:removeMaskLayer()       
    end

    local function fullPercentComplete()
      levelCount = levelCount + 1
      echo("fullPercentComplete:level =", levelCount)
      self.label_curLevel:setString("Lv. "..levelCount)
    end

    if self.myprogresser ~= nil then
      self:addMaskLayer(10)

      self.myprogresser:setFgVisible(false, 1) --隐藏绿色进度条
      self.myprogresser:startProgressing(progressFinish, startPercent, endPercent, 2)
      self.myprogresser:setFullPercentCallback(fullPercentComplete)
    else
      progressFinish()
    end

    if self:getDelegate() then 
      if self.enhanceChangeFlag then 
        self:getDelegate():updateView()
      end 
    end   
  else
    Enhance:instance():handleErrorCode(msg.state)    
  end
end

function CardSkillUpView:reduceCallback1()
  self:unSelectOneBook(1)
end 

function CardSkillUpView:reduceCallback2()
  self:unSelectOneBook(2)
end 

function CardSkillUpView:reduceCallback3()
  self:unSelectOneBook(3)
end 

function CardSkillUpView:reduceCallback4()
  self:unSelectOneBook(4)
end

function CardSkillUpView:reduceCallback5()
  self:unSelectOneBook(5)
end

function CardSkillUpView:addMaskLayer(duration)
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self.maskLayerTimer = self:performWithDelay(handler(self, CardSkillUpView.removeMaskLayer), duration or 6.0)
end 

function CardSkillUpView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayerTimer then    
    self:stopAction(self.maskLayerTimer)
    self.maskLayerTimer = nil 
  end 

  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
  
  _hideLoading()
--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end  
end 
