require("view.BaseView")
QuestPopAwardView = class("QuestPopAwardView",BaseView)
function QuestPopAwardView:ctor(taskData)
  self._taskData = taskData
  self:setNodeEventEnabled(true)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("labelName","CCLabelTTF")
  pkg:addProperty("labelRequirement","CCLabelTTF")
  pkg:addProperty("labelCoin","CCLabelTTF")
  pkg:addProperty("labelExp","CCLabelTTF")
  pkg:addProperty("labelMoney","CCLabelTTF")
  --pkg:addProperty("label_taskCondition","CCLabelTTF")
  pkg:addProperty("label_taskBonus","CCLabelTTF")
  pkg:addProperty("nodeDrops","CCNode")
  pkg:addProperty("nodeBaseAward","CCNode")
  pkg:addProperty("nodeMoneyAward","CCNode")
  pkg:addProperty("nodeContainer","CCNode")
  --pkg:addProperty("scale9SpriteBg","CCScale9Sprite")
  pkg:addProperty("btnGetAward","CCControlButton")
  
  pkg:addFunc("onGetAwardHandler",QuestPopAwardView.onGetAwardHandler)
  
  --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,215), display.width, display.height)
  self:addChild(layerColor)
  
  local anim_pkg = ccbRegisterPkg.new(self)
  anim_pkg:addProperty("mAnimationManager","CCBAnimationManager")
  anim_pkg:addFunc("playend",function() end)
  local anim_layer,owner = ccbHelper.load("anim_MissionComplete.ccbi","TaskCompleteCCB","CCLayer",anim_pkg)
  self:addChild(anim_layer)
  
  self:setTouchEnabled(true)
  self:addTouchEventListener(
    function(event, x, y)
      return true
    end,false, -128, true)
  
  local layer,owner = ccbHelper.load("QuestPopAwardView.ccbi","QuestPopAwardViewCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.btnGetAward:setTouchPriority(-1000)
  self._initBtnY = self.btnGetAward:getPositionY()
  
  --top circle anim
  local bgSize = CCSizeMake(640,300)
  local imgCircle = _res(3022057)
  imgCircle:setScale(1.50)
  if imgCircle ~= nil then
    --imgCircle:setPosition(ccp(bgSize.width/2, bgSize.height-40))
    imgCircle:setPositionY(180)
    local action = CCRotateBy:create(2.7, 360)
    imgCircle:runAction(CCRepeatForever:create(action))
    self.nodeContainer:addChild(imgCircle,-1)
  end 

  --top star anim
  local starAnim = _res(6010020)
  if starAnim ~= nil then 
    starAnim:setPosition(ccp(bgSize.width/2-260, bgSize.height))
    self.nodeContainer:addChild(starAnim, 10)
  end
  
  --self.label_taskCondition:setString(_tr("task_condition"))
  self.label_taskBonus:setString(_tr("task_bonus"))
  
   local taskTypeStr = ""
   if taskData:getTaskType() == 1 then
      taskTypeStr = _tr("main_line")
   elseif taskData:getTaskType() == 2 then
      taskTypeStr = _tr("sub_line")
   elseif taskData:getTaskType() == 3 then
      taskTypeStr = _tr("nor_line")
   end
   
   local taskName = ""
   if taskData:getName() ~= nil and taskData:getProgressStr() ~= nil then               
      taskName = taskTypeStr..taskData:getName()..taskData:getProgressStr()
   end 
   self.labelName:setString(taskName)
  
  local taskRequirement = ""
  if taskData:getDesciption() ~= nil then
     taskRequirement = taskData:getDesciption()
  end
  self.labelRequirement:setString(_tr("task_condition")..taskRequirement)
   
   local coin = "0"
   if taskData:getCoin() ~= nil then
       coin = taskData:getCoin()..""
   end
   self.labelCoin:setString(coin)
   
   local exp = "0"
   if taskData:getExp() ~= nil then
      exp = taskData:getExp()..""
   end
   self.labelExp:setString(exp)
   
   local money= "0"
   if taskData:getMoney() ~= nil then
      money = taskData:getMoney()..""
   end
   self.labelMoney:setString(money)
   
   if money == "0" then
      self.nodeMoneyAward:setVisible(false)
   else
      self.nodeMoneyAward:setVisible(true)
   end
   
  local dropDatas = taskData:getDropItemDatas()
  if #dropDatas > 0 then
     local dropShow = self:buildAwardDetailViewByTask(taskData)
     self.nodeDrops:addChild(dropShow)
     --self.nodeDrops.spriteBg:setVisible(false)
     --dropShow:setPosition(ccp(0,-dropShow.spriteBg:getContentSize().height/2))
     self.btnGetAward:setPositionY(self._initBtnY - 100)
  else
     --self.nodeBaseAward:setPositionY(-50)
  end
end

function QuestPopAwardView:onEnter()
   local checkGuideLayer = function()
      if Guide:Instance():getGuideLayer() ~= nil then
         Guide:Instance():getGuideLayer():setVisible(false)
         self:stopAllActions()
      end
   end

   Guide:Instance():setGuideLayerTouchEnabled(false)
   if Guide:Instance():getGuideLayer() ~= nil then
      Guide:Instance():getGuideLayer():setVisible(false)
   else
      self:schedule(checkGuideLayer, 0.1)   
   end
   
   
end

function QuestPopAwardView:onExit()
   self:stopAllActions()
   Guide:Instance():setGuideLayerTouchEnabled(true)
   if Guide:Instance():getGuideLayer() ~= nil then
      Guide:Instance():getGuideLayer():setVisible(true)
   end
end

function QuestPopAwardView:onGetAwardHandler()
  if self._callBack ~= nil then
     self:runAction(CCCallFunc:create(self._callBack))
     print("onGetAwardHandler~~")
  end
  print("onGetAwardHandler")
  Quest:Instance():askForTaskAward(self._taskData)
end

function QuestPopAwardView:buildAwardDetailViewByTask(taskData)
  local detail = QuestAwardDetailView.new()
  local dropDatas = taskData:getDropItemDatas()
   local configIdArr = {}
   local function tableCellTouched(tableView,cell)
      local target = cell:getChildByTag(123)
      if target ~= nil then 
        --local size = target:getContentSize()
        local posOffset = ccp(45, 100)
        if target ~= nil then
           TipsInfo:showTip(cell,configIdArr[cell:getIdx()+1], nil, posOffset)
        end
      end
    end
  
    local function cellSizeForTable(tableView,idx)
      return 100,100
    end
  
    local function tableCellAtIndex(tableView, idx)
      local cell = tableView:cellAtIndex(idx)
      if nil == cell then
        cell = CCTableViewCell:new()
      else
        cell:removeAllChildrenWithCleanup(true)
      end

      local type = dropDatas[idx + 1].array[1]
      local configId = dropDatas[idx + 1].array[2]
      local count = dropDatas[idx + 1].array[3]
      local dropItemView = DropItemView.new(configId,count)
      configIdArr[idx+1] = configId

       if dropItemView ~= nil then
           dropItemView:setPositionX(50)
           dropItemView:setPositionY(50)
           dropItemView:setTag(123)
           cell:addChild(dropItemView)
       end
         
      return cell
    end
  
    local function numberOfCellsInTableView(tableView)
      return #dropDatas
    end

    --build tableview
    local size = detail.tableViewCon:getContentSize()
    local scrollView = CCTableView:create(size)
    --scrollView:setContentSize(size)
    scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    --registerScriptHandler functions must be before the reloadData function
    --scrollView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    --scrollView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
    scrollView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    scrollView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    scrollView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    scrollView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    scrollView:reloadData()
    scrollView:setTouchPriority(-1000)
    detail.tableViewCon:addChild(scrollView)
    detail.spriteBg:setVisible(false)
    return detail
end



return QuestPopAwardView