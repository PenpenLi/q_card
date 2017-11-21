ChapterAwardView = class("ChapterAwardView",BaseView)
function ChapterAwardView:ctor(chapterId,currentCount,maxCount)
  self:setNodeEventEnabled(true)
  self._chapterId = chapterId or 1
  self._currentCount = currentCount or 0
  self._maxCount = maxCount
  self:setTouchEnabled(true)
  --self:addTouchEventListener(function() return true end,false,-128,true)
  local function checkTouchOutsideView(x, y)
    --outside check 
    local size2 = self.popupBg:getContentSize()
    local pos2 = self.popupBg:convertToNodeSpace(ccp(x, y))
    if pos2.x < 0 or pos2.x > size2.width or pos2.y < 0 or pos2.y > size2.height then 
      return true 
    end
  
    return false  
  end 

  self:addTouchEventListener(function(event, x, y)
                                if event == "began" then
                                  self.preTouchFlag = checkTouchOutsideView(x,y)
                                  return true
                                elseif event == "ended" then
                                  local curFlag = checkTouchOutsideView(x,y)
                                  if self.preTouchFlag == true and curFlag == true then
                                    self:removeFromParentAndCleanup(true)
                                  end 
                                end
                            end,
              false, -128, true)
                
  local starRanks = {}
  for key, chapterAward in pairs(AllConfig.chapter_award) do
  	if chapterAward.chapter == self._chapterId then
  	 table.insert(starRanks,chapterAward)
  	end
  end
  self:setStarRanks(starRanks)
end

------
--  Getter & Setter for
--      ChapterAwardView._StarRanks 
-----
function ChapterAwardView:setStarRanks(StarRanks)
	self._StarRanks = StarRanks
end

function ChapterAwardView:getStarRanks()
	return self._StarRanks
end

function ChapterAwardView:onEnter()
  display.addSpriteFramesWithFile("scenario/chapter_award.plist", "scenario/chapter_award.png")
  
  --color layer
  local layerScale = 2
  local layerColor = CCLayerColor:create(ccc4(0,0,0,168), display.width*layerScale, display.height*layerScale)
  self:addChild(layerColor)
  layerColor:setPosition(-(display.width*layerScale - display.width)/2,-(display.height*layerScale - display.height)/2)

  local bg = display.newScale9Sprite("#chapter_award_bg.png",display.cx,display.cy,CCSizeMake(600,600))
  self:addChild(bg)
  self.popupBg = bg
  
  local title = display.newSprite("#chapter_award_title.png")
  self:addChild(title)
  title:setPosition(ccp(display.cx,display.cy + 245))
  
  local label = CCLabelBMFont:create(self._currentCount.."/"..self._maxCount, "client/widget/words/card_name/number_skillup.fnt")
  title:addChild(label)
  label:setPosition(ccp(215,50))

  local closeBtn = UIHelper.ccMenuWithSprite(display.newSprite("#chapter_award_btn_close_nor.png"),
      display.newSprite("#chapter_award_btn_close_sel.png"),
      display.newSprite("#chapter_award_btn_close_sel.png"),
      function()
        self:removeFromParentAndCleanup(true)
      end)
  self:addChild(closeBtn)
  closeBtn:setPositionX(display.cx + 265)
  closeBtn:setPositionY(display.cy + 273)
  closeBtn:setTouchPriority(-128)
  
  --table view
  self:buildTableView()
end


function ChapterAwardView:buildTableView()
  local function tableCellTouched(tableview,cell)
      print("cell touched at index: " .. cell:getIdx())
   end
  
   local function cellSizeForTable(table,idx) 
      return 140,575
   end
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()  
      else
        cell:removeAllChildrenWithCleanup(true)
      end
      
      local item = self:buildListItem(idx)
      cell:addChild(item)
      
      return cell
  end
  
   local function numberOfCellsInTableView(val)
     return #self:getStarRanks()
  end
  
  local mSize = CCSizeMake(580,425)

  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  --tableView:setBounceable(false)
  self:addChild(tableView)
  tableView:setPosition((display.width - 640)/2 + 45,display.cy - 220)
  --registerScriptHandler functions must be before the reloadData function
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  tableView:setTouchPriority(-128)
  self._tableView = tableView
  
end 

function ChapterAwardView:buildListItem(itemIdx)
  local iconScale = 0.8
  local award = self:getStarRanks()[itemIdx + 1]
  local drops = GameData:Instance():getItemsWithDropsArray(award.drop)
  local starNum = award.star
  
  local geted = false
  --local chapterAwards = GameData:Instance():getCurrentPlayer():getGetedAwardsByAwardType(AwardType.CHEPTER_AWARD)
  local chapterAwards = GameData:Instance():getCurrentPlayer():getAllGetedAwards().chepter
  for key, m_award in pairs(chapterAwards) do
    if m_award.id == award.id then
      geted = true
      break
    end
  end
  
  
  local node = display.newNode()
  local listbg = display.newSprite("#chapter_award_list_bg.png")
  node:addChild(listbg)
  listbg:setAnchorPoint(ccp(0,0))
  listbg:setPosition(110,15)
  
  local icon = display.newSprite("#chapter_award_box"..award.type..".png")
  node:addChild(icon)
  icon:setPosition(50,73)
  
  local iconBoader = display.newSprite("#chapter_award_box_boader.png")
  node:addChild(iconBoader)
  iconBoader:setPosition(ccp(50,30))
  
  local label = CCLabelBMFont:create(starNum.."", "client/widget/words/card_name/number_skillup.fnt")
  --label:setAnchorPoint(ccp(0,0.5))
  node:addChild(label)
  label:setPosition(ccp(65,30))
 
  local line = display.newSprite("#chapter_award_line.png")
  line:setAnchorPoint(ccp(0,0))
  line:setPositionX(5)
  node:addChild(line)
  
  local nor = display.newSprite("#chapter_award_btn_nor.png")
  local sel = display.newSprite("#chapter_award_btn_sel.png")
  local dis = display.newSprite("#chapter_award_btn_gray.png")
  
  local getAwardFunc = function(a,pSender)
    GameData:Instance():getCurrentPlayer():reqQueryAwardC2S(award.id,AwardType.CHEPTER_AWARD)
    pSender:setVisible(false)
    local getedIcon = display.newSprite("#chapter_award_btn_gray1.png")
    node:addChild(getedIcon)
    getedIcon:setPosition(495,70)
  end
  
  if geted == true then
    local getedIcon = display.newSprite("#chapter_award_btn_gray1.png")
    node:addChild(getedIcon)
    getedIcon:setPosition(495,70)
  else
   
    if self._currentCount >= starNum then
      local btnAward,menuItem = UIHelper.ccMenuWithSprite(nor,sel,dis,getAwardFunc)
      node:addChild(btnAward)
      btnAward:setVisible(true)
      btnAward:setPosition(ccp(495,70))
      --self._btnAward = btnAward
    else
      local dis = display.newSprite("#chapter_award_btn_gray.png")
      node:addChild(dis)
      dis:setPosition(495,70)
    end
    
  end
  
  local configIdArr = {}
  
  local function tableCellTouched(tableview,cell)
      local target = cell:getChildByTag(123)
      if target ~= nil then 
        local posOffset = ccp(45, 100)
        if target ~= nil then
           print("configIdArr[cell:getIdx()+1]",configIdArr[cell:getIdx()+1])
           TipsInfo:showTip(cell,configIdArr[cell:getIdx()+1], nil, posOffset)
        end
      end
   end
  
   local function cellSizeForTable(table,idx) 
      return 90,110*0.8
   end
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()  
      else
        cell:removeAllChildrenWithCleanup(true)
      end
      
      local dropItemView = DropItemView.new(drops[idx + 1].configId,drops[idx + 1].count)
      if dropItemView ~= nil then
         configIdArr[idx + 1] = drops[idx + 1].configId
         dropItemView:setScale(iconScale)
         dropItemView:setPositionX(50*iconScale)
         dropItemView:setPositionY(50)
         dropItemView:setTag(123)
         cell:addChild(dropItemView)
      end
      return cell
  end
  
   local function numberOfCellsInTableView(val)
     return #drops
  end
  
  local mSize = CCSizeMake(272,100)

  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  tableView:setClippingToBounds(true)
  --tableView:setBounceable(false)
  listbg:addChild(tableView)
  tableView:setPosition(25,2)
  --registerScriptHandler functions must be before the reloadData function

  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
  tableView:setTouchPriority(-200)
  return node
end


function ChapterAwardView:onExit()
  display.removeSpriteFramesWithFile("scenario/chapter_award.plist", "scenario/chapter_award.png")
  self:getDelegate():updateBoxStateByChapterId(self._chapterId)
end

function ChapterAwardView:buildCellItem()
  
end

return ChapterAwardView