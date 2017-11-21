require("GameInitConfig")
SoundManager = {}
local engine = SimpleAudioEngine:sharedEngine()

local defaultEffectsVolume = 1.0
local defaultMusicVolume = 0.35


function SoundManager.init()

  SoundManager._musicOn = true
  if CCUserDefault:sharedUserDefault():getStringForKey("music_on") == "true" or CCUserDefault:sharedUserDefault():getStringForKey("music_on") == nil then
     SoundManager._musicOn = true
  elseif CCUserDefault:sharedUserDefault():getStringForKey("music_on") == "false" then
     SoundManager._musicOn = false
  end
  
  SoundManager._sndOn = true
  if CCUserDefault:sharedUserDefault():getStringForKey("sound_on") == "true" or CCUserDefault:sharedUserDefault():getStringForKey("sound_on") == nil then
     SoundManager._sndOn = true
  elseif CCUserDefault:sharedUserDefault():getStringForKey("sound_on") == "false" then
     SoundManager._sndOn = false
  end
  
  engine:preloadBackgroundMusic(BGM_LOGIN)
  engine:preloadBackgroundMusic(BGM_MAIN)
  engine:preloadBackgroundMusic(BGM_BATTLE_FAST)
  engine:preloadBackgroundMusic(BGM_BATTLE_SLOW)
  engine:preloadBackgroundMusic(BGM_BATTLE_WIN)
  engine:preloadBackgroundMusic(BGM_BATTLE_LOST)
  
  engine:preloadEffect(SFX_CLICK)
  engine:preloadEffect(SFX_CLICK_BACK)
  engine:preloadEffect(SFX_SWAP_SCREEN)
  engine:preloadEffect(SFX_STAR_FALL)
  engine:preloadEffect(SFX_ITEM_ACQUIRED)
  engine:preloadEffect(SFX_MELEE_ATTACK)
  engine:preloadEffect(SFX_RANGED_ATTACK)
  engine:preloadEffect(SFX_MAGE_ATTACK)
  engine:preloadEffect(SFX_CLERIC_ATTACK)
  engine:preloadEffect(SFX_WIZARD_ATTACK)
  engine:preloadEffect(SFX_CATAPULT_ATTACK)
  engine:preloadEffect(SFX_MARTIAL_ARTIST_ATTACK)
  engine:preloadEffect(SFX_DANCER_ATTACK)
  engine:preloadEffect(SFX_BLOCK)
  engine:preloadEffect(SFX_UNIT_DEAD)
  engine:preloadEffect(SFX_SWORDMAN_MOVE)
  engine:preloadEffect(SFX_HORSEMAN_MOVE)
  engine:preloadEffect(SFX_SKILL_CAST)
  engine:preloadEffect(SFX_SKILL_FIRE)
  engine:preloadEffect(SFX_SKILL_WATER)
  engine:preloadEffect(SFX_SKILL_LIGHTING)
  engine:preloadEffect(SFX_SKILL_POISON)
  engine:preloadEffect(SFX_SKILL_HPRESTORE)
  engine:preloadEffect(SFX_SKILL_CHAIN)
  engine:preloadEffect(SFX_SKILL_SHIELD)
  engine:preloadEffect(SFX_SKILL_HIT)
  engine:preloadEffect(SFX_CASTLE_HURT)

  
  SoundManager._curBgm = ""
  
  --set default volume
  engine:setEffectsVolume(defaultEffectsVolume)
  engine:setBackgroundMusicVolume(defaultMusicVolume)

end

function SoundManager.toggleMusic()
  if SoundManager._musicOn == false then
    SoundManager._musicOn = true
  else
    SoundManager._musicOn = false
  end
  SoundManager._update()
  return SoundManager._musicOn
end

function SoundManager.toggleSnd()
  if SoundManager._sndOn == false then
    SoundManager._sndOn = true
  else
    SoundManager._sndOn = false
  end
  SoundManager._update()
  return SoundManager._sndOn  
end

function SoundManager._update()
  if SoundManager._musicOn == true then
    engine:resumeBackgroundMusic()
    if engine:isBackgroundMusicPlaying() == false then
      engine:playBackgroundMusic(SoundManager._curBgm,true)
      engine:setBackgroundMusicVolume(defaultMusicVolume)
    end
    
  else
    engine:stopBackgroundMusic(false)
  end
  
  print("getBackgroundMusicVolume：",engine:getBackgroundMusicVolume())
  print("getEffectsVolume：",engine:getEffectsVolume())
end

function SoundManager.playBgm(path)
  if SoundManager._curBgm ~= path then
    if SoundManager._musicOn == true then
      engine:playBackgroundMusic(path,true)
      engine:setBackgroundMusicVolume(defaultMusicVolume)
    end  
  end
  
  if SoundManager._musicOn == true and engine:isBackgroundMusicPlaying() == false then
     engine:playBackgroundMusic(path,true)
     engine:setBackgroundMusicVolume(defaultMusicVolume)
  end 
  
  SoundManager._curBgm = path


end

function SoundManager.playEffect(path)
  local m_nSoundId = nil
  if SoundManager._sndOn == true then
     m_nSoundId = engine:playEffect(path)
  end
  return m_nSoundId
end

function SoundManager.stopEffect(sndId)
  engine:stopEffect(sndId)
end


_playBgm = SoundManager.playBgm
_playSnd = SoundManager.playEffect
SoundManager.init()
