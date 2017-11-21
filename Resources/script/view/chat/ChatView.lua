require("view.component.PopModule")
require("view.chat.ChatMessageView")
ChatView = class("ChatView",PopModule)
local touchPriority = -256
function ChatView:ctor(channel,priority)
  if priority ~= nil then
    touchPriority = priority
  end
  
  local size = CCSizeMake(615,880)
  ChatView.super.ctor(self,size,touchPriority,true)
  self:setNodeEventEnabled(true)
  
  if channel == nil then
    channel = Chat.ChannelWorld
  end
  self._currentChannel =  channel
  self._messages = {}
end

function ChatView:onEnter()
   ChatView.super.onEnter(self)
   display.addSpriteFramesWithFile("chat/chat.plist","chat/chat.png")
   
   self:setTitleWithSprite(display.newSprite("#chat_pop_title.png"))
   
   local bottomBar = display.newNode()
   self:getListContainer():addChild(bottomBar)
   
   local normal = display.newSprite("#chat_btn_shijie_2.png")
   local highted = display.newSprite("#chat_btn_shijie.png")
   local disabled = display.newSprite("#chat_btn_shijie.png")
   local worldMenu,worldMenuItem = UIHelper.ccMenuWithSprite(normal,highted,disabled,
    function() self:switchChannel(Chat.ChannelWorld)
   end)
   worldMenu:setTouchPriority(touchPriority)
   bottomBar:addChild(worldMenu)
   worldMenu:setPosition(ccp(65,88))
   self._worldMenuItem = worldMenuItem
   
   local normal = display.newSprite("#chat_btn_gonghui_2.png")
   local highted = display.newSprite("#chat_btn_gonghui.png")
   local disabled = display.newSprite("#chat_btn_gonghui.png")
   local guildMenu,guildMenuItem = UIHelper.ccMenuWithSprite(normal,highted,disabled,
    function() self:switchChannel(Chat.ChannelGuild)
   end)
   bottomBar:addChild(guildMenu)
   guildMenu:setTouchPriority(touchPriority)
   guildMenu:setPositionX(normal:getContentSize().width + 65)
   guildMenu:setPositionY(88)
   self._guildMenuItem = guildMenuItem
   
   local barBg = display.newScale9Sprite("#chat_list_input_b_bg.png",0,0,CCSizeMake(575,70))
   bottomBar:addChild(barBg)
   barBg:setAnchorPoint(ccp(0,0))
   
   local normal = display.newSprite("#chat_fasong1.png")
   local highted = display.newSprite("#chat_fasong2.png")
   local disabled = display.newSprite("#chat_fasong3.png")
   local sendMenu,sendMenuItem = UIHelper.ccMenuWithSprite(normal,highted,disabled,function()
    if self._input:getText() ~= "" then
      if Guild:Instance():isRightLength(self._input:getText(),100) == false then
        Toast:showString(self, _tr("input_too_long"), ccp(display.cx, display.cy))
        return
      end
      Chat:Instance():reqChatC2S(self._input:getText(),0,self._currentChannel)
      self._input:setText("")
    end
   end)
   bottomBar:addChild(sendMenu)
   sendMenu:setTouchPriority(touchPriority)
   sendMenu:setPositionX(515)
   sendMenu:setPositionY(33)

   
   local inPutBg = display.newScale9Sprite("#chat_list_input_f_bg.png",10,10,CCSizeMake(445,50))
   barBg:addChild(inPutBg)
   inPutBg:setAnchorPoint(ccp(0,0))
   
   self._input = UIHelper.convertBgToEditBox(inPutBg,"",24,ccc3(255,255,255),false,200)
   self._input:setMaxLength(100)
   self._input:setTouchPriority(touchPriority)
   
   self:switchChannel(self._currentChannel)
   self:buildTableView()
   Chat:Instance():setChatView(self)
end

function ChatView:updateView(channel)
  if self.tableView ~= nil and channel == self._currentChannel then
    self._messages = Chat:Instance():getMessagesByChannel(self._currentChannel)
    self.tableView:reloadData()
    
    if self.tableView:getContainer():getContentSize().height > self.tableView:getViewSize().height then
      self.tableView:setContentOffset(ccp(0,0),false)
    end
    return
  end
end

function ChatView:onExit()
  ChatView.super.onExit(self)
  Chat:Instance():setHasNewMessage(false)
  CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.UPDATE_TIP)
  Chat:Instance():setChatView(nil)
end

function ChatView:switchChannel(channel)
  if channel == Chat.ChannelGuild then
    if Guild:Instance():getSelfHaveGuild() ~= true then
      Toast:showString(GameData:Instance():getCurrentScene(),_tr("not_join_guild"), ccp(display.cx, display.cy))
      return
    end
  end
  
  self._worldMenuItem:unselected()
  self._guildMenuItem:unselected()
  
  if channel == Chat.ChannelPlayer then
    
  elseif channel == Chat.ChannelWorld then
    self._worldMenuItem:selected()
  elseif channel == Chat.ChannelGuild then
    self._guildMenuItem:selected()
  end
  self._currentChannel = channel
  self:updateView(self._currentChannel)
end


function ChatView:buildTableView()
  self._messages = Chat:Instance():getMessagesByChannel(self._currentChannel)
  
  local function tableCellTouched(table,cell)
      printf("cell touched at index: " .. cell:getIdx())
   end
  
   local function cellSizeForTable(table,idx) 
      return 150,535
   end
  
   local function tableCellAtIndex(tableView, idx)
      local cell = tableView:dequeueCell()
      if nil ~= cell then
        cell:removeFromParentAndCleanup(true)
      end
      
      cell = CCTableViewCell:new()
      local item = ChatMessageView.new(self._messages[#self._messages - idx])
      item:setDelegate(tableView)
      cell:addChild(item)
      cell:setIdx(idx)
      return cell
  end
   
  local function numberOfCellsInTableView(val)
     return #self._messages
  end
  
  if self.tableView ~= nil then
    self.tableView:reloadData()
    return
  end
  
  local offsetY = 140
  local mSize = CCSizeMake(self:getCanvasContentSize().width,self:getCanvasContentSize().height - offsetY)
  local tableView = CCTableView:create(mSize)
  tableView:setVerticalFillOrder(kCCTableViewFillBottomUp)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setClippingToBounds(true)
  self:getListContainer():addChild(tableView)
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  --tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  self.tableView = tableView
  tableView:setPositionX(8)
  tableView:setPositionY(offsetY)
  tableView:setTouchPriority(touchPriority)
end

return ChatView