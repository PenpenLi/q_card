require("view.card_flash_sale.CardFlashSalePreview")
CardFlashDetailView = class("CardFlashDetailView",ViewWithEave)
local lotteryNoticeTable = {}
local rewardCardTable = {}      --抽卡获得的卡牌
local rewardCardChipTable = {}  --抽卡获得的卡牌转换为相应碎片
local animIsFinish = true
local isFreeStatus = false

local function formatTime(time)
  local hour = 0
  local min  = 0
  local sec  = 0
  if time >0 then
    hour = math.floor(time/3600)
    min = math.floor((time - hour * 3600) / 60)
    sec = math.floor((time - hour * 3600)%60)
  end 
  return hour,min,sec
end

function CardFlashDetailView:ctor(configIds)
  CardFlashDetailView.super.ctor(self)
  self:setNodeEventEnabled(true)
  self._configIds = configIds
  self._cardParts = {}
  
  local curScene = GameData:Instance():getCurrentScene()
  self._popupNode = curScene:getChildByTag(POPUP_NODE_ZORDER)
  assert(self._popupNode ~= nil)
  if self._popupNode == nil then
    self._popupNode = display.newNode()
    curScene:addChild(self._popupNode,1999,POPUP_NODE_ZORDER)
  end
end

function CardFlashDetailView:onBackHandler()
  CardFlashDetailView.super.onBackHandler(self)
  local te = CardFlashSaleView.new()
  GameData:Instance():getCurrentScene():replaceView(te)
end

function CardFlashDetailView:onTouch(event,x,y)
  if event == "began" then
    return true
  elseif event == "ended" then
    print("ended")
    local target = UIHelper.getTouchedNode(self._cardParts,x,y)
    if target ~= nil then
      print(target.configId)
      TipsInfo:showTip(target,target.configId,nil, ccp(0,45))
    end
  end
end

function CardFlashDetailView:onEnter()
	CardFlashDetailView.super.onEnter(self)
	display.addSpriteFramesWithFile("card_flash_sale/card_flash_sale.plist", "card_flash_sale/card_flash_sale.png")
	
	local bg = display.newSprite("card_flash_sale/card_flash_sale_bg.png")
	self:getEaveView():getNodeContainer():addChild(bg)
	bg:setPosition(ccp(display.cx,display.cy))
	
	net.registMsgCallback(PbMsgId.GreatDrawCardResultS2C,self,CardFlashDetailView.onGreatDrawCardResultS2C)
	
	self:setTabControlEnabled(false)
  self:setTitleTextureName("xianshidianjiang_dianjiangtai_title.png")
  
  self:getEaveView().btnHelp:setVisible(false)
  
  local itemsContainer = display.newNode()
  self:addChild(itemsContainer)
  itemsContainer:setPositionX(display.cx)
  local bottomSize = GameData:Instance():getCurrentScene():getBottomContentSize()
  --local topSize = GameData:Instance():getCurrentScene():getTopContentSize()
  local canvasSize = self:getCanvasContentSize()
  itemsContainer:setPositionY(bottomSize.height + canvasSize.height/2)
  
  --effect
  -- 1 pos 2 scale 3 alpha 4 zoder
  local pos_scale_fixs = {
    {ccp(0,0),1,255,4},
    {ccp(-250,0),0.8,100,3},
    {ccp(0,0),0.5,0,1},
    {ccp(250,0),0.8,100,2}
  }
  
  local cardsView = {}
  
  for i = 1, #self._configIds do
    local configId = self._configIds[i]
    local pId = AllConfig.unit[configId].unit_pic
    local p = _res(pId)
    p:setCascadeOpacityEnabled(true)
    itemsContainer:addChild(p)
    
    table.insert(cardsView,p)
    
    p:setPosition(pos_scale_fixs[i][1])
    p:setScale(pos_scale_fixs[i][2])
    p:setOpacity(pos_scale_fixs[i][3])
    p:setZOrder(pos_scale_fixs[i][4])
    
    if i == 1 then
      local move = CCMoveBy:create(1.5, ccp(0, 30))
      local move1 = CCMoveBy:create(1.5, ccp(0, -30))
      local action = CCSequence:createWithTwoActions(move,move1)
      p:runAction(CCRepeatForever:create(action)) 
    end
  end
  
  local idx = 1
  local sweepCard = function()
    idx = idx + 1
    if idx > #self._configIds then
      idx = 1
    end
    
    local posIdx = 1
    for i = idx, #self._configIds + idx -1 do
      if i > #self._configIds then
        i = i - #self._configIds
      end
      local p = cardsView[i]
      --print("posIdx:",posIdx)
      
      p:stopAllActions()
      
      local array = CCArray:create()
      local dur = 0.25
      local move = CCMoveTo:create(dur,pos_scale_fixs[posIdx][1])
      local scale = CCScaleTo:create(dur,pos_scale_fixs[posIdx][2])
      local fade = CCFadeTo:create(dur,pos_scale_fixs[posIdx][3])
      local moveAndScaleAndFade = CCSpawn:createWithTwoActions(move,CCSpawn:createWithTwoActions(scale,fade))
      array:addObject(moveAndScaleAndFade)
      
      if i == idx then
        local move = CCMoveBy:create(1.5, ccp(0, 30))
        local move1 = CCMoveBy:create(1.5, ccp(0, -30))
        local action = CCSequence:createWithTwoActions(move,move1)
        array:addObject(action)
      end
            
--      p:setPosition(pos_scale_fixs[posIdx][1])
--      p:setScale(pos_scale_fixs[posIdx][2])
--      p:setOpacity(pos_scale_fixs[posIdx][3])
      p:setZOrder(pos_scale_fixs[posIdx][4])
      
      local action = CCSequence:create(array)
      p:runAction(action)
      posIdx = posIdx + 1
    end
  end
  
  
  local action = self:schedule(sweepCard, 2.5)
  
  local configId = self._configIds[1]
  local country = AllConfig.unit[configId].country1
  self._country = country

  local resStr = "#xianshidianjiang_title"..country..".png"
  local title = display.newSprite(resStr)
  if title then
    self:addChild(title) 
    title:setPositionX(display.cx)
    title:setPositionY(bottomSize.height + canvasSize.height - title:getContentSize().height/2 + 55)
  end
  
  --preview btn
  --
  
  local previewHandler = function()
    local cardFlashSalePreview = CardFlashSalePreview.new(self._country)
    GameData:Instance():getCurrentScene():addChildView(cardFlashSalePreview)
  end
  
  local normal,sel,dis
  normal = display.newSprite("#xianshidianjiang_btn_preview.png")
  sel = display.newSprite("#xianshidianjiang_btn_preview1.png")
  dis = display.newSprite("#xianshidianjiang_btn_preview1.png")
  local preViewBtn = UIHelper.ccMenuWithSprite(normal,sel,dis,previewHandler)
  self:addChild(preViewBtn) 
  preViewBtn:setPositionX(display.width - normal:getContentSize().width - 10)
  preViewBtn:setPositionY(bottomSize.height + canvasSize.height - title:getContentSize().height/2)
    
  local createBtn = function(cost,type)
    local node = display.newNode()
    --cost bg 
    local bg = display.newSprite("#xianshidianjiang_kuang.png")
    bg:setAnchorPoint(ccp(0,0.5))
    node:addChild(bg)
    bg:setPositionX(-85)
    
    local moneyIcon = display.newSprite("#playstates-image-yuanbao.png")
    bg:addChild(moneyIcon)
    moneyIcon:setPosition(ccp(95,15))
    
    --label cost
    local labelCost = CCLabelTTF:create(_tr("pre_cost_desc"), "Courier-Bold",22)
    labelCost:setAnchorPoint(ccp(1,0.5))
    bg:addChild(labelCost)
    labelCost:setPosition(ccp(70,20))
    
    --label cost value
    local labelCost = CCLabelTTF:create(cost.."", "Courier-Bold",22)
    bg:addChild(labelCost)
    labelCost:setPosition(ccp(138,20))
    
    if type == nil then
      self._labelOnceCost = labelCost
      local labelFree = CCLabelTTF:create(cost.."", "Courier-Bold",22)
      labelFree:setAnchorPoint(ccp(0.5,0.5))
      labelFree:setPositionY(115)
      labelFree:enableStroke(ccc3(0,0,0),2,true)
      self._labelFree = labelFree
      node:addChild(labelFree)
    end
    
    local normal,sel,dis
    if type == nil then
      normal = display.newSprite("#xianshidianjiang_dianjiangyici_0.png")
      sel = display.newSprite("#xianshidianjiang_dianjiangyici_1.png")
      dis = display.newSprite("#xianshidianjiang_dianjiangyici_1.png")
    else
    
      normal = display.newSprite("#xianshidianjiang_dianjiangshici_0.png")
      sel = display.newSprite("#xianshidianjiang_dianjiangshici_1.png")
      dis = display.newSprite("#xianshidianjiang_dianjiangshici_1.png")
      local saleIcon = display.newSprite("#xianshidianjiang_zhekou.png")
      normal:addChild(saleIcon)
      saleIcon:setPosition(ccp(20,55))
    end
    
    local callBack = function()
       if type ~= nil then
          print("ten clicked")
          if self._tenCost > GameData:Instance():getCurrentPlayer():getMoney() then
            GameData:Instance():notifyForPoorMoney()
            return
          end
          self:drawCardTence()
       else
          print("one clicked")
          if isFreeStatus ~= true and self._onceCost > GameData:Instance():getCurrentPlayer():getMoney() then
            GameData:Instance():notifyForPoorMoney()
            return
          end
          self:drawCardOnce()
       end
    end
 
    local menu = UIHelper.ccMenuWithSprite(normal,sel,dis,callBack)
    node:addChild(menu)
    menu:setPosition(ccp(0,65))
    
    return node
  end
  
  local onceCost = 9999
  local tenCost = 9999
  local replaceCount = 10
  for key, var in pairs(AllConfig.greatbonus) do
  	if var.country == country and var.drop_count == 10 then
  	 tenCost = var.cost
  	elseif var.country == country and var.drop_count == 1 then
  	 onceCost = var.cost
  	 replaceCount = var.replace_count
  	end
  end
  
  
  
  self._onceCost = onceCost
  self._tenCost = tenCost
  self._replaceCount = replaceCount
  
  --btn left
  local leftBtn = createBtn(onceCost)
  self:addChild(leftBtn)
  leftBtn:setPositionX(display.cx - 160)
  leftBtn:setPositionY(bottomSize.height + 15)
  
  --btn right 
  local rightBtn = createBtn(tenCost,1)
  self:addChild(rightBtn)
  rightBtn:setPositionX(display.cx + 160)
  rightBtn:setPositionY(bottomSize.height + 15)
  
  --count tip
  print(GameData:Instance():getCurrentPlayer():getDrawCardGreatCount())
  --assert(false)
  
  local tipBg = display.newSprite("#xianshidianjiang_zaichou.png")
  self:addChild(tipBg)
  tipBg:setPositionX(display.cx)
  tipBg:setPositionY(bottomSize.height + 180)
  self._tipBg = tipBg
    
  self:updateView()
  
end

function CardFlashDetailView:drawCardOnce()
  _showLoading()
  
  self._drawType = "itemOne"
          
  local configId = 0
  for key, var in pairs(AllConfig.greatbonus) do
    if var.country == self._country and var.drop_count == 1 then
       configId = key
    end
  end
  
  local free = 0
  if isFreeStatus == true then
    free = 1
  end
  
  if configId > 0 then
    local data = PbRegist.pack(PbMsgId.GreatDrawCardC2S,{configId = configId, free = free})
    net.sendMessage(PbMsgId.GreatDrawCardC2S, data)
  end
  
end

function CardFlashDetailView:drawCardTence()
  _showLoading()
  
  self._drawType = "itemTen"
  
  local configId = 0
  for key, var in pairs(AllConfig.greatbonus) do
    if var.country == self._country and var.drop_count == 10 then
       configId = key
    end
  end
  
  if configId > 0 then
    local data = PbRegist.pack(PbMsgId.GreatDrawCardC2S,{configId = configId, free = 0})
    net.sendMessage(PbMsgId.GreatDrawCardC2S, data)
  end
end

function CardFlashDetailView:updateView()
  self:stopActionByTag(230)


  local leftSec1 = self:getLeftTimeForFree()
  local function updataTime()
    leftSec1 = leftSec1-1
    if leftSec1 > 0 then 
      isFreeStatus = false
      self._labelOnceCost:setColor(ccc3(255,255,255))
      self._labelFree:setString(_tr("lottery_free")..":"..string.format("%02d:%02d:%02d", formatTime(leftSec1)))
    else 
--      self.leftFreeTime:setString(_tr("lottery_cur_free"))
--      self.leftOneCost:setString(_tr("lottery_free"))
      --self._freeLoyaltyLottery = true 
      isFreeStatus = true
      self._labelOnceCost:setColor(sgGREEN)
      self._labelOnceCost:setString(_tr("lottery_free"))
      self:stopActionByTag(230)
      self._labelFree:setString("")
    end 
    
  end

  if leftSec1 <= 0 then
    isFreeStatus = true
    self._labelOnceCost:setColor(sgGREEN)
    self._labelOnceCost:setString(_tr("lottery_free"))
    self._labelFree:setString("")
  else
    isFreeStatus = false
    self._labelOnceCost:setColor(ccc3(255,255,255))
    local action = self:schedule(updataTime, 1.0)
    action:setTag(230) 
    self._labelFree:setString(_tr("lottery_free")..":"..string.format("%02d:%02d:%02d", formatTime(leftSec1)))
    self._labelOnceCost:setString(self._onceCost) 
  end
  
  --update replace count
  local replaceRemain = self._replaceCount - GameData:Instance():getCurrentPlayer():getDrawCardGreatCount()%self._replaceCount
  local tipBg = self._tipBg
  if tipBg then
    tipBg:removeAllChildrenWithCleanup(true)
    if replaceRemain > 0 then
      local num = display.newSprite("#xianshidianjiang__num_"..replaceRemain..".png")
      tipBg:addChild(num)
      num:setPosition(ccp(215,35))
    end
  end
 
end


function CardFlashDetailView:getLeftTimeForFree()
  local leftSec = 0 
  local curTime = Clock:Instance():getCurServerUtcTime()
  leftSec = GameData:Instance():getCurrentPlayer():getLastFreeGreatTime() + AllConfig.characterinitdata[34].data*60 - curTime
  echo("getLeftTimeForFree:",leftSec)
  return leftSec 
end 

function CardFlashDetailView:onGreatDrawCardResultS2C(action,msgId,msg)
  printf(msg.error)
  --[[
  NO_ERROR_CODE = 1; //
  NOT_FOUND_CONFIG = 2; //没有找到配置
  NEED_MORE_MONEY = 3; //钱不够
  FREE_IN_CD_TIME = 4; //免费抽卡在CD时间
  SYSTEM_ERROR = 99; // 系统错误
    ]]
  _hideLoading()
  if msg.error == "NO_ERROR_CODE" then
    if isFreeStatus == true and self._drawType == "itemOne" then
      local curTime = Clock:Instance():getCurServerUtcTime()
      GameData:Instance():getCurrentPlayer():setLastFreeGreatTime(curTime)
    end
    
    self:insertRewardCard2Table(msg)
    self:playAnimWithType(self._drawType)
    self:updateView()
  end
end

function CardFlashDetailView:onExit()
  net.unregistAllCallback(self)
  display.removeSpriteFramesWithFile("card_flash_sale/card_flash_sale.plist", "card_flash_sale/card_flash_sale.png")
	CardFlashDetailView.super.onExit(self)
end

function CardFlashDetailView:onAnimFinishForSingleDraw()
  animIsFinish = true

  --check drop card/chip
  if #rewardCardTable == 0 and #rewardCardChipTable == 0 then 
    echo("=== no card / chip ...")
    if self._popupNode ~= nil then 
      self._popupNode:removeAllChildrenWithCleanup(true)
    end 
    return 
  end 

  local isGainedCard = #rewardCardTable > 0 
  local configId
  if isGainedCard then 
    configId = rewardCardTable[1]:getConfigId()
  else  
    configId = rewardCardChipTable[1].orgCardId --原始对应卡牌 id
    echo("====org configId", configId)
    if configId == nil then 
      configId = AllConfig.item[rewardCardChipTable[1].configId].item_unit_id
    end 
  end 
  if configId <= 0 then 
    echo("=== invalid configId")
    if self._popupNode ~= nil then 
      self._popupNode:removeAllChildrenWithCleanup(true)
    end 
    return 
  end 

  --show large card 
  local parent = self._fightAnimLayer:getParent()
  if parent ~= nil then
    parent:removeChildByTag(12567)
  end

  self._fightAnimLayer:removeFromParentAndCleanup(true)
  local node = display.newNode()
  node:setPosition(ccp(0,0))
  node:setCascadeOpacityEnabled(true)
  if self._popupNode ~= nil then
    self._popupNode:addChild(node,1,1221)
  end

  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("mAnimationManager","CCBAnimationManager")
  pkg:addProperty("cardNode","CCSprite")   -- 卡牌的容器
  pkg:addProperty("get_card_flare","CCParticleSystemQuad")
  local layer,owner = ccbHelper.load("anim_GetCard.ccbi","AnimGetCardCCB","CCLayer",pkg)

  if self._lotteryType == "loyaltyOne" then
    self.get_card_flare:setVisible(false)
  end

  local mask = Mask.new({opacity = 0,priority = -1130})
  self.cardNode:addChild(mask)

  --显示卡牌大头像,如果是碎片则显示由卡牌转换成碎片的效果
  local cardHead = OrbitCard.new({configId = configId, node = mask}) 
  cardHead:show()
  
  --count tip
  local tipBg = display.newSprite("#xianshidianjiang_zaichou.png")
  mask:addChild(tipBg)
  tipBg:setPositionY(-270)
  
  local replaceRemain = self._replaceCount - GameData:Instance():getCurrentPlayer():getDrawCardGreatCount()%self._replaceCount
  if replaceRemain > 0 then
    local num = display.newSprite("#xianshidianjiang__num_"..replaceRemain..".png")
    tipBg:addChild(num)
    num:setPosition(ccp(215,35))
  end


  if isGainedCard == false then 
    tipBg:setVisible(false)
    tipBg:setPositionY(-270 + 100)
    self:performWithDelay(
      function()
        local function scaleEnd()
          tipBg:setVisible(true)
          cardHead:setVisible(false)
          --show chips 
          local item = rewardCardChipTable[1]
          local sprite = GameData:Instance():getCurrentPackage():getItemSprite(nil, item.iType, item.configId, item.count)
          if sprite then 
            local label = CCLabelTTF:create(_tr("gained_cards_exchanged_to_chips"), "Courier-Bold", 24)
            label:setPosition(ccp(0, -80))
            sprite:addChild(label)
            sprite:setPosition(ccp(0, 60))
            mask:addChild(sprite)
          end 

          self:removeMaskLayer()
        end 
        
        local seq = CCSequence:createWithTwoActions(CCScaleTo:create(0.5, 0.2),  CCCallFunc:create(scaleEnd))
        cardHead:runAction(seq)
      end, 
      1.0)
  end 

  -- TODO:单张卡牌的显示，不翻转
  node:addChild(layer)
  self._getCardAnimLayer = layer
  self._getCardAnimLayer:setVisible(false)
  self._getCardAnimLayer:setVisible(true)
  self.mAnimationManager:runAnimationsForSequenceNamed("GetCard")

end


function CardFlashDetailView:playAnimWithType(type)  --播放抽卡动画
  
  self._cardParts = {} 
  local node = display.newNode()
  node:setPosition(ccp(0,0))
  node:setCascadeOpacityEnabled(true)

  if self._popupNode ~= nil then
    self._popupNode:addChild(node,1)
  else
    self._popupNode = display.newNode()
    GameData:Instance():getCurrentScene():addChild(self._popupNode,1999,POPUP_NODE_ZORDER)
    self._popupNode:addChild(node,1)
  end

  if type == "loyaltyOne" or type == "itemOne" then
    
    if #rewardCardTable == 0 then --单抽获得的是碎片
      self:addMaskLayer()
    end 
    
    local mask = Mask.new({opacity = 0,priority = -500})
    node:addChild(mask,1,12567)

    local pkg = ccbRegisterPkg.new(self)
    pkg:addProperty("mAnimationManager","CCBAnimationManager")
    pkg:addProperty("baoXiangSilverCloseStateIcon","CCSprite")
    pkg:addProperty("baoXiangSilverOpenStateIcon","CCSprite")
    pkg:addProperty("baoXiangGoldCloseStateIcon","CCSprite")
    pkg:addProperty("baoXiangGoldOpenStateIcon","CCSprite")
    pkg:addProperty("signle_flare","CCParticleSystemQuad")

    pkg:addFunc("singleDrawEndCallBack",CardFlashDetailView.onAnimFinishForSingleDraw)

    local layer,owner = ccbHelper.load("anim_SingleDraw.ccbi","SingleDrawCCB","CCLayer",pkg)

    if type == "loyaltyOne" then
      self.signle_flare:setVisible(false)
      self.baoXiangGoldCloseStateIcon:setVisible(false) 
      self.baoXiangGoldOpenStateIcon:setVisible(false)

      local anim,offsetX,offsetY,duration = _res(5020149)
      if anim ~= nil then
        self.baoXiangSilverOpenStateIcon:removeAllChildrenWithCleanup()
        self.baoXiangSilverOpenStateIcon:addChild(anim)
        anim:setScale(2.2)
        anim:setPosition(ccp(299+offsetX,296+offsetY))
        anim:getAnimation():play("default")
      end

    elseif type == "itemOne" then
      self.baoXiangSilverCloseStateIcon:setVisible(false)
      self.baoXiangSilverOpenStateIcon:setVisible(false)

      local anim,offsetX,offsetY,duration = _res(5020149)
      if anim ~= nil then
        self.baoXiangGoldOpenStateIcon:removeAllChildrenWithCleanup()
        self.baoXiangGoldOpenStateIcon:addChild(anim)
        anim:setScale(2.2)
        anim:setPosition(ccp(299+offsetX,296+offsetY))
        anim:getAnimation():play("default")
      end
    end

    assert(layer)
    node:addChild(layer)
    self._fightAnimLayer = layer
    self._fightAnimLayer:setVisible(false)
    self._fightAnimLayer:setVisible(true)
    self.mAnimationManager:runAnimationsForSequenceNamed("SingleDraw")

  elseif type == "loyaltyTen" or type == "itemTen" then 

    local mask = Mask.new({opacity = 0,priority = -1126})
    node:addChild(mask)

    local pkg = ccbRegisterPkg.new(self)
    local cardNodeArray = { "cardNode1","cardNode2","cardNode3","cardNode4","cardNode5",
                            "cardNode6","cardNode7","cardNode8","cardNode9","cardNode10"
                          }
    pkg:addProperty("mAnimationManager","CCBAnimationManager")
    pkg:addProperty("baoxiangOpen_g","CCSprite")
    pkg:addProperty("baoxiangOpen_s","CCSprite")
    pkg:addProperty("baoxiangClose_g","CCSprite")
    pkg:addProperty("baoxiangClose_s","CCSprite")

    pkg:addProperty("enevtNode","CCNode")
    pkg:addProperty("zaichou10ciBtn","CCControlButton")
    pkg:addProperty("confirmBtn","CCControlButton")
    pkg:addProperty("menu_lianhun","CCMenu")    
    pkg:addProperty("yuanbaoIcon","CCSprite")
    pkg:addProperty("minxinIcon","CCSprite")
    pkg:addProperty("costNum","CCLabelTTF")
    pkg:addProperty("lblGainChipsTip","CCLabelTTF")
    pkg:addProperty("ten_flare1","CCParticleSystemQuad")
    pkg:addProperty("ten_flare2","CCParticleSystemQuad")

    local numCardNode = table.getn(cardNodeArray)
    for i = numCardNode,1,-1 do
      pkg:addProperty(cardNodeArray[i],"CCSprite")
    end
    pkg:addFunc("multiDrawFinishCallBack",CardFlashDetailView.onMultiDrawFinishCallBack)
    pkg:addFunc("DrawTenTimeCallBack",CardFlashDetailView.OnDrawTenTimeAgainCallBack)  -- 再抽10次按钮
    pkg:addFunc("confirmCallBack",CardFlashDetailView.onConfirmCallBack)          -- 确定按钮
    pkg:addFunc("lianhunCallback",CardFlashDetailView.lianhunCallback)
    
    local layer,owner = ccbHelper.load("anim_MultiDraw.ccbi","MultiDrawCCB","CCLayer",pkg)
    layer:setTouchEnabled(true)
    layer:addTouchEventListener(handler(self,self.onTouch),false,-1128,true)
    
    
    local function changeSpriteObj(sprite,newsprite)
      newsprite=tolua.cast(newsprite,"CCSprite")
      assert(sprite and newsprite,"")
      local spriteframe = newsprite:displayFrame()
    
      assert(spriteframe,"")
    
      sprite:setDisplayFrame(spriteframe)
    end

    local moneyIcon = display.newSprite("#playstates-image-yuanbao.png")
    changeSpriteObj(self.yuanbaoIcon,moneyIcon)
  
    local cardsLen = #rewardCardTable 
    local chipsLen = #rewardCardChipTable
    print("ten lottery, cards/chips len=", cardsLen, chipsLen)
    for i=1, 10 do 
      if i <= cardsLen then 
        local configId = rewardCardTable[i]:getConfigId()
        local cardHead = CardHeadView.new()
        cardHead:setCardByConfigId(configId) 
        cardHead:setLvVisible(false) 
        -- cardHead:setScale(0.85) 
        cardHead:enableClick(true) 
        --setStar(self,cardHead) 
        self["cardNode"..i]:addChild(cardHead) 
      else 
        if i-cardsLen <= chipsLen then 
          local item = rewardCardChipTable[i-cardsLen]
          local chipNode = GameData:Instance():getCurrentPackage():getItemSprite(nil, item.iType, item.configId, item.count)
          chipNode.configId = item.configId
          if chipNode ~= nil then 
            self["cardNode"..i]:addChild(chipNode) 
          end 
          table.insert(self._cardParts,chipNode)
        end 
      end 
    end 

    self.lblGainChipsTip:setVisible(chipsLen > 0)
    self.lblGainChipsTip:setString(_tr("gained_cards_exchanged_to_chips"))
    
    -- 设置按钮的优先级
    self.zaichou10ciBtn:setTouchPriority(-1129)
    self.confirmBtn:setTouchPriority(-1129)
    self.menu_lianhun:setTouchPriority(-1129)

    if type == "loyaltyTen" then
      self.ten_flare2:setVisible(false)
      self.ten_flare1:setVisible(false)
      self.baoxiangClose_g:setVisible(false) 
      self.baoxiangOpen_g:setVisible(false) 
      self.yuanbaoIcon:removeFromParentAndCleanup(true)
      self.costNum:setString(self.loyaltyTenCost .. "")

      local anim,offsetX,offsetY,duration = _res(5020149)
      if anim ~= nil then
        self.baoxiangOpen_s:removeAllChildrenWithCleanup()
        self.baoxiangOpen_s:addChild(anim)
        anim:setScale(2.2)
        anim:setPosition(ccp(306+offsetX,297+offsetY))
        anim:getAnimation():play("default")
      end
    else
      self.baoxiangOpen_s:setVisible(false) 
      self.baoxiangClose_s:setVisible(false) 

      local anim,offsetX,offsetY,duration = _res(5020149)
      if anim ~= nil then
        self.baoxiangOpen_g:removeAllChildrenWithCleanup()
        self.baoxiangOpen_g:addChild(anim)
        anim:setScale(2.2)
        anim:setPosition(ccp(306+offsetX,297+offsetY))
        anim:getAnimation():play("default")
      end

      self.minxinIcon:removeFromParentAndCleanup(true)
      self.costNum:setString(self._tenCost .."")
    end

    mask:addChild(layer)
    self._lotteryTenAnimLayer = layer

    self.mAnimationManager:runAnimationsForSequenceNamed("MultiDraw")
  end
end

function CardFlashDetailView:insertRewardCard2Table(msg, isFreeDrawCard)
  print("=== insertRewardCard2Table")
  rewardCardTable = {}
  rewardCardChipTable = {}

  if msg.client.card ~= nil then
    for k,val in pairs(msg.client.card) do
      echo("my card = : action=", val.action, val.object.id)
      if val.action == "Add" then
        local cardModel = Card.new()
        cardModel:setId(val.object.id)
        cardModel:setIsBoss(val.object.is_leader)
        cardModel:setIsOnBattle(val.object.is_active)
        cardModel:setConfigId(val.object.config_id)
        table.insert(rewardCardTable,cardModel)
      elseif val.action == "Remove" then

      elseif val.action == "Update" then
        local cardModel = Card.new()
        cardModel:setId(val.object.id)
        cardModel:setIsBoss(val.object.is_leader)
        cardModel:setIsOnBattle(val.object.is_active)
        cardModel:setConfigId(val.object.config_id)
        table.insert(rewardCardTable,cardModel)
      end
    end
  end 

  if isFreeDrawCard == true then 

    if msg.client.item ~= nil then 
      for k,val in pairs(msg.client.item) do 
        echo("=== my chip", val.action)      
        if val.action == "Add" then
          if AllConfig.item[val.object.type_id].item_type == 3 then --card chip 
            local propsItem = {iType = 6, configId = val.object.type_id, count = val.object.count}
            table.insert(rewardCardChipTable, propsItem)
          end 

        elseif val.action == "Update" then 
          if AllConfig.item[val.object.type_id].item_type == 3 then --card chip 
            local oldItem = GameData:Instance():getCurrentPackage():getPropsByConfigId(val.object.type_id)
            if oldItem ~= nil then 
              local propsItem = {iType = 6, configId = val.object.type_id, count = val.object.count-oldItem:getCount()}
              table.insert(rewardCardChipTable, propsItem)
            end 
          end 
        end 
      end 
    end 

  else 

    --抽卡获得的原始卡牌(未转换为碎片之前), 与抽到的结果作对照, 计算碎片数量未合并之前的状态，保证总共有10份数据
    if msg.cards ~= nil then 
     --dump(msg.cards, "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ cards map")

      local tmpTbl = {}
      for k, v in pairs(rewardCardTable) do 
        tmpTbl[k] = v 
      end       

      local function isLotteryCard(id)
        for k, v in pairs(tmpTbl) do 
          if v:getConfigId() == id then 
            table.remove(tmpTbl, k)
            return true 
          end 
        end 

        return false  
      end 

      local chipInfo 
      for k, v in pairs(msg.cards) do --预期抽到的卡牌剔除掉已抽到的卡牌，其他则用碎片显示
        if isLotteryCard(v) == false then 
          --echo("====orgCardId", v)
          chipInfo = AllConfig.unit[v].card_puzzle_drop 
          local propsItem = {iType = chipInfo[1], configId = chipInfo[2], count = chipInfo[3], orgCardId = v}
          table.insert(rewardCardChipTable, propsItem)
        end 
      end 
    end 
  end 

  GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
end

function CardFlashDetailView:onMultiDrawFinishCallBack()
  local array = CCArray:create()
  local actionTo = CCMoveTo:create(0.3,CCPointMake(display.cx,self.enevtNode:getPositionY()))
  array:addObject(actionTo)
  array:addObject(CCDelayTime:create(2.0))
  array:addObject(CCCallFunc:create(function() animIsFinish = true end))
  local action = CCSequence:create(array)
  self.enevtNode:runAction(action)
end

function CardFlashDetailView:OnDrawTenTimeAgainCallBack()
  print("OnDrawTenTimeAgainCallBack")
  if animIsFinish == false then 
    return 
  end 

  if self._lotteryTenAnimLayer ~= nil then
    self._lotteryTenAnimLayer:getParent():removeFromParentAndCleanup(true)
    self._lotteryTenAnimLayer = nil 
  end
  
  self:drawCardTence()
end

function CardFlashDetailView:onConfirmCallBack()
  print("onConfirmCallBack")
  if animIsFinish == false then 
    return 
  end 

  if self._lotteryTenAnimLayer ~= nil then
    self._lotteryTenAnimLayer:getParent():removeFromParentAndCleanup(true)
    self._lotteryTenAnimLayer = nil 
  end
end

function CardFlashDetailView:lianhunCallback() -- 跳到炼魂界面
  print("lianhunCallback")
  if animIsFinish == false then 
    return 
  end 
  self:onConfirmCallBack()
  if GameData:Instance():checkSystemOpenCondition(27, true) == false then 
    return 
  end 

  local controller = ControllerFactory:Instance():create(ControllerType.CARD_SOUL_CONTROLLER)
  controller:enter(CardSoulMenu.REFINE_CARD)
end 

function CardFlashDetailView:addMaskLayer()
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1500})
  self:addChild(self.maskLayer)
  
  self:performWithDelay(handler(self, LotteryView.removeMaskLayer), 6.0)
end

function CardFlashDetailView:removeMaskLayer()
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 


return CardFlashDetailView