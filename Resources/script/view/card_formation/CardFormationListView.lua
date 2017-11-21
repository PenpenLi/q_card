require("view.component.PopModule") 
require("view.card_formation.CardFormationListItemView") 
require("view.battle_formation.BattleFormationListView")
CardFormationListView = class("CardFormationListView",PopModule)

local mScale = 0.9
local itemW = 317 * mScale
local itemH = 130 * mScale
      
function CardFormationListView:ctor(size,playstates)
  CardFormationListView.super.ctor(self,size)
  self:setNodeEventEnabled(true)
  self:setAutoDisposeEnabled(true)
  
  self.playstates = playstates
  self.UNIT_TAG = {333,334}
  self._isChangeCardType = playstates:getIsChangeType()
  self._listType = playstates:getPreViewTabType() --1 已上阵 2 未上阵
  printf("INIT LIST_TYPE:"..self._listType)
  Guide:Instance():removeGuideLayer()
  self._globalPosX = 0
  self._isExcuteSelect = false
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch))
end

function CardFormationListView:onTouch(event,x,y)
  if event == "began" then
      self._startX = x
      self._startY = y
      self._globalPosX = x
      self._draged = false
      return true
   elseif event == "moved" then
      if math.abs(self._startX - x) > 10 or math.abs(self._startY - y) > 10 then
        self._draged = true
      end
   elseif event == "ended" then

   end
end

function CardFormationListView:tabControlOnClick(idx)
  self._isExcuteSelect = false
  self._listType = idx + 1
  if self._listType > 1 then
     self._leaderCostNode:setVisible(false)
     self._selectMenu:setVisible(true)
  else
     self._leaderCostNode:setVisible(true)
     self._selectMenu:setVisible(false)
  end
  
  self.playstates:setPreViewTabType(self._listType)
  self._isChangeCardType = false
  self.playstates:setIsChangeType(self._isChangeCardType)
  local battleCards  = {}
  if self._listType == 1 then
     self.playstates:setListContentOffset(nil)
     battleCards = self.playstates:getBattleCards()
     if self._switchControl ~= nil then
        self._switchControl:setVisible(true)
        --self._switchControl:setOn(true)
     end
     
--     if self._tipStr ~= nil then
--        self._tipStr:setVisible(true)
--     end

  else
     battleCards = GameData:Instance():getCurrentPackage():getIdleCards()
     if self._switchControl ~= nil then
        self._switchControl:setVisible(false)
     end
     
--     if self._tipStr ~= nil then
--        self._tipStr:setVisible(false)
--     end
  end

  self._cardsArr = battleCards
  self._cacheCardsArr=battleCards
  self:rebuildCCTableView()
  _executeNewBird()

end

function CardFormationListView:onCloseHandler()
  CardFormationListView.super.onCloseHandler(self)
  self.playstates:setListContentOffset(nil)
  Guide:Instance():removeGuideLayer()
  GameData:Instance():gotoPreView()
end


function CardFormationListView:onExit()
  CardFormationListView.super.onExit(self)
  display.removeSpriteFramesWithFile("playstates/preview_playstates.plist", "playstates/preview_playstates.png")
  display.removeSpriteFramesWithFile("battle_formation/battle_formation.plist", "battle_formation/battle_formation.png")
  EquipmentReinforce:Instance():setPrePlaystatesView(nil)
end

function CardFormationListView:onEnter()
  --bg 
  local bg = display.newSprite("img/pvp_rank_match/pvp_rank_match_bg.png")
  self:setMaskbackGround(bg)
  
  
  CardFormationListView.super.onEnter(self)
  EquipmentReinforce:Instance():setPrePlaystatesView(self)
  

  display.addSpriteFramesWithFile("playstates/preview_playstates.plist", "playstates/preview_playstates.png")
  display.addSpriteFramesWithFile("battle_formation/battle_formation.plist", "battle_formation/battle_formation.png")
  local menu1 = {"#previrew_playstates_on.png","#previrew_playstates_on1.png"}
  local menu2 = {"#previrew_playstates_off.png","#previrew_playstates_off1.png"}
  local menuArray = {menu1,menu2}

  self:setMenuArray(menuArray)
  --self:setTitleWithSprite(display.newSprite("#previrew_playstates_title.png"))
  
  
  self:getTabMenu():setItemSelectedByIndex(self._listType)
  
  local battleCards  = {}
  if self._listType == 1 then
     battleCards = self.playstates:getBattleCards()
  else
     battleCards = GameData:Instance():getCurrentPackage():getIdleCards()
  end 
  
  self._cardsArr = battleCards
  self._cacheCardsArr=battleCards
  
  
  --[[local valueChanged = function(strEventName,pSender)
    if self._switchControl == nil then
       return
    end
    printf(strEventName,pSender)
    if self._switchControl:isOn() == true then
       self._isChangeCardType = false
       self._dressEquipmentBtn:setVisible(true)
    else
       self._isChangeCardType = true
       self._dressEquipmentBtn:setVisible(false)
       _executeNewBird()
    end
    
    self.playstates:setIsChangeType(self._isChangeCardType)
    
    if self.tableView ~= nil then
       self.tableView:reloadData()
    end
  end]]
  
--  local tipStr = display.newSprite("#previrew_playstates_str_change.png")
--  self:addChild(tipStr)
--  tipStr:setPosition(ccp(display.cx + 125,display.cy + 280))
--  self._tipStr = tipStr
--  
  --[[local switchControl = CCControlSwitch:create( display.newSprite("img/playstates/preplaystates_switch_mask.png"),
    display.newSprite("img/playstates/preplaystates_switch_off.png"),
    display.newSprite("img/playstates/preplaystates_switch_on.png"),
    display.newSprite("img/playstates/preplaystates_switch_thumb.png")
  )
  if self._isChangeCardType == true then
     switchControl:setOn(false)
  else
     switchControl:setOn(true)
  end
  
  switchControl:addHandleOfControlEvent(valueChanged, CCControlEventValueChanged)
  self:addChild(switchControl)
  ]]
  
  
  
  local function onEnterBattleFormation()
    local controller = ControllerFactory:Instance():create(ControllerType.BATTLE_FORMATION_CONTROLLER)
    controller:enter(true,BattleFormation:Instance():getCurrentAttackBattleFormationIdx())
  end     
  
  local function onSwitchBattleFormation()
    local listView = BattleFormationListView.new(true,BattleFormation:Instance():getCurrentAttackBattleFormationIdx())
    listView:setDelegate(self)
    self:addChild(listView,3000)
  end                                                                                                          
  
  local switchControl = CCMenu:create()
  self:addChild(switchControl)
  switchControl:setContentSize(CCSizeMake(109,42))
  
  local editMenuItem = CCMenuItemImage:create()
  local frameNor =  display.newSpriteFrame("preplaystates_tiaozheng.png")
  local frameSel =  display.newSpriteFrame("preplaystates_tiaozheng1.png")
  editMenuItem:setNormalSpriteFrame(frameNor)
  editMenuItem:setSelectedSpriteFrame(frameSel)
  editMenuItem:registerScriptTapHandler(onEnterBattleFormation)
  switchControl:addChild(editMenuItem)
  editMenuItem:setVisible(true)
  self._editMenuItem = editMenuItem
  
  
  local loadMenuItem = CCMenuItemImage:create()
  local frameNor =  display.newSpriteFrame("preplaystates_zairu.png")
  local frameSel =  display.newSpriteFrame("preplaystates_zairu1.png")
  loadMenuItem:setNormalSpriteFrame(frameNor)
  loadMenuItem:setSelectedSpriteFrame(frameSel)
  loadMenuItem:registerScriptTapHandler(onSwitchBattleFormation)
  switchControl:addChild(loadMenuItem)
  loadMenuItem:setVisible(true)
  loadMenuItem:setPositionX(loadMenuItem:getPositionX() - 100)
  self._loadMenuItem = loadMenuItem
  
--  if self._isChangeCardType == true then
--    loadMenuItem:setVisible(false)
--    editMenuItem:setVisible(true)
--  else
--    loadMenuItem:setVisible(true)
--    editMenuItem:setVisible(false)
--  end
  
  switchControl:setPosition(ccp(display.cx + 230,display.cy + 288))
  
  self._switchControl = switchControl
  if self._listType == 1 then
     self._switchControl:setVisible(true)
     --self._tipStr:setVisible(true)
  else
     self._switchControl:setVisible(false)
     --self._tipStr:setVisible(false)
  end
  
  local leaderCostNode = display.newNode()
  self:addChild(leaderCostNode)
  self._leaderCostNode = leaderCostNode
  
  local showText = self.playstates:getCurrentCost().."/"..GameData:Instance():getCurrentPlayer():getLeadShip()
  local label = CCLabelBMFont:create(showText, "client/widget/words/card_name/lead_number_nor.fnt")
  label:setPosition(ccp(display.cx - 150,display.cy + 207))
  leaderCostNode:addChild(label)
  self._leaderCostLabel = label
  
  local leaderStr = display.newSprite("#preplaystates_cost_str.png")
  leaderCostNode:addChild(leaderStr)
  leaderStr:setPosition(ccp(display.cx - 230,display.cy + 205))
  
  local label_red = CCLabelBMFont:create(showText, "client/widget/words/card_name/lead_number_add.fnt")
  label_red:setPosition(ccp(display.cx - 150,display.cy + 207))
  leaderCostNode:addChild(label_red)
  self._leaderCostRedLabel = label_red
  
  
  --一键装备
  local dressEquipmentBtn = CCMenu:create()
  leaderCostNode:addChild(dressEquipmentBtn)
  dressEquipmentBtn:setPosition(ccp(display.cx + 220,display.cy + 205))
  self._dressEquipmentBtn = dressEquipmentBtn
  
  local dressTexture = display.newSprite("#playstates-button-nor-dress.png")
  local dressEquipmentBtnItem = UIHelper.ccMenuItemImageWithSprite(dressTexture,
          display.newSprite("#playstates-button-sel-dress.png"),
          display.newSprite("#previrew_playstates_on1.png"),
          function()
            local battleCards = GameData:Instance():getCurrentPackage():getBattleCards()
            local todoCards = {}
            for key, card in pairs(battleCards) do
            	table.insert(todoCards,card:getId())
            end
            EquipmentReinforce:Instance():reqChangeEquipment("Dress",todoCards,0)
          end)
  dressEquipmentBtnItem:setContentSize(CCSizeMake(130,55))
  dressEquipmentBtn:addChild(dressEquipmentBtnItem)
  self._dressEquipmentBtn = dressEquipmentBtn
  
  --for test
  --dressEquipmentBtn:setVisible(false)
  
  _registNewBirdComponent(106006,dressTexture)
  _registNewBirdComponent(106402,self.closeBtn)
  _registNewBirdComponent(106502,self._editMenuItem)
  _registNewBirdComponent(106501,self._loadMenuItem)
  
  local tabMenu = self:getTabMenu():getTableView()
  for i = 1, 2 do
    local targetCell = tabMenu:cellAtIndex(i-1)
    if targetCell ~= nil then
      targetCell:setContentSize(CCSizeMake(135,60))
      _registNewBirdComponent(106503 + (i-1),targetCell)
    end
  end

  --未上阵 筛选
  local function openSelectView() 
    require("view.card_formation.GeneralSelectView")
    local pop = GeneralSelectView:new(self)
    self:addChild(pop)
  end

  local selectNormal = display.newSprite("#previrew_playstates_shaixuan.png")
  local selectSelected = display.newSprite("#previrew_playstates_shaixuan1.png")
  local selectDisabled = display.newSprite("#previrew_playstates_shaixuan2.png")
  local menu = UIHelper.ccMenuWithSprite(selectNormal,selectSelected,selectDisabled,openSelectView)
  menu:setPosition(ccp(display.cx + 220,display.cy + 285))
  self:addChild(menu)
  self._selectMenu=menu

  if self._listType > 1 then
     self._leaderCostNode:setVisible(false)
     self._selectMenu:setVisible(true)
  else
     self._leaderCostNode:setVisible(true)
     self._selectMenu:setVisible(false)
  end
    
  label_red:setVisible(false)
  
  if self.playstates:getCurrentCost() > GameData:Instance():getCurrentPlayer():getLeadShip() then
     label_red:setVisible(true)
     label:setVisible(false)
  end
  self:updateView()
  self:setIsScrollLock(_executeNewBird())
end


function CardFormationListView:updateLeaderCost()
  local showText = self.playstates:getCurrentCost().."/"..GameData:Instance():getCurrentPlayer():getLeadShip()
  self._leaderCostLabel:setString(showText)
  self._leaderCostRedLabel:setString(showText)
end

function CardFormationListView:rebuildCCTableView()
  self:getListContainer():removeAllChildrenWithCleanup(true)
  local function scrollViewDidScroll(tableview)
    if self:getIsScrollLock() == true and self._listType == 1 then
     if self._lockY ~= nil then
        tableview:getContainer():setPositionY(self._lockY)
     end
     return
    end
  end
  
  local function tableCellTouched(table,cell)
      printf("cell touched at index: " .. cell:getIdx())
      printf("self._globalPosX:"..self._globalPosX)
      if self._globalPosX < display.cx then
         self:onClickItemHandler(cell:getChildByTag(self.UNIT_TAG[1]))
      else
         self:onClickItemHandler(cell:getChildByTag(self.UNIT_TAG[2]))
      end
      self:setIsScrollLock(false)
   end
  
   local function cellSizeForTable(table,idx) 
      return itemH + 4,ConfigListCellWidth
   end
   
   local function setItemData(item,card)
      item:setCard(card)
      if card == nil then
        if self._listType == 1 then
          item:setVisible(true)
        else
          item:setVisible(false)
        end
      end
   end
  
   local function tableCellAtIndex(tableView, idx)
--           idx   idx+1
--      1,2   0      1        idx + idx + 1
--      3,4   1      2        
--      5,6   2      3
--      7,8   3      4

      local cell = tableView:dequeueCell()
      local cardIdx = idx*2 + 1
      if nil ~= cell then
        cell:removeFromParentAndCleanup(true)
      end
      
      cell = CCTableViewCell:new()
      
      
      for j = 1, 2 do
        local item = CardFormationListItemView.new()
        item:setScale(mScale)
        item:setIndex(cardIdx)
        item:setTag(self.UNIT_TAG[j])
        cell:addChild(item)
        item:setPositionX(itemW*0.5 + itemW *(j-1))
        --item:setPositionY(130*0.5 + 130 *(i-1))
        item:setPositionY(itemH*0.5)
        local card = self._cardsArr[cardIdx]
        setItemData(item,card)
        if self._isChangeCardType == true and self._listType == 1 then
          if  card ~= nil then
             local tipImg = display.newSprite("#previrew_playstates_change_tip.png")
             item.nodeCard:addChild(tipImg)
             local sequence = CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCFadeOut:create(1.5))
             local seq = CCSequence:createWithTwoActions(CCFadeIn:create(1.5), sequence)
             tipImg:runAction(CCRepeatForever:create(seq))
          else
             --item:setVisible(false)
          end
        end

        _registNewBirdComponent(106101 + idx,cell)

        cardIdx = cardIdx + 1
      end
      
      cell:setIdx(idx)
      return cell
  end
  
  local function numberOfCellsInTableView(val)
     if self._listType == 1 then
       return 4
     end
     return math.round(#self._cardsArr/2)
  end
  
  local sizeOffset = 0
  if self._listType == 1 then
    sizeOffset = -60 
  elseif self._listType == 2 then
     sizeOffset = 0
  end
  
  local mSize = CCSizeMake(self:getCanvasContentSize().width,self:getCanvasContentSize().height + sizeOffset)
  local tableView = CCTableView:create(mSize)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
  tableView:setClippingToBounds(true)
  self:getListContainer():addChild(tableView)
  tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
  tableView:reloadData()
  self.tableView = tableView
  local contentOffset = self.playstates:getListContentOffset()
  if contentOffset ~= nil then
    self.tableView:setContentOffset(contentOffset)
  end
  --self:setIsScrollLock(_executeNewBird())

end


------
--  Getter & Setter for
--      CardFormationListView._IsScrollLock 
-----
function CardFormationListView:setIsScrollLock(IsScrollLock)
  self._IsScrollLock = IsScrollLock
  if self.tableView ~= nil then
      local targetY = self.tableView:getContainer():getPositionY()
      self._lockY = targetY
  end
end

function CardFormationListView:getIsScrollLock()
  return self._IsScrollLock
end

function CardFormationListView:getTitleSpriteWithBattleFormationIdx(battleInformationIdx)
  local titleName = ""
  if battleInformationIdx == BattleFormation.BATTLE_INDEX_NORMAL_1 then
    titleName = "#battle_formation_attack_name1.png"
  elseif battleInformationIdx == BattleFormation.BATTLE_INDEX_NORMAL_2 then
    titleName = "#battle_formation_attack_name2.png"
  elseif battleInformationIdx == BattleFormation.BATTLE_INDEX_NORMAL_3 then
    titleName = "#battle_formation_attack_name3.png"
  elseif battleInformationIdx == BattleFormation.BATTLE_INDEX_PVP then
    titleName = "#battle_formation_pvp_name.png"
  elseif battleInformationIdx == BattleFormation.BATTLE_INDEX_RANK_MATCH then
    titleName = "#battle_formation_rank_match_name.png"
  end
  local spr = display.newSprite(titleName)
  return spr
end

function CardFormationListView:updateView()
  --self:setTitleWithString(BattleFormation:Instance():getCurrentAttackBattleFormationIdx())
  local battleCards  = {}
  if self._listType == 1 then
    battleCards = self.playstates:getBattleCards()
  else
    battleCards = GameData:Instance():getCurrentPackage():getIdleCards()
  end 
  
  self._cardsArr = battleCards
  self._cacheCardsArr=battleCards
  
  local titleSprite = self:getTitleSpriteWithBattleFormationIdx(BattleFormation:Instance():getCurrentAttackBattleFormationIdx())
  self:setTitleWithSprite(titleSprite)
  self.playstates:updateAbility()
  self:rebuildCCTableView()
  self:updateLeaderCost()
end

function CardFormationListView:onBackHandler()
  CardFormationListView.super:onBackHandler()
  GameData:Instance():gotoPreView()
end

function CardFormationListView:onClickItemHandler(item) 
    if item == nil then
       return
    end
    
    printf("onClickHandler")
    if self._listType == 1 then
       --self:getDelegate():enterPlayStatesView()
       if self._isChangeCardType == true then
          if item:getCard() ~= nil then
              printf("change card handler")
              self.playstates:setIsChangeType(self._isChangeCardType)
              self.playstates:setCurrentShowCardByIdx(item:getIndex() - 1,true)
              self:getDelegate():enterSelectListView(SelectListType.CARD,nil,nil,true)
          else
              if item:getLocked() == false then
                 self.playstates:setIsChangeType(self._isChangeCardType)
                 local battleCardsArray = self.playstates:getBattleCards()
                 local  position = #battleCardsArray + 1
                 self:getDelegate():enterSelectListView(SelectListType.CARD,position,true,true)
              end
          end
       else
          if item:getLocked() ~= true then
             if item:getCard() ~= nil then
              self:getDelegate():enterByIdx(item:getIndex(),true)
             else
              local controller = ControllerFactory:Instance():create(ControllerType.BATTLE_FORMATION_CONTROLLER)
              controller:enter(true,BattleFormation:Instance():getCurrentAttackBattleFormationIdx())
             end
          else
             printf("locked")
          end
       end
    else
       if item:getCard() == nil then
         return
       end
       printf("current IDx:"..item:getIndex() - 1)
       
       if self._isExcuteSelect == true then
         self.playstates:setCurrentShowCard(item:getCard())
         self.playstates:setListContentOffset(nil)
       else
         local contentOffset = self.tableView:getContentOffset()
         self.playstates:setListContentOffset(contentOffset)
         self.playstates:setCurrentShowCardByIdx(item:getIndex() - 1,false)
       end
       self:getDelegate():enterPlayStatesView(false)
    end
end


function CardFormationListView:onExcuteSelect(star,position,country)
  self._cardsArr = self:selectGeneral(self._cacheCardsArr,star,position,country)
  self._isExcuteSelect = true
  self.playstates:setListContentOffset(nil)
  self:rebuildCCTableView()
end


function CardFormationListView:selectGeneral(generals,star,position,country)
  local result={}
  if #star==1 and star[1]==0 then
     --忽略星级，根据位置和国家选择武将
     if #position==1 and position[1]==0 then
         --忽略星级、位置 ;根据国家选择武将
         if #country==1 and country[1]==0 then
            --选择全部
            result=generals
         else
            --仅仅国家
            for key,value in pairs(generals) do
                for k,v in pairs(country) do
                   if value:getCountry()==v then
                      table.insert(result,value)
                      break
                   end
                end
            end 
         end
     else
       --根据位置和国家
       if #country==1 and country[1]==0 then
           --仅仅位置
           for key,value in pairs(generals) do
              local unitType = value:getSpecies()
              local atkType = AllConfig.unittype[unitType].atk_type
              for k,v in pairs(position) do
                  if atkType==v then
                      table.insert(result,value)
                      break
                  end
               end
           end
       else
          --位置 国家
          for key,value in pairs(generals) do
              local positionFlag=false
              local countryFlag=false
              local unitType = value:getSpecies()
              local atkType = AllConfig.unittype[unitType].atk_type
              for k,v in pairs(position) do
                  if atkType==v then
                      positionFlag=true
                      break
                  end
              end
              for k,v in pairs(country) do
                  if value:getCountry()==v then
                     countryFlag=true
                     break   
                  end
              end
              if positionFlag and countryFlag then
                  table.insert(result,value)     
              end
          end
       end
     end
  else
     --
     if #position==1 and position[1]==0 then
          if #country==1 and country[1]==0 then
             --仅仅星级
             for key,value in pairs(generals) do
                 for k,v in pairs(star) do
                     if value:getMaxGrade()==v then
                        table.insert(result,value)
                        break
                     end
                 end
             end   
          else
            --星级 国家
             for key,value in pairs(generals) do
                 local starFlag=false
                 local countryFlag=false
                 for k,v in pairs(star) do
                     if v==value:getMaxGrade() then
                        starFlag=true
                        break     
                     end
                 end
                 for k,v in pairs(country) do
                     if value:getCountry()==v then
                        countryFlag=true
                        break
                     end
                 end
                 if starFlag and countryFlag then
                     table.insert(result,value)   
                 end
             end
          end
     else
       --星级，位置
        if #country==1 and country[1]==0 then
            for key,value in pairs(generals) do
              local unitType = value:getSpecies()
              local atkType = AllConfig.unittype[unitType].atk_type
              local starFlag = false
              local positionFlag=false
              for k,v in pairs(star) do
                  if v==value:getMaxGrade() then
                     starFlag=true
                     break
                  end
              end
              for k,v in pairs(position)do 
                 if atkType==v then
                   positionFlag=true
                   break
                 end
              end
              if starFlag and positionFlag then
                 table.insert(result,value) 
              end
            end
        else
            --星级，位置，国家
            for key,value in pairs(generals) do
              local unitType = value:getSpecies()
              local atkType = AllConfig.unittype[unitType].atk_type
              local starFlag=false
              local positionFlag=false
              local countryFlag=false
              for k,v in pairs(star) do
                if v==value:getMaxGrade() then
                  starFlag=true
                  break
                end
              end
              for k,v in pairs(position) do
                 if v==atkType then
                    positionFlag=true
                    break
                 end
              end
              for k,v in pairs(country) do
                 if v==value:getCountry() then
                    countryFlag=true
                    break
                 end    
              end
              if starFlag and positionFlag and countryFlag then
                 table.insert(result,value)   
              end  
            end
        end
     end
  end
  return result
end


--[[
function CardFormationListView:tabControlOnClick(idx)
  return true
end

function CardFormationListView:onEnter()
  CardFormationListView.super.onEnter(self)
  display.addSpriteFramesWithFile("playstates/preview_playstates.plist", "playstates/preview_playstates.png")
  local menu1 = {"#previrew_playstates_on.png","#previrew_playstates_on1.png"}
  local menu2 = {"#previrew_playstates_off.png","#previrew_playstates_off1.png"}
  local menuArray = {menu1,menu2}

  self:setMenuArray(menuArray)
  self:setTitleWithSprite(display.newSprite("#previrew_playstates_title.png"))
end
]]



return CardFormationListView