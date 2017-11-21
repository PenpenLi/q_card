ShowErrorView = class("ShowErrorView",BaseView)

function ShowErrorView:ctor()
  ShowErrorView.textArray={}
  ShowErrorView.tableSize=0
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("onConfirmHandler",ShowErrorView.onConfirmHandler)
  local layer,owner = ccbHelper.load("ShowErrorView.ccbi","ShowErrorViewCCB","CCLayer",pkg)
  self:addChild(layer)
  local winSize=CCDirector:sharedDirector():getWinSize()
  local tableView = CCTableView:create(CCSizeMake(500, 150))
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setPosition(CCPointMake(winSize.width/2-246, winSize.height / 2-40))
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self._tableView=tableView
  self:addChild(self._tableView)
end

function ShowErrorView:onConfirmHandler()
  self:removeFromParentAndCleanup(true)
end



function ShowErrorView.scrollViewDidScroll(view)
  print("scrollViewDidScroll")
end

function ShowErrorView.scrollViewDidZoom(view)
  print("scrollViewDidZoom")
end

function ShowErrorView.tableCellTouched(table,cell)
  print("cell touched at index: " .. cell:getIdx())
end

function ShowErrorView.cellSizeForTable(table,idx) 
  return 25,200
end
--idx从0开始
function ShowErrorView.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = CCTableViewCell:new()
        label = CCLabelTTF:create(ShowErrorView.textArray[idx+1], "Courier-Bold",20.0)
        label:setColor(ccc3(255, 0, 0))
        label:setPosition(CCPointMake(0,0))
        label:setAnchorPoint(CCPointMake(0,0))
        label:setTag(123)
        cell:addChild(label)
    else
        label = tolua.cast(cell:getChildByTag(123),"CCLabelTTF")
        if nil ~= label then
            label:setString(ShowErrorView.textArray[idx+1])
        end
    end

    return cell
end
--行数
function ShowErrorView.numberOfCellsInTableView(table)
   return ShowErrorView.tableSize
end



function ShowErrorView:setMessage(res)
   local len=string.len(res)
   local textCount=48
   local i=0
   repeat
      subStr=string.sub(res,1,textCount)
      i=i+1
      res=string.sub(res,textCount+1,string.len(res))
      table.insert(ShowErrorView.textArray,i, subStr)
      ShowErrorView.tableSize=ShowErrorView.tableSize+1
   until res==nil or res==""
    self._tableView:registerScriptHandler(ShowErrorView.scrollViewDidScroll,CCTableView.kTableViewScroll)
    self._tableView:registerScriptHandler(ShowErrorView.scrollViewDidZoom,CCTableView.kTableViewZoom)
    self._tableView:registerScriptHandler(ShowErrorView.tableCellTouched,CCTableView.kTableCellTouched)
    self._tableView:registerScriptHandler(ShowErrorView.cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    self._tableView:registerScriptHandler(ShowErrorView.tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    self._tableView:registerScriptHandler(ShowErrorView.numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    self._tableView:reloadData()
end

return ShowErrorView