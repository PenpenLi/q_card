CardFlashSaleListItem = class("CardFlashSaleListItem",BaseView)
function CardFlashSaleListItem:ctor(dropId)
  local listSize = CCSizeMake(575,145)
  local listItem = display.newScale9Sprite("#component_list_pop_change_list_bg.png",display.cx,display.cy,listSize)
  listItem:setAnchorPoint(ccp(0,0.5))
  listItem:setPosition(ccp(0,listSize.height/2))
  self._bg = listItem
  self:addChild(listItem)
  
  local cardList = self:buildCardList(dropId)
  listItem:addChild(cardList)
  cardList:setPosition(ccp(65,12))
end

------
--  Getter & Setter for
--      CardFlashSaleListItem._Index 
-----
function CardFlashSaleListItem:setIndex(Index)
	self._Index = Index
	local weekDay = Index
	if Index == 7 then
	  weekDay = 0
	end
	if self._weekDayIcon ~= nil then
	 self._weekDayIcon:removeFromParentAndCleanup(true)
	end
	self._weekDayIcon = display.newSprite("#xianshidianjiang_week"..weekDay..".png")
	self._bg:addChild(self._weekDayIcon)
	self._weekDayIcon:setPosition(ccp(35,80))
end

function CardFlashSaleListItem:getIndex()
	return self._Index
end

function CardFlashSaleListItem:buildCardList(dropId)
  
  local dropGroup = AllConfig.drop[dropId]
  local drops = dropGroup.drop_data

  local function tableCellTouched(table,cell)
      printf("cell touched at index: " .. cell:getIdx())
      local idx =  cell:getIdx()
      local configId = drops[idx+1].array[2]
      local orbitCard = OrbitCard.new({configId =  configId })
      orbitCard:show()
   end
  
   local function cellSizeForTable(table,idx) 
      if idx == 0 then
         return 110,150
      end
      return 110,110
   end
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil ~= cell then
        cell:removeFromParentAndCleanup(true)
      end
      
      cell = CCTableViewCell:new()
      local configId = drops[idx+1].array[2]
      --local cardRoot = AllConfig.unit[configId].unit_root
      --local card = GameData:Instance():getCurrentPlayer():getIllustratedInstance():getCardByUnitRoot(cardRoot)
      local card = CollectionCard.new()
      card:initAttrById(configId)
      
      if card ~= nil then
        card:setState("HasOwned")
        local dropItemView = CollectionCardView.new(card)
        dropItemView._nameTtf:setColor(ccc3(0,0,0))
        cell:addChild(dropItemView)
       
        dropItemView:setPositionX(dropItemView:getContentSize().width/2 - 5)
        dropItemView:setPositionY(dropItemView:getContentSize().height/2 + 10)
      end
      return cell
  end
   
  local function numberOfCellsInTableView(val)
     return #drops
  end
  local canvasSize = CCSizeMake(475,145)
  local tableView = CCTableView:create(canvasSize)
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  tableView:setClippingToBounds(true)
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  
  tableView:setTouchPriority(-256)
  
  return tableView

end

return CardFlashSaleListItem