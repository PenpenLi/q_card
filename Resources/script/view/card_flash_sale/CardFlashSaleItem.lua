require("view.card_flash_sale.CardFlashDetailView")
CardFlashSaleItem = class("CardFlashSaleItem",BaseView)
function CardFlashSaleItem:ctor(configId)
  CardFlashSaleItem.super.ctor(self)
  display.addSpriteFramesWithFile("card_flash_sale/card_flash_sale.plist", "card_flash_sale/card_flash_sale.png")
  
  
  local portraitId = AllConfig.unit[configId].unit_pic
  local portrait = _res(portraitId)
  if portrait ~= nil then
    portrait:setPositionY(50)
    portrait:setScale(0.45)
    self:addChild(portrait)
  end
  
  local todayStar = display.newSprite("#xianshidianjiang_benrizhixing.png")
  self:addChild(todayStar)
  todayStar:setPosition(ccp(-120,70))
  
  
          
  local s = AllConfig.unit[configId].unit_cardname
  local name = ""
  local zh_idx = 1
  local zh_size = 3
  local zh_len = string.len(s)/zh_size
  for i= 1, zh_len do
    name = name..string.sub(s,zh_idx,string.len(s)/zh_len*i).."\n"
    zh_idx = zh_idx + zh_size
  end
  local label = CCLabelBMFont:create(name, "client/widget/words/card_name/name_card.fnt")
  self:addChild(label)
  label:setPosition(ccp(110,50))
  
  local lightBg = display.newSprite("#xianshidianjiang_title_light_bg.png")
  if lightBg then
    self:addChild(lightBg)
    lightBg:setPositionY(-80)
  end
  
  local resStr = "#xianshidianjiang_title"..AllConfig.unit[configId].country1..".png"
  local title = display.newSprite(resStr)
  if title then
    self:addChild(title)
    title:setPositionY(-80)
  end
  
  --BTN
  
  local callBack = function()
    print("clicked")
    if self:getUnits() == nil then
      return
    end
    
    dump(self:getUnits())
    
    local cardFlashDetailView = CardFlashDetailView.new(self:getUnits())
    GameData:Instance():getCurrentScene():replaceView(cardFlashDetailView)
    --GameData:Instance():getCurrentScene():addChildView(cardFlashDetailView)
    
  end
  
  local normal,sel,dis
  normal = display.newSprite("#xianshidianjiang_zhaomu.png")
  sel = display.newSprite("#xianshidianjiang_zhaomu1.png")
  dis = display.newSprite("#xianshidianjiang_zhaomu1.png")
  local menu = UIHelper.ccMenuWithSprite(normal,sel,dis,callBack)
  self:addChild(menu)
  menu:setPositionY(-170)
  
  
end

------
--  Getter & Setter for
--      CardFlashSaleItem._Units 
-----
function CardFlashSaleItem:setUnits(Units)
	self._Units = Units
end

function CardFlashSaleItem:getUnits()
	return self._Units
end

return CardFlashSaleItem