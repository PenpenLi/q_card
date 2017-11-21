require("view.BaseView")
require("view.notice.login_notice.LoginNoticeItem")
require("view.notice.login_notice.LoginNoticeDetailView")

LoginNoticeView = class("LoginNoticeView",BaseView)
local viewSize = CCSizeMake(455,530)

function LoginNoticeView:ctor()
  self:setNodeEventEnabled(true)
  self:setTouchEnabled(true)
  self._isDragging = false
  self._touchEnabled = false
  self._listOpenEnabled = false
  --self._datas = {}
  --build temp data
--  for i= 1, 15 do
--    local data = {}
--    data.title = "Notice Title "..i
--    data.content = i.." Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title Notice Title "
--    table.insert(self._datas,data)
--  end
  
  GameData:Instance():getCurrentScene():setLoginNoticeView(self)
  self:addTouchEventListener(handler(self,self.onTouch),false, -300, true)
  --self:addTouchEventListener(handler(self,self.onTouch))
end

function LoginNoticeView:buildPicList()
  local function scrollViewDidScroll(view)
    --print("scrollViewDidScroll")
  end
  
  local function scrollViewDidZoom(view)
      print("scrollViewDidZoom")
  end
  
  local function tableCellTouched(table,cell)
      print("cell touched at index: " .. cell:getIdx())
      self._currentPage = cell:getIdx() + 1
      local targetX = -display.width*(self._currentPage - 1)
      transition.execute(self._listsViewCon, CCMoveTo:create(0.25,ccp(targetX,self._listsViewCon:getPositionY())),
       {
          onComplete = function()
             self._isDragging = false
              for key, point in pairs(self._gradeArr) do
                   point:unselected()
              end
              self._gradeArr[self._currentPage]:selected()
              self._listOpenEnabled = true
          end,
       })
       
       self._listsViewCon:setVisible(true)
       self._gradeContainer:setVisible(true)
       self._tableView:removeFromParentAndCleanup(true)
       self._tableView = nil
       

   end
  
   local function cellSizeForTable(table,idx) 
      return 175,458
   end
  
   local function tableCellAtIndex(tableView, idx)
      
      local cell = tableView:dequeueCell()
      if nil == cell then
        cell = CCTableViewCell:new()  
      else
        cell:removeAllChildrenWithCleanup(true)
        cell:reset()
      end
      
      local bannerId = 0
      local type = 0
      if self._allData[idx+1] ~= nil and self._allData[idx+1].type ~= nil then
        type = toint(self._allData[idx+1].type)
      end
      print("Notice type:",type)
      
      
       
  
--  assert(AllConfig.system_notice ~= nil,"sys_notice is nil")
--  for key, notice in pairs(AllConfig.system_notice) do
--    print("NN_key:",key)
--    print("res:",notice.res)
--    print("title_res:",notice.title_res)
--    
--  end
--  assert(false)
      
      if AllConfig.system_notice[type] ~= nil then
         bannerId = AllConfig.system_notice[type].res
      else
         bannerId = 3039004
      end
      
      local banner = _res(bannerId)
      if banner ~= nil then
        banner:setAnchorPoint(ccp(0,0))
        cell:setIdx(idx)
        cell:addChild(banner)
      end
      return cell
  end
  
  local function numberOfCellsInTableView(val)
     return self._totalPages
  end

  local tableView = CCTableView:create(viewSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  tableView:setPosition(ccp(display.cx - viewSize.width/2,display.cy - viewSize.height/2 + 25))
  tableView:setTouchPriority(-320)
  
  --tableView:setBounceable(false)
  self:addChild(tableView,100)
  --registerScriptHandler functions must be before the reloadData function
  tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  self._tableView = tableView
end

function LoginNoticeView:onEnter()
  display.addSpriteFramesWithFile("login_notice/login_notice.plist", "login_notice/login_notice.png")
  self._resAdded = true
  --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,125), display.width, display.height)
  self:addChild(layerColor)
  local bg = display.newSprite("#login_notice_bg_large.png")
  self:addChild(bg)
  bg:setPosition(ccp(display.cx,display.cy))
  
  local maskSize = CCSizeMake(455,710)
  local mask = DSMask:createMask(maskSize)
  self:addChild(mask)
  mask:setPosition(ccp(display.cx - maskSize.width/2,display.cy -maskSize.height/2))
  
  local allcon = display.newNode()
  mask:addChild(allcon)
  allcon:setPosition(ccp(-display.cx + maskSize.width/2,-display.cy + maskSize.height/2))
  
  local listsViewCon = display.newNode()
  allcon:addChild(listsViewCon)
  self._listsViewCon = listsViewCon
  self._listsViewCon:setVisible(false)
  
  
  self._currentPage = 1
  self._pagesView = {} 
  
  self:performWithDelay(function()
    _hideLoading()
    local pop = PopupView:createTextPopup(_tr("connect_and_load_notice_fail"), function() 
      Guide:Instance():setGuideLayerTouchEnabled(true)
      self._resAdded = false
      self:removeFromParentAndCleanup(true)
      return  
    end,true)
    pop:setTouchCloseEnable(false)
    GameData:Instance():getCurrentScene():addChildView(pop)
  end,8)
  
  local function buildLists(httpRequest,isSuccess,body,header,status,error) 
      _hideLoading() 
      self:stopAllActions()
      print("httpRequest:",httpRequest)
      print("isSuccess:",isSuccess)
      --print("body:",body)
      print("header",header)
      print("status",status)
      print("error",error)
      
      if self._resAdded ~= true then
         return
      end
      --enter btn
      local nor = display.newSprite("#login_notice_enter_btn_nor.png")
      local sel = display.newSprite("#login_notice_enter_btn_sel.png")
      local dis = display.newSprite("#login_notice_enter_btn_sel.png")
      
      if nor == nil or sel == nil or dis == nil then
        return
      end
      
      local btn = UIHelper.ccMenuWithSprite(nor,sel,dis,function() self:removeFromParentAndCleanup(true) end)
      if btn == nil then
        return
      end
      
      self:addChild(btn)
      btn:setTouchPriority(-300)
      btn:setPosition(ccp(display.cx,display.cy -410 + 95))
      
      if isSuccess == false then
         local pop = PopupView:createTextPopup(_tr("connect_and_load_notice_fail"), function() Guide:Instance():setGuideLayerTouchEnabled(true) return  end,true)
         GameData:Instance():getCurrentScene():addChildView(pop)
         return
      end
      
      local str = body
      local jsonData = JSON.decode(str)
      
      local all_data = jsonData.login_notice
      self._allData = all_data
      
      self._totalPages = #all_data
      
      local n_idx = 1
      for key, notice_data in pairs(all_data) do
--      	print("type:",notice_data.type)
--      	local notice = notice_data.notice
--      	for key, m_notice in pairs(notice) do
--      		  print("title:",m_notice.title)
--      		  print("content:",m_notice.content)
--      	end

        local page = self:buildListView(notice_data)
        listsViewCon:addChild(page)
        page:setPositionX(display.width*(n_idx-1))
        self._pagesView[n_idx] = page
        n_idx = n_idx + 1
      end
      
      self._touchEnabled = true
--      for i= 1, self._totalPages do
--        local page = self:buildListView()
--        page.data = 
--        listsViewCon:addChild(page)
--        page:setPositionX(display.width*(i-1))
--        self._pagesView[i] = page
--      end

      --pic list
      self:buildPicList()

    
      --create points
      local gradeContainer = CCMenu:create()
      self:addChild(gradeContainer)
      
      self._gradeArr = {}
      for i = 1, self._totalPages do
        local gradeSelectItem = CCMenuItemImage:create()
        local nor_frame =  display.newSpriteFrame("login_notice_page_item_sel.png")
        local disabled_frame = display.newSpriteFrame("login_notice_page_item_nor.png")
        gradeSelectItem:setNormalSpriteFrame(nor_frame)
        gradeSelectItem:setSelectedSpriteFrame(disabled_frame)
        gradeSelectItem:setDisabledSpriteFrame(disabled_frame)
        gradeContainer:addChild(gradeSelectItem)
        --gradeSelectItem:registerScriptTapHandler(handler(self,self.onClickGradeSwitch))
        gradeSelectItem:setPositionX(35*(i-1))
        gradeSelectItem.index = i
        self._gradeArr[i] = gradeSelectItem
      end
      gradeContainer:setPosition(ccp(display.cx - 35*(self._totalPages-1)/2,display.cy - 530/2))
      if #self._gradeArr > 0 then
        self._gradeArr[1]:selected()
      end
      
      self._gradeContainer = gradeContainer
      self._gradeContainer:setVisible(false)
      
  end  
  
  _showLoading()
  local request = CCLuaHttpRequest:create()
  request:setUrl(LOGIN_NOTICE_URL)
  --request:setTag(tag)
  request:setRequestType(CCHttpRequest.kHttpGet)
  request:setResponseScriptCallback(buildLists)
  CCHttpClient:getInstance():send(request)
  request:release()
  
end

function LoginNoticeView:buildListView(notice_data)
  
  local data = notice_data.notice

  local con = display.newNode()
  con:setAnchorPoint(ccp(0,0))
 
  local listItemArray = {}
  
  local listContent = display.newNode()
  listContent:setAnchorPoint(ccp(0,0))
  
  local detail = LoginNoticeDetailView.new()
  listContent:addChild(detail)
  detail:setPositionX(detail:getContentSize().width/2 + 10)
  detail:setVisible(false)
  
  local totalNum = #data
  local item = nil
  for i= 1, totalNum do
    item = LoginNoticeItem.new()
    item:setIndex(i)
    listContent:addChild(item)
    item:setLabelText(data[i].title)
    item:setState(data[i].state)
    item:setPositionX(item:getContentSize().width/2)
    item:setPositionY(item:getContentSize().height*(i-1) + item:getContentSize().height/2)
    table.insert(listItemArray,item)
  end
  listContent:setContentSize(CCSizeMake(item:getContentSize().width,item:getContentSize().height*totalNum))
  
  local scrollView =  CCScrollView:create()
  con:addChild(scrollView)
  scrollView:setViewSize(viewSize)
  
  scrollView:setDirection(kCCScrollViewDirectionVertical)
  scrollView:setClippingToBounds(true)
  scrollView:setBounceable(true)
  scrollView:setDelegate(self)
  scrollView:setContainer(listContent)
  scrollView:setPosition(ccp(display.cx - viewSize.width/2,display.cy - viewSize.height/2 + 25))
  scrollView:setTouchPriority(-300)
  
  -- scroll to top
  listContent:setPosition(ccp(0, viewSize.height - listContent:getContentSize().height))
  scrollView:setContentSize(listContent:getContentSize())

  self._itemHeight = item:getContentSize().height
  
  con.listItemArray = listItemArray
  con.detail = detail
  con.scrollView = scrollView
  con.data = data
  con.listContentSize = listContent:getContentSize()
  
  --title 
  local type = toint(notice_data.type)
  local titleId = AllConfig.system_notice[type].title_res
  local title = _res(titleId)
  con:addChild(title)
  title:setPosition(ccp(display.width/2,display.cy + viewSize.height/2 + title:getContentSize().height + 18 ))

  return con
end

function LoginNoticeView:onTouch(event, x,y)
  
  if self._touchEnabled == false then
     return true
  end
  
  if self._listOpenEnabled == false then
     return true
  end

  if event == "began" then
    self._startX = x
    self._startY = y
    self._oldX = x
    return true
  elseif event == "moved" then
    if self._isDragging == false then
      if math.abs(x - self._oldX) > 10 and math.abs(y - self._startY) < 10 then
         self._isDragging = true
      end
    else
       local m_offset = x - self._oldX
       if self._currentPage == 1 or self._currentPage == self._totalPages then
          m_offset = m_offset/2
       end
       self._listsViewCon:setPositionX(self._listsViewCon:getPositionX() + m_offset)
    end
    self._oldX = x
  elseif event == "ended" then
       if math.abs(self._startX - x) > 25 and self._isDragging == true then
          if x > self._startX then
            self._currentPage = self._currentPage -1
            if self._currentPage < 1 then
               self._currentPage = 1
            end
          else
            self._currentPage = self._currentPage + 1
            if self._currentPage > self._totalPages then
               self._currentPage = self._totalPages
            end
          end
          --self._listsViewCon:runAction(CCMoveTo:create(0.15,ccp(-display.width*(self._currentPage - 1),self._listsViewCon:getPositionY())))  
          local targetX = -display.width*(self._currentPage - 1)
          transition.execute(self._listsViewCon, CCMoveTo:create(0.25,ccp(targetX,self._listsViewCon:getPositionY())),
           {
              onComplete = function()
                 self._isDragging = false
                  for key, point in pairs(self._gradeArr) do
                       point:unselected()
                  end
                  self._gradeArr[self._currentPage]:selected()
              end,
           })
           
           
          return
       end
  
       if math.abs(self._startY - y) > 15 then
          return
       end
       
       
       local pageListItemArr = self._pagesView[self._currentPage].listItemArray
       local detailView = self._pagesView[self._currentPage].detail
       local scrollView = self._pagesView[self._currentPage].scrollView
       local listContent = scrollView:getContainer()
       local listContentSize = self._pagesView[self._currentPage].listContentSize
       local targetItem = UIHelper.getTouchedNode(pageListItemArr,x,y)
       local data = self._pagesView[self._currentPage].data
       if targetItem ~= nil then
          print(targetItem:getIndex())
          if targetItem:getIsOpened() == true then
             targetItem:setIsOpened(false)
             detailView:setVisible(false)
             for key, item in pairs(pageListItemArr) do
                item:setIsOpened(false)
                --item:runAction(CCMoveTo:create(0.01,ccp(item:getPositionX(),item:getContentSize().height*(item:getIndex()-1)+self._itemHeight/2)))
                item:setPositionY(item:getContentSize().height*(item:getIndex()-1) + self._itemHeight/2)
             end
             listContent:setContentSize(listContentSize)
             scrollView:setContentSize(listContentSize)
             if listContent:getPositionY() < scrollView:getViewSize().height - listContent:getContentSize().height then
                 listContent:setPositionY(scrollView:getViewSize().height - listContent:getContentSize().height)
             end
          else
             targetItem:setIsOpened(true)
             detailView:setLabelText(data[targetItem:getIndex()].content)
             detailView:setVisible(false)
             detailView:setPositionY(targetItem:getContentSize().height*(targetItem:getIndex() - 1) + detailView:getContentSize().height/2)
             for key, item in pairs(pageListItemArr) do
             	   item:stopAllActions()
             	   if item:getIndex() >= targetItem:getIndex() then
             	      item:setPositionY(item:getContentSize().height * (item:getIndex() - 1) + self._itemHeight/2 + detailView:getContentSize().height) 
             	   else
             	      item:setPositionY(item:getContentSize().height * (item:getIndex() - 1) + self._itemHeight/2)
             	   end
             end
             
             local t_size = CCSizeMake(listContentSize.width,listContentSize.height + detailView:getContentSize().height)
             listContent:setContentSize(t_size)
             scrollView:setContentSize(t_size)
             detailView:setVisible(true)
             listContent:setPositionY(-((targetItem:getIndex()*self._itemHeight + detailView:getContentSize().height) - scrollView:getViewSize().height))
          end
          
          if scrollView:getViewSize().height > listContent:getContentSize().height then
            listContent:setPositionY(viewSize.height - listContent:getContentSize().height)
          end
          
       end
   
  end
end

function LoginNoticeView:onExit()
  --[[if self:getDelegate() ~= nil then
     self:getDelegate():addMaskLayer()
     self:getDelegate():delayTrigger()
  end]]
  display.removeSpriteFramesWithFile("login_notice/login_notice.plist", "login_notice/login_notice.png")
  self._resAdded = false
  GameData:Instance():getCurrentScene():setLoginNoticeView(nil)
end

return LoginNoticeView