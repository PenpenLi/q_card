SystemContact = class("SystemContact",BaseView)
function SystemContact:ctor()
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("node_free","CCNode")
  pkg:addProperty("node_uc","CCNode")
  pkg:addProperty("spriteBackground","CCSprite")
  pkg:addProperty("label_officialMail","CCLabelTTF")
  pkg:addProperty("label_officialMail2","CCLabelTTF")
  pkg:addProperty("label_officialQQ","CCLabelTTF")
  
  pkg:addProperty("labelLine","CCLabelTTF")
  pkg:addProperty("labelEmailAdress","CCLabelTTF")
  pkg:addProperty("labelEmailAdress2","CCLabelTTF")
  

  local layer,owner = ccbHelper.load("SystemContact.ccbi","SystemContactCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.label_officialMail:setString(_tr("qcard_email"))
  self.label_officialMail2:setString(_tr("qcard_email"))
  self.label_officialQQ:setString(_tr("qcard_QQ"))
  
  self.labelEmailAdress:setString(_tr("contact_email_adress"))
  self.labelEmailAdress2:setString(_tr("contact_email_adress"))
  self.labelLine:setString(_tr("contact_line"))
  
  if ChannelManager:getCurrentLoginChannel() == 'uc'
  or GameData:Instance():getLanguageType() == LanguageType.JPN then
     self.node_uc:setVisible(true)
     self.node_free:setVisible(false)
  else
     self.node_uc:setVisible(false)
     self.node_free:setVisible(true)
  end
end

function SystemContact:getContentSize()
  return self.spriteBackground:getContentSize()
end

return SystemContact