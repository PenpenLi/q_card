require("view.equipment_reinforce.EquipmentChangeListItem")
EquipmentChangeListView = class("EquipmentChangeListView",BaseView)

local cellWidth = 522
local cellHeight = 151
local tagId = 155

function EquipmentChangeListView:ctor(card,equipmentType)
  self:setNodeEventEnabled(true)
  local layerColor = CCLayerColor:create(ccc4(0,0,0,190), display.width, display.height)
  self:addChild(layerColor)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeCurrent","CCNode")
  pkg:addProperty("nodeList","CCNode")
  pkg:addProperty("spriteBackground","CCScale9Sprite")
  pkg:addProperty("spriteTitleSelect","CCSprite")
  pkg:addProperty("labelTarget","CCLabelTTF")
  pkg:addProperty("labelCurrent","CCLabelTTF")
  pkg:addFunc("closeHandler",function() self:removeFromParentAndCleanup(true) end)
  
  
  local ccbi,owner = ccbHelper.load("component_list_view.ccbi","component_list_view","CCLayer",pkg)
  self:addChild(ccbi)
  
  assert(card ~= nil)
  self:setCard(card)
  self:setEquipmentType(equipmentType)
  
  self.labelTarget:setString(_tr("select_equipment"))
  self.labelCurrent:setString(_tr("current_equipment"))
  
--  local equipmentData = nil
--  if equipmentType == EquipmentReinforceConfig.EquipmentTypeWeapon then
--    equipmentData = card:getWeapon()
--  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeArmor then
--    equipmentData = card:getArmor()
--  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeAccessory then
--    equipmentData = card:getAccessory()
--  end
  
  --reg touch event
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false, -128, true)
  
  --self:setStartEquipment(equipmentData)
  self:buildList()
end

function EquipmentChangeListView:onEnter()
  _executeNewBird()
  EquipmentReinforce:Instance():setEquipmentSelectListView(self)
end

function EquipmentChangeListView:onExit()
  EquipmentReinforce:Instance():setEquipmentSelectListView(nil)
end

function EquipmentChangeListView:checkTouchOutsideView(x, y)
  local size2 = self.spriteBackground:getContentSize()
  local pos2 = self.spriteBackground:convertToNodeSpace(ccp(x, y))
  if pos2.x < 0 or pos2.x > size2.width or pos2.y < 0 or pos2.y > size2.height then 
    return true 
  end

  return false  
end

function EquipmentChangeListView:onTouch(event, x, y)
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
--      EquipmentChangeListView._Card 
-----
function EquipmentChangeListView:setCard(Card)
	self._Card = Card
end

function EquipmentChangeListView:getCard()
	return self._Card
end

------
--  Getter & Setter for
--      EquipmentChangeListView._EquipmentType 
-----
function EquipmentChangeListView:setEquipmentType(EquipmentType)
	self._EquipmentType = EquipmentType
end

function EquipmentChangeListView:getEquipmentType()
	return self._EquipmentType
end

--------
----  Getter & Setter for
----      EquipmentChangeListView._StartEquipment 
-------
--function EquipmentChangeListView:setStartEquipment(StartEquipment)
--	self._StartEquipment = StartEquipment
--end
--
--function EquipmentChangeListView:getStartEquipment()
--	return self._StartEquipment
--end

function EquipmentChangeListView:buildList()
--  local card = self:getCard()
--  local allEquipments = {}
--  local equipmentType = self:getEquipmentType()
--  if equipmentType == EquipmentReinforceConfig.EquipmentTypeWeapon then
--    allEquipments = GameData:Instance():getCurrentPackage():getAllWeapons()
--  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeArmor then
--    allEquipments = GameData:Instance():getCurrentPackage():getAllArmors()
--  elseif equipmentType == EquipmentReinforceConfig.EquipmentTypeAccessory then
--    allEquipments = GameData:Instance():getCurrentPackage():getAllAccessories()
--  end
--  
--  local equipments = {} --equipments to show at list
--  
--  if self:getStartEquipment() ~= nil then
--    for key, equipData in pairs(allEquipments) do
--      if equipData:getId() ~= self:getStartEquipment():getId()
--      and equipData:getCard() == nil
--      then
--    	  table.insert(equipments,equipData)
--    	end
--    end
--  else
--    for key, equipData in pairs(allEquipments) do
--      if equipData:getCard() == nil then
--        table.insert(equipments,equipData)
--      end
--    end
--  end
--  
--  GameData:Instance():getCurrentPackage():sortEquipments(equipments,true,card:getActiveEquipId(),true)
   
   local equipments,startEquipment = EquipmentReinforce:Instance():getEquipmentsByCardAndEquipmentType(self:getCard(),self:getEquipmentType())

   local function scrollViewDidScroll(view)
    -- print("scrollViewDidScroll")
   end
   
   local function scrollViewDidZoom(view)
       print("scrollViewDidZoom")
   end
  
   local function tableCellTouched(tableview,cell)
      print("cell touched at index: " .. cell:getIdx())
      local newEquipment = equipments[cell:getIdx() + 1]
      --assert((dressOrUnDress == "Dress" or dressOrUnDress == "UnDress"))
      EquipmentReinforce:Instance():setTargetEquipment(newEquipment)
      EquipmentReinforce:Instance():reqChangeEquipment("Dress",{self:getCard():getId()},newEquipment:getId())
   end
  
   local function cellSizeForTable(table,idx) 
      return cellHeight,cellWidth
   end
  
   local function tableCellAtIndex(tableview, idx)
      local cell = tableview:dequeueCell()
      local item = nil
      if nil == cell then
        cell = CCTableViewCell:new()  
        item = EquipmentChangeListItem.new()
        cell:addChild(item)
      else
        item = cell:getChildByTag(tagId)
      end
      
      cell:setContentSize(CCSizeMake(cellWidth,cellHeight))
      _registNewBirdComponent(124400 + idx + 1,cell)

      
      item:setEquipmentData(equipments[idx + 1])
      item:setPosition(cellWidth*0.5,cellHeight*0.5)
      
      item:setTag(tagId)
      
      --local cellNum = math.ceil(tableview:getViewSize().height/ConfigListCellHeight)
      --UIHelper.showScrollListView({object=item, totalCount=cellNum, index =idx})
      return cell
  end

  local mSize = self.nodeList:getContentSize()
  if startEquipment ~= nil then
    mSize = CCSizeMake(mSize.width,mSize.height - 215)
    self.nodeCurrent:setVisible(true)
    local startEquipmentItem = EquipmentChangeListItem.new(startEquipment)
    self.nodeCurrent:addChild(startEquipmentItem)
    startEquipmentItem:setPosition(cellWidth*0.5 + 13,93)
    
    
   --[[ if GameData:Instance():getLanguageType() == LanguageType.JPN then
      local nor = display.newSprite("#equipment_refresh_btn_undress.png")
      local sel = display.newSprite("#equipment_refresh_btn_undress1.png")
      local dis = display.newSprite("#equipment_refresh_btn_undress1.png")
      
      local undressMenu,menuitem = UIHelper.ccMenuWithSprite(nor,sel,dis,function()
        EquipmentReinforce:Instance():reqChangeEquipment("UnDress",{self:getCard():getId()},startEquipment:getId())
      end)
      
      self.nodeCurrent:addChild(undressMenu)
      undressMenu:setPosition(ccp(87,88))
    end]]
  else
    self.nodeCurrent:setVisible(false)
  end
  
  local function numberOfCellsInTableView(val)
    return #equipments
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
  tableView:setTouchPriority(-200)
  self._tableView = tableView
end

return EquipmentChangeListView