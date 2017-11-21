-- for CCLuaEngine
function __G__TRACKBACK__(errorMessage)
  CCLuaLog("----------------------------------------")
  CCLuaLog("LUA ERROR: "..tostring(errorMessage).."\n")
  CCLuaLog(debug.traceback("", 2))
  CCLuaLog("----------------------------------------")
  if CFunctionToLua~=nil and CFunctionToLua.isDebug~=nil and CFunctionToLua:isDebug() then
    require("ShowErrorView")
    local callback=function() end
    local res=debug.traceback("", 2)
    res=string.sub(res,string.len("stack traceback:")+2,string.len(res))
    res=string.gsub(res,"%c","")
    res=tostring(errorMessage)..res
    local pop=ShowErrorView:new()
    pop:setMessage(res)
    CCDirector:sharedDirector():getRunningScene():addChild(pop)
  end
end

local function prepareEnterGame()
  require("GameInitConfig")
  require("framework.init")
  require("common.Consts")
  require("common.PbRegister")
  require("common.EventRegister")  
  require("common.ViewType")
  require("common.NetRegister")
  require("common.Clock")
  require("common.Object")
  require("framework.json")
  require("helper.UIHelper")
  require("model.GameData")
  require("controller.ControllerFactory")
  require("view.component.SceneWithTopBottom")
  require("manager.ResManager")
  require("manager.SoundManager")
  require("model.guide.Guide")
  require("manager.NewBirdGuideManager")
  require("model.battle.BattleConfig")
  require("model.battle.BattleFormation")

  AllConfig = require("config.AllConfig")
  local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()

  if targetPlatform == kTargetWindows then
    AllConfig.init("config","all_config_data.data","mapping_id_data.data")
  else
    AllConfig.init("config","all_config_data.zip","mapping_id_data.zip")
  end
  localization.init()
  GameData:Instance():init()
  print("Data Version:"..AllConfig.data_version)
  
  BattleConfig.IsUseSumaryFile = false
  local scene = SceneWithTopBottom.new()
  GameData:Instance():setCurrentScene(scene)
  display.replaceScene(scene, "fade", 0.6, display.COLOR_WHITE)
  if BATTLE_TEST_OPEN > 0 then
    local battleController = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
    battleController:enter(true,false)
  else
    local registController = ControllerFactory:Instance():create(ControllerType.REGIST_CONTROLLER)
    registController:enter()
  end
  
  net.loop()
end

local handle=nil

local function doLoadingScene()
    local loadingScene = CCScene:create()
    local loadingLayer = CCLayer:create()
    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
    local bg
    if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then
       bg = CCSprite:create("img/regist/loadingBG-ip5.png")
    else
       bg = CCSprite:create("img/regist/loadingBg.png")
    end
    bg:setPosition(visibleSize.width / 2, visibleSize.height/ 2)
    local loading=CCSprite:create("img/regist/game_loading_plz_wait.png")
    loading:setPosition(visibleSize.width/2,loading:getContentSize().height*3)
    loadingLayer:addChild(bg)
    loadingLayer:addChild(loading)
    loadingScene:addChild(loadingLayer)
    
    if CCDirector:sharedDirector():getRunningScene() then
      CCDirector:sharedDirector():replaceScene(loadingScene) 
    else
      CCDirector:sharedDirector():runWithScene(loadingScene) 
    end
    
    local function transition()
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
        prepareEnterGame() 
    end

    handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(transition, 0.1, false)
end


local function addAllSearchPaths()
    local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
  if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then
    local writeablePath = CCFileUtils:sharedFileUtils():getWritablePath()
    CCFileUtils:sharedFileUtils():addSearchPath(writeablePath .. "script/")
    CCFileUtils:sharedFileUtils():addSearchPath(writeablePath .. "img/")
    CCFileUtils:sharedFileUtils():addSearchPath(writeablePath .. "ccbi/")
    CCFileUtils:sharedFileUtils():addSearchPath(writeablePath .. "ccbi/skills/")
    CCFileUtils:sharedFileUtils():addSearchPath(writeablePath .. "fonts/")
  elseif kTargetAndroid==targetPlatform then
    local writeablePath = CCFileUtils:sharedFileUtils():getWritablePath()
    CCFileUtils:sharedFileUtils():addSearchPath(writeablePath .. "script/")
    CCFileUtils:sharedFileUtils():addSearchPath(writeablePath .. "img/")
    CCFileUtils:sharedFileUtils():addSearchPath(writeablePath .. "ccbi/")
    CCFileUtils:sharedFileUtils():addSearchPath(writeablePath .. "ccbi/skills/")
    CCFileUtils:sharedFileUtils():addSearchPath(writeablePath .. "fonts/")
  else
    local writeablePath = CCFileUtils:sharedFileUtils():getWritablePath()
    local path = writeablePath .. "sanguoRes/"
    CCFileUtils:sharedFileUtils():addSearchPath(path .. "script/")
    CCFileUtils:sharedFileUtils():addSearchPath(path .. "img/")
    CCFileUtils:sharedFileUtils():addSearchPath(path .. "ccbi/skills/")
     CCFileUtils:sharedFileUtils():addSearchPath(path .. "ccbi/")
    CCFileUtils:sharedFileUtils():addSearchPath(path .. "fonts/")
  end

  CCFileUtils:sharedFileUtils():addSearchPath("script/")
  CCFileUtils:sharedFileUtils():addSearchPath("img/")
  CCFileUtils:sharedFileUtils():addSearchPath("ccbi/")
  CCFileUtils:sharedFileUtils():addSearchPath("ccbi/skills/")
  CCFileUtils:sharedFileUtils():addSearchPath("fonts/")
end


local function main()
  collectgarbage("setpause", 100)
  collectgarbage("setstepmul", 5000)
  addAllSearchPaths()
  doLoadingScene()
end

xpcall(function()
  main()
end, __G__TRACKBACK__)
