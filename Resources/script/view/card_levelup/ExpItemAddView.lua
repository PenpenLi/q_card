require("view.component.DropItemView")
ExpItemAddView = class("ExpItemAddView",BaseView)
function ExpItemAddView:ctor(configId,count,priority)
  assert(configId ~= nil and count ~= nil,"must create with params:'configId' and 'count'")
  ExpItemAddView.super.ctor(self)
  self._priority = priority
  self:setConfigId(configId)
  self._count = count
  self:setSelectedCount(0)
end

------
--  Getter & Setter for
--      ExpItemAddView._ConfigId 
-----
function ExpItemAddView:setConfigId(ConfigId)
	self._ConfigId = ConfigId
end

function ExpItemAddView:getConfigId()
	return self._ConfigId
end

function ExpItemAddView:onEnter()
  local iconSprite = DropItemView.new(self._ConfigId,self._count)
  self:addChild(iconSprite)
  iconSprite:setScale(0.9)
  self:setContentSize(iconSprite:getContentSize())
  iconSprite:setShowString(self._count.."")
  self._iconSprite = iconSprite
  
  local label = CCLabelBMFont:create("", "client/widget/words/card_name/number_skillup.fnt")
  local labelSize = tolua.cast(label:getContentSize(),"CCSize")  
  label:setAnchorPoint(ccp(0.5,0.5))
  label:setPosition(ccp(labelSize.width/2 + 10,iconSprite:getContentSize().height/2 + 20))
  self:addChild(label)
  self._addedCountLabel = label
  
  local callBack = function()
    print("reduce")
    self:getDelegate():reduceCount(self)
--    local selectedCount = self:getSelectedCount()
--    if selectedCount >= 1 then
--      selectedCount = selectedCount - 1
--      self:setSelectedCount(selectedCount)
--    end
  end
  
  local normal,highted,disabled
  normal = display.newSprite("#shangzhen_jian0.png")
  highted = display.newSprite("#shangzhen_jian2.png")
  disabled = display.newSprite("#shangzhen_jian2.png")
  local reduce = UIHelper.ccMenuWithSprite(normal,highted,disabled,callBack)
  self:addChild(reduce)
  reduce:setPositionY(-75)
  self._btnReduce = reduce
  reduce:setTouchPriority(self._priority or  -256)
  self._btnReduce:setVisible(false)
end

function ExpItemAddView:onExit()
  
end

------
--  Getter & Setter for
--      ExpItemAddView._SelectedCount 
-----
function ExpItemAddView:setSelectedCount(SelectedCount)
	self._SelectedCount = SelectedCount
	local btnReduceVisible = (SelectedCount > 0)
	if self._btnReduce ~= nil then
    self._btnReduce:setVisible(btnReduceVisible)
  end
	
	if self._addedCountLabel ~= nil then
	 local str = SelectedCount..""
	 if SelectedCount <= 0 then
	   str = ""
	 end 
	 self._addedCountLabel:setString(str)
	end
	
	if self._iconSprite ~= nil then
	   self._iconSprite:setShowString(math.max(self._count - SelectedCount,0).."")
	end

end

function ExpItemAddView:getSelectedCount()
	return self._SelectedCount
end

function ExpItemAddView:getEachExp()
  local eachExp = AllConfig.item[self._ConfigId].bonus[3] 
  return eachExp 
end

function ExpItemAddView:getSelectedExp()
  local eachExp = AllConfig.item[self._ConfigId].bonus[3] 
  return eachExp * self._SelectedCount
end

function ExpItemAddView:setCount(count)
  self._count = count
end

function ExpItemAddView:getCount()
  return self._count
end

return ExpItemAddView