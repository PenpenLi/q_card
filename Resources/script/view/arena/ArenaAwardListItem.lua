ArenaAwardListItem = class("ArenaAwardListItem",function()
  return display.newNode()
end)
function ArenaAwardListItem:ctor(m_id)
  self:setNodeEventEnabled(true)
  assert(m_id ~= nil,"must has id with ctor")
  self:setId(m_id)
end

------
--  Getter & Setter for
--      ArenaAwardListItem._Id 
-----
function ArenaAwardListItem:setId(Id)
	self._Id = Id
end

function ArenaAwardListItem:getId()
	return self._Id
end

function ArenaAwardListItem:onEnter()
  local m_idDisplay = nil
  local m_id = self:getId()
  
  local lineSprite = display.newSprite("#contest_fenge.png")
  lineSprite:setAnchorPoint(ccp(0,0))
  self:addChild(lineSprite)
  lineSprite:setPositionX(-10)
  
  local label = CCLabelTTF:create("Notice Title","Courier-Bold",22)
  label:setAnchorPoint(ccp(0,0.5))
  local rankStr = ""
  if AllConfig.arena_top[m_id].min_rank == AllConfig.arena_top[m_id].max_rank then
     rankStr = AllConfig.arena_top[m_id].min_rank..""
  else
     rankStr = AllConfig.arena_top[m_id].min_rank.."-"..AllConfig.arena_top[m_id].max_rank
  end
  label:setString(_tr("rank_number%{num}",{num = rankStr}))
  m_idDisplay = label

  if m_idDisplay ~= nil then
     m_idDisplay:setPosition(ccp(25,95))
     self:addChild(m_idDisplay)
  end
  
  self:buildAwardListWithRank(m_id)
end

function ArenaAwardListItem:buildAwardListWithRank(awardRank)
   
   local con = display.newNode()
   con:setContentSize(CCSizeMake(225,90))
   self:addChild(con)
   
   --local dropGroupId = AllConfig.arena_top[awardRank].drop
    local dropGroupArray = AllConfig.arena_top[awardRank].drop
	local currentLevel = GameData:Instance():getCurrentPlayer():getLevel()

	local dropitem=nil
	for n,v in pairs(dropGroupArray) do
		dropitem = AllConfig.drop[v] 
		if(currentLevel >= dropitem.min_level and currentLevel <= dropitem.max_level) then
			break
		end
	end
   local configIdArr = {}

   local function tableCellTouched(tableView,cell)
      local target = cell:getChildByTag(123)
      if target ~= nil then 
        --local size = target:getContentSize()
        local posOffset = ccp(45, 80)
        if target ~= nil then
           TipsInfo:showTip(cell,configIdArr[cell:getIdx()+1], nil, posOffset)
        end
      end
    end
  
    local function cellSizeForTable(tableView,idx)
      return 70,70
    end
  
    local function tableCellAtIndex(tableView, idx)
      local cell = tableView:cellAtIndex(idx)
      if nil == cell then
        cell = CCTableViewCell:new()
      else
        cell:removeAllChildrenWithCleanup(true)
      end

      local type = dropitem.drop_data[idx + 1].array[1]
      local dropItemId = dropitem.drop_data[idx + 1].array[2]
      local count = dropitem.drop_data[idx + 1].array[3]
      
      local dropItemView = DropItemView.new(dropItemId,count,type)
      configIdArr[idx+1] = dropItemId

      if dropItemView ~= nil then
        dropItemView:setScale(0.75)
        dropItemView:setPositionX(35)
        dropItemView:setPositionY(35)
        dropItemView:setTag(123)
        cell:addChild(dropItemView)
      end
         
      return cell
    end
  
    local function numberOfCellsInTableView(tableView)
      return #dropitem.drop_data
    end
    
    --build tableview
    local size = con:getContentSize()
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
    --scrollView:setTouchPriority(-999)
    
    con:addChild(scrollView)
    scrollView:setPositionX(30)
    scrollView:setPositionY(10)

end

function ArenaAwardListItem:onExit()

end

return ArenaAwardListItem