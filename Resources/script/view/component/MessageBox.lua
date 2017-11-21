
require("view.BaseView")
require("view.component.TipsInfo")


function executeByTag(self,tag,callback,otherCallback)
	if (not self) then
		print("can't cast to ccnode")
		return
	end
	local count =self:getChildrenCount()-1 
	for i=0,count,1  do
		local node = self:getChildren():objectAtIndex(i)
		if node.getTag and  tag == node:getTag() then
			local ret = callback(node)
			if nil ~=  ret then
				return ret
			end
		else
			if (otherCallback) then
				otherCallback(node)
			end
		end
	end
end

local gColorGrayHelp={
	pgGray = CCCommonFunctionHelp:getProgram(CCCommonFunctionHelp.kCCShaderExt_PositionTextureGrayColor),
	pgColor = CCCommonFunctionHelp:getProgram("ShaderPositionTextureColor")
}
function UI_SetEnable(node,b)
	node._Enabled=b
	if (b) then
	    node:setShaderProgram(gColorGrayHelp.pgColor)
	else
		node:setShaderProgram(gColorGrayHelp.pgGray)
	end
end
function UI_IsEnable(node)
	return node._Enabled
end

local _MessageBox =  class("_MessageBox",function() return CCNode:create() end)


--[[
callback_events = {
event_ok = function() end ...
event_cancel = function() end ...
}
]]
local ButtonType = enum({"MB_OK", "MB_CANCEL","MB_YES","MB_NO","MB_RETRY"})

function _MessageBox:close()
	
	_MessageBox.LayerClickRemove(self._nodeRoot)
	self:removeFromParentAndCleanup(true)
end
function _MessageBox:init_events(callback_events)
	function no_process(eventName)
		return function()
				printf("%s event not handled ",eventName)
				if(self:isRunning()) then
					self:removeFromParentAndCleanup(true)
				end
			end
	end
	local ret={}
	for k,v in pairs(callback_events) do
		if(not v) then
			v= no_process(k)
		end
		ret[k] = handler(self,v)

	end
	return ret
end


function _MessageBox.getRichTextCfgString(fmt,...)
local param={...}
	local defaultfont = param[1]["fontname"] or "Helvetica"
	local defaultsize = param[1]["fontsize"]
	local defaultcolor = param[1]["color"]
	
	local isempty = not( defaultfont or defaultsize or defaultcolor)
	for n= isempty and 2 or 1,#param,1 do
		local current = param[n]
		if type (current) ~= "string" then
			local fmt = current["format"]
			local font =current["fontname"]
			local size =current["fontsize"]
			local color = current["color"]
			local value = current["value"]
			value = (n==1 and "" or value or "")
			value =fmt and fmt:format(value) or value
			local colorstr = color and "<color><value>"..color.."</>".. value .."</>" or defaultcolor and "<color><value>"..defaultcolor.."</>".. value .."</>" or ""
			param[n] = string.format("<font>%s%s%s%s",
				font and "<fontname>"..font.."</>" or defaultfont and "<fontname>"..defaultfont.."</>" or "",
				size and "<fontsize>"..size.."</>" or defaultsize and "<fontsize>"..defaultsize.."</>" or "",
				colorstr,
				n==1 and "" or ((#colorstr>0 and "" or value).. "</>")
			)
		else
			param[n] = current
		end
	end
	if(isempty) then
		param[1]=""
	end

	for n=2,#param,1 do 
		param[n] = "</>" .. param[n] .. param[1]
	end
	return  param[1] ..string.format(fmt,unpack(param,2))
end
function _MessageBox.TTF2RichText(ttf,str,...)
	if(str == nil) then
		str = ttf:getString()
	end

	local param={...}

	local hasparam= #param~=0
	if(not hasparam) then
		param[1]={}
	end

	local RectSize = param[1]["size"] and CCSizeMake(unpack(param[1]["size"])) or ttf:getContentSize()
	local Position = param[1]["position"] or {ttf:getPosition()}
	
	param[1]["fontname"] =  param[1]["fontname"] or ttf:getFontName()
	param[1]["fontsize"] = param[1]["fontsize"] or ttf:getFontSize()
	for n= 2,#param,1 do
		if(type (param[n]) == "function") then
			param[n]=param[n](param[1])
		end
	end

	local defaultfont = param[1]["fontname"]
	local defaultsize = param[1]["fontsize"]
	local defaultcolor = param[1]["color"]

	str = hasparam and (_MessageBox.getRichTextCfgString(str,unpack(param)).."</>") or str

	local lable = RichLabel:create(str,defaultfont,defaultsize,RectSize,true,false)
	--lable:setAnchorPoint(ccp(0,1))
	lable:setPosition(unpack(Position))
	local node = ttf:getParent()
	ttf:removeFromParent()
	node:addChild(lable)
end

function _MessageBox.createSpriteFrame(fileOrFrameName)
	local ret
	if string.byte(fileOrFrameName) == 35 then -- first char is #
		ret = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(string.sub(fileOrFrameName,2))
	else
		local sp = CCSprite:create(fileOrFrameName)
		if (sp == nil) then
			return nil
		end

		local texture = sp:getTexture()
		local size = texture:getContentSize()
		ret = CCSpriteFrame:createWithTexture(texture,CCRectMake(0,0,size.width,size.height))
	end

	ret = ret and tolua.cast(ret,"CCSpriteFrame")
	return ret
end
function _MessageBox.createGraySpriteFrame(fileOrFrameName)
	local sprite = display.newSprite(fileOrFrameName)
	if(not sprite) then
		return nil
	end

	UI_SetEnable(sprite,false)

	local texture = sprite:getTexture()
	local size = texture:getContentSize()
	local ret = CCSpriteFrame:createWithTexture(texture,CCRectMake(0,0,size.width,size.height))
	ret = ret and tolua.cast(ret,"CCSpriteFrame")
	return ret
end
function _MessageBox.changeSpriteObj(sprite,newsprite)
	newsprite=tolua.cast(newsprite,"CCSprite")
	assert(sprite and newsprite,"")
	local spriteframe = newsprite:displayFrame()

	assert(spriteframe,"")

	sprite:setDisplayFrame(spriteframe)
end

function _MessageBox.changeSpriteImage(sprite,fileOrFrameName)
	sprite = tolua.cast(sprite,"CCSprite")
	local spriteFrame=_MessageBox.createSpriteFrame(fileOrFrameName)
	assert(sprite and spriteFrame,"")
	sprite:setDisplayFrame(spriteFrame)
end
function _MessageBox.changeScale9SpriteImage(scale9sprite,fileOrFrameName)
	local spriteFrame=_MessageBox.createSpriteFrame(fileOrFrameName)
	assert(spriteFrame,"")
	scale9sprite:setSpriteFrame(spriteFrame)
end


--_MessageBox.isTouchEnd = true
--_MessageBox.PRIORITY = -300
_MessageBox.Align = enum({"CENTER"})

function _MessageBox._setNodeSameSize(parent,TagID,size)

	executeByTag(parent,TagID,function(sub)
		if (sub.isScale9Sprite) then
			sub:setPreferredSize(size)
		else
			sub:setContentSize(size)
		end
		_MessageBox._setNodeSameSize(sub,TagID,size)	
	 end,
	 function(sub)
		_MessageBox._setNodeSameSize(tolua.cast(sub,"CCNode"),TagID,size)
	end)
end


function _MessageBox:getContentSize() 
	return self._nodeRoot:getContentSize()
end

function _MessageBox.LayerClick(layer,touchNode,onClick,onOutSide,priority,peekTouches,IsFullRange)
	layer:addTouchEventListener(function(e,x,y)
		local p1 = type(x) == "CCPoint" and x or type(x) == "table" and ccp(x[1],x[2]) or  type(x) == "number" and ccp(x,y) or false
		if(touchNode == nil) then
			touchNode = layer
		end

		p1 = touchNode:convertToNodeSpace(p1)
		local rect = touchNode:boundingBox()
		local anchorpoint = touchNode:getAnchorPoint()
		rect.origin.x = 0 
		rect.origin.y = 0 
		local inrect = IsFullRange or rect:containsPoint(p1)

		if(inrect) then
			if (e=="began") then
				return true
			elseif (e =="ended") then
				if (onClick) then
					local ret =	onClick(layer,p1)
					if (ret~=nil) then
						return ret
					end
					return true
				end
			end
		elseif(onOutSide) then
			local ret= onOutSide(e,p1)
			if (ret~=nil) then
				return ret
			end
		end
		return false
	end, false,priority or -128,not(peekTouches))
  	layer:setTouchEnabled(true)
end
function _MessageBox.LayerClickNodes(layer,touchNodes,onTouchBegin,onTouchMove,onTouchEnd,onOutSide,priority,peekTouches,IsFullRange)
	function getTouchedObjects(point)
		local retNodes={}
		if(touchNodes) then
			for i,touchNode in ipairs(touchNodes)do
				local pn= touchNode:convertToNodeSpace(point)
				local rect = touchNode:boundingBox()
				--local anchorpoint = touchNode:getAnchorPoint()
				rect.origin.x = 0 
				rect.origin.y = 0 
				if(rect:containsPoint(pn)) then
					retNodes[i]=pn
				end
			end
		end
		return retNodes
	end
	local islayerInIt = false
	for i,touchNode in ipairs(touchNodes)do
		if(touchNode == layer) then
			islayerInIt=true
			break
		end
	end
	if(islayerInIt) then
		table.insert(touchNodes,layer)
	end
	layer:addTouchEventListener(function(e,x,y)
		local p1 = type(x) == "CCPoint" and x or type(x) == "table" and ccp(x[1],x[2]) or  type(x) == "number" and ccp(x,y) or false
		if(IsFullRange) then
			if(e=="ended" and onClick) then
				if (not (onClick(layer,p1)==false)) then
					return true
				end
			end
			return true
		end


		local retNodes = getTouchedObjects(p1)

		local isprocessed = false
		for i,touchNode in ipairs(touchNodes)do
			if(touchNode:isVisible()) then
				if(retNodes[i]) then
					if (e=="began") then
						if (onTouchBegin and not (onTouchBegin(touchNode,retNodes[i])==false)) then
							return true
						end
					elseif(e=="ended") then
						if (onTouchEnd and not (onTouchEnd(touchNode,retNodes[i])==false)) then
							return true
						end
					elseif (e =="moved") then
						if (onTouchMove and not (onTouchMove(touchNode,retNodes[i])==false)) then
							return true
						end
					end
				elseif(onOutSide) then
					if (onOutSide(touchNode,p1)==true) then
						return true
					end
				end
			end
		end
		return false
	end, false,priority or -128,not(peekTouches))
  	layer:setTouchEnabled(true)
end

function _MessageBox.LayerClickRemove(layer)
	layer:setTouchEnabled(false)
	layer:removeTouchEventListener()
end

function _MessageBox:ctor(
	titleNodeOrImage,
	contentNodeOrCCBName,
	buttonNodesOrCCBName,
	callback_events,
	size,
	broad,
	--parent,
	--centerSetting,
	priority)

	local oldSetContentSize = self.setContentSize
	function self:setContentSize(size)
		oldSetContentSize(self,size)
		self._nodeRoot:setContentSize(size)
		self._setNodeSameSize(self._nodeRoot,1010,size)
	end

	self:registerScriptHandler(function(event)
		if event =="enter" then
			self:onEnter()
		elseif event =="exit" then
			self:onExit()
		end
	end)
	local broadImageName = broad and broad.imageName
	local capInsetsRect = broad and broad.capInsetsRect
	local msgCCBFile = broad and broad.MainCCBFile or "TalentMessagebox.ccbi"

	if(not callback_events) then
		callback_events={}
	end

	--if (buttonNodesOrCCBName == nil) then
		callback_events.event_MB_OK = callback_events.event_MB_OK or false
		callback_events.event_MB_CANCEL = callback_events.event_MB_CANCEL or false
		callback_events.event_NOMB_OUTSIDE = callback_events.event_NOMB_OUTSIDE or false
		callback_events.event_NOMB_INSIDE = callback_events.event_NOMB_INSIDE or function() end
		callback_events.event_NOMB_ENTER = callback_events.event_NOMB_ENTER or function() end
		callback_events.event_NOMB_LEAVE = callback_events.event_NOMB_LEAVE or function() end
	--end
	local owner= self:init_events(callback_events)
	self._owner = owner

	local proxy = CCBProxy:create()
	
	local layer = broad and broad.MainNode or tolua.cast(CCBuilderReaderLoad(msgCCBFile,proxy,owner),"CCLayer")
	assert(layer,"Message Background Node not exist, pls check it")
	for k,v in pairs(owner) do
		if (type(v) ~= "function") then
			v.Name = k
		end
	end

	owner.ccb_borad = tolua.cast(owner.ccb_borad,"CCScale9Sprite")
	owner.spriteTitleBg = tolua.cast(owner.spriteTitleBg,"CCScale9Sprite")
	owner.btn_MB_OK = tolua.cast(owner.btn_MB_OK,"CCMenuItem")
	owner.btn_MB_Upgrade = tolua.cast(owner.btn_MB_Upgrade,"CCMenuItem")
	owner.btn_MB_CANCEL = tolua.cast(owner.btn_MB_CANCEL,"CCMenuItem")
	local closeMenu = tolua.cast(owner.btn_MB_CANCEL:getParent(),"CCMenu")
	closeMenu:setTouchPriority(-999)
	--owner.ccb_borad.setContentSize = owner.ccb_borad.setPreferredSize
	owner.ccb_borad.isScale9Sprite = true
	self._nodeRoot = layer

	local contentNode
	if (contentNodeOrCCBName ~=nil) then
		if (contentNodeOrCCBName.CCBFile ) then
			contentNodeOrCCBName.Node = CCBuilderReaderLoad(contentNodeOrCCBName.CCBFile,proxy,owner)
		end
		if (contentNodeOrCCBName.Node) then
			contentNode = contentNodeOrCCBName.isTop and owner.ccb_contentTop or owner.ccb_content
			if (contentNodeOrCCBName.autoSize) then
			   size = contentNodeOrCCBName.Node:getContentSize()
			end		
		else
			printf("contentNodeOrCCBName is nil")
		end
	end

	if (broadImageName) then
		self.changeScale9SpriteImage(owner.ccb_borad,broadImageName)
		if size ~= nil then
		  owner.ccb_borad:setContentSize(size)
		end
	--elseif(broad) then
	--	self.changeScale9SpriteImage(owner.ccb_borad,"#empty.png")
	end
	if (capInsetsRect) then
	   owner.ccb_borad:setCapInsets(capInsetsRect)
	end


	if (size ~=nil) then
		self:setContentSize(size)
		local titleBgSize = CCSizeMake(size.width - 2,owner.spriteTitleBg:getContentSize().height)
		owner.spriteTitleBg:setContentSize(titleBgSize)
		closeMenu:setPositionX(titleBgSize.width/2)
	end

	if(contentNodeOrCCBName and contentNodeOrCCBName.Node and contentNode) then
		contentNode:removeAllChildren()
		contentNode:addChild(contentNodeOrCCBName.Node)
		if (contentNodeOrCCBName.isBack)  then
			contentNode:setZOrder(-1)
		end
	end
	if (buttonNodesOrCCBName) then
		if ( type(buttonNodesOrCCBName) =="string") then
			buttonNodesOrCCBName = CCBuilderReaderLoad(buttonNodesOrCCBName,proxy,owner) 
		end
  		owner.ccb_buttons:removeAllChildren()
		owner.ccb_buttons:addChild(buttonNodesOrCCBName)
	end

	if (titleNodeOrImage ~=nil) then
		if (type(titleNodeOrImage) == "string") then
			self.changeSpriteImage(owner.ccb_title, titleNodeOrImage)
		else
			local parent = owner.ccb_title:getParent()
			owner.ccb_title:removeFromParentAndCleanup(true)
			parent:addChild(titleNodeOrImage)
		end
	end

	_MessageBox.LayerClick(layer,layer,owner.event_NOMB_INSIDE,owner.event_NOMB_OUTSIDE,priority)

	self:setAnchorPoint(ccp(0.5,0.5))
	layer:setAnchorPoint(ccp(0,0))
	self:addChild(layer)

end
function _MessageBox:show(parent,align,canvasContentSize)
	self:removeFromParentAndCleanup(true)
	if (not align) then
		align = _MessageBox.Align.CENTER
	end

	local psize
	local selfSize = self:getContentSize()
	local addChild

	if(parent) then
		psize = parent:getContentSize()
		addChild = parent.addChild
	else
		psize = CCDirector:sharedDirector():getWinSize()
		parent = GameData:Instance():getCurrentScene()
		addChild =GameData:Instance():getCurrentScene().addChildView
	end
	if(canvasContentSize) then
		psize = canvasContentSize
	end
	local posX = psize.width/2 
	local posY = psize.height/2  
	self:setPosition(ccp(posX,posY))
	addChild(parent,self)

end

function _MessageBox:setIsOKButton(visible)
  self._owner.btn_MB_OK:setVisible(visible)
  self._owner.btn_MB_Upgrade:setVisible(not visible)
end

function _MessageBox:setEnableOKButton(b,isOkBtn)
	self._owner.btn_MB_OK:setEnabled(b)
	self._owner.btn_MB_Upgrade:setEnabled(b)
end
function _MessageBox:onExit()
	--if(self._owner.event_NOMB_LEAVE) then
		self._owner.event_NOMB_LEAVE(self)
	--end
	for k,cfg in pairs(self._dataConfig) do 
		if (type(cfg.clean) == "function") then
			local item = self._owner[k]
			if (item and type(item)~="function") then
				cfg.clean(self,item)
			end
		end
	end

	self:unregisterScriptHandler()
end
function _MessageBox:onEnter()
	if (self._enterAction) then
		self:setScale(0.5)
		self:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5, 1.0),0.3))
	end
	--if(self._owner.event_NOMB_ENTER) then
		self._owner.event_NOMB_ENTER(self)
	--end
end
function _MessageBox:getComponentsAndEvents()
	return self._owner
end
function _MessageBox:initData(data,enterAction)
	self._dataConfig = data
	self._enterAction = enterAction
	for k,cfg in pairs(self._dataConfig) do 
		if (type(cfg.init) == "function") then
			local item = self._owner[k]
			if (item and type(item)~="function") then
				cfg.init(self,item)
			end
		end
	end
end
local MessageType = enum({"MB_OKCANCEL", "MB_OK","MB_YESNO","MB_YESNOCANCEL", 
                  "MB_RETRYCANCEL","MB_USERDEFINED"})


MessageBox = {}

local function setString(o,t,v)
	o = tolua.cast(o,t)
	o:setString(v)
end
local function bindString(t,b,color)
	if (type(color) =="number") then
		color = ccc3(color%0x10000,color%0x100 and 0xff,color and 0xff)
	end
	return function(s,o)
		o = tolua.cast(o,t)
		if b == nil then
			b = _tr("=数据不存在=")
		end
		o:setString(b)
		if (color) then
			o:setColor(color)
		end
	end
end
MessageBox.Help={
	bindStringTTFFormat = function(...)
		local data={...} 
		return function(s,o)
			o = tolua.cast(o,"CCLabelTTF")
			o:setString(o:getString():format(unpack(data)))
		end
	end,
	bindStringTTF = function (b,color)
		return bindString("CCLabelTTF",b,color)
	end,
	bindStringBMF = function (b)
		return bindString("CCLabelBMFont",b)
	end	,
	bindImageSprite = function (file)
		return function (s,o)
		o = tolua.cast(o,"CCSprite") 
		_MessageBox.changeSpriteImage(o,file)
		end
	end,
	changeSpriteImage=_MessageBox.changeSpriteImage,
	changeSpriteObj = _MessageBox.changeSpriteObj,
	createSpriteFrame = _MessageBox.createSpriteFrame,
	--createGraySpriteFrame = _MessageBox.createGraySpriteFrame,
	LayerClick = _MessageBox.LayerClick,
	LayerClickRemove = _MessageBox.LayerClickRemove,
	LayerClickNodes = _MessageBox.LayerClickNodes,
	getRichTextCfgString = _MessageBox.getRichTextCfgString,
	TTF2RichText = _MessageBox.TTF2RichText,
	bindTTF2RichText = function(...)
		local data={...}
		return function(s,o)
			o = tolua.cast(o,"CCLabelTTF")		
			_MessageBox.TTF2RichText(o,o:getString(),unpack(data))
		end
	end
}
MessageBox.popType = MessageType
MessageBox.Align = _MessageBox.Align


function MessageBox.showTalentUpgrade(dataObj,events,parent,CenterSetting)
	local pop = _MessageBox.new(
	"#talent_tianfu_shengjitianfu.png"
	,{CCBFile="TalentUpgrade.ccbi",isTop = false,autoSize=true}
	,nil
	,events	)
	pop:setIsOKButton(false)
	pop:initData(dataObj,true)
	pop:show(parent,CenterSetting)

	return pop
end
function MessageBox.showTalentBankUpgrade(dataObj,events,parent,CenterSetting)
	local pop = _MessageBox.new(
	"#talent_tianfu_tishengkucun.png"
	,{CCBFile="TalentStockadd.ccbi",isTop = false,autoSize=true}
	,nil
	,events
	)
	pop:setIsOKButton(false)
	pop:initData(dataObj,true)
	pop:show(parent,CenterSetting)

	return pop
end

function MessageBox.showTalentBankFinishRightNow(dataObj,events,parent,CenterSetting)
	local pop = _MessageBox.new(
	"#talent_tianfu_lijiwancheng.png"
	,{CCBFile="TalentComplete.ccbi",isTop = false,isBack=true,autoSize=true}
	,nil
	,events
	,nil
	,{imageName = "#talent_messagebox_borad_2.png"}	)
	pop:setIsOKButton(true)
	pop:initData(dataObj,true)
	pop:show(parent,CenterSetting)

	return pop
end

function MessageBox.showTalentFinishRightNow(dataObj,events,parent,CenterSetting)
	local pop = _MessageBox.new(
	"#talent_tianfu_lijiwancheng.png"
	,{CCBFile="TalentAccelerate.ccbi",autoSize=true}
	,nil
	,events	)
	pop:setIsOKButton(true)
	pop:initData(dataObj,true)
	pop:show(parent,CenterSetting)

	return pop
end

function MessageBox.showCommonFastBuy(dataObj,events,parent,CenterSetting)
	local priority=-999
	local pop = _MessageBox.new("#common_tishi.png"	,{CCBFile="CommonFastBuy.ccbi",autoSize=true}	,CCNode:create()	,events,nil,nil,priority	)
	local owner = pop:getComponentsAndEvents()
	tolua.cast(owner.btn_use:getParent(),"CCMenu"):setTouchPriority(priority)
	tolua.cast(owner.btn_buy:getParent(),"CCMenu"):setTouchPriority(priority)
	tolua.cast(owner.lbl_hit,"CCLabelTTF"):setDimensions(CCSizeMake(340,0))
	pop:initData(dataObj,true)
	pop:setIsOKButton(true)
	pop:show(parent,CenterSetting)
	return pop
end

function MessageBox.showPannel1(node,events,priority,parent,CenterSetting)
	if (priority == nil) then
		priority = -128
	end
	local pop = _MessageBox.new("#common_tishi.png"	,{Node=node,isTop = false,isBack=true,autoSize=true},nil,events,nil,{imageName = "#talent_messagebox_borad_2.png"},priority)
	local owner = pop:getComponentsAndEvents()
	tolua.cast(owner.btn_MB_CANCEL:getParent(),"CCMenu"):setTouchPriority(priority)
	tolua.cast(owner.btn_MB_OK:getParent(),"CCMenu"):setTouchPriority(priority)
	pop:initData({},true)
	pop:setIsOKButton(true)
	pop:show(parent,CenterSetting)
	return pop
end


--function MessageBox.createActivityPop(parent,align)	
--	local dataObj = Activity:instance():getActivitySetting()
--	local showItems={}
--	for n,v in ipairs(dataObj) do
--		if (v[3]()) then
--			table.insert(showItems,v)
--		end
--	end

--	function buildTableView(self)

--		local function tableCellTouched(tableview,cell)
		
--			local itemsetting = showItems[cell:getIdx()+1]
--			if(itemsetting) then
--				itemsetting[2]()
--				self:close()
--			else
--				print("cell touched at index(not found): " .. cell:getIdx())
--			end
--		end

--		local function cellSizeForTable(table,idx)
--			local subnode =display.newSprite(showItems[idx+1][1])
--			local g_cellSize = subnode:getContentSize()
--			subnode=nil

--			return  g_cellSize.height+10,g_cellSize.width
--		end
  
--		local function tableCellAtIndex(tableView, idx)

--			local cell = tableView:dequeueCell()
--			if nil == cell then
--				cell = CCTableViewCell:new()  
--			else
--				cell:removeAllChildrenWithCleanup(true)
--				cell:reset()
--			end

--			cell:setIdx(idx)
--			local itemsetting = showItems[idx+1]

--			local spr = display.newSprite(itemsetting[1])
--			if (spr) then
--				spr:setAnchorPoint(ccp(0,0))
--				cell:addChild(spr)
--			end

--			return cell
--		end

--		local function numberOfCellsInTableView(val)
--			return #showItems
--		end

--		local mSize = self:getContentSize() --CCSizeMake(544,726)
--		mSize.width = mSize.width - 40
--		mSize.height = mSize.height - 60
--		self._tableView = CCTableView:create(mSize)

--		--self._firstShowCellNum = math.ceil(mSize.height /g_cellSize.height )
--		self._owner.ccb_content:addChild(self._tableView)
--		self._tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
--		self._tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
--		self._tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
--		self._tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
--		self._tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
--		self._tableView:setPosition(30,10)
--		self._tableView:setTouchPriority(-9999)
--		self._tableView:reloadData()
--	end


--	local pop = _MessageBox.new(
--	"#Activity_title.png"
--	,nil
--	,nil
--	,{
--	event_NOMB_ENTER={["Function"]=function(myobj,self)
--		--display.addSpriteFramesWithFile("activity/activity_notice.plist","activity/activity_notice.png")
--		buildTableView(self)
--	end},
--	event_NOMB_LEAVE={["Function"]=function(myobj,self)
--		self._owner.ccb_content:removeAllChildrenWithCleanup()
--		--display.removeSpriteFramesWithFile("activity/activity_notice.plist","activity/activity_notice.png")
--	end}
--	}											--callback_events
--	,nil								--size
--	,{MainCCBFile = "ActivityPop.ccbi"}	--broad
--	,parent
--	,align	
--	)

--	pop:initData({},true)

--	if(not (parent or align) ) then
--		return pop
--	end
--	return nil
--end