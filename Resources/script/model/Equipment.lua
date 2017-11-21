require("model.Item")

EquipmentCfgData = class("EquipmentCfgData",{Instance = Object.getInstance})

--[[ 
	属性类型定义
	1	  武力	固定值
	2	  智力	固定值
	3	  统帅	固定值
	4	  生命	固定值
	5	  攻击	固定值
	6	  武力	百分比
	7	  智力	百分比
	8	  统帅	百分比
	9	  生命	百分比
	10	攻击	百分比
	11	命中	百分比
	12	闪避	百分比
	13	暴击	百分比
	14	韧性	百分比
	15	格挡	百分比
	16	破击	百分比
	17	攻击时伤害增加	百分比
	18  伤害减免	百分比
	19	反伤(固定值)	百分比
	20	反伤(承受伤害百分比)	百分比
	21	吸血(固定值)	百分比
	22	吸血(造成伤害百分比)	百分比
	23	吸血(自身生命上限百分比)	百分比
	24	暴击伤害增加	百分比
	25	承受暴击伤害降低	百分比
	26  治疗加强 固定值
	27  治疗加强 百分比
	28  施加混乱成功率
	29  伤害追加 固定值
	30  最终伤害加成 百分比
	31  对魏国阵营造成伤害追加 百分比
	32  对蜀国阵营造成伤害追加 百分比
	33  对吴国阵营造成伤害追加 百分比
	34  对群雄阵营造成伤害追加 百分比
	35  受到治疗效果增强 固定值
	36  受到治疗效果增强 百分比
	37  普通攻击后双倍怒气增加 百分比
	38  二段伤害对潮湿状态伤害加成 百分比
	39  地形对攻击效果加成 百分比
	40  对被克兵种伤害加成 百分比
	41 	承受技能伤害降低	百分比
	42  主将死亡时有一定概率不会清空全军怒气 百分比
--]]


function EquipmentCfgData:ctor()
	local ret={}
	for n,v in pairs(AllConfig.xilian) do
		ret[v.equip_rank] = ret[v.equip_rank] or {}
		local row = ret[v.equip_rank]
		row[v.quality] = v
	end
	AllConfig.XiLianData = ret
end

function EquipmentCfgData:GetXiLianConfig()
	return AllConfig.XiLianData
end

Equipment = class("Equipment",Item)
local _equipment_gradename = {[1]="通品",[2]="上品",[3]="精品",[4]="绝品",[5]="圣品"}

function Equipment:ctor()
	Equipment.super.ctor(self)
	self:setLevel(1)
  self:resetProperties()
end

function Equipment:resetProperties()
  self:setProperties(nil)
  local properties = {}
  for i = 1, kMaxProperties do
    properties[i] = 0
  end
  self:setProperties(properties)
end

------
--  Getter & Setter for
--      Equipment._Properties 
-----
function Equipment:setProperties(Properties)
	self._Properties = Properties
end

function Equipment:getProperties()
	return self._Properties
end

function Equipment:getPropertyByType(type)
  return self._Properties[type]
end

------
--  Getter & Setter for
--      Equipment._ConfigId 
-----
function Equipment:setConfigId(ConfigId)
	self._ConfigId = ConfigId
	
	local configId = self._ConfigId
	local equipmentStatic = AllConfig.equipment[configId]
	self:setName(equipmentStatic.name)
	self:setCardName(equipmentStatic.card_name)
	--self:setThumbnailTextureName("playstates-button-wuqi.png")
	self:setEquipType(equipmentStatic.equip_type)
	self:setGrade(equipmentStatic.equip_rank+1)
	self:setMaxGrade(equipmentStatic.equip_rank+1)
	self:setCurrencyType(equipmentStatic.currency_type)
	self:setSalePrice(equipmentStatic.sell_price)
	self:setIconId(equipmentStatic.equip_icon)
	self:setQuality(equipmentStatic.quality)
	self:setMaxExperience(equipmentStatic.total_need_exp)
	assert(equipmentStatic.total_need_exp)
	self:setNextLevelID(equipmentStatic.upgrade_equip_id)
	self:setSmeltDataArray(equipmentStatic.smelt_data)
	self:setCanSmelt(equipmentStatic.can_smelt)
	self:setRootId(equipmentStatic.equip_root)
	
	self:setBaseAttr(equipmentStatic.base_attr)
	self:setImproveAttr(equipmentStatic.improve_attr)
	
	
	-- local baseProp = equipmentStatic.base_prop
	-- local propGroup = AllConfig.propgroup[baseProp].prop_id
	-- self._descArr = {}
	-- for i = 1,table.getn(propGroup) do
	-- 	local propArr = propGroup[i].array
	-- 	for j = 1,table.getn(propArr) do
	-- 		local type = AllConfig.prop[propGroup[i].array[1]].type
	-- 		local desc = AllConfig.prop[propGroup[i].array[1]].desc
	-- 		table.insert(self._descArr,desc)
	-- 	end
	-- end
	local random_prop = equipmentStatic.random_prop
	if(random_prop>0) then
		self._RandomPropGroup = AllConfig.propgroup[random_prop].prop_id
	else
		self._RandomPropGroup ={}
	end
	local base_prop = equipmentStatic.base_prop
	if(base_prop>0) then
		self._BasePropGroup = AllConfig.propgroup[base_prop].prop_id
	else
		self._BasePropGroup ={}
	end
end

function Equipment:setCardName(n)
	self._card_name = n
end

function Equipment:getCardName()
	return self._card_name
end

function Equipment:getXiLianConfig()
	return EquipmentCfgData:Instance():GetXiLianConfig()[self:getGrade()-1][self:getQuality()]
end

function Equipment:getConfigId()
	return self._ConfigId
end

function Equipment:update(equipment)
	local configId = equipment.config_id
	self:setConfigId(configId)
	self:setId(equipment.id)
	self:resetProperties()

	self:setCurrentCardID(equipment.card_id)
	self:setExperience(equipment.exp)
	self:setSkillAttr(equipment.skill)
	assert(equipment.level >= 1,"Equipment level must > 1")
	self:setLevel(equipment.level)
end

function Equipment:setCard(card)
	self._card = card
end

function Equipment:getCard()
	return self._card
end


function Equipment:hasCard()
	local hasCard = false
	if self:getCard() ~= nil then
		hasCard = true
	end
	return hasCard
end

function Equipment:setDescArray(desc)
	self._descArr = desc
end

function Equipment:getDescArray()
	return self._descArr
end

function Equipment:setIconId(id)
	self._iconId = id
end

function Equipment:getIconId()
	return self._iconId
end

function Equipment:setCurrencyType(type)
	--type: 1 coin; 2 money
	self._currencyType = type
end 

function Equipment:getCurrencyType()
	return self._currencyType
end 

function Equipment:setEquipType(type)
	self._equipType = type
end 

function Equipment:getEquipType()
	return self._equipType
end

function Equipment:setSkillAttr(skillAttr)
	local skillAttr_Configed={
		Replaced={},
		AllUsefull={},
		ByID={}
	}
	self.skillAttr_Configed = skillAttr_Configed

	if skillAttr == nil then 
		return 
	end
	--update attr 兼容
	local attr_fix = 0
	local attr_per = 0
	local int_fix = 0
	local int_per = 0
	local dom_fix = 0
	local dom_per = 0
	local hp_fix = 0
	local hp_per = 0
	local atk_fix = 0
	local atk_per = 0

	for k,v in pairs(skillAttr) do 
		assert(v.state == "Normal" or v.state=="BeReplaced" or v.state =="Replaced" , "")
		if(v.state == "Normal" or v.state=="BeReplaced") then
			table.insert(skillAttr_Configed.AllUsefull,v)
		else
			table.insert(skillAttr_Configed[v.state],v)
		end

		skillAttr_Configed.ByID[v.skill_id]= skillAttr_Configed.ByID[v.skill_id] or {}
		skillAttr_Configed.ByID[v.skill_id][v.state]=v

		if v.state ~= "Replaced" then	--new property not on equipment
			if v.type == k_property_str_fix then   -- strength
				attr_fix = attr_fix + v.data
			elseif v.type == k_property_str_per then 
				attr_per = attr_per + v.data
			elseif v.type == k_property_int_fix then  --intelligence
				int_fix = int_fix + v.data
			elseif v.type == k_property_int_per then
				int_per = int_per + v.data

			elseif v.type == k_property_dom_fix then --dom
				dom_fix = dom_fix + v.data
			elseif v.type == k_property_dom_per then
				dom_per = dom_per + v.data

			elseif v.type == k_property_hp_fix then --hp
				hp_fix = hp_fix + v.data
			elseif v.type == k_property_hp_per then
				hp_per = hp_per + v.data

			elseif v.type == k_property_atk_fix then --atk
				atk_fix = atk_fix + v.data
			elseif v.type == k_property_atk_per then
				atk_per = atk_per + v.data
			end
		end 
    self._Properties[v.type] = self._Properties[v.type] + v.data
	end

	self:setExtStrength(attr_fix, attr_per/10000)
	self:setExtIntelligence(int_fix, int_per/10000)
	self:setExtDominance(dom_fix, dom_per/10000)
	self:setExpHp(hp_fix, hp_per/10000)
	self:setExtAttack(atk_fix, atk_per/10000)
end

function Equipment:getSkillAttr()

	if (self.skillAttr_Configed == nil) then
		self:setSkillAttr(nil)
	end
	return self.skillAttr_Configed.AllUsefull
end

function Equipment:getSkillReplaced()
	if (self.skillAttr_Configed == nil) then
		self:setSkillAttr(nil)
	end
	return self.skillAttr_Configed.Replaced
end

function Equipment:createSkillAttrExtByType(_type,id,data,generate_type,hasChoose)
	local staticItem = AllConfig.proptype[_type]
	local propitem= nil
	
	generate_type = generate_type == "Base" and  1 or 2
  local comgroup = generate_type == 1 and self._BasePropGroup or self._RandomPropGroup
	
	if generate_type == 2 then
    local configId = self:getConfigId()
    local refrehRandomProp = AllConfig.equipment[configId].xilian_prop
    if refrehRandomProp > 0 then
     assert(AllConfig.propgroup[refrehRandomProp] ~= nil,"config error: AllConfig.propgroup["..refrehRandomProp.."]")
     comgroup = AllConfig.propgroup[refrehRandomProp].prop_id
     for n,v in ipairs(comgroup) do
      local propid = v.array[1]
      local item = AllConfig.prop[propid]
      if item.type==_type then
        propitem = item
        break
      end
     end
    end
  end
	
	if propitem == nil then
    for n,v in ipairs(comgroup) do
      local propid = v.array[1]
      local item = AllConfig.prop[propid]
      if item.type==_type then
        propitem = item
        break
      end
    end
	end

	assert(staticItem,"config error")
	return {
			id = id,
			genType = generate_type,
			name = staticItem.name,
			attrIconId = staticItem.imageid,
			data = string.format(staticItem.showformat,data/staticItem.rate),
			eType = _type,
			propItem = propitem and Object.Extend(propitem,{min = string.format(staticItem.showformat1,propitem.min/staticItem.rate),max = string.format(staticItem.showformat1,propitem.max/staticItem.rate)}) or nil,
			hasChoose = hasChoose
		}
end

function Equipment:getSkillAttrExt(withChoose)
	local attrTable = {}
	local skillAttrs = self:getSkillAttr()
	local newattr = nil
	
	if(withChoose) then
		local count
		newattr,count = self:buildNewAttributeMap()
		if(count==0) then
			newattr=nil
		end
	end
	for k, v in pairs(skillAttrs) do 
		table.insert(attrTable,self:createSkillAttrExtByType(v.type,v.skill_id,v.data,v.generate_type, newattr and not newattr[v.skill_id] or false ))
	end

	return attrTable
end

function Equipment:buildCurrentAttributeMap()
	local attrTable = {}
	local skillAttrs = self:getSkillAttr()

	local count=0
	for k, v in pairs(skillAttrs) do 
		attrTable[v.skill_id] = self:createSkillAttrExtByType(v.type,v.skill_id,v.data,v.generate_type)
		count=count+1
	end

	return attrTable,count
end

function Equipment:buildNewAttributeMap()
	local attrTable = {}
	local skillAttrs = self:getSkillReplaced()
	local count=0
	for k, v in pairs(skillAttrs) do
		attrTable[v.skill_id] = self:createSkillAttrExtByType(v.type,v.skill_id,v.data,v.generate_type)
		count=count+1
	end

	return attrTable,count
end

function Equipment:setExtStrength(str_fix, str_per)
	self._str_fix = str_fix
	self._str_per = str_per
end

function Equipment:getExtStrength()
	return self._str_fix, self._str_per
end

function Equipment:setExtIntelligence(int_fix, int_per)
	self._int_fix = int_fix
	self._int_per = int_per
end

function Equipment:getExtIntelligence()
	return self._int_fix, self._int_per
end

function Equipment:setExtDominance(dom_fix, dom_per)
	self._dom_fix = dom_fix
	self._dom_per = dom_per
end

function Equipment:getExtDominance()
	return self._dom_fix, self._dom_per
end

function Equipment:setExpHp(hp_fix, hp_per)
	self._hp_fix = hp_fix
	self._hp_per = hp_per
end

function Equipment:getExpHp()
	return self._hp_fix, self._hp_per
end

function Equipment:setExtAttack(atk_fix, atk_per)
	self._atk_fix = atk_fix
	self._atk_per = atk_per
end

function Equipment:getExtAttack()
	return self._atk_fix, self._atk_per
end

function Equipment:setQuality(qualityLevel)
	self._quality = qualityLevel
end 

function Equipment:getQuality()
	return self._quality
end

function Equipment:getExperience()
	return self._experience 
end 

function Equipment:setExperience(experience)
	self._experience = experience
end 
 
function Equipment:getMaxExperience()
	return self._max_experience 
end 

function Equipment:setMaxExperience(max_experience)
	self._max_experience = max_experience
end 

function Equipment:getNextLevelID()
	return self._next_level 
end 

function Equipment:setNextLevelID(next_level)
	self._next_level = next_level
end

function Equipment:getSmeltDataArray()
	return self._smelt_data
end 

function Equipment:setSmeltDataArray(dataArray)
	self._smelt_data = dataArray
end

function Equipment:getCanSmelt()
	return self._can_smelt
end 

function Equipment:setCanSmelt(canSmelt)
	self._can_smelt = canSmelt
end

function Equipment:getCurrentCardID()
	return self._card_id
end 

function Equipment:setCurrentCardID(card_id)
	self._card_id = card_id
end

function Equipment:hasPutOn()
	return  self._card_id~=0
end

function Equipment:setRootId(id)
	self._rootId = id 
end 

function Equipment:getRootId()
	return self._rootId
end 

function Equipment:getExpPercentByLeve(exp)
	local percent = 100
	if self:getExperience() < self:getMaxExperience() then
	local nextlevel_exp = exp+self:getExperience()
	percent = nextlevel_exp >self:getMaxExperience() and 100 or toint(nextlevel_exp/self:getMaxExperience() *100)
	end

	echo("---Skill:getExpPercentByLeve:current,add exp,percent=", self:getExperience(), exp,percent)
	return percent
end

function Equipment.QualityNameImg(level,islarge)
	return "#quality"..level.. (islarge and  "_L" or "") ..".png","client/widget/quality/quality"..(islarge and  "_L" or "")
end

function Equipment:getQualityNameImg(islarge)
	local level = self:getQuality()
	assert(level>0 and level<=5,"config error")
	return  self.QualityNameImg(level,islarge)
end 

function Equipment:getNextQualityNameImg(islarge)
	local level = self:getQuality()+1
	assert(level > 0 and level <= 5,"config error")
	return  self.QualityNameImg(level,islarge)
end

function Equipment:getQualityName()
	local ret = _equipment_gradename[self:getQuality()]
	assert(ret,"config error")
	return ret
end 

function Equipment:getNextQualityName()
	local ret = _equipment_gradename[self:getQuality()+1]
	return ret
end

function Equipment:getRequiredExperenceForNextQuality()
	return self:getMaxExperience()-self:getExperience()
end

function Equipment:getDismantleInfo()
	if self._dropInfo == nil then 
		self._dropInfo = {}
	end

	local tbl = {}
	for k, v in pairs(self._dropInfo) do 
		table.insert(tbl, v)
	end 

  	local dropIdArr = self:getSmeltDataArray()

  	for i = 1, table.getn(dropIdArr) do 
  		local dropItem = AllConfig.drop[dropIdArr[i]]
		assert(dropItem,"config error: AllConfig.drop[idx] not found")
		for k, v in pairs(dropItem.drop_data) do 
			local dropData = v.array
			local props_iconId = nil 
			local confId = nil 
			if dropData[1] == 6 then -- props
		    	confId = dropData[2] 
		    	props_iconId = AllConfig.item[confId].item_resource
			end
			local drop_count = dropItem.drop_count * dropData[3]
			local drop_rate = dropItem.rate

			local itemInfo = {count=drop_count, rate=drop_rate, configId=confId, iconId=props_iconId, name=nil}
			table.insert(tbl, itemInfo)
		end
  	end 

	return tbl

end 

function Equipment.CanOpenCheck(n)
	local model = {Consts.Strings.HIT_EQUIPMENT_TIEJIANGPU,Consts.Strings.HIT_EQUIPMENT_DUANZAO,Consts.Strings.HIT_EQUIPMENT_CHONGZHU,Consts.Strings.HIT_EQUIPMENT_FENGJIE,Consts.Strings.HIT_EQUIPMENT_XILIAN}

	local level = GameData:Instance():getCurrentPlayer():getLevel()
	n = n and n+1 or 1
	local id = 22+ (n>1 and n-1 or n)
	local reqLevel = AllConfig.systemopen[id].type_value
	local ret = level >= reqLevel
	return  ret, ret and "" or string.format(Consts.Strings.HIT_OPEN_FEATURE,reqLevel,string._tran(model[n]))
end

function Equipment:getAttrValueArray()
	local valArray = {}
	for _type=1, 100 do 
		valArray[_type] = 0 
	end 

	local skillAttrs = self:getSkillAttr()
	for k, v in pairs(skillAttrs) do 
		valArray[v.type] = valArray[v.type] + v.data
	end 

	return valArray
end 

function Equipment:getBaseAttr()
	local name = ""
	local val = 0 	
	local skillAttrs = self:getSkillAttr()
	for k, v in pairs(skillAttrs) do 
		if v.generate_type == "Base" then 
			name = AllConfig.proptype[v.type]
			val = v.data
			break 
		end 	
	end 

	return name, val 
end 


--new add
------
--  Getter & Setter for
--      Equipment._Level 
-----
function Equipment:setLevel(Level)
  self._Level = Level
end

function Equipment:getLevel()
  return self._Level
end

------
--  Getter & Setter for
--      Equipment._BaseAttr 
-----
function Equipment:setBaseAttr(BaseAttr)
  self._BaseAttr = BaseAttr
end

function Equipment:getBaseAttr()
  return self._BaseAttr
end

------
--  Getter & Setter for
--      Equipment._ImproveAttr 
-----
function Equipment:setImproveAttr(ImproveAttr)
	self._ImproveAttr = ImproveAttr
end

function Equipment:getImproveAttr()
	return self._ImproveAttr
end

return Equipment