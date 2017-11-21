ExpeditionDailyAwardView = class("ExpeditionDailyAwardView",BaseView)
function ExpeditionDailyAwardView:ctor()
  self:setNodeEventEnabled(true)
  self:setTouchEnabled(true)
  self:addTouchEventListener(function() return true end,false,-128,true)
  self.expedition = GameData:Instance():getExpeditionInstance()
  self:setNodeEventEnabled(true)
  
  --color layer
  local layerScale = 2
  local layerColor = CCLayerColor:create(ccc4(0,0,0,215), display.width*layerScale, display.height*layerScale)
  self:addChild(layerColor)
  layerColor:setPosition(-(display.width*layerScale - display.width)/2,-(display.height*layerScale - display.height)/2)
end

function ExpeditionDailyAwardView:onEnter()
  
  GameData:Instance():getCurrentScene():setTopVisible(false)
  GameData:Instance():getCurrentScene():setBottomVisible(false)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("labelTip_top","CCLabelTTF")
  pkg:addProperty("labelTip_next","CCLabelTTF")
  pkg:addProperty("node_award_1","CCNode")
  pkg:addProperty("node_award_2","CCNode")
  pkg:addFunc("canleHandler",function() self:removeFromParentAndCleanup(true) end)
  
  local layer,owner = ccbHelper.load("ExpeditionDailyAwardView.ccbi","ExpeditionDailyAwardView","CCLayer",pkg)
  self:addChild(layer)
  
--  local closeBtn = UIHelper.ccMenuWithSprite(display.newSprite("#expedition_close_nor.png"),
--          display.newSprite("#expedition_close_sel.png"),
--          display.newSprite("#expedition_close_sel.png"),
--          function()
--            self:removeFromParentAndCleanup(true)
--          end)
--  self:addChild(closeBtn)
--  closeBtn:setPositionX(display.cx)
--  closeBtn:setPositionY(display.cy - 190)
  
  self.labelTip_top:setString("")
  self.labelTip_next:setString("")
  
  local dailyScore = self.expedition:getSelfPvpBaseData():getDailyScore()
  
  local rankId,drops = self:getRankInfoByScore(dailyScore)
  self:buildAwardListWithRank(drops,true)
  self.labelTip_top:setDimensions(CCSizeMake(460,0))
  self.labelTip_top:setString(_tr("get_battle_score_today%{score}",{score = dailyScore}))

  if AllConfig.pvpscorebonus[rankId + 1] ~= nil and AllConfig.pvpscorebonus[rankId + 1].type == 1 then
    local rankId,drops = self:getRankInfoByScore(AllConfig.pvpscorebonus[rankId + 1].score_min)
    self:buildAwardListWithRank(drops,false)
    local targetScore = AllConfig.pvpscorebonus[rankId].score_min
    self.labelTip_next:setString(_tr("get%{score}to_get_award",{score = targetScore}))
  end


end

function ExpeditionDailyAwardView:getRankInfoByScore(score)
  local drops = {}
  local rankId = 0
  local level = GameData:Instance():getCurrentPlayer():getLevel()
  for key, scoreRank in pairs(AllConfig.pvpscorebonus) do
    if score >= scoreRank.score_min and score <= scoreRank.score_max and scoreRank.type == 1 then
         drops = GameData:Instance():getItemsWithDropsArray(scoreRank.drops)
         rankId = key
         break
    end
  end
  return rankId,drops
end


function ExpeditionDailyAwardView:onExit()
  GameData:Instance():getCurrentScene():setTopVisible(true)
  GameData:Instance():getCurrentScene():setBottomVisible(true)
end


function ExpeditionDailyAwardView:buildAwardListWithRank(drops,isCurrentRank)
   
   
   local con = self.node_award_1
   if isCurrentRank == true then
      con = self.node_award_1
   else
      con = self.node_award_2
   end
   con:removeAllChildrenWithCleanup(true)
   
   
   
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
    
      local dropItemView = DropItemView.new(drops[idx + 1].configId,drops[idx + 1].count)

       if dropItemView ~= nil then
           configIdArr[idx + 1] = drops[idx + 1].configId
           dropItemView:setPositionX(50)
           dropItemView:setPositionY(50)
           dropItemView:setTag(123)
           cell:addChild(dropItemView)
       end
         
      return cell
    end
  
    local function numberOfCellsInTableView(tableView)
      return #drops
    end
    
    --build tableview
    local size = con:getContentSize()
    self._scrollView = CCTableView:create(size)
    --self._scrollView:setContentSize(size)
    self._scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    --registerScriptHandler functions must be before the reloadData function
    --self._scrollView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    --self._scrollView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
    self._scrollView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    self._scrollView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    self._scrollView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    self._scrollView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    self._scrollView:reloadData()
    self._scrollView:setTouchPriority(-128)
    con:addChild(self._scrollView)

end

return ExpeditionDailyAwardView