
require("view.BaseView")
require("view.component.EditBoxExt")
require("view.component.EditBoxExt2")
require("model.mail.Mail")



MailPopup = class("MailPopup", BaseView)

function MailPopup:ctor(flag,touchPriority)
  if touchPriority ~= nil then
    self.priority = touchPriority
  end
  local pkg = ccbRegisterPkg.new(self)

  pkg:addFunc("closeCallback",MailPopup.close)
  pkg:addFunc("deleteCallback",MailPopup.deleteCallback)
  pkg:addFunc("fetchCallback",MailPopup.fetchCallback)
  pkg:addFunc("cancelCallback",MailPopup.cancelCallback)
  pkg:addFunc("sendCallback",MailPopup.sendCallback)
  pkg:addFunc("replyCallback",MailPopup.replyCallback)
  pkg:addFunc("friendsListCallback",MailPopup.friendsListCallback)


  pkg:addProperty("node_sysMail","CCNode")
  pkg:addProperty("node_privMail","CCNode")  
  pkg:addProperty("node_writeMail","CCNode")
  pkg:addProperty("node_att","CCNode")
  pkg:addProperty("node_attachment","CCNode")
  pkg:addProperty("node_mailContent","CCNode")
  pkg:addProperty("node_listContainer","CCNode")
  pkg:addProperty("node_writeContent","CCNode")

  pkg:addProperty("label_senderName","CCLabelTTF") 
  pkg:addProperty("label_title1","CCLabelTTF")

  pkg:addProperty("label_sender3","CCLabelTTF") 
  pkg:addProperty("label_title3","CCLabelTTF")
  pkg:addProperty("label_content3","CCLabelTTF")

  pkg:addProperty("layer_friendsList","CCLayer")
  pkg:addProperty("friendImgNor","CCSprite")
  pkg:addProperty("friendImgSel","CCSprite")
  pkg:addProperty("sprite9_bg","CCScale9Sprite")
  pkg:addProperty("sprite9_listBg","CCScale9Sprite")
  pkg:addProperty("sprite9_name","CCScale9Sprite")
  pkg:addProperty("sprite9_title","CCScale9Sprite")
  pkg:addProperty("sprite9_content","CCScale9Sprite")
  pkg:addProperty("sprite9_contentBg","CCScale9Sprite")

  pkg:addProperty("bn_close1","CCMenu")
  pkg:addProperty("bn_close2","CCMenu")
  pkg:addProperty("bn_close3","CCMenu")
  pkg:addProperty("bn_close_all","CCMenu")
  pkg:addProperty("bn_fetch","CCControlButton")
  pkg:addProperty("bn_delete","CCControlButton")
  pkg:addProperty("bn_cancel","CCControlButton")
  pkg:addProperty("bn_send","CCControlButton")
  pkg:addProperty("bn_friendList","CCMenu")

  pkg:addProperty("bn_delete3","CCControlButton")
  pkg:addProperty("bn_reply","CCControlButton")

  local layer,owner = ccbHelper.load("MailPopup.ccbi","MailPopupCCB","CCLayer",pkg)
  self:addChild(layer)

  
  self:init(flag)
end


function MailPopup:init(flag)
  echo("=== MailPopup:init ===")
  
  local menuTbl = {self.bn_close1, self.bn_close2, self.bn_close3,self.bn_close_all, self.bn_delete, self.bn_fetch, 
                    self.bn_friendList, self.bn_delete3, self.bn_close3, self.bn_reply, self.bn_cancel,self.bn_send}

  self.priority = self.priority or -250                   
  for i=1, #menuTbl do 
    menuTbl[i]:setTouchPriority(self.priority-3)
  end

  self._inContentView = false  
  if flag == 1 then --open mail
    self._inContentView = true 
    
  end 
  
  self:addTouchEventListener(function(event, x, y)

                                  if event == "began" then
                                    return self._inContentView
                                  elseif event == "ended" then
                                    self:checkTouchPosition(x, y)
                                  end
                              end,
                false, self.priority-1, true)

    self:setTouchEnabled(true)

  self.bnDeltePosX = self.bn_delete:getPositionX()
  self.bnFetchPosX = self.bn_fetch:getPositionX()

  --mask layer
  self.maskLayer = Mask.new({opacity=0, priority = self.priority})
  self:addChild(self.maskLayer)  
end

function MailPopup:onExit()
  echo("=== MailPopup:onExit === ")

end 

function MailPopup:checkTouchPosition(x, y)
  local size = self.sprite9_bg:getContentSize()
  local pos = self.sprite9_bg:getParent():convertToWorldSpace(ccp(self.sprite9_bg:getPosition()))
  local scenePos = ccp(CCDirector:sharedDirector():getRunningScene():getPosition())
  local touchPos = ccp(x, y) --ccpAdd(ccp(x,y), scenePos)
  -- echo("====== touch x, y=", x, y)
  -- echo("====== pos", pos.x, pos.y, touchPos.x, touchPos.y)
  if touchPos.x < pos.x or touchPos.x > pos.x+size.width or touchPos.y < pos.y or touchPos.y > pos.y+size.height then 
    echo(" checkTouchPosition: close popup")
    self:close()
  end
end 

function MailPopup:showMailContent(mail)
  self.mail = mail
  self._inContentView = true 
  self.node_writeMail:setVisible(false)

  echo("showMailContent: sender flag =", mail:getSenderId())
  if mail:getSenderId() <= 0 then --sys mail

    self.node_sysMail:setVisible(true)
    self.node_privMail:setVisible(false)

    self.label_senderName:setString(mail:getSenderName())
    self.label_title1:setString(mail:getTitle())

    --show content str
    self.node_mailContent:removeAllChildrenWithCleanup(true)
    local viewSize = CCSizeMake(450, 225)
    local attTbl = mail:getAttachment() 
    if attTbl == nil or #attTbl == 0 then 
      viewSize = CCSizeMake(450, 225)
      self.sprite9_contentBg:setPreferredSize(CCSizeMake(474, 258))
      self.node_att:setVisible(false)
    else 
      viewSize = CCSizeMake(450, 96)
      self.sprite9_contentBg:setPreferredSize(CCSizeMake(474, 120))
      self.node_att:setVisible(true)
    end 

    local pDispInfo = RichLabel:create(mail:getContent(),"Courier-Bold",24, CCSizeMake(viewSize.width, 0),true,false)
    pDispInfo:setColor(ccc3(255,255,255))
    local textSize = pDispInfo:getTextSize()

    local ttfContainer = display.newNode()
    pDispInfo:setPosition(ccp(0, textSize.height))
    ttfContainer:addChild(pDispInfo)
    ttfContainer:setContentSize(textSize)  
  
    local scrollView = CCScrollView:create()
    scrollView:setViewSize(viewSize)
    scrollView:setContentSize(textSize)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    scrollView:setContainer(ttfContainer)
    scrollView:setTouchPriority(self.priority-2)
    scrollView:setPosition(ccp(0, -viewSize.height))
    self.node_mailContent:addChild(scrollView)
    ttfContainer:setPosition(ccp(0, scrollView:getViewSize().height - ttfContainer:getContentSize().height))
    if scrollView:getViewSize().height > ttfContainer:getContentSize().height then
      scrollView:setTouchEnabled(false)
    end


    --set button position
    if table.getn(mail:getAttachment()) == 0 then 
      self.bn_fetch:setVisible(false)
      self.bn_delete:setPositionX((self.bnFetchPosX+self.bnDeltePosX)/2)
    end

    self:showAttachList(mail:getAttachment())
  else 
    self.node_sysMail:setVisible(false)
    self.node_privMail:setVisible(true)

    self.label_sender3:setString(mail:getSenderName())
    self.label_title3:setString(mail:getTitle())
    self.label_content3:setString(mail:getContent())
  end 

  if mail:getIsNew() == true then 
    mail:setIsNew(false)
    --tell the server the mail has read
    local data = PbRegist.pack(PbMsgId.MailUpdateC2S, {id = mail:getId(),flag = 1})
    net.sendMessage(PbMsgId.MailUpdateC2S, data) 
  end  
end 

function MailPopup:showGuildWriteView(recvName)
  self._isGuildMail = true
  self._inContentView = false 

  self.node_sysMail:setVisible(false)
  self.node_privMail:setVisible(false)
  self.node_writeMail:setVisible(true)
  self.layer_friendsList:setZOrder(11)
  self.bn_friendList:setVisible(false)

  self.friendListMaxHeight = 200
  self.isShowingList = false
  self.sprite9_listBg:setVisible(false)
  self.friendImgNor:setVisible(false)
  self.friendImgSel:setVisible(false)

  self:initInputEditor(recvName)
end


function MailPopup:showWriteView(recvName)
  self._inContentView = false 

  self.node_sysMail:setVisible(false)
  self.node_privMail:setVisible(false)
  self.node_writeMail:setVisible(true)
  self.layer_friendsList:setZOrder(11)

  self.friendListMaxHeight = 200
  self.isShowingList = false
  self.sprite9_listBg:setVisible(false)
  self.friendImgNor:setVisible(true)
  self.friendImgSel:setVisible(false)

  self:initInputEditor(recvName)
end 

function MailPopup:close()
  echo(" MailPopup:close")
  MailPopup.selfObj = nil
  self:removeFromParentAndCleanup(true)
  net.unregistAllCallback(self)
end 

function MailPopup:deleteCallback()
  echo("deleteCallback")
  _playSnd(SFX_CLICK)

  local function startDelete()
    echo("=== send mail delete msg..")
    local data = PbRegist.pack(PbMsgId.MsgC2SMailRemove, {id = self.mail:getId()})
    net.sendMessage(PbMsgId.MsgC2SMailRemove, data)
    self:getParent():deleteMail(self.mail, true)
    self:close()
  end

  if table.getn(self.mail:getAttachment()) > 0 then 
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "shanchu0.png",leftSelBtn = "shanchu1.png",
                                                  text = _tr("delete attach mail?"),
                                                  leftCallBack = function() return startDelete() end})
    self:addChild(pop)

  else
    startDelete()
  end
end 

function MailPopup:checkDisplayPopToCleanBag()
  local needClean = false 
  local isEnough1 = true 
  local isEnough2 = true
  local isEnough3 = true
  local str = " "
  local attachment = self.mail:getAttachment()

  for k, v in pairs(attachment) do
    if v.itype == 6 then 
      isEnough1 = GameData:Instance():getCurrentPackage():checkItemBagEnoughSpace(1)
      str = _tr("bag is full,clean up?")
    end 
    if v.itype == 8 then 
      isEnough2 = GameData:Instance():getCurrentPackage():checkCardBagEnoughSpace(1)
      str = _tr("card bag is full,clean up?")
    end 
    if v.itype == 7 then 
      isEnough3 = GameData:Instance():getCurrentPackage():checkEquipBagEnoughSpace(1)
      str = _tr("equip bag is full,clean up?")
    end     
  end 

  if (isEnough1 == false) or (isEnough2 == false) or (isEnough3 == false) then
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",
                                                   leftSelBtn = "button-sel-zhengli.png",
                                                   text = str,
                                                   leftCallBack = function()
                                                      if isEnough1 == false then
                                                        return self:getDelegate():goToItemView()
                                                      end 
                                                      if isEnough2 == false then 
                                                        return self:getDelegate():goToCardBagView()
                                                      end
                                                      if isEnough3 == false then 
                                                        return self:getDelegate():goToEquipBagView()
                                                      end
                                                  end})
    self:getDelegate():getScene():addChild(pop,100)
    needClean = true
  end 

  return needClean
end 




function MailPopup:fetchCallback()
  _playSnd(SFX_CLICK)

  if self:checkDisplayPopToCleanBag() == false then 
    MailPopup.selfObj = self 
    
    _showLoading()
    local mailId = self.mail:getId()
    local data = PbRegist.pack(PbMsgId.MailGetAdjunctC2S, {mail = mailId})
    net.sendMessage(PbMsgId.MailGetAdjunctC2S, data)
    --self.loading = Loading:show()  
  end 
end 

function MailPopup:cancelCallback()
  self:close()
end 

function MailPopup:sendCallback()
  
  local friendsTbl = Friend:Instance():getCurrentFriend()
  if self._isGuildMail ~= true then
    if friendsTbl == nil or table.getn(friendsTbl) < 1 then 
      Toast:showString(self, _tr("receiver should be friends"), ccp(display.cx, display.cy))
      return false
    end
  end
  
  local revdName = self.inputName:getText()
  if revdName == "" then 
    echo("empty reciever name !")
    Toast:showString(self, _tr("no receiver"), ccp(display.width/2, display.height*0.4))
    return false
  end
  
  local friendId = 0
  if self._isGuildMail ~= true then
    local found = false
    for i=1, table.getn(friendsTbl) do 
      if revdName == friendsTbl[i]:getName() then 
        found = true
        friendId = friendsTbl[i]:getFriendId()
        break
      end
    end
    if found == false then 
      echo("invalid friend's nick name !")
      Toast:showString(self, _tr("receiver should be friends"), ccp(display.width/2, display.height*0.4))
      return false
    end
  end

  local titleStr = self.inputTitle:getText()
  if titleStr == "" then
    echo("empty title !")
    Toast:showString(self, _tr("pls input title"), ccp(display.width/2, display.height*0.4))
    return false
  end
  
  local titleLabel = CCLabelTTF:create(titleStr, "Courier-Bold", 24)
  if titleLabel:getContentSize().width >= 340 then 
    Toast:showString(self, _tr("title too long"), ccp(display.width/2, display.height*0.4))
    return false 
  end 
  
  local str = EditBoxExt.getOrgText(self.inputContent:getText())
  if self._isGuildMail ~= true then
    local myId = GameData:Instance():getCurrentPlayer():getId()
    local mailData = {sender = myId, reciver = friendId, content = str, title = titleStr}
    local data = PbRegist.pack(PbMsgId.MsgC2SMailToFriend, {mail = mailData})
    net.sendMessage(PbMsgId.MsgC2SMailToFriend, data)
    --self.loading = Loading:show()
  else -- send guild mail
    Guild:Instance():reqGuildMailC2S(titleStr,str)
  end
  
  Toast:showString(self, _tr("send success"), ccp(display.width/2, display.height*0.4))

  self:close()

  return true
end 

function MailPopup:replyCallback()
  self:showWriteView(self.mail:getSenderName())
end

function MailPopup:friendsListCallback()

  self:setEditorEnable(self.isShowingList)
  self.isShowingList = not self.isShowingList

  if self.isShowingList == false then 
    self.sprite9_listBg:setVisible(false)
    self.friendImgNor:setVisible(true)
    self.friendImgSel:setVisible(false)

    self.node_listContainer:removeAllChildrenWithCleanup(true)
  else 
    self.sprite9_listBg:setVisible(true)
    self.friendImgNor:setVisible(false)
    self.friendImgSel:setVisible(true)

    local friendsTbl = Friend:Instance():getCurrentFriend()
    self:showFriendsList(friendsTbl)
  end
end 


function MailPopup:showAttachList(attachArray)
  
  if attachArray == nil or (table.getn(attachArray) == 0) then 
    echo(" empty attachment")
    return
  end

  -- local function scrollViewDidScroll(view)
  -- end
  local function tableCellTouched(tableview,cell)
    local index = cell:getIdx()+1
    if index <= #attachArray then 
      local configId = attachArray[index].configId 
      TipsInfo:showTip(cell, configId, nil, ccp(50, 100)) 
    end
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.attachCellH,self.attachCellW
  end
  
  local function tableCellAtIndex(tableview, idx)
    --echo("cellAtIndex = "..idx)
    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local pos = ccp(self.attachCellW/2, self.attachCellH/2)
    local node = GameData:Instance():getCurrentPackage():getItemSprite(nil, attachArray[idx+1].iType, attachArray[idx+1].configId, attachArray[idx+1].num)
    node:setPosition(pos)
    cell:addChild(node)
 
    return cell
  end
  

  local function numberOfCellsInTableView(tableview)
    return self.attachTotalCells
  end


  self.attachCellW = 100 -- self.node_attachment:getContentSize().width/4
  self.attachCellH = self.node_attachment:getContentSize().height
  self.attachTotalCells = table.getn(attachArray)

  echo("remove old tableview")
  self.node_attachment:removeAllChildrenWithCleanup(true)

  local tableView = CCTableView:create(self.node_attachment:getContentSize())
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  tableView:setTouchPriority(self.priority-2)
  self.node_attachment:addChild(tableView)

  -- tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  tableView:reloadData()
end


function MailPopup:fetchResult(result)
  echo("---fetchResult =", result)

  self = MailPopup.selfObj

  _hideLoading()

  if result == "NO_ERROR_CODE" then 

    self.bn_fetch:setEnabled(false)

    --remove attachment from mail info
    echo("remove attachment from mail info..")
    self.mail:setAttachment(nil)
    self.node_attachment:removeAllChildrenWithCleanup(true)
  end
end

function MailPopup:initInputEditor(recvName)

  if self.inputName == nil then 
    self.inputName = UIHelper.convertBgToEditBox(self.sprite9_name,"",24,ccc3(255,255,255))
    self.inputName:setMaxLength(20)
    if self._isGuildMail ~= true then
      self.inputName:setTouchPriority(self.priority-1)
    end
    --self.inputName:registerScriptEditBoxHandler(inputNameHandler)
  end
  if recvName ~= nil then 
    self.inputName:setText(recvName)
  else 
    self.inputName:setText("")
  end

  if self.inputTitle == nil then 
    self.inputTitle = UIHelper.convertBgToEditBox(self.sprite9_title,"",24,ccc3(255,255,255))
    self.inputTitle:setMaxLength(40)
    self.inputTitle:setTouchPriority(self.priority-1)
    --self.inputTitle:registerScriptEditBoxHandler(inputTitleHandler)
  end

  if self.inputContent == nil then 
    local size = self.sprite9_content:getContentSize()
    local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
    if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then 
      self.inputContent = EditBoxExt2.converImgToEditBox(self.sprite9_content, "Courier-Bold", 24, nil, CCSizeMake(size.width, size.height-24))      
    else 
      self.inputContent = EditBoxExt.converImgToEditBox(self.sprite9_content, "Courier-Bold", 24, nil, CCSizeMake(size.width, size.height-24))
    end 
    self.inputContent:setPlaceHolder(_tr("rich_text_forbidden"))
    self.inputContent:setPlaceholderFontColor(ccc3(150, 150, 150))    
    self.inputContent:setTouchPriority(self.priority-1)
  else 
    self.inputContent:setText("")
  end
end

function MailPopup:setEditorEnable(isEnable)

  if self.inputName == nil then 
    echo("editor not open.")
    return
  end

  self.inputName:setEnabled(isEnable)
  self.inputTitle:setEnabled(isEnable)
  self.inputContent:setEnabled(isEnable)
end

function MailPopup:showFriendsList(friendsArray)


  local function tableCellTouched(tableview,cell)
    local idx = cell:getIdx()
    echo("tableCellTouched")
    if friendsArray ~= nil then 
      self:friendsListCallback()

      local name = friendsArray[idx+1]:getName()
      self.inputName:setText(name)
    end
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.friendsCellHeight,self.friendsCellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    echo("cellAtIndex = "..idx)
    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end

    local node = CCNode:create()
    local label = CCLabelTTF:create("", "Courier-Bold", 20)
    label:setAnchorPoint(ccp(0,0))
    label:setString(friendsArray[idx+1]:getName())
    label:setColor(ccc3(0,0,0))
    node:addChild(label)
    cell:addChild(node)

    return cell
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.friendsTotalCells
  end



  if friendsArray == nil or (table.getn(friendsArray) == 0) then
    echo("empty friends list data !!!")
    return
  end

  --init cell size info
  self.friendsCellWidth = self.node_listContainer:getContentSize().width
  self.friendsCellHeight = 30
  self.friendsTotalCells = table.getn(friendsArray)

  echo("remove old tableview")
  self.node_listContainer:removeAllChildrenWithCleanup(true)

  --resize listContainer's size
  local h = math.min(self.friendListMaxHeight, self.friendsCellHeight*self.friendsTotalCells)
  self.node_listContainer:setContentSize(CCSizeMake(self.friendsCellWidth, h))

  --resize list bg 's size
  local bgSize = self.sprite9_listBg:getContentSize()
  bgSize.height = math.max(150, h+60)
  self.sprite9_listBg:setContentSize(bgSize)

  --create tableview
  local tableView = CCTableView:create(CCSizeMake(self.friendsCellWidth, h))
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setTouchPriority(self.priority)
  self.node_listContainer:addChild(tableView)

  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

  tableView:reloadData()
end