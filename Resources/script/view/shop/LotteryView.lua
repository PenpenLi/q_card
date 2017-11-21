require("view.BaseView")
require("model.Mall")
require("view.shop.component.CardAwardNotifyView")
require("view.shop.LotteryPreview")
require("view.card_flash_sale.CardFlashSalePreview")

LotteryView = class("LotteryView", ViewWithEave)

local scheduleScrollID = nil
local notifyPlayertable ={} -- 当前抽到4星级以上的人物
local key = 0
local lotteryNoticeTable = {}
local rewardCardTable = {}      --抽卡获得的卡牌
local rewardCardChipTable = {}  --抽卡获得的卡牌转换为相应碎片
local animIsFinish = true
local FRIST_PAGE_FREE_NODE_TAG = 1110


function LotteryView:ctor(control)
  print("LotteryView ctor")

  LotteryView.super.ctor(self)
  self:setDelegate(control)
  self:setNodeEventEnabled(true)
  self._cardParts = {}
end

function LotteryView:onTouch(event,x,y)
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

function LotteryView:enterFlashSaleHandler()
  local controller = ControllerFactory:Instance():create(ControllerType.CARD_FLASH_SALE)
  controller:enter()
end

function LotteryView:flashSalePreviewHandler()
  display.addSpriteFramesWithFile("card_flash_sale/card_flash_sale.plist", "card_flash_sale/card_flash_sale.png")
  local cardFlashSalePreview = CardFlashSalePreview.new(1)
  GameData:Instance():getCurrentScene():addChildView(cardFlashSalePreview)
end


function LotteryView:enter()

  local pkg = ccbRegisterPkg.new(self)
  self._lotteryType = "none" -- todo:定义当前抽卡的类型 -- loyaltyOne loyaltyTen itemOne itemTen
  pkg:addProperty("mainLeftBg","CCSprite")
  pkg:addProperty("mainRightBg","CCSprite")
  pkg:addProperty("noticeBg","CCSprite")  -- TODO: 通知的背景
  pkg:addProperty("flashSaleBtn","CCControlButton")
    
  pkg:addProperty("labelFlashSaleFree","CCLabelTTF")
  pkg:addProperty("spriteFlashSaleFree","CCSprite")

  pkg:addFunc("enterFlashSaleHandler",LotteryView.enterFlashSaleHandler)
  pkg:addFunc("flashSalePreviewHandler",LotteryView.flashSalePreviewHandler)
  local layer,owner = ccbHelper.load("DianJiangView.ccbi","DainJiangViewCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.labelFlashSaleFree:setString(_tr("lottery_free"))
  local curTime = Clock:Instance():getCurServerUtcTime()
  local leftSec = GameData:Instance():getCurrentPlayer():getLastFreeGreatTime() + AllConfig.characterinitdata[34].data*60 - curTime

  self.spriteFlashSaleFree:setVisible(leftSec <= 0)

  --抽卡花费
  self.loyaltyOneCost = AllConfig.erniebonus[1].cost
  self.loyaltyTenCost = AllConfig.erniebonus[2].cost
  self.itemOneCost = AllConfig.guidebonus[1].cost
  self.itemTenCost = AllConfig.guidebonus[2].cost

  -- setting title
  self:setTabControlEnabled(false)
  self:setTitleTextureName("dianjiangtai_title.png")

  -- TODO: init FreeDrawState
  self._freeLoyaltyLottery = false
  self._freeItemLottery = false  -- free item lottery

  --
  self:updateLotteryFreeState("loyalty")
  self:updateLotteryFreeState("item")

  self:drawLotteryComponentWithDirection("left")
  self:drawLotteryComponentWithDirection("right")

  self:drawLotterySecondPageWithDirection("left")
  self:drawLotterySecondPageWithDirection("right")
  self._leftSecondLayer:setVisible(false)
  self._rightSecondLayer:setVisible(false)

  -- draw Notice Layer
  local parent = self.noticeBg:getParent()
  self.noticeLayer = display.newLayer()
  self.noticeLayer:setContentSize(CCSizeMake(640,self.noticeBg:getContentSize().height))
  self.noticeMaskLayer = DSMask:createMask(CCSizeMake(self.noticeBg:getContentSize().width,self.noticeBg:getContentSize().height))
  self.noticeMaskLayer:setPosition(ccp(self.noticeBg:getPositionX(),self.noticeBg:getPositionY() ))
  parent:addChild(self.noticeMaskLayer)
  self.noticeMaskLayer:addChild(self.noticeLayer)

  key = GameData:Instance():getAskForDrawTenCardInformationResultOfKey()
  lotteryNoticeTable = GameData:Instance():getAskForDrawTenCardInformationResultOfData()
  if key == nil and lotteryNoticeTable == nil then
    key = 0
  end

  Mall:Instance():reqNoticeInfo(key)
  
  _registNewBirdComponent(121003,self:getEaveView().btnHelp)

  -- 注册消息
  net.registMsgCallback(PbMsgId.AskForDrawTenCardInformationResult,self,LotteryView.onAskForDrawTenCardInformationResult)
  net.registMsgCallback(PbMsgId.DrawCardUseLoyaltyResult,self,LotteryView.onDrawCardUseLoyaltyResult)
  net.registMsgCallback(PbMsgId.DrawCardUseItemResult,self,LotteryView.onDrawCardUseItemResult)
  net.registMsgCallback(PbMsgId.LoyaltyFreeDrawCardResult,self,LotteryView.onLoyaltyFreeDrawCardResult) --TODO：民心免费抽卡
  net.registMsgCallback(PbMsgId.FreeDrawCardResult,self,LotteryView.onFreeDrawCardResult)       --TODO：锦囊免费抽卡

  net.registMsgCallback(PbMsgId.QuickDrawCardUseItemResult,self,LotteryView.onQuickDrawCardUseItemResult) 
  
  local function showNotice()
    self:showRewardNotice()
  end
  self:performWithDelay(showNotice,0.1)

  local curScene = GameData:Instance():getCurrentScene()
  self._popupNode = curScene:getChildByTag(POPUP_NODE_ZORDER)
  assert(self._popupNode ~= nil)
  if self._popupNode == nil then
    self._popupNode = display.newNode()
    curScene:addChild(self._popupNode,1999,POPUP_NODE_ZORDER)
  end

end

function LotteryView:drawLotterySecondPageWithDirection(dir)
  echo("@@@ drawLotterySecondPageWithDirection:", dir)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("dropDownBtn","CCControlButton")
  pkg:addProperty("oneLotteryBtn","CCControlButton")
  pkg:addProperty("tenLotteryBtn","CCControlButton")
  pkg:addProperty("oneCost","CCLabelTTF")
  pkg:addProperty("tenCost","CCLabelTTF")
  pkg:addProperty("tipsShow","CCLabelTTF")
  pkg:addProperty("freshTime","CCLabelTTF")  -- 免费倒计时
  pkg:addProperty("minxin1Icon","CCSprite")
  pkg:addProperty("yuanbao1Icon","CCSprite")
  pkg:addProperty("remaining_time","CCLabelTTF")

  pkg:addProperty("minxin2Icon","CCSprite")
  pkg:addProperty("yuanbao2Icon","CCSprite")


  if dir == "left" then
    pkg:addFunc("dropDownCallBack",LotteryView.onLeftDropDownCallBack)
    pkg:addFunc("oneLotteryCallBack",LotteryView.onLeftOneLotteryCallBack)
    pkg:addFunc("tenLotteryCallBack",LotteryView.onLeftTenLotteryCallBack)
  elseif dir == "right" then
    pkg:addFunc("dropDownCallBack",LotteryView.onRightDropDownCallBack)
    pkg:addFunc("oneLotteryCallBack",LotteryView.onRightOneLotteryCallBack)
    pkg:addFunc("tenLotteryCallBack",LotteryView.onRightTenLotteryCallBack)
  end

  local layer,owner = ccbHelper.load("LotteryComponent.ccbi","LotteryComponentViewCCB","CCLayer",pkg)
  --self.oneLotteryBtn:removeFromParentAndCleanup(true)
  --layer:setPosition(ccp(0.0,0.0))
  self.dropDownBtn:setTouchPriority(-200)
  self.oneLotteryBtn:setTouchPriority(-200)
  self.tenLotteryBtn:setTouchPriority(-200)

  self.remaining_time:setString(_tr("remaining_time"))
  if dir == "left" then
    self.leftOneCost = self.oneCost
  elseif dir == "right" then
    self.rightOneCost = self.oneCost
    self._rightEnterBtn = self.oneLotteryBtn
    _registNewBirdComponent(121002,self._rightEnterBtn)
  end
  
  local action1 = CCJumpBy:create(1.5,ccp(0,0),5,2)
  local action = CCRepeatForever:create(action1)
  self.dropDownBtn:runAction(action)

  if dir == "left" then --民心抽卡
    --self._freeItemLottery = false
    self._leftSecondLayer = layer
    self.yuanbao1Icon:setVisible(false)
    self.yuanbao2Icon:setVisible(false)
    self.mainLeftLayer:addChild(layer)
    self.leftFreeTime = self.freshTime

    local leftSec1 = self:getLeftTimeForFree("left")

    local function updataTime()
      leftSec1 = leftSec1-1
      if leftSec1 > 0 then 
        self.leftFreeTime:setString(string.format("%02d:%02d:%02d", formatTime(leftSec1)))
      else 
        self.leftFreeTime:setString(_tr("lottery_cur_free"))
        self.leftOneCost:setString(_tr("lottery_free"))
        self._freeLoyaltyLottery = true 
        self:stopActionByTag(230)
      end 
    end

    if leftSec1 <= 0 then
      self.leftFreeTime:setString(_tr("lottery_cur_free"))
      self.leftOneCost:setString(_tr("lottery_free"))
    else
      local action = self:schedule(updataTime, 1.0)
      action:setTag(230) 
      self.leftFreeTime:setString(string.format("%02d:%02d:%02d", formatTime(leftSec1)))
      self.leftOneCost:setString(self.loyaltyOneCost) 
    end

    self.tenCost:setString(self.loyaltyTenCost)
    self.tipsShow:setString(_tr("lottery_tip2"))

  elseif dir == "right" then --锦囊抽卡
    self._rightSecondLayer = layer
    self.minxin1Icon:setVisible(false)
    self.minxin2Icon:setVisible(false)
    self.mainRightLayer:addChild(layer)
    self.rightFreeTime = self.freshTime

    local leftSec2 = self:getLeftTimeForFree("right")
    local function updataTime()
      leftSec2 = leftSec2-1
      if leftSec2 > 0 then 
        self.rightFreeTime:setString(string.format("%02d:%02d:%02d", formatTime(leftSec2)))
      else 
        self.rightFreeTime:setString(_tr("lottery_cur_free"))
        self.rightOneCost:setString(_tr("lottery_free"))
        self._freeItemLottery = true

        self:stopActionByTag(231)
      end 
    end
    
    if leftSec2 <= 0 then
      self.rightFreeTime:setString(_tr("lottery_cur_free"))
      self.rightOneCost:setString(_tr("lottery_free"))
    else
      self.rightFreeTime:setString(string.format("%02d:%02d:%02d", formatTime(leftSec2)))
      self.rightOneCost:setString(self.itemOneCost) 
      local action = self:schedule(updataTime,1.0)
      action:setTag(231)
    end

    self.tenCost:setString(self.itemTenCost)       ---
    self.tipsShow:setString(_tr("lottery_tip"))
  end
end

function LotteryView:updataFreeDrawState(loyaltyType)
  local fristPageFreeNode = nil
  local timerTag
  local leftSec = 0 

  if loyaltyType == "loyaltyOne" then
    fristPageFreeNode = self.leftMinXinIcon:getChildByTag(FRIST_PAGE_FREE_NODE_TAG)
    leftSec = self:getLeftTimeForFree("left")
    timerTag = 234 
  elseif loyaltyType == "itemOne" then
    fristPageFreeNode = self.rightJinTianIcon:getChildByTag(FRIST_PAGE_FREE_NODE_TAG)
    leftSec = self:getLeftTimeForFree("right")
    timerTag = 235 
  end


  local function updataTime()
    leftSec = leftSec-1

    if leftSec > 0 then
      if fristPageFreeNode ~= nil and fristPageFreeNode:isVisible() == true  then
        fristPageFreeNode:setVisible(false)
      end

      if loyaltyType == "loyaltyOne" then
        self.leftFreeTime:setString(string.format("%02d:%02d:%02d", formatTime(leftSec)))
        self.leftOneCost:setString(self.loyaltyOneCost)
      elseif loyaltyType == "itemOne" then
        self.rightFreeTime:setString(string.format("%02d:%02d:%02d", formatTime(leftSec)))
        self.rightOneCost:setString(self.itemOneCost)
      end

    else
      self:stopActionByTag(timerTag)

      if loyaltyType == "loyaltyOne"  then
        self._freeLoyaltyLottery = true
        if fristPageFreeNode == nil then
          self.leftMinXinIcon:addChild(self:getFreeFontMarkNode("left"),1,FRIST_PAGE_FREE_NODE_TAG)
        else
          self.leftMinXinIcon:setVisible(true)
        end

        self.leftFreeTime:setString(_tr("lottery_cur_free"))
        self.leftOneCost:setString(_tr("lottery_free"))

      elseif loyaltyType == "itemOne" then
        self._freeItemLottery = true
        if fristPageFreeNode == nil then
          self.rightJinTianIcon:addChild(self:getFreeFontMarkNode("right"),1,FRIST_PAGE_FREE_NODE_TAG)
        else
          self.rightJinTianIcon(true)
        end

        self.rightFreeTime:setString(_tr("lottery_cur_free"))
        self.rightOneCost:setString(_tr("lottery_free"))        
      end
    end
  end

  local action = self:schedule(updataTime,1.0)
  action:setTag(timerTag)
end

function LotteryView:drawLotteryComponentWithDirection(dir)
  local lotteryMask
  lotteryMask = DSMask:createMask(CCSizeMake(self.mainLeftBg:getContentSize().width,self.mainLeftBg:getContentSize().height - 20)) 
  lotteryMask:setPosition(ccp(0,10))
  

  if dir == "left" then
    self.mainLeftLayer =  CCLayerColor:create(ccc4(0,0,0,0))
    self.mainLeftLayer:setContentSize(CCSizeMake(self.mainLeftBg:getContentSize().width,self.mainLeftBg:getContentSize().height*2))
    self.mainLeftLayer:ignoreAnchorPointForPosition(false)
    self.mainLeftLayer:setAnchorPoint(ccp(0.5,0))
    self.mainLeftLayer:setPosition(ccp(self.mainLeftBg:getContentSize().width/2.0,-self.mainLeftBg:getContentSize().height-10)) 
    lotteryMask:addChild(self.mainLeftLayer)

    self.leftMinXinIcon = display.newSprite("#dianjiang_minxin.png")
    self.leftMinXinIcon:setPosition(self.mainLeftLayer:getContentSize().width/2.0,self.mainLeftLayer:getContentSize().height*3/4.0)
    self.mainLeftLayer:addChild(self.leftMinXinIcon)

    local function leftEntryBtnCallBack()
      if self._leftIsDropping == true then
        return
      end
    
      self._leftSecondLayer:setVisible(true)
      local array = CCArray:create()
      local actionTo = CCMoveBy:create(0.3,CCPointMake(0,self.mainLeftBg:getContentSize().height))
      array:addObject(actionTo)
      array:addObject(CCCallFunc:create(function ()
        self.mainLeftLayer:setPositionY(-10)
      end))
      local action = CCSequence:create(array)
      self.mainLeftLayer:runAction(action)
    end
    
    local nor = display.newSprite("#dianjiangtai_btn_preview.png")
    local sel = display.newSprite("#dianjiangtai_btn_preview1.png")
    local dis = display.newSprite("#dianjiangtai_btn_preview1.png")
    local previewBtn = UIHelper.ccMenuWithSprite(nor,sel,dis,function()
      local lotteryPreview = LotteryPreview.new(1)
      GameData:Instance():getCurrentScene():addChildView(lotteryPreview)
    end)
    
    self.leftMinXinIcon:addChild(previewBtn,0)
    previewBtn:setPosition(ccp(self.leftMinXinIcon:getContentSize().width/2.0 + 70,435))

    local leftBtnframe1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dianjaingtai_jinru0.png")
    local leftBtnframe2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dianjaingtai_jinru1.png")
    local pLeftBackgroundButton = CCScale9Sprite:createWithSpriteFrame(leftBtnframe1)
    local pBackgroundHighlightedButton = CCScale9Sprite:createWithSpriteFrame(leftBtnframe2)
    local pLeftButton = CCControlButton:create(pLeftBackgroundButton)
    pLeftButton:setBackgroundSpriteForState(pBackgroundHighlightedButton, CCControlStateHighlighted)
    pLeftButton:addHandleOfControlEvent(leftEntryBtnCallBack,CCControlEventTouchDown)
    pLeftButton:setPosition(ccp(self.leftMinXinIcon:getContentSize().width/2.0,83.0))
    self.leftMinXinIcon:addChild(pLeftButton,0)
    pLeftButton:setPreferredSize(CCSizeMake(132, 61))
    pLeftButton:setTouchPriority(-200)

    -- TODO: 判断是否在首页  显示 免费
    if self._freeLoyaltyLottery == true then
      self.leftMinXinIcon:addChild(self:getFreeFontMarkNode("left"),1,FRIST_PAGE_FREE_NODE_TAG)
    end

    -- TODO: scroll
    local topScroll = display.newSprite("#gray_scroll.png")
    topScroll:setPosition(self.leftMinXinIcon:getContentSize().width/2.0,self.leftMinXinIcon:getContentSize().height-topScroll:getContentSize().height/2.0)
    self.mainLeftBg:addChild(topScroll,10)
    local minxinFont = display.newSprite("#minxin_font.png")
    minxinFont:setAnchorPoint(ccp(0.5,0))
    minxinFont:setPosition(topScroll:getContentSize().width/2.0,topScroll:getContentSize().height - 17)
    topScroll:addChild(minxinFont)
    local bottomScroll =  display.newSprite("#gray_scroll.png")
    bottomScroll:setPosition(self.leftMinXinIcon:getContentSize().width/2.0,bottomScroll:getContentSize().height/2.0)
    self.mainLeftBg:addChild(bottomScroll,10)

    self.mainLeftBg:addChild(lotteryMask)
  elseif dir == "right" then

    self.mainRightLayer =  CCLayerColor:create(ccc4(0,0,0,0))
    self.mainRightLayer:setContentSize(CCSizeMake(self.mainRightBg:getContentSize().width,self.mainRightBg:getContentSize().height*2))
    self.mainRightLayer:ignoreAnchorPointForPosition(false)
    self.mainRightLayer:setAnchorPoint(ccp(0.5,0))
    self.mainRightLayer:setPosition(ccp(self.mainRightBg:getContentSize().width/2.0,-self.mainRightBg:getContentSize().height-10))
    lotteryMask:addChild(self.mainRightLayer)

    self.rightJinTianIcon = display.newSprite("#dianjiang_jitian.png")
    self.rightJinTianIcon:setPosition(self.mainRightLayer:getContentSize().width/2.0,self.mainRightLayer:getContentSize().height*3/4.0)
    self.mainRightLayer:addChild(self.rightJinTianIcon)

    local function rightEntryBtnCallBack()
      if self._rightIsDropping == true then
        return
      end
    
      animIsFinish = false
      self._rightSecondLayer:setVisible(true)
      local array = CCArray:create()
      local actionTo = CCMoveBy:create(0.3,CCPointMake(0,self.mainRightBg:getContentSize().height))
      array:addObject(actionTo)
      array:addObject(CCCallFunc:create(function ()
        self.mainRightLayer:setPositionY(-10)
        if _executeNewBird() == true then
          local array = CCArray:create()
          array:addObject(CCDelayTime:create(0.5))
          array:addObject(CCCallFunc:create(function() animIsFinish = true end))
          local action = CCSequence:create(array)
          self:runAction(action)
        else
          animIsFinish = true
        end
      end))
      local action = CCSequence:create(array)
      self.mainRightLayer:runAction(action)
    end
    
    local nor = display.newSprite("#dianjiangtai_btn_preview.png")
    local sel = display.newSprite("#dianjiangtai_btn_preview1.png")
    local dis = display.newSprite("#dianjiangtai_btn_preview1.png")
    local previewBtn = UIHelper.ccMenuWithSprite(nor,sel,dis,function()
      local lotteryPreview = LotteryPreview.new(2)
      GameData:Instance():getCurrentScene():addChildView(lotteryPreview)
    end)
    
    self.rightJinTianIcon:addChild(previewBtn,0)
    previewBtn:setPosition(ccp(self.rightJinTianIcon:getContentSize().width/2.0 + 70,435))

    local leftBtnframe1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dianjaingtai_jinru0.png")
    local leftBtnframe2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dianjaingtai_jinru1.png")
    local pLeftBackgroundButton = CCScale9Sprite:createWithSpriteFrame(leftBtnframe1)
    local pBackgroundHighlightedButton = CCScale9Sprite:createWithSpriteFrame(leftBtnframe2)
    local pLeftButton = CCControlButton:create(pLeftBackgroundButton)
    pLeftButton:setBackgroundSpriteForState(pBackgroundHighlightedButton, CCControlStateHighlighted)
    pLeftButton:addHandleOfControlEvent(rightEntryBtnCallBack,CCControlEventTouchDown)
    pLeftButton:setPosition(ccp(self.rightJinTianIcon:getContentSize().width/2.0,83.0))
    self.rightJinTianIcon:addChild(pLeftButton,0)
    pLeftButton:setPreferredSize(CCSizeMake(132, 61))
    pLeftButton:setTouchPriority(-200)
    
    _registNewBirdComponent(121001,pLeftButton)

    -- TODO: input 免费
    if self._freeItemLottery == true  then
      self.rightJinTianIcon:addChild(self:getFreeFontMarkNode("right"),1,FRIST_PAGE_FREE_NODE_TAG)
    end
    -- TODO:scroll
    local topScroll = display.newSprite("#golden_scroll.png")
    topScroll:setPosition(self.rightJinTianIcon:getContentSize().width/2.0,self.rightJinTianIcon:getContentSize().height-topScroll:getContentSize().height/2.0)
    self.mainRightBg:addChild(topScroll,10)
    local jinTianFont = display.newSprite("#jintian_font.png")
    jinTianFont:setAnchorPoint(ccp(0.5,0))
    jinTianFont:setPosition(topScroll:getContentSize().width/2.0,topScroll:getContentSize().height - 17)
    topScroll:addChild(jinTianFont)
    local bottomScroll =  display.newSprite("#golden_scroll.png")
    bottomScroll:setPosition(self.rightJinTianIcon:getContentSize().width/2.0,bottomScroll:getContentSize().height/2.0)
    self.mainRightBg:addChild(bottomScroll,10)
    self.mainRightBg:addChild(lotteryMask)

    local posX = pLeftButton:getPositionX()
    local posY = pLeftButton:getPositionY()
    local btnPos = pLeftButton:getParent():convertToWorldSpace(ccp(posX,posY))
    _executeNewBird()
  end
end

function LotteryView:getFreeFontMarkNode(dir)
  local inputBg = CCScale9Sprite:createWithSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("common_bar_bg.png"))
  inputBg:setPosition(ccp(self.mainLeftBg:getContentSize().width/2.0,150))

  if dir == "left" then
    self.leftFreeFont = CCLabelTTF:create(_tr("lottery_free"),"Courier-Bold",24)
    self.leftFreeFont:setColor(ccc3(0,255,0))
    self.leftFreeFont:setPosition(ccp(inputBg:getContentSize().width/2.0,inputBg:getContentSize().height/2.0))
    inputBg:addChild(self.leftFreeFont)
  elseif dir == "right" then
    self.rightFreeFont = CCLabelTTF:create(_tr("lottery_free"),"Courier-Bold",24)
    self.rightFreeFont:setColor(ccc3(0,255,0))
    self.rightFreeFont:setPosition(ccp(inputBg:getContentSize().width/2.0,inputBg:getContentSize().height/2.0))
    inputBg:addChild(self.rightFreeFont)
  end

  return inputBg
end

function LotteryView:onLeftDropDownCallBack()
  print("=== onLeftDropDownCallBack")
  self._leftIsDropping = true
  local array = CCArray:create()
  local actionTo = CCMoveBy:create(0.3,CCPointMake(0,-self.mainLeftBg:getContentSize().height))
  array:addObject(actionTo)
  local callfunc = CCCallFunc:create(function() self._leftSecondLayer:setVisible(false) self._leftIsDropping = false end)
  array:addObject(callfunc)
  local action = CCSequence:create(array)
  self.mainLeftLayer:runAction(action)
end

--民心单抽
function LotteryView:onLeftOneLotteryCallBack()
  print("=== onLeftOneLotteryCallBack", animIsFinish)

  _playSnd(SFX_CLICK)

  if animIsFinish == false then
    return
  end
  animIsFinish = false
  self._lotteryType = "loyaltyOne"

  if self._freeLoyaltyLottery == true then
    if self:checkBagEnoughSpace(8) == false then  -- 8：卡牌
      animIsFinish = true
      return
    end
  else  -- 1.cost is enough 2.card Bag is enough
    local loyalty = GameData:Instance():getCurrentPlayer():getLoyalty()
    local isEnoughCost = self:isEnoughLoyaltyOrMoney("loyaltyOne")
    local iscardBagEnough = true
    if isEnoughCost == true then
      iscardBagEnough = self:checkBagEnoughSpace(8)
    end
    if isEnoughCost == false or iscardBagEnough == false then
      animIsFinish = true
      return
    end
  end

  _showLoading()
  -- 抽卡消息
  if self._freeLoyaltyLottery == true then
    net.sendMessage(PbMsgId.LoyaltyFreeDrawCard) -- 民心免费抽卡
  else
    local lotteryOneByLoyaltyData = PbRegist.pack(PbMsgId.DrawCardUseLoyalty,{config_id = 1})
    net.sendMessage(PbMsgId.DrawCardUseLoyalty,lotteryOneByLoyaltyData)
  end
end

--TODO：民心十连抽
function LotteryView:onLeftTenLotteryCallBack()
  print("=== onLeftTenLotteryCallBack")

  if animIsFinish == false then
    return
  end
  animIsFinish = false

  _playSnd(SFX_CLICK)
  self._lotteryType = "loyaltyTen"

  local loyalty = GameData:Instance():getCurrentPlayer():getLoyalty()
  local isEnoughCost = self:isEnoughLoyaltyOrMoney("loyaltyTen")
  print("isEnougtCost",isEnoughCost)
  local iscardBagEnough = true
  if isEnoughCost == true then
    iscardBagEnough = self:checkBagEnoughSpace(8)
  end
  if isEnoughCost == false or iscardBagEnough == false then
    animIsFinish = true
    return
  end

  _showLoading()
  -- 抽卡消息
  local lotteryTenByLoyaltyData = PbRegist.pack(PbMsgId.DrawCardUseLoyalty,{config_id = 2})
  net.sendMessage(PbMsgId.DrawCardUseLoyalty,lotteryTenByLoyaltyData)
end

function LotteryView:updateLotteryFreeState(lotteryType)
  if lotteryType == "loyalty"  then
    --self.leftFreeFont:setString("民心免费抽")
    if self:getLeftTimeForFree("left") <= 0 then
      self._freeLoyaltyLottery = true
    else
      self._freeLoyaltyLottery = false
    end
  elseif lotteryType == "item" then
    --self.rightFreeFont:setString("锦囊免费抽")
    if self:getLeftTimeForFree("right") <= 0 then   --free time /24H
      self._freeItemLottery = true
    else
      self._freeItemLottery = false
    end
  end
end

function LotteryView:isEnoughLoyaltyOrMoney(type)
  self._type = type
  local winSize = CCDirector:sharedDirector():getWinSize()
  local loyalty = GameData:Instance():getCurrentPlayer():getLoyalty()
  local package = GameData:Instance():getCurrentPackage()
  local costItemNum = 0
  local costItemId = 0

  if type == "itemOne"  then
    costItemId  = AllConfig.guidebonus[1].item_id
    costItemNum = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(costItemId)
  elseif type == "itemTen" then
    costItemId  = AllConfig.guidebonus[2].item_id
    costItemNum = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(costItemId)
  end

  if type ~= nil and type == "loyaltyOne" and loyalty < self.loyaltyOneCost then
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "pop_qianwang0.png",leftSelBtn = "pop_qianwang1.png",
                                                 text = _tr("not_enough_loyalty"),
                                                 leftCallBack = function() return self:getDelegate():gotoMining() end}) 
    self:getDelegate():getScene():addChild(pop,100)

    return  false
  elseif type ~= nil and type == "loyaltyTen" and loyalty < self.loyaltyTenCost then
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "pop_qianwang0.png",leftSelBtn = "pop_qianwang1.png",
                                                 text = _tr("not_enough_loyalty"),
                                                 leftCallBack = function() return self:getDelegate():gotoMining() end}) 
    self:getDelegate():getScene():addChild(pop,100)    
    return false
  elseif type ~= nil and type == "itemOne" and costItemNum < self.itemOneCost  then
    return  false
  elseif type ~= nil and type == "itemTen"  and costItemNum < self.itemTenCost then
    return  false
  else
    return true
  end
end

-- TODO: 判断背包是否满
function LotteryView:checkBagEnoughSpace(_type)
  local ret = true

  local package = GameData:Instance():getCurrentPackage()

  if _type == 6 and package:checkItemBagEnoughSpace(1)  == false then      
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",leftSelBtn = "button-sel-zhengli.png",text =_tr("bag is full,clean up?"),
                                                    leftCallBack = function() return self:goToItemView() end})
    self:addChild(pop,100)
    ret = false
  elseif _type == 7 and package:checkEquipBagEnoughSpace(1) == false then   
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "button-nor-zhengli.png",leftSelBtn = "button-sel-zhengli.png",text =_tr("equip bag is full,clean up?"),
                                                    leftCallBack = function() return self:goToEquipBagView() end})
    self:addChild(pop,100)
    ret = false
  elseif _type == 8 and  package:checkCardBagEnoughSpace(1) == false then   
    local pop = PopupView:createTextPopupWithPath({leftNorBtn = "lianhun0.png",leftSelBtn = "lianhun1.png",rightNorBtn = "chushou.png", rightSelBtn = "chushou1.png",text = _tr("card bag is full,clean up?"),
                                                    leftCallBack = function() return self:lianhunCallback() end,rightCallBack = function() return self:toToCardView() end})
    self:addChild(pop,100)
    ret = false
  end

  return ret
end


function LotteryView:onRightDropDownCallBack()
  self._rightIsDropping = true
  local array = CCArray:create()
  local actionTo = CCMoveBy:create(0.3,CCPointMake(0,-self.mainLeftBg:getContentSize().height))
  array:addObject(actionTo)
  local callfunc = CCCallFunc:create(function() self._rightSecondLayer:setVisible(false) self._rightIsDropping = false end)
  array:addObject(callfunc)
  local action = CCSequence:create(array)
  self.mainRightLayer:runAction(action)
end

-- 锦囊单抽
function LotteryView:onRightOneLotteryCallBack()
  print("=== onRightOneLotteryCallBack", animIsFinish)

  _playSnd(SFX_CLICK)
  if animIsFinish == false then
    return
  end
  animIsFinish = false
  self._lotteryType = "itemOne"
  local iscardBagEnough = self:checkBagEnoughSpace(8)
  local isEnoughCost = true
  if iscardBagEnough == true then
    isEnoughCost = self:isEnoughLoyaltyOrMoney("itemOne")
  else
    animIsFinish = true
    return
  end

  if iscardBagEnough == true and self._freeItemLottery == true then
    _showLoading()
    net.sendMessage(PbMsgId.FreeDrawCard)   --免费
  elseif iscardBagEnough == true then
    isEnoughCost = self:isEnoughLoyaltyOrMoney("itemOne")
    if isEnoughCost == false then
      self:goToCollectView()
    else
      self:startQuickDrawCards()
    end
  end

end

--锦囊十连抽
function LotteryView:onRightTenLotteryCallBack()
  print("=== onRightTenLotteryCallBack", animIsFinish)

  _playSnd(SFX_CLICK)
  if animIsFinish == false then
    return
  end
  animIsFinish = false
  self._lotteryType = "itemTen"
  local iscardBagEnough = self:checkBagEnoughSpace(8)
  local isEnoughCost = true

  if iscardBagEnough == true then
    isEnoughCost = self:isEnoughLoyaltyOrMoney("itemTen")
  else
    animIsFinish = true
    return
  end

  if isEnoughCost == false then  -- auto bug jinNang
    self:goToCollectView()
  else
    self:startQuickDrawCards()
  end
end


function LotteryView:showRewardNotice()
  self.noticeLayer:removeAllChildrenWithCleanup(true)
  if scheduleScrollID ~= nil then
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleScrollID)
    scheduleScrollID = nil
  end

  notifyPlayertable = {}
  local mainLayerNum = 0

  if lotteryNoticeTable ~= nil and #lotteryNoticeTable > 0 then
    print("-------count -   ", #lotteryNoticeTable)
    mainLayerNum = math.ceil(#lotteryNoticeTable / 2)
    self.noticeLayer:setContentSize(CCSizeMake(mainLayerNum*display.width,self.noticeLayer:getContentSize().height))
    print("--mainLayerNum ,mainLayerWidth---",mainLayerNum,mainLayerNum*display.width)
  end

  local function updataPos(self,dt)
    print("time is ",dt)
    print("self.noticeLayer:getPositionX()",self.noticeLayer:getPositionX())
    print("mainLayerNum",mainLayerNum)
    if self.noticeLayer:getPositionX() <= -640 * (mainLayerNum-1) then

      local array = CCArray:create()
      array:addObject(CCMoveBy:create(3.0,ccp(-640,0)))
      array:addObject(CCCallFunc:create(
        function()
          self.noticeLayer:setPositionX(640)
        end))

      local action = CCSequence:create(array)
      self.noticeLayer:runAction(action)
    else
      self.noticeLayer:runAction(CCMoveBy:create(3.0,ccp(-640,0)))
    end
  end


  local noticeNodeTable = Mall:Instance():getNoticeNode()

  if lotteryNoticeTable ~= nil and #lotteryNoticeTable >0 then
    if #lotteryNoticeTable == 1 then
      local player1 = lotteryNoticeTable[1]
      local nickName1 = player1["nickName"]
      local cardConfigId1 = player1["cardConfigId"]
      local time1 =  player1["time"]
      local notifyPlayer = CardAwardNotifyView.new()
      notifyPlayer:initData(cardConfigId1,nickName1,time1)
      notifyPlayer:setStarAndTimeInvisible()
      self.noticeLayer:addChild(notifyPlayer)
    else
      for i= 1, #lotteryNoticeTable,2 do
        local player1 = lotteryNoticeTable[i]
        local nickName1 = player1["nickName"]
        local cardConfigId1 = player1["cardConfigId"]
        local time1 =  player1["time"]
        local index = math.floor(i+1/2)
        local notifyPlayer = nil --noticeNodeTable[index]

        if (i+1) <= #lotteryNoticeTable then
          local player2 = lotteryNoticeTable[i+1]
          local nickName2 = player2["nickName"]
          local cardConfigId2 = player2["cardConfigId"]
          local time2 =  player2["time"]

          notifyPlayer =  CardAwardNotifyView.new()
          notifyPlayer:initData(cardConfigId1,nickName1,time1,cardConfigId2,nickName2,time2)
        else

          notifyPlayer = CardAwardNotifyView.new()
          notifyPlayer:initData(cardConfigId1,nickName1,time1)
        end
        notifyPlayer:setPosition(ccp((i-1)*display.width/2,-10))
        self.noticeLayer:addChild(notifyPlayer)
      end

      scheduleScrollID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(handler(self,updataPos),6.0, false)
    end
  else
    local notifyPlayer1 = CardAwardNotifyView.new()
    notifyPlayer1:initData(0,_tr("enpty_info"),0,  0,_tr("enpty_info"),0)
    self.noticeLayer:addChild(notifyPlayer1)
  end
end


function LotteryView:onAskForDrawTenCardInformationResult(action,msgId,msg)
  print("msg.key",msg.key)
  print("onAskForDrawTenCardInformationResult count == ",#msg.card)
  --notifyPlayertable ={}
  if #msg.card > 0 and msg.key >0 then
    GameData:Instance():setAskForDrawTenCardInformationResultOfData(msg)     -- 保存全局数据
    GameData:Instance():setAskForDrawTenCardInformationResultOfKey(msg.key)
    key = GameData:Instance():getAskForDrawTenCardInformationResultOfKey()
    lotteryNoticeTable = GameData:Instance():getAskForDrawTenCardInformationResultOfData()

    local function showNotice()
      self:showRewardNotice()
    end
    self:performWithDelay(showNotice,0.1)

  end
end

--免费民心抽卡
function LotteryView:onLoyaltyFreeDrawCardResult(action,msgId,msg)
  print("=== FreeLoyaltyDrawCardResult", msg.state)
  _hideLoading()
  if msg.state == "Ok" then
    self:insertRewardCard2Table(msg, true)
    self:playAnimWithType("loyaltyOne")
    local curTime = Clock:Instance():getCurServerUtcTime() 
    GameData:Instance():getCurrentPlayer():setLastLoyaltyFreeDrawTime(curTime)
    self._freeLoyaltyLottery = false
    self:updataFreeDrawState("loyaltyOne")
  end
end

--使用民心抽卡
function LotteryView:onDrawCardUseLoyaltyResult(action,msgId,msg)
  print("=== onDrawCardUseLoyaltyResult:", msg.state)
  _hideLoading()
  if msg.state == "Ok" then
    self:insertRewardCard2Table(msg) 
    self:playAnimWithType(self._lotteryType)
  end
end

--锦囊免费抽卡
function LotteryView:onFreeDrawCardResult(action,msgId,msg)
  print("=== onDrawCardUseLoyaltyResult:", msg.state)
  _hideLoading()
  if msg.state == "Ok" then
    Guide:Instance():removeGuideLayer()
    self:insertRewardCard2Table(msg, true)
    self:playAnimWithType("itemOne")
    local curTime = Clock:Instance():getCurServerUtcTime()
    GameData:Instance():getCurrentPlayer():setLastItemFreeDrawTime(curTime)
    self._freeItemLottery = false
    self:updataFreeDrawState("itemOne")
  end
end

--使用锦囊抽卡
function LotteryView:onDrawCardUseItemResult(action,msgId,msg)
  print("=== onDrawCardUseItemResult:", msg.state)
  _hideLoading()
  if msg.state == "Ok" then
    self:insertRewardCard2Table(msg)  
    self:playAnimWithType(self._lotteryType)
  end
end


function LotteryView:onQuickDrawCardUseItemResult(action,msgId,msg)
  print("=== onQuickDrawCardUseItemResult:", msg.state)
  _hideLoading()
  if msg.state == "Ok" then
    self:insertRewardCard2Table(msg) 
    self:playAnimWithType(self._lotteryType)
  end
end

function LotteryView:insertRewardCard2Table(msg, isFreeDrawCard)
  print("=== insertRewardCard2Table")
  rewardCardTable = {}
  rewardCardChipTable = {}

  if msg.client_sync.card ~= nil then
    for k,val in pairs(msg.client_sync.card) do
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

    if msg.client_sync.item ~= nil then 
      for k,val in pairs(msg.client_sync.item) do 
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
      dump(msg.cards, "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ cards map")

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
          echo("====orgCardId", v)
          chipInfo = AllConfig.unit[v].card_puzzle_drop 
          local propsItem = {iType = chipInfo[1], configId = chipInfo[2], count = chipInfo[3], orgCardId = v}
          table.insert(rewardCardChipTable, propsItem)
        end 
      end 
    end 
  end 

  GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
end

local function drawQualityFrame(parentNode,frameId) -- 4,5
  local anim,offsetX,offsetY,duration = _res(frameId)
  if anim ~= nil and parentNode ~= nil then
    parentNode:addChild(anim,10,4321)
    anim:getAnimation():play("default")
  end
end

local function setStar(self,cardHeadView)

  cardHeadView:removeChildByTag(1234)
  cardHeadView:removeChildByTag(4321)
  local cardMod = cardHeadView:getCard()
  local maxRank = cardMod:getMaxGrade()
  local curRank = cardMod:getGrade()
  local startBgIconId = {3022001,3022002,3022003,3022004,3022005 }

  local starBgLayer = CCLayerColor:create(ccc4(0,0,0,0))  -- 30,30  +10
  starBgLayer:ignoreAnchorPointForPosition(false)
  starBgLayer:setAnchorPoint(ccp(0.5,1))
  local cardSize =  cardHeadView:getContentSize()

  starBgLayer:setPosition(ccp(0,-40.0))
  cardHeadView:addChild(starBgLayer,100,1234)

  for i = 1, maxRank, 1 do
    local starId = 0
    if i<= curRank then
      starId = 3022006 --亮星星
    else
      starId = startBgIconId[curRank]
    end
    local startBg = _res(starId)
    startBg:setAnchorPoint(ccp(0,0.5))
    startBg:setPosition(ccp((i-1)*25,startBg:getContentSize().height/2.0))
    starBgLayer:addChild(startBg)
  end
  starBgLayer:setContentSize(CCSizeMake(maxRank*25,30))
  starBgLayer:setScale(0.8)

  if maxRank == 4 then
    drawQualityFrame(cardHeadView,5020170)
  elseif maxRank == 5 then
    drawQualityFrame(cardHeadView,5020171)
  end
end


function LotteryView:playAnimWithType(type)  --播放抽卡动画
  
  self._cardParts = {} 
  
  local node = display.newNode()
  node:setPosition(ccp(0,0))
  node:setCascadeOpacityEnabled(true)

  if self._popupNode ~= nil then
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

    pkg:addFunc("singleDrawEndCallBack",LotteryView.onAnimFinishForSingleDraw)

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
    pkg:addFunc("multiDrawFinishCallBack",LotteryView.onMultiDrawFinishCallBack)
    pkg:addFunc("DrawTenTimeCallBack",LotteryView.OnDrawTenTimeAgainCallBack)  -- 再抽10次按钮
    pkg:addFunc("confirmCallBack",LotteryView.onConfirmCallBack)          -- 确定按钮
    pkg:addFunc("lianhunCallback",LotteryView.lianhunCallback)
    
    local layer,owner = ccbHelper.load("anim_MultiDraw.ccbi","MultiDrawCCB","CCLayer",pkg)
    layer:setTouchEnabled(true)
    layer:addTouchEventListener(handler(self,self.onTouch),false,-1128,true)
  
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
        setStar(self,cardHead) 
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
      self.costNum:setString(self.itemTenCost .."")
    end

    mask:addChild(layer)
    self._lotteryTenAnimLayer = layer

    self.mAnimationManager:runAnimationsForSequenceNamed("MultiDraw")
  end
end

function LotteryView:onAnimFinishForSingleDraw()
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

  if isGainedCard == false then 
    
    self:performWithDelay(
      function()
        local function scaleEnd()
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


function LotteryView:onMultiDrawFinishCallBack()
  local array = CCArray:create()
  local actionTo = CCMoveTo:create(0.3,CCPointMake(display.cx,self.enevtNode:getPositionY()))
  array:addObject(actionTo)
  array:addObject(CCDelayTime:create(2.0))
  array:addObject(CCCallFunc:create(function() animIsFinish = true end))
  local action = CCSequence:create(array)
  self.enevtNode:runAction(action)
end

function LotteryView:OnDrawTenTimeAgainCallBack()
  print("OnDrawTenTimeAgainCallBack")
  if animIsFinish == false then 
    return 
  end 

  if self._lotteryTenAnimLayer ~= nil then
    self._lotteryTenAnimLayer:getParent():removeFromParentAndCleanup(true)
    self._lotteryTenAnimLayer = nil 
  end

  if self._lotteryType == "loyaltyTen" then
    self:onLeftTenLotteryCallBack()
  elseif self._lotteryType == "itemTen" then
    self:onRightTenLotteryCallBack()
  end
end

function LotteryView:onConfirmCallBack()
  print("onConfirmCallBack")
  if animIsFinish == false then 
    return 
  end 

  if self._lotteryTenAnimLayer ~= nil then
    self._lotteryTenAnimLayer:getParent():removeFromParentAndCleanup(true)
    self._lotteryTenAnimLayer = nil 
  end
end

function LotteryView:lianhunCallback() -- 跳到炼魂界面
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

function LotteryView:goToItemView() -- 跳到行囊界面
  local bagController = ControllerFactory:Instance():create(ControllerType.BAG_CONTROLLER)
  bagController:enter()
end

function LotteryView:toToCardView() -- 跳到卡牌界面
  local cardBagController =  ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  cardBagController:enter()
end

function LotteryView:goToEquipBagView() -- 跳到装备背包界面
  local cardBagController = ControllerFactory:Instance():create(ControllerType.CARDBAG_CONTROLLER)
  cardBagController:enter(true)
end

function LotteryView:startQuickDrawCards()
  print("LotteryView:startQuickDrawCards")

  local costItemId = 0
  local _type = 1

  if self._lotteryType == "itemOne"  then
    costItemId  = AllConfig.guidebonus[1].item_id
    _type = 1
  elseif self._lotteryType == "itemTen" then
    costItemId  = AllConfig.guidebonus[2].item_id
    _type = 2 
  end

  local shopItem = Shop:instance():getShopItemByConfigId(ShopCurViewType.DianCang, costItemId)
  if shopItem ~= nil then 
    local data = PbRegist.pack(PbMsgId.QuickDrawCardUseItem,{config_id = _type, cell_id=shopItem:getId()})
    _showLoading()
    net.sendMessage(PbMsgId.QuickDrawCardUseItem, data)
  end 
end 

function LotteryView:goToCollectView()

  -- 锦囊不足的时候，后台替玩家 花费元宝购买锦囊 保证抽卡成功
  local lotteryOneCost = AllConfig.guidebonus[1].cost
  local lotteryTenCost = AllConfig.guidebonus[2].cost

  local costItemNum = 0 --已经有的锦囊数
  local costItemId = 0
  local needPayItemNum = 0

  if self._lotteryType == "itemOne"  then
    costItemId  = AllConfig.guidebonus[1].item_id
    costItemNum = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(costItemId)
    needPayItemNum = lotteryOneCost - costItemNum

  elseif self._lotteryType == "itemTen" then
    costItemId  = AllConfig.guidebonus[2].item_id
    costItemNum = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(costItemId)
    needPayItemNum = lotteryTenCost - costItemNum
  end

  local itemCost = AllConfig.guidebonus[1].quick_money_cost 
  local totalCost = needPayItemNum *itemCost

  local function checkIsAutoBuy()
    animIsFinish = false

    local function gotoPayView()
      local shopController = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
      shopController:enter(ShopCurViewType.PAY)
    end

    if GameData:Instance():getCurrentPlayer():getMoney() < totalCost then -- 元宝不够支付锦囊购买的
      animIsFinish = true
      local pop = PopupView:createTextPopupWithPath({text = _tr("money_limit_ask"),leftCallBack = function() return gotoPayView() end})
      self:getDelegate():getScene():addChild(pop,100)
    else
      self:startQuickDrawCards()
      return true
    end
  end

  if needPayItemNum > 0 then
    animIsFinish = true
    local strTip = _tr("Need to boot%s{count}%{count}",{count =needPayItemNum,count =totalCost}) --string.format("锦囊不足(还需要%d个)，是否花费%d元宝进行补足差价",needPayItemNum,totalCost)
    local pop = PopupView:createTextPopupWithPath({text = strTip, leftCallBack = function() return checkIsAutoBuy() end})
    self:addChild(pop,100,12456)
  end

  -- check pop is demise
  local action = nil
  local function popIsDemise()
    local pop = self:getChildByTag(12456)
    if pop == nil then
      animIsFinish = true
      self:stopAction(action)
    end
  end
  action = self:schedule(popIsDemise,2.0)
end


function LotteryView:onExit()
  print("LotteryView:onExit")

  animIsFinish = true
  net.unregistAllCallback(self)
  
  if scheduleScrollID ~= nil then
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleScrollID)
    scheduleScrollID = nil
  end
end

function LotteryView:exit()
  print("LotteryView:exit()")
end

function LotteryView:onHelpHandler()
  local help = HelpView.new()
  help:addHelpBox(1018,nill,true)
  self:getDelegate():getScene():addChild(help, 1000)
end

function LotteryView:onBackHandler()
  LotteryView.super:onBackHandler()
  self:getDelegate():goBackView()
end


function LotteryView:getLeftTimeForFree(dir)
  local leftSec = 0 
  local curTime = Clock:Instance():getCurServerUtcTime()
  if dir == "left" then 
    leftSec = GameData:Instance():getCurrentPlayer():getLastLoyaltyFreeDrawTime()+AllConfig.characterinitdata[31].data*60 - curTime 
  else 
    leftSec = GameData:Instance():getCurrentPlayer():getLastItemFreeDrawTime() + AllConfig.characterinitdata[23].data*60 - curTime
  end 

  echo("getLeftTimeForFree:", dir, leftSec)
  return leftSec 
end 

function LotteryView:addMaskLayer()
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1500})
  self:addChild(self.maskLayer)
  
  self:performWithDelay(handler(self, LotteryView.removeMaskLayer), 6.0)
end 

function LotteryView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 
end 


return LotteryView
