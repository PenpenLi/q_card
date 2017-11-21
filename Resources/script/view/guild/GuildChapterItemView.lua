require("view.guild.GuildStagesView")
GuildChapterItemView = class("GuildChapterItemView",BaseView)
function GuildChapterItemView:ctor(chapterData)
  self._chapterData = chapterData
  self:setNodeEventEnabled(true)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("nodeIcon","CCNode")
  pkg:addProperty("nodeProgressBar","CCNode")
  pkg:addProperty("nodeOpenCost","CCNode")
  pkg:addProperty("labelChapterName","CCLabelTTF")
  pkg:addProperty("labelOpenCost","CCLabelTTF")
  pkg:addProperty("labelPreOpenCost","CCLabelTTF")
  pkg:addProperty("labelOpenGuildLevel","CCLabelTTF")
  
  pkg:addProperty("menuParent","CCMenu")
  pkg:addProperty("btnEnterChapter","CCMenuItemImage")
  pkg:addProperty("btnOpenChapter","CCMenuItemImage")
  
  pkg:addFunc("enterChapterHandler",GuildChapterItemView.enterChapterHandler)
  pkg:addFunc("openChapterHandler",GuildChapterItemView.openChapterHandler)
  
  local node,owner = ccbHelper.load("guild_chapter_item.ccbi","guild_chapter_item","CCNode",pkg)
  self:addChild(node)
  
  local progressBar_bg = display.newSprite("#guild_jindutiao_bj.png")
  local progressBar_green = display.newSprite("#guild_jindutiao_bj_1.png")
  local progressBar = ProgressBarView.new(progressBar_bg, progressBar_green)
  progressBar:setPositionX(100)
  progressBar:setPercent(0, 1)
  self.nodeProgressBar:addChild(progressBar)
  self._progressBar = progressBar
  
  local label = CCLabelBMFont:create("", "client/widget/words/card_name/number_skillup.fnt")
  --local labelSize = tolua.cast(label:getContentSize(),"CCSize")  
  progressBar:addChild(label)
  label:setPosition(ccp(9,-2))
  self._labelProgress = label
  
  --self.menuParent:setTouchPriority(-256)
  self.labelChapterName:setString(chapterData:getName())
  
  --self.labelPreOpenCost:setString("")
  self.labelOpenCost:setString("")
  
  self:updateView()
end

function GuildChapterItemView:updateView(refreshList)
  if refreshList == true then
    self:getDelegate():reloadData()
    return
  end
  
  self:stopAllActions()
  
  local chapterInfo = Guild:Instance():getGuildStageInstance()
  local chapter = chapterInfo:getChapter()
  
  self.nodeIcon:removeAllChildrenWithCleanup(true)
  self.nodeOpenCost:setVisible(true)
  
  local resId = self._chapterData:getChapterResId()
  if resId > 0 then
    local icon = _res(resId)
    if icon ~= nil then
      self.nodeIcon:addChild(icon)
      icon:setScale(0.75)
    end
  end
  
  local curTime = Clock:Instance():getCurServerUtcTime()
  local chaperCloseTime = chapterInfo:getCloseTime() - curTime
  
  self._labelProgress:setString(chapterInfo:getProgress().."%")
  self._progressBar:setVisible((chapter ~= nil and chaperCloseTime > 0))
  
  local chapterId = self._chapterData:getId()
  self.labelOpenCost:setString(AllConfig.guild_instance[chapterId].money.."")
  self.labelOpenGuildLevel:setString("所需公会等级:"..AllConfig.guild_instance[chapterId].open_lv)
  
  self.btnOpenChapter:setVisible(false)
  self.btnEnterChapter:setVisible(false)
  local selfMember = Guild:Instance():getSelfGuildBase():getMemberById(GameData:Instance():getCurrentPlayer():getId())
  
  
  
  if chapter ~= nil and chaperCloseTime > 0 then
    --printf("have chapter")
    
    if self._chapterData:getId() == chapter:getId() then
      local curTime = Clock:Instance():getCurServerUtcTime()
      self._chaperCloseTime = chapterInfo:getCloseTime() - curTime
      self.labelOpenGuildLevel:setString("")
      self:startTimeCountDown()
      self.nodeOpenCost:setVisible(false)
    end
    
    self._progressBar:setVisible(self._chapterData:getId() == chapter:getId())
    if self._chapterData:getId() == chapter:getId() then
        self.btnOpenChapter:setVisible(false)
        self.btnEnterChapter:setVisible(true)
        self.btnEnterChapter:setEnabled(true)
    else
      if Guild:Instance():getIsManagerByMember(selfMember) == true then
        self.btnOpenChapter:setVisible(true)
        self.btnOpenChapter:setEnabled(false)
        self.btnEnterChapter:setVisible(false)
      end
    end
  else
    --printf("not chapter")
    self.btnEnterChapter:setEnabled(false)
    --assert(selfMember ~= nil,"have not self member info")
    if selfMember ~= nil then
       --printf("have member")
       --printf("selfMember:getJob():"..selfMember:getJob())
       if Guild:Instance():getIsManagerByMember(selfMember) == true
       then
         --printf("is manager")
         self.btnOpenChapter:setVisible(true)
         self.btnEnterChapter:setVisible(false)
       else
          --printf("not manager")
         self.btnOpenChapter:setVisible(false)
         self.btnEnterChapter:setVisible(true)
       end
    else
      --printf("have no member")
      self.btnEnterChapter:setEnabled(true)
      self.btnEnterChapter:setVisible(true)
    end
  end
  
end

function GuildChapterItemView:enterChapterHandler()
  local guildStagesView = GuildStagesView.new(self._chapterData)
  guildStagesView:setDelegate(ControllerFactory:Instance():getCurController())
  GameData:Instance():getCurrentScene():replaceView(guildStagesView,true)
end

function GuildChapterItemView:openChapterHandler()
  
  local chapterId = self._chapterData:getId()
  local needGuildMoney = AllConfig.guild_instance[chapterId].money
  local haveGuildMoney = Guild:Instance():getSelfGuildBase():getMoney()
  if needGuildMoney > haveGuildMoney then
    Guild:Instance():toastError("GUILD_MONEY_LIMIT")
    return
  end
  
  local needLevel = AllConfig.guild_instance[chapterId].open_lv
  local currentLevel = Guild:Instance():getSelfGuildBase():getLevel()
  if needLevel > currentLevel then
    Guild:Instance():toastError("GUILD_LEVEL_LIMIT")
    return
  end
  
  local pop = PopupView:createTextPopup(_tr("make_sure_open_guild_chapter"), function() 
        Guild:Instance():reqGuildOpenInstanceC2S(self._chapterData:getId(),self)
  end)
  GameData:Instance():getCurrentScene():addChildView(pop)
end

function GuildChapterItemView:startTimeCountDown()
  local enabledCountDown = true
  local updateTimeShow = function()
    if enabledCountDown == false then
      return
    end
    
    self._chaperCloseTime = self._chaperCloseTime - 1
    if self._chaperCloseTime < 0 then
        self.labelOpenGuildLevel:setString(_tr("unOpen"))
        self:stopAllActions()
        self:updateView()
    else
        if self._chaperCloseTime > 86400 then --24*3600
          self.labelOpenGuildLevel:setString(_tr("left time").._tr("day %{count}", {count=math.ceil(self._chaperCloseTime/86400)}))
        else
          local hour = math.floor(self._chaperCloseTime/3600)
          local min = math.floor((self._chaperCloseTime%3600)/60)
          local sec = math.floor(self._chaperCloseTime%60)
          self.labelOpenGuildLevel:setString(_tr("left time")..string.format("%02d:%02d:%02d", hour,min,sec))
        end
    end
  end
  self:schedule(updateTimeShow,1/1)
end

return GuildChapterItemView