require("view.component.RichText")
PvpRankMatchRuleView = class("PvpRankMatchRuleView",BaseView)
function PvpRankMatchRuleView:ctor()
  PvpRankMatchRuleView.super.ctor(self)
  self:setNodeEventEnabled(true)
  
   --color layer
  local layerColor = CCLayerColor:create(ccc4(0,0,0,168), display.width*2.0, display.height*2.0)
  self:addChild(layerColor)
  
  local popSize = CCSizeMake(615,800)
  
  local bg = display.newScale9Sprite("#rank_match_bg.png",display.cx,display.cy,popSize)
  self:addChild(bg)
  self._popupBg = bg
  
  local titleBg = display.newScale9Sprite("#rank_match_title_bg.png",0,0,CCSizeMake(popSize.width,67))
  self:addChild(titleBg)
  titleBg:setPosition(ccp(display.cx,display.cy + popSize.height/2 - titleBg:getContentSize().height/2 ))
  self._titleBg = titleBg
  
  local titleStr = display.newSprite("#rank_match_rule_title.png")
  titleBg:addChild(titleStr)
  titleStr:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2)
  
--  local label = CCLabelBMFont:create(self._currentCount.."/"..self._maxCount, "client/widget/words/card_name/number_skillup.fnt")
--  titleBg:addChild(label)
--  label:setPosition(ccp(215,50))

  self:setTouchEnabled(true)
  self:addTouchEventListener(function() return true end,false,-128,true)
  
  local nor = display.newSprite("#rank_match_close.png")
  local sel = display.newSprite("#rank_match_close.png")
  local dis = display.newSprite("#rank_match_close.png")
  local closeBtn = UIHelper.ccMenuWithSprite(nor,sel,dis,
      function()
        self:removeFromParentAndCleanup(true)
      end)
  self:addChild(closeBtn)
  closeBtn:setPositionX(display.cx + popSize.width/2 - nor:getContentSize().width/2 + 10)
  closeBtn:setPositionY(display.cy + popSize.height/2 - nor:getContentSize().height/2 + 10)
  closeBtn:setTouchPriority(-128)
  
  self:buildList()
end

function PvpRankMatchRuleView:buildList()
  
  local ruleNode = display.newNode()
  ruleNode:setAnchorPoint(ccp(0,0))
  ruleNode:setContentSize(CCSizeMake(600,800))
  
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("labelCurrentRankTitle","CCLabelTTF")
  pkg:addProperty("labelCurrentRank","CCLabelTTF")
  pkg:addProperty("labelKeep","CCLabelTTF")
  pkg:addProperty("labelMoney","CCLabelTTF")
  pkg:addProperty("labelCoin","CCLabelTTF")
  pkg:addProperty("labelItem","CCLabelTTF")
  pkg:addProperty("nodeItem","CCNode")
  pkg:addProperty("labelHistoryTitle","CCLabelTTF")
  pkg:addProperty("labelHistory","CCLabelBMFont")
  pkg:addProperty("labelRule","CCLabelTTF")
  local ruleCCbi,owner = ccbHelper.load("pvp_rank_match_rule.ccbi","pvp_rank_match_rule","CCNode",pkg)
  ruleNode:addChild(ruleCCbi)
  
  local mSize = CCSizeMake(self._popupBg:getContentSize().width,self._popupBg:getContentSize().height - self._titleBg:getContentSize().height - 15)

  self._scrollView = CCScrollView:create()
  self._scrollView:setViewSize(mSize)
  self._scrollView:setDirection(kCCScrollViewDirectionVertical)
  self._scrollView:setClippingToBounds(true)
  self._scrollView:setBounceable(true)
  
  self._scrollView:setContainer(ruleNode)
  
  self._popupBg:addChild(self._scrollView)
  self._scrollView:setPosition(32,15)
  
  ruleNode:setPosition(ccp(0, self._scrollView:getViewSize().height - ruleNode:getContentSize().height))
  self._scrollView:setContentSize(ruleNode:getContentSize())
  
  self._scrollView:setTouchPriority(-128)
  
  self.labelMoney:setString("0")
  
  local selfPlayer = PvpRankMatch:Instance():getSelfPlayer()
  local currentRank = selfPlayer:getRank()
  local maxRank = selfPlayer:getMaxRank()
  self.labelCurrentRank:setString(currentRank.."")
  self.labelHistory:setString(maxRank.."")
  self.labelCurrentRankTitle:setString(_tr("pvp_rank_match_current_rank"))
  self.labelKeep:setString(_tr("pvp_rank_match_award_tip")..":")
  self.labelHistoryTitle:setString(_tr("pvp_rank_match_history_rank")..":")
  local awardArray = {}
  --award info
  for key, awardInfo in pairs(AllConfig.rank_match_award) do
  	if awardInfo.type == 1 and currentRank >= awardInfo.min_rank and currentRank <= awardInfo.max_rank then
  	 awardArray = awardInfo.award
  	 break
  	end
  end
  
  local drops = GameData:Instance():getItemsWithDropsArray(awardArray)
  dump(drops)
  for key, dropItem in pairs(drops) do
  	if dropItem.type == 4 then
  	 self.labelCoin:setString("x "..dropItem.count)
  	elseif dropItem.type == 5 then
  	 self.labelMoney:setString("x "..dropItem.count)
  	else
  	 local dropItemView = DropItemView.new(dropItem.configId,1,dropItem.type)
  	 self.nodeItem:addChild(dropItemView)
  	 dropItemView:setScale(0.4)
  	 self.labelItem:setString("x "..dropItem.count)
  	end
  end
  local str = _tr("pvp_rank_match_rule")
  local labelDesc = RichText.new(str, 475, 0, "Courier-Bold", 21)
  local textSize = labelDesc:getTextSize()
  self.labelRule:setString("")
  self.labelRule:addChild(labelDesc)
  labelDesc:setPositionY(-labelDesc:getTextSize().height)
  
end

return PvpRankMatchRuleView