
require("view.component.ViewWithEave")
require("view.component.CardHeadView")
require("view.component.CardHeadLargeView")
require("view.component.Loading")
require("view.component.PopupView")
require("view.component.TipsInfo")
require("view.component.ProgressBarView")
require("view.help.HelpView")
require("view.enhance.PropsBuyOrUseView")

LevelUpView = class("LevelUpView", ViewWithEave)

function LevelUpView:ctor()
  LevelUpView.super.ctor(self)
  --self:setTabControlEnabled(false)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("selectHeroCallback",LevelUpView.selectHeroCallback)
  pkg:addFunc("startLevelUpCallback",LevelUpView.startLevelUpCallback)
  pkg:addFunc("selectCallback",LevelUpView.selectCallback)
  pkg:addFunc("quickSelectCallback",LevelUpView.quickSelectCallback)
  pkg:addFunc("useCallback",LevelUpView.useCallback)
  pkg:addFunc("buyCallback",LevelUpView.buyCallback)

  pkg:addProperty("label_num","CCLabelTTF")
  pkg:addProperty("menu_selectHero","CCMenuItemSprite")
  pkg:addProperty("menu_startLevelup","CCControlButton")
  pkg:addProperty("sprite_selectHero","CCSprite")

  pkg:addProperty("node_largeheader","CCNode")
  pkg:addProperty("node_listContainer","CCNode")

  --node readme
  pkg:addProperty("node_readme","CCNode")
  pkg:addProperty("label_readme","CCLabelTTF")
  pkg:addProperty("label_gain","CCLabelTTF")
  pkg:addProperty("label_cost","CCLabelTTF")
  pkg:addProperty("label_stillNeed","CCLabelTTF")

  --card info1
  pkg:addProperty("node_heroInfo","CCNode")
  pkg:addProperty("node_progresser","CCNode")
  pkg:addProperty("node_nextLevel","CCNode")

  pkg:addProperty("label_cardName","CCLabelBMFont")
  pkg:addProperty("label_cardLevel","CCLabelTTF")
  pkg:addProperty("label_cardLevel2","CCLabelTTF")
  pkg:addProperty("lable_needMoreExp","CCLabelTTF")
  pkg:addProperty("lable_experience","CCLabelTTF")
  pkg:addProperty("lable_money","CCLabelTTF")
  pkg:addProperty("sprite_stillNeedExp","CCSprite")

  --card info2
  pkg:addProperty("node_heroInfo2","CCNode")
  pkg:addProperty("node_progresser2","CCNode")
  pkg:addProperty("label_cardName2","CCLabelBMFont")
  pkg:addProperty("label_curLevel2","CCLabelTTF")
  pkg:addProperty("label_nextLevel2","CCLabelTTF")
  pkg:addProperty("lable_curLife","CCLabelTTF")
  pkg:addProperty("lable_nextLife","CCLabelTTF")
  pkg:addProperty("lable_curGong","CCLabelTTF")
  pkg:addProperty("lable_nextGong","CCLabelTTF")
  pkg:addProperty("lable_curWu","CCLabelTTF")
  pkg:addProperty("lable_nextWu","CCLabelTTF")
  pkg:addProperty("lable_curZhi","CCLabelTTF")
  pkg:addProperty("lable_nextZhi","CCLabelTTF")
  pkg:addProperty("lable_curTong","CCLabelTTF")
  pkg:addProperty("lable_nextTong","CCLabelTTF")

  pkg:addProperty("node_usebuyMenu","CCNode")
  pkg:addProperty("bn_use","CCControlButton")

  local layer,owner = ccbHelper.load("LevelUpView.ccbi","LevelUpViewCCB","CCLayer",pkg)
  self:getEaveView():getNodeContainer():addChild(layer)
end


function LevelUpView:init()
  echo("---LevelUpView:init---")
  net.registMsgCallback(PbMsgId.EatCardResult, self, LevelUpView.EatCardResult)

  local expCardArray = Enhance:instance():getAllExpCards(false)
  if #expCardArray <= 0 then 
    self.bn_use:setEnabled(false)
  end 

  if self:getDelegate():getTabMenuVisible() == false then 
    self:setTitleTextureName("lv_title_shengji.png")
    self:setTabControlEnabled(false)
  else 
    self.node_usebuyMenu:setVisible(false)
    self:setTitleTextureName("cardlvup-image-paibian.png")
    local menuArray = {
        {"#bn_levelup_0.png","#bn_levelup_1.png"},
        {"#bn_surmount_0.png","#bn_surmount_1.png"},
        {"#bn_dismantle_0.png","#bn_dismantle_1.png"},
        {"#bn_skillUp0.png","#bn_skillUp1.png"}
      }
    self:setMenuArray(menuArray)
    self:getTabMenu():setItemSelectedByIndex(1)    
  end 
  self._pageDropped = false

  --user config
  self.totalCells = 4
  self.cellWidth = 0
  self.cellHeight = 0

  self:setIsLevelUping(false)

  self.totalGainExp = 0
  self.totalCost = 0
  self.needNum = 0

  self.label_readme:setString(_tr("levelupinfo"))
  self.label_gain:setString(_tr("gain"))
  self.label_cost:setString(_tr("cost"))
  self.label_stillNeed:setString(_tr("still_need"))

  local bg = CCSprite:createWithSpriteFrameName("pg_bg.png")
  local fg1 = CCSprite:createWithSpriteFrameName("pg_green.png")
  local fg2 = CCSprite:createWithSpriteFrameName("pg_yellow.png")
  self.progresser1 = ProgressBarView.new(bg, fg1, fg2)
  self.progresser1:setPercent(0, 1)
  self.progresser1:setPercent(0, 2)
  self.progresser1:setBreathAnim(1)
  self.node_progresser:addChild(self.progresser1)


  local bg2 = CCSprite:createWithSpriteFrameName("pg_bg.png")
  local fg2 = CCSprite:createWithSpriteFrameName("pg_yellow.png") 
  self.progresser2 = ProgressBarView.new(bg2, fg2)
  self.progresser2:setPercent(1)
  self.node_progresser2:addChild(self.progresser2)

  local nodeSize = self.node_largeheader:getContentSize()
  self.eatCardArray = self:getDelegate():dataInstance():getLevelUpCards()
  local card = self:getDelegate():dataInstance():getLevelUpCard()

  --check card exist
  if card ~= nil then 
    local found = false 
    local allCards = GameData:Instance():getCurrentPackage():getAllCards()
    for k, v in pairs(allCards) do 
      if v:getConfigId() == card:getConfigId() then 
        found = true 
        break 
      end 
    end 

    if found == false then 
      echo("=== card not exist...")
      card = nil 
      self:getDelegate():dataInstance():setLevelUpCard(nil)
    end 
  end 
  
  if card ~= nil then
    local largeCard = CardHeadLargeView.new(card)
    local scale = nodeSize.height/largeCard:getHeight()
    largeCard:setScale(scale)
    largeCard:setPosition(ccp(nodeSize.width/2, nodeSize.height/2))
    self.node_largeheader:addChild(largeCard)

    self:showCardInfo(1, card)
  else 
    local heroBg = _res(3021010) --默认英雄背景
    if heroBg ~= nil then 
      
      local scale = nodeSize.height/heroBg:getContentSize().height
      heroBg:setScale(scale)
      heroBg:setPosition(ccp(nodeSize.width/2, nodeSize.height/2))
      self.node_largeheader:addChild(heroBg, -2)

      local bg2 = _res(3021020) --底部渐变
      if bg2 ~= nil then 
        local scale2 = (nodeSize.width-18)/bg2:getContentSize().width 
        bg2:setScale(scale2)
        bg2:setAnchorPoint(ccp(0, 0))
        bg2:setPosition(ccp(9,13))
        self.node_largeheader:addChild(bg2, -1)
      end
    end
    local action = CCSequence:createWithTwoActions(CCFadeTo:create(0.8, 100),CCFadeTo:create(1.0, 255))
    self.sprite_selectHero:runAction(CCRepeatForever:create(action))

    self.eatCardArray = {}
    self:showCardInfo(0, nil)
    self:getDelegate():dataInstance():resetSelectedCards()
  end

  self:showCardsList()
end

function LevelUpView:onEnter()
  echo("---LevelUpView:onEnter---")
  self:init()
end 

function LevelUpView:onExit()
  echo("---LevelUpView:onExit---")
  net.unregistAllCallback(self)

  if self.progresser1 ~= nil then 
    self.progresser1:stopProgressBar()
  end

  if self.progresser2 ~= nil then 
    self.progresser2:stopProgressBar()
  end  
end 

function LevelUpView:showCardsList()

  
  local cardslen = self.needNum --table.getn(self.eatCardArray)

  -- local function scrollViewDidScroll(view)
  --   --[[
  --   local x = view:getContentOffset().x
  --   local y = self.scrollShadow:getPositionY()
  --   self.scrollShadow:setPosition(ccp(x, y))
  --   --]]
  -- end
  
  local function tableCellTouched(tableview,cell)
    local idx = cell:getIdx()
    echo("tableCellTouched: idx=", idx)
    -- if self.eatCardArray ~= nil and (idx+1 <= table.getn(self.eatCardArray)) then 
    --   local card = self.eatCardArray[idx+1]
    --   if card ~= nil then 
    --     TipsInfo:showTip(nil, card:getConfigId(), card)  
    --   end
    -- end
    self:selectCallback()
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end

  local function tableCellAtIndex(tableview, idx)
    echo("cell index= ", idx)

    local cell = tableview:dequeueCell()
    if cell == nil then 
      cell = CCTableViewCell:new()
    else 
      cell:removeChildByTag(200,true)
    end

    local node = CCNode:create()
    --background img
    local centerPos = ccp(self.cellWidth/2, self.cellHeight/2)
    local bg = CCSprite:createWithSpriteFrameName("kongbaikuang.png")
    bg:setPosition(centerPos)
    node:addChild(bg)

    --card headers
    if self.eatCardArray ~= nil then       
      if cardslen >= idx + 1 then 
        local cardView = CardHeadView.new()
        cardView:setCard(self.eatCardArray[idx+1])
        cardView:setPosition(centerPos)
        cardView:setLvVisible(false)
        -- local factor = bg:getContentSize().width/cardView:getWidth()
        -- cardView:setScale(factor)
        node:addChild(cardView)
      else 
        local img_jia = CCSprite:createWithSpriteFrameName("jia.png")
        img_jia:setPosition(centerPos)
        local action = CCSequence:createWithTwoActions(CCFadeTo:create(1.0, 100),CCFadeTo:create(1.0, 255))
        img_jia:runAction(CCRepeatForever:create(action))
        node:addChild(img_jia)        
      end
    end
    node:setTag(200)
    cell:addChild(node)

    return cell
  end
  
  self.node_listContainer:removeAllChildrenWithCleanup(true)

  self.cellWidth = self.node_listContainer:getContentSize().width/4
  self.cellHeight = self.node_listContainer:getContentSize().height
  
  if cardslen < 4 then 
    self.totalCells = 4 
  else 
    self.totalCells = cardslen + 1
  end
  --echo("self.totalCells = ", self.totalCells, cardslen)

  local tableView = CCTableView:create(self.node_listContainer:getContentSize())
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  self.node_listContainer:addChild(tableView)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
end


function LevelUpView:onHelpHandler()
  echo("helpCallback")
  local help = HelpView.new()
  help:addHelpBox(1004)
  help:addHelpItem(1005, self.node_largeheader, ccp(100,80), ArrowDir.LeftLeftUp)
  help:addHelpItem(1006, self.node_listContainer, ccp(220,0), ArrowDir.RightUp)
  help:addHelpItem(1007, self.menu_startLevelup, ccp(10,20), ArrowDir.RightDown)
  self:getDelegate():getScene():addChild(help, 1000)
end 

function LevelUpView:onBackHandler()
  echo("LevelUpView:backCallback")
  LevelUpView.super:onBackHandler()
  self:getDelegate():goBackView()
end

function LevelUpView:tabControlOnClick(idx)
  _playSnd(SFX_CLICK)   

  local result = true
  if idx == 0 then
  elseif idx == 1 then 
    result = self:getDelegate():displaySurmountView()
  elseif idx == 2 then
    self:getDelegate():displayDismantleView()
  elseif idx == 3 then
    result = self:getDelegate():displaySkillView()
  end

  return result
end

function LevelUpView:selectHeroCallback()
  echo("selectHeroCallback")
  if self:getIsLevelUping() == true then 
    return
  end

  if self:getDelegate():getTabMenuVisible() == false then 
    if self:getDelegate():dataInstance():getLevelUpCard() ~= nil then 
      echo("disable selecte other card for playstate")
      return 
    end
  end 

  self:getDelegate():disPlayCardListForLevelUp(SelectType.SELECTE_ONE)
end

function LevelUpView:selectCallback()
  echo("selectCallback")
  _playSnd(SFX_CLICK) 
  
  if self:getIsLevelUping() == true then 
    return
  end

  local skillCard = self:getDelegate():dataInstance():getLevelUpCard()
  if skillCard == nil then 
    Toast:showString(self, _tr("please select card"), ccp(display.width/2, display.height*0.4))
    return
  end

  if skillCard:getLevel() == skillCard:getMaxLevel() then 
    Toast:showString(self, _tr("has been max level"), ccp(display.width/2, display.height*0.4))
    return 
  end

  self:getDelegate():disPlayCardListForLevelUp(SelectType.SELECTE_ALL)
end

function LevelUpView:addMaskLayer()
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)
end 

function LevelUpView:removeMaskLayer()
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 

function LevelUpView:playLevelupAnimation()

  self:addMaskLayer()

  local function playAnimOk()
    local anim,offsetX,offsetY,duration = _res(5020096)
    if anim ~= nil then
      local nodeSize = self.node_largeheader:getContentSize()
      local pos = ccp(nodeSize.width/2, nodeSize.height/2)
      anim:setPosition(pos)
      self.node_largeheader:addChild(anim)
      anim:getAnimation():play("default")
      self:performWithDelay(function ()
                              anim:removeFromParentAndCleanup(true)
                              echo("---remove finish anim")
                              self:removeMaskLayer()
                              self:showCardInfo(2, self:getDelegate():dataInstance():getLevelUpCard())
                              if Guide:Instance():getGuideLayer() ~= nil then      
                                Guide:Instance():getGuideLayer():setVisible(true)
                              end
                              
                              GameData:Instance():getCurrentPlayer():toastBattleAbility(self.preBattleAbility)
                            end,
                            duration)
    end
  end

  local function repeatCheck()
    if self.AnimPartile ~= nil then 
      echo("repeate")

      if self.isProgressFinish == true or self:getIsLevelUping() == false then 
        echo("---remove setp2 anim")
        self.AnimPartile:removeFromParentAndCleanup(true)
        self.AnimPartile = nil

        if self.animRotateImg ~= nil then 
          self.animRotateImg:removeFromParentAndCleanup(true)
          self.animRotateImg = nil
        end
      
        --setp 3. play finish anim
        playAnimOk()
      else 
        self:performWithDelay(repeatCheck, 0.5)
      end
    end
  end

  --setp 1. play eat anim
  self.eatenCardsNum = math.min(4, self.needNum)

  if self.eatenCardsNum > 0 then 
    local duration_time = 0
    for i=1, self.eatenCardsNum do 
      local anim,offsetX,offsetY,duration = _res(5020097)
      duration_time = duration
      if anim ~= nil then
        self:addChild(anim)
        local pos_x = self.node_listContainer:getPositionX() + (i-1)*self.cellWidth + self.cellWidth/2
        local pos_y = self.node_listContainer:getPositionY() + self.cellHeight/2
        local pos = self.node_listContainer:getParent():convertToWorldSpace(ccp(pos_x,pos_y))
        anim:setPosition(pos)
        anim:getAnimation():play("default")
        self:performWithDelay(function ()
                                anim:removeFromParentAndCleanup(true)
                              end,
                              duration) 
      end
    end

    if duration_time > 0 then 
      self:performWithDelay(function ()
                              --setp 2. play repeat anim
                              local nodeSize = self.node_largeheader:getContentSize()
                              local pos = ccp(nodeSize.width/2, nodeSize.height/2)
                              self.animRotateImg = _res(3100001)
                              if self.animRotateImg ~= nil then 
                                self.animRotateImg:setPosition(pos)
                                self.node_largeheader:addChild(self.animRotateImg)
                                self.animRotateImg:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 360)))
                              end

                              self.AnimPartile = _res(6010001)
                              if self.AnimPartile ~= nil then
                                self.AnimPartile:setPosition(pos)
                                self.node_largeheader:addChild(self.AnimPartile)
                              end

                              --start repeat check
                              self:performWithDelay(repeatCheck, 0.5)
                            end,

                            duration_time*0.8) 
    end 
    
    self.eatCardArray = {}
    self.needNum = 0
    self.label_num:setString("0")
    self:showCardsList()
  end 
end




function LevelUpView:EatCardResult(action,msgId,msg)
  echo("EatCardResult: ",msg.state)
--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end
  _hideLoading() 

  local skillCard = self:getDelegate():dataInstance():getLevelUpCard()
  local levelCount = skillCard:getLevel()

  local function fullPercentComplete()
    
    levelCount = levelCount + 1
    self.label_cardLevel:setString(string.format("%d", levelCount))
  end

  local function progressFinish()
    echo("progress finish.")
    self:getDelegate():dataInstance():setLevelUpCards(nil)
    self.isProgressFinish = true
    
    self:setIsLevelUping(false)
  end

  if msg.state ~= "Ok" then 
    self:setIsLevelUping(false)
  end

  if msg.state == "Ok" then 

    self.preLevel = skillCard:getLevel()
    local preExp = skillCard:getExperience()

    self.preStr = skillCard:getStrengthByLevel(self.preLevel)
    self.preInt = skillCard:getIntelligenceByLevel(self.preLevel)
    self.preDom = skillCard:getDominanceByLevel(self.preLevel)
    self.preHp = skillCard:getHpByLevel(self.preLevel)
    self.preAtk = skillCard:getAttackByLevel(self.preLevel)
    local precoin = GameData:Instance():getCurrentPlayer():getCoin()
    local startPercent = skillCard:getExpPercentByLeve(skillCard:getLevel(), skillCard:getExperience())
    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
    local endPercent = skillCard:getExpPercentByLeve(skillCard:getLevel(), skillCard:getExperience())
    local curcoin = GameData:Instance():getCurrentPlayer():getCoin()
    endPercent = endPercent + 100*(skillCard:getLevel()-self.preLevel)
    echo("############# preExp, curExp", preExp, skillCard:getExperience())
    echo("------preLevel, curLevel,cost=",self.preLevel, skillCard:getLevel(),precoin-curcoin)
    echo("======startPercent,endPercent =:",startPercent,endPercent)

    if self.progresser1 ~= nil and endPercent > startPercent then
      --play animation
      self.isProgressFinish = false       
      self:playLevelupAnimation()

      self.progresser1:setFgVisible(false, 1) --隐藏绿色进度条
      self.progresser1:startProgressing(progressFinish, startPercent, endPercent, 2)
      self.progresser1:setFullPercentCallback(fullPercentComplete)
    end
  elseif msg.state == "NotEnoughCurrency" then
    Toast:showString(self, _tr("not enough coin"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "CouldNotEatAnyMore" then
    Toast:showString(self, _tr("can not eat card"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "NoCardToEat" then
    Toast:showString(self, _tr("has no eatable cards"), ccp(display.width/2, display.height*0.4))
  elseif msg.state == "WorkInMine" then
    Toast:showString(self, _tr("working card can not eaten"), ccp(display.width/2, display.height*0.4))    
  else 
    Toast:showString(self, msg.state, ccp(display.width/2, display.height*0.4))
  end
end 

function LevelUpView:updateEatenInfo()
  self.totalGainExp = 0
  self.totalCost = 0
  self.needNum = 0
  local needMaxExp = 0 

  local eatCardsCount = table.getn(self.eatCardArray)

  local skillCard = self:getDelegate():dataInstance():getLevelUpCard()
  if skillCard ~= nil then
    local _,maxLeveTotalExp = skillCard:getExpByLeve(skillCard:getMaxLevel())
    needMaxExp = maxLeveTotalExp - skillCard:getExperience()
    echo(" needMaxExp =", needMaxExp)

    for k, v in pairs(self.eatCardArray) do
      echo("will be eatean cards:",v:getConfigId(), v:getId())
      self.totalGainExp = self.totalGainExp + v:getGainedExpAfterEaten()
      self.totalCost = self.totalCost + v:getCost()
      self.needNum = self.needNum + 1

      if self.totalGainExp > needMaxExp then
        echo("---pay cards back to user count: ", eatCardsCount - self.needNum)
        --self:getDelegate():dataInstance():resetSelectedCards()
        break
      end
    end
  end
  echo(" updateEatenInfo:needNum,totalCost,totalGainExp =", self.needNum, self.totalCost, self.totalGainExp)

  --update info,eg:gained experience and cost coin
  local nextPercent = 0
  local nextExp = 0
  if (skillCard ~= nil) and (eatCardsCount > 0) then
    self.node_nextLevel:setVisible(true)
    nextExp = self.totalGainExp + skillCard:getExperience() 
    local targetLevel = skillCard:getLevelByExp(nextExp)
    self.label_cardLevel2:setString(string.format("%d", targetLevel))
    if targetLevel > skillCard:getLevel() then --只要大于1级,则绿色进度条显示100%
      nextPercent = 100
    else 
      nextPercent = skillCard:getExpPercentByLeve(targetLevel, nextExp)
    end
  else 
    self.node_nextLevel:setVisible(false)
  end

  self.lable_experience:setString(string.format("%d", self.totalGainExp))
  self.lable_money:setString(string.format("%d", self.totalCost))

  local needMoreExp = needMaxExp - self.totalGainExp 
  if needMoreExp < 0  then 
    needMoreExp = 0
  end 
  self.lable_needMoreExp:setString(string.format("%d", needMoreExp))
  local w1 = self.label_stillNeed:getContentSize().width 
  local w2 = self.sprite_stillNeedExp:getContentSize().width 
  self.sprite_stillNeedExp:setPositionX(self.label_stillNeed:getPositionX() + w1 + w2/2 + 10)
  self.lable_needMoreExp:setPositionX(self.sprite_stillNeedExp:getPositionX()+w2/2+10)

  self.label_num:setString(string.format("%d", self.needNum))


  --set progress percentage
  if self.progresser1 ~= nil and skillCard ~= nil then 
    local curPercent = skillCard:getExpPercentByLeve(skillCard:getLevel(), skillCard:getExperience())
    echo("updateEatenInfo: card_id,level =",skillCard:getConfigId(),skillCard:getLevel())
    echo("updateEatenInfo:curExp,nextExp, curPercent,nextPercent=", skillCard:getExperience(),nextExp,curPercent,nextPercent)
    self.progresser1:setPercent(curPercent, 2)
    if nextPercent > 0 then 
      self.progresser1:setFgVisible(true, 1)
      self.progresser1:setPercent(nextPercent, 1)
    end
  end
end 


function LevelUpView:startLevelUpCallback()
  echo("startLevelUpCallback")
  _playSnd(SFX_CLICK) 

  if self:getIsLevelUping() == true then 
    return
  end

  local skillCard = self:getDelegate():dataInstance():getLevelUpCard()
  if skillCard == nil then 
    Toast:showString(self, _tr("please select card"), ccp(display.width/2, display.height*0.4))
    return
  end

  if skillCard:getLevel() == skillCard:getMaxLevel() then 
    Toast:showString(self, _tr("has been max level"), ccp(display.width/2, display.height*0.4))
    return
  end

  if self.eatCardArray == nil or self.needNum < 1 then 
    Toast:showString(self, _tr("please select eatable cards"), ccp(display.width/2, display.height*0.4))
    return
  end

  local coin = GameData:Instance():getCurrentPlayer():getCoin()
  if coin < self.totalCost then
    Toast:showString(self, _tr("not enough coin"), ccp(display.width/2, display.height*0.4))
    return 
  end

  local needToPop = false 
  local eatCardIdTbl = {}
  for i = 1, self.needNum do 
    table.insert(eatCardIdTbl, self.eatCardArray[i]:getId())
    echo("will be eatean cards:",self.eatCardArray[i]:getConfigId(), self.eatCardArray[i]:getId())
    if self.eatCardArray[i]:getMaxGrade() >= 3 then 
      needToPop = true
    end 
  end
  
  local allIsExpCards = true 
  for i = 1, self.needNum do 
    if self.eatCardArray[i]:getIsExpCard() == false then 
      allIsExpCards = false 
      break 
    end 
  end 

  local function sendEatCardsMsg()
    
    local isBattleCard = "Backup"
    if skillCard:getIsOnBattle() == true then 
      isBattleCard = "Active"
    end

    _showLoading()
    local data = PbRegist.pack(PbMsgId.EatCard, {card_group=isBattleCard, beneficiary=skillCard:getId(), victim = eatCardIdTbl})
    net.sendMessage(PbMsgId.EatCard, data)

    --show waiting
    --self.loading = Loading:show()
    self:setIsLevelUping(true)

    --backup battle ability for toast
    local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
    self.preBattleAbility = GameData:Instance():getBattleAbilityForCards(battleCards)
  end

  local function popOkCallback()
    sendEatCardsMsg()
  end

  if needToPop == true and allIsExpCards == false then 
      local pop = PopupView:createTextPopup(_tr("be sure eat cards"), popOkCallback)
      self:addChild(pop)    
  else 
    sendEatCardsMsg()
  end 
end

function LevelUpView:showCardInfo(index, card)

  local skillCard = self:getDelegate():dataInstance():getLevelUpCard()

  if index == 0 then 
    self.node_readme:setVisible(true)
    self.node_heroInfo:setVisible(false)
    self.node_heroInfo2:setVisible(false)
    self.label_num:setString("0")
  elseif index == 1 then
    self.node_readme:setVisible(false)
    self.node_heroInfo:setVisible(true)
    self.node_heroInfo2:setVisible(false)
    local cardName = AllConfig.unit[card:getConfigId()].unit_cardname
    self.label_cardName:setString(cardName)
    self.label_cardName:setScale(30/self.label_cardName:getContentSize().height)
    self.label_cardLevel:setString(string.format("%d", skillCard:getLevel()))

    --show eaten info
    self:updateEatenInfo()
    
  elseif index == 2 then 
    self.node_readme:setVisible(false)
    self.node_heroInfo:setVisible(false)
    self.node_heroInfo2:setVisible(true)

    --set progress percentage
    local progresser2 = self.progresser2
    if progresser2 ~= nil and skillCard ~= nil then 
      local percent = skillCard:getExpPercentByLeve(skillCard:getLevel(), skillCard:getExperience())
      echo("showCardInfo2: card_id,level,curExp,percent =".." "..skillCard:getConfigId()..", "..skillCard:getLevel()..", "..skillCard:getExperience()..", "..percent)  
      progresser2:setPercent(percent)
    end 

    local curLevel = card:getLevel()
    local cardName = AllConfig.unit[card:getConfigId()].unit_cardname
    self.label_cardName2:setString(cardName)
    self.label_cardName2:setScale(30/self.label_cardName2:getContentSize().height)
    self.label_curLevel2:setString(string.format("%d",self.preLevel))
    self.label_nextLevel2:setString(string.format("%d",curLevel))

 
    local nextHp = card:getHpByLevel(curLevel)
    self.lable_curLife:setString(string.format("%d", self.preHp))
    self.lable_nextLife:setString(string.format("%d", nextHp))

    local nextGong = card:getAttackByLevel(curLevel)
    self.lable_curGong:setString(string.format("%d", self.preAtk))
    self.lable_nextGong:setString(string.format("%d", nextGong))

    local nextWu = card:getStrengthByLevel(curLevel)
    self.lable_curWu:setString(string.format("%d", self.preStr))
    self.lable_nextWu:setString(string.format("%d", nextWu))

    local nextZhi = card:getIntelligenceByLevel(curLevel)
    self.lable_curZhi:setString(string.format("%d", self.preInt))
    self.lable_nextZhi:setString(string.format("%d", nextZhi))

    local nextTong = card:getDominanceByLevel(curLevel)
    self.lable_curTong:setString(string.format("%d", self.preDom))
    self.lable_nextTong:setString(string.format("%d", nextTong))
  end 

  
end


function LevelUpView:setIsLevelUping(isleveling)

  self.isLevelUping = isleveling
  echo("setIsLevelUping:", isleveling)

  local scheduler = CCDirector:sharedDirector():getScheduler()
  if self.scheduler ~= nil then 
    scheduler:unscheduleScriptEntry(self.scheduler)
    self.scheduler = nil
  end

  local function timerCallback(dt)
    echo("timer expire....")
    if self.scheduler ~= nil then 
      scheduler:unscheduleScriptEntry(self.scheduler)
      self.scheduler = nil
    end
  end

  --strat timer
  if isleveling == true then 
    self.scheduler = scheduler:scheduleScriptFunc(timerCallback, 60, false)
  end
end

function LevelUpView:getIsLevelUping()
  echo("...is levelUping...")
  return self.isLevelUping
end

function LevelUpView:quickSelectCallback()
  echo("=== quickSelectCallback")
  self:autoFillExpCards()
end 

function LevelUpView:useCallback()
  local view = PropsBuyOrUseView.new(false)
  view:setDelegate(self:getDelegate())
  -- self:addChild(view)
  GameData:Instance():getCurrentScene():addChild(view, 1001)
end 

function LevelUpView:buyCallback()
  local view = PropsBuyOrUseView.new(true)
  view:setDelegate(self:getDelegate())
  self:addChild(view)
end 

function LevelUpView:autoFillExpCards()
  local skillCard = self:getDelegate():dataInstance():getLevelUpCard()
  if skillCard == nil then
    Toast:showString(self, _tr("please select card"), ccp(display.width/2, display.height*0.4))
    return 
  end 

  local _,maxLeveTotalExp = skillCard:getExpByLeve(skillCard:getMaxLevel())
  local needMaxExp = maxLeveTotalExp - skillCard:getExperience()  
  if needMaxExp > 0 then 
    local dataInstance = self:getDelegate():dataInstance()
    local skillCard = dataInstance:getLevelUpCard()
    if skillCard ~= nil then 
      local eatenExpCards = dataInstance:getExpCardsForEaten(needMaxExp)
      if #eatenExpCards > 0 then 
        self.eatCardArray = eatenExpCards
        dataInstance:setLevelUpCards(self.eatCardArray)
        self:showCardInfo(1, skillCard)
        self:showCardsList()
      else 
        Toast:showString(self, _tr("has no eatable exp cards"), ccp(display.width/2, display.height*0.4))
      end 
    end 
  else 
    Toast:showString(self, _tr("has been max level"), ccp(display.width/2, display.height*0.4))
  end 
end 
