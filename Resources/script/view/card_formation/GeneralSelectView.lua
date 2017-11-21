require("view.BaseView")
GeneralSelectView = class("GeneralSelectView", BaseView)

function GeneralSelectView:ctor()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addFunc("onSelectViewClose",GeneralSelectView.onSelectViewClose)
  pkg:addFunc("onSelectViewConfirm",GeneralSelectView.onSelectViewConfirm)
  self.currentStar=0
  self.currentPosition=0
  self.currentCountry=0
  for i=0,5 do
    local levelButton="level_button_"..i
    pkg:addProperty(levelButton,"CCControlButton")
    local levelSprite="sprite_level_"..i
    pkg:addProperty(levelSprite,"CCControlButton")
  end

  for i=0,2 do
    local positionButton="position_button_"..i
    pkg:addProperty(positionButton,"CCControlButton")
    local positionSprite="sprite_position_"..i
    pkg:addProperty(positionSprite,"CCControlButton")
  end

  for i=0,4 do
    local countryButton="country_button_"..i
    pkg:addProperty(countryButton,"CCControlButton")
    local countrySprite="sprite_country_"..i
    pkg:addProperty(countrySprite,"CCControlButton")
  end
  
  pkg:addProperty("label_star_all","CCLabelTTF")
  pkg:addProperty("label_star_1","CCLabelTTF")
  pkg:addProperty("label_star_2","CCLabelTTF")
  pkg:addProperty("label_star_3","CCLabelTTF")
  pkg:addProperty("label_star_4","CCLabelTTF")
  pkg:addProperty("label_star_5","CCLabelTTF")
  
  pkg:addProperty("label_pos_all","CCLabelTTF")
  pkg:addProperty("label_pos_1","CCLabelTTF")
  pkg:addProperty("label_pos_2","CCLabelTTF")
  
  pkg:addProperty("label_country_all","CCLabelTTF")
  pkg:addProperty("label_country_wei","CCLabelTTF")
  pkg:addProperty("label_country_shu","CCLabelTTF")
  pkg:addProperty("label_country_wu","CCLabelTTF")
  pkg:addProperty("label_country_qun","CCLabelTTF")
  
  local opacity = 190
   --color layer
  local layerScale = 2
  local layerColor = CCLayerColor:create(ccc4(0,0,0,opacity), display.width*layerScale, display.height*layerScale)
  self:addChild(layerColor)
  layerColor:setPosition(-(display.width*layerScale - display.width)/2,-(display.height*layerScale - display.height)/2)

  local layer,owner = ccbHelper.load("GeneralSelectView.ccbi","GeneralSelectViewCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.label_star_all:setString(_tr("ALL"))
  self.label_star_1:setString(_tr("STAR_1"))
  self.label_star_2:setString(_tr("STAR_2"))
  self.label_star_3:setString(_tr("STAR_3"))
  self.label_star_4:setString(_tr("STAR_4"))
  self.label_star_5:setString(_tr("STAR_5"))
  
  self.label_pos_all:setString(_tr("ALL"))
  self.label_pos_1:setString(_tr("unit_before"))
  self.label_pos_2:setString(_tr("unit_behind"))
  
  self.label_country_all:setString(_tr("ALL"))
  self.label_country_wei:setString(_tr("country_wei"))
  self.label_country_shu:setString(_tr("country_shu"))
  self.label_country_wu:setString(_tr("country_wu"))
  self.label_country_qun:setString(_tr("country_qun"))
  
  self:setTouchEnabled(true)
  self:addTouchEventListener(
    function(event, x, y)
      return true
    end,false, -128, true)

  local function levelTouchHandler(event,sender) 
       if(self.level_button_0==sender) then
          if not self["sprite_level_0"]:isVisible() then
            for i=1,5 do
              self["sprite_level_"..i]:setVisible(false)  
            end
          end
          self["sprite_level_0"]:setVisible(not self["sprite_level_0"]:isVisible())
       elseif self.level_button_1==sender then
          self["sprite_level_0"]:setVisible(false) 
          self["sprite_level_1"]:setVisible(not self["sprite_level_1"]:isVisible()) 
       elseif self.level_button_2==sender then
           self["sprite_level_0"]:setVisible(false)
           self["sprite_level_2"]:setVisible(not self["sprite_level_2"]:isVisible())
       elseif self.level_button_3==sender then
           self["sprite_level_0"]:setVisible(false)
           self["sprite_level_3"]:setVisible(not self["sprite_level_3"]:isVisible())
       elseif self.level_button_4==sender then
           self["sprite_level_0"]:setVisible(false)
           self["sprite_level_4"]:setVisible(not self["sprite_level_4"]:isVisible())
       elseif self.level_button_5==sender then
           self["sprite_level_0"]:setVisible(false)
           self["sprite_level_5"]:setVisible(not self["sprite_level_5"]:isVisible())
       end 
  end
  local function positionTouchHandler(event,sender)
      if(self.position_button_0==sender) then
        if not self["sprite_position_0"]:isVisible() then
           self["sprite_position_1"]:setVisible(false)
           self["sprite_position_2"]:setVisible(false)   
        end
        self["sprite_position_0"]:setVisible(not self["sprite_position_0"]:isVisible()) 
      elseif self.position_button_1==sender then
        self["sprite_position_0"]:setVisible(false)
        self["sprite_position_1"]:setVisible(not self["sprite_position_1"]:isVisible()) 
      elseif self.position_button_2==sender then
        self["sprite_position_0"]:setVisible(false)
        self["sprite_position_2"]:setVisible(not self["sprite_position_2"]:isVisible()) 
      end    
   
  end
  local function countryTouchHandler(event,sender)
       if(self.country_button_0==sender) then
          if not self["sprite_country_0"]:isVisible() then
            for i=1,4 do
              self["sprite_country_"..i]:setVisible(false)
            end
          end
          self["sprite_country_0"]:setVisible(not self["sprite_country_0"]:isVisible())
       elseif self.country_button_1==sender then
          self["sprite_country_0"]:setVisible(false) 
          self["sprite_country_1"]:setVisible(not self["sprite_country_1"]:isVisible()) 
       elseif self.country_button_2==sender then
           self["sprite_country_0"]:setVisible(false)
           self["sprite_country_2"]:setVisible(not self["sprite_country_2"]:isVisible())
       elseif self.country_button_3==sender then
           self["sprite_country_0"]:setVisible(false)
           self["sprite_country_3"]:setVisible(not self["sprite_country_3"]:isVisible())
       elseif self.country_button_4==sender then
           self["sprite_country_0"]:setVisible(false)
           self["sprite_country_4"]:setVisible(not self["sprite_country_4"]:isVisible())
        end
  end

   for i=0,5 do
    if i==0 then 
       self["sprite_level_"..i]:setVisible(true)
    else 
       self["sprite_level_"..i]:setVisible(false)
    end
    self["level_button_"..i]:setTouchPriority(-128)
    self["level_button_"..i]:addHandleOfControlEvent(levelTouchHandler, CCControlEventTouchUpInside)  
  end

    for i=0,2 do
    if i==0 then 
       self["sprite_position_"..i]:setVisible(true)
    else 
       self["sprite_position_"..i]:setVisible(false)
    end 
    self["position_button_"..i]:setTouchPriority(-128)
    self["position_button_"..i]:addHandleOfControlEvent(positionTouchHandler, CCControlEventTouchUpInside)  
  end
  for i=0,4 do
    if i==0 then 
       self["sprite_country_"..i]:setVisible(true)
    else 
       self["sprite_country_"..i]:setVisible(false)
    end 
    self["country_button_"..i]:setTouchPriority(-128)
    self["country_button_"..i]:addHandleOfControlEvent(countryTouchHandler, CCControlEventTouchUpInside)  
  end  
end

function GeneralSelectView:onSelectViewClose()
   self:removeFromParentAndCleanup(true)
end

function GeneralSelectView:onSelectViewConfirm()
  local currentStar={}
  local currentPosition={}
  local currentCountry={}
  if self["sprite_level_0"]:isVisible() then
      table.insert(currentStar,0)
  else
      local isSelect=false
      if self["sprite_level_1"]:isVisible() then
        table.insert(currentStar,1)
        isSelect=true
      end
      if self["sprite_level_2"]:isVisible() then
        table.insert(currentStar,2)
        isSelect=true
      end
      if self["sprite_level_3"]:isVisible() then
        table.insert(currentStar,3)
        isSelect=true
      end
      if self["sprite_level_4"]:isVisible() then
        table.insert(currentStar,4)
        isSelect=true
      end
      if self["sprite_level_5"]:isVisible() then
        table.insert(currentStar,5)
        isSelect=true
      end
      if not isSelect then
        table.insert(currentStar,0)  
      end
  end

  if self["sprite_position_0"]:isVisible() then
    table.insert(currentPosition,0)
  else
    local isSelect=false
    if self["sprite_position_1"]:isVisible() then
      table.insert(currentPosition,1) 
      isSelect=true
    end
    if self["sprite_position_2"]:isVisible() then
      table.insert(currentPosition,2) 
      isSelect=true
    end
    if not isSelect then
      table.insert(currentPosition,0)
    end
  end

  if self["sprite_country_0"]:isVisible() then
     table.insert(currentCountry,0)
  else
     local isSelect=false
     if self["sprite_country_1"]:isVisible() then
       table.insert(currentCountry,1)
       isSelect=true
     end
     if self["sprite_country_2"]:isVisible() then
       table.insert(currentCountry,2)
       isSelect=true
     end
     if self["sprite_country_3"]:isVisible() then
       table.insert(currentCountry,3)
       isSelect=true
     end
     if self["sprite_country_4"]:isVisible() then
       table.insert(currentCountry,4)
       isSelect=true
     end
     if not isSelect then
        table.insert(currentCountry,0)
     end

  end 
   self:getParent():onExcuteSelect(currentStar,currentPosition,currentCountry)
   self:removeFromParentAndCleanup(true)
end


return GeneralSelectView