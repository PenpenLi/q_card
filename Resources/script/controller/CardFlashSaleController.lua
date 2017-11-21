require("view.card_flash_sale.CardFlashSaleView")
CardFlashSaleController = class("CardFlashSaleController",BaseController)
function CardFlashSaleController:ctor()
   CardFlashSaleController.super.ctor(self,"CardFlashSaleController")
end

function CardFlashSaleController:enter()
  CardFlashSaleController.super.enter(self)
  self:setScene(GameData:Instance():getCurrentScene())
  local cardFlashSaleView = CardFlashSaleView.new()
  self:getScene():replaceView(cardFlashSaleView)
end

function CardFlashSaleController:exit()
   CardFlashSaleController.super.exit(self)
end

return CardFlashSaleController