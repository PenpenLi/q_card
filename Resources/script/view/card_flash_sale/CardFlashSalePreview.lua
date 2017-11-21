require("view.component.PopModule") 
require("view.card_flash_sale.CardFlashSaleListItem")
CardFlashSalePreview = class("CardFlashSalePreview",PopModule)
local touchPriority = -256
function CardFlashSalePreview:ctor(startcountry)
  local size = CCSizeMake(615,765)
  self._popSize = size
  GuildView.super.ctor(self,size)
  self:setNodeEventEnabled(true)
  self:setAutoDisposeEnabled(true)
  self:setTouchEnabled(true)
  self:addTouchEventListener(function() return true end,false, touchPriority, true)
  self._startcountry = startcountry
end

function CardFlashSalePreview:onEnter()
	CardFlashSalePreview.super.onEnter(self)
	self:setTitleWithSprite(display.newSprite("#xianshidianjiang_shenjiangyulan.png"))
	
  local menuArray = {
    {"#xianshidianjiang_weiguo_2.png","#xianshidianjiang_weiguo_1.png"},  
    {"#xianshidianjiang_shuguo_2.png","#xianshidianjiang_shuguo_1.png"},
    {"#xianshidianjiang_wuguo_2.png","#xianshidianjiang_wuguo_1.png"},
    {"#xianshidianjiang_qunguo_2.png","#xianshidianjiang_qunguo_1.png"}
  }
  self:setMenuArray(menuArray)
  
  if self._startcountry ~= nil then
    self._startcountry = self._startcountry - 1
  end
  local startcountry = self._startcountry or 0
  
  self:tabControlOnClick(startcountry)
  self:getTabMenu():setItemSelectedByIndex(startcountry + 1)

end

function CardFlashSalePreview:onExit()
	CardFlashSalePreview.super.onExit(self)
end

function CardFlashSalePreview:tabControlOnClick(idx)

  local country = idx + 1
  --weekDay
  local info = nil 
  for key, var in pairs(AllConfig.greatbonus) do
    if var.country == country and var.drop_count == 1 then
     info = var
     break
    end
  end
  
  
  local container = self:getListContainer()
  container:removeAllChildrenWithCleanup(true)
  local canvasSize = self:getCanvasContentSize()
  
  local starstr = display.newSprite("#xianshidianjiang_benrizhixing1.png")
  container:addChild(starstr)
  starstr:setPosition(ccp(120,570))
  
  local starstr1 = display.newSprite("#xianshidianjiang_jinrizhuda.png")
  container:addChild(starstr1)
  starstr1:setPosition(ccp(377,570))
  
  local tableView = self:buildPreviewList(info)
  container:addChild(tableView)
end

function CardFlashSalePreview:buildPreviewList(info)

  local drops = info.drops

  local function tableCellTouched(table,cell)
      printf("cell touched at index: " .. cell:getIdx())
   end
  
   local function cellSizeForTable(table,idx) 
      return 151,535
   end
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil ~= cell then
        cell:removeFromParentAndCleanup(true)
      end
      
      cell = CCTableViewCell:new()
      local item = CardFlashSaleListItem.new(drops[idx + 1])
      item:setIndex(idx)
      cell:addChild(item)
      cell:setIdx(idx)
      return cell
  end
   
  local function numberOfCellsInTableView(val)
     return #drops
  end
  local canvasSize = self:getCanvasContentSize()
  local showSize = CCSizeMake(canvasSize.width,canvasSize.height - 45)
  local tableView = CCTableView:create(showSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  --tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  
  tableView:setTouchPriority(touchPriority)
  
  return tableView

end

return CardFlashSalePreview