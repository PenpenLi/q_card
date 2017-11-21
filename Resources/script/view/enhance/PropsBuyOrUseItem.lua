
require("view.BaseView")

PropsBuyOrUseItem = class("PropsBuyOrUseItem", BaseView)


function PropsBuyOrUseItem:ctor()
  PropsBuyOrUseItem.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("decCallback",PropsBuyOrUseItem.decCallback)
  pkg:addFunc("incCallback",PropsBuyOrUseItem.incCallback)
  pkg:addFunc("maxCallback",PropsBuyOrUseItem.maxCallback)
  pkg:addFunc("buyUseCallback",PropsBuyOrUseItem.buyUseCallback)
  pkg:addFunc("useCallback",PropsBuyOrUseItem.useCallback)


  pkg:addProperty("node_info","CCNode")
  pkg:addProperty("node_buyInfo","CCNode")
  pkg:addProperty("node_propsImg","CCNode")
  pkg:addProperty("node_coin","CCNode")
  pkg:addProperty("node_detail","CCNode")
  pkg:addProperty("sprite9_input","CCScale9Sprite")

  pkg:addProperty("bn_jian","CCControlButton")
  pkg:addProperty("bn_jia","CCControlButton")
  pkg:addProperty("bn_max","CCControlButton")
  pkg:addProperty("bn_buyAndUse","CCControlButton")
  pkg:addProperty("bn_use","CCControlButton")

  pkg:addProperty("label_propsName","CCLabelTTF")
  pkg:addProperty("label_propsPrice","CCLabelTTF")
  pkg:addProperty("label_propsDesc","CCLabelTTF")
  pkg:addProperty("label_preTotalCost","CCLabelTTF")
  pkg:addProperty("label_totalCost","CCLabelTTF")

  local layer,owner = ccbHelper.load("PropsBuyOrUseItem.ccbi","PropsBuyOrUseItemCCB","CCLayer",pkg)
  self:addChild(layer)
end



function PropsBuyOrUseItem:setData(props, isBuy)
  self.props = props
  self.isBuy = isBuy
  self.number = 1
  self.totalPropsNum = props:getCount()

  --icon
  local configId = props:getConfigId()
  local node = GameData:Instance():getCurrentPackage():getItemSprite(nil, 6, configId, 1)
  if node ~= nil then 
    self.node_propsImg:addChild(node)
    self.propsNumLabel = CCLabelBMFont:create("1", "client/widget/words/card_name/number_skillup.fnt")
    if self.propsNumLabel ~= nil then 
      node:addChild(self.propsNumLabel)

      if self.totalPropsNum > 0 then 
        self.propsNumLabel:setVisible(true)
        local iconWidth = 95 
        local numStr = string.format("%d", self.totalPropsNum)
        self.propsNumLabel:setString(numStr)
        local labelSize = tolua.cast(self.propsNumLabel:getContentSize(),"CCSize")  
        self.propsNumLabel:setPosition(ccp(iconWidth/2-labelSize.width/2-7, -iconWidth/2+labelSize.height/2+7))
      else 
        self.propsNumLabel:setVisible(false) 
      end 
    end 

    self:updatePropsNum(self.number)
  end 

  --name
  self.label_propsName:setString("")
  self.pOutLinePropName = ui.newTTFLabelWithOutline( {
                                            text = props:getName(),
                                            font = "Courier-Bold",
                                            size = 24,
                                            x = 0,
                                            y = 0,
                                            color = ccc3(255, 234, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = CCSize(200, 30),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )
  self.pOutLinePropName:setPosition(ccp(self.label_propsName:getPosition()))
  self.label_propsName:getParent():addChild(self.pOutLinePropName)  

  self.selectedNum = 1

  if isBuy then 
    self.node_coin:setVisible(true)
    self.bn_use:setVisible(false)

    self.buyPrice = AllConfig.shop[1].sell_price
    if configId == AllConfig.shop[2].item then 
      self.buyPrice = AllConfig.shop[2].sell_price
    elseif configId == AllConfig.shop[3].item then 
      self.buyPrice = AllConfig.shop[3].sell_price
    end 
    self.label_propsPrice:setString(string.format("%d", self.buyPrice))
    self.label_preTotalCost:setString(_tr("total_cost"))
    self.label_totalCost:setString(string.format("%d", self.buyPrice*self.selectedNum))
  else 
    self.node_coin:setVisible(false)
    self.bn_buyAndUse:setVisible(false)
    self.bn_use:setVisible(true)
    self.label_propsDesc:setString(props:getDescStr())
  end 

  self:initInputEditor()
end 

function PropsBuyOrUseItem:updatePropsNum(inputNum)
  if self.inputBox ~= nil then 
    self.inputBox:setText(string.format("%d",inputNum))
    if self.isBuy then 
      self.label_totalCost:setString(string.format("%d", inputNum*self.buyPrice))
    end 
  end 
end 

function PropsBuyOrUseItem:setDetailVisible(isVisible)
  self.node_detail:setVisible(isVisible)
  self.node_buyInfo:setVisible(self.isBuy)
  if isVisible == false then 
    self.node_info:setPositionY(0)
  end 
end 

function PropsBuyOrUseItem:initInputEditor()
  local function editBoxTextEventHandle(strEventName,pSender)

    if strEventName == "began" then
    elseif strEventName == "changed" then
    elseif strEventName == "ended" then
    elseif strEventName == "return" then
      local maxNum = 50 
      if self.isBuy then 
        local coin = GameData:Instance():getCurrentPlayer():getCoin()
        local canBuyNum = math.floor(coin/self.buyPrice)
        maxNum = math.min(50, canBuyNum)
      end 

      self.number = toint(self.inputBox:getText())      
      if self.number > maxNum then 
        self.number = maxNum
      elseif self.number <= 0 then 
        self.number = 0
      end
      self:updatePropsNum(self.number)
    end
  end

  self.inputBox = UIHelper.convertBgToEditBox(self.sprite9_input,string.format("%d", self.number),22,ccc3(69,20,1))
  self.inputBox:setMaxLength(6)
  self.inputBox:setInputMode(kEditBoxInputModeNumeric)
  self.inputBox:setTouchPriority(self.priority)
  self.inputBox:registerScriptEditBoxHandler(editBoxTextEventHandle)
end 

function PropsBuyOrUseItem:setIdx(idx)
  self.idx = idx
end 

function PropsBuyOrUseItem:getIdx()
  return self.idx
end

function PropsBuyOrUseItem:onEnter()
  -- echo("---PropsBuyOrUseItem:onEnter---")
end 

function PropsBuyOrUseItem:onExit()
  -- echo("---PropsBuyOrUseItem:onExit---")
  net.unregistAllCallback(self)
end 


function PropsBuyOrUseItem:decCallback()
  if self.inputBox ~= nil then 
    if self.number > 1 then 
      self.number = self.number - 1 
      self:updatePropsNum(self.number)
    end 
  end 
end 

function PropsBuyOrUseItem:incCallback()
  if self.inputBox ~= nil then 
    local maxNum = nil 
    if self.isBuy then
      local coin = GameData:Instance():getCurrentPlayer():getCoin()
      local canBuyNum = math.floor(coin/self.buyPrice)
      maxNum = math.min(50, canBuyNum)
    else 
      maxNum = math.min(50, self.totalPropsNum)
    end 
    self.number = math.min(self.number+1, maxNum)
    self:updatePropsNum(self.number)
  end 
end 

function PropsBuyOrUseItem:maxCallback()
  if self.isBuy then 
    local coin = GameData:Instance():getCurrentPlayer():getCoin()
    local canBuyNum = math.floor(coin/self.buyPrice)
    self.number = math.min(50, canBuyNum)
    self.label_totalCost:setString(string.format("%d", self.number*self.buyPrice))
  else 
    self.number = math.min(50, self.totalPropsNum)
  end 
  self:updatePropsNum(self.number)  
end 

function PropsBuyOrUseItem:buyUseCallback()
  echo("=== buyUseCallback, num=", self.number)
  if self:getDelegate():onValidTouch() == false then 
    echo("==== touch outside..")
    return 
  end 

  local coin = GameData:Instance():getCurrentPlayer():getCoin()
  if self.number > 0 and coin >= self.number*self.buyPrice then 
    if self:getDelegate()~= nil then 
      self:getDelegate():buyAndUseExpCard(self.props:getId(), self.number, self:getIdx())
    end 
  else 
    Toast:showString(self, _tr("not enough coin"), ccp(display.width/2, display.height*0.4))
  end
end 

function PropsBuyOrUseItem:useCallback()
  echo("=== useCallback, num=", self.number)
  if self:getDelegate():onValidTouch() == false then 
    echo("==== touch outside..")
    return 
  end 

  if self.number > 0 then 
    self:getDelegate():openBox(self.props:getId(), self.number, self:getIdx())
  else 
    Toast:showString(self, _tr("wrong number"), ccp(display.width/2, display.height*0.4))
  end 
end 

function PropsBuyOrUseItem:setTouchPriority(priority)
  self.priority = priority

  self.bn_jian:setTouchPriority(self.priority)
  self.bn_jia:setTouchPriority(self.priority)
  self.bn_max:setTouchPriority(self.priority)
  self.bn_buyAndUse:setTouchPriority(self.priority)
  self.bn_use:setTouchPriority(self.priority)

  self:addTouchEventListener(handler(self,self.onTouch), false, self.priority+1, true)
  self:setTouchEnabled(true)
end 

function PropsBuyOrUseItem:onTouch(event, x,y)

  if event == "began" then

    if self.node_detail:isVisible() == false then 
      return false
    end 

    local size = self.node_detail:getContentSize()
    local pos = self.node_detail:convertToNodeSpace(ccp(x, y))
    if pos.x > 0 and pos.x < size.width and pos.y > 0 and pos.y < size.height then 
      return true 
    end 

    return false 

  elseif event == "ended" then
  end
end 