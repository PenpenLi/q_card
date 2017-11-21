require("view.card_flash_sale.CardFlashSaleItem")
CardFlashSaleView = class("CardFlashSaleView",ViewWithEave)
function CardFlashSaleView:ctor()
  CardFlashSaleView.super.ctor(self)
end

function CardFlashSaleView:onEnter()
	CardFlashSaleView.super.onEnter(self)
	display.addSpriteFramesWithFile("card_flash_sale/card_flash_sale.plist", "card_flash_sale/card_flash_sale.png")

	self:setTabControlEnabled(false)
	self:setTitleTextureName("xianshidianjiang_dianjiangtai_title.png")
	
	self:getEaveView().btnHelp:setVisible(false)
	local bg = display.newSprite("card_flash_sale/card_flash_sale_bg.png")
  self:getEaveView():getNodeContainer():addChild(bg)
  bg:setPosition(ccp(display.cx,display.cy))
	
	local itemsContainer = display.newNode()
	self:addChild(itemsContainer)
	itemsContainer:setPositionX(display.cx)
	local bottomSize = GameData:Instance():getCurrentScene():getBottomContentSize()
	local canvasSize = self:getCanvasContentSize()
	itemsContainer:setPositionY(bottomSize.height + canvasSize.height/2)
	
	local positions = {ccp(-160,200),ccp(160,200),ccp(-160,-160),ccp(160,-160)}
	
	local currentTime = Clock:Instance():getCurServerTime()
	
	--%w 
  --Weekday as decimal number (0 – 6; Sunday is 0)
  --local weekDay = os.date("%w", currentTime) + 1
  
  local timeTable = os.date("!*t", currentTime)
  print("server day now: yy--mm--dd", timeTable.year,timeTable.month,timeTable.day)
  print("server time now:currentTime hh-mm-ss:",timeTable.hour,timeTable.min,timeTable.sec)
  print("server week day is:",timeTable.wday - 1)
  
  local weekDay = timeTable.wday
  
  local drops = {}
  for country = 1, 4 do
     for key, config in pairs(AllConfig.greatbonus) do
        if config.country == country then
          drops[country] = config.drops[weekDay]
          break
        end
     end
  end
  
  local unitsToShow = {}
  local allDropsCard = {}
  for key, dropId in pairs(drops) do
    local allDrops = {}
  	if AllConfig.drop[dropId] and #AllConfig.drop[dropId].drop_data > 0 then
  	  table.insert(unitsToShow,AllConfig.drop[dropId].drop_data[1].array[2])
  	  for key, var in pairs(AllConfig.drop[dropId].drop_data) do
  	  	table.insert(allDrops,var.array[2])
  	  end
  	  table.insert(allDropsCard,allDrops)
  	end
  end
  
	for i = 1, #unitsToShow do
		local item = CardFlashSaleItem.new(unitsToShow[i])
		item:setUnits(allDropsCard[i])
    itemsContainer:addChild(item)
    item:setPosition(positions[i])
	end
end

function CardFlashSaleView:onExit()
  display.removeSpriteFramesWithFile("card_flash_sale/card_flash_sale.plist", "card_flash_sale/card_flash_sale.png")
	CardFlashSaleView.super.onExit(self)
end

function CardFlashSaleView:onBackHandler()
  CardFlashSaleView.super.onBackHandler(self)
  local controller = ControllerFactory:Instance():create(ControllerType.LOTTERY_CONTROLLER)
  controller:enter()
end

return CardFlashSaleView