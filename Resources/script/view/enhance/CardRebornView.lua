require("view.BaseView")
require("view.enhance.CardRebornPop")

CardRebornView = class("CardRebornView", BaseView)

function CardRebornView:ctor()
  CardRebornView.super.ctor(self)

  --1. load levelup view ccbi
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("previewCallback",CardRebornView.previewCallback)

  pkg:addProperty("node_select","CCNode")
  pkg:addProperty("node_touchRect","CCNode")
  pkg:addProperty("node_info","CCNode")
  pkg:addProperty("node_card","CCNode")

  pkg:addProperty("sprite_lv","CCSprite")
  pkg:addProperty("sprite_star1","CCSprite")
  pkg:addProperty("sprite_star2","CCSprite")
  pkg:addProperty("sprite_star3","CCSprite")
  pkg:addProperty("sprite_star4","CCSprite")
  pkg:addProperty("sprite_star5","CCSprite")
  pkg:addProperty("sprite_star6","CCSprite")
  pkg:addProperty("sprite_star7","CCSprite")
  pkg:addProperty("sprite_star8","CCSprite")
  pkg:addProperty("sprite_star9","CCSprite")
  pkg:addProperty("sprite_star10","CCSprite")
  pkg:addProperty("label_name","CCLabelTTF")
  pkg:addProperty("label_level","CCLabelBMFont")
  pkg:addProperty("label_subRare","CCLabelBMFont")

  local layer,owner = ccbHelper.load("CardRebornView.ccbi","CardRebornViewCCB","CCLayer",pkg)
  self:addChild(layer)


  -- net.registMsgCallback(PbMsgId.UpdateCardSkillExperienceResult, self, CardRebornView.cardSkillUpResult)
end

function CardRebornView:onEnter()
  self:init()

  self:updateView()
end 

function CardRebornView:onExit()
  net.unregistAllCallback(self)
end 

function CardRebornView:init()
  self.priority = 0 

  self:addTouchEventListener(function(event, x, y)
                                if event == "began" then 
                                  local size = self.node_touchRect:getContentSize()
                                  local pos = self.node_touchRect:convertToNodeSpace(ccp(x, y))
                                  if pos.x > 0 and pos.x < size.width and pos.y > 0 and pos.y < size.height then 
                                    self:selectCallback()
                                  end

                                  return true 
                                end 
                            end,
                            false, self.priority+1, true)
  self:setTouchEnabled(true)
end 

function CardRebornView:showNode(index)
  if index == 1 then 
    self.node_select:setVisible(true)
    self.node_info:setVisible(false)
  elseif index == 2 then 
    self.node_select:setVisible(false)
    self.node_info:setVisible(true)
    self.node_card:removeAllChildrenWithCleanup(true)
    if self.card then 
      local resId = AllConfig.unit[self.card:getConfigId()].unit_pic 
      local pic = _res(resId)
      if pic then 
        pic:setAnchorPoint(ccp(0.5, 0))
        self.node_card:addChild(pic)
      end 
      self.label_name:setString(self.card:getName())      
      self.sprite_lv:setPositionX(self.label_name:getPositionX()+self.label_name:getContentSize().width+30)
      self.label_level:setPositionX(self.sprite_lv:getPositionX()+40)
      self.label_level:setString(self.card:getLevel())

      self:showGradeStar(self.card:getGrade(), self.card:getMaxGrade())
    end 
  end 
end 

function CardRebornView:showGradeStar(starNum, maxNum)
  local starArray = {self.sprite_star1, self.sprite_star2, self.sprite_star3, self.sprite_star4, self.sprite_star5,
                     self.sprite_star6, self.sprite_star7, self.sprite_star8, self.sprite_star9, self.sprite_star10}
  local starW = self.sprite_star1:getContentSize().width
  local start_x = self.sprite_star1:getPositionX() 

  for i=1, 10 do 
    starArray[i]:setVisible(false)
  end

  for i=1, maxNum do 
    if i <= starNum then 
      starArray[5+i]:setVisible(true)
      starArray[5+i]:setPositionX(start_x)
    end 
    starArray[i]:setVisible(true)
    starArray[i]:setPositionX(start_x)
    start_x = start_x + starW + 6 
  end 
    local subRare = AllConfig.unit[self.card:getConfigId()].card_improve
    if subRare > 0 then 
      self.label_subRare:setVisible(true)
      if self.card:getGrade() <= 3 then 
        self.label_subRare:setFntFile("client/widget/words/change_number/change_number_blue.fnt")
      else 
        self.label_subRare:setFntFile("client/widget/words/change_number/change_number_purple.fnt")
      end 
      self.label_subRare:setPositionX(starArray[maxNum]:getPositionX()+30)
      self.label_subRare:setString(string.format("+%d", subRare))
    else 
      self.label_subRare:setVisible(false)
    end 
end 

function CardRebornView:updateView()
  local rebornCards = CardSoul:instance():getRebornCards()
  if #rebornCards > 0 then 
    self.card = rebornCards[1]
    self:showNode(2)
  else 
    self.card = nil 
    self:showNode(1)
  end 
end 

function CardRebornView:selectCallback()
  self:getDelegate():disPlayCardListForReborn()
end 

function CardRebornView:previewCallback()
  local pop = CardRebornPop.new(self.card, self.priority-2)
  pop:setDelegate(self)
  self:getDelegate():getScene():addChildView(pop)
end 

function CardRebornView:onHelpHandler()
  local help = HelpView.new()
  help:addHelpBox(1059,nil,true)
  self:getDelegate():getScene():addChild(help, 1000)  
end 

function CardRebornView:addMaskLayer()
  echo("=== addMaskLayer")
  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
  end 

  self.maskLayer = Mask.new({opacity=0, priority = -1000})
  self:addChild(self.maskLayer)

  self.maskLayerTimer = self:performWithDelay(handler(self, CardRebornView.removeMaskLayer), 6.0)
end 

function CardRebornView:removeMaskLayer()
  echo("=== removeMaskLayer")
  if self.maskLayerTimer then    
    self:stopAction(self.maskLayerTimer)
    self.maskLayerTimer = nil 
  end 

  if self.maskLayer ~= nil then 
    self.maskLayer:removeFromParentAndCleanup(true)
    self.maskLayer = nil 
  end 

  if self.loading ~= nil then 
    self.loading:remove()
    self.loading = nil
  end  
end 
