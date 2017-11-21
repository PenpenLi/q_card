BattleResultAnimation = class("BattleResultAnimation",BaseView)

function BattleResultAnimation:ctor(result_lv,fightType)
  BattleResultAnimation.super.ctor(self)


  	--assert( ControllerFactory:Instance():getCurrentControllerType() ==  ControllerType.BATTLE_CONTROLLER )
	if( fightType == "PVP_REAL_TIME" ) then
		local battleController = ControllerFactory:Instance():getCurController()
		local battleView = battleController:getBattleView()
		assert(battleView)
		battleView:setIsFinish(true)
		battleView:showButtons(false);
	end

--    WIN_LEVEL_1 = 2;
--    WIN_LEVEL_2 = 3;
--    WIN_LEVEL_3 = 4;
--    LOSE_LEVEL_1 = 5;
--    LOSE_LEVEL_2 = 6;
--    LOSE_LEVEL_3 = 7;
   local level = 2
   if fightType == "PVE_NORMAL" 
   or fightType == "PVE_ACTIVITY" 
   then
      self._isPVEFight = true
   else
      self._isPVEFight = false
   end
   
   local isWin = false
   if result_lv == "WIN_LEVEL_1" then
      isWin = true
      if self._isPVEFight == true then
         isWin = false
      end
   elseif result_lv == "WIN_LEVEL_2" then
      isWin = true
   elseif result_lv == "WIN_LEVEL_3" then
      isWin = true
      if self._isPVEFight == true then
         isWin = false
      end
   elseif result_lv == "LOSE_LEVEL_1" then
      isWin = false
   elseif result_lv == "LOSE_LEVEL_2" then
      isWin = false
   elseif result_lv == "LOSE_LEVEL_3" then
      isWin = false
   else
   end
   
   if isWin == false then
      local pkg = ccbRegisterPkg.new(self)
      pkg:addProperty("mAnimationManager","CCBAnimationManager")
      pkg:addProperty("level1","CCSprite")
      pkg:addProperty("level2","CCSprite")
      pkg:addProperty("level3","CCSprite")
      pkg:addFunc("play_end",BattleResultAnimation.animPlayEndHandler)
      local layer,owner = ccbHelper.load("anim_Lose.ccbi","anim_Lose","CCLayer",pkg)
      self:addChild(layer)
      
      self.level1:setVisible(false)
      self.level2:setVisible(false)
      self.level3:setVisible(false)
      
      if result_lv == "LOSE_LEVEL_1" then
        self.level1:setVisible(true)
      elseif result_lv == "LOSE_LEVEL_2" then
        self.level2:setVisible(true)
      elseif result_lv == "LOSE_LEVEL_3" then
        self.level3:setVisible(true)
      elseif result_lv == "WIN_LEVEL_1" then 
        self.level2:setVisible(true)
      elseif result_lv == "WIN_LEVEL_3" then
        self.level2:setVisible(true)
      end
      _playSnd(BGM_BATTLE_LOST)
   else
      local pkg = ccbRegisterPkg.new(self)
      pkg:addProperty("mAnimationManager","CCBAnimationManager")
      pkg:addProperty("level1","CCSprite")
      pkg:addProperty("level2","CCSprite")
      pkg:addProperty("level3","CCSprite")
      pkg:addProperty("sprite_win_star","CCSprite")
      pkg:addFunc("play_end",BattleResultAnimation.animPlayEndHandler)
      local layer,owner = ccbHelper.load("anim_Win.ccbi","anim_Win","CCLayer",pkg)
      self:addChild(layer)
      
      local hideStars = function()
        self.level1:setVisible(false)
        self.level2:setVisible(false)
        self.level3:setVisible(false)
        self.sprite_win_star:setVisible(false)
      end
      hideStars()
      
      
      if result_lv == "WIN_LEVEL_1" then
        if self._isPVEFight == true then
           isWin = false
        else
           self.level1:setVisible(true)
        end
      elseif result_lv == "WIN_LEVEL_2" then
        self.level2:setVisible(true)
        if self._isPVEFight == true then
        else
           self.sprite_win_star:setVisible(true)
        end
      elseif result_lv == "WIN_LEVEL_3" then
        if self._isPVEFight == true then
           isWin = false
        else
           self.level3:setVisible(true)
        end
      end
      
      if fightType == "PVE_GUILD" then
         hideStars()
         self.level2:setVisible(true)
      end
       
      _playSnd(BGM_BATTLE_WIN)
   end
   
end

function BattleResultAnimation:animPlayEndHandler()
  self:getDelegate():onTouch("ended",100,100)
end

return BattleResultAnimation