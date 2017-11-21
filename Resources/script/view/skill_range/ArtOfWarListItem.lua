ArtOfWarListItem = class("ArtOfWarListItem",BaseView)
function ArtOfWarListItem:ctor()
  
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeEffect","CCNode")
  pkg:addProperty("labelName","CCLabelTTF")
  pkg:addProperty("labelDesc","CCLabelTTF")
  local node,owner = ccbHelper.load("AtrOfWarListItem.ccbi","ArtOfWarListItemCCB","CCNode",pkg)
  self:addChild(node)
end

------
--  Getter & Setter for
--      ArtOfWarListItem._Data 
-----
function ArtOfWarListItem:setData(Data)
	self._Data = Data
	if Data ~= nil then
	   self.nodeEffect:removeAllChildrenWithCleanup(true)
	   local res = _res(Data.icon)
	   self.nodeEffect:addChild(res)
	   
	   if Data.pos == 1 then
	      res:setPosition(ccp(45,25))
	      res:setScale(0.8)
	   else
	   
	   end
	   
	   self.labelName:setString(Data.name)
	   self.labelDesc:setString(Data.content)
	end
end

function ArtOfWarListItem:getData()
	return self._Data
end

return ArtOfWarListItem