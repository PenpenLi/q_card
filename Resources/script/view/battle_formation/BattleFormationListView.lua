
BattleFormationListView = class("BattleFormationListView",BaseView)

local cellWidth = 522
local cellHeight = 151
local tagId = 155
local touchPriority = -512

function BattleFormationListView:ctor(isAttack,startIdx)
  self:setNodeEventEnabled(true)
  self._isAttack = isAttack
  if self._isAttack == nil then
    self._isAttack = true
  end
  self._startIdx = startIdx
  self:setIsFastSwitchInBattle(false)
  --reg touch event
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false, touchPriority, true)
end

function BattleFormationListView:onEnter()
  display.addSpriteFramesWithFile("battle_formation/battle_formation.plist", "battle_formation/battle_formation.png")
  
  local layerColor = CCLayerColor:create(ccc4(0,0,0,190), display.width, display.height)
  self:addChild(layerColor)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeCurrent","CCNode")
  pkg:addProperty("nodeList","CCNode")
  pkg:addProperty("spriteBackground","CCScale9Sprite")
  pkg:addProperty("spriteTitleSelect","CCSprite")
  pkg:addProperty("labelTarget","CCLabelTTF")
  pkg:addProperty("labelCurrent","CCLabelTTF")
  pkg:addProperty("btnClose","CCMenuItemImage")
  
  pkg:addFunc("closeHandler",function() self:removeFromParentAndCleanup(true) end)
  
  
  local ccbi,owner = ccbHelper.load("component_list_view.ccbi","component_list_view","CCLayer",pkg)
  self:addChild(ccbi)

  self.labelTarget:setString(_tr("target_playstates"))
  self.labelCurrent:setString(_tr("current_playstates"))

  local menu = tolua.cast(self.btnClose:getParent(),"CCMenu")
  menu:setTouchPriority(touchPriority)
  
  self:buildList()
end

function BattleFormationListView:onExit()
  self:setDelegate(nil)
end

function BattleFormationListView:getTitleSpriteWithBattleFormationIdx(battleInformationIdx)
  local titleName = ""
  if battleInformationIdx == BattleFormation.BATTLE_INDEX_NORMAL_1 then
    titleName = "#battle_formation_attack_listname1.png"
  elseif battleInformationIdx == BattleFormation.BATTLE_INDEX_NORMAL_2 then
    titleName = "#battle_formation_attack_listname2.png"
  elseif battleInformationIdx == BattleFormation.BATTLE_INDEX_NORMAL_3 then
    titleName = "#battle_formation_attack_listname3.png"
  elseif battleInformationIdx == BattleFormation.BATTLE_INDEX_PVP then
    titleName = "#battle_formation_pvp_listname.png"
  elseif battleInformationIdx == BattleFormation.BATTLE_INDEX_RANK_MATCH then
    titleName = "#battle_formation_rank_match_listname.png"
  end
  local spr = display.newSprite(titleName)
  return spr
end

function BattleFormationListView:buildListItem(battleInformationIdx)
  --local listItem = display.newSprite("#component_list_pop_change_list_bg.png")
  --assert(battleInformationIdx ~= nil)
  local battleFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(battleInformationIdx)
  --dump(battleFormation)
  
  local listSize = CCSizeMake(525,151)
  local listItem = display.newScale9Sprite("#component_list_pop_change_list_bg.png",display.cx,display.cy,listSize)
  
  local listTitleSprite = self:getTitleSpriteWithBattleFormationIdx(battleInformationIdx)
  listItem:addChild(listTitleSprite)
  listTitleSprite:setPosition(ccp(150,listSize.height/2))
  
  local label = CCLabelTTF:create(_tr("playstated%{count}cards",{count = #battleFormation}),"Courier-Bold",22.0)
  label:setAnchorPoint(ccp(1,0.5))
  label:setColor(ccc3(0,0,0))
  listItem:addChild(label)
  label:setPosition(ccp(490,listSize.height/2))
  return listItem
end

function BattleFormationListView:checkTouchOutsideView(x, y)
  local size2 = self.spriteBackground:getContentSize()
  local pos2 = self.spriteBackground:convertToNodeSpace(ccp(x, y))
  if pos2.x < 0 or pos2.x > size2.width or pos2.y < 0 or pos2.y > size2.height then 
    return true 
  end

  return false  
end

function BattleFormationListView:onTouch(event, x, y)
  if event == "began" then
    self.preTouchFlag = self:checkTouchOutsideView(x,y)
    return true
  elseif event == "ended" then
    local curFlag = self:checkTouchOutsideView(x,y)
    if self.preTouchFlag == true and curFlag == true then 
      self:removeFromParentAndCleanup(true)
    end 
  end     
end

------
--  Getter & Setter for
--      BattleFormationListView._IsFastSwitchInBattle 
-----
function BattleFormationListView:setIsFastSwitchInBattle(IsFastSwitchInBattle)
	self._IsFastSwitchInBattle = IsFastSwitchInBattle
end

function BattleFormationListView:getIsFastSwitchInBattle()
	return self._IsFastSwitchInBattle
end

function BattleFormationListView:buildList()
   
   local battleInformationIdxs = {}
   local allIdxs = {}
   --[[if self._isAttack == true then
    allIdxs = BattleFormation:Instance():getAttackBattleFormationIdxs()
   else
    allIdxs = BattleFormation:Instance():getDefendBattleFormationIdxs()
   end]]
   
   
   allIdxs = BattleFormation:Instance():getAttackBattleFormationIdxs()
   if self:getDelegate()._isPopMode == false 
   and self:getIsFastSwitchInBattle() == false 
   and self:getDelegate()._selfOrgIsAttacker== true then
     allIdxs = {}
     local defendBattleFormationIdxs = BattleFormation:Instance():getDefendBattleFormationIdxs()
     for key, idx in pairs(defendBattleFormationIdxs) do
      table.insert(allIdxs,idx)
     end
     
     local attackBattleFormationIdxs = BattleFormation:Instance():getAttackBattleFormationIdxs()
     for key, idx in pairs(attackBattleFormationIdxs) do
     	table.insert(allIdxs,idx)
     end
    
   end
   
   for key, battleFormationIdx in pairs(allIdxs) do
   	if self._startIdx ~= battleFormationIdx then
   	  table.insert(battleInformationIdxs,battleFormationIdx)
   	end
   end

   local function scrollViewDidScroll(view)
    -- print("scrollViewDidScroll")
   end
   
   local function scrollViewDidZoom(view)
       printf("scrollViewDidZoom")
   end
  
   local function tableCellTouched(tableview,cell)
      printf("cell touched at index: " .. cell:getIdx())
      if self:getDelegate() ~= nil then
        print("isAttack:",self._isAttack)
        if self._isAttack == true then
          local targetBattleInformationIdx = battleInformationIdxs[cell:getIdx() + 1]
          printf("targetBattleInformationIdx:"..targetBattleInformationIdx)
          local battleFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(targetBattleInformationIdx)
          
          if self:getIsFastSwitchInBattle() == true then
            if #battleFormation > 0 then
              BattleFormation:Instance():setCurrentAttackBattleFormationIdx(targetBattleInformationIdx)
            else
              Toast:showString(GameData:Instance():getCurrentScene(), _tr("empty_battle_formation"), ccp(display.cx, display.cy))
            end
          else
            if self:getDelegate()._isPopMode ~= true then
              if BattleFormation:Instance():checkBattleFormationIdxIsAttack(targetBattleInformationIdx) == true then
                printf("setCurrentAttackBattleFormationIdx:"..targetBattleInformationIdx)
                BattleFormation:Instance():setCurrentAttackBattleFormationIdx(targetBattleInformationIdx)
              end
            end
          end
        end
        self:getDelegate():updateView(battleInformationIdxs[cell:getIdx() + 1])
      end
      self:removeFromParentAndCleanup(true)
   end
  
   local function cellSizeForTable(table,idx) 
      return cellHeight,cellWidth
   end
  
   local function tableCellAtIndex(tableview, idx)
      local cell = tableview:dequeueCell()
      local item = nil
      if nil ~= cell then
        cell:removeFromParentAndCleanup(true)
        cell = nil
      end
      cell = CCTableViewCell:new()  
      item = self:buildListItem(battleInformationIdxs[idx + 1])
      cell:addChild(item)
      cell:setContentSize(CCSizeMake(cellWidth,cellHeight))
      
      item:setPosition(cellWidth*0.5,cellHeight*0.5)
      
      item:setTag(tagId)
      return cell
  end

  local mSize = self.nodeList:getContentSize()
  if self._startIdx ~= nil then
    mSize = CCSizeMake(mSize.width,mSize.height - 215)
    self.nodeCurrent:setVisible(true)
    local startItem = self:buildListItem(self._startIdx)
    self.nodeCurrent:addChild(startItem)
    startItem:setPosition(cellWidth*0.5 + 13,93)
  else
    self.nodeCurrent:setVisible(false)
  end
  
  local function numberOfCellsInTableView(val)
    return #battleInformationIdxs
  end
  self.spriteTitleSelect:setPositionY(mSize.height)
  
  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  --tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  --tableView:setBounceable(false)
  self.nodeList:addChild(tableView)
  --registerScriptHandler functions must be before the reloadData function
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  tableView:setTouchPriority(touchPriority)
  self._tableView = tableView
end

return BattleFormationListView