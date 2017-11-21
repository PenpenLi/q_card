AutoFightDropItem = class("AutoFightDropItem",function()
    return display.newNode()
end)
function AutoFightDropItem:ctor(stage,drops,idx,coin,exp)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("tableViewCon","CCNode")
  pkg:addProperty("labelFightIdx","CCLabelTTF")
  pkg:addProperty("labelCoin","CCLabelTTF")
  pkg:addProperty("labelExp","CCLabelTTF")
  pkg:addProperty("lablePreDrop","CCLabelTTF")
  pkg:addProperty("spriteLeftArrow","CCSprite")
  pkg:addProperty("spriteRightArrow","CCSprite")
  
  local layer,owner = ccbHelper.load("AutoFightDropItem.ccbi","AutoFightDropItemCCB","CCNode",pkg)
  self:addChild(layer)
  
  self._dropsArray = drops
  
  self.spriteLeftArrow:setVisible(false)
  self.spriteRightArrow:setVisible(false)
  
  local getcoin = coin or 0
  local getexp = exp or 0
  
  self.labelCoin:setString("+"..getcoin)
  self.labelExp:setString("+"..getexp)
  self.lablePreDrop:setString(_tr("geted_award"))
  
  if stage:getIsElite() == true then
     self.labelFightIdx:setString(_tr("elite")..stage:getStageChapterId().."-"..stage:getCheckPointIndex())
  else
     self.labelFightIdx:setString(_tr("battle_times:%{count}", {count=idx}))
  end
  
  if #drops > 0 then
     if #drops > 3 then
        self.spriteLeftArrow:setVisible(true)
        self.spriteRightArrow:setVisible(true)
     end
     self:buildLists()
     self:setContentSize(CCSizeMake(490,140))
  else
     self.lablePreDrop:setString("")
     self:setContentSize(CCSizeMake(490,35))
     self:setPositionY(-(140-35))
  end
  
end

function AutoFightDropItem:buildLists()

      local dropNum = table.getn(self._dropsArray)
      if dropNum > 0 then
          local function scrollViewDidScroll(view)
          end
          
          local function scrollViewDidZoom(view)
          end
          
          local function tableCellTouched(table,cell)
          end
        
          local function cellSizeForTable(table,idx)
            return 95,95
          end
        
          local function tableCellAtIndex(table, idx)
            local cell = table:cellAtIndex(idx)
            if nil == cell then
              cell = CCTableViewCell:new()
            else
              cell:removeAllChildrenWithCleanup(true)
            end
            
            local dropItemView = DropItemView.new(self._dropsArray[idx+1].configId,self._dropsArray[idx+1].count)
            cell:addChild(dropItemView)
            dropItemView:setPosition(ccp(dropItemView:getContentSize().width/2+7,dropItemView:getContentSize().height/2+5))
            
            return cell
          end
        
          local function numberOfCellsInTableView(val)
            return dropNum
          end
          
          --build tableview
          local size = self.tableViewCon:getContentSize()
          self._scrollView = CCTableView:create(size)
          --self._scrollView:setContentSize(size)
          self._scrollView:setDirection(kCCScrollViewDirectionHorizontal)
          --registerScriptHandler functions must be before the reloadData function
          --self._scrollView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
          --self._scrollView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
          --self._scrollView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
          self._scrollView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
          self._scrollView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
          self._scrollView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
          self._scrollView:reloadData()
          --self._scrollView:setTouchPriority(-999)
          self.tableViewCon:addChild(self._scrollView)
          self._scrollView:setTouchPriority(-128)
      end
end

return AutoFightDropItem