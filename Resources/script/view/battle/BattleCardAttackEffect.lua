require("model.battle.Battle")
require("model.battle.BattleCard")

BattleCardAttackEffect = {}
--local speed = 0.55
local speed = 1.0 * CONFIG_BATTLE_SPEED_RATIO_LV1

local function defaultSrcMeleeAttackAnim(card,cardView,battle,battleView)

  local sign = cardView:getActionSign()
  local duration = 0.3 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  local array = CCArray:create()
  local originPos = battleView:getPosByIndex(card:getPos())
  -- raise up
  local raiseDuration = duration * 0.4
--  local r_skew = CCSkewBy:create(raiseDuration,3,3)
  local r_bezier = ccBezierConfig()
  r_bezier.controlPoint_1 = ccp(0, 6);
  r_bezier.controlPoint_2 = ccp(10, 10)
  r_bezier.endPosition = ccp(10,15)
  local r_move = CCBezierBy:create(raiseDuration,r_bezier)
  local r_rotation = CCRotateBy:create(raiseDuration,30, 30)
--  local r_anim = CCSpawn:createWithTwoActions(r_skew,CCSpawn:createWithTwoActions(r_move,r_rotation))
  local r_anim = CCEaseIn:create(CCSpawn:createWithTwoActions(r_move,r_rotation),0.2)
  array:addObject(r_anim)
  
  -- cut down
  local cutDownDuration = duration * 0.3
--  local c_skew = CCSkewBy:create(cutDownDuration,-6,-6)
  local c_bezier = ccBezierConfig()
  c_bezier.controlPoint_1 = ccp(0, -12);
  c_bezier.controlPoint_2 = ccp(-20, -20)
  c_bezier.endPosition = ccp(-20,-30)
  local c_move = CCBezierBy:create(cutDownDuration,c_bezier)
  local c_rotation = CCRotateBy:create(cutDownDuration,-40, -40)
--  local c_anim = CCSpawn:createWithTwoActions(c_skew,CCSpawn:createWithTwoActions(c_move,c_rotation))
  local c_anim = CCEaseOut:create(CCSpawn:createWithTwoActions(c_move,c_rotation),0.2)
  array:addObject(c_anim)
  
  -- back anim
  local backDuration = duration * 0.3
  local backSkew = CCSkewTo:create(backDuration,0,0)
  local backMove = CCMoveTo:create(backDuration,originPos)
  local backRotation = CCRotateTo:create(backDuration,0, 0)
  local backAnim = CCSpawn:createWithTwoActions(backSkew,CCSpawn:createWithTwoActions(backMove,backRotation))
  array:addObject(backAnim)
  
  array:addObject(CCCallFunc:create(function ()
    local origin = battleView:getPosByIndex(card:getPos())
    cardView:setPosition(origin)
  end))
  
  local action = CCSequence:create(array)
  cardView:runAction(action)
  
  return duration
end

local function defaultSrcRemoteAttackAnim(card,cardView,battle,battleView)

  local sign = cardView:getActionSign()
  local duration = 0.4 * speed * CONFIG_DEFAULT_ANIM_DELAY_RATIO
  local move_distance = 30 * sign
  local array = CCArray:create()
  local move_back_duration = 0.4 * duration
  local move_back = CCMoveBy:create(move_back_duration,ccp(0,-move_distance))
  array:addObject(move_back)
  local move_forward_duration = 0.6 * duration
  local move_forward = CCEaseBounceOut:create(CCMoveBy:create(move_forward_duration,ccp(0,move_distance)))
  array:addObject(move_forward)
  local action = CCSequence:create(array)
  cardView:runAction(action)
  
  return duration

end

-- normal attack src animation
function BattleCardAttackEffect.defaultSrcAnim(fromcard,fromCardView,battle,battleView,forceMelee)
  local attackType = PbAttackType.AttackNormal
  if forceMelee == true then
    attackType = PbAttackType.AttackForceMelee
  end
  local unitTypeConfig = AllConfig.unittype[fromcard:getType()]
  assert(unitTypeConfig,string.format("Invalid unitTypeConfig,type:%d",fromcard:getType()))
  -- card action
  if unitTypeConfig.atk_type == 1 then
    defaultSrcMeleeAttackAnim(fromcard,fromCardView,battle,battleView)
  else
    if forceMelee == true then
      defaultSrcMeleeAttackAnim(fromcard,fromCardView,battle,battleView)
    else
      defaultSrcRemoteAttackAnim(fromcard,fromCardView,battle,battleView)
    end
  end
  
  local anim = PbTroopAnim[fromcard:getType()][attackType].src
  assert(anim)
  -- card effect
  return fromCardView:playAttackAnim(anim.animId,anim.flip)  
end

-- normal attack dst animation
function BattleCardAttackEffect.defaultDstAnim(fromcard,target,targetView,battle,battleView,forceMelee)
  local attackType = PbAttackType.AttackNormal
  if forceMelee == true then
    attackType = PbAttackType.AttackForceMelee
  end
  local anim = PbTroopAnim[fromcard:getType()][attackType].dst
  return targetView:playAttackAnim(anim.animId,anim.flip)  
  
end

for key, var in pairs(PbTroopType) do
  BattleCardAttackEffect[var] = {}
	BattleCardAttackEffect[var].execSrcAnim = BattleCardAttackEffect.defaultSrcAnim
	BattleCardAttackEffect[var].execDstAnim = BattleCardAttackEffect.defaultDstAnim
end



--BattleCardAttackEffect[PbTroopType.Infantry] = {}
--BattleCardAttackEffect[PbTroopType.Infantry].execSrcAnim = function (fromcard,cardView,battle,battleView,forceMelee)
--  defaultSrcMeleeAttackAnim(fromcard,cardView,battle,battleView)
--  local anim = PbTroopAnim[PbTroopType.Infantry][forceMelee].src
--  cardView:playAttackAnim(anim.animId,anim.flip)
--end