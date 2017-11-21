
require("view.BaseView")

AchievementListCellView = class("AchievementListCellView",BaseView)
local CurViewTag = enum({"NULL","FRIEND_LIST","APPLY_FRIEND","RECOMMEND_FRIEND"})

function AchievementListCellView:ctor()

	AchievementListCellView.super.ctor(self)

	local pkg = ccbRegisterPkg.new(self)
	pkg:addFunc("rewardCallBack",AchievementListCellView.rewardCallBack)
	pkg:addFunc("gotoCallback",AchievementListCellView.gotoCallback)
	pkg:addProperty("node_bonus","CCNode")
	pkg:addProperty("label_title","CCLabelTTF")
	pkg:addProperty("label_desc","CCLabelTTF")
	pkg:addProperty("label_preProgress","CCLabelTTF")
	pkg:addProperty("label_progress","CCLabelTTF")
	pkg:addProperty("yiwancheng","CCSprite")
	pkg:addProperty("vipNote","CCSprite")
	pkg:addProperty("arrowLeft","CCSprite")
	pkg:addProperty("arrowRight","CCSprite")
	pkg:addProperty("bn_goto","CCMenu")
	pkg:addProperty("bn_reward","CCMenu")

	local layer,owner = ccbHelper.load("AchievementListCellView.ccbi","AchievementListViewCCB","CCLayer",pkg)
	self:addChild(layer)

	self._isVipList = false

	self.label_preProgress:setString(_tr("ach_progress"))
end

function AchievementListCellView:onEnter()
	if self:getIdx() ~= nil and self:getIdx() == 0 then 
		_registNewBirdComponent(120001, self.bn_reward)
		_executeNewBird() 		
	end 
end 

function AchievementListCellView:onExit()
end

function AchievementListCellView:setData(data)
	self.data = data
end 

function AchievementListCellView:updateInfos()
	if self.data == nil then 
		return 
	end 
  
	self.label_title:setString(self.data:getName())
	self.label_desc:setString(self.data:getDesc())
	local isVip = GameData:Instance():getCurrentPlayer():isVipState()

	if self.data:getIsFinish() == true then
		self.bn_reward:setVisible(self.data:getIsAwarded() == false) --领取
		self.yiwancheng:setVisible(self.data:getIsAwarded() == true)
		self.bn_goto:setVisible(false)
		self.vipNote:setVisible(false)

    self.label_progress:setString(self.data:getAchTotalProgress() .."/" .. self.data:getAchTotalProgress())
		self.label_progress:setColor(ccc3(32,143,00))
	else
		self.bn_reward:setVisible(false)
		self.yiwancheng:setVisible(false)
		self.bn_goto:setVisible(self._isVipList==false or (self._isVipList and isVip))
		self.vipNote:setVisible(self._isVipList and isVip==false)
		
    self.label_progress:setString(self.data:getAchProgress() .."/" .. self.data:getAchTotalProgress())
		self.label_progress:setColor(ccc3(201,1,1))
	end

	self:showBonusList(self.data:getBonus())
end

function AchievementListCellView:rewardCallBack()
  if self:getDelegate():getIsValidTouch() then 
    self:getDelegate():setIsValidTouch(false)

  	self.bn_reward:setVisible(false)
  	self.yiwancheng:setVisible(true)
  	
    local array = CCArray:create()
  	local expandAction = CCScaleTo:create(0.1, 1.2, 0.9);
  	local shrinkAction = CCScaleTo:create(0.05,1.0,1.0);
  	array:addObject(expandAction)
    array:addObject(shrinkAction)

  	local action = CCSequence:create(array)
  	self.yiwancheng:runAction(action)
  	
    self:getDelegate():fetchBonusReq(self:getIdx(), self.data:getAchievementId())
  end 
end

function AchievementListCellView:gotoCallback()
  echo("====getIsValidTouch")
  if self:getDelegate():getIsValidTouch() then 
    self:getDelegate():setIsValidTouch(false)  

    if self.data and self.bn_goto:isVisible() then 
      GameData:Instance():gotoViewByJumpType(self.data:getJumpTypeVal())
    end 
  end 
end 

function AchievementListCellView:setIsVipList(isVipList)
	self._isVipList =  isVipList
end

function AchievementListCellView:setIdx(idx)
	self._idx = idx 
end 	

function AchievementListCellView:getIdx()
	return self._idx
end 


function AchievementListCellView:showBonusList(dropDatas)

	local function tableCellTouched(tblView,cell)
		local idx = cell:getIdx()
    local itype = dropDatas[idx+1].array[1]
    local configId = dropDatas[idx+1].array[2]
    local x = idx*self.cellWidth + tblView:getContentOffset().x + self.cellWidth/2
    if itype == 20 then --将魂
      configId = itype
    end 
    TipsInfo:showTip(self.node_bonus, configId, nil, ccp(x, self.cellHeight+10)) 
	end

  local function cellSizeForTable(tblView,idx)
    return self.cellHeight,self.cellWidth
  end

  local function tableCellAtIndex(tblView, idx)
    local cell = tblView:cellAtIndex(idx)
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local itemInfo = dropDatas[idx + 1].array
    local node = GameData:Instance():getCurrentPackage():getItemSprite(nil, itemInfo[1], itemInfo[2], itemInfo[3])
    if node then 
    	node:setScale(self.cellHeight/95)
    	node:setPosition(ccp(self.cellWidth/2, self.cellHeight/2))
    	cell:addChild(node)
    end 

    return cell
  end

  local function numberOfCellsInTableView(tblView)
    return self.totoalCells 
  end

  local size = self.node_bonus:getContentSize()
  self.cellWidth = size.height  
  self.cellHeight = size.height  
  self.totoalCells = #dropDatas 

  local visibleCells = math.floor(size.width/self.cellWidth)
  self.arrowLeft:setVisible(self.totoalCells > visibleCells)
  self.arrowRight:setVisible(self.totoalCells > visibleCells)

  self.node_bonus:removeAllChildrenWithCleanup(true) 
  
  local tableView = CCTableView:create(size)
  self.node_bonus:addChild(tableView)
  --tableView:setTouchPriority(-999)
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
end

return AchievementListCellView
