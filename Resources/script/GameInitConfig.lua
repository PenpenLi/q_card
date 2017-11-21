

-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2
DEBUG_FPS =  false
DEBUG_MEM = true

-- design resolution
CONFIG_SCREEN_WIDTH  = 640
CONFIG_SCREEN_HEIGHT = 960

local winSize = CCDirector:sharedDirector():getWinSize()

-- auto scale mode

--CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"

local w_h_ratio = winSize.height/winSize.width
if w_h_ratio < 1.5 then
   CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT" -- for ipad
else
   CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"  
end

-- sounds
GAME_SFX = {
}

GAME_TEXTURE_DATA_FILENAME  = "AllSprites.plist"
GAME_TEXTURE_IMAGE_FILENAME = "AllSprites.png"

CONFIG_WRITE_PATH_ROOT = CCFileUtils:sharedFileUtils():getWritablePath()
CONFIG_SESSION_FILE = CONFIG_WRITE_PATH_ROOT.."/session.file"

CONFIG_DEFAULT_ANIM_DELAY_RATIO = 1.0

CONFIG_BATTLE_SPEED_RATIO_LV1 = 1.3
CONFIG_BATTLE_SPEED_RATIO_LV2 = 1.5
CONFIG_BATTLE_SPEED_RATIO_LV3 = 1.8

CONFIG_BATTLE_SPEED_RATIO = CONFIG_BATTLE_SPEED_RATIO_LV1

-- color
sgYELLOW   = ccc3(255 ,245,165)
sgVIOLET   = ccc3(69, 20, 1)
sgGREEN    =  ccc3(0,  214, 40)
sgBROWN    = ccc3(64, 27, 0)
sgORANGE   = ccc3(184, 63, 3)
sgRED      = ccc3(183, 00, 7)
sgBLUE     = ccc3(19,45,176)

-- list cell size
ConfigListCellWidth = 640
ConfigListCellHeight = 154

-- popUpNode tag
POPUP_NODE_ZORDER = 2000
ANDROID_PAY_COMBIN_PLAYER_LV = 20  -- 多支付渠道开启的玩家等级

--login notice url
LOGIN_NOTICE_URL = "http://10.103.252.67:8080/news.json"

--server list name
SEVER_LISTS_NAME = {
   ["District_1"] = "不测不能上",
   ["District_2"] = "Server 67",
   ["District_3"] = "Server 68",
   ["District_4"] = "Server 91"
}

-- open or close cdk exchange
-- 0 close 1 open
CDK_ENABLED = 1

-- open or close share
-- 0 close 1 open
IOS_SHARE_ENABLED = 0

--force skip battle play
-- 0 normal, 1 force skip
BATTLE_SKIP_ENABLED = 1

--camera follows action card
-- 0 don't follow, 1 follow
BATTLE_CAMERA_FOLLOW = 0

--force skip new bird guide
-- 0 normal, 1 force skip
NEW_BIRD_SKIP_ENABLED = 1

--force open all system (only for test,maybe bring some troubles)
-- 0 normal, 1 force open
ALL_SYSTEM_OPEN = 1

--for local battle test
-- 0 close (enter game), 1 open (enter battle test)
BATTLE_TEST_OPEN = 0

BGM_LOGIN = "bgm/music_login.mp3"
BGM_MAIN = "bgm/music_menu.mp3"
BGM_BATTLE_FAST = "bgm/music_battle_fast.mp3"
BGM_BATTLE_SLOW = "bgm/music_battle_slow.mp3"
BGM_BATTLE_WIN = "bgm/music_battle_win.mp3"
BGM_BATTLE_LOST = "bgm/music_battle_loss.mp3"

SFX_CLICK = "sfx/click.wav"
SFX_CLICK_BACK = "sfx/click_back.wav"
SFX_SWAP_SCREEN = "sfx/swap_screen.wav"
SFX_STAR_FALL = "sfx/star_fall.wav"
SFX_ITEM_ACQUIRED = "sfx/item_acquired.wav"
SFX_MELEE_ATTACK = "sfx/melee_attack.wav"
SFX_RANGED_ATTACK = "sfx/ranged_attack.wav"
SFX_MAGE_ATTACK = "sfx/mage_attack.wav"
SFX_CLERIC_ATTACK = "sfx/cleric_attack.wav"
SFX_WIZARD_ATTACK = "sfx/wizard_attack.wav"
SFX_CATAPULT_ATTACK = "sfx/catapult_attack.wav"
SFX_MARTIAL_ARTIST_ATTACK = "sfx/martial_artist_attack.wav"
SFX_DANCER_ATTACK = "sfx/dancer_attack.wav"
SFX_BLOCK = "sfx/block.wav"
SFX_UNIT_DEAD = "sfx/unit_dead.wav"
SFX_SWORDMAN_MOVE = "sfx/swordman_move.wav"
SFX_HORSEMAN_MOVE = "sfx/horseman_move.wav"
SFX_SKILL_CAST = "sfx/skill_cast.wav"
SFX_SKILL_FIRE = "sfx/skill_fire.wav"
SFX_SKILL_WATER = "sfx/skill_water.wav"
SFX_SKILL_LIGHTING = "sfx/skill_lighting.wav"
SFX_SKILL_POISON = "sfx/skill_poison.wav"
SFX_SKILL_HPRESTORE = "sfx/skill_hp_restore.wav"
SFX_SKILL_CHAIN = "sfx/skill_chain.wav"
SFX_SKILL_SHIELD = "sfx/skill_shield.wav"
SFX_SKILL_HIT = "sfx/skill_hit.wav"
SFX_CASTLE_HURT = "sfx/castle_hurt.wav"
