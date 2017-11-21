 QuestAwardDetailView = class("QuestAwardDetailView",BaseView)
 function QuestAwardDetailView:ctor()
  local pkg = ccbRegisterPkg.new(self)
  
  pkg:addProperty("spriteBg","CCSprite")
  pkg:addProperty("tableViewCon","CCNode")

  local layer,owner = ccbHelper.load("QuestAwardDetailView.ccbi","QuestDetailCCB","CCLayer",pkg)
  self:addChild(layer)
 end
 
 return QuestAwardDetailView