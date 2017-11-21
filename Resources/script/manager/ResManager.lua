require("view.component.SequenceAnim")
require("view.component.CcbiAnim")
local ResManager = {}

local ResConfig = nil

function ResManager.init(lang)
--  ResConfig = require("..config.res."..lang..".lua")

end

function ResManager.getResource(id,params)
--	print("id = ",id)
  local type = toint(id / 1000000)
  local resInfo = nil
  local offsetX = 0
  local offsetY = 0
  local duration = 0
  local isFlipY = false
  local res = nil
  if type == 1 then
    resInfo = AllConfig.sprite[id]
    res = CCSprite:create(resInfo.path)
    res.filePath = resInfo.path
  elseif type == 2 then
    local plistInfo = AllConfig.plist[id]
    if plistInfo ~= nil then
      CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistInfo.path)
    else
      printf("Can nout found res info by id:%d",id)
    end
  elseif type == 3 then
    resInfo = AllConfig.frames[id]
    if resInfo ~= nil then
      ResManager.getResource(resInfo.plist)
      res = CCSprite:createWithSpriteFrameName(resInfo.playstates)
      assert(res ~= nil,"can not CCSprite:createWithSpriteFrameName with "..resInfo.playstates)
      res.frameName = resInfo.playstates
    else
      printf("Can nout found res info by id:%d",id)
    end

  elseif type == 4 then
    resInfo = AllConfig.skeletonanims[id]
    if resInfo == nil then
      printf("Can nout found res info by id:%d",id)
    else
      for i=0, resInfo.size - 1 do
--      echo(resInfo.folder.."/"..resInfo.name.."/"..resInfo.name..i..".plist")
--      echo(resInfo.folder.."/"..resInfo.name.."/"..resInfo.name..i..".png")
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(resInfo.folder.."/"..resInfo.name.."/"..resInfo.name..i..".plist"
        ,resInfo.folder.."/"..resInfo.name.."/"..resInfo.name..i..".png")
      end
      res = display.newArmature(resInfo.folder,resInfo.name,resInfo.armature,resInfo.animate)
      offsetX = -resInfo.offsetx
      offsetY = resInfo.offsety
      duration = resInfo.duration/1000.0 + 0.06
      
    end

  elseif type == 5 then
    resInfo = AllConfig.sequenceanims[id]
    if resInfo == nil then
      printf("Can nout found res info by id:%d",id)
    else  
      for key, plist in pairs(resInfo.plists) do
        ResManager.getResource(plist)
      end
      
      res = SequenceAnim.new(resInfo)
      offsetX = -resInfo.offsetx
      offsetY = resInfo.offsety
      if resInfo.is_flip_y == 1 then
        isFlipY = true
      end
       
      duration = resInfo.duration * (resInfo.to - resInfo.from) / 1000.0 + 0.06
      
      if resInfo.scale ~= nil then
        if resInfo.scale > 0 then
          res:setScale(resInfo.scale/10000)
        end
      end
    end

  elseif type == 6 then
    resInfo = AllConfig.partucleanims[id]
    if resInfo == nil then
      printf("Can nout found res info by id:%d",id)
    else  
      local path = resInfo.folder.."/"..resInfo.name
      res = CCParticleSystemQuad:create(path)
      res:setAnchorPoint(ccp(0.5, 0.5))
      if resInfo.isloop == 1 then
        duration = resInfo.duration/1000.0 + 0.06
        res:setDuration(-1)
      else
        res:setAutoRemoveOnFinish(true)
      end
    end
  elseif type == 7 then
    resInfo = AllConfig.ccbianims[id]
    if resInfo == nil then
      printf("Can nout found res info by id:%d",id)
    else
      local path = resInfo.folder.."/"..resInfo.ccbi_name..".ccbi"
      local codeConnectionName = resInfo.ccbi_name
      res = CcbiAnim.new(path,codeConnectionName,"CCNode",params)
      duration = res:getDuration() + 0.06
      offsetX = -resInfo.offsetx
      offsetY = resInfo.offsety
      if resInfo.is_flip_y == 1 then
        isFlipY = true
      end
    end
  else
    echoError("Can not found handle res[%d] with type:%d",id,type)
  end
  
  return res,offsetX,offsetY,duration,isFlipY,params
end

_res = ResManager.getResource

return ResManager