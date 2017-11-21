require("model.battle.Battle")
require("model.battle.BattleCard")

BattleCardMoveEffect = {}
local speed = 0.85

-- infantry
local function defaultMoveAnim_0(card,cardView,battle,battleView,from,to)

  local duration = 0.5 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  local array = CCArray:create()
  local move = CCEaseSineInOut:create(CCMoveTo:create(duration,to))
  local scaleArray = CCArray:create()
  local scaleDuration = duration * 0.5
  local scaleRatio = 0.618
  scaleArray:addObject(CCEaseIn:create(CCScaleTo:create(scaleDuration,scaleRatio,scaleRatio),0.5))
  scaleArray:addObject(CCEaseIn:create(CCScaleTo:create(scaleDuration,1.0,1.0),0.5))
  local scale = CCSequence:create(scaleArray)
  array:addObject(CCSpawn:createWithTwoActions(move,scale))
  local action = CCSequence:create(array)
  cardView:runAction(action)
  
  local effect_move = CCEaseSineInOut:create(CCMoveTo:create(duration,to))
  cardView._effectNode:runAction(effect_move)
  
  cardView:wait(duration)
  
  return duration
end

-- cavalry
local function defaultMoveAnim_1(card,cardView,battle,battleView,from,to)
  local duration = 0.6 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  local count = 2
  local sub_duration = duration / count
  local sub_distance = (to.y - from.y) / count
  for i=1, count do
    local target_pos = ccp(from.x,from.y + sub_distance * i)
    local array = CCArray:create()
    local move = CCEaseSineInOut:create(CCMoveTo:create(sub_duration,target_pos))
    local scaleArray = CCArray:create()
    local scaleDuration = sub_duration * 0.5
    local scaleRatio = 1.28
    scaleArray:addObject(CCEaseIn:create(CCScaleTo:create(scaleDuration,scaleRatio,scaleRatio),0.5))
    scaleArray:addObject(CCEaseIn:create(CCScaleTo:create(scaleDuration,1.0,1.0),0.5))
    local scale = CCSequence:create(scaleArray)
    array:addObject(CCSpawn:createWithTwoActions(move,scale))
    local action = CCSequence:create(array)
    cardView:runAction(action)
    
    local effect_move = CCEaseSineInOut:create(CCMoveTo:create(sub_duration,target_pos))
    cardView._effectNode:runAction(effect_move)  	
    
    cardView:wait(sub_duration)
  end
  
  return duration
end

-- dancer
local function defaultMoveAnim_2(card,cardView,battle,battleView,from,to)
  local duration = 0.5 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  local count = 3
  local sub_duration = duration / count
  local sub_distance = (to.y - from.y) / count
  local sign = 0
  local x_offset = BattleConfig.BattleFieldLen * 0.1
  x_offset = 0
  local angle_distance = 20
  local init_angle = angle_distance * 0.5
  local angle = init_angle
  local rotation_array = CCArray:create()
  local function anim(target_pos,sub_duration,angle)
    
    local rotation_duration = sub_duration
    local rotation = CCRotateTo:create(rotation_duration,angle)
    rotation_array:addObject(rotation)
  end
  
  for i=1, count do
    if i%2 == 0 then
      sign = 1
    else
      sign = -1
    end

    local target_pos = ccp(from.x + x_offset * sign,from.y + sub_distance * i)
    if i == 1 then
      anim(target_pos,sub_duration,init_angle)
    elseif i == count then
      anim(to,sub_duration,0)
    else
      anim(target_pos,sub_duration,angle)
    end
    
    angle = angle + sign * angle_distance
  end
  
  local move = CCMoveTo:create(duration,to)
  local all_rotation = CCSequence:create(rotation_array)
  local action = CCSpawn:createWithTwoActions(move,all_rotation)
  cardView:runAction(action)
  
  local effect_move = CCEaseSineInOut:create(CCMoveTo:create(sub_duration,to))
  cardView._effectNode:runAction(effect_move)   
  cardView:wait(duration)
  
  return duration
end

-- counselor
local function defaultMoveAnim_3(card,cardView,battle,battleView,from,to)

  local duration = 0.5 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  local array = CCArray:create()
  local scaleInDuration = duration * 0.2
  local scaleIn = CCScaleTo:create(scaleInDuration,0.3,1.0)
  array:addObject(scaleIn)
  local hide = CCHide:create()
  array:addObject(hide)  
  local delayDuration = duration * 0.6
  local delay = CCDelayTime:create(delayDuration)
  array:addObject(delay)
  local place = CCPlace:create(to)
  array:addObject(place)  
  local show = CCShow:create()
  array:addObject(show)  
  local scaleOutDuration = duration * 0.2
  local scaleOut = CCScaleTo:create(scaleOutDuration,1.0,1.0)
  array:addObject(scaleOut)  
  local action = CCSequence:create(array)
  cardView:runAction(action)
  
  cardView:wait(duration)
  cardView._effectNode:setPosition(to)
  
  return duration
end

-- catapult
local function defaultMoveAnim_4(card,cardView,battle,battleView,from,to)

  local duration = 0.9 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  local scale_dst = 1.1
  
  local array = CCArray:create()
  local scaleOutDuration = duration * 0.1
  local scaleOut = CCScaleTo:create(scaleOutDuration,scale_dst,scale_dst)
  array:addObject(scaleOut)    
  local moveDuration = duration * 0.8
  local move = CCEaseOut:create(CCMoveTo:create(moveDuration,to),0.9)
  array:addObject(move) 
  local scaleInDuration = duration * 0.1
  local scaleIn = CCScaleTo:create(scaleInDuration,1.0,1.0)
  array:addObject(scaleIn)   
  local action = CCSequence:create(array)
  cardView:runAction(action)
  
  local effect_move = CCEaseSineInOut:create(CCMoveTo:create(duration,to))
  cardView._effectNode:runAction(effect_move)
  
  cardView:wait(duration)
  
  return duration
end

BattleCardMoveEffect[PbTroopType.Infantry] = defaultMoveAnim_0
BattleCardMoveEffect[PbTroopType.Cavalry] = defaultMoveAnim_1
BattleCardMoveEffect[PbTroopType.Archer] = defaultMoveAnim_0
BattleCardMoveEffect[PbTroopType.Martial] = defaultMoveAnim_0
BattleCardMoveEffect[PbTroopType.Hoursemen] = defaultMoveAnim_1
BattleCardMoveEffect[PbTroopType.Counselor] = defaultMoveAnim_3
BattleCardMoveEffect[PbTroopType.Taoist] = defaultMoveAnim_3
BattleCardMoveEffect[PbTroopType.Geomancer] = defaultMoveAnim_3
BattleCardMoveEffect[PbTroopType.Dancer] = defaultMoveAnim_2
BattleCardMoveEffect[PbTroopType.Catapult] = defaultMoveAnim_4