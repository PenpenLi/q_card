require("controller.BaseController")
require("view.regist.CreatePlayerNameView")

require("view.BaseScene")
CreatePlayerNameController = class("CreatePlayerNameController",BaseController)

function CreatePlayerNameController:ctor()
	CreatePlayerNameController.super.ctor(self)
end

function CreatePlayerNameController:enter()
	CreatePlayerNameController.super.enter(self)
	
 	self:setScene(GameData:Instance():getCurrentScene())

	local view = CreatePlayerNameView.new()
	view:setDelegate(self)
	self:getScene():replaceView(view,true)
end





