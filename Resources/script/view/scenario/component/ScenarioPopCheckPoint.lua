require("view.component.DropItemView")
require("view.component.TipsInfo")
require("view.Common")


ScenarioPopCheckPoint = class("ScenarioPopCheckPoint",BaseView)

ScenarioPopCheckPoint.isPoping = false

function ScenarioPopCheckPoint:ctor(checkPoint,scenarioView)
  self._checkPoint = checkPoint
  self._scenarioView = scenarioView
	self:setTouchEnabled(true)
--  self:addTouchEventListener(
--    function(event, x, y)
--      return true
--    end,false, -128, true)
  self:setNodeEventEnabled(true)
  self:setDelegate(scenarioView:getDelegate())
  --color layer
  local layerScale = 2
  local layerColor = CCLayerColor:create(ccc4(0,0,0,125), display.width*layerScale, display.height*layerScale)
  self:addChild(layerColor)
  layerColor:setPosition(-(display.width*layerScale - display.width)/2,-(display.height*layerScale - display.height)/2)
  
  -- load an ccbi file
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("popGuoguan","CCNode")
  pkg:addProperty("nodeDropContainer","CCNode")
  pkg:addProperty("nodeHeadContainer","CCNode")
  pkg:addProperty("titleStarCon","CCMenu")
  pkg:addProperty("labelStageDesc","CCLabelTTF")
  pkg:addProperty("labelCoin","CCLabelTTF")
  pkg:addProperty("labelExp","CCLabelTTF")
  pkg:addProperty("labelWinCondition","CCLabelTTF")
  pkg:addProperty("labelStageName","CCLabelBMFont")
  pkg:addProperty("labelTimes","CCLabelTTF")
  pkg:addProperty("labelCost","CCLabelTTF")
  pkg:addProperty("labelAwardCondition","CCLabelTTF")
  pkg:addProperty("btnAutoFight","CCMenuItemImage")
  pkg:addProperty("btnEasy","CCMenuItemImage")
  pkg:addProperty("btnNormal","CCMenuItemImage")
  pkg:addProperty("btnHard","CCMenuItemImage")
  pkg:addProperty("btnGoFight","CCMenuItemImage")
  pkg:addProperty("spriteVip","CCSprite")
  pkg:addProperty("star1","CCMenuItemImage")
  pkg:addProperty("star2","CCMenuItemImage")
  pkg:addProperty("star3","CCMenuItemImage")
  pkg:addProperty("btnClose","CCMenuItemImage")
  pkg:addProperty("popupBg","CCScale9Sprite")
  pkg:addProperty("labelPlayerName","CCLabelTTF")
  pkg:addProperty("nodeFirstKill","CCNode")
  pkg:addProperty("menuReview","CCMenu")
  
  pkg:addFunc("goFightHandler",ScenarioPopCheckPoint.goFightHandler)
  pkg:addFunc("guajiHandler",ScenarioPopCheckPoint.guajiHandler)
  pkg:addFunc("canleHandler",ScenarioPopCheckPoint.canleHandler)
  pkg:addFunc("firstKillReviewHandler",ScenarioPopCheckPoint.firstKillReviewHandler)
  
  
  local layer,owner = ccbHelper.load("ScenarioPopGuoguan.ccbi","ScenarioPopGuoguanCCB","CCLayer",pkg)
  self:addChild(layer)
  
  _registNewBirdComponent(108002,self.btnGoFight)
  _registNewBirdComponent(108301,self.btnEasy)
  _registNewBirdComponent(108302,self.btnNormal)
  _registNewBirdComponent(108303,self.btnHard)
  _registNewBirdComponent(108401,self.btnAutoFight)
  
  self.menuReview:setTouchPriority(-256)
  
  self.labelOldPos = ccp(self.labelAwardCondition:getPosition())  
  
  local function checkTouchOutsideView(x, y)
    --outside check 
    local size2 = self.popupBg:getContentSize()
    local pos2 = self.popupBg:convertToNodeSpace(ccp(x, y))
    if pos2.x < 0 or pos2.x > size2.width or pos2.y < 0 or pos2.y > size2.height then 
      return true 
    end
  
    return false  
  end 
    
    --reg touch event
  self:addTouchEventListener(function(event, x, y)
                                if event == "began" then
                                  self.preTouchFlag = checkTouchOutsideView(x,y)
                                  return true
                                elseif event == "ended" then
                                  local curFlag = checkTouchOutsideView(x,y)
                                  if self.preTouchFlag == true and curFlag == true then
                                    echo(" touch out of region: close popup") 
                                    self:canleHandler()
                                  end 
                                end
                            end,
              false, -256, true)
             
  self.labelAwardCondition:setString(_tr("starAwardCond"))

  self.labelStageDesc:setDimensions(CCSizeMake(416, 0))
  self.labelPlayerName:setString("")
  
  --self.btnEasy:setEnabled(false)
  --self.btnNormal:setEnabled(false)
  --self.btnHard:setEnabled(false)
  self.btnEasy:setVisible(false)
  self.btnNormal:setVisible(false)
  self.btnHard:setVisible(false)
  
  self.star1:setEnabled(false)
  self.star2:setEnabled(false)
  self.star3:setEnabled(false)
  self.star1:setVisible(false)
  self.star2:setVisible(false)
  self.star3:setVisible(false)
  
  self.btnEasy:registerScriptTapHandler(handler(self,ScenarioPopCheckPoint.onClickEasy))
  self.btnNormal:registerScriptTapHandler(handler(self,ScenarioPopCheckPoint.onClickNormal))
  self.btnHard:registerScriptTapHandler(handler(self,ScenarioPopCheckPoint.onClickHard))
  
  if self._checkPoint:getStageType() == StageConfig.StageTypeElite 
  or self._checkPoint:getStageType() == StageConfig.StageTypeEliteHide 
  or self._checkPoint:getStageType() == StageConfig.StageTypeNormalHide 
  or self._checkPoint:getStageType() == StageConfig.StageTypeGuild
  then
     self.btnGoFight:setPositionX(self.btnGoFight:getPositionX()+ 105)
     self.spriteVip:setVisible(false)
     self.btnAutoFight:setVisible(false)
  end
  
  self.spriteVip:setVisible(false)
  self.nodeFirstKill:setVisible(false)
  
  local btns = {self.btnEasy,self.btnNormal,self.btnHard,self.btnGoFight,self.btnAutoFight,self.btnClose}
  for key, btn in pairs(btns) do
  	local parent = tolua.cast(btn:getParent(),"CCMenu")
  	parent:setTouchPriority(-256)
  end
    
  -- make a button high light by idx
  local function checkSelect(key)
      if key == 1 then
         self.btnEasy:setEnabled(true)
         self.btnEasy:selected()
      elseif key == 2 then
         self.btnEasy:setEnabled(true)
         self.btnNormal:setEnabled(true)
         self.btnEasy:unselected()
         self.btnNormal:selected()
      elseif key == 3 then
         self.btnEasy:setEnabled(true)
         self.btnNormal:setEnabled(true)
         self.btnHard:setEnabled(true)
         
         self.btnEasy:unselected()
         self.btnNormal:unselected()
         self.btnHard:selected()
      end
  end
  
  --set star position
  local startX = self.titleStarCon:getPositionX()
  local totalstage = #checkPoint:getStages()
  local m_distance = 35
  self.titleStarCon:setPositionX(startX + m_distance*(3 - totalstage) )
  
  -- set diffcutly btn position
  m_distance = 90
  self.btnEasy:setPositionX(self.btnEasy:getPositionX() + m_distance*(3 - totalstage) )
  self.btnNormal:setPositionX(self.btnNormal:getPositionX() + m_distance*(3 - totalstage) )
  self.btnHard:setPositionX(self.btnHard:getPositionX() + m_distance*(3 - totalstage) )
  
      
  
  -- make stage button enabled if stage is passed
  for key, stage in pairs(checkPoint:getStages()) do
      if stage:getIsPassed() == true then
         if key == 1 then
            self.btnEasy:setEnabled(true)
         elseif key == 2 then
            self.btnNormal:setEnabled(true)
         elseif key == 3 then
            self.btnHard:setEnabled(true)
         end
      end
  end
  
  local selectedIdx =  1
  self._selectStage = checkPoint:getStages()[selectedIdx]
  checkSelect(selectedIdx) 
  
  -- show the difficulty buttons
  for key, stage in pairs(checkPoint:getStages()) do
      if key == 1 then
         self.btnEasy:setVisible(true)
         self.star1:setVisible(true)
         if stage:getIsPassed() == true then
            self.star1:setEnabled(true)
         end
      elseif key == 2 then
         self.btnNormal:setVisible(true)
         self.star2:setVisible(true)
         if stage:getIsPassed() == true then
            self.star2:setEnabled(true)
         end
      elseif key == 3 then
         self.btnHard:setVisible(true)
         self.star3:setVisible(true)
         if stage:getIsPassed() == true then
            self.star3:setEnabled(true)
         end
      end
      
  end
  
  -- index to select then newest difficulty
  local allPassed = true
  for key, stage in pairs(checkPoint:getStages()) do
      if stage:getIsPassed() == false then
          self._selectStage = stage
          allPassed = false
          checkSelect(key)
          break
      end
  end
  
  -- if all passed,select the last one
  if allPassed == true then
      checkSelect(#checkPoint:getStages())
     self._selectStage = checkPoint:getStages()[#checkPoint:getStages()]
  end
  
  if checkPoint:getSelectedStage() ~= nil then
     self._selectStage = checkPoint:getSelectedStage()
     for key, stage in pairs(checkPoint:getStages()) do
         if stage:getStageId() == self._selectStage:getStageId() then
            self:selectButtonByIdx(key)
            break
         end
     end
  else
     --checkPoint:setSelectedStage(self._selectStage)
  end
  
  
  self:updateInfoShow()

 
  local resId = self._selectStage:getHeadRes()
  if resId > 0 then
    local head = _res(resId)
    if head ~= nil then
       local mask = DSMask:createMask(CCSizeMake(205,222))
       mask:setPosition(ccp(-205/2,-222/2-6))
       head:setPosition(ccp(205/2,222/2))
       head:setScale(0.5)
       mask:addChild(head)
       self.nodeHeadContainer:addChild(mask)
    end
  end
  
  _executeNewBird()

end

function ScenarioPopCheckPoint:firstKillReviewHandler()
  local reportInfo = self._selectStage:getReportInfo()
  if reportInfo ~= nil then
     BattleReportShare:Instance():reqBattleReview(reportInfo.view,reportInfo.ft)
     Scenario:Instance():setCurrentStage(self._selectStage)
  end
end

 -- select an stage button by index
function ScenarioPopCheckPoint:selectButtonByIdx(key)
   if self.btnEasy:isEnabled() == true then
      self.btnEasy:unselected()
   end
   
   if self.btnNormal:isEnabled() == true then
      self.btnNormal:unselected()
   end
   
   if self.btnHard:isEnabled() == true then
      self.btnHard:unselected()
   end
   
   local btn = nil 
   if key == 1 then
      btn = self.btnEasy
   elseif key == 2 then
      btn = self.btnNormal
   elseif key == 3 then
      btn = self.btnHard
   end
   
   if btn:isEnabled() == true then
      btn:selected()
   end
end

function ScenarioPopCheckPoint:updateInfoShow()
  --reset state
  self.btnGoFight:setEnabled(true)
  self.btnAutoFight:setEnabled(true)
  self.nodeDropContainer:removeAllChildrenWithCleanup(true)
  self.nodeFirstKill:setVisible(false)
  
  
  if self._selectStage:getReportInfo() ~= nil then
    local reportInfo = self._selectStage:getReportInfo()
        --[[
      message ShareReport{
        enum ReportSource{
          SYSTEM = 1;   //来自玩家
          PLAYER = 2;   //来自系统
        }
        optional FightType ft = 1;        //战报类型
        optional int32 view = 2;        //录像Id
        optional RelationData attacker = 3;   //进攻方
        optional RelationData defender = 4;   //防守方
        optional int32 other = 5;       //附带数据  如果FightType = Protocal::PVE_NORMAL  other = 副本ID
        optional ReportSource source = 6;     //来源
      }
      ]]
      self.nodeFirstKill:setVisible(true)
      self.labelPlayerName:setString(reportInfo.attacker.name)
  end
  
  self._dropsArray = {}
  if self._selectStage:getDropShow() ~= nil then
    --local tableViewContainer = display.newNode()
    
   
    local idx = 0
    for key, dropItemId in pairs(self._selectStage:getDropShow()) do
      table.insert(self._dropsArray,dropItemId)
      idx = idx + 1
    end
    
    self.tipObjectArray = {}

    local dropNum = #self._dropsArray
    local distanceX = 10
    local distanceY = 0
    if dropNum > 0 then
          --tableViewContainer:setContentSize(CCSizeMake((self._dropsArray[1]:getContentSize().width+5)*dropNum,self._dropsArray[1]:getContentSize().height))   
          local function scrollViewDidScroll(view)
          end
        
          local function scrollViewDidZoom(view)
          end
        
          local function tableCellTouched(table,cell)
            local idx = cell:getIdx()

            local node = self.tipObjectArray[idx+1]
            if node ~= nil then 
              local configId = node:getConfigId()
              echo("=== configId=", configId)
              local x = table:getContentOffset().x + idx * 90 + 45
              local itemPos = ccp(x, 100)
              TipsInfo:showTip(self.nodeDropContainer, configId, nil, itemPos)
            end 
          end
        
          local function cellSizeForTable(table,idx)
            --return tableViewContainer:getContentSize().height,tableViewContainer:getContentSize().width
            return 90,90 + distanceX
          end
        
          local function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()
            if nil == cell then
              cell = CCTableViewCell:new()  
            else
              cell:removeAllChildrenWithCleanup(true)
              cell:reset()
            end
            
            local dropItemId = self._dropsArray[idx + 1]
            --print("dropItemId:",dropItemId)
            local dropItemView = DropItemView.new(dropItemId)
            self.tipObjectArray[idx+1] = dropItemView
            cell:addChild(dropItemView)
            dropItemView:setPositionX(dropItemView:getContentSize().width/2 + distanceX/2)
            dropItemView:setPositionY(dropItemView:getContentSize().height/2 + distanceY/2)

            return cell
          end
        
          local function numberOfCellsInTableView(val)
            return dropNum
          end
          
          --build tableview
          local size = self.nodeDropContainer:getContentSize()
          self._scrollView = CCTableView:create(size)
          self._scrollView:setContentSize(size)
          self._scrollView:setDirection(kCCScrollViewDirectionHorizontal)
          --registerScriptHandler functions must be before the reloadData function
          --self._scrollView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
          --self._scrollView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
          self._scrollView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
          self._scrollView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
          self._scrollView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
          self._scrollView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
          self._scrollView:reloadData()
          self._scrollView:setTouchPriority(-300)
          self._scrollView:setPositionY(5)
          self.nodeDropContainer:addChild(self._scrollView)
    end
  end
  
  if self._selectStage:getStageConditionDesc() ~= nil then
    self:setWinConditionStr(self._selectStage:getStageConditionDesc())
  end
  
  --show the stage information 
  if self._selectStage:getStageDesc() ~= nil then
    --self.labelStageDesc:setString(self._selectStage:getStageDesc())
    self.labelStageDesc:setString("")
  end
  
  if self._selectStage:getStageName(false) ~= nil then
    local s = self._selectStage:getStageName(false)
     local name = ""
     local zh_idx = 1
     local zh_size = 3
     local zh_len = string.len(s)/zh_size
     for i= 1, zh_len do
        name = name..string.sub(s,zh_idx,string.len(s)/zh_len*i).." "
        zh_idx = zh_idx + zh_size
     end
     self.labelStageName:setString(name)
  end
  
   if self._selectStage:getStageCoin() ~= nil then
    self.labelCoin:setString(self._selectStage:getStageCoin().."")
  end
  
   if self._selectStage:getStageCharExp() ~= nil then
    self.labelExp:setString(self._selectStage:getStageCharExp().."")
  end
  
  if self._selectStage:getCost() ~= nil then
    self.labelCost:setString(_tr("energy_%{count}", {count=self._selectStage:getCost()}))
  end
  
  --local todayTotalCanBuy = self._selectStage:getBuyCount()
  --local canBuy = (self._selectStage:getBoughtCountToday() < todayTotalCanBuy and self._selectStage:getPermitBuy() == true)
  local canBuy = self._selectStage:getIsCanBuyToday()
  
  if self._selectStage:getLeftTimesToday() ~= nil then
     if self._selectStage:getLeftTimesToday() < 0 then
        self.labelTimes:setString(_tr("left_times_unlimited"))
     elseif self._selectStage:getLeftTimesToday() == 0 then
        if self._selectStage:getPermitBuy() == false then
           self.btnGoFight:setEnabled(false)
        else
           if canBuy == true then
             self.btnGoFight:setEnabled(true)
           else
             --self.btnGoFight:setEnabled(false)
           end
        end
        self.labelTimes:setString(_tr("left_times_%{count}", {count=self._selectStage:getLeftTimesToday()}))
     else
        self.btnGoFight:setEnabled(true)
        self.labelTimes:setString(_tr("left_times_%{count}", {count=self._selectStage:getLeftTimesToday()}))
     end
  end
    
  if self._selectStage:getIsOpen() == false then
     if self._selectStage:getPreStage() ~= nil then 
        if self._selectStage:getPreStage():getIsPassed() == false then
           self.btnGoFight:setEnabled(false)
           self.btnAutoFight:setEnabled(false)
        end
     else
     end
  end
end

function ScenarioPopCheckPoint:onEnter()
  ScenarioPopCheckPoint.super.onEnter(self)
  ScenarioPopCheckPoint.isPoping = true
end


function ScenarioPopCheckPoint:onExit()
  ScenarioPopCheckPoint.isPoping = false
  self.btnEasy:unregisterScriptTapHandler ()
  self.btnNormal:unregisterScriptTapHandler ()
  self.btnHard:unregisterScriptTapHandler ()
  self._scenarioView:setPopView(nil)
  self._scenarioView = nil
end

function ScenarioPopCheckPoint:selectDifficultyType(difficultyType)
  if difficultyType == StageConfig.DifficultyTypeEasy then
     self:onClickEasy()
  elseif difficultyType == StageConfig.DifficultyTypeNormal then
     self:onClickNormal()
  elseif difficultyType == StageConfig.DifficultyTypeHard then
     self:onClickHard()
  end
end

function ScenarioPopCheckPoint:onClickEasy()
  echo("onClickEasy")
  _executeNewBird()
  self:selectButtonByIdx(1)
  if self.btnNormal:isEnabled() == true then
     self.btnNormal:unselected()
  end
  if self.btnHard:isEnabled() == true then
     self.btnHard:unselected()
  end

  self._selectStage = self._checkPoint:getStages()[1]
  if self._selectStage:getStageConditionDesc() ~= nil then
    self:setWinConditionStr(self._selectStage:getStageConditionDesc())
  end
  
  self._checkPoint:setSelectedStage(self._selectStage)
  
  self:updateInfoShow()
end

function ScenarioPopCheckPoint:onClickNormal()
  echo("onClickNormal")
  _executeNewBird()
  self:selectButtonByIdx(2)
  self._selectStage = self._checkPoint:getStages()[2]
  if self._selectStage:getStageConditionDesc() ~= nil then
    self:setWinConditionStr(self._selectStage:getStageConditionDesc())
  end
  self._checkPoint:setSelectedStage(self._selectStage)
  
  self:updateInfoShow()
  
  --UIHelper.triggerGuideWithObject(11804,self.btnGoFight,nil,emRight)
end

function ScenarioPopCheckPoint:onClickHard()
  echo("onClickHard")
  _executeNewBird()
  self:selectButtonByIdx(3)
  self._selectStage = self._checkPoint:getStages()[3]
  if self._selectStage:getStageConditionDesc() ~= nil then
    self:setWinConditionStr(self._selectStage:getStageConditionDesc())
  end
  self._checkPoint:setSelectedStage(self._selectStage)
  self:updateInfoShow()
end

function ScenarioPopCheckPoint:goFightHandler()
  
  --local todayTotalCanBuy = self._selectStage:getBuyCount()
  --local canBuy = (self._selectStage:getBoughtCountToday() < todayTotalCanBuy and self._selectStage:getPermitBuy() == true)
--  local canBuy = self._selectStage:getIsCanBuyToday()
--  local pop = nil
--  if self._selectStage:getLeftTimesToday() == 0 then
--     if self._selectStage:getPermitBuy() == false then
--        pop = PopupView:createTextPopup(_tr("challenge_times_used_out"), function() return end,true)
--        GameData:Instance():getCurrentScene():addChildView(pop)
--        return
--     elseif self._selectStage:getPermitBuy() == true then
--        if canBuy == true then
--            local forcibleCount = self._selectStage:getBoughtCountToday()
--            local needMoney = 0
--            for key, var in pairs(AllConfig.cost) do
--               if var.type == 15 then
--                  --print(var.cost)
--                  if var.min_count == forcibleCount + 1 then
--                     needMoney = var.cost
--                     break
--                  end
--               end
--            end
--            
--            if needMoney <= 0 then
--               return
--            end
--           pop = PopupView:createTextPopup(_tr("challenge_used_out_buy?_%{count}", {count = needMoney}), function() self:getDelegate():reqForcibleBuyStage(self._selectStage:getStageId(),needMoney)  return  end)
--           GameData:Instance():getCurrentScene():addChildView(pop)
--           return
--        else
--           local pop = PopupView:createTextPopupWithPath(
--            {leftNorBtn = "goumai.png",
--             leftSelBtn = "goumai1.png",
--             text = _tr("add_buy_counts_after_vip_up"),
--             leftCallBack = function()
--             -- self:showView(ShopCurViewType.PAY)
--             local shopController = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
--             shopController:enter()
--             shopController:gotoVipPrivilegeView()
--           end}) 
--            
--           GameData:Instance():getCurrentScene():addChildView(pop)
--           return
--        end
--     end
--  end
--  
--  echo("_selectStage:",self._selectStage:getStageId())
--  if GameData:Instance():getCurrentPlayer():getSpirit() < self._selectStage:getCost() then
--	   Common.CommonFastBuySpirit()
--     return
--  end
  if Scenario:Instance():isStageCanFightNow(self._selectStage) == true then
    self:getDelegate():reqPVEFightCheck(self._selectStage)
  end
end

function ScenarioPopCheckPoint:canleHandler()
  self:removeFromParentAndCleanup(true)
end

function ScenarioPopCheckPoint:guajiHandler()
  if GameData:Instance():checkSystemOpenCondition(12, true) == false then 
    return 
  end 
  
  self._scenarioView:alertQuickFight(self._selectStage)
  self:removeFromParentAndCleanup(true)
end

function ScenarioPopCheckPoint:setWinConditionStr(str)
  self.labelWinCondition:setString(str)
  --rejust pos
  local w1 = self.labelAwardCondition:getContentSize().width 
  local w2 = self.labelWinCondition:getContentSize().width 

  local pos = self.labelAwardCondition:getParent():convertToWorldSpace(self.labelOldPos)
  if pos.x + w1 + w2 > 600 then 
    local offsetX = pos.x + w1 + w2 - 600 
    self.labelAwardCondition:setPositionX(self.labelOldPos.x-offsetX)
    self.labelWinCondition:setPositionX(self.labelOldPos.x-offsetX+w1)
  else 
    self.labelAwardCondition:setPositionX(self.labelOldPos.x)
    self.labelWinCondition:setPositionX(self.labelOldPos.x+w1)
  end 
end 

return ScenarioPopCheckPoint