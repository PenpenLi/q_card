-- Mining mainMenu
require("view.component.ViewWithEave")

MiningMenuView = class("FrindMenuView",ViewWithEave)

function MiningMenuView:ctor(control)   -- control is miningController
	MiningMenuView.super.ctor(self)

	self:setDelegate(control)

end

function MiningMenuView:enter()  -- 工具controler 的 entryTag决定进入那个界面

	local control = self:getDelegate()
	local pkg = ccbRegisterPkg.new(self)
	self._curBtn = nil
	--regist member
	pkg:addProperty("mainMenuBg","CCSprite")
	pkg:addProperty("miningFieldBtn","CCControlButton")
	pkg:addProperty("miningInfoBtn","CCControlButton")

	--register handle
	pkg:addFunc("miningFieldCallBack",MiningMenuView.onMiningFieldCallBack)  --
	pkg:addFunc("miningInfoCallBack",MiningMenuView.onMiningInfoCallBack) 	--

	local layer,owner = ccbHelper.load("MiningMenuView.ccbi","MiningMenuViewCCB","CCLayer",pkg)
	-- 如果当前是好友的矿场，则不显示矿场信息界面

	local mining = Mining:Instance()
	self._IsMyInfoWin = true
	if mining:getUserName() ~= GameData:Instance():getCurrentPlayer():getName() then
		self.miningInfoBtn:removeFromParentAndCleanup(true)
		local menuArray =
		{
			{"#mine-button-nor-kuangchang.png","#mine-button-sel-kuangchang.png"}
		}
		self._IsMyInfoWin = false
		self:setMenuArray(menuArray)
		self:setTitleTextureName("mine-image-paibian.png")
		self._curMenuIndex = 0      --记录当前的table位置

	else
		local menuArray =
		{
			{"#mine-button-nor-kuangchang.png","#mine-button-sel-kuangchang.png"},
			{"#mine-button-nor-xinxi.png","#mine-button-sel-xinxi.png"}
		}
		self:setMenuArray(menuArray)
		self:setTitleTextureName("mine-image-paibian.png")
		self._curMenuIndex = control:getMinerWinTag() - 1      --记录当前的table位置
	end
	--self:onFriendListCallBack()

	local miningController = self:getDelegate()
	local action
	local function  delayEnter()

		if (mining:getIsMyMining() == true and mining:getMyMiningDataIsOk() == true )   or
				(mining:getIsMyMining() == false and mining:getFriendMiningDataIsOk() == true ) then
			self:stopAction(action)
--			if self._loading ~= nil then
--				self._loading:remove()
--			end
--			self._loading =  nil
      _hideLoading()
			if miningController ~= nil then
				local entryTag = miningController:getMinerWinTag()
				self:tabControlOnClick(entryTag-1)
				if  mining:getIsMyMining() == true then
					mining:setMyMiningDataIsOk(false)
				else
					mining:setFriendMiningDataIsOk(false)
				end
			end
		end
	end
	--self._loading = Loading:show()
	_showLoading()
	local entryTag = miningController:getMinerWinTag()
	self:getTabMenu():setItemSelectedByIndex(entryTag)
	action = self:schedule(delayEnter,0.5)


end

function MiningMenuView:tabControlOnClick(idx)
	local miningController = self:getDelegate()
	self._curMenuIndex = idx
	if idx == 0 then                           -- 矿场
		miningController:dispMiningFieldView()
	elseif idx == 1 then                       -- 信息
	--	miningController:dispMiningInfoView()
	else
		return
	end
end

function MiningMenuView:onMiningFieldCallBack()
	print("MiningMenuView.lua<MiningMenuView:return > :onMiningFieldCallBack() ")
	local miningController = self:getDelegate()
	miningController:dispMiningFieldView()
end

function MiningMenuView:onMiningInfoCallBack()
	print("onMiningInfoCallBack")
	local miningController = self:getDelegate()
	--miningController:dispMiningInfoView()
end



function MiningMenuView:setActiveBtn(tag) --set state(true or false) of button
	if self._curBtn ~= nil then
		self._curBtn:setEnabled(true)
	end
	if tag == 1 then
		self._curBtn = self.miningFieldBtn
	elseif tag == 2 then
		self._curBtn = self.miningInfoBtn
	else
		return
	end
	self._curBtn:setEnabled(false)
end

function MiningMenuView:onBackHandler()
	local control = self:getDelegate()
	control:setcurViewTag(MinerWinTag.NONE)
	control:setCurMiningView(nil)
	if self._IsMyInfoWin == true then
		local homeController = ControllerFactory:Instance():create(ControllerType.HOME_CONTROLLER)
		homeController:enter()
	else
		local friendController = ControllerFactory:Instance():create(ControllerType.FRIEND_CONTROLLER)
		friendController:enter(ViewType.home)
	end
end

function MiningMenuView:onExit()
	echo("---MiningMenuView:onExit---")
	local control = self:getDelegate()
	control:setcurViewTag(MinerWinTag.NONE)
	control:setCurMiningView(nil)
end


return  MiningMenuView

