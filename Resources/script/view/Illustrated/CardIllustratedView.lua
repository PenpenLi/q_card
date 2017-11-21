require("view.Illustrated.CollectionCardView") 
require("view.Illustrated.CollectionEquipmentView") 
require("view.Illustrated.IllustratedListItem") 
require("view.component.OrbitCard") 
CardIllustratedView = class("CardIllustratedView",ViewWithEave)
IllustratedType = enum({"NONE","CARD","EQUIPMENT"})
function CardIllustratedView:ctor(controller,illustrated)
  self.super.ctor(self)
  self:setNodeEventEnabled(true)
  self:setDelegate(controller)
  self._illustrated = illustrated
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self,self.onTouch))
end

function CardIllustratedView:onEnter()
  CardIllustratedView.super.onEnter(self)
  self:getEaveView().btnHelp:setVisible(false)
  display.addSpriteFramesWithFile("gallery/gallery.plist", "gallery/gallery.png")
  self:setTitleTextureName("#gallery-image-paibian.png")
  
  local menuArray = { 
           {"#gallery_wujiang_nor.png","#gallery_wujiang_sel.png"},
           {"#gallery_zhuangbei_nor.png","#gallery_zhuangbei_sel.png"}
       }
  self:setMenuArray(menuArray)

  local posX = self:getListContainer():getPositionX()
  local posY = self:getListContainer():getPositionY()
  local pos = self:getListContainer():getParent():convertToWorldSpace(ccp(posX,posY))
  self._cardViewConArray = {}
  self._menuHeight = 0

  self._headList = display.newNode()
  self._headList:setAnchorPoint(ccp(0,0))
  self._scrollView = CCScrollView:create()
  self._scrollView:setViewSize(CCSizeMake(self:getCanvasContentSize().width,self:getCanvasContentSize().height - 185))
  --self._scrollView:setContentSize(CCSizeMake(570,self:getCanvasContentSize().height - self._menuHeight))
  self._scrollView:setDirection(kCCScrollViewDirectionVertical)
  self._scrollView:setClippingToBounds(true)
  self._scrollView:setBounceable(true)
  
  self._scrollView:setContainer(self._headList)

  self:addChild(self._scrollView)
  self._scrollView:setPosition(ccp(30,130))
  self._scrollView:setVisible(true)
  
  -- country flags
  local countryFlagRes = {
    {3022008,3022048},
    {3022009,3022049},
    {3022007,3022047},
    {3022010,3022050}
  }
  
  self._selectCountryFlags = {}
  self._countryFlagsContainer = display.newNode()
  self:addChild(self._countryFlagsContainer)
  local selectCountryFlag = function(bp,target)
    if target:getTag() == self._countryType then
       target:selected()
       return
    end
    
    self._countryType = target:getTag()
    for key, flag in pairs(self._selectCountryFlags) do
    	flag:unselected()
    end
    target:selected()
    
    local cardsToshow = {}
    if self._gradeSelected == 6 then
      cardsToshow = self._illustrated:getCardsByCountry(self._countryType)
    else
      cardsToshow = self._illustrated:getCardsByGradeAndCountry(self._gradeSelected,self._countryType)
    end
    self:showCards(cardsToshow)
  end
  
  for key, resarr in pairs(countryFlagRes) do
  	local norSprite = _res(resarr[1])
    local selSprite = _res(resarr[2])
    local disSprite = _res(resarr[2])
    local countryFlagBtn,menuItem = UIHelper.ccMenuWithSprite(norSprite,selSprite,disSprite,selectCountryFlag)
    menuItem:setTag(key)
    self._countryFlagsContainer:addChild(countryFlagBtn)
    countryFlagBtn:setPosition(45 + (norSprite:getContentSize().width+10)*key ,display.height - 275)
    self._selectCountryFlags[key] = menuItem
  end
  
  -- card grade select 
  local boaderbg = display.newSprite("#gallery_black_bg.png")
  self:addChild(boaderbg)
  self._boaderbg = boaderbg
  boaderbg:setPosition(ccp(display.cx,display.height - 370))
  boaderbg:setScale(1.4)
  
  local labels = {"一星","二星","三星","四星","五星","全部"}
  self._labelContainer = display.newNode()
  self:addChild(self._labelContainer)
  self._labelContainer:setPositionY(display.height - 370)
  
  local gradeContainer = CCMenu:create()
  self:addChild(gradeContainer)
  self._gradeContainer = gradeContainer
  gradeContainer:setPosition(ccp(90,display.height - 370))
  self._gradeArr = {}
  for i = 1, #labels do
   
    local gradeSelectItem = CCMenuItemImage:create()
    local nor_frame =  display.newSpriteFrame("point_nor.png")
    local disabled_frame = display.newSpriteFrame("point_dis.png")
    gradeSelectItem:setNormalSpriteFrame(nor_frame)
    gradeSelectItem:setSelectedSpriteFrame(disabled_frame)
    gradeSelectItem:setDisabledSpriteFrame(disabled_frame)
    
    gradeSelectItem:registerScriptTapHandler(handler(self,self.onClickGradeSwitch))
    gradeContainer:addChild(gradeSelectItem)
    gradeSelectItem:setPositionX(95*(i-1))
    gradeSelectItem.index = i
    self._gradeArr[i] = gradeSelectItem
    
    local plabel = CCLabelTTF:create(labels[i],"Marker Felt", 22)
    plabel:setColor(ccc3(255, 255, 255))
    plabel:setPositionX(100 + 95*(i-1))
    self._labelContainer:addChild(plabel)
  end
  self._gradeArr[1]:selected()

  --equipment type select
   local equipmentTypeIconRes = {
    {"#gallery_weapon_nor.png","#gallery_weapon_sel.png"},
    {"#gallery_armor_nor.png","#gallery_armor_sel.png"},
    {"#gallery_as_nor.png","#gallery_as_sel.png"}
  }
  self._equipmentTypeBtns = {}
  self._equipmentTypeContainer = display.newNode()
  self:addChild(self._equipmentTypeContainer)
  local selectEquipmentType = function(bp,target)
    if target:getTag() == self._equipmentType then
       target:selected()
       return
    end
    
    self._equipmentType = target:getTag()
    for key, equipmentTypeIcon in pairs(self._equipmentTypeBtns) do
      equipmentTypeIcon:unselected()
    end
    target:selected()
    
    local cardsToshow = self._illustrated:getEquipmentsByGradeAndEquipEype(4,self._equipmentType)
    self:showCards(cardsToshow)
  end
  
  for key, resarr in pairs(equipmentTypeIconRes) do
    local norSprite = display.newSprite(resarr[1])
    local selSprite = display.newSprite(resarr[2])
    local disSprite = display.newSprite(resarr[2])
    local equipmentBtn,menuItem = UIHelper.ccMenuWithSprite(norSprite,selSprite,disSprite,selectEquipmentType)
    menuItem:setTag(key)
    self._equipmentTypeContainer:addChild(equipmentBtn)
    equipmentBtn:setPosition(40 + 140*key ,display.height - 275)
    self._equipmentTypeBtns[key] = menuItem
  end
  
  --default to show card
  self:tabControlOnClick(0)
end

function CardIllustratedView:onClickGradeSwitch(dp,target)
  if target.index == self._gradeSelected then
     target:selected()
     return
  end
  self._gradeSelected = target.index
  for key, grade_btn in pairs(self._gradeArr) do
  	  grade_btn:unselected()
  end
  target:selected()
  
  
    
  local cardsToshow = {}
  if target.index == 6 then
    if self._illustratedType == IllustratedType.CARD then
        cardsToshow = self._illustrated:getCardsByCountry(self._countryType)
    elseif self._illustratedType == IllustratedType.EQUIPMENT then
        cardsToshow = self._illustrated:getEquipmentsByGradeAndEquipEype(4,self._equipmentType)
    end
  else
     if self._illustratedType == IllustratedType.CARD then
        cardsToshow = self._illustrated:getCardsByGradeAndCountry(self._gradeSelected,self._countryType)
    elseif self._illustratedType == IllustratedType.EQUIPMENT then
        cardsToshow = self._illustrated:getEquipmentsByGradeAndEquipEype(4,self._equipmentType)
    end
    
  end
  self:showCards(cardsToshow)
end

function CardIllustratedView:showCards(cardsToShow)
    
    self._cardViewConArray = {}
    self._headList:removeAllChildrenWithCleanup(true)
    
    local columnNumber = 5
    local lineNumber = 0
    
    local totalNumber = table.getn(cardsToShow)
    
    local function sortTables(a, b)
       if a:getGrade() == b:getGrade() then
          return a:getConfigId() < b:getConfigId()
       end
       return a:getGrade() > b:getGrade()
    end
    
    if self._illustratedType == IllustratedType.CARD then
        table.sort(cardsToShow,sortTables)
    end
   
    if totalNumber <= columnNumber then
      lineNumber = 1
    else
      lineNumber = math.ceil(totalNumber/columnNumber)
    end 
    
    local distance = 0
    local idx = 0
    local cardView = nil 
    for i = lineNumber, 0,-1 do
       for j = 0, columnNumber-1 do
          if idx < totalNumber then
              if self._illustratedType == IllustratedType.CARD then  --create card views
                  local cardModel = cardsToShow[idx+1]
                  if cardModel ~= nil then
                      cardView = CollectionCardView.new(cardModel)
                      cardView:setPositionX((cardView:getContentSize().width+distance)*j+cardView:getContentSize().width/2+distance)
                      cardView:setPositionY((cardView:getContentSize().height+distance)*i+cardView:getContentSize().height/2-distance)
                      self._headList:addChild(cardView)
                      idx = idx + 1
                      table.insert(self._cardViewConArray,cardView)
                  end
              elseif self._illustratedType == IllustratedType.EQUIPMENT then  --create equipment views 
                  distance = 13
                  local equipmentData = cardsToShow[idx+1]
                  if equipmentData ~= nil then
                      cardView = CollectionEquipmentView.new(equipmentData)
                      cardView:setPositionX((cardView:getContentSize().width+distance)*j+cardView:getContentSize().width/2+distance)
                      cardView:setPositionY((cardView:getContentSize().height+distance)*i+cardView:getContentSize().height/2-distance)
                      self._headList:addChild(cardView)
                      idx = idx + 1
                      table.insert(self._cardViewConArray,cardView)
                  end
              end
          end
       end
    end
    
    echo("columnNumber:",columnNumber,"lineNumber:", lineNumber)
    --set list content size
    if cardView ~= nil then
        self._headList:setContentSize(CCSizeMake((cardView:getContentSize().width+distance)*(columnNumber-1)+cardView:getContentSize().width,(cardView:getContentSize().height+distance)*lineNumber+cardView:getContentSize().height))
        echo("headListContentSize:",self._headList:getContentSize().width,self._headList:getContentSize().height)
        --self._scrollView:reloadData()
         -- scroll to top
        self._headList:setPosition(ccp(0, self._scrollView:getViewSize().height - self._headList:getContentSize().height))
        self._scrollView:setContentSize(self._headList:getContentSize())
        
    end
end

-- tab buttons swicth
function CardIllustratedView:tabControlOnClick(idx)
  self._countryType = 1
  self._equipmentType = 1
  self._gradeSelected = 1
  local cardsToshow = {}
  if idx == 0 then
      self._countryFlagsContainer:setVisible(true)
      self._equipmentTypeContainer:setVisible(false)
      self._scrollView:setViewSize(CCSizeMake(self:getCanvasContentSize().width,self:getCanvasContentSize().height - 185))
      self._gradeContainer:setVisible(true)
      self._labelContainer:setVisible(true)
      self._boaderbg:setVisible(true) 
      
      self._illustratedType = IllustratedType.CARD
      cardsToshow = self._illustrated:getCardsByGradeAndCountry(self._gradeSelected,self._countryType)
      for key, flag in pairs(self._selectCountryFlags) do
          flag:unselected()
      end
      self._selectCountryFlags[1]:selected()
      
      for key, gradeBtn in pairs(self._gradeArr) do
      	gradeBtn:unselected()
      end
      self._gradeArr[1]:selected()
  elseif idx == 1 then
      self._countryFlagsContainer:setVisible(false)
      self._equipmentTypeContainer:setVisible(true)
      self._scrollView:setViewSize(CCSizeMake(self:getCanvasContentSize().width,self:getCanvasContentSize().height - 185 + 65))
      self._gradeContainer:setVisible(false)
      self._labelContainer:setVisible(false)
      self._boaderbg:setVisible(false) 
      
      self._illustratedType = IllustratedType.EQUIPMENT
      cardsToshow = self._illustrated:getEquipmentsByGradeAndEquipEype(4,self._equipmentType)
      for key, icon in pairs(self._equipmentTypeBtns) do
          icon:unselected()
      end
      self._equipmentTypeBtns[1]:selected()
  end
  self:showCards(cardsToshow)
  
end


function CardIllustratedView:onTouch(event, x,y)
  --echo(event,x,y)
  if event == "began" then
    self._touchStepX = x
    self._touchStepY = y
    return true
  elseif event == "moved" then
  elseif event == "ended" then
    if math.abs(self._touchStepX-x) < 20 and math.abs(self._touchStepY-y) < 10 and y >= 115 then
       local targetCard = UIHelper.getTouchedNode(self._cardViewConArray,x,y)
       if targetCard ~= nil then
          if self._illustratedType == IllustratedType.CARD then
              echo("tap:",targetCard:getData():getName())
              if targetCard:getData():getState() == "HasMeeted" or targetCard:getData():getState() == "HasOwned" then
                 local configId = toint(targetCard:getData():getUnitRoot().."0"..targetCard:getData():getMaxGrade())
                 local cardDetail = OrbitCard.new({configId = configId})
                 --cardDetail:showMaxStar()
                 cardDetail:show()
                 --self:addChild(cardDetail)
              end
          elseif self._illustratedType == IllustratedType.EQUIPMENT then
              echo("tap EQ:")
                if targetCard:getData():getHasOwend() == true then
                    local equipData = Equipment.new()
                    equipData:setConfigId(targetCard:getData():getConfigId())
                    local equipmentCard =  EquipOrbitCard.new({equipData = equipData,isGallery = true})
                    equipmentCard:show()
                end
          end
       end
    end
  end
end

function CardIllustratedView:onHelpHandler()
    local helpView = HelpView.new(1037)
    GameData:Instance():getCurrentScene():addChildView(helpView)
    CardIllustratedView.super:onHelpHandler()
end

-- back to pre page
function CardIllustratedView:onBackHandler()
  self.super:onBackHandler()
  self:getDelegate():goToHome()
end

function CardIllustratedView:onExit()
  display.removeSpriteFramesWithFile("gallery/gallery.plist", "gallery/gallery.png")
  CardIllustratedView.super.onExit(self)
end

return CardIllustratedView