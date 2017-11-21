ChannelSharePopView = class("ChannelSharePopView",BaseView)
channelView=nil
function ChannelSharePopView:ctor(super)
  self._channelView = super
  math.randomseed(os.time())
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("lb_share_bonus_tip","CCLabelTTF")
  pkg:addProperty("lb_text_1","CCLabelTTF")
  pkg:addProperty("lb_text_2","CCLabelTTF")
  pkg:addProperty("lb_text_3","CCLabelTTF")
  pkg:addProperty("lb_text_4","CCLabelTTF")
  pkg:addProperty("lb_text_5","CCLabelTTF")
  pkg:addProperty("lb_share_success","CCSprite")
  pkg:addProperty("extra_bonus","CCSprite")
  pkg:addProperty("sprite_coin_1","CCSprite")
  pkg:addProperty("sprite_coin_2","CCSprite")
  pkg:addProperty("sprite_title_1","CCSprite")
  pkg:addProperty("sprite_title_2","CCSprite")
  pkg:addFunc("onShareClick",ChannelSharePopView.onShareClick)
  local layer,owner = ccbHelper.load("ChannelSharePopView.ccbi","ChannelSharePopViewCCB","CCLayer",pkg)
  self:addChild(layer)
  self:setTouchEnabled(true)
  self:addTouchEventListener(
    function(event, x, y)
      return true
    end,false, -128, true)
end


function ChannelSharePopView:setResult(result)
   self._result=result
   if result.page == "share"  then --分享提示页面
     self.lb_text_1:setVisible(true)
     self.sprite_title_1:setVisible(true)
     self.sprite_title_2:setVisible(false)
     self.lb_text_2:setVisible(true)
     self.lb_share_bonus_tip:setString("每日首次分享均可获得")
     self.lb_share_bonus_tip:setVisible(true)  
     self.lb_text_1:setString("根据当前角色等级可获得")
     local level=GameData:Instance():getCurrentPlayer():getLevel()
     local coin=AllConfig.wechat[level].bonus[1].array[3]
     self.lb_text_2:setString(coin)
     self.sprite_coin_1:setVisible(true)
     self.sprite_coin_2:setVisible(false)
     self.extra_bonus:setVisible(true) 
     self.lb_share_success:setVisible(false) 
     self.lb_text_5:setVisible(false)
   elseif result.page == "result" then--分享成功提示页面
      self.lb_share_success:setVisible(true) 
      self.extra_bonus:setVisible(false) 
      self.lb_share_bonus_tip:setVisible(false)  
      self.lb_text_1:setVisible(false)
      self.lb_text_2:setVisible(false)
      self.lb_text_3:setString("恭喜您获得")
      self.lb_text_4:setString(result.coin)
      self.sprite_coin_1:setVisible(false)
      self.sprite_coin_2:setVisible(true)
      self.lb_text_3:setVisible(true)
      self.lb_text_4:setVisible(true)
      self.sprite_title_1:setVisible(false)
      self.sprite_title_2:setVisible(true)
      self.lb_text_5:setVisible(false)
      if result.coin == 0 then --今天已经分享过
        self.lb_text_3:setVisible(false)
        self.lb_text_4:setVisible(false)
        self.sprite_coin_1:setVisible(false)
        self.sprite_coin_2:setVisible(false)
        self.lb_text_5:setVisible(true)
        self.lb_text_5:setString("谢谢您的分享")
      end
   end
end


function ChannelSharePopView:onShareClick()
	if self._result.page == "share" then --分享
	  self:removeFromParentAndCleanup(true)
     local filePath
     local number = math.random(1,3)
     number = math.random(1,3)
     if number == 1 then
        filePath = CCFileUtils:sharedFileUtils():fullPathForFilename("img/share/cao_chuan_jie_jian.jpg")
     elseif number == 2 then
        filePath = CCFileUtils:sharedFileUtils():fullPathForFilename("img/share/san_gu_mao_lu.jpg")
     elseif number ==3 then
        filePath = CCFileUtils:sharedFileUtils():fullPathForFilename("img/share/san_ying_zhan_lv_bu.jpg")
     end
     local args={filePath=filePath}
     local luaoc=require("framework.ocbridge")
     local className="WeChatBridge"
     local function weiXinCallback()
        luaoc.callStaticMethod(className,"unregisterScriptHandler")
        self._channelView:onShareCallback()
     end
     luaoc.callStaticMethod(className,"registerScriptHandler",{scriptHandler=weiXinCallback})
     local ret=luaoc.callStaticMethod(className,"sendPhotoContent",args)
     
	elseif self._result.page=="result" then --确定
    self:removeFromParentAndCleanup(true)
	end
end

return ChannelSharePopView
