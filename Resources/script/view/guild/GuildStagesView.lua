require("view.scenario.component.ScenarioMapView")
require("view.guild.GuildLogsView")
GuildStagesView = class("GuildStagesView",PopModule)
local touchIdx = -256
function GuildStagesView:ctor(chapter)
  local size = CCSizeMake(615,880)
  self._popSize = size
  GuildStagesView.super.ctor(self,size)
  self:setNodeEventEnabled(true)
  self:setAutoDisposeEnabled(false)
  
--  --for test
--  local currentChapter = Guild:Instance():getGuildStageInstance()
--  chapter = Scenario:Instance():getChapterById(1001)
  self._chapter = chapter
end

function GuildStagesView:onEnter()
  local bg = display.newSprite("img/pvp_rank_match/pvp_rank_match_bg.png")
  self:setMaskbackGround(bg)
  GuildStagesView.super.onEnter(self)
  local scrollView = CCScrollView:create()
  self.scrollView = scrollView
  self:getListContainer():addChild(self.scrollView)

  local size = self:getCanvasContentSize()
  local offsetX = 25
  local offsetY = 0
  size = CCSizeMake(size.width + offsetX,size.height + offsetY)
  self.scrollView:setViewSize(size)
  self.scrollView:setPositionX((display.width - 640)/2)
  self.scrollView:setDirection(kCCScrollViewDirectionHorizontal)
  self.scrollView:setClippingToBounds(true)
  self.scrollView:setBounceable(false)
  self:setScrollView(self.scrollView)
  self.scrollView:setPosition(ccp(-offsetX/2,-offsetY))
  --self.scrollView:setTouchPriority(touchIdx)
  
  self:setTitleWithSprite(display.newSprite("#guild_gonghuifuben.png"))
  
  self:goToChapter(self._chapter,false)
  
  local nor = display.newSprite("#guild_log_btn.png")
  local sel = display.newSprite("#guild_log_btn1.png")
  local dis = display.newSprite("#guild_log_btn1.png")
  
  local starAwardMenu,menuitem = UIHelper.ccMenuWithSprite(nor,sel,dis,function()
    local guildView = GuildLogsView.new()
    GameData:Instance():getCurrentScene():addChildView(guildView)
  end)
  
  self:addChild(starAwardMenu)
  starAwardMenu:setPositionX(display.cx - self._popSize.width/2 + 90)
  starAwardMenu:setPositionY(display.cy + self._popSize.height/2 - 105)
end

function GuildStagesView:goToChapter(chapter,isElite)
  if self.map ~= nil then
    self.map:removeFromParentAndCleanup(true)
    self.map = nil
  end
  
  local map = ScenarioMapView.new(self,chapter,isElite)
  self.map = map
  self.scrollView:setContainer(self.map)
  self.scrollView:setContentSize(self.map:getContentSize())
  
end

function GuildStagesView:onCloseHandler()
  GuildStagesView.super.onCloseHandler(self)
  local guildChaptersView = GuildChaptersView.new()
  GameData:Instance():getCurrentScene():replaceView(guildChaptersView,true)
end

function GuildStagesView:onExit()
  GuildStagesView.super.onExit(self)
end

function GuildStagesView:popCheckPoint(checkPoint,defultDifficulty)
  
  if ScenarioPopCheckPoint.isPoping == true then
    return
  end

  local pop = ScenarioPopCheckPoint.new(checkPoint,self)
  self:addChild(pop,2000)
  self:setPopView(pop)
  pop:setScale(0.5)
  pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
  pop:selectDifficultyType(defultDifficulty)
end

------
--  Getter & Setter for
--      GuildStagesView._PopView 
-----
function GuildStagesView:setPopView(PopView)
	self._PopView = PopView
end

function GuildStagesView:getPopView()
	return self._PopView
end


------
--  Getter & Setter for
--      GuildStagesView._ScrollView 
-----
function GuildStagesView:setScrollView(ScrollView)
  self._ScrollView = ScrollView
end

function GuildStagesView:getScrollView()
  return self._ScrollView
end

return GuildStagesView