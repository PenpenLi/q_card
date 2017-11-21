PlayerInfoView = class("PlayerInfoView",BaseView)

function PlayerInfoView:ctor()
  PlayerInfoView.super.ctor(self)
  self:setNodeEventEnabled(true)
    
	local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("headContainer","CCNode")
  pkg:addProperty("playerInfoContainer","CCNode")
  pkg:addProperty("playerHeadContainer","CCNode")
  pkg:addProperty("nodeRankIconContainer","CCNode")
  pkg:addProperty("lableMaxRankingName","CCLabelBMFont")
  pkg:addProperty("lableRankingName","CCLabelBMFont")
  pkg:addProperty("spriteVipIcon","CCSprite")
  
  
  pkg:addProperty("menuHead","CCMenu")
  pkg:addProperty("menuClose","CCMenu")
 
  pkg:addProperty("nodeScroll","CCNode")
  pkg:addFunc("goToSelectPicHandler",PlayerInfoView.goToSelectPicHandler)
  pkg:addFunc("makeSureHandler",PlayerInfoView.makeSureHandler)
  pkg:addFunc("canleHandler",PlayerInfoView.canleHandler)
  
  
  local lableNameArray = {"lableName","lableId","lableLevel","lableExp","lableNeedExp",
      "lableBattleScore","lableCardNum","lableEquipmentNum","lableVip","labelToken",
      "labelTockenTime","labelSpirit","labelSpiritTime", "lableWallBlood","labelYingzhaiBlood",
      "lableMoney","lableCoin","vipTimeLeft", 

      "lablePreLevel","lablePreExp","lablePreNeedExp", "labelPreYingzhaiBlood","labelPreToken",
      "labelPreSpirit","lablePreBattleScore","lablePreCardNum", "lablePreEquipNum","lablePreWallBlood",
      "labelPreTockenTime","labelPreSpiritTime","labelPreRankingName", "labelPreMaxRankName","labelNickName",
      "labelUnitName","labelChange"
    }

  local numLables = table.getn(lableNameArray)
  for i = 1,numLables do
     pkg:addProperty(lableNameArray[i],"CCLabelTTF")
  end
  
  local layer,owner = ccbHelper.load("PlayerInfoView.ccbi","PlayerInfoCCB","CCLayer",pkg)
  self:addChild(layer)
  
  self.lablePreLevel:setString(_tr("pop_level"))
  self.lablePreExp:setString(_tr("current exp"))
  self.lablePreNeedExp:setString(_tr("nextExp"))
  self.labelPreYingzhaiBlood:setString(_tr("pop_houseHp"))
  self.labelPreToken:setString(_tr("tokent"))
  self.labelPreSpirit:setString(_tr("energy"))
  self.lablePreBattleScore:setString(_tr("pop_score"))
  self.lablePreCardNum:setString(_tr("allCards"))
  self.lablePreEquipNum:setString(_tr("allEquipCards"))
  self.lablePreWallBlood:setString(_tr("pop_wallHp"))
  self.labelPreTockenTime:setString(_tr("restoreTime"))
  self.labelPreSpiritTime:setString(_tr("restoreTime"))
  self.labelPreRankingName:setString(_tr("pop_rank"))
  self.labelPreMaxRankName:setString(_tr("maxRankName"))
  self.labelNickName:setString(_tr("pop_nickName"))
  self.labelUnitName:setString(_tr("unitName"))
  self.labelChange:setString(_tr("touchToChange"))
  
  self.labelSpiritTime:setString("")
  self.labelTockenTime:setString("")
  self.lableBattleScore:setString("0")
  
  self.spriteVipIcon:setVisible(false)
  self.vipTimeLeft:setVisible(false)

  net.registMsgCallback(PbMsgId.ChangeAvatarResult,self,PlayerInfoView.onChangeAvatarResult)
  self.headContainer:setScale(0.7)

  local unitRoot = GameData:Instance():getCurrentPlayer():getAvatar()
  local picId = 0
  if unitRoot <= 1 then
     picId = 3012502
  else
     local cardConfigId = tonumber(unitRoot.."01")
     picId = AllConfig.unit[cardConfigId].unit_head_pic
  end
  local head = _res(picId)
  if head ~= nil then
     self.headContainer:addChild(head)
  end
--    --templete
--  local menu1 = {"tableBtnIcon/information-button-nor-wodexinxi.png","tableBtnIcon/information-button-sel-wodexinxi.png"}
--  local menuArray = {menu1}
  
  --self:setMenuArray(menuArray)
 
  
  
  
  self:updateWithPlayer(GameData:Instance():getCurrentPlayer())
 -- self:setTitleTextureName("inventory-image-xinxi.png")
  
--  local bottomBar = GameBottomBar.new()
--  self:addChild(bottomBar)
  
  self:refreshSpiritCountTime()
  self:refreshCommondCountTime()
  self:startTimeCountDown()
  
  local curTime = Clock:Instance():getCurServerUtcTime()
  self.vip_left = GameData:Instance():getCurrentPlayer():getVipEndTime() - curTime
  
   
  self:addTouchEventListener(handler(self,self.onTouch),false,-256,true)
  self:setTouchEnabled(true)
  
  self.menuHead:setTouchPriority(-256)
  self.menuClose:setTouchPriority(-256)
  
end

function PlayerInfoView:buildList()
   
  self.scrollView = CCScrollView:create()
  self.scrollView:setViewSize(self.nodeScroll:getContentSize())
  self.scrollView:setContentSize(self.nodeScroll:getContentSize())
  self.scrollView:setDirection(kCCScrollViewDirectionVertical)
  self.scrollView:setClippingToBounds(true)
  self.scrollView:setBounceable(true)
  self.nodeScroll:addChild(self.scrollView)
  self.scrollView:setTouchPriority(-256)
  
  self.headList = display.newNode()
  self.scrollView:setContainer(self.headList)

  local m_rootCardArray = GameData:Instance():getCurrentPlayer():getIllustratedInstance():getCollectionCardsOwend()
  
  local function sortTables(a, b)
     if a:getMaxGrade() == b:getMaxGrade() then
        return a:getConfigId() < b:getConfigId()
     end
     return a:getMaxGrade() > b:getMaxGrade()
  end
  
  local rootCardArray = {}
  for key, card in pairs(m_rootCardArray) do
    if card:getMaxGrade() > 3 and card:getIsExpCard() == false then
       table.insert(rootCardArray,card)
    end
  end
  table.sort(rootCardArray,sortTables)
  
  
  self._cardHeadArray = {}
  self._cardHeadConArray = {}
  
  local columnNumber = 4
  local lineNumber = 0
  
  local totalNumber = table.getn(rootCardArray)
 
  if totalNumber <= columnNumber then
    lineNumber = 1
  else
    lineNumber = math.ceil(totalNumber/columnNumber)
  end 
  
  local head = nil
  local idx = 0
  for i = lineNumber, 0,-1 do
     for j = 0, columnNumber-1 do
        if idx < totalNumber then
          local cardModel = rootCardArray[idx+1]
          if cardModel ~= nil then
              head = CardHeadView.new()
              head:setScale(0.8)
              head:setCard(cardModel)
              head:hideCardDetails()
              head:setLvVisible(false)
              head:setIsHideBoard(true)
              head.portraitNode:setScale(1.2)
              local headCon = display.newNode()
              headCon:addChild(head)
              headCon:setContentSize(head:getContentSize())
              headCon:setPositionX((head:getWidth())*j+head:getWidth()/2)
              headCon:setPositionY((head:getHeight())*i + head:getHeight()/2)
              self.headList:addChild(headCon)
              idx = idx + 1
              table.insert(self._cardHeadArray,head)
              table.insert(self._cardHeadConArray,headCon)
          end
        end
     end
  end
  
  if head ~= nil then
      self.headList:setContentSize(CCSizeMake((head:getWidth())*(columnNumber-1)+head:getWidth(),(head:getHeight())*lineNumber+head:getHeight()))
      --self.headList:setPositionY(-self.headList:getContentSize().height+self.nodeScroll:getContentSize().height)
      --self.headList:setPositionY(self.nodeScroll:getContentSize().height - self.headList:getContentSize().height)
  end
  self.playerHeadContainer:setVisible(false)
  
  self.labelSpiritTime:setString("")
  self.labelTockenTime:setString("")
  self.lableBattleScore:setString("")
  
  self.scrollView:setContentSize(self.headList:getContentSize())
end

function PlayerInfoView:canleHandler()
  self:getDelegate():closePlayerInfoHandler()
end

function PlayerInfoView:refreshSpiritCountTime()
    local spirit = GameData:Instance():getCurrentPlayer():getSpirit()
    local maxSpirit = GameData:Instance():getCurrentPlayer():getMaxSpirit() --AllConfig.characterinitdata[4].data
    self.labelSpirit:setString(spirit.."/"..maxSpirit)
    local curTime = Clock:Instance():getCurServerUtcTime()
    while curTime > GameData:Instance():getCurrentPlayer():getNextSpiritRefreshTime() do
       GameData:Instance():getCurrentPlayer():setNextSpiritRefreshTime(GameData:Instance():getCurrentPlayer():getNextSpiritRefreshTime() + AllConfig.characterinitdata[5].data )
    end
    self.leftSpiritTime = GameData:Instance():getCurrentPlayer():getNextSpiritRefreshTime() - curTime
end

function PlayerInfoView:refreshCommondCountTime()
  local commond = GameData:Instance():getCurrentPlayer():getToken()
  local maxCommond =GameData:Instance():getCurrentPlayer():getMaxToken() -- AllConfig.characterinitdata[15].data
  self.labelToken:setString(commond.."/"..maxCommond)
  
  local curTime = Clock:Instance():getCurServerUtcTime()
  while curTime > GameData:Instance():getCurrentPlayer():getNextCommondRefreshTime() do
    GameData:Instance():getCurrentPlayer():setNextCommondRefreshTime(GameData:Instance():getCurrentPlayer():getNextCommondRefreshTime() + AllConfig.characterinitdata[16].data )
  end
  self.leftCommondTime = GameData:Instance():getCurrentPlayer():getNextCommondRefreshTime() - curTime
end

function PlayerInfoView:startTimeCountDown()
 

  local enabledCountDown = true
  local updateTimeShow = function()
      if enabledCountDown == false then
        return 
      end
      
      self.vip_left = self.vip_left - 1
      if self.vip_left < 0 then
          self.vipTimeLeft:setString(_tr("unOpen"))
      else
          if self.vip_left > 86400 then --24*3600
            self.vipTimeLeft:setString(_tr("left time").._tr("day %{count}", {count=math.ceil(self.vip_left/86400)}))
          else
            local hour = math.floor(self.vip_left/3600)
            local min = math.floor((self.vip_left%3600)/60)
            local sec = math.floor(self.vip_left%60)
            self.vipTimeLeft:setString(_tr("left time")..string.format("%02d:%02d:%02d", hour,min,sec))
          end
      end
      
--      echo("leftSpiritTime:",self.leftSpiritTime)
--      echo("labelTockenTime:",self.leftCommondTime)
      self.leftSpiritTime = self.leftSpiritTime - 1
     
      if self.leftSpiritTime < 0 then
         --enabledCountDown = false
         self.labelSpiritTime:setString("00:00:00")
         self:refreshSpiritCountTime()
         self:getDelegate():update()
         
      else 
          if self.leftSpiritTime > 86400 then --24*3600
            self.labelSpiritTime:setString(_tr("day %{count}", {count=math.ceil(self.leftSpiritTime/86400)}))
          else
            local hour = math.floor(self.leftSpiritTime/3600)
            local min = math.floor((self.leftSpiritTime%3600)/60)
            local sec = math.floor(self.leftSpiritTime%60)
            self.labelSpiritTime:setString(string.format("%02d:%02d:%02d", hour,min,sec))
          end
          
      end
      
      local spirit = GameData:Instance():getCurrentPlayer():getSpirit()
      local maxSpirit = GameData:Instance():getCurrentPlayer():getMaxSpirit() --AllConfig.characterinitdata[4].data
      if spirit >= maxSpirit then
         self.labelSpiritTime:setString(_tr("full"))
      end
      
       self.leftCommondTime = self.leftCommondTime - 1
       if self.leftCommondTime < 0 then
         --enabledCountDown = false
         self.labelTockenTime:setString("00:00:00")
         self:refreshCommondCountTime()
         self:getDelegate():update()
      else 
          if self.leftCommondTime > 86400 then --24*3600
            self.labelTockenTime:setString(_tr("day %{count}", {count=math.ceil(self.leftCommondTime/86400)}))
          else
            local hour = math.floor(self.leftCommondTime/3600)
            local min = math.floor((self.leftCommondTime%3600)/60)
            local sec = math.floor(self.leftCommondTime%60)
            self.labelTockenTime:setString(string.format("%02d:%02d:%02d", hour,min,sec))
          end
      end
      local commond = GameData:Instance():getCurrentPlayer():getToken()
      local maxCommond = GameData:Instance():getCurrentPlayer():getMaxToken() --AllConfig.characterinitdata[15].data
      
      if commond >= maxCommond then
         self.labelTockenTime:setString(_tr("full"))
      end
  end
  self:schedule(updateTimeShow,1/1)
end

function PlayerInfoView:onTouch(event, x,y)
  if event == "began" then
    echo(event,x,y)
    self._startX = x
    self._startY = y
    --return false
    return true
  elseif event == "ended" then
    echo("ended:",event,x,y)
    --print("self:getTouchedNode({self.nodeScroll},x,y) ~= nil",self:getTouchedNode({self.nodeScroll},x- self.nodeScroll:getContentSize().width/2,y - self.nodeScroll:getContentSize().height/2) ~= nil)
    if self.playerHeadContainer:isVisible() == true and self:getTouchedNode({self.nodeScroll},x- self.nodeScroll:getContentSize().width/2,y - self.nodeScroll:getContentSize().height/2) ~= nil  then
        if math.abs(x - self._startX) < 10 and math.abs(y - self._startY) < 10 then
            self._selectedCard = self:getTouchedNode(self._cardHeadConArray,x,y) --touchat an cardView
            if self._selectedCard ~= nil then
              local idx = 1
              for key, cardView in pairs(self._cardHeadConArray) do
                if self._selectedCard == cardView then
                   self._cardHeadArray[idx]:setSelected(true)
                   self._nowSelectedCard = self._cardHeadArray[idx]:getCard()
                   self:makeSureHandler()
                else
                   self._cardHeadArray[idx]:setSelected(false)
                end
                idx = idx + 1
              end
            end
         end
     end
  end
end

function PlayerInfoView:getTouchedNode(toTouchArray,x,y)
  local isGetedNode = false
  local touchedNode = nil
  for i = 1, table.getn(toTouchArray) do
    local contentSize = toTouchArray[i]:getContentSize()
    local position = toTouchArray[i]:getParent():convertToNodeSpace(ccp(x + contentSize.width/2,y + contentSize.height/2 ))  --获取 x,y 相对于toTouchArray[i]:getParent()坐标系的坐标点
    isGetedNode = toTouchArray[i]:boundingBox():containsPoint(position)
    if isGetedNode == true then
      touchedNode = toTouchArray[i]
      break
    end
  end
  return touchedNode
end

function PlayerInfoView:updateWithPlayer(player)
  --self.lableId:setString(player:getId().."")
  self.lableId:setString(player:pidToCode(player:getId()))
  
  if AllConfig.charlevel[player:getLevel()+1] ~= nil then
     local needExp = AllConfig.charlevel[player:getLevel()+1].totalexp - player:getExperience()
     self.lableNeedExp:setString(needExp.."")
  else
     self.lableNeedExp:setString("--")
  end
  self.lableName:setString(player:getName())
  self.lableLevel:setString(player:getLevel().."")
  self.lableExp:setString(player:getExperience().."")
  self.lableWallBlood:setString(AllConfig.charlevel[player:getLevel()].gate_hp.."")
  self.labelYingzhaiBlood:setString(AllConfig.charlevel[player:getLevel()].gate2_hp.."")
  self.lableCoin:setString(player:getCoin().."")
  self.lableMoney:setString(player:getMoney().."")
  if GameData:Instance():getExpeditionInstance() ~= nil then
     if GameData:Instance():getExpeditionInstance():getSelfPvpBaseData() ~= nil then
        if GameData:Instance():getExpeditionInstance():getSelfPvpBaseData():getScore() ~= nil then
            self.lableBattleScore:setString(GameData:Instance():getExpeditionInstance():getSelfPvpBaseData():getScore().."")
        end
     end
  end
  
  if Achievement:instance():getOfficialName() ~= nil then
     self.lableRankingName:setString(Achievement:instance():getOfficialName())
  end
  
  local rank = 0
  if GameData:Instance():getExpeditionInstance() ~= nil and GameData:Instance():getExpeditionInstance():getSelfPvpBaseData() ~= nil then
      local maxScore = GameData:Instance():getExpeditionInstance():getSelfPvpBaseData():getMaxScore() --300
      --for rank, rankData in pairs(AllConfig.rank) do
      for i = 1, table.getn(AllConfig.rank) do
      	  if maxScore <= AllConfig.rank[i].max_point then
      	     rank = i
      	     break
      	  end
      end
      
      --self.nodeRankIconContainer:removeAllChildrenWithCleanup(true)
      if rank < 1 then
        -- self.nodeRankIconContainer:removeAllChildrenWithCleanup(true)
         self.lableMaxRankingName:setString(_tr("none2"))
      else
--          local iconSpr = _res(AllConfig.rank[rank].rank_pic)
--          if iconSpr ~= nil then
--             iconSpr:setScale(0.8)
--             self.nodeRankIconContainer:addChild(iconSpr)
--          end
          
--          local iconNum = _res(AllConfig.rank[rank].rank_number)
--          if iconNum ~= nil then
--             --iconNum:setScale(0.8)
--             self.nodeRankIconContainer:addChild(iconNum)
--          end
          
          self.lableMaxRankingName:setString(AllConfig.rank[rank].sub_rank_name)
      end
    
  else
      --self.nodeRankIconContainer:removeAllChildrenWithCleanup(true)
      self.lableMaxRankingName:setString(_tr("none2"))
  end
  
  
  self.lableCardNum:setString(table.getn(GameData:Instance():getCurrentPackage():getAllCards()).."")
  self.lableEquipmentNum:setString(table.getn(GameData:Instance():getCurrentPackage():getAllEquipments()).."")

  self:rejustLabelPos()
end

function PlayerInfoView:goToSelectPicHandler()
  if self.scrollView == nil then
    self:buildList()
  end
   -- scroll to top
  self.scrollView:setContentOffset(ccp(0, self.nodeScroll:getContentSize().height - self.headList:getContentSize().height))

  self.playerInfoContainer:setVisible(false)
  self.playerHeadContainer:setVisible(true)
  printf("goToSelectPicHandler")
end

--function PlayerInfoView:onBackHandler()
--  if self.playerInfoContainer:isVisible() == false then
--    self.playerInfoContainer:setVisible(true)
--    self.playerHeadContainer:setVisible(false)
--  else
--    self:getParent():getTopBlock():closePlayerInfoHandler()
--  end
--end

function PlayerInfoView:makeSureHandler()
  self.playerInfoContainer:setVisible(true)
  self.playerHeadContainer:setVisible(false)
  if self._nowSelectedCard ~= nil then
     local uintRootId = self._nowSelectedCard:getUnitRoot()
     local data = PbRegist.pack(PbMsgId.ChangeAvatar,{avatar_id = uintRootId})
     net.sendMessage(PbMsgId.ChangeAvatar,data)
  end
end

function PlayerInfoView:onChangeAvatarResult(action,msgId,msg)
--     enum traits { value = 3780;}
--  enum State {
--    Ok = 0;
--    NoSuchAvatarOrNoChange = 1;
--  }
--  required State state = 1;
    if msg.state == "Ok" then
       self.headContainer:removeAllChildrenWithCleanup(true)
       local picId = self._nowSelectedCard:getUnitHeadPic()
       local head = _res(picId) 
       self.headContainer:addChild(head)
       GameData:Instance():getCurrentPlayer():setAvatar(self._nowSelectedCard:getUnitRoot())
       self:getDelegate():setAvatar(self._nowSelectedCard:getUnitRoot())
       self._nowSelectedCard = nil
    elseif msg.state == "NoSuchAvatarOrNoChange" then
      echo(msg.state)
    else
      echo("changeAvatar Error")
    end
   
end

--    if msg.state == "Ok" then
--       self.headContainer:removeAllChildrenWithCleanup(true)
--       local cardConfigId = tonumber(msg.avatar_id.."01")
--       local picId = AllConfig.unit[cardConfigId].unit_head_pic
--       local head = _res(picId) 
--       self.headContainer:addChild(head)
--       GameData:Instance():getCurrentPlayer():setAvatar(msg.avatar_id)
--       self:getDelegate():setAvatar(msg.avatar_id)
--    elseif msg.state == "NoSuchAvatarOrNoChange" then
--      echo(msg.state)
--    else
--      echo("changeAvatar Error")
--    end

function PlayerInfoView:onExit()
    net.unregistAllCallback(self)
end

function PlayerInfoView:rejustLabelPos()
  local key = {self.labelNickName, self.labelUnitName, self.lablePreLevel, self.lablePreExp, 
               self.lablePreNeedExp, self.labelPreYingzhaiBlood, self.labelPreToken,
               self.labelPreSpirit, self.labelPreRankingName, self.lablePreBattleScore, 
               self.lablePreCardNum, self.lablePreEquipNum, self.lablePreWallBlood, 
               self.labelPreTockenTime, self.labelPreSpiritTime, self.labelPreMaxRankName
              }

  local val = {self.lableName, self.lableId, self.lableLevel, self.lableExp,
               self.lableNeedExp, self.labelYingzhaiBlood, self.labelToken,
               self.labelSpirit, self.lableRankingName, self.lableBattleScore, 
               self.lableCardNum, self.lableEquipmentNum, self.lableWallBlood, 
               self.labelTockenTime, self.labelSpiritTime, self.lableMaxRankingName
               }

  for i=1, #key do 
    local strW = key[i]:getContentSize().width 
    local x, y = key[i]:getPosition()
    -- local pos = key[i]:getParent():convertToWorldSpace(ccp(x, y))
    val[i]:setPosition(ccp(x+strW, y))
  end
end 

return PlayerInfoView