BattleReportItem = class("BattleReportItem",BaseView)

function BattleReportItem:ctor(data)
	local pkg = ccbRegisterPkg.new(self)
    pkg:addProperty("isSelectedHightLight","CCScale9Sprite")
	pkg:addProperty("lablebattleDesc","CCLabelTTF")

	pkg:addProperty("lablebattleDesc","CCLabelTTF")
	pkg:addProperty("lablebattleDesc","CCLabelTTF")
	pkg:addProperty("labelMyName","CCLabelTTF")
	pkg:addProperty("labelWinCoin","CCLabelTTF")
	pkg:addProperty("lableWinScroe","CCLabelTTF")
	pkg:addProperty("lablebTime","CCLabelTTF")

  pkg:addProperty("lableBattleDesc","CCLabelTTF")
  pkg:addProperty("lableCoin","CCLabelTTF")
  pkg:addProperty("lableWinCoin","CCLabelTTF")
  pkg:addProperty("lableWinScore","CCLabelTTF")
  pkg:addProperty("lableTelentPoint","CCLabelTTF")
  pkg:addProperty("lableTime","CCLabelTTF")
  pkg:addProperty("spriteWinIcon","CCSprite")
  pkg:addProperty("spriteFailIcon","CCSprite")
  pkg:addProperty("nodePreviewContainer","CCNode")
  pkg:addProperty("btnReview","CCControlButton")
  
  pkg:addFunc("onClickReviewHandler",BattleReportItem.onClickReviewHandler)
  pkg:addFunc("shareHandler",BattleReportItem.shareHandler)
  local layer,owner = ccbHelper.load("ExpeditionBattleReportItem.ccbi","BattleReportItemCCB","CCLayer",pkg)
  self:addChild(layer)
  self.isSelectedHightLight:setVisible(false)

  self:setData(data)
end
--startReviewBattleWithResult
------
--  Getter & Setter for
--      BattleReportItem._Selected 
-----
function BattleReportItem:setSelected(Selected)
	self._Selected = Selected
	if self._Selected == true then
  end
	
end

function BattleReportItem:shareHandler()
  BattleReportShare:Instance():reqShareBattleReportShare(self:getData():getId(),"PVP_NORMAL")
end

function BattleReportItem:onClickReviewHandler()
  print("onClickReviewHandler")
  print("reviewId:",self:getData():getReviewId())
  BattleReportShare:Instance():reqBattleReview(self:getData():getReviewId(),"PVP_NORMAL")
end

function BattleReportItem:setData(Data)
	self._Data = Data
	-- wrong, for test
	--self.lableCoin:setString("奖励：")
	
	if self._Data ~= nil then
	   local targetPlayer = nil
	   self.spriteWinIcon:setVisible(false)
     self.spriteFailIcon:setVisible(false)
	   if self._Data:getAttacker():getPlayerId() == GameData:Instance():getCurrentPlayer():getId() then
	      if self._Data:getBattleResult() == 2 or self._Data:getBattleResult() == 3 or self._Data:getBattleResult() == 4 then
	         self.spriteWinIcon:setVisible(true)
	         self.lableWinScore:setColor(sgGREEN)
	         self.lableWinScore:setString("+ "..NumberHelp.greateThanZero(self._Data:getBattleAttackScore()))
	         self.lableWinCoin:setColor(sgGREEN)
	         self.lableWinCoin:setString("+ ".. NumberHelp.greateThanZero(self._Data:getAllCoin()))
	         self.lableTelentPoint:setColor(sgGREEN)
	         self.lableTelentPoint:setString("+ "..NumberHelp.greateThanZero(self._Data:getTelentPoint()))
	      elseif self._Data:getBattleResult() == 5 or self._Data:getBattleResult() == 6 or self._Data:getBattleResult() == 7 then
	         self.spriteFailIcon:setVisible(true)
	         self.lableWinScore:setColor(sgRED)
	         --if self._Data:getBattleAttackScore() <= 0 then
	            --self.lableWinScore:setString("- 0")
	         --else
	            self.lableWinScore:setString("- "..NumberHelp.greateThanZero(self._Data:getBattleAttackScore()))
	         --end
	         
	         self.lableTelentPoint:setColor(sgRED)
	         --if self._Data:getTelentPoint() <= 0 then
              --self.lableTelentPoint:setString("- 0")
           --else
              self.lableTelentPoint:setString("- ".. NumberHelp.greateThanZero(self._Data:getTelentPoint()))
           --end
	         
	         self.lableWinCoin:setColor(sgRED)
	         --if self._Data:getAllCoin() <= 0 then
	            --self.lableWinCoin:setString("- 0")
	         --else
	           self.lableWinCoin:setString("- "..NumberHelp.greateThanZero(self._Data:getAllCoin()))
	            -- wrong, for test
	             --self.lableWinCoin:setColor(sgGREEN)
	             --self.lableWinCoin:setString("0")
	         --end
	      else
	         echo("unexp battle result",self._Data:getBattleResult())
	      end
	      --self.lableWinCoin:setString((self._Data:getCoin() + self._Data:getMinerCoin()).."")
	      self.lableBattleDesc:setString(_tr("you_attack%{playerName}",{playerName = self._Data:getDefender():getPlayerName()})) --_tr("你攻打了 ".. self._Data:getDefender():getPlayerName())
	      targetPlayer = self._Data:getDefender()
	   else
	      if self._Data:getBattleResult() == 5 or self._Data:getBattleResult() == 6 or self._Data:getBattleResult() == 7 then
           self.spriteWinIcon:setVisible(true)
           self.lableWinScore:setColor(sgGREEN)
           self.lableWinScore:setString("+ "..NumberHelp.greateThanZero(self._Data:getBattleDefendScore()))
           self.lableBattleDesc:setString(_tr("you_resist%{playerName}",{playerName = self._Data:getAttacker():getPlayerName()}))  --_tr("你抵御了 ".. self._Data:getAttacker():getPlayerName().." 的进攻")
           
           self.lableWinCoin:setColor(sgGREEN)
           self.lableWinCoin:setString("+ "..NumberHelp.greateThanZero(self._Data:getAllCoin()))
           
           self.lableTelentPoint:setColor(sgGREEN)
           self.lableTelentPoint:setString("+ "..NumberHelp.greateThanZero(self._Data:getTelentPoint()))
          
        elseif self._Data:getBattleResult() == 2 or self._Data:getBattleResult() == 3 or self._Data:getBattleResult() == 4 then
           self.spriteFailIcon:setVisible(true)
           self.lableWinScore:setColor(sgRED)
           --if self._Data:getBattleDefendScore() <= 0 then
              --self.lableWinScore:setString("- 0")
           --else
              self.lableWinScore:setString("- "..NumberHelp.greateThanZero(self._Data:getBattleDefendScore()))
           --end
           self.lableBattleDesc:setString( _tr("%{playerName}attack_you",{playerName = self._Data:getAttacker():getPlayerName()}))  --_tr(self._Data:getAttacker():getPlayerName().." 攻打了 您 的城池")
           
           self.lableTelentPoint:setColor(sgRED)
           --if self._Data:getTelentPoint() <= 0 then
              --self.lableTelentPoint:setString("- 0")
           --else
              self.lableTelentPoint:setString("- "..NumberHelp.greateThanZero(self._Data:getTelentPoint()))
           --end
           
           self.lableWinCoin:setColor(sgRED)
           --if self._Data:getAllCoin() <= 0 then
              --self.lableWinCoin:setString("- 0")
           --else
              self.lableWinCoin:setString("- "..NumberHelp.greateThanZero(self._Data:getAllCoin()))
              -- wrong, for test
               --self.lableWinCoin:setColor(sgGREEN)
               --self.lableWinCoin:setString("0")
           --end
           
        else
           echo("unexp battle result",self._Data:getBattleResult())
        end
        --self.lableWinCoin:setString("0")
        targetPlayer = self._Data:getAttacker()
        
	   end
	   if self._Data:getFightTime() ~= nil then
	       local nowTime = Clock:Instance():getCurServerUtcTime()
	      
	       local reportTime = self._Data:getFightTime()
	       local miniutes = math.ceil((nowTime - self._Data:getFightTime())/60)
	       echo(miniutes,"ago")
	       local timeShowStr = ""
	       if miniutes < 60 then
	           timeShowStr = _tr("%{miniute}ago",{miniute = miniutes}) --_tr(miniutes.."分钟前")
	       elseif miniutes >= 60 and miniutes < 1440 then
	           timeShowStr =  _tr("%{hour}hour_ago",{hour = math.floor(miniutes/60)}) --_tr(math.floor(miniutes/60).."小时前")
	       else
	           timeShowStr = _tr("%{day}day_ago",{day = math.floor(miniutes/1440)}) --_tr(math.floor(miniutes/1440).."天前")
	       end
	       self.lableTime:setString(timeShowStr)
	   end
	   
	   self.nodePreviewContainer:removeAllChildrenWithCleanup(true)
      if targetPlayer:getHeadId() ~= nil then
         local headIcon = nil
         if targetPlayer:getHeadId() > 1 then
            headIcon = _res(targetPlayer:getHeadId())
         else
            headIcon = _res(3012502)
         end
         if headIcon ~= nil then
            headIcon:setScale(0.65)
            self.nodePreviewContainer:addChild(headIcon)
         end
      end
	end
	
	  
  if self:getData():getReviewId() > 0 then
     self.btnReview:setEnabled(true)
  else
     self.btnReview:setEnabled(false)
  end
end

function BattleReportItem:getData()
	return self._Data
end

function BattleReportItem:getSelected()
	return self._Selected
end
return BattleReportItem