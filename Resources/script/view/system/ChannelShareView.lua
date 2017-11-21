
require("view.system.ChannelSharePopView")

ChannelShareView = class("ChannelShareView",BaseView)

function ChannelShareView:ctor(mSize)
  local bottomHeight=GameData:Instance():getCurrentScene():getBottomContentSize().height
  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  tableView:setPosition(ccp(0,bottomHeight))
  self:addChild(tableView)
  net.registMsgCallback(PbMsgId.ReqWechatShareResult,self,ChannelShareView.onCallback)
  --单元格被点击
  local function tableCellTouched(table,cell)
    if cell:getIdx()==0 then
       --微信分享
        local channelSharePopView = ChannelSharePopView.new(self)
        channelSharePopView:setResult({page="share"})
        self:addChild(channelSharePopView)
    end
  end

  --单元格尺寸
  local function cellSizeForTable(table,idx) 
    return 208,643
  end

  --生成单元格
  local function tableCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end
    if idx==0 then
      local share=CCSprite:create("img/settings/wechat_share_navigator.png")
      share:setAnchorPoint(ccp(0,0))
      cell:addChild(share)
      cell:setIdx(idx)
    end
    return cell
  end

  --提供单元格行数
  local function numberOfCellsInTableView(val)
       return 1
  end
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData() 
end



function ChannelShareView:onEnter()
   
end

function ChannelShareView:onExit()
  net.unregistAllCallback(self)
end

function ChannelShareView:onShareCallback()
  printf("isShared:"..GameData:Instance():getCurrentPlayer():getIsWeiXinSharedDone())
  if GameData:Instance():getCurrentPlayer():getIsWeiXinSharedDone() == 0 then
      _showLoading()
      local data = PbRegist.pack(PbMsgId.ReqWechatShare,{})
      net.sendMessage(PbMsgId.ReqWechatShare,data) 
  else
     local channelSharePopView = ChannelSharePopView.new(self) 
     channelSharePopView:setResult({page="result",coin=0})
     self:addChild(channelSharePopView)  
  end
end

function ChannelShareView:onCallback(action,msgId,msg)
  printf("ChannelShareView:onCallback,"..msg.state)
  _hideLoading()
  local channelSharePopView = ChannelSharePopView.new(self)
  if msg.state =="FistShare" then
     local preCoin = GameData:Instance():getCurrentPlayer():getCoin()
     
     local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
     for i = 1,table.getn(gainItems) do
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.5-i*40), 0.3*(i-1))
     end
    
     GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
     local curCoin = GameData:Instance():getCurrentPlayer():getCoin()
     local gainedCoin = math.max(0, curCoin-preCoin)
     channelSharePopView:setResult({page="result",coin=gainedCoin})
  else
      channelSharePopView:setResult({page="result",coin=0})
  end 
  self:addChild(channelSharePopView)  
end

return ChannelShareView



  

   

  
