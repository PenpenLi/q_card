CardFormationCombineSkillView = class("CardFormationCombineSkillView",BaseView)
function CardFormationCombineSkillView:ctor(cardFormationView)

  local layerColor = CCLayerColor:create(ccc4(0,0,0,200), display.width*2.0, display.height*2.0)
  self:addChild(layerColor)

  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("closeMenu","CCMenu")
  pkg:addProperty("nodeSkillDesc","CCNode")
  pkg:addProperty("bgsprite","CCScale9Sprite")
  pkg:addProperty("sprite_son_bg1","CCScale9Sprite")
  pkg:addProperty("labelCurrentActiveCount","CCLabelTTF")
  
  for i = 1, 4 do
    pkg:addProperty("person"..i,"CCLabelTTF")
    pkg:addProperty("buff"..i,"CCLabelTTF")
  end
  
  pkg:addFunc("closeHandler",function()
    self:onCloseHandler()
  end)
  local layer,owner = ccbHelper.load("card_formation_commbineskill.ccbi","card_formation_commbineskill","CCLayer",pkg)
  self:addChild(layer)
  
  local configId = cardFormationView:getCurrentShowCard():getConfigId()
  
  local activeCount = 0
  local cardRoots = AllConfig.unit[configId].activate_units
  for key, cardRoot in pairs(cardRoots) do
  	if cardFormationView:checkIsbattleCard(cardRoot) == true then
  	  activeCount = activeCount + 1
  	end
  end
  
  self.labelCurrentActiveCount:setString(_tr("current_playstates_count%{count}",{count = activeCount}))
  
  local comboSkillId = AllConfig.unit[configId].combined_skill
  local isActiveComboSkill = nil
  if comboSkillId ~= nil and comboSkillId > 0 then
    local skillName = AllConfig.cardskill[comboSkillId].skill_name
    local isActive, comboSkillInfo = cardFormationView:formatComboSkillName(comboSkillId)
    local dimension = CCSizeMake(435, 0)
    local color = ccc3(255, 255, 255)
    local label = RichLabel:create("「"..skillName.."」:"..comboSkillInfo,"Courier-Bold",20, dimension, true,false)
    label:setColor(color)
    local labelSize = label:getTextSize()
    label:setPositionY(labelSize.height/2)
    self.nodeSkillDesc:addChild(label)
  else
    local label = CCLabelTTF:create(_tr("none"),"Courier-Bold",20)
    label:setAnchorPoint(ccp(0,0.5))
    local color = ccc3(255, 255, 255)
    label:setColor(color)
    self.nodeSkillDesc:addChild(label)
  end
  
 
  local buffId = AllConfig.cardskill[comboSkillId].buffs[1]
  local buffType = AllConfig.skillbuff[buffId].buff_type
  
  local totalUnitCount = #AllConfig.unit[configId].activate_units
  
  for i = 1, 4 do
    print(self["person"..i],i,"label")
    self["person"..i]:setString("")
    self["buff"..i]:setString("")
  end
  if totalUnitCount >= 2 then
    for i = 2, totalUnitCount do
      for key, var in pairs(AllConfig.combineskillgrow) do
      	if buffType == var.buff_type and i == var.active_card_counts then
      	   local buffValue = var.value_revise[1].array[2]
      	   local strIdx = i - 1
      	   self["person"..strIdx]:setString(i.."")
      	   local buffValueType = var.percent_constant
      	   if buffValueType > 0 then
      	     buffValue = (buffValue/100).."%"
      	   end
           self["buff"..strIdx]:setString(buffValue.."")
      	   break
      	end
      end
    end
  end
  
  local function tableCellTouched(table,cell)
     local cardRoot = AllConfig.unit[configId].activate_units[cell:getIdx() + 1]
     local card = GameData:Instance():getCurrentPlayer():getIllustratedInstance():getCardByUnitRoot(cardRoot) 
     if card ~= nil and card:getConfigId() ~= nil then
      local itemId = AllConfig.unit[card:getConfigId()].card_puzzle_drop[2]
      if itemId ~= nil then
        local sourceView = ItemSourceView.new(itemId)
        self:addChild(sourceView)
      end
     end
  end

  local function cellSizeForTable(table,idx)
    return 100,100
  end

  local function tableCellAtIndex(table, idx)
    local cell = table:cellAtIndex(idx)
    if nil ~= cell then
      cell:removeFromParentAndCleanup(true)
    end
    
    cell = CCTableViewCell:new()
    
    local cardRoot = AllConfig.unit[configId].activate_units[idx + 1]
    local card = GameData:Instance():getCurrentPlayer():getIllustratedInstance():getCardByUnitRoot(cardRoot)
    if card ~= nil then
      card:setState("HasMeeted")
      
      local allCards = GameData:Instance():getCurrentPackage():getAllCards()
      for key, pCard in pairs(allCards) do
      	if pCard:getUnitRoot() == cardRoot then
      	    card:setState("HasOwned")
      	 break
      	end
      end
      
      --local dropItemView = DropItemView.new(card:getConfigId(),nil,nil,not cardFormationView:checkIsbattleCard(cardRoot))
      local dropItemView = CollectionCardView.new(card)
      cell:addChild(dropItemView)
     
      dropItemView:setPositionX(dropItemView:getContentSize().width/2 - 5)
      dropItemView:setPositionY(dropItemView:getContentSize().height/2 + 10)
    end
    
    return cell
  end

  local function numberOfCellsInTableView(val)
    return #AllConfig.unit[configId].activate_units
  end
  
  --build tableview
  local size = CCSizeMake(510,180)
  local tableView = CCTableView:create(size)
  --tableView:setContentSize(size)
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  --registerScriptHandler functions must be before the reloadData function
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  --tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
  
  self.sprite_son_bg1:addChild(tableView)
  tableView:setPositionX(5)
  tableView:setPositionY(15)

  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch),false,-256,true)
  tableView:setTouchPriority(-256)
  self.closeMenu:setTouchPriority(-256)
end

function CardFormationCombineSkillView:onTouch(event,x,y)
  
  if event == "began" then
    return true 
  elseif event == "ended" then

    local size = self.bgsprite:getContentSize()
    local pos = self.bgsprite:convertToNodeSpace(ccp(x, y))
    if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
      self:onCloseHandler()
    end
    
    return true
  end
                              
end

function CardFormationCombineSkillView:onCloseHandler()
  self:removeFromParentAndCleanup(true)
end


return CardFormationCombineSkillView