
require("view.component.ViewWithEave")
require("view.component.TipPic")
require("view.mail.MailListItem")
require("view.mail.MailPopup")
require("model.mail.Mail")


CurState = enum({"NONE","MAIL_LIST","READING_MAIL"})

MailListView = class("MailListView", ViewWithEave)

function MailListView:ctor(index, recvName)
  self.super.ctor(self)
  --self:setTabControlEnabled(false)
  self:setScrollBgVisible(false)
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("writeCallback",MailListView.writeCallback)
  pkg:addFunc("quickFetchCallback",MailListView.quickFetchCallback)
  pkg:addFunc("quickDeleteCallback",MailListView.quickDeleteCallback)
  pkg:addProperty("node_list","CCNode")
  pkg:addProperty("node_quickFetch","CCNode")
  pkg:addProperty("bn_write","CCControlButton")
  pkg:addProperty("bn_quickDelete","CCControlButton")
  pkg:addProperty("bn_quickFetch","CCControlButton")
 
  local layer,owner = ccbHelper.load("MailListView.ccbi","MailListViewCCB","CCLayer",pkg)
  self:addChild(layer)

  --manul loading plist file
  -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/mail/mail.plist")

  self:setTitleTextureName("mail-title.png")

  local menuArray = {
      {"#bn_xitong0.png","#bn_xitong1.png"},
      {"#bn_geren0.png","#bn_geren1.png"}
    }
  self:setMenuArray(menuArray)

  self.viewIndex = index or 1
  self:setRecvName(recvName)
  self:getTabMenu():setItemSelectedByIndex(self.viewIndex)

  self.sysMailsMax = 100
  self.privMailsMax = 30

  self.curState = CurState.NONE
end


function MailListView:onEnter()
  echo("==MailListView:onEnter==")
  MailListView.super:onEnter()
  MailBox:instance():setView(self)
  net.registMsgCallback(PbMsgId.MsgS2CMailList,self,MailListView.updateMails)
end

function MailListView:onExit()
  echo("==MailListView:onExit==")
  MailBox:instance():setView(nil)
  net.unregistAllCallback(self)
  self.super:onExit()
  -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("img/mail/mail.plist")
end

function MailListView:init()

  local size = self:getCanvasContentSize()
  local bottomHeight = self:getDelegate():getScene():getBottomContentSize().height
  local w = size.width
  local h = size.height - 10

  self.bn_write:setPosition(ccp(640+(display.width-640)/2-90, bottomHeight+size.height+40))

  --init list
  self.node_list:setContentSize(CCSizeMake(w, h))
  self.node_list:setPosition(ccp((display.width-640)/2, bottomHeight + 10))
  self.node_quickFetch:setPosition(ccp((display.width-640)/2, bottomHeight))

  UIHelper.setIsNeedScrollList(true)
  self:showViewByIndex(self.viewIndex)
end

function MailListView:showViewByIndex(index)
  echo("MailListView:showViewByIndex:", index)
  if index == 1 then     
    self.mailArray = MailBox:instance():getValidSystemMails()
    local hasTip = MailBox:instance():getHasNewMailForPriv()
    self:getTabMenu():setTipImgVisible(1, false)
    self:getTabMenu():setTipImgVisible(2, hasTip)
  else 
    self.mailArray = MailBox:instance():getPrivateMails()
    local hasTip = MailBox:instance():getHasNewMailForSys()
    self:getTabMenu():setTipImgVisible(1, hasTip)
    self:getTabMenu():setTipImgVisible(2, false)
  end
  MailBox:instance():sortMails(self.mailArray)
  self:showMessageList(self.mailArray)  
end 

function MailListView:getMailsMax()
  if self.viewIndex == 1 then 
    return self.sysMailsMax
  end
  return self.privMailsMax
end 

function MailListView:onHelpHandler()
  echo("onHelpHandler.")
  local help = HelpView.new()
  help:addHelpBox(1028, nil, true)
  self:getDelegate():getScene():addChild(help, 1000)
end

function MailListView:onBackHandler()
  echo("MailListView:onBackHandler")
  MailListView.super:onBackHandler()

  if self.node_list:isVisible() == false then 
    UIHelper.setIsNeedScrollList(true)
    self:showMessageList(self.mailArray)
  else
    self:getDelegate():displayHomeView()
  end
end

function MailListView:tabControlOnClick(idx)
  _playSnd(SFX_CLICK)

  if self.viewIndex == idx+1 then 
    return 
  end
  self.viewIndex = idx + 1

  if idx == 0 then 
    self:showViewByIndex(self.viewIndex)
  elseif idx == 1 then 
    self:showViewByIndex(self.viewIndex)
  end
end

function MailListView:writeCallback(recvName)
  echo("writeCallback")

  local pop = MailPopup.new(2)
  pop:setDelegate(self:getDelegate())
  pop:showWriteView(recvName)
  self:addChild(pop)
end

function MailListView:setRecvName(name)
  self._recvName = name
end

function MailListView:getRecvName()
  return self._recvName
end

function MailListView:showMessageList(mailArray)
  echo("showMessageList")
  self.curState = CurState.MAIL_LIST



  -- local function scrollViewDidScroll(view)
  -- end

  local function tableCellHighLight(tableview, cell)  
    local idx = cell:getIdx()  
    if self.listItemArray[idx+1] ~= nil then 
      self.listItemArray[idx+1]:setHighlight(true)
    end
  end 

  local function tableCellUnhighLight(tableview, cell)
    local idx = cell:getIdx()  
    if self.listItemArray[idx+1] ~= nil then 
      self.listItemArray[idx+1]:setHighlight(false)
    end
  end

  local function tableCellTouched(tableview,cell)
    self.curMailIdx = cell:getIdx()
    self:openMail(self.mailArray[self.curMailIdx+1])
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    --echo("cellAtIndex = "..idx)
    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local node = MailListItem.new()
    node:setDelegate(self)
    if self.viewIndex == 1 then 
      node:setLeftTimeVisibled(true)
    else
      node:setLeftTimeVisibled(false)
    end 
    node:setMail(mailArray[idx+1])

    cell:addChild(node)
    self.listItemArray[idx+1] = node 

    if self.cellNumPerPage > 0 then 
      UIHelper.showScrollListView({object=node, totalCount=self.cellNumPerPage, index = idx})
    end 

    return cell
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end

  if mailArray == nil then
    echo("empty list data !!!")
    return
  end

  self.listItemArray = {}

  self.cellWidth = ConfigListCellWidth
  self.cellHeight = ConfigListCellHeight
  self.totalCells = math.min(self:getMailsMax(),table.getn(mailArray))

  echo("remove old tableview")
  self.node_list:removeAllChildrenWithCleanup(true)

  local w = self.node_list:getContentSize().width
  local h = self.node_list:getContentSize().height

  self.cellNumPerPage = math.ceil(h/self.cellHeight)
  if self.cellNumPerPage == 0 then 
    UIHelper.setIsNeedScrollList(false)
  end
  
  if self.totalCells == 0 then 
    self:setEmptyImgVisible(true)
  else 
    self:setEmptyImgVisible(false)
  end

  if self.viewIndex == 1 then --sys mail 
    self.node_quickFetch:setVisible(true)
    self.tableView = CCTableView:create(CCSizeMake(w,h-60))
    self.tableView:setPosition(ccp(0, 60))
  else 
    self.node_quickFetch:setVisible(false)
    self.tableView = CCTableView:create(CCSizeMake(w,h))
  end 
  self.tableView:setDirection(kCCScrollViewDirectionVertical)
  self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  self.node_list:addChild(self.tableView)

  --self.tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  self.tableView:registerScriptHandler(tableCellHighLight,CCTableView.kTableCellHighLight)
  self.tableView:registerScriptHandler(tableCellUnhighLight,CCTableView.kTableCellUnhighLight)  
  self.tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  self.tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  self.tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  self.tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  self.tableView:reloadData()

  if self:getMailWithAttachMent(mailArray) then 
    self.bn_quickFetch:setEnabled(true)
  else 
    self.bn_quickFetch:setEnabled(false)
  end
   
  if self:getMailWithNoAttachMent(self.mailArray) then 
    self.bn_quickDelete:setEnabled(true)
  else 
    self.bn_quickDelete:setEnabled(false)
  end 
end

function MailListView:updateCurCell()
  if self.tableView ~= nil and self.curMailIdx ~= nil then 
    self.tableView:updateCellAtIndex(self.curMailIdx)
  end 
end



function MailListView:openMail(mail)
  if mail == nil then 
    return 
  end

  self.curState = CurState.READING_MAIL

  local pop = MailPopup.new(1)
  pop:setDelegate(self:getDelegate())
  pop:showMailContent(mail)
  pop:setTag(100)
  self:addChild(pop)
end


function MailListView:updateMails(action,msgId,msg)
  echo("=== MailListView:updateMails ===")
  MailBox:instance():sortMails(self.mailArray)
  self:showMessageList(self.mailArray)
end

function MailListView:deleteMail(mail, isUpdateList)
  if mail ~= nil then 
    MailBox:instance():deleteMail(mail)

    if mail:getSenderId() <= 0 then --sys mail
      self.mailArray = MailBox:instance():getValidSystemMails()
    else 
      self.mailArray = MailBox:instance():getPrivateMails()
    end 
    if isUpdateList then 
      self:showMessageList(self.mailArray)
    end 
  end
end

function MailListView:getMailWithAttachMent(mailArray)
  for k, v in pairs(mailArray) do 
    if #v:getAttachment() > 0 then 
      return v 
    end 
  end 

  return 
end 

function MailListView:getMailWithNoAttachMent(mailArray)
  for k, v in pairs(mailArray) do 
    if #v:getAttachment() == 0 then 
      return v 
    end 
  end 

  return 
end 

function MailListView:quickDeleteCallback()
  echo("quickDeleteCallback")
  
  local function sendDeleteMsg()
    local mail = self:getMailWithNoAttachMent(self.mailArray)
    if mail then 
      local data = PbRegist.pack(PbMsgId.MsgC2SMailRemove, {id = mail:getId()})
      net.sendMessage(PbMsgId.MsgC2SMailRemove, data)
      self:deleteMail(mail, false) 

    else --全部删除完
      if self.deleteTimer then 
        self:unschedule(self.deleteTimer)
        self.deleteTimer = nil 
      end 
      self:showMessageList(self.mailArray)
      _hideLoading()
    end  
  end 

  if self:getMailWithNoAttachMent(self.mailArray) then 
    _showLoading()
    self.deleteTimer = self:schedule(sendDeleteMsg, 0.2)
  end 
end 

function MailListView:quickFetchCallback()
  self.curMailForFetch = self:getMailWithAttachMent(self.mailArray)
  if self.curMailForFetch then 
    _showLoading()
    echo("===start fetch...")
    local mailId = self.curMailForFetch:getId()
    local data = PbRegist.pack(PbMsgId.MailGetAdjunctC2S, {mail = mailId})
    net.sendMessage(PbMsgId.MailGetAdjunctC2S, data)
    return true 
  end 

  --已全部领取完
  return false 
end 

function MailListView:updateForFetch(result)
  echo("=== updateForFetch")

  if self:getChildByTag(100) then --在单个邮件界面领取时 
    self:getChildByTag(100):fetchResult(result)
    self:updateCurCell()
  else --批量领取时

    if self.node_quickFetch:isVisible() then 
      if self.curMailForFetch then 
        self.curMailForFetch:setAttachment(nil)
        self.curMailForFetch:setIsNew(false)
        self:updateCurCell()
      end 

      if self:quickFetchCallback() == false then --已全部领取完
        _hideLoading()

        self:showMessageList(self.mailArray)
      end 
    end 
  end 
end 
