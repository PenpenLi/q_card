require("model.battle.BattleResult")
require("model.Props")
require("view.component.DropItemView")
require("view.battle.BattleDamageCountView")

require("view.battle.BattleResultAnimation")
BattleResultView = class("BattleResultView",BaseView)

local function performWithDelay(node, callback, delay)
    local delay = CCDelayTime:create(delay)
    local callfunc = CCCallFunc:create(callback)
    local sequence = CCSequence:createWithTwoActions(delay, callfunc)
    node:runAction(sequence)
    return sequence
end
        
function BattleResultView:ctor(result,msg,fightType,battleView)
  BattleResultView.super.ctor(self)
  self._fightType = fightType
  self._oldPercent = -1
  self._newPercent = -1
  self._newLevel = 1
  self._dropsArray = {}
  self._result = result
  
  self:setBattleView(battleView)
  
  if fightType == "PVP_REAL_TIME" then
     self._msg = msg.result
     self._arena_msg = msg
  else
     self._msg = msg
  end
  
  self._isShowDropDetail = false
  self._dropDetailPageIdx = 1
  self.touchStep = 0
  
    
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("scale9SpriteBg","CCScale9Sprite")
  pkg:addProperty("lableCoin","CCLabelTTF")
  pkg:addProperty("lableLevel","CCLabelTTF")
  pkg:addProperty("lableExp","CCLabelTTF")
  pkg:addProperty("lableOldLevel","CCLabelTTF")
  pkg:addProperty("lableOldCost","CCLabelTTF")
  pkg:addProperty("lableOldHp","CCLabelTTF")
  pkg:addProperty("lableOldFriendMax","CCLabelTTF")
  pkg:addProperty("labelNewLevel","CCLabelTTF")
  pkg:addProperty("labelNewCost","CCLabelTTF")
  pkg:addProperty("lableNewHp","CCLabelTTF")
  pkg:addProperty("preFriendMax","CCLabelTTF")
  pkg:addProperty("lableNewFriendMax","CCLabelTTF")
  pkg:addProperty("labelPreLevel","CCLabelTTF")
  pkg:addProperty("nodeDropContainer","CCNode")
  pkg:addProperty("nodeLevelUp","CCNode")
  pkg:addProperty("nodeAwardContainer","CCNode")
  pkg:addProperty("friendArrow","CCSprite")
  pkg:addProperty("spriteBattleScore","CCSprite")
  pkg:addProperty("spriteExpIcon","CCSprite")
  pkg:addProperty("nodeWin","CCNode")
  pkg:addProperty("nodeLose","CCNode")
  pkg:addProperty("btnCardGradeUp","CCMenuItemSprite")
  pkg:addProperty("btnSkillUp","CCMenuItemSprite")
  pkg:addProperty("btnEquipmentUp","CCMenuItemSprite")
  pkg:addProperty("btnDressEquipment","CCMenuItemSprite")
  pkg:addProperty("btnEquipmentGradeUp","CCMenuItemSprite")
  pkg:addProperty("btnDetail","CCMenuItemSprite")
  
  pkg:addProperty("label_preLevel","CCLabelTTF")
  pkg:addProperty("label_preLeadship","CCLabelTTF")
  pkg:addProperty("label_preSpirit","CCLabelTTF")
  pkg:addProperty("label_preGain","CCLabelTTF")
  pkg:addFunc("detailHandler",BattleResultView.detailHandler)
  
  --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,125), display.width, display.height)
  self:addChild(layerColor)

  local layer,owner = ccbHelper.load("BattleAccountView.ccbi","BattleAccountCCB","CCLayer",pkg)
  self:addChild(layer)
  self.layer = layer 
  
  self.labelPreLevel:setString(_tr("level")..":")
  self.label_preLevel:setString(_tr("level")..":")
  self.label_preLeadship:setString(_tr("leadship")..":")
  self.label_preSpirit:setString(_tr("energy"))
  self.label_preGain:setString(_tr("gain")..":")
  
  local backMenu = CCMenu:create()
  backMenu:setPosition(0,0)
  self:addChild(backMenu)
  
  local closeOffsetX = 0
  
  local createReFightBtn = function()
    closeOffsetX = 120
    local reFightBtn = UIHelper.ccMenuItemImageWithSprite(display.newSprite("#battle_result_restart_nor.png"),
            display.newSprite("#battle_result_restart_sel.png"),
            display.newSprite("#battle_result_restart_sel.png"),
            function()
                if self._fightType == "PVE_NORMAL" then
                  local stage = self:getBattleView():getBattleData():getStage()
                  if Scenario:Instance():isStageCanFightNow(stage) == true then
                    Scenario:Instance():reqPVEFightCheck(stage)
                  end
                elseif self._fightType == "PVE_ACTIVITY" then
                  --[[local stage = ActivityStages:Instance():getCurrentStage()
                  if stage:getIsCanBuyToday() == true then
                    ActivityStages:Instance():reqActivityStageFightCheck()
                  end]]
                  
                  local controller = ControllerFactory:Instance():create(ControllerType.ACTIVITY_STAGE_CONTROLLER)
                  controller:enter() 
                  controller:startLastStage()
                end
            end)
    backMenu:addChild(reFightBtn)
    reFightBtn:setPositionX(display.cx - closeOffsetX)
    reFightBtn:setPositionY(display.cy - 330)
  end
  
  local reFightEnabled = GameData:Instance():checkSystemOpenCondition(40,false)
  if self._fightType == "PVE_NORMAL" 
  and reFightEnabled == true 
  and self._msg.result_lv ~= "WIN_LEVEL_2" then
    createReFightBtn()
  elseif self._fightType == "PVE_ACTIVITY" 
  and self._msg.result_lv ~= "WIN_LEVEL_2" 
  then
    createReFightBtn()
  elseif self._fightType == "PVE_ACTIVITY" 
  and self._msg.result_lv == "WIN_LEVEL_2"
  then
    createReFightBtn()
  end
  
  local closeBtn = UIHelper.ccMenuItemImageWithSprite(display.newSprite("#battle_result_close_nor.png"),
            display.newSprite("#battle_result_close_sel.png"),
            display.newSprite("#battle_result_close_sel.png"),
            function()
                self:goBack()
            end)
  backMenu:addChild(closeBtn)
  closeBtn:setPositionX(display.cx + closeOffsetX)
  closeBtn:setPositionY(display.cy - 330)
  self._goBackBtn = backMenu
  self._goBackBtn:setVisible(false)
  self.btnDetail:setVisible(false)

  
  self._needShowLargeDropIds = {}

  local tapHandler = function (dp,target)
     if target:getTag() == 0 then --dress equipment

     elseif target:getTag() == 1 then --equipment level up
       local playstatesController  = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
       playstatesController:enter(1)
     elseif target:getTag() == 2 then --equipment grade up
       
     elseif target:getTag() == 3 then --card grade up
       local playstatesController  = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
       playstatesController:enter(1)
     elseif target:getTag() == 4 then --skill up
       local playstatesController  = ControllerFactory:Instance():create(ControllerType.PLAY_STATES_CONTROLLER)
       playstatesController:enter(1)
     end
  end
  
  self.btnCardGradeUp:registerScriptTapHandler(tapHandler)
  self.btnSkillUp:registerScriptTapHandler(tapHandler)
  self.btnEquipmentUp:registerScriptTapHandler(tapHandler)
  self.btnDressEquipment:registerScriptTapHandler(tapHandler)
  self.btnEquipmentGradeUp:registerScriptTapHandler(tapHandler)
  
  layer:setVisible(false)
  self.spriteBattleScore:setVisible(false)
  
  echo("OnBattleResultView")
  echo(self._fightType)
  if  self.nodeLevelUp ~= nil then
    self.nodeLevelUp:setVisible(false)
  end
  
  self._oldLevel = GameData:Instance():getCurrentPlayer():getLevel()
  self._oldLeadShip = GameData:Instance():getCurrentPlayer():getLeadShip()
  self._oldExp = GameData:Instance():getCurrentPlayer():getExperience()
  self._oldCoin = GameData:Instance():getCurrentPlayer():getCoin()
  self._oldSpirit  = GameData:Instance():getCurrentPlayer():getSpirit()
  self._oldMoney = GameData:Instance():getCurrentPlayer():getMoney()
  self._oldJiangHun = GameData:Instance():getCurrentPlayer():getCardSoul()
  local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
  self._oldCards = clone(battleCards)

  local oldLevel = self._oldLevel
  local oldLeadShip = self._oldLeadShip
  local oldExp = self._oldExp
  local oldCoin = self._oldCoin
  local oldSpirit  = self._oldSpirit
  local oldMoney = self._oldMoney
  local oldJiangHun = self._oldJiangHun

  local function getPercents(nowLevel,exp)
        local mpercent = 0
        if nowLevel == nil or exp == nil then
           return mpercent
        end
        
        if exp == 0 then
           return mpercent
        end
        
        if AllConfig.charlevel[nowLevel+1] == nil then 
           return mpercent
        end
              
        if nowLevel ~= nil and nowLevel >= 1 then
           local currentExp =  exp - AllConfig.charlevel[nowLevel].totalexp
           local needExp = AllConfig.charlevel[nowLevel+1].exp
           mpercent = (currentExp/needExp)*100
        end
        return mpercent
  end
            
  self._oldPercent = getPercents(oldLevel,oldExp)
  
    
  if self._result.result.win_group == BattleConfig.BattleSide.Blue then
     if self._msg ~= nil then
        if self._msg.client_sync ~= nil and self._msg.result_lv == "WIN_LEVEL_2" then
--           echo(GameData:Instance():getCurrentPlayer():getCoin())
--           echo(self._msg.client_sync.common.level)
--           echo(GameData:Instance():getCurrentPlayer():getExperience())
           
           local newLevel = self._msg.client_sync.common.level
           
           print("newLevel",newLevel)
           local newExp = self._msg.client_sync.common.experience
           
           self._newPercent = getPercents(newLevel,newExp)
           if oldLevel ~= newLevel then
               if self.nodeLevelUp ~= nil then
                  self.nodeLevelUp:setVisible(true)
               end
               self.nodeDropContainer:setVisible(false)
               self.lableOldLevel:setString(oldLevel.."")
               self.lableOldCost:setString(oldLeadShip.."")
               
               local costSpirit = Scenario:Instance():getCurrentStage():getCost()
               self.lableOldHp:setString((oldSpirit - costSpirit).."")
               
               if self._msg.client_sync.changed_information ~= nil then
                  self.lableNewHp:setString(self._msg.client_sync.changed_information.spirit.current.."")          
               else
                  self.lableNewHp:setString(oldSpirit.."")
               end
               
               local oldFriendCount = AllConfig.char_friend_count[oldLevel].friend_max_count
               local newFriendCount = AllConfig.char_friend_count[newLevel].friend_max_count
               
               if oldFriendCount == newFriendCount then
                   self.friendArrow:setVisible(false)
                   self.preFriendMax:setString("")
                   self.lableOldFriendMax:setString("")
                   self.lableNewFriendMax:setString("")
               else
                   self.lableOldFriendMax:setString(oldFriendCount.."")
                   self.lableNewFriendMax:setString(newFriendCount.."")
                   self.friendArrow:setVisible(true)
               end
               
               self.labelNewLevel:setString(newLevel.."")
               self.labelNewCost:setString(AllConfig.charlevel[newLevel].leadship + GameData:Instance():getCurrentPlayer():getFriendLeadShip().."")
               
               self._newPercent = self._newPercent + (newLevel - oldLevel)*100
               
           end
           
           echo(self._msg.client_sync.common.coin)
           echo(self._msg.client_sync.common.level)
           echo(self._msg.client_sync.common.experience)  
           
           local coin = self._msg.client_sync.common.coin - oldCoin
           local exp = self._msg.client_sync.common.experience - oldExp
           local money = self._msg.client_sync.common.money + self._msg.client_sync.common.point - oldMoney
           local jianghun = self._msg.client_sync.common.jianghun - oldJiangHun
           self.lableExp:setColor(sgGREEN)
           self.lableCoin:setColor(sgGREEN)
           self.lableCoin:setString(coin.."")
           self.lableExp:setString(exp.."")
           self._newLevel = self._msg.client_sync.common.level
           self._getMoney = money
           self._jiangHun = jianghun
           self._guildPoint = guildPoint
           --self.lableLevel:setString(self._msg.client_sync.common.level.."")
           --show drops for pve
           self:showDrops(self._msg.client_sync)
          --GameData:Instance():getCurrentPackage():parseClientSyncMsg(self._msg.client_sync)
        end
     end
  end
  
  self:addTouchEventListener(handler(self,self.onTouch))
end

function BattleResultView:onExit()
  if self._msg ~= nil then
    if  self._fightType == "PVE_BABLE"
    or self._fightType == "PVE_GUILD"
    then
      GameData:Instance():getCurrentPackage():parseClientSyncMsg(self._msg.client_sync)
    end
  end
end

function BattleResultView:detailHandler()
   self._battleDamageCount = BattleDamageCountView.new(self._msg.result)
   self:addChild(self._battleDamageCount,500)
end

function BattleResultView:showBattleCards()
  --self.nodeWin
  local oldCards = self._oldCards
  local newCards = GameData:Instance():getCurrentPackage():getBattleCards()
  for key, card in pairs(oldCards) do
  	local cardView = CardHeadView.new()
  	cardView:setLvFadeEnabled(false)
  	cardView:setCard(card)
  	self.nodeWin:addChild(cardView)
  	--cardView:setLvVisible(false)
  	
  	if key > 4 then
  	 cardView:setPositionX((key - 4)*cardView:getContentSize().width - 285)
  	 cardView:setPositionY(-cardView:getContentSize().height/2)
  	else
  	 cardView:setPositionX(key*cardView:getContentSize().width - 285)
  	 cardView:setPositionY(cardView:getContentSize().height/2)
  	end
  	
  	local new_card = GameData:Instance():getCurrentPackage():getCardById(card:getId())
  	assert(new_card ~= nil)

    local oldLevel = card:getLevel()
    local newLevel = new_card:getLevel()
    
    local oldExp = card:getExperience()
    local newExp = new_card:getExperience()
    
    assert(newLevel >= oldLevel)
    
    printf("OLD_LEVEL:"..oldLevel..", NEW_LEVEL:"..newLevel)
    printf("OLD_EXP:"..oldExp..", NEW_EXP:"..newExp)
    
    local oldPercent = 0
    local newPercent = 0
    
    local m_cardExp = nil
    local m_nextCardExp = nil
    
    local m_newLevelCardExp = nil
    local m_newLevelNextCardExp = nil
    
    for key, cardExp in pairs(AllConfig.cardlevelupexp) do
      if --[[cardExp.card_max_rank == card:getMaxGrade() - 1 and]] cardExp.level == oldLevel + 1 then
        m_nextCardExp = cardExp
      end
    	if --[[cardExp.card_max_rank == card:getMaxGrade() - 1 and]] cardExp.level == oldLevel then
    	  m_cardExp = cardExp
    	end
    	if --[[cardExp.card_max_rank == card:getMaxGrade() - 1 and]] cardExp.level == newLevel then
    	  m_newLevelCardExp = cardExp
    	end
    	if --[[cardExp.card_max_rank == card:getMaxGrade() - 1 and]] cardExp.level == newLevel + 1 then
        m_newLevelNextCardExp = cardExp
      end
    end
    
    assert(m_cardExp ~= nil)
    
    if m_nextCardExp == nil then
      oldPercent = 0
      newPercent = 0
    else
      local oldGetedExpThisLevel = oldExp - m_cardExp.total_exp
      oldPercent = (oldGetedExpThisLevel/m_nextCardExp.exp)*100
      if m_cardExp.exp == 0 then
        oldPercent = 0
      end
      
      local newGetedExpThisLevel = newExp - m_cardExp.total_exp
      --local newNextCardExp = AllConfig.cardlevelupexp[key + 1]
      newPercent = (newGetedExpThisLevel/m_nextCardExp.exp)*100
      if m_cardExp.exp == 0 then
        newPercent = 0
      end
      
      if newLevel > oldLevel then
         local newGetedExpThisLevel = newExp - m_newLevelCardExp.total_exp
         newPercent = (newGetedExpThisLevel/m_newLevelNextCardExp.exp)*100 + (newLevel - oldLevel)*100
      end
    end
    
    print("PERCENT_START1:",oldPercent,newPercent)
    
    local bg = display.newSprite("#battle_result_progress_card_bg.png")
    local fg1 = display.newSprite("#battle_result_progress_card.png")         
    local fg2 = display.newSprite("#battle_result_progress_card2.png")     
    
    local progressBarExp = ProgressBarView.new(bg, fg1,fg2)
    progressBarExp:setLabelEnabled(false)
    progressBarExp:setAnchorPoint(ccp(0,0))
    cardView:addChild(progressBarExp)
    progressBarExp:setPosition(-cardView:getContentSize().width/2 + 12, -56)
    progressBarExp:setPercent(oldPercent,1)
    progressBarExp:setPercent(oldPercent,2)
    progressBarExp:setFullPercentCallback(function()
     cardView:setCard(new_card)
     progressBarExp:setPercent(1,2)
   end)
    
    print("PERCENT_START2:",oldPercent,newPercent)
    
    if oldPercent >= 0 and newPercent >= 0 then 
       performWithDelay(self,function()
          progressBarExp:startProgressing(function() 
             progressBarExp:stopProgressBar()  
--             fg1:setCascadeOpacityEnabled(true)
--             local sequence = CCSequence:createWithTwoActions(CCDelayTime:create(1), CCFadeOut:create(1.5))
--             local seq = CCSequence:createWithTwoActions(CCFadeIn:create(1.5), sequence)
--             fg1:runAction(CCRepeatForever:create(seq)) 
          end,oldPercent,newPercent,1)  
          
          --card level up
          if newLevel > oldLevel then
            local level_str = display.newSprite("#battle_result_level_up.png")
            cardView:addChild(level_str,200)
            local array = CCArray:create()
            array:addObject(CCMoveBy:create(1.0, ccp(0, 30)))
            --array:addObject(CCDelayTime:create(0.4))
            --array:addObject(CCFadeOut:create(0.8))
            --array:addObject(CCRemoveSelf:create())
            local action = CCSequence:create(array)
            level_str:runAction(action)
      --      local levelup_icon = display.newSprite("#battle_result_level_up_arrow.png")
      --      cardView:addChild(levelup_icon,200)
      --      levelup_icon:setPosition(ccp(-cardView:getContentSize().width/2 + 25,-cardView:getContentSize().height/2 + 35))
          end
    
       end,0.5)
    end
    
  end
  
end

function BattleResultView:showDrops(clientSync)
 if clientSync == nil then
  return
 end

 local dropItemView = nil
  --  dropEquipments
  if clientSync.equipment ~= nil then
    for k,val in pairs(clientSync.equipment) do
      echo("drop equipment: action=", val.action, val.object.id, val.object.config_id)
      if val.action == "Add" then
--         dropItemView = DropItemView.new(val.object.config_id,1)
         table.insert(self._dropsArray,{configId = val.object.config_id ,count = 1})
--         table.insert(self._needShowLargeDropIds,dropItemView)
      elseif val.action == "Remove" then
  
      elseif val.action == "Update" then
         
      end
    end
  end
  
 --dropCards
 if clientSync.card ~= nil then
    for k,val in pairs(clientSync.card) do
      echo("drop card = : action=", val.action, val.object.id,val.object.config_id)
      if val.action == "Add" then
         dropItemView = DropItemView.new(val.object.config_id,1)
         
         local card = Card.new()
         card:initAttrById(val.object.config_id)
         if card:getMaxGrade() >= 4 then
            table.insert(self._needShowLargeDropIds,1,dropItemView)
            table.insert(self._dropsArray,1,{configId = val.object.config_id ,count = 1})
         else
            table.insert(self._dropsArray,{configId = val.object.config_id ,count = 1})
         end
         card = nil
      elseif val.action == "Remove" then
      elseif val.action == "Update" then
      end
    end
  end

  
  --drop money
  if self._getMoney ~= nil and self._getMoney > 0 then
--     dropItemView = DropItemView.new(5,self._getMoney)
--     table.insert(self._dropsArray,dropItemView)
     table.insert(self._dropsArray,{configId = 5 ,count = self._getMoney})
  end
  
  if self._jiangHun ~= nil and self._jiangHun > 0 then
    table.insert(self._dropsArray,{configId = 20 ,count = self._jiangHun})
  end
  
  local oldGuildPoint = GameData:Instance():getCurrentPlayer():getGuildPoint() or 0
  local guildPoint = self._msg.client_sync.common.guild_point - oldGuildPoint
  self._guildPoint = guildPoint
  if self._guildPoint ~= nil and self._guildPoint > 0 then
    table.insert(self._dropsArray,{configId = 26 ,count = self._guildPoint})
  end
  
  --  dropItems
  if clientSync.item ~= nil then
    for k,val in pairs(clientSync.item) do
      echo("drop item: action=", val.action, val.object.id, val.object.type_id, val.object.count)
      if val.action == "Add" then
         --dropItemView = DropItemView.new(val.object.type_id,val.object.count)
         --table.insert(self._dropsArray,dropItemView)
         table.insert(self._dropsArray,{configId = val.object.type_id ,count = val.object.count})
      elseif val.action == "Remove" then
  
      elseif val.action == "Update" then
        local item_in_bag = GameData:Instance():getCurrentPackage():getPropsById(val.object.id)
        local currentCount = 0
        if item_in_bag ~= nil then
           currentCount = item_in_bag:getCount()
        end
        
        
        local newGetCount = val.object.count - currentCount      
        --echo("getCount:",newGetCount,item_in_bag)
        --dropItemView = DropItemView.new(val.object.type_id,newGetCount)
        --table.insert(self._dropsArray,dropItemView)
        table.insert(self._dropsArray,{configId = val.object.type_id ,count = newGetCount})
      end
    end
  end

  GameData:Instance():getCurrentPackage():parseClientSyncMsg(clientSync)
  
  -- tableViewContainer
  self._tableViewScrolled = false
  --local tableViewContainer = display.newNode()
  
  local dropNum = #self._dropsArray
--  for itemIdx = 1, dropNum do
--       tableViewContainer:addChild(self._dropsArray[itemIdx])
--       self._dropsArray[itemIdx]:setPositionX((self._dropsArray[itemIdx]:getContentSize().width+20)*(itemIdx-1) + self._dropsArray[itemIdx]:getContentSize().width/2 + 15)
--       self._dropsArray[itemIdx]:setPositionY(self._dropsArray[itemIdx]:getContentSize().height/2 + 5)
--       
--  end
  if dropNum > 0 then
      --tableViewContainer:setContentSize(CCSizeMake((self._dropsArray[1]:getContentSize().width+20)*dropNum,self._dropsArray[1]:getContentSize().height))   
      local function scrollViewDidScroll(view)
          print("did scroll,posX:",view:getContainer():getPositionX())

--          if math.abs(view:getContainer():getPositionX()) > 5 then
--             self._tableViewScrolled = true
--          else
--             self._tableViewScrolled = false
--          end
          
      end
    
      local function scrollViewDidZoom(view)
      end
    
      local function tableCellTouched(table,cell)
        if self._isShowDropDetail == true or self.touchStep < 1 then
           return
        end
        
        local target = cell:getChildByTag(123)
        if target ~= nil then 
          --local size = target:getContentSize()
          local posOffset = ccp(45, 100)
          if target ~= nil then
             TipsInfo:showTip(cell,self._dropsArray[cell:getIdx()+1].configId, nil, posOffset)
          end
        end
      end
    
      local function cellSizeForTable(table,idx)
        return 75,75
      end
    
      local function tableCellAtIndex(table, idx)
        local cell = table:cellAtIndex(idx)
        if nil == cell then
          cell = CCTableViewCell:new()
        else
          cell:removeAllChildrenWithCleanup(true)
        end
        
        
        local dropItemView = DropItemView.new(self._dropsArray[idx + 1].configId,self._dropsArray[idx + 1].count)
        cell:addChild(dropItemView)
        local pos = 75*0.5
        dropItemView:setPosition(pos,pos)
        if idx == 0 then
           self._firstDropToShow = dropItemView
        end
        if #self._needShowLargeDropIds > 0 then
           if self._needShowLargeDropIds[0] == self._dropsArray[idx + 1].configId then
              self._firstDropToShow = dropItemView
           end
        end
    
        dropItemView:setTag(123)
        dropItemView:setScale(0.75)
        return cell
      end
    
      local function numberOfCellsInTableView(val)
        return #self._dropsArray
      end
      
      --build tableview
      local size = CCSizeMake(435,150)
      self._scrollView = CCTableView:create(size)
      --self._scrollView:setContentSize(size)
      self._scrollView:setDirection(kCCScrollViewDirectionHorizontal)
      --registerScriptHandler functions must be before the reloadData function
      --self._scrollView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
      --self._scrollView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
      self._scrollView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
      self._scrollView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
      self._scrollView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
      self._scrollView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
      self._scrollView:reloadData()
      self._scrollView:setTouchPriority(-128)
      
      self.nodeDropContainer:addChild(self._scrollView)
      self._scrollView:setPositionX(-195)
      self._scrollView:setPositionY(-40)
  end
end

------
--  Getter & Setter for
--      BattleResultView._BattleView 
-----
function BattleResultView:setBattleView(BattleView)
	self._BattleView = BattleView
end

function BattleResultView:getBattleView()
	return self._BattleView
end

function BattleResultView:enter()
  self:setTouchEnabled(true)
  self.resultIcon = nil
  local oldLevel = self._oldLevel
  local oldLeadShip = self._oldLeadShip
  local oldExp = self._oldExp
  local oldCoin = self._oldCoin
  local oldSpirit  = self._oldSpirit
  
  self.lableLevel:setString(oldLevel.."")
    
  local levelPlus = function()
     oldLevel = oldLevel + 1
     self.lableLevel:setString(oldLevel.."")
  end

  local bg = CCSprite:createWithSpriteFrameName("battle_result_progress_blue_bg.png")
  local fg1 = CCSprite:createWithSpriteFrameName("battle_result_progress_blue.png")             
  self.progressBarExp = ProgressBarView.new(bg, fg1)
  self.progressBarExp:setLabelEnabled(false)
  self.progressBarExp:setAnchorPoint(ccp(0,0))
  self.nodeAwardContainer:addChild(self.progressBarExp)
  self.progressBarExp:setPosition(-263,12)
  self.progressBarExp:setPercent(self._oldPercent)
  self.progressBarExp:setFullPercentCallback(levelPlus)
     
     
  --if self._result.result.win_group == BattleConfig.BattleSide.Blue then
  if self:checkIsWinByResult(self._msg) == true then --win
     local fail_reason_icon = nil
     local posY = 0
     if self._fightType == "PVE_NORMAL" or self._fightType == "PVE_ACTIVITY" then
        if self._msg.result_lv == "WIN_LEVEL_2" then --passed
           self.nodeWin:setVisible(true)
           self.nodeLose:setVisible(false)
        else -- fail
           self.lableCoin:setString("0")
           self.lableExp:setString("0")
           self.lableLevel:setString(oldLevel.."")
           posY = 180
           fail_reason_icon = _res(3059036)
           self.nodeWin:setVisible(false)
           self.nodeLose:setVisible(true)
        end
     elseif self._fightType == "PVE_GUILD" then --guild win
         self.nodeWin:setVisible(true)
         self.nodeLose:setVisible(false)
         local coin = self._msg.client_sync.common.coin - oldCoin
         local exp = self._msg.client_sync.common.experience - oldExp
         self.lableCoin:setString(coin.."")
         self.lableExp:setString(exp.."")
         self:showDrops(self._msg.client_sync)
     else
        self.nodeWin:setVisible(true)
        self.nodeLose:setVisible(false)
     end
     
     self.resultIcon = BattleResultAnimation.new(self._msg.result_lv,self._fightType)
     self.resultIcon:setDelegate(self)
     self:addChild(self.resultIcon)
     --self.resultIcon:setScale(0.7)
     --self.resultIcon:setPositionY(posY)
     if fail_reason_icon ~= nil then
       self.resultIcon:addChild(fail_reason_icon)
       fail_reason_icon:setPosition(ccp(display.cx,display.cy-180))
       fail_reason_icon:setScale(2.5)
       fail_reason_icon:runAction(CCScaleTo:create(0.20,1))
     end     
  else--if self._result.result.win_group == BattleConfig.BattleSide.Red then
--     self.resultIcon = display.newSprite("battle/lose.png",display.cx,display.cy) 
--     self:addChild(self.resultIcon)
     self.resultIcon = BattleResultAnimation.new(self._msg.result_lv,self._fightType)
     self.resultIcon:setDelegate(self)
     self:addChild(self.resultIcon)
--     self.resultIcon:setScale(0.7)
--     self.resultIcon:setPositionY(180)
     echo("ResultStarFail:",self._msg.result_lv)
     echo("RedGroupWin")
     
     if self._fightType == "PVE_BOSS" 
     or self._fightType == "PVE_GUILD"
     --or self._fightType == "PVE_BABLE"
     then
         local coin = self._msg.client_sync.common.coin - oldCoin
         local exp = self._msg.client_sync.common.experience - oldExp
         self.lableCoin:setString(coin.."")
         self.lableExp:setString(exp.."")
         self:showDrops(self._msg.client_sync)
         --GameData:Instance():getCurrentPackage():parseClientSyncMsg(self._msg.client_sync)
     elseif self._fightType == "PVP_NORMAL" then
         --self:showPvpResult()
     else
         self.lableCoin:setString("0")
         self.lableExp:setString("0")
     end
     self.lableLevel:setString(oldLevel.."")
     
     if self._fightType == "PVE_BOSS"
     or self._fightType == "PVE_GUILD"
     --or self._fightType == "PVE_BABLE"
     then
      self.nodeWin:setVisible(true)
      self.nodeLose:setVisible(false)
     else
      self.nodeWin:setVisible(false)
      self.nodeLose:setVisible(true)
     end
  end
  
  if self.nodeLose:isVisible() == true then
    local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
    local equipmentLvEnabled = false
    local equipmentGradeEnabled = false
    local surmountedEnabled = false
    for key, card in pairs(battleCards) do
      if equipmentLvEnabled == false then
      	if EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(card,EquipmentReinforceConfig.EquipmentTypeWeapon) == true
      	or EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(card,EquipmentReinforceConfig.EquipmentTypeArmor) == true
      	or EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(card,EquipmentReinforceConfig.EquipmentTypeAccessory) == true
      	then
      	   equipmentLvEnabled = true
      	end
    	end
    	
    	if equipmentGradeEnabled == false then
      	if EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(card,EquipmentReinforceConfig.EquipmentTypeWeapon) == true
        or EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(card,EquipmentReinforceConfig.EquipmentTypeArmor) == true
        or EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(card,EquipmentReinforceConfig.EquipmentTypeAccessory) == true
        then
           equipmentGradeEnabled = true
        end
      end
      
      if surmountedEnabled == false and Enhance:instance():isCardCanSurmounted(card) == true then
        surmountedEnabled = true
      end
      
    end
    
    if equipmentLvEnabled == true or equipmentGradeEnabled == true then
      local tip = TipPic.new()
      self.btnEquipmentUp:addChild(tip)
      tip:setPosition(ccp(110,105))
    end
    
    if surmountedEnabled == true then
      local tip = TipPic.new()
      self.btnCardGradeUp:addChild(tip)
      tip:setPosition(ccp(115,105))
    end
  end
end

function BattleResultView:checkIsWinByResult(msg)
   local m_msg = msg or self._msg
   local result_lv = m_msg.result_lv
   local isWin = false
   if result_lv == "WIN_LEVEL_1" or result_lv == "WIN_LEVEL_2" or result_lv == "WIN_LEVEL_3" then
      isWin = true
   elseif result_lv == "LOSE_LEVEL_1" or result_lv == "LOSE_LEVEL_2" or result_lv == "LOSE_LEVEL_3" then
      isWin = false
   end 
   return isWin,self._fightType,result_lv
end

function BattleResultView:showArenaResult()
   if self._arena_msg ~= nil then
      self.lableExp:setColor(sgGREEN)
      self.lableExp:setString(""..self._arena_msg.award.score)
      self.lableCoin:setColor(sgGREEN)
      self.lableCoin:setString(""..self._arena_msg.award.coin)   
      if self:checkIsWinByResult(self._arena_msg.result) == true then
        self.nodeDropContainer:setVisible(true)
        self:showDrops(self._arena_msg.result.client_sync)
      --else
        --self.lableCoin:setString("0")
        --self.lableExp:setString("0")
      end
   end
end


function BattleResultView:showPvpResult()
   local report =  GameData:Instance():getExpeditionInstance():getAttackReport()
   if report ~= nil then
      local dropItemView = nil
      --drop telent point
      if report:getTelentPoint() ~= nil and report:getTelentPoint() > 0 then
         --dropItemView = DropItemView.new(19,report:getTelentPoint())
         --table.insert(self._dropsArray,dropItemView)
         table.insert(self._dropsArray,{configId = 21 ,count = report:getTelentPoint()})
      end
       
      local stopKeepWin = GameData:Instance():getExpeditionInstance():getStopKeepWin()
      local stopKeepWinCoin = 0
      for i = 1, #AllConfig.stopwinbonus do
      	 if stopKeepWin >= AllConfig.stopwinbonus[i].min_win and stopKeepWin <= AllConfig.stopwinbonus[i].max_win then
      	    for key, drop in pairs(AllConfig.stopwinbonus[i].bonus) do
    	    	  local type = drop.array[1]
    	    	  local configId = drop.array[2]
    	    	  local count = drop.array[3]
              if configId >= 0 and configId <= 100 then
                 configId = type
              end
              table.insert(self._dropsArray,{configId = configId ,count = count})
      	    end
      	    
      	    break
      	 end
      end
    
   
       self.nodeDropContainer:setVisible(true)
       local targetPlayer = nil
       if report:getAttacker():getPlayerId() == GameData:Instance():getCurrentPlayer():getId() then
          if report:getBattleResult() == 2 or report:getBattleResult() == 3 or report:getBattleResult() == 4 then
             
             self.lableExp:setColor(sgGREEN)
             self.lableExp:setString(""..report:getBattleAttackScore())
             
             self.lableCoin:setColor(sgGREEN)
             self.lableCoin:setString(""..report:getAllCoin())   
             
          elseif report:getBattleResult() == 5 or report:getBattleResult() == 6 or report:getBattleResult() == 7 then
           
             self.lableExp:setColor(sgRED)
             
             if report:getBattleAttackScore() == 0 then
                self.lableExp:setString("0")
             else
                self.lableExp:setString("- "..report:getBattleAttackScore())
             end
             
             self.lableCoin:setColor(sgRED)
             
             if report:getAllCoin() == 0 then
                self.lableCoin:setString("0")
             else
                self.lableCoin:setString("- "..report:getAllCoin())
             end
          else
             echo("unexp battle result",report:getBattleResult())
          end
          --self.lableCoin:setString((report:getCoin() + report:getMinerCoin()).."")
          targetPlayer = report:getDefender()
       else
          if report:getBattleResult() == 5 or report:getBattleResult() == 6 or report:getBattleResult() == 7 then
             
             self.lableExp:setColor(sgGREEN)
             self.lableExp:setString(""..report:getBattleAttackScore())
   
             
             self.lableCoin:setColor(sgGREEN)
             self.lableCoin:setString(""..report:getAllCoin())   
             
             
          elseif report:getBattleResult() == 2 or report:getBattleResult() == 3 or report:getBattleResult() == 4 then
             
             self.lableExp:setColor(sgRED)
             if report:getBattleDefendScore() == 0 then
                self.lableExp:setString("0")
             else
                self.lableExp:setString("- "..report:getBattleDefendScore())
             end
             
             self.lableCoin:setColor(sgRED)
             if report:getAllCoin() == 0 then
                self.lableCoin:setString("0") 
             else
                self.lableCoin:setString("－ "..report:getAllCoin()) 
             end  
          else
             echo("unexp battle result",report:getBattleResult())
          end
          --self.lableCoin:setString("0")
          targetPlayer = report:getAttacker()
        end
    else
        self.lableCoin:setString("0")
        self.lableExp:setString("0")
    end
   
    -- show drops for pvp
    self:showDrops(GameData:Instance():getExpeditionInstance():getFightResultClientSync())
end

function BattleResultView:goBack()
    self.progressBarExp:stopProgressBar()
    if self._fightType == "PVP_NORMAL" then
      self:getDelegate():goToExpedition()
    elseif self._fightType == "PVE_NORMAL" then
      self:getDelegate():goToScenario()
    elseif self._fightType == "PVE_ACTIVITY" then 
      self:getDelegate():goToActivityStage()
    elseif self._fightType == "PVP_REAL_TIME" then 
     self:getDelegate():goToArena()
    elseif self._fightType == "PVP_RANK_MATCH" then 
      self:getDelegate():goToRankMatch()
    elseif self._fightType == "PVE_GUILD" then 
      self:getDelegate():goToGuild()
    elseif self._fightType == "PVE_BABLE" then 
      self:getDelegate():goToBable()
    else 
      self:getDelegate():goToActivity()
    end
end

function BattleResultView:showDropEffect()
     self._goBackBtn:setVisible(true)
     self.btnDetail:setVisible(true)
     if self._fightType ~= "PVE_BABLE" then
      self:showBattleCards()
     end
     if #self._needShowLargeDropIds > 0 then
       self._goBackBtn:setVisible(false)
       self.btnDetail:setVisible(false)
       local firstDropToShow = self._firstDropToShow
       local firstDropLargeToShow = nil
       firstDropToShow:setVisible(false)  
       local posX = firstDropToShow:getPositionX()
       local posY = firstDropToShow:getPositionY()
       local pos = firstDropToShow:getParent():convertToWorldSpace(ccp(posX,posY))
       local dropItem = DropItemView.new(firstDropToShow:getConfigId())
       dropItem:setOpacity(1)
       dropItem:setAnchorPoint(ccp(0.5,0.5))
       self:addChild(dropItem,100)
       dropItem:setPositionX(display.cx)
       dropItem:setPositionY(display.cy)
       --dropItem:setOpacity(125)
       dropItem:setScale(5.0)
       local showFirstDrop = function(node)
          node:setVisible(false)
          
          local dur = 0.85
          firstDropToShow:setVisible(true)
          
          local pkg = ccbRegisterPkg.new(self)
          pkg:addProperty("mAnimationManager","CCBAnimationManager")
          pkg:addProperty("cardNode","CCSprite")   -- 卡牌的容器
          pkg:addProperty("nodeOpen","CCSprite")
          pkg:addProperty("get_card_flare","CCParticleSystemQuad")
          local layer,owner = ccbHelper.load("anim_GetCard.ccbi","AnimGetCardCCB","CCLayer",pkg)
          self.mAnimationManager:runAnimationsForSequenceNamed("GetCard")
          self:addChild(layer)
          self.nodeOpen:setVisible(false)
          self._bg_effect = layer
          
          self.detailDropContainer = display.newNode()
          self:addChild(self.detailDropContainer)
          local detailView = nil
          for i = 1, #self._needShowLargeDropIds do
          	 local dropType = self._needShowLargeDropIds[i]:getType()
             if dropType == 8 then --card
                 local card = Card.new()
                 card:initAttrById(self._needShowLargeDropIds[i]:getConfigId())
                 detailView = CardHeadLargeView.new(card)
                 --detailView = OrbitCard.new({configId = card:getConfigId()})
             elseif dropType == 7 then --equipment
                 detailView = EquipOrbitCard.new({configId = self._needShowLargeDropIds[i]:getConfigId()})
                 detailView:setTouchEnabled(false)
                 print("created equipCard")
             end
             self.detailDropContainer:addChild(detailView)
              if i > 1 then
                  if dropType == 8 then
                    detailView:setPositionX(display.cx + ((i - 1) * display.width))
                    detailView:setPositionY(display.cy)
                  elseif dropType == 7 then
                    detailView:setPositionX(display.cx + ((i - 1) * display.width) - detailView:getContentSize().width/2)
                    detailView:setPositionY(display.cy - detailView:getContentSize().height/2)
                  end
              else
                  if dropType == 8 then
                      detailView:setPositionX(pos.x)
                      detailView:setPositionY(pos.y)
                      detailView._cardLayer:setScale(0.02)
                      detailView._cardLayer:runAction(CCEaseElasticOut:create(CCScaleTo:create(dur,1.0,1.0)))
                      detailView:runAction(CCEaseElasticOut:create(CCMoveTo:create(dur,ccp(display.cx,display.cy))))
                  elseif dropType == 7 then
                      detailView:setPositionX(pos.x - detailView:getContentSize().width/2)
                      detailView:setPositionY(pos.y - detailView:getContentSize().height/2)
                      detailView:setScale(0.02)
                      detailView:runAction(CCEaseElasticOut:create(CCScaleTo:create(dur,1.0,1.0)))
                      detailView:runAction(CCEaseElasticOut:create(CCMoveTo:create(dur,ccp(display.cx - detailView:getContentSize().width/2,display.cy - detailView:getContentSize().height/2))))
                  end
                  
    --              local delay = CCDelayTime:create(dur/2)
    --              local callfunc = CCCallFunc:create(function()
    --                    if self._bg_effect ~= nil then 
    --                      self._bg_effect:setVisible(true)
    --                    end
    --                 end)
    --              local sequence = CCSequence:createWithTwoActions(delay, callfunc)
    --              node:runAction(sequence)
                  
              end
          end
          
       
          if detailView ~= nil then
             self._isShowDropDetail = true 
          end
          local closeBtn = UIHelper.ccMenuWithSprite(display.newSprite("#battle_result_close_nor.png"),
            display.newSprite("#battle_result_close_sel.png"),
            display.newSprite("#battle_result_close_sel.png"),
            function()
                self._bg_effect:removeFromParentAndCleanup(true)
                self.detailDropContainer:removeAllChildrenWithCleanup(true)
                if self._closeBtn ~= nil then
                   self._closeBtn:removeFromParentAndCleanup(true)
                   self._closeBtn = nil
                end
                if self._scrollView ~= nil then
                  self._scrollView:setTouchEnabled(true)
                end
                self._isShowDropDetail = false
                self._goBackBtn:setVisible(true)
                self.btnDetail:setVisible(true)
            end)
          self:addChild(closeBtn)
          closeBtn:setPositionX(display.cx)
          closeBtn:setPositionY(90)
          self._closeBtn = closeBtn
       end
       
       local dur_action = 0.35
       local array = CCArray:create()
       local move = CCMoveTo:create(dur_action,ccp(pos.x,pos.y))
       local scale = CCScaleTo:create(dur_action,0.8,0.8)
       local scaleAndMove = CCSpawn:createWithTwoActions(scale,move)
       local scaleAndMoveAndFade = CCSpawn:createWithTwoActions(CCFadeTo:create(dur_action,255),scaleAndMove)
       array:addObject(scaleAndMoveAndFade)
       
       local delayAction = CCDelayTime:create(0.20)
       array:addObject(delayAction)
       array:addObject(CCCallFuncN:create(showFirstDrop)) 
       local action = CCSequence:create(array)
       dropItem:runAction(action)
       
       
       local delayTime = CCDelayTime:create(dur_action)
       local callfunction = CCCallFunc:create(function()
            self:getBattleView():shake()
         end)
       local sequenceAction = CCSequence:createWithTwoActions(delayTime, callfunction)
       self:runAction(sequenceAction)
    end

end

function BattleResultView:onTouch(event,x,y)
  if event == "began" then
      self._startX = x
      self._startY = y
      self._oldX = x
      self._oldY = y
      self._tableViewScrolled = false
      if self._scrollView ~= nil and self._isShowDropDetail == true then
         self._scrollView:setTouchEnabled(false)
      end
      return true
  elseif event == "moved" then
    --echo(event,x,y)
    if self.detailDropContainer ~= nil and self.detailDropContainer:isVisible() == true then
       local offsetX = self._oldX - x
       self.detailDropContainer:setPositionX(self.detailDropContainer:getPositionX() - offsetX)
       self._oldX = x
    end

  elseif event == "ended" then
    --echo(event,x,y)
   
    if self.resultIcon ~= nil then
       self:removeChild(self.resultIcon,true)
       self.resultIcon = nil
    end
    
    if self._scrollView ~= nil and self._isShowDropDetail == false then
       self._scrollView:setTouchEnabled(true)
    end
    
    if #self._dropsArray <= 0 then
       self._goBackBtn:setVisible(true)
       self.btnDetail:setVisible(true)
    end
    
    if self.touchStep >= 1 then
        
        if self.nodeLevelUp:isVisible() == true then
           self.nodeLevelUp:setVisible(false)
           self.nodeDropContainer:setVisible(true)
           self:showDropEffect()
--           if #self._dropsArray <= 0 then
--              --self:goBack()
--           else
--              
--           end
           
        else
           
           --self:showDropEffect()
--           local dropContainer = UIHelper.getTouchedNode({self._scrollView},x,y)
           if self._tableViewScrolled == true then
              print("return tap")
              return 
           end
           if self._isShowDropDetail == false then
             --self:goBack()  -- click countinue
           elseif self._isShowDropDetail == true then
             local slideStepLong = self._startX  - x
             if math.abs(slideStepLong) > 10 then
                if slideStepLong > 0 then
                   self._dropDetailPageIdx = self._dropDetailPageIdx + 1
                   if self._dropDetailPageIdx > #self._needShowLargeDropIds then
                      self._dropDetailPageIdx = #self._needShowLargeDropIds
                   end
                else
                   self._dropDetailPageIdx = self._dropDetailPageIdx - 1
                   if self._dropDetailPageIdx < 1 then
                      self._dropDetailPageIdx = 1
                   end
                end
                print("current page:",self._dropDetailPageIdx)
                local move = CCMoveTo:create(0.3,ccp(-(self._dropDetailPageIdx-1) * display.width,self.detailDropContainer:getPositionY()))
                self.detailDropContainer:runAction(move)
             end
           end
        end
    else
        self.layer:setVisible(true)
        if self.nodeLevelUp:isVisible() == false then
           self:showDropEffect()
        end
      
        local progressBarEnd = function()
           self.progressBarExp:stopProgressBar()
           self.lableLevel:setString(self._newLevel.."")
           echo("progressBar end")
        end
         
        local startRunProgress = function()
           --echo("startRunProgress")
           if self._oldPercent >= 0 and self._newPercent >= 0 then 
               echo("Start Progressbar:",self._oldPercent,self._newPercent)
               self.progressBarExp:startProgressing(progressBarEnd,self._oldPercent,self._newPercent)
           end
           
           if self._oldLevel ~= self._newLevel
           and self._result.result.win_group == BattleConfig.BattleSide.Blue 
           and self._fightType == "PVE_NORMAL" 
           and self._msg.result_lv == "WIN_LEVEL_2" then
              
               local pkg = ccbRegisterPkg.new(self)
               pkg:addProperty("mAnimationManager","CCBAnimationManager")
               pkg:addProperty("effectNode","CCNode")
               pkg:addFunc("playCompleteHandler",function()
                  self.effectNode:removeAllChildrenWithCleanup(true)
               end)
               pkg:addFunc("playEffect",function() 
                  
               end)
               local layer,owner = ccbHelper.load("LevelUp.ccbi","LevelUpAnimationCCB","CCLayer",pkg)
               self:addChild(layer)
               local effectAnim = _res(6010003)
               effectAnim:setPosition(ccp(0,150))
               self.effectNode:addChild(effectAnim,-1)
               
           end
         end
         
         if self._fightType == "PVP_NORMAL" then
            self.spriteBattleScore:setVisible(true)
            self.spriteExpIcon:setVisible(false)
            --self.labelPreLevel:setString("")
            --self.lableLevel:setString("")
            --self.progressBarExp:setVisible(false)
            self:showPvpResult()
         elseif self._fightType == "PVP_REAL_TIME" then
			
            self.spriteBattleScore:setVisible(true)
            self.spriteExpIcon:setVisible(false)
            self:showArenaResult()
         else
            self.spriteBattleScore:setVisible(false)
            self.spriteExpIcon:setVisible(true)
            
            performWithDelay(self,startRunProgress,0.5)
         end 
         
    end
    self.touchStep = self.touchStep + 1
    --echo(event,x,y)
  end
end


return BattleResultView
