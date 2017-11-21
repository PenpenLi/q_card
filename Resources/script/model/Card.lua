require("model.Item")
require("model.Skill")
Card = class("Card",Item)
Card.CardHpTypeBable = "BableType"
function Card:ctor(configId)
  Card.super.ctor(self)
  --index value
  self._species = 1      
  self._level = 1    
  self._maxLevel = 1     
  self._hp = 0             
  self._maxHp = 0          
  self._mp = 0            
  self._maxMp = 0         
  self._isUser = false    
  self._isBoss = false    
  self._isDebris = false   
  self._isOnBattle = false 
  self._damage = 0
  self._dominance = 0
  self._strength = 0
  self._intelligence = 0
  self._country = 1  --1.shu 2.wei 3.wu, 4.qun
  self._weapon = nil
  self._armor = nil
  self._accessory = nil
  self._PlayStagesPosition = -1
  self._position = 0
  self:setPos(0)
  self:setOwnerType(BattleConfig.CardOwnerTypeSelf)
  self:setBableIsAlive(0)
  self:setCardHpperInfo({})
  if configId then
    self:initAttrById(configId)
  end
end

function Card:update(cardInfo)

  self:initAttrById(cardInfo.config_id)
  self:setIsBoss(cardInfo.is_leader)
  self:setId(cardInfo.id)
  self:setWorkState(cardInfo.state)
  
  self:setWeapon(nil)
  self:setArmor(nil)
  self:setAccessory(nil)
  
  if cardInfo.weapon ~= nil and cardInfo.weapon > 0 then
    local weapons = GameData:Instance():getCurrentPackage():getAllWeapons()
    if weapons ~= nil then 
      for i = 1, table.getn(weapons) do 
        if weapons[i]:getId() == cardInfo.weapon then 
          self:setWeapon(weapons[i])
          break 
        end
      end
    end
  end
  
  if cardInfo.armor ~= nil and cardInfo.armor > 0 then
    local armors = GameData:Instance():getCurrentPackage():getAllArmors()
    if armors ~= nil then 
      for i = 1, table.getn(armors) do 
        if armors[i]:getId() == cardInfo.armor then 
          self:setArmor(armors[i])
          break 
        end
      end
    end
  end
  
  if cardInfo.adornment ~= nil and cardInfo.adornment > 0 then
    local accessories = GameData:Instance():getCurrentPackage():getAllAccessories()
    if accessories ~= nil then 
      for i = 1, table.getn(accessories) do 
        if accessories[i]:getId() == cardInfo.adornment then 
          self:setAccessory(accessories[i])
          break 
        end
      end
    end
  end

  self:setPosition(cardInfo.position)
  self:setExperience(cardInfo.experience)
  self:setIsOnBattle(cardInfo.is_active)
  local skill = self:getSkill()
  if skill ~= nil then
    skill:update(cardInfo.config_id, cardInfo.skill_experience)
  end
  
  self:setCardHpperInfo(cardInfo.card_hp_per)
end

------
--  Getter & Setter for
--      Card._BableIsAlive 0 dead 1 live
-----
function Card:setBableIsAlive(BableIsAlive)
	self._BableIsAlive = BableIsAlive
end

function Card:getBableIsAlive()
	return self._BableIsAlive
end

------
--  Getter & Setter for
--      Card._CardHpperInfo 
-----
function Card:setCardHpperInfo(CardHpperInfo)
	self._CardHpperInfo = CardHpperInfo
	if self._CardHpperInfo ~= nil then
	 --print("update card hpper")
	 --update bable battle formation
	 for key, var in pairs(self._CardHpperInfo) do
    --print("var.hp_type:",var.hp_type)
    --print("var.card_hp_per:",var.card_hp_per)
    
    if var.hp_type == Card.CardHpTypeBable then
      if var.card_hp_per > 0 then
        self:setBableIsAlive(1)
      else
        self:setBableIsAlive(0)
      end
    
      local cardsFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(BattleFormation.BATTLE_INDEX_BABLE)
      for key, battleCardInfo in pairs(cardsFormation) do
        if battleCardInfo.card == self:getId() and var.card_hp_per <= 0 then
          table.remove(cardsFormation,key)
        end
      end
    end
  end
	end
end

function Card:getCardHpperInfo()
	return self._CardHpperInfo
end

function Card:getCardHpperByHpType(hpType)
  local hpper = 10000
  local hpInfo = self:getCardHpperInfo()
	for key, var in pairs(hpInfo) do
	  --dump(var)
	  --print("var.hp_type:",var.hp_type)
	  --print("var.card_hp_per:",var.card_hp_per)
		if var.hp_type == hpType then
		  hpper = var.card_hp_per
		end
	end
	return hpper
end

------
--  Getter & Setter for
--      Card._OwnerType 
-----
function Card:setOwnerType(OwnerType)
	self._OwnerType = OwnerType
end

function Card:getOwnerType()
	return self._OwnerType
end

function Card:initAttrById(id)
	self:setConfigId(id)
	
	local item = AllConfig.unit[id]	
	if item == nil then
	 echo("[Card.lua]------------can not find the configId:", id)
	 return 
  	end
	
	self:setName(item.unit_name)
	self:setGrade(item.card_rank + 1)
	self:setMaxGrade(item.card_max_rank + 1)
	self:setImproveGrade(item.card_improve)
	self:setSpecies(item.unit_type)
	self:setCountry(item.country1)
	self:setLevel(1)
	self:setMaxLevel(item.max_level)
	   ---- self:setCountry()
	self:setUnitRoot(item.unit_root)
	self:setLeadCost(item.lead_cost)					--cur leadship
	self:setLeadShip(AllConfig.charlevel[self:getLevel()].leadship)	--max leadship
	self:setCombinedSkill(item.combined_skill)

	local index = self:getMaxGrade()*10000 + (self:getGrade()-1)*1000 + self:getLevel()
	local price = AllConfig.cardsell[index].price
	self:setSalePrice(price)
	
	--skill info
	if self:getSkill() == nil then 
		local skillId = item.skill
		local skill = Skill.new(self)
		skill:update(id, 0)
		self:setSkill(skill)
	end 
	
	self:setUnitHeadPic(item.unit_head_pic)
	self:setUnitPic(item.unit_pic)
	 
  self:setBattleHead(item.battle_head)
  self:setBattlePic(item.battle_pic)
  
  self:setCanDismantled(id)
	self:setDismantleInfo(id)
	self:setIsExpCard(item.is_exp_card)
	self:setActiveEquipId(item.active_equipment)
	
	local dubbings = {}
	if item.unit_dubbing ~= nil then
		for key,dubbingId  in pairs(item.unit_dubbing) do
			table.insert(dubbings,dubbingId)
		end
	end
	self:setDubbings(dubbings)
	
	if self:getIsExpCard()==false then 
	  assert(AllConfig.jianghun[id] ~= nil,"AllConfig.jianghun["..id.."] error")
		self:setCardSoulCost(AllConfig.jianghun[id].cost)
		self:setCardSoulGainType(AllConfig.jianghun[id].currency_type)
		self:setCardSoulGain(AllConfig.jianghun[id].currency)	
	end 
	self:initProperties()

  self:setGroupIndex(item.group)
end 

------
--  Getter & Setter for
--      Card._ActiveEquipId 
-----
function Card:setActiveEquipId(ActiveEquipId)
	self._ActiveEquipId = ActiveEquipId
end

function Card:getActiveEquipId()
	return self._ActiveEquipId
end

------
--  Getter & Setter for
--      Card._Dubbings 
-----
function Card:setDubbings(Dubbings)
	self._Dubbings = Dubbings
end

function Card:getDubbings()
	return self._Dubbings
end

------
--  Getter & Setter for
--      Card._Pos 
-----
function Card:setPos(Pos)
	self._Pos = Pos
end

function Card:getPos()
	return self._Pos
end

------
--  Getter & Setter for
--      Card._BattlePic 
-----
function Card:setBattlePic(BattlePic)
	self._BattlePic = BattlePic
end

function Card:getBattlePic()
	return self._BattlePic
end

------
--  Getter & Setter for
--      Card._BattleHead 
-----
function Card:setBattleHead(BattleHead)
	self._BattleHead = BattleHead
end

function Card:getBattleHead()
	return self._BattleHead
end

function Card:getRandomDubbing()
  local pathId = 0
  local randomId = 1
  local total = #self:getDubbings()
  if total == 1 then
     pathId = self:getDubbings()[randomId]
  elseif total > 1 then
     randomId = math.random(1,total)
     pathId = self:getDubbings()[randomId]
  else
  end
  return pathId
end

function Card:getLevelByExp(exp)

	local level = 1

	if exp <= 1 then
		return level
	end

	--update level
	local starIndex = 1
	local endIndex = self:getMaxLevel()

	--get level by total skill exp
	for i=starIndex, endIndex do 
		local totalExp = AllConfig.cardlevelupexp[i].total_exp
		if exp >= totalExp then 
		  level = AllConfig.cardlevelupexp[i].level
		else
		  break
		end
	end

	if level > self:getMaxLevel() then 
		level = self:getMaxLevel()
	end

	return level	
end

function Card:setExperience(exp)
	self._exp = exp

	local level = self:getLevelByExp(exp)
	self:setLevel(level)
end

function Card:getExperience()
	return self._exp
end 

function Card:getEnabledLevelUp()
  local enabledLevelUp = false
	if self:getLevel() < self:getMaxLevel() and self:getLevel() < GameData:Instance():getCurrentPlayer():getLevel() then
      local itemToShow = {22401001,22401004,22401008,22401009}
      local totalCount = 0
      for key, configId in pairs(itemToShow) do
        local item = GameData:Instance():getCurrentPackage():getPropsByConfigId(configId)
        local count = 0
        if item ~= nil then
          count = item:getCount()
        end
        totalCount = totalCount + count
      end
      if totalCount > 0 then
        enabledLevelUp = true
      end
  end
  return enabledLevelUp
end


------
--  Getter & Setter for
--      Card._ConfigId 
-----
function Card:setConfigId(ConfigId)
	self._ConfigId = ConfigId
end

function Card:setUnitHeadPic(unitHeadPicId)
	self._unitHeadPic = unitHeadPicId
end

function Card:getUnitHeadPic()
	return self._unitHeadPic
end

function Card:getConfigId()
	return self._ConfigId
end

------
--  Getter & Setter for
--      Card._UnitPic 
-----
function Card:setUnitPic(UnitPic)
	self._UnitPic = UnitPic
end

function Card:getUnitPic()
	return self._UnitPic
end

function Card:getEquipAttr(baseType, randomType)
	local attr_fix = 0
	local attr_per = 0


	local weapon = self:getWeapon()
	if weapon ~= nil then
		-- local attrArray = weapon:getSkillAttr() --{v.type, v.data, v.generate_type}
		-- if attrArray ~= nil then 
		-- 	for k, v in pairs(attrArray) do 
		-- 		if v[1] == baseType then 
		-- 			attr_fix = attr_fix + v[2]
		-- 		elseif v[1] == randomType then
		-- 			attr_per = attr_per + v[2]
		-- 		end
		-- 	end
		-- end

	end

	local armor = self:getArmor()
	if armor ~= nil then 
		-- local attrArray = armor:getSkillAttr()
		-- if attrArray ~= nil then 
		-- 	for k, v in pairs(attrArray) do 
		-- 		if v[1] == baseType then 
		-- 			attr_fix = attr_fix + v[2]
		-- 		elseif v[1] == randomType then 
		-- 			attr_per = attr_per + v[2]
		-- 		end
		-- 	end
		-- end
	end

	local accessory = self:getAccessory()
	if accessory ~= nil then 
		-- local attrArray = accessory:getSkillAttr()
		-- if attrArray ~= nil then 
		-- 	for k, v in pairs(attrArray) do 
		-- 		if v[1] == baseType then 
		-- 			attr_fix = attr_fix + v[2]
		-- 		elseif v[1] == randomType then 
		-- 			attr_per = attr_per + v[2]
		-- 		end
		-- 	end
		-- end
	end

	return attr_fix, attr_per
end

function Card:getEquipStr()
	local attr_fix = 0
	local attr_per = 0

	local weapon = self:getWeapon()
	if weapon ~= nil then
		local a, b = weapon:getExtStrength()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	local armor = self:getArmor()
	if armor ~= nil then 
		local a, b = armor:getExtStrength()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	local accessory = self:getAccessory()
	if accessory ~= nil then 
		local a, b = accessory:getExtStrength()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	return attr_fix,attr_per
end

function Card:getEquipInt()
	local attr_fix = 0
	local attr_per = 0

	local weapon = self:getWeapon()
	if weapon ~= nil then
		local a, b = weapon:getExtIntelligence()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	local armor = self:getArmor()
	if armor ~= nil then 
		local a, b = armor:getExtIntelligence()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	local accessory = self:getAccessory()
	if accessory ~= nil then 
		local a, b = accessory:getExtIntelligence()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	return attr_fix,attr_per
end

function Card:getEquipDom()
	local attr_fix = 0
	local attr_per = 0

	local weapon = self:getWeapon()
	if weapon ~= nil then
		local a, b = weapon:getExtDominance()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	local armor = self:getArmor()
	if armor ~= nil then 
		local a, b = armor:getExtDominance()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	local accessory = self:getAccessory()
	if accessory ~= nil then 
		local a, b = accessory:getExtDominance()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	return attr_fix,attr_per
end

function Card:getEquipHp()
	local attr_fix = 0
	local attr_per = 0

	local weapon = self:getWeapon()
	if weapon ~= nil then
		local a, b = weapon:getExpHp()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	local armor = self:getArmor()
	if armor ~= nil then 
		local a, b = armor:getExpHp()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	local accessory = self:getAccessory()
	if accessory ~= nil then 
		local a, b = accessory:getExpHp()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	return attr_fix,attr_per
end

function Card:getEquipAtk()
	local attr_fix = 0
	local attr_per = 0

	local weapon = self:getWeapon()
	if weapon ~= nil then
		local a, b = weapon:getExtAttack()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	local armor = self:getArmor()
	if armor ~= nil then 
		local a, b = armor:getExtAttack()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	local accessory = self:getAccessory()
	if accessory ~= nil then 
		local a, b = accessory:getExtAttack()
		attr_fix = attr_fix + a 
		attr_per = attr_per + b
	end

	return attr_fix,attr_per
end


function Card:setStrength(strenth)
	self._strength = strenth
end

function Card:getStrength()
	return self:getStrengthByLevel(self:getLevel())
end

function Card:setPlayStagesPosition(PlayStagesPosition)
	self._PlayStagesPosition = PlayStagesPosition
end

function Card:getPlayStagesPosition()
	return self._PlayStagesPosition
end


function Card:initProperties()
  local configId = self:getConfigId()
  local properties = {}
  for i = 1, kMaxProperties do
    properties[i] = 0
    if i == k_property_evade then
      properties[i] = AllConfig.unitgrown[configId].evade
    elseif i == k_property_hit then
      properties[i] = AllConfig.unitgrown[configId].hit
    elseif i == k_property_cri then
      properties[i] = AllConfig.unitgrown[configId].cri
    elseif i == k_property_tough then
      properties[i] = AllConfig.unitgrown[configId].toughness
    elseif i == k_property_block then
      properties[i] = AllConfig.unitgrown[configId].block
    elseif i == k_property_precision then
      properties[i] = AllConfig.unitgrown[configId].precision
    elseif i == k_property_damage_increase then
      properties[i] = AllConfig.unitgrown[configId].damage_increase
    elseif i == k_property_damage_reduce then
      properties[i] = AllConfig.unitgrown[configId].damage_reduce
    end
  end
  self:setProperties(properties)
end

------
--  Getter & Setter for
--      Equipment._Properties 
-----
function Card:setProperties(Properties)
  self._Properties = Properties
end

function Card:getProperties()
  return self._Properties
end

function Card:getPropertyByType(type)
  return self:getPropertyByTypeAndLevel(type,self:getLevel())
end

function Card:getPropertyByTypeAndLevel(type,level)
  local isPer = false
  if type ==  k_property_hp_fix then
    return toint(self:getHpByLevel(level)),isPer
  elseif type == k_property_atk_fix then
    return toint(self:getAttackByLevel(level)),isPer
  elseif type == k_property_str_fix then
    return toint(self:getStrengthByLevel(level)),isPer
  elseif type == k_property_int_fix then
    return toint(self:getIntelligenceByLevel(level)),isPer
  elseif type == k_property_dom_fix then
    return toint(self:getDominanceByLevel(level)),isPer
  end
  
  isPer = true

  assert(type == k_property_hit
  or type == k_property_evade
  or type == k_property_cri
  or type == k_property_tough 
  or type == k_property_block 
  or type == k_property_precision
  or type == k_property_damage_increase
  or type == k_property_damage_reduce
  or type == kCriticalDamageIncAddPercent,"not Support this type")
  return self._Properties[type] + self:getEquipPropertyByType(type),isPer
end

function Card:getEquipPropertyByType(type)
  local property = 0
  local weapon = self:getWeapon()
  if weapon ~= nil then
    property = weapon:getPropertyByType(type) + property
  end

  local armor = self:getArmor()
  if armor ~= nil then 
    property = armor:getPropertyByType(type) + property
  end

  local accessory = self:getAccessory()
  if accessory ~= nil then 
    property = accessory:getPropertyByType(type) + property
  end
  return property
end

function Card:getStrengthByLevel(level)
	local configId = self:getConfigId()
	local attr_type = AllConfig.unit[configId].attr_type   --兵种
	local attrId = attr_type*1000 + level
	--local grownId = AllConfig.unit[configId].grown_id
	local str = AllConfig.attrtype[attrId].str_fix
	local str_grown = AllConfig.unitgrown[configId].str_grown/10000

	local str_fix, str_per = self:getEquipStr()
	self._strength = (str * str_grown + str_fix)*(1 + str_per)

	--echo("  id,level,strenth =",configId,level,self._strength)
	--echo("  str_fix, str_per =", str_fix, str_per)
	return self._strength
end

function Card:setIntelligence(intelligence)
	self._intelligence = intelligence
end

function Card:getIntelligence()
	return self:getIntelligenceByLevel(self:getLevel())
end


function Card:getIntelligenceByLevel(level)
	local configId = self:getConfigId()
	local attr_type = AllConfig.unit[configId].attr_type   --兵种
	local attrId = attr_type*1000 + level

	local int = AllConfig.attrtype[attrId].int_fix
	local int_grown = AllConfig.unitgrown[configId].int_grown/10000
	local int_fix, int_per = self:getEquipInt()
	self._intelligence = (int * int_grown + int_fix)*(1 + int_per)
	-- echo("  getIntelligence = "..self._intelligence)

	return self._intelligence
end

function Card:setDominance(dominance)
	self._dominance = dominance
end

function Card:getDominance()
	return self:getDominanceByLevel(self:getLevel())
end

function Card:getDominanceByLevel(level)
	local configId = self:getConfigId()
	local attr_type = AllConfig.unit[configId].attr_type   --兵种
	local attrId = attr_type*1000 + level

	local dom = AllConfig.attrtype[attrId].dom_fix
	local dom_grown = AllConfig.unitgrown[configId].dom_grown/10000
	local dom_fix, dom_per = self:getEquipDom()

	self._dominance = (dom * dom_grown + dom_fix)*(1 + dom_per)
	--echo("  getDominance = "..self._dominance)
	return self._dominance
end

function Card:setHp(hp)
	self._hp = hp
end

function Card:getHp()
	return self:getHpByLevel(self:getLevel())
end

function Card:getHpByLevel(level)
	local configId = self:getConfigId()
	local attr_type = AllConfig.unit[configId].attr_type   --兵种
	local attrId = attr_type*1000 + level

	local hp = AllConfig.attrtype[attrId].hp_fix
	local hp_fix, hp_per = self:getEquipHp()
	local unitConfig = AllConfig.unit[self:getConfigId()].config
	local dom_hp = AllConfig.unitinitdata[unitConfig].dom_hp/10000 * self:getDominanceByLevel(level)
	--echo("--->>>hp,hp_fix, hp_per,dom_hp",hp, hp_fix, hp_per, dom_hp)
	self._hp = (dom_hp + hp + hp_fix)*(1 + hp_per)
	--echo("  getHp = "..self._hp)
	return self._hp
end

function Card:setAttack(atk)
	self._atk = atk
end

function Card:getAttack()
	return self:getAttackByLevel(self:getLevel())
end

function Card:getAttackByLevel(level)
	local configId = self:getConfigId()
	local attr_type = AllConfig.unit[configId].attr_type   --兵种
	local attrId = attr_type*1000 + level

	local atk = AllConfig.attrtype[attrId].atk_fix
	local atk_fix, atk_per = self:getEquipAtk()
	local unitConfig = AllConfig.unit[self:getConfigId()].config
	local str_atk = AllConfig.unitinitdata[unitConfig].str_atk/10000 * self:getStrengthByLevel(level)
	local int_atk = AllConfig.unitinitdata[unitConfig].int_atk/10000 * self:getIntelligenceByLevel(level)

	self._atk = (str_atk + int_atk + atk + atk_fix)*(1 + atk_per)
	--echo(" _atk = "..self._atk)
	return self._atk
end

--function Card:setDamageIncrease(DamageIncrease)
--  self._DamageIncrease = DamageIncrease
--end
--
--function Card:getDamageIncrease()
--  return self._DamageIncrease
--end
--
--
--function Card:setHit(hit)
--  self._hit = hit
--end
--
--function Card:getHit()
--  return self._hit
--end
--
--function Card:setEvade(evade)
--  self._evade = evade
--end
--
--function Card:getEvade()
--  return self._evade
--end
--
--function Card:setCritical(critical)
--  self._critical = critical
--end
--
--function Card:getCritical()
--  return self._critical
--end
--
--function Card:setToughness(toughness)
--  self._toughness = toughness
--end
--
--function Card:getToughness()
--  return self._toughness
--end
--
--function Card:setBlock(block)
--  self._block = block
--end
--
--function Card:getBlock()
--  return self._block
--end
--
--function Card:setDamageReduce(damageReduce)
--  self._damageReduce = damageReduce
--end
--
--function Card:getDamageReduce()
--  return self._damageReduce
--end
--
--function Card:setReflect(reflect)
--  self._reflect = reflect
--end
--
--function Card:getReflect()
--  return self._reflect
--end




function Card:setUnitRoot(type)
	self._unitRoot = type
end

function Card:getUnitRoot()
	return self._unitRoot
end

function Card:setSalePrice(money)
	self._salePrice = money
end 

function Card:getSalePrice()
	return self._salePrice
end 

function Card:setLeadCost(lead)
	self._leadCost = lead
end 

function Card:getLeadCost()
	return self._leadCost
end 

function Card:setLeadShip(leadship)
	self._leadShip = leadship
end 

function Card:getLeadShip()
	return self._leadShip
end 



function Card:setId(Id)
	self._Id = Id
end

function Card:getId()
	return self._Id
end

------
--  Getter & Setter for
--      Card._TalentDesc 
-----
function Card:setTalentDesc(TalentDesc)
	self._TalentDesc = TalentDesc
end

function Card:getTalentDesc()
	return self._TalentDesc
end

------
--  Getter & Setter for
--      Card._CombinedSkill 
--      int
-----
function Card:setCombinedSkill(CombinedSkill)
	self._CombinedSkill = CombinedSkill
end

function Card:getCombinedSkill()
	return self._CombinedSkill
end


function Card:setPreviewTexturePath(previewTexturePath)
	self._previewTexturePath = previewTexturePath
end


--  Getter & Setter for
--      Card._weapon 
-----
function Card:setWeapon(weapon)
--  if self._weapon ~= nil then
--     self._weapon:setCard(nil)
--     self._weapon = nil
--  end
--  
--  
--  if weapon ~= nil then
--    print("setWeapon:",weapon:getName())
--    weapon:setCard(self)
--  else
--    print("setWeapon:nil")
--  end
  self._weapon = weapon
end

function Card:getWeapon()
  return self._weapon
end

------
--  Getter & Setter for
--      Card._armor 
-----
function Card:setArmor(armor)
--  if self._armor ~= nil then
--     self._armor:setCard(nil)
--     self._armor = nil
--  end
--  if armor ~= nil then
--   armor:setCard(self)
--  end
  self._armor = armor
end

function Card:getArmor()
	return self._armor
end

------
--  Getter & Setter for
--      Card._accessory 
-----
function Card:setAccessory(accessory)
--  if self._accessory ~= nil then
--     self._accessory:setCard(nil)
--     self._accessory = nil
--  end
--  
--  if accessory ~= nil then
--   accessory:setCard(self)
--  end
  self._accessory = accessory
end
------
--  Getter & Setter for
--      Card._accessory 
-----
function Card:getAccessory()
	return self._accessory
end




function Card:setSpecies(species)
	self._species = species
end

function Card:getSpecies()
	return self._species
end

function Card:setCost(cost)
	self._cost = cost
end

function Card:getCost()
	return self._cost
end

function Card:setGainedExpAfterEaten(exp)
	self._eatenExp = exp
end

function Card:getGainedExpAfterEaten()
	--update cost and gained exp whild level changed
	local index = self:getMaxGrade()*1000 + self:getLevel()
	local cost = AllConfig.cardgainexp[index].coin_cost
	self._eatenExp = AllConfig.unit[self:getConfigId()].gain_exp + AllConfig.cardgainexp[index].gain_exp
	self:setCost(cost)
	
	return self._eatenExp
end

function Card:setIsBoss(isBoss)
	self._isBoss = isBoss
end

function Card:getIsBoss()
	return self._isBoss
end

function Card:setIsOnBattle(isOnBattle)
	self._isOnBattle = isOnBattle
end

function Card:getIsOnBattle()
  local isOnAnyBattle,battleFormationIdxs = self:getHasBattleFormation()
	return isOnAnyBattle,self._isOnBattle,battleFormationIdxs
end

function Card:getHasBattleFormation()
  local isOnAnyBattle = false
  local battleFormationIdxs = {}
  local battleFormations = BattleFormation:Instance():getAllBattleFormations()
  for battleFormationIdx, battleFormation in pairs(battleFormations) do
   for key, battleCardInfo in pairs(battleFormation) do
      if battleCardInfo.card == self:getId() then
        table.insert(battleFormationIdxs,battleFormationIdx)
        isOnAnyBattle = true 
        break
      end
   end
  end
  return isOnAnyBattle,battleFormationIdxs
end

function Card:setCountry(country)
  self._country = country
end

function Card:getCountry()
  return self._country
end

function Card:setLevel(level)
  self._level = level
end

function Card:getLevel()
  return self._level
end

------
--  Getter & Setter for
--      Card._maxLevel 
-----
function Card:setMaxLevel(maxLevel)
  self._maxLevel = maxLevel
end

function Card:getMaxLevel()
  return self._maxLevel
end

--function Card:setWeapon(weapon)
--  self._weapon = weapon
--  if nil ~= weapon then
--    self._weapon:setCard(self)
--  end
--end
--
--function Card:getWeapon()
--  return self._weapon
--end
--
--function Card:setArmor(armor)
--  self._armor = armor
--  if nil ~= armor then
--    self._armor:setCard(self)
--  end
--end
--
--function Card:getArmor()
--  return self._armor
--end
--
--function Card:setAccessory(accessory)
--  self._accessory = accessory
--  if nil ~= accessory then
--    self._accessory:setCard(self)
--  end
--end
--
--function Card:getAccessory()
--  return self._accessory
--end

function Card:setSkill(skill)
  self._skill = skill
end

function Card:getSkill()
  return self._skill
end

function Card:attack(enabledWalk,isCounte)
end

function Card:hurt(hpNum,skill)
end

function Card:getAttackTarget()
  return self._attackTarget
end

function Card:setPosition(pos)
  self._position = pos
end

function Card:getPosition()
  return self._position
end

function Card:setCanDismantled(configId)
  self._canDismantled = AllConfig.unit[configId].can_dismantle > 0 
end 

function Card:getCanDismantled()
  return self._canDismantled 
end 

function Card:setDismantleInfo(configId)
  self._dropInfo = {}

  -- local array = AllConfig.unit[configId].dismantle_data
  -- for i=1, table.getn(array) do
  -- 	echo("===========drop", configId, array[i])
  -- 	local dropItem = AllConfig.drop[array[i]]
  --   for k,v in pairs(dropItem.drop_data) do 
		-- 	local dropData = v.array
		-- 	local dropName = nil 
		-- 	local confId = dropData[2] 
		--     if dropData[1] == 6 then -- props	    	
		--     	dropName = AllConfig.item[confId].item_name
		--     end
		--   local drop_count = dropItem.drop_count *dropData[3]
		-- 	local drop_rate = dropItem.rate
	 --    local itemInfo = {itype = dropData[1], count=drop_count, rate=drop_rate, configId=confId, name=dropName}
	 --    table.insert(self._dropInfo, itemInfo)
		-- end
  -- end
end
	
function Card:getDismantleInfo()
	if self._dropInfo == nil then 
		self._dropInfo = {}
	end

	local tbl = {}
	-- for k, v in pairs(self._dropInfo) do 
	-- 	table.insert(tbl, v)
	-- end 

	-- --根据等级获取掉落的士兵卡包
	-- local index = self:getGrade()*1000 + self:getLevel()
	-- local dropIdArr = AllConfig.cardlevelupexp[index].drop

	-- for i=1, table.getn(dropIdArr) do 
	-- 	local dropItem = AllConfig.drop[dropIdArr[i]]
	--   for k, v in pairs(dropItem.drop_data) do 
	-- 		local dropData = v.array

	-- 		local props_iconId = nil 
	-- 		local confId = dropData[2] 
	-- 	    local drop_count = dropItem.drop_count * dropData[3]
	-- 		local drop_rate = dropItem.rate
	--     local itemInfo = {itype = dropData[1], count=drop_count, rate=drop_rate, configId=confId, name=nil}
	--     table.insert(tbl, itemInfo)
	-- 	end
	-- end 
	
	return tbl
end 

function Card:getExpByLeve(level)
	local levelupExp = AllConfig.cardlevelupexp[level].exp
	local totalExp = AllConfig.cardlevelupexp[level].total_exp

	echo("Card:getExpByLeve:",level, levelupExp,totalExp)
	return levelupExp,totalExp
end


function Card:getExpPercentByLeve(level, exp)
  local percent = 100
  if level < self:getMaxLevel() then 
    local nexlevel_exp,nexlevel_totalExp = self:getExpByLeve(level+1)
    percent = 100*(1.0 - (nexlevel_totalExp-exp)/nexlevel_exp)
  end

  return percent
end

function Card:setWorkState(workState)
	self._cardWorkState = workState
end

function Card:getWorkState()
	return self._cardWorkState
end

function Card:getCradIsWorkState()
	if self._cardWorkState == nil or self._cardWorkState == "MINE_NONE" then
		return false
	else
		return true
	end
end

function Card:setIsExpCard(isExpCard)
	self._isExpCard = false 

	if isExpCard > 0 then 
		self._isExpCard = true
	end 
end

function Card:getIsExpCard()
	return self._isExpCard
end

function Card:setSurmountFlag(flag)
	self._surmountFlag = flag
end

function Card:getSurmountFlag()
	return self._surmountFlag
end

function Card:setCardSoulCost(val)
	self._cardSoulCost = val
end 

function Card:getCardSoulCost()
	return self._cardSoulCost or 0 
end 

function Card:setCardSoulGainType(currencyType)
	self._cardSoulGainType = currencyType 
end 

function Card:getCardSoulGainType()
	return self._cardSoulGainType 
end 

function Card:setCardSoulGain(val)
	self._cardSoulGain = val
end 

function Card:getCardSoulGain()
	return self._cardSoulGain or 0 
end 

function Card:setImproveGrade(grade)
	self._improveGrade = grade
end 

function Card:getImproveGrade()
	return self._improveGrade or 0
end 

--武将替换分组: 
-- 0——不参与活动
-- 1——元宝/付费武将
-- 2——公会、竞技场、通天塔兑换的5星武将
-- 3——抽卡、副本、炼魂商店的5星武将
function Card:setGroupIndex(index)
  self._groupIndex = index 
end 

function Card:getGroupIndex()
  return self._groupIndex or 0  
end 

return Card