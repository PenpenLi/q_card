require("view.BaseView")
require("view.component.CardHeadView")
require("view.enhance.LevelUpView")
require("model.GameData")
require("view.component.Toast")
require("view.home.CreateRoleView")

CreatePlayerNameView = class("CreatePlayerNameView",BaseView)

function CreatePlayerNameView:ctor()
	CreatePlayerNameView.super.ctor(self)
	local pkg = ccbRegisterPkg.new(self)

	--pkg:addFunc("returnBtnCallBack",CreatePlayerNameView.returnBtnCallBack)
	pkg:addProperty("nameInputBg","CCScale9Sprite")
	pkg:addProperty("confirmBtn","CCControlButton")
	pkg:addProperty("returnBtn","CCControlButton")

	pkg:addProperty("diceBtn","CCControlButton")
	pkg:addProperty("tips","CCLabelTTF")
	pkg:addProperty("inputText","CCLabelTTF")
	pkg:addFunc("diceBtnCallBack",CreatePlayerNameView.onDiceBtnCallBack)
	pkg:addFunc("confirmBtnCallBack",CreatePlayerNameView.confirmBtnCallBack)
	local layer = nil
	layer,self.owner = ccbHelper.load("CreatePlayerName.ccbi","CreatePlayNameCCB","CCLayer",pkg)

	self.tips:setString(_tr("nick_name_tip"))
	self.inputText:setString(_tr("input_name"))
	self.fieldUserName = UIHelper.convertBgToEditBox(self.nameInputBg,"",25,ccc3(255,255,255),false,8)
	self.fieldUserName:registerScriptEditBoxHandler(function(strEventName,pSender) return self:editBoxTextEventHandle(strEventName,pSender) end)
	self:addChild(layer)
	self.returnBtn:setVisible(false)

	print("---CreatePlayerNameView:ctor()---",self.fieldUserName)

	--net.sendMessage(PbMsgId.PlayerQueryRndNameC2S) -- 随机名字
	net.registMsgCallback(PbMsgId.PlayerQueryRndNameS2C,self,CreatePlayerNameView.onPlayerQueryRndNameS2C)
	net.registMsgCallback(PbMsgId.BindGameNickNameResult,self,CreatePlayerNameView.onBindGameNickNameResult)
end

function CreatePlayerNameView:onEnter()
  print("CreatePlayerNameView:onEnter")
  if GameData:Instance():getLanguageType() == LanguageType.JPN then 
    self.diceBtn:setVisible(false)
  else 
    self:onDiceBtnCallBack()
  end 
end

function CreatePlayerNameView:editBoxTextEventHandle(strEventName,pSender)
	 --self.confirmBtn:setHighlighted(true)
	print("strEventName,pSender",strEventName,pSender)
	local edit = tolua.cast(pSender,"CCEditBox")
	local strFmt
	if strEventName == "began" then
		strFmt = string.format("editBox %p DidBegin !", edit)
		print(strFmt)
	elseif strEventName == "ended" then
		strFmt = string.format("editBox %p DidEnd !", edit)
		print(strFmt)
	elseif strEventName == "return" then
		strFmt = string.format("editBox %p was returned !",edit)
		print(strFmt)
	elseif strEventName == "changed" then
		strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
		print(strFmt)
	end
end

function CreatePlayerNameView:confirmBtnCallBack()

	local inputName = self.fieldUserName:getText()   -- get input username
    local len = string.len(inputName)

	local function utf8_length(str)
		local len = 0
		local pos = 1
		local length = string.len(str)
		while true do
			local char = string.sub(str , pos , pos)

			local b = string.byte(char)
			if b >= 128 then
				pos = pos + 3
				len = len + 2
			elseif b < 128 and char >= 'A' and char <= 'Z' then
				pos = pos + 1
				len = len + 1.2
			else
				pos = pos + 1
				len = len + 1
			end

			-- print(word)
			-- print("pos: " .. pos)
			if pos > length then
				break
			end
		end

		return len
	end

	print("inputName len=====",len)
	--print("utf8_len= ",utf8_length(inputName))
	if inputName == "" then
		Toast:showString(self, _tr("empty_name"), ccp(display.width/2, display.height*0.4))
        return
	elseif inputName ~= "" and utf8_length(inputName) > 10 then
		Toast:showString(self, _tr("name_too_long"), ccp(display.width/2, display.height*0.4))
		return
	end

	if net.isConnected == false then
		net.connect()
	else
		print("net. already connect")
    end

    local data = PbRegist.pack(PbMsgId.BindGameNickName,{ nick_name = inputName})
    net.sendMessage(PbMsgId.BindGameNickName,data)

end

function CreatePlayerNameView:onDiceBtnCallBack()
	print("---onDiceBtnCallBack----")
	net.sendMessage(PbMsgId.PlayerQueryRndNameC2S) -- 随机名字
end

function CreatePlayerNameView:onBindGameNickNameResult(action,msgId,msg)
    print("msgId = ",msgId)
    print("msg.state = ", msg.state)
    print(msg.nick_name)
    if msg.state == "Ok" then
    elseif msg.state == "NameHasErrorCode" then

    	Toast:showString(self, _tr("invalid_name"), ccp(display.width/2, display.height*0.4))
    	return
    elseif msg.state == "NameIsTooLong" then
	    Toast:showString(self, _tr("name_too_long"), ccp(display.width/2, display.height*0.4))
		 return
    elseif msg.state == "NameConflictWithOther" then
	    Toast:showString(self, _tr("is_same_name"), ccp(display.width/2, display.height*0.4))
		 return
    elseif msg.state == "NoRightToChangeNickName" then

		  return
    elseif msg.state == "NameIsTooShort" then

	    Toast:showString(self, _tr("name_too_shot"), ccp(display.width/2, display.height*0.4))
		  return
    elseif msg.state == "NameNotValid" then
        Toast:showString(self, _tr("invalid_name"), ccp(display.width/2, display.height*0.4))
        --Toast:showString(self, msg.state, ccp(350, 200))
        return
    end

	--print("zm  CreatePlayerNameView:BindGameNickNameResult")
	GameData:Instance():getCurrentPlayer():setName(msg.nick_name)


	local flag = GameData:Instance():getCurrentPlayer():getCardGiftFlag()
	echo("===== award flag=", flag)	
  	if flag ~= nil and flag > 0 then --has selected card
		local homeController = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
		homeController:enter(true)    		
  	else 
		local view = CreateRoleView.new()
		GameData:Instance():getCurrentScene():addChild(view)
	end 
end

function CreatePlayerNameView:onExit()
	net.unregistAllCallback(self)
	self.super:onExit()
end

function CreatePlayerNameView:onPlayerQueryRndNameS2C(action,msgId,msg)
	self.fieldUserName:setText(msg.name)
end

return CreatePlayerNameView




