BattleAccountView = class("BattleAccountView",BaseView)

function BattleAccountView:ctor()
	local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("scale9SpriteBg","CCScale9Sprite")
  pkg:addProperty("labelCoin","CCLabelTTF")
  pkg:addProperty("labelLevel","CCLabelTTF")
  pkg:addProperty("labelExp","CCLabelTTF")
  pkg:addProperty("lableOldLevel","CCLabelTTF")
  pkg:addProperty("lableOldCost","CCLabelTTF")
  pkg:addProperty("lableOldHp","CCLabelTTF")
  pkg:addProperty("lableOldFriendMax","CCLabelTTF")
  pkg:addProperty("labelNewLevel","CCLabelTTF")
  pkg:addProperty("labelNewCost","CCLabelTTF")
  pkg:addProperty("lableNewHp","CCLabelTTF")
  pkg:addProperty("lableNewFriendMax","CCLabelTTF")
  local layer,owner = ccbHelper.load("BattleAccountView.ccbi","BattleAccountCCB","CCLayer",pkg)
  self:addChild(layer)
end

return BattleAccountView