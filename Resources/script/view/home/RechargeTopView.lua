require("view.BaseView")

RechargeTopView = class("RechargeTopView", BaseView)

function RechargeTopView:ctor(priority)
  RechargeTopView.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  -- pkg:addFunc("closeCallback",RechargeTopView.closeCallback)
  pkg:addFunc("rechargeCallback",RechargeTopView.rechargeCallback)
  pkg:addFunc("praiseCallback",RechargeTopView.praiseCallback)
  pkg:addFunc("fetchCallback",RechargeTopView.fetchCallback)

  pkg:addProperty("layer_mask","CCLayerColor")
  pkg:addProperty("node_playerPic","CCNode")
  pkg:addProperty("node_tips1","CCNode")
  pkg:addProperty("node_tips2","CCNode")

  pkg:addProperty("label_playerName","CCLabelTTF")
  pkg:addProperty("label_playerLevel","CCLabelBMFont")
  pkg:addProperty("label_vipLevel","CCLabelBMFont")
  pkg:addProperty("label_prePraiseCount","CCLabelTTF")
  pkg:addProperty("label_praiseCount","CCLabelTTF")
  
  -- pkg:addProperty("bn_close","CCControlButton")
  pkg:addProperty("bn_recharge","CCControlButton")
  pkg:addProperty("bn_praise","CCControlButton")
  pkg:addProperty("bn_fetch","CCControlButton")

  pkg:addProperty("sprite_bg","CCSprite")



 

  local layer,owner = ccbHelper.load("RechargeTopView.ccbi","RechargeTopViewCCB","CCLayer",pkg)
  self:addChild(layer)

  self.priority = priority or -300 

  net.registMsgCallback(PbMsgId.ReqGetLikeAwardResult, self, RechargeTopView.fetchAwardResult)
  net.registMsgCallback(PbMsgId.ReqGiveLikeResult, self, RechargeTopView.praiseResult) 
  net.registMsgCallback(PbMsgId.RechargeMaxInfo, self, RechargeTopView.updateInfo) 
  net.registMsgCallback(PbMsgId.RankInformationS2C, self, RechargeTopView.updateInfo) 
end

function RechargeTopView:onEnter()
  self:init()
  self:showInfo()
end 

function RechargeTopView:onExit()
  net.unregistAllCallback(self)
end 

function RechargeTopView:init()
  -- self.bn_close:setTouchPriority(self.priority)
  self.bn_recharge:setTouchPriority(self.priority)
  self.bn_praise:setTouchPriority(self.priority)
  self.bn_fetch:setTouchPriority(self.priority)

  self.layer_mask:addTouchEventListener(function(event, x, y)
                                          local size = self.sprite_bg:getContentSize()
                                          local pos = self.sprite_bg:convertToNodeSpace(ccp(x, y))
                                          if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
                                            self:closeCallback()
                                          end
                                          return true 
                                        end,
                                        false, self.priority+1, true)
  self.layer_mask:setTouchEnabled(true)


  --top circle anim
  local bgSize = self.sprite_bg:getContentSize()
  local imgCircle = _res(3022057)
  if imgCircle ~= nil then
    imgCircle:setPosition(ccp(bgSize.width/2, bgSize.height-70))
    local action = CCRotateBy:create(2.7, 360)
    imgCircle:runAction(CCRepeatForever:create(action))
    self.sprite_bg:addChild(imgCircle,-1)
  end 

  --top star anim
  local starAnim = _res(6010020)
  if starAnim ~= nil then 
    starAnim:setPosition(ccp(bgSize.width/2, bgSize.height-50))
    self.sprite_bg:addChild(starAnim, 10)
  end 
end 

function RechargeTopView:showInfo()
  local curTopInfo = GameData:Instance():getPlayersRank(RankEnum.Vip_Level)
  local pre_1st = Home:instance():getRechargeTopInfo() --昨天第一名
  local cur_1st = curTopInfo[1]
  local cur_2nd = curTopInfo[2]

  self.node_playerPic:removeAllChildrenWithCleanup(true)
  self.node_tips1:removeAllChildrenWithCleanup(true)
  self.node_tips2:removeAllChildrenWithCleanup(true)
  self.label_prePraiseCount:setString(_tr("recharge_praised_count"))
  --self.label_praiseCount:setPositionX(self.label_prePraiseCount:getPositionX()+self.label_prePraiseCount:getContentSize().width + 40)

  local preTopPlayer = nil
  local praiseCount = 0 
  local awardFlag = 1 
  if pre_1st == nil then 
    echo("=== pre top is empty.") 
    self.bn_praise:setEnabled(false) 
    self.bn_fetch:setEnabled(false) 
--    if cur_1st then 
--      preTopPlayer = cur_1st 
--    end 
  else 
    preTopPlayer = pre_1st.player 
    praiseCount = pre_1st.praisedCount 
    awardFlag = pre_1st.awardedFlag 
    if pre_1st.player.id == cur_1st.id then --当昨天和今天第一名为同一个人时,以最新信息为准 
      preTopPlayer = cur_1st 
    end 
  end 

  if preTopPlayer ~= nil then 
    --show player avatar
    if preTopPlayer.avatar == 1 then 
      preTopPlayer.avatar = 120502 
    end 
    local cardConfigId = preTopPlayer.avatar*100+1
    if AllConfig.unit[cardConfigId] ~= nil then 
      local resId = AllConfig.unit[cardConfigId].unit_head_pic
      local icon = _res(resId)
      if icon ~= nil then 
        icon:setScale(95/icon:getContentSize().width)
        icon:setPosition(ccp(self.node_playerPic:getContentSize().width/2, 0))
        self.node_playerPic:addChild(icon)
      end 
    end 

    --name, level  
    self.label_playerName:setString(preTopPlayer.name)
    self.label_playerLevel:setString(string.format("%d", preTopPlayer.level))
    self.label_vipLevel:setString(string.format("%d", preTopPlayer.vip_level))
    self.label_praiseCount:setString(string.format("%d", praiseCount))


    --本人与第一名充值元宝变化描述
    local player = GameData:Instance():getCurrentPlayer()
    local myVipExp = player:getVipExp()    
    local str = ""  
    
    --local cur_1st = curTopInfo[1]
    --local cur_2nd = curTopInfo[2]
    if cur_1st ~= nil then
       --自己是当前第一
      if player:getId() == cur_1st.id then
       if cur_2nd ~= nil then
         str = _tr("recharge_top_tips2_%{count}", {count = myVipExp - cur_2nd.vip_exp})
         print(cur_2nd.name)
       end
      else
       if preTopPlayer~= nil and player:getId() == preTopPlayer.id then
        str = _tr("recharge_top_tips4_%{count}", {count = cur_1st.vip_exp - myVipExp})
       else
         str = _tr("recharge_top_tips1_%{count}", {count = cur_1st.vip_exp - myVipExp})
       end      
      end
    end

--    echo(" my / top vip_exp:", myVipExp, preTopPlayer.vip_exp) 
--    if player:getId() == preTopPlayer.id then --本人是昨天第一名时
--      echo(" I am top !!!")
--      if player:getId() == cur_1st.id then --现在仍然是第一名, 则跟第二名进行比较      
--        if cur_2nd ~= nil then 
--          echo("====cur_2nd: vip_exp", vip_exp)
--          if cur_2nd.vip_exp > myVipExp then --被其他玩家超越
--            str = _tr("recharge_top_tips4_%{count}", {count = cur_2nd.vip_exp - myVipExp})
--          else 
--            str = _tr("recharge_top_tips2_%{count}", {count = myVipExp - cur_2nd.vip_exp})
--          end 
--        end
--
--      else --现在已被别人超过，则跟第一名比较
--        str = _tr("recharge_top_tips4_%{count}", {count = cur_1st.vip_exp - myVipExp})
--      end 
--      
--    else 
--      if myVipExp > preTopPlayer.vip_exp then --本人超过第一名 
--        str = _tr("recharge_top_tips3_%{count}", {count = myVipExp - preTopPlayer.vip_exp})
--      else 
--        str = _tr("recharge_top_tips1_%{count}", {count = preTopPlayer.vip_exp - myVipExp})
--      end 
--    end 

    local tips1 = RichText.new(str, self.node_tips1:getContentSize().width, 0, "Courier-Bold", 24, 0xffefa5) 
    tips1:setPosition(ccp(0, (self.node_tips1:getContentSize().height-tips1:getTextSize().height)/2)) 
    self.node_tips1:addChild(tips1) 

    --点赞或领取信息
    local coin, str2 = Home:instance():getTopRechargerBonus(preTopPlayer.level, praiseCount)
    if player:getId() == preTopPlayer.id then --本人是第一名时显示领取信息 
      self.bn_fetch:setVisible(true)
      self.bn_praise:setVisible(false) 
      self.bn_fetch:setEnabled(awardFlag == 0)

      str2 = _tr("recharge_top_tips5_%{count}", {count=coin})

    else --其他玩家显示点赞信息
      self.bn_fetch:setVisible(false)
      self.bn_praise:setVisible(true) 
      self.bn_praise:setEnabled(player:getPraisedFlag() == 0)
    end 
    
    if str2 ~= "" then 
      local tips2 = RichText.new(str2, self.node_tips2:getContentSize().width, 0, "Courier-Bold", 24, 0xffefa5)
      tips2:setPosition(ccp(0, (self.node_tips2:getContentSize().height-tips2:getTextSize().height)/2))
      self.node_tips2:addChild(tips2) 
    end 
  end 
end 

function RechargeTopView:closeCallback()
  self:removeFromParentAndCleanup(true)
end 

function RechargeTopView:rechargeCallback()
  local shopController = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
  shopController:enter(ShopCurViewType.PAY)  

  self:closeCallback()
end 

function RechargeTopView:praiseCallback()
  _showLoading()
  net.sendMessage(PbMsgId.ReqGiveLike) 
  --self.loading = Loading:show()
  self:addMaskLayer()
end 

function RechargeTopView:praiseResult(action,msgId,msg)
  echo("=== praiseResult", msg.result)
--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end 
  _hideLoading()

  if msg.result == "Success" then 
    self.bn_praise:setEnabled(false)

    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i = 1,table.getn(gainItems) do
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.cx,display.cy-i*40), 0.3*(i-1))
    end

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
  else 
    Home:instance():handleErrorCode(msg.result)
  end 
  self:removeMaskLayer()
end 

function RechargeTopView:updateInfo(action,msgId,msg) 
  echo("=== RechargeTopView:updateInfo") 
  self:performWithDelay(handler(self, RechargeTopView.showInfo), 0.5) 
end 

function RechargeTopView:fetchCallback()
  _showLoading()
  net.sendMessage(PbMsgId.ReqGetLikeAward) 
  --self.loading = Loading:show()
  self:addMaskLayer()  
end 

function RechargeTopView:fetchAwardResult(action,msgId,msg)
  echo("=== praiseResult", msg.result)
--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end 
  _hideLoading()

  if msg.result == "Success" then 
    self.bn_fetch:setEnabled(false)

    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    for i = 1,table.getn(gainItems) do
      local str = string.format("+%d", gainItems[i].count)
      Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.cx,display.cy-i*40), 0.3*(i-1))
    end

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
  else 
    Home:instance():handleErrorCode(msg.result)
  end 

  self:removeMaskLayer()
end 


function RechargeTopView:addMaskLayer()
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self.maskLayerTimer = self:performWithDelay(handler(self, RechargeTopView.removeMaskLayer), 6.0)
end 

function RechargeTopView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayerTimer then    
    self:stopAction(self.maskLayerTimer)
    self.maskLayerTimer = nil 
  end 

  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 

--  if self.loading ~= nil then 
--    self.loading:remove()
--    self.loading = nil
--  end  
  _hideLoading()
end 

