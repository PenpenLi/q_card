
require("view.BaseView")


ActivityBossListItem = class("ActivityBossListItem", BaseView)

function ActivityBossListItem:ctor(boss)

  local pkg = ccbRegisterPkg.new(self)

  pkg:addFunc("joinInCallback",ActivityBossListItem.joinInCallback)
  pkg:addProperty("node_bg","CCNode")
  pkg:addProperty("node_card","CCNode")
  pkg:addProperty("node_nameLevel","CCNode")

  pkg:addProperty("label_preTime","CCLabelTTF")
  pkg:addProperty("label_leftTime","CCLabelTTF")

  pkg:addProperty("sprite_notOpen","CCSprite")
  pkg:addProperty("sprite_fighting","CCSprite")
  pkg:addProperty("sprite_death","CCSprite")
  pkg:addProperty("sprite_waiting","CCSprite")
  pkg:addProperty("bn_joinIn","CCControlButton")
  pkg:addProperty("bn_look","CCControlButton")
  pkg:addProperty("layer_gray","CCLayerColor")

  local layer,owner = ccbHelper.load("ActivityBossListItem.ccbi","ActivityBossListItemCCB","CCLayer",pkg)
  self:addChild(layer)

  self.boss = boss

  self:init(self.boss)
end


function ActivityBossListItem:init(boss)
  if boss == nil then 
    return
  end

  self:initOutLineLabel()

  --reg exit event
  local function onNodeEvent(event)
    if event == "enter" then

    elseif event == "exit" then
      -- echo("ActivityBossListItem: stop scheduler")
      if self.scheduler ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
        self.scheduler = nil
      end
    end
  end
  self:registerScriptHandler(onNodeEvent)


  local state = boss:getBossState(true)
  self:updateByState(state)

  --show boss bg
  local bg = nil 
  if state == BossState.KILLED then --图片变灰
    bg = GraySprite:create("img/activity/bg_boss.png")
  else 
    bg = CCSprite:create("img/activity/bg_boss.png")
  end 
  bg:setAnchorPoint(ccp(0,0))
  self.node_bg:addChild(bg)

  --show card image
  local picId = boss:getHeadPicId()
  local bossImg = nil 
  if state == BossState.KILLED then --图片变灰
    -- bossImg = GraySprite:createWithTexture(bossImg:getTexture())
    local picName = AllConfig.frames[picId].playstates
    local plistId = AllConfig.frames[picId].plist
    local plistPath = AllConfig.plist[plistId].path 
    echo("====== boss plist =", plistPath)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistPath) 
    bossImg = GraySprite:createWithSpriteFrameName(picName)
  else
    bossImg = _res(picId)
  end

  if bossImg ~= nil then
    -- bossImg:setScale(200/bossImg:getContentSize().height)
    bossImg:setAnchorPoint(ccp(0,0))
    self.node_card:addChild(bossImg)   
  end

  --show card name and level 
  local nameImg = nil 
  if state == BossState.KILLED then --图片变灰
    if toint(boss:getNameImgId()/1000000) == 3 then 
      resInfo = AllConfig.frames[boss:getNameImgId()]
      if resInfo ~= nil then
        local plistInfo = AllConfig.plist[resInfo.plist]
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistInfo.path)
        nameImg = GraySprite:createWithSpriteFrameName(resInfo.playstates)
      end
    end
  else
    nameImg = _res(boss:getNameImgId())
  end
  nameImg:setAnchorPoint(ccp(0,0))
  nameImg:setPositionY(-15)
  self.node_nameLevel:addChild(nameImg)
  local w1 = nameImg:getContentSize().width 


  -- local preLevel = nil 
  -- if state == BossState.KILLED then --图片变灰
  --   preLevel = GraySprite:createWithSpriteFrameName("act_level.png")
  -- else 
  --   preLevel = CCSprite:createWithSpriteFrameName("act_level.png")
  -- end    
  -- local w2 = preLevel:getContentSize().width 
  -- preLevel:setAnchorPoint(ccp(0,0))
  -- preLevel:setPositionX(w1)
  -- self.node_nameLevel:addChild(preLevel)

  -- local level = CCLabelBMFont:create(string.format("%d", boss:getLevel()), "client/widget/words/card_name/level_number.fnt")
  -- level:setAnchorPoint(ccp(0,0))
  -- level:setPosition(ccp(w1+w2+2, -3))
  -- self.node_nameLevel:addChild(level)
  -- if state == BossState.KILLED then --图片变灰
  --   level:setColor(ccc3(50,50,50))
  --   level:setOpacity(128)
  -- end

  --show left time count down
  local curDate = Clock:Instance():getCurServerTimeAsTable()
  self.leftTime = boss:getLeftTime(true, curDate)
  
  if self.leftTime > 86400 then --24*3600
    self.labelTime:setString(string.format("%d%s", math.ceil(self.leftTime/86400), _tr("day")))
  else
    local hour = math.floor(self.leftTime/3600)
    local min = math.floor((self.leftTime%3600)/60)
    local sec = math.floor(self.leftTime%60)
    self.labelTime:setString(string.format("%02d:%02d:%02d", hour,min,sec))
  end

  self:CountDownTime()
end

function ActivityBossListItem:setDelegate(delegate)
  self._delegate = delegate
end 

function ActivityBossListItem:getDelegate()
  return self._delegate
end 

function ActivityBossListItem:updateByState(state)
  self.layer_gray:setVisible(false)

  if state == BossState.CLOSE or state == BossState.BEFORE_OPEN then --已关闭/未开启
    self.sprite_notOpen:setVisible(true)
    self.sprite_death:setVisible(false)
    self.sprite_fighting:setVisible(false)
    self.sprite_waiting:setVisible(false)

    self.labelPreTime:setColor(ccc3(166,166,166))
    self.labelTime:setColor(ccc3(166,166,166))
    self.labelPreTime:setString(_tr("open_time")) 

    self.bn_look:setVisible(false)
    self.bn_joinIn:setVisible(true)
    self.bn_joinIn:setEnabled(false)

  elseif state == BossState.KILLED then --已击杀
    self.sprite_notOpen:setVisible(false)
    self.sprite_death:setVisible(true)
    self.sprite_fighting:setVisible(false)
    self.sprite_waiting:setVisible(false)
    
    self.labelPreTime:setString(_tr("close_time"))
    self.bn_look:setVisible(true)
    self.bn_joinIn:setVisible(false)    
    self.bn_look:setEnabled(true)

    self.layer_gray:setVisible(true)

  elseif state == BossState.FIGHTING then  --讨伐中
    self.sprite_notOpen:setVisible(false)
    self.sprite_death:setVisible(false)
    self.sprite_fighting:setVisible(true)
    self.sprite_waiting:setVisible(false)
    
    self.labelPreTime:setString(_tr("close_time"))
    self.bn_look:setVisible(false)
    self.bn_joinIn:setVisible(true)    
    self.bn_joinIn:setEnabled(true)
    
  elseif state == BossState.WAITING_FOR_OPEN then  --等待开启中
    self.sprite_notOpen:setVisible(false)
    self.sprite_death:setVisible(false)
    self.sprite_fighting:setVisible(false)
    self.sprite_waiting:setVisible(true)
    
    self.labelPreTime:setString(_tr("will_open"))
    self.labelTime:setString("")
    self.bn_look:setVisible(false)
    self.bn_joinIn:setVisible(true)     
    self.bn_joinIn:setEnabled(false)
  end
end

function ActivityBossListItem:joinInCallback()
  echo("joinInCallback")
  _playSnd(SFX_CLICK)
  
  Activity:instance():setTargetBoss(self.boss)
  self:getDelegate():enterViewByIndex(ActMenu.BOSS, true)
end


-- function ActivityBossListItem:setProgressPercent(percent)
--   local bgSize = self.sprite_gray:getContentSize()
--   local w = (bgSize.width-10)*percent/100
--   self.sprite_green:setContentSize(CCSizeMake(w, bgSize.height))
-- end


function ActivityBossListItem:setLevel(level)
  self.lable_level:setString(string.format("%d", level))
end

function ActivityBossListItem:CountDownTime()

  local function timerCallback(dt)

    self.leftTime = self.leftTime - 1
    if self.leftTime <= 0 then
      CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
      self.scheduler = nil
     
      if self.boss:getBossState() == BossState.BEFORE_OPEN then
        self.boss:setBossState(BossState.WAITING_FOR_OPEN) --wait fort opening...
        self:updateByState(BossState.WAITING_FOR_OPEN)

      elseif self.boss:getBossState() == BossState.WAITING_FOR_OPEN then 
        self.boss:setBossState(BossState.FIGHTING) --start fighting...
        self:updateByState(BossState.FIGHTING)        
      end
      -- self.labelTime:setString("00:00:00")
      self.labelTime:setVisible(false)
    else
      if self.leftTime > 86400 then --24*3600
        self.labelTime:setString(string.format("%d%s", math.ceil(self.leftTime/86400), _tr("day")))
      -- elseif self.boss:getBossState() == BossState.WAITING_FOR_OPEN then 
        -- self.labelTime:setString("")
      else 
        local hour = math.floor(self.leftTime/3600)
        local min = math.floor((self.leftTime%3600)/60)
        local sec = math.floor(self.leftTime%60)
        self.labelTime:setString(string.format("%02d:%02d:%02d", hour,min,sec))
      end
    end
  end

  
  if self.leftTime <= 0 then 
    return 
  end 

  -- if self.boss:getBossState() == BossState.WAITING_FOR_OPEN then 
  --   self.labelTime:setString("")
  -- else 
    if self.leftTime > 86400 then --24*3600
      self.labelTime:setString(string.format("%d%s", math.ceil(self.leftTime/86400), _tr("day")))
    else
      local hour = math.floor(self.leftTime/3600)
      local min = math.floor((self.leftTime%3600)/60)
      local sec = math.floor(self.leftTime%60)
      self.labelTime:setString(string.format("%02d:%02d:%02d", hour,min,sec))
    end 
  -- end

  self.scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timerCallback, 1.0, false)
end

function ActivityBossListItem:initOutLineLabel()
  self.label_preTime:setString("")
  self.labelPreTime = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = self.label_preTime:getFontName(),
                                            size = self.label_preTime:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(32, 143, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = self.label_info:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )

  self.labelPreTime:setPosition(ccp(self.label_preTime:getPosition()))
  self.label_preTime:getParent():addChild(self.labelPreTime)  

  self.label_leftTime:setString("")
  self.labelTime = ui.newTTFLabelWithOutline( {
                                            text = " ",
                                            font = self.label_leftTime:getFontName(),
                                            size = self.label_leftTime:getFontSize(),
                                            x = 0,
                                            y = 0,
                                            color = ccc3(32, 143, 0),
                                            align = ui.TEXT_ALIGN_LEFT,
                                            --valign = ui.TEXT_VALIGN_TOP,
                                            --dimensions = self.label_info:getContentSize(),
                                            outlineColor =ccc3(0,0,0),
                                            pixel = 2
                                            }
                                          )

  self.labelTime:setPosition(ccp(self.label_leftTime:getPosition()))
  self.label_leftTime:getParent():addChild(self.labelTime)
end