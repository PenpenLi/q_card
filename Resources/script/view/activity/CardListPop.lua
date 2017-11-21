
require("view.BaseView")
require("view.component.TabControlEx")

CardListPop = class("CardListPop", BaseView)

function CardListPop:ctor(listData)
  CardListPop.super.ctor(self)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("node_TabMenu","CCNode") 
  pkg:addProperty("node_list","CCNode") 
  pkg:addProperty("sprite9_bg","CCScale9Sprite")
  pkg:addProperty("layer_mask","CCLayerColor")


  local layer,owner = ccbHelper.load("CardListPop.ccbi","CardListPopCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.priority = -200
  self.listData = listData 

  local menuArray = {}
  for k, v in pairs(self.listData) do 
    table.insert(menuArray, v.menu)
  end 
  if #menuArray > 0 then 
    self.tabCtrl = TabControlEx.new(CCSizeMake(552, 74), nil, self.priority)
    self.tabCtrl:setDelegate(self)
    self.node_TabMenu:addChild(self.tabCtrl)
    self.tabCtrl:setMenuArray(menuArray)

    self.tabCtrl:setItemSelectedByIndex(1)
  end 
end

function CardListPop:onEnter()
  
  --reg touch event
  self:addTouchEventListener(function(event, x, y)
                                if event == "began" then
                                  self.preTouchFlag = self:checkTouchOutsideView(x, y)
                                  return true
                                elseif event == "ended" then
                                  local curFlag = self:checkTouchOutsideView(x, y)
                                  if self.preTouchFlag == true and curFlag == true then
                                    echo(" touch out of region: close popup") 
                                    self:closeCallback()
                                  end 
                                end
                            end,
              false, self.priority+1, true)
  self:setTouchEnabled(true)

  if self.listData[1] and self.listData[1].data then 
    self:showCardList(self.listData[1].data)
  end 
end 

function CardListPop:onExit()
end 

function CardListPop:checkTouchOutsideView(x, y)
  local size = self.sprite9_bg:getContentSize()
  local pos = self.sprite9_bg:convertToNodeSpace(ccp(x, y))
  if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
    return true 
  end

  return false  
end 

function CardListPop:closeCallback()
  self:removeFromParentAndCleanup(true)
end 

function CardListPop:tabControlOnClick(idx)
  _playSnd(SFX_CLICK) 

  self:showCardList(self.listData[idx+1].data)

  return true
end 


function CardListPop:showCardList(itemArray)
  if itemArray == nil then 
    return 
  end 

  self.node_list:removeAllChildrenWithCleanup(true)

  local ViewSize = self.node_list:getContentSize()
  local grid_w = 110
  local grid_h = 110 

  --先创建scrollview
  local node = display.newNode()
  local nodeSize = CCSizeMake(ViewSize.width, math.ceil(#itemArray/5)*grid_h+20)
  node:setContentSize(nodeSize)

  local x, y
  for k, v in pairs(itemArray) do 
    x = (k-1)%5 * grid_w + grid_w/2 
    y = nodeSize.height - math.floor((k-1)/5)*grid_h - grid_h/2
    
    local card 
    if type(v) == "number" then --root id
      card = GameData:Instance():getCurrentPlayer():getIllustratedInstance():getCardByUnitRoot(v)
    else --card mode 
      card = v 
    end 
    if card then 
      local cardView = CardHeadView.new()
      cardView:setCard(card)
      cardView:setScale(0.85)
      cardView:enableClick(true)
      cardView:setClickCallback(handler(self, CardListPop.onClickHead))
      cardView:setPosition(ccp(x, y))
      node:addChild(cardView)

      local name = CCLabelTTF:create(card:getName(),"Courier-Bold",20)
      name:setColor(ccc3(255, 239, 165))
      name:setPosition(ccp(x, y-50))
      node:addChild(name)
    end 
  end 


  local scrollView = CCScrollView:create()
  self.node_list:addChild(scrollView)

  scrollView:setViewSize(ViewSize)
  scrollView:setDirection(kCCScrollViewDirectionVertical)
  scrollView:setClippingToBounds(true)
  scrollView:setBounceable(true)
  scrollView:setContentSize(nodeSize)
  scrollView:setContainer(node)
  node:setPosition(ccp(0, ViewSize.height - nodeSize.height))
  scrollView:setTouchPriority(-1300)
end 

function CardListPop:setUserCallback(callback)
  self._userCallback = callback 
end 

function CardListPop:onClickHead(card)
  echo("===onClickHead")
  if card then 
    if self._userCallback then 
      self._userCallback(card)
      self:closeCallback()
    else 
      local orbitCard = OrbitCard.new({configId = card:getConfigId() })
      orbitCard:show()
    end 
  else 
    echo("== invalid card")
  end 
end 

