require("view.Common")
ActivityStagesView = class("ActivityStages",BaseView)
local direction = 1

function ActivityStagesView:ctor()

  self:setNodeEventEnabled(true)
  Guide:Instance():removeGuideLayer()
  local back_ground = display.newSprite("img/activity_stages/activity_stages_bg.png")
  if back_ground ~= nil then
     back_ground:setPosition(ccp(display.cx,display.cy))
     self:addChild(back_ground)
  end
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("labelOpenTime","CCLabelTTF")
  pkg:addProperty("labelLastTimes","CCLabelTTF")
  pkg:addProperty("labelWeekOpenTime","CCLabelTTF")
  pkg:addProperty("labelCostEasy","CCLabelTTF")
  pkg:addProperty("labelCostNormal","CCLabelTTF")
  pkg:addProperty("labelCostHard","CCLabelTTF")
  pkg:addProperty("labelCostLegend","CCLabelTTF")
  pkg:addProperty("labelCodition","CCLabelTTF")
  pkg:addProperty("btnEasy","CCMenuItemSprite")
  pkg:addProperty("btnNormal","CCMenuItemSprite")
  pkg:addProperty("btnHard","CCMenuItemSprite")
  pkg:addProperty("btnLegend","CCMenuItemSprite")
  pkg:addProperty("labelLevelEasy","CCLabelBMFont")
  pkg:addProperty("labelLevelNormal","CCLabelBMFont")
  pkg:addProperty("labelLevelHard","CCLabelBMFont")
  pkg:addProperty("labelLevelLegend","CCLabelBMFont")
  pkg:addProperty("nodeEasyLevel","CCNode")
  pkg:addProperty("nodeNormalLevel","CCNode")
  pkg:addProperty("nodeHardLevel","CCNode")
  pkg:addProperty("nodeLegendLevel","CCNode") 
  pkg:addProperty("btnStartBattle","CCMenuItemSprite")
  pkg:addProperty("btnBuyCount","CCMenuItemSprite")
  pkg:addProperty("nodeTableViewContainer","CCNode")
  pkg:addProperty("nodeButtonsContainer","CCNode")
  pkg:addProperty("nodeStageName","CCNode")
  
  
  pkg:addFunc("gotoEasyStageHandler",ActivityStagesView.gotoEasyStageHandler)
  pkg:addFunc("gotoNormalStageHandler",ActivityStagesView.gotoNormalStageHandler)
  pkg:addFunc("gotoHardStageHandler",ActivityStagesView.gotoHardStageHandler)
  pkg:addFunc("gotoLegendStageHandler",ActivityStagesView.gotoLegendStageHandler)
  pkg:addFunc("goToStageHandler",ActivityStagesView.goToStageHandler)
  --pkg:addFunc("buyCountHandler",ActivityStagesView.buyCountHandler)
  
  
  local layer,owner = ccbHelper.load("ActivityStagesView.ccbi","ActivityStageViewCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.labelCodition:setString("")
  --self.btnBuyCount:setVisible(false)
  
  self.waitingTimePreStr = _tr("waiting_time")

  self._leftOpenTime = 0
  
  self._angle = ActivityStages:Instance():getLastAngle() or 0
  
  self._radius = 270
  self._roundCounts = 12
  self._offsetX = 320
  self._offsetY = 130
  
--  print(self._angle)
--  if self._angle ~= 0 then
--      assert(false)
--  end
  
  self._distanceAngle = 360/self._roundCounts
  self._movingAngle = self._angle
  
  local effectAnim = _res(5020167)
  self.nodeButtonsContainer:addChild(effectAnim,100)
  effectAnim:getAnimation():play("default")
  effectAnim:setPosition(ccp(self:getPosByAngle(0).x - self._offsetX,self:getPosByAngle(0).y + self._offsetY))
  self._effectAnim = effectAnim
  
  local activityCheckPoints = ActivityStages:Instance():getCheckPoints()
  local idx = 1
  self._btnArray = {}
  -- init _checkPointArray
  self._checkPointArray = {}

  local mask = DSMask:createMask(CCSizeMake(640,500))
  self.nodeButtonsContainer:addChild(mask)
  mask:setPosition(ccp(-self._offsetX,self._offsetY))
  
  local sortActiveCheckPointsArray = {}
  local m_Idx = 1
  for key, checkPoint in pairs(activityCheckPoints) do
      sortActiveCheckPointsArray[m_Idx] = checkPoint
      m_Idx =  m_Idx + 1
  end
  
  local lastCheckPoint = ActivityStages:Instance():getCurrentCheckPoint()
  local defaultCheckPoint = lastCheckPoint 
  if lastCheckPoint == nil then
    defaultCheckPoint = ActivityStages:Instance():getCheckPointById(sortActiveCheckPointsArray[1]:getIndex())
  end
  if defaultCheckPoint:getLeftTime() > 0 then
    local hasChallenge,checkPoints = ActivityStages:Instance():hasStageToChallenge()
    if hasChallenge == true then
      defaultCheckPoint = checkPoints[1]
    end
  end
  self:setCurrentCheckPoint(defaultCheckPoint)
  
  local offseted = false
  for i = 1, self._roundCounts do
      self._checkPointArray[i] = sortActiveCheckPointsArray[idx]
  	  local ball = self:buildStageTypeIcon(i - 1,sortActiveCheckPointsArray[idx])
      mask:addChild(ball)
      ball.idx = i - 1
      local angle = (self._roundCounts - i -self._roundCounts) * self._distanceAngle
      --print("angleangle:",angle)
      ball.angle = angle
      ball:setPosition(self:getPosByAngle(self._angle + self._distanceAngle*ball.idx))
  
      table.insert(self._btnArray,ball)
      idx = idx + 1
      if idx > #sortActiveCheckPointsArray then
         idx = 1
         offseted = true
      end
      
      if offseted ~= true and sortActiveCheckPointsArray[idx]:getIndex() == defaultCheckPoint:getIndex() then
        self._angle = (self._roundCounts - i -self._roundCounts) * self._distanceAngle
      end
  end
  
  for key, ball in pairs(self._btnArray) do
  	ball:setPosition(self:getPosByAngle(self._angle + self._distanceAngle*ball.idx))
  end
  
  self.labelOpenTime:setString(self.waitingTimePreStr.."-:--:--")
  
  --local isVip = GameData:Instance():getCurrentPlayer():isVipState()
  self.btnBuyCount:setVisible(false)
  self.btnBuyCount:registerScriptTapHandler(handler(self,ActivityStagesView.buyCountHandler))
  if GameData:Instance():getCurrentPlayer():getLevel() < self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeEasy]:getRequiredCharLevel()
  or self._CurrentCheckPoint:getLeftTime() > 0 then
     self.btnBuyCount:setVisible(false)
  end
  
  self:startTimeCountDown()
  self._toucheEnabled = true
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch))

end

function ActivityStagesView:getPosByAngle(angle)
  return ccp(math.sin(angle/180*math.pi)*self._radius + self._offsetX,math.cos(angle/180*math.pi)*self._radius - self._offsetY)
end

function ActivityStagesView:onTouch(event,x,y)
  if self._toucheEnabled == false then
     return false
  end
  
  if y > 345 or y < 130 then
     return
  end
  
  if event == "began" then
    self._startX = x
    self._startY = y
    self._touchStepX = x
    self._touchStepY = y
    direction = 1
    --print("startAngle:",self._angle)
    self._startAngle = self._angle
    self._movingAngle = self._angle
    return true
  elseif event == "moved" then
    self._effectAnim:setVisible(false)
    self._angle = self._angle + ((x - self._touchStepX)*0.5)
    if math.abs(self._angle) >= 360 then
       self._angle = self._angle%360
    end
    --self._ball:setPosition(self:getPosByAngle(self._angle))
    
    for key, ball in pairs(self._btnArray) do
    	ball:setPosition(self:getPosByAngle(self._angle + self._distanceAngle*ball.idx))
    end
    
    self._touchStepX = x
    self._movingAngle = self._angle
    
  elseif event == "ended" then
    --print("self._angle_S:",self._angle)
    local targetBtn = UIHelper.getTouchedNode(self._btnArray,x,y)
    if targetBtn ~= nil and math.abs(self._startX - x) < 10 and math.abs(self._startY - y) < 10 then
       --echo("target btn:",targetBtn.angle)
       self._angle = targetBtn.angle + self._distanceAngle
    end
       
    if math.abs(self._angle) >= 360 then
       self._angle = self._angle%360
    end
--    if self._angle < 0 then
--       self._angle = 360 + self._angle
--    end
    local count = 0
    if self._angle > 0 then
      direction = 1
    else
      direction = -1
    end
    --print("direction:",direction)
    count = math.ceil(math.abs(self._angle)/self._distanceAngle)
    if math.abs(self._angle) < self._distanceAngle and math.abs(self._startAngle) == self._distanceAngle then
       count = 0
    end
    --print("count:",count)
    self._angle = self._distanceAngle*count*direction
    if math.abs(self._angle) >= 360 then
       self._angle = self._angle%360
    end
    --print("self._angle_D:",self._angle)
    local idx = count
    if direction > 0 then
       idx = self._roundCounts - count
       if idx >= self._roundCounts then
          idx = 0
       end
    end
    self:setCurrentCheckPoint(self._checkPointArray[idx + 1])
    self._toucheEnabled = false
    for key, ball in pairs(self._btnArray) do
     -- ball:setPosition(self:getPosByAngle(self._angle + self._distanceAngle*ball.idx))
      local targetPos = self:getPosByAngle(self._angle + self._distanceAngle*ball.idx)
      --self._ball:setPosition(targetPos)
      transition.execute(ball, CCMoveTo:create(0.10,targetPos),
        {
             --easing = "backout",
             onComplete = function()
               self._toucheEnabled = true
               self._effectAnim:setVisible(true)
             end,
        })
     end
  end
end

------
--  Getter & Setter for
--      ActivityStagesView._CurrentCheckPoint 
-----
function ActivityStagesView:setCurrentCheckPoint(CurrentCheckPoint)
	self._CurrentCheckPoint = CurrentCheckPoint
	if CurrentCheckPoint ~= nil then
--	   if self._CurrentCheckPoint:getIndex() == self._lastCheckPointIdx then
--	      return
--	   end
	   self._lastCheckPointIdx = self._CurrentCheckPoint:getIndex()
	   
	   self.labelOpenTime:setString(self.waitingTimePreStr.."-:--:--")
	   
	   self.nodeStageName:removeAllChildrenWithCleanup(true)
	   local name_res = _res(CurrentCheckPoint:getStageNameResId())
	   if name_res ~= nil then
	      self.nodeStageName:addChild(name_res)
	   end
	   
	   local selectedDifficultyType = StageConfig.DifficultyTypeEasy
	   --check point details
	   if GameData:Instance():getCurrentPlayer():getLevel() >= self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeEasy]:getRequiredCharLevel() then
	      self.btnEasy:setEnabled(true)
	      self.nodeEasyLevel:setVisible(false)
	   else
	      self.btnEasy:setEnabled(false)
	      self.nodeEasyLevel:setVisible(true)
	      self.labelLevelEasy:setString(self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeEasy]:getRequiredCharLevel().."")
	   end
	   
	   if GameData:Instance():getCurrentPlayer():getLevel() >= self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeNormal]:getRequiredCharLevel() then
        self.btnNormal:setEnabled(true)
        self.nodeNormalLevel:setVisible(false)
        --self:setBtnSelectedByDifficulty(StageConfig.DifficultyTypeNormal)
        --self._selectStage = self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeNormal]
        selectedDifficultyType = StageConfig.DifficultyTypeNormal
     else
        self.btnNormal:setEnabled(false)
        self.nodeNormalLevel:setVisible(true)
        self.labelLevelNormal:setString(self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeNormal]:getRequiredCharLevel().."")
     end
     
     if GameData:Instance():getCurrentPlayer():getLevel() >= self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeHard]:getRequiredCharLevel() then
        self.btnHard:setEnabled(true)
        self.nodeHardLevel:setVisible(false)
        --self:setBtnSelectedByDifficulty(StageConfig.DifficultyTypeHard)
        --self._selectStage = self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeHard]
        selectedDifficultyType = StageConfig.DifficultyTypeHard
     else
        self.btnHard:setEnabled(false)
        self.nodeHardLevel:setVisible(true)
        self.labelLevelHard:setString(self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeHard]:getRequiredCharLevel().."")
     end
     
     if GameData:Instance():getCurrentPlayer():getLevel() >= self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeLegend]:getRequiredCharLevel() then
        self.btnLegend:setEnabled(true)
        self.nodeLegendLevel:setVisible(false)
        --self:setBtnSelectedByDifficulty(StageConfig.DifficultyTypeHard)
        --self._selectStage = self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeHard]
        selectedDifficultyType = StageConfig.DifficultyTypeLegend
     else
        self.btnLegend:setEnabled(false)
        self.nodeLegendLevel:setVisible(true)
        self.labelLevelLegend:setString(self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeLegend]:getRequiredCharLevel().."")
     end
     
     -- select last difficulty
     if self._CurrentCheckPoint:getLastSelectedDifficulty() ~= nil then
        selectedDifficultyType = self._CurrentCheckPoint:getLastSelectedDifficulty()
        print("----------------------last selectedDifficultyType:",selectedDifficultyType)
     end
     
     self:setBtnSelectedByDifficulty(selectedDifficultyType)
     self._selectStage = self._CurrentCheckPoint:getStages()[selectedDifficultyType]
     self._CurrentCheckPoint:setLastSelectedDifficulty(selectedDifficultyType)
     print("-------------------------selectedDifficultyType:",selectedDifficultyType)
     
     self._leftOpenTime = self._CurrentCheckPoint:getLeftTime()
     --print("self._leftOpenTime:",self._leftOpenTime)
     if self._leftOpenTime > 0 then
        self.btnStartBattle:setEnabled(false)
        self._enabledCountDown = true
        self.btnBuyCount:setVisible(false)
     else
        self.btnStartBattle:setEnabled(true)
        self.btnBuyCount:setVisible(true)
        self.btnBuyCount:setEnabled(self:isCanBuyCount())
     end
     self.labelWeekOpenTime:setString(_tr("stage_open_time")..self._CurrentCheckPoint:getOpenTimeStr())
     
     local easyCost = self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeEasy]:getCost()
     local normalCost = self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeNormal]:getCost()
     local hardCost = self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeHard]:getCost()
     local hardLegend = self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeLegend]:getCost()
     
     self.labelCostEasy:setString("")
     self.labelCostNormal:setString("")
     self.labelCostHard:setString("")
     self.labelCostLegend:setString("")
     
     if easyCost > 0 then
       self.labelCostEasy:setString(_tr("energy")..easyCost.."")
     end
     
     if normalCost > 0 then
       self.labelCostNormal:setString(_tr("energy")..normalCost.."")
     end
     
     if hardCost > 0 then
       self.labelCostHard:setString(_tr("energy")..hardCost.."")
     end
     
     if hardLegend > 0 then
       self.labelCostLegend:setString(_tr("energy")..hardLegend.."")
     end
     
	   -- stage details
	   self:updateInfoShow()
	   
	end
end

function ActivityStagesView:isCanBuyCount()
  self.btnBuyCount:stopAllActions()
  if self._selectStage == nil then
    return false
  end

  local canBuy = self._selectStage:getIsCanBuyToday()
  if canBuy == true then
     --button effect
      local menuItem = self.btnBuyCount
      local strength = 5.0
      local times = 2
      local array = CCArray:create()
      local s_duration = 0.6/(times * 2)
      for i = 1, times do
        array:addObject(CCScaleTo:create(s_duration,1.15,1.10))
        array:addObject(CCScaleTo:create(s_duration,1.0,1.0))
      end
      array:addObject(CCDelayTime:create(3.0))
      local action = CCSequence:create(array)
      menuItem:runAction(CCRepeatForever:create(action))
  end
  return canBuy
end

function ActivityStagesView:setBtnSelectedByDifficulty(difficultyType)
   local function unselectAllDifficultyType()
      local btns = {self.btnEasy,self.btnNormal,self.btnHard,self.btnLegend}
      for key, btn in pairs(btns) do
        if btn:isEnabled() == true then
          btn:unselected()
        end
      end
   end
   
   unselectAllDifficultyType()
   if StageConfig.DifficultyTypeEasy == difficultyType then
      if self.btnEasy:isEnabled() == true then
         self.btnEasy:selected()
      end
   elseif StageConfig.DifficultyTypeNormal == difficultyType then
      if self.btnNormal:isEnabled() == true then
         self.btnNormal:selected()
      end
   elseif StageConfig.DifficultyTypeHard == difficultyType then
      if self.btnHard:isEnabled() == true then
         self.btnHard:selected()
      end
   elseif StageConfig.DifficultyTypeLegend == difficultyType then
      if self.btnLegend:isEnabled() == true then
         self.btnLegend:selected()
      end
   end
end

function ActivityStagesView:startTimeCountDown()
  self._enabledCountDown = true
  self.btnBuyCount:setEnabled(self:isCanBuyCount())
  local updateTimeShow = function()
      if self._enabledCountDown == false then
        return 
      end
      self._leftOpenTime = self._leftOpenTime - 1
     
      if self._leftOpenTime <= 0 then
         self._enabledCountDown = false
         self.labelOpenTime:setString(self.waitingTimePreStr.."00:00:00")
         self:updateInfoShow()
      else 
          if self._leftOpenTime > 86400 then --24*3600
            self.labelOpenTime:setString(self.waitingTimePreStr.._tr("day %{count}", {count=math.ceil(self._leftOpenTime/86400)}))
          else
            local hour = math.floor(self._leftOpenTime/3600)
            local min = math.floor((self._leftOpenTime%3600)/60)
            local sec = math.floor(self._leftOpenTime%60)
            self.labelOpenTime:setString(self.waitingTimePreStr..string.format("%02d:%02d:%02d", hour,min,sec))
          end
      end
  end
  self:schedule(updateTimeShow,1/1)
end

function ActivityStagesView:updateInfoShow()
  local selectStage = Scenario:Instance():getStageById(self._selectStage:getStageId())
  selectStage:setActivityId(self._selectStage:getActivityId())
  self._selectStage = selectStage
  
  print("stageId:",self._selectStage:getStageId())
  print("cd:",self._selectStage:getEnterCD())
  print("lastEnterTime:",self._selectStage:getLastEnterTime())
  print("self._selectStage:getBoughtCountToday()",self._selectStage:getBoughtCountToday())
  --print("ActivityStages:Instance():getActivityBuyCount():",ActivityStages:Instance():getActivityBuyCount())
  
  local leftTimesToday = self._selectStage:getLeftTimesToday()
  local todayFreeTimes = AllConfig.stage[self._selectStage:getStageId()].day_enter_limit
  self.labelLastTimes:setString(_tr("today_left_times")..leftTimesToday.."/"..todayFreeTimes)
  
  --tu buy count,must has instanceData 
  if self._selectStage:getInstanceData() == nil then
     self.btnBuyCount:setVisible(false)
  else
     --local isVip = GameData:Instance():getCurrentPlayer():isVipState()
     self.btnBuyCount:setVisible(true)
     self.btnBuyCount:setEnabled(self:isCanBuyCount())
     if GameData:Instance():getCurrentPlayer():getLevel() < self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeEasy]:getRequiredCharLevel()
     or self._CurrentCheckPoint:getLeftTime() > 0 then
        self.btnBuyCount:setVisible(false)
     end
  end

  
  local lastEnterTime = self._selectStage:getLastEnterTime()
  local lastTimeTable = os.date("*t", lastEnterTime)
  local lastDate = lastTimeTable.year * 10000 + lastTimeTable.month * 100 + lastTimeTable.day
  local lastSecond = lastTimeTable.hour * 3600 + lastTimeTable.min*60 + lastTimeTable.sec
  
  local timeTable = Clock:Instance():getCurServerTimeAsTable()
  local curDate = timeTable.year * 10000 + timeTable.month * 100 + timeTable.day
  local currentSecond = timeTable.hour * 3600 + timeTable.min*60 + timeTable.sec
  
  self._leftOpenTime = self._CurrentCheckPoint:getLeftTime()
  print("self._leftOpenTime~~~~~",self._leftOpenTime)
  if self._leftOpenTime <= 0 then
    if  self._selectStage:getLastEnterTime() > 0 then
        if lastDate < curDate then
           self._enabledCountDown = false
           self.btnStartBattle:setEnabled(true)
           self.labelOpenTime:setString(self.waitingTimePreStr.."00:00:00")
        else
            local cdOpenTime = lastSecond + self._selectStage:getEnterCD()
            self._leftOpenTime =  cdOpenTime - currentSecond
            
            print("!CD left time:",self._leftOpenTime)
            
            if self._leftOpenTime <= 0 then
               self._enabledCountDown = false
               self.btnStartBattle:setEnabled(true)
               self.labelOpenTime:setString(self.waitingTimePreStr.."00:00:00")
            else
               self._enabledCountDown = true
               self.btnStartBattle:setEnabled(false)
            end
        end
    else
        if self._leftOpenTime <= 0 then
           self._enabledCountDown = false
           self.btnStartBattle:setEnabled(true)
           self.labelOpenTime:setString(self.waitingTimePreStr.."00:00:00")
        end
    end
  else
    self._enabledCountDown = true
    self.btnStartBattle:setEnabled(false)
    self.labelLastTimes:setString(_tr("today_left_times").."--/--")
  end
  
  self.nodeTableViewContainer:removeAllChildrenWithCleanup(true)
  self._dropsArray = {}
  if self._selectStage:getDropShow() ~= nil then
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
              TipsInfo:showTip(self.nodeTableViewContainer, configId, nil, itemPos)
            end 
          end
        
          local function cellSizeForTable(table,idx)
            return 90,90 + distanceX
          end
        
          local function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()
            if nil == cell then
              cell = CCTableViewCell:new()  
            else
              cell:removeAllChildrenWithCleanup(true)
            end
            
            local dropItemView = nil 
            local dropItemId = self._dropsArray[idx + 1]
            dropItemView = DropItemView.new(dropItemId)
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
          local size = self.nodeTableViewContainer:getContentSize()
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
          self.nodeTableViewContainer:addChild(self._scrollView)
    end
  end
  
  if self._selectStage:getStageConditionDesc() ~= nil then
     -- self.labelWinCondition:setString(self._selectStage:getStageConditionDesc())
  end
  
  --show the stage information 
  if self._selectStage:getStageDesc() ~= nil then
  end
  
  if self._selectStage:getStageName() ~= nil then
  end
  
  if self._selectStage:getStageCoin() ~= nil then
  end
  
  if self._selectStage:getStageCharExp() ~= nil then
    --self.labelExp:setString(self._selectStage:getStageCharExp().."")
  end
  
  if self._selectStage:getCost() ~= nil then
    --self.labelCost:setString(_tr("体力："..self._selectStage:getCost()..""))
  end
  
  if GameData:Instance():getCurrentPlayer():getLevel() < self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeEasy]:getRequiredCharLevel() then
     self.btnStartBattle:setEnabled(false)
  end
  
  self.labelCodition:setString(_tr("stage_pass_condition")..self._selectStage:getStageConditionDesc())
  
end

function ActivityStagesView:getCurrentCheckPoint()
	return self._CurrentCheckPoint
end

function ActivityStagesView:gotoStageByDifficultyType(difficultyType)
  self:setBtnSelectedByDifficulty(difficultyType)
  self._selectStage = self._CurrentCheckPoint:getStages()[difficultyType]
  self._CurrentCheckPoint:setLastSelectedDifficulty(difficultyType)
  self:updateInfoShow()
end

function ActivityStagesView:gotoEasyStageHandler()
  print("easy")
  self:gotoStageByDifficultyType(StageConfig.DifficultyTypeEasy)
end

function ActivityStagesView:gotoNormalStageHandler()
  print("normal")
  self:gotoStageByDifficultyType(StageConfig.DifficultyTypeNormal)
end

function ActivityStagesView:gotoHardStageHandler()
  print("hard")
  self:gotoStageByDifficultyType(StageConfig.DifficultyTypeHard)
end

function ActivityStagesView:gotoLegendStageHandler()
  self:gotoStageByDifficultyType(StageConfig.DifficultyTypeLegend)
end

function ActivityStagesView:goToStageHandler()
  if self._selectStage == nil then
     return
  end
  local canBuy = self:isCanBuyCount()
  local pop = nil
  if self._selectStage:getLeftTimesToday() == 0 then
     if self._selectStage:getPermitBuy() == false then
        pop = PopupView:createTextPopup(_tr("challenge_times_used_out"), function() return end,true)
        GameData:Instance():getCurrentScene():addChildView(pop)
        return
     elseif self._selectStage:getPermitBuy() == true then
        if canBuy == true then
            --local forcibleCount = ActivityStages:Instance():getActivityBuyCount()
            local forcibleCount = self._selectStage:getBoughtCountToday()
            local needMoney = 0
            for key, var in pairs(AllConfig.cost) do
               if var.type == 17 then
                  --print(var.cost)
                  if var.min_count == forcibleCount + 1 then
                     needMoney = var.cost
                     break
                  end
               end
            end
            
            if needMoney <= 0 then
               return
            end
           pop = PopupView:createTextPopup(_tr("challenge_used_out_buy?_%{count}", {count = needMoney}), function()
                   if GameData:Instance():getCurrentPlayer():getMoney() < needMoney then
                    GameData:Instance():notifyForPoorMoney()
                   else
                    self:getDelegate():reqForcibleBuyActivityStage(self:getCurrentCheckPoint():getIndex(),self._selectStage:getStageId(),true)
                    ActivityStages:Instance():setLastAngle(self._angle)
                   end
                   return
                 end)
           GameData:Instance():getCurrentScene():addChildView(pop)
           return
        else
--           pop = PopupView:createTextPopup(_tr("all_challenge_used_out"), function() return end,true)
--           GameData:Instance():getCurrentScene():addChildView(pop)
           
           local pop = PopupView:createTextPopupWithPath(
            {leftNorBtn = "goumai.png",
             leftSelBtn = "goumai1.png",
             text = _tr("add_buy_counts_after_vip_up"),
             leftCallBack = function()
             -- self:showView(ShopCurViewType.PAY)
             local shopController = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
             shopController:enter()
             shopController:gotoVipPrivilegeView()
           end}) 
            
           GameData:Instance():getCurrentScene():addChildView(pop)
           
           return
        end
     end
  end
  
  echo("_selectStage:",self._selectStage:getStageId())
  if GameData:Instance():getCurrentPlayer():getSpirit() < self._selectStage:getCost() then
     --pop = PopupView:createTextPopup(_tr("not_enough_engergy"), function() return end,true)
     --GameData:Instance():getCurrentScene():addChildView(pop)
	   Common.CommonFastBuySpirit()
     return
  end
  
  ActivityStages:Instance():setLastAngle(self._angle)
  
  print("check activity id:",self:getCurrentCheckPoint():getIndex())
  self:getDelegate():reqActivityStageFightCheck(self:getCurrentCheckPoint():getIndex(),self._selectStage)
  
end

function ActivityStagesView:buyCountHandler()
  local pop = nil
  if GameData:Instance():getCurrentPlayer():getLevel() < self._CurrentCheckPoint:getStages()[StageConfig.DifficultyTypeEasy]:getRequiredCharLevel() then
     pop = PopupView:createTextPopup(_tr("pls_buy_to_challenge"), function() return end,true)
     GameData:Instance():getCurrentScene():addChildView(pop)
     return
  end
  
  local canBuy = self:isCanBuyCount()
  if canBuy == true then
      --local forcibleCount = ActivityStages:Instance():getActivityBuyCount()
      local forcibleCount = self._selectStage:getBoughtCountToday()
      local needMoney = 0
      for key, var in pairs(AllConfig.cost) do
         if var.type == 17 then
            --print(var.cost)
            if var.min_count == forcibleCount + 1 then
               needMoney = var.cost
               break
            end
         end
      end
      
      if needMoney <= 0 then
         return
      end
     pop = PopupView:createTextPopup(_tr("spend_%{count}_for_challenge?", {count=needMoney}), function()
             if GameData:Instance():getCurrentPlayer():getMoney() < needMoney then
               GameData:Instance():notifyForPoorMoney()
             else
               self:getDelegate():reqForcibleBuyActivityStage(self:getCurrentCheckPoint():getIndex(),self._selectStage:getStageId())
               ActivityStages:Instance():setLastAngle(self._angle)
             end
             return
           end)
     GameData:Instance():getCurrentScene():addChildView(pop)
     return
  else
     pop = PopupView:createTextPopup(_tr("cannot_buy_challenge_again"), function() return end,true)
     GameData:Instance():getCurrentScene():addChildView(pop)
     return
  end
end

function ActivityStagesView:buildStageTypeIcon(idx,checkPoint)
  local iconContainer = display.newNode()
  local icon_bg = display.newSprite("#activity_stage_cir_bj.png")
  iconContainer:addChild(icon_bg)
  iconContainer:setContentSize(icon_bg:getContentSize())
  
  local icon = nil
  if checkPoint:getLeftTime() <= 0 then
     icon = _res(checkPoint:getResouceId())
  else
    local resInfo = AllConfig.frames[checkPoint:getResouceId()]
    if resInfo ~= nil then
      _res(resInfo.plist)
      icon = GraySprite:createWithSpriteFrameName(resInfo.playstates)
    else
      printf("Can nout found res info by id")
    end
  end
  
  if icon ~= nil then
     iconContainer:addChild(icon)
  end
  
--  local label = CCLabelTTF:create(idx.."","Courier-Bold",24)
--  iconContainer:addChild(label)
  local icon_top = display.newSprite("#activity_stage_fubenkuang.png")
  iconContainer:addChild(icon_top)
  
  iconContainer:setContentSize(icon_top:getContentSize())
  
  return iconContainer
end

return ActivityStagesView