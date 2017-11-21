require("model.Weapon")
require("model.Accessory")
require("model.Armor")
require("model.shop.ShopItem")
require("model.Props")
require("model.Mall")
require("model.battle.BattleFormation")

Package = class("Package")

function CreatEnumTable(tbl, index)

		local enumtbl = {}
		local enumindex = index or 0
		for i, v in ipairs(tbl) do
				enumtbl[v] = enumindex + i
		end
		return enumtbl
end

EnumTable =
{
		"emItemFile",
		"emEquipFile",
		"emUintFile"  ,
}
EnumTable = CreatEnumTable(EnumTable, 5)

function Package:ctor()

	math.randomseed(os.time())
	local weaponArray = {}
	local accessoryArray = {}
	local armorArray = {}
	local cardArray = {}
	self:setAllCards(cardArray)
	self:setAllWeapons(weaponArray)
	self:setAllAccessories(accessoryArray)
	self:setAllArmors(armorArray)
end


function Package:initMarketSalses(pbMsg)
	local marketSalesArray ={}
	local soulMarketSales = {}
	print("=== Package:initMarketSalses")

	local isFress = Mall:Instance():isUseMoneyOrVIPRefreshMarket()
	if isFress == false and (Clock:Instance():getCurServerUtcTime() - pbMsg.last_refresh_time) < 10 then
		Mall:Instance():setHasNewTip(true)
	end
	Mall:Instance():setUseMoneyOrVIPRefreshMarket(false) -- reset free flag

	GameData:Instance():setLastRefreshTime(pbMsg.last_refresh_time)
	GameData:Instance():setLastRefreshTimeForSoul(pbMsg.last_jianghun_refresh_time)

	for i =1,table.getn(pbMsg.information)  do
		local marketSales = ShopItem.new()
		marketSales:setId(pbMsg.information[i].id)
		local itemId =  pbMsg.information[i].config_id
		local tableType = pbMsg.information[i].type
		marketSales:setObjectType(tableType)

		if tableType == EnumTable.emItemFile then
			if AllConfig.item[itemId] ~= nil then
				marketSales:setName(AllConfig.item[itemId].item_name)
				marketSales:setDesc(AllConfig.item[itemId].item_desc)
				marketSales:setIconId(AllConfig.item[itemId].item_resource)
			end

		elseif tableType == EnumTable.emEquipFile then
			marketSales:setName(AllConfig.equipment[itemId].name)
			marketSales:setDesc(AllConfig.equipment[itemId].description)
			marketSales:setIconId(AllConfig.equipment[itemId].equip_icon)  -- 装备暂时没有 资源ID

		elseif tableType == EnumTable.emUintFile then
			marketSales:setName(AllConfig.unit[itemId].unit_name)
			marketSales:setDesc(AllConfig.unit[itemId].description)
			marketSales:setIconId(AllConfig.unit[itemId].unit_head_pic)
		end

		marketSales:setConfigId(itemId)
		--marketSales:setThumbnailTextureName("playstates-button-wuqi.png")
		marketSales:setIsDiscount(true)
		marketSales:setPrice(pbMsg.information[i].base_price)
		marketSales:setCurrencyType(pbMsg.information[i].base_currency_type)
		marketSales:setRealCurrencyType(pbMsg.information[i].currency_type)
		marketSales:setDiscountPrice(pbMsg.information[i].price)
		marketSales:setItemCount(pbMsg.information[i].count)
		marketSales:setBuyTimes(pbMsg.information[i].used_buy_times)

		if pbMsg.information[i].market_type == "NORMAL_MARKET" then 
			table.insert(marketSalesArray, marketSales)
		elseif pbMsg.information[i].market_type == "JIANGHUN_MARKET" then 
			table.insert(soulMarketSales, marketSales)
		else 
			echo("=== invalid market item")
		end 
	end

	self:setAllSales(marketSalesArray)
	self:setSoulMarketSales(soulMarketSales)
end

function Package:insertEquipItems(equipItem)
		local idx = equipItem.config_id
	 -- echo("insertEquipItems", idx)
		GameData:Instance():getCurrentPlayer():getIllustratedInstance():insertEquipmentToIllustrated(equipItem.config_id)
		
		local cardToEquipment = nil
		--echo("EquipmentINFO:",equipItem.skill[1].type)
	 -- echo("EquipmentINFO:",equipItem.id,equipItem.card_id)

		if  AllConfig.equipment[idx].equip_type == 1 then -- weapon
		 -- echo("weapon:",equipItem.id,equipItem.card_id)
			local weapon = Weapon.new()
			weapon:update(equipItem)
			
			if equipItem.card_id ~= 0 then
					cardToEquipment = self:getCardById(equipItem.card_id)
					if cardToEquipment ~= nil then 
						cardToEquipment:setWeapon(weapon)
						weapon:setCard(cardToEquipment)
					end
			else
				--table.insert(self._idleEquipmentsArray,weapon)
			end
			
			table.insert(self._allEquipmentsArray,weapon)

		elseif AllConfig.equipment[idx].equip_type == 2 then -- armor
			local armor = Armor.new()
			armor:update(equipItem)
		 
			if equipItem.card_id ~= 0 then
				cardToEquipment = self:getCardById(equipItem.card_id)
				if cardToEquipment ~= nil then 
					cardToEquipment:setArmor(armor)
					armor:setCard(cardToEquipment)
				end
			else
				--table.insert(self._idleEquipmentsArray,armor)
			end
		 
			table.insert(self._allEquipmentsArray,armor)
			--printf("armor")
		elseif AllConfig.equipment[idx].equip_type == 3 then --accessory
			local accessory = Accessory.new()
			accessory:update(equipItem)
			
			if equipItem.card_id ~= 0 then
				cardToEquipment = self:getCardById(equipItem.card_id)
				if cardToEquipment ~= nil then 
					cardToEquipment:setAccessory(accessory)
					accessory:setCard(cardToEquipment)
				end
			else
				--table.insert(self._idleEquipmentsArray,accessory)
			end
			
			table.insert(self._allEquipmentsArray,accessory)
			--printf("accessory")
		end
		
		self:sortEquipmentType()
end

function Package:sortEquipmentType()
		self._weaponArray = {}
		self._armorArray = {}
		self._accessoryArray = {}
		for key, equipment in pairs(self._allEquipmentsArray) do
			if equipment:getEquipType() == 1 then
				 table.insert(self._weaponArray,equipment)
			elseif equipment:getEquipType() == 2 then
				 table.insert(self._armorArray,equipment)
			elseif equipment:getEquipType() == 3 then
				 table.insert(self._accessoryArray,equipment)
			else
				 
			end
		end
end


function Package:updateEquip(equipItem)
	 --equipItem.card_id
	 print("update equipment:",equipItem.id,equipItem.card_id)
	 for key, equipment in pairs(self._allEquipmentsArray) do
	 		-- print("equ name", equipment:getName(), equipment:getId(), equipItem.id, equipItem.card_id)
			if equipment:getId() == equipItem.id then
				equipment:update(equipItem)
				equipment:setCard(nil)

				if equipItem.card_id == 0 then
					 equipment:setCard(nil)
				else
					 equipment:setCard(self:getCardById(equipItem.card_id))
				end
				break
			end
	 end
	 self:sortEquipmentType()
end

function Package:removeEquip(id)
	for k, v in pairs(self._allEquipmentsArray) do 
		if v:getId() == id then
		 -- echo("remove equip: id="..id)
			table.remove(self._allEquipmentsArray, k)
			break
		end
	end
	
	self:sortEquipmentType()
end

function Package:insertCard(cardInfo,position)
	local card = Card.new()
	card:update(cardInfo)
	if position~= nil then
	 card:setPlayStagesPosition(position) --for local
	end
	card:setIntegrityTextureName("shop_card_tu.png")
	table.insert(self._allCardArray, card)
end

function Package:removeCard(id)
	for k, v in pairs(self._allCardArray) do 
		if v:getId() == id then 
			--echo("removeCard: id="..id)
			table.remove(self._allCardArray, k)
			break
		end
	end
end

function Package:updateCardAttr(cardInfo)
	local card = self:getCardById(cardInfo.id)
	assert(card ~= nil, "invaild card:"..cardInfo.id)
	card:update(cardInfo)
end


function Package:update(msgId,pbMsg)
	echo("================ Package:update")

	self._allEquipmentsArray = {}
	self._idleEquipmentsArray = {}
	self._weaponArray = {}
	self._accessoryArray = {}
	self._armorArray = {}

	--card
	self._allCardArray = {}
	for i = 1,table.getn(pbMsg.card.card) do
		self:insertCard(pbMsg.card.card[i],i)
	end

	--equip
	local equipmentNum = table.getn(pbMsg.equipment.equipment)
	for j = 1,equipmentNum do
		local equipItem = pbMsg.equipment.equipment[j]
		self:insertEquipItems(equipItem)
	end

	--props
	self._propsArray = {}
	self._mergePropsArray = {}

	if pbMsg.item ~= nil and pbMsg.item.item ~= nil then 
		for k,v in pairs(pbMsg.item.item) do
			if AllConfig.item[v.type_id] ~= nil then
				local props = Props.new(v.id, v.type_id, v.count)
				table.insert(self._propsArray, props)
			end
		end
	end
	
	--init avatar
	--print(GameData:Instance():getCurrentPlayer():getAvatar())
	if GameData:Instance():getCurrentPlayer():getAvatar() <= 1 then
		 --assert(false)
		 if #self._allCardArray > 0 then
			 local uintRootId = self._allCardArray[1]:getUnitRoot()
			 GameData:Instance():getCurrentPlayer():setAvatar(uintRootId)
			 local data = PbRegist.pack(PbMsgId.ChangeAvatar,{avatar_id = uintRootId})
			 net.sendMessage(PbMsgId.ChangeAvatar,data)
		 end
	end
end

------
--  Getter & Setter for
--      Package._allEquipmentsArray 
-----
function Package:setAllEquipments(allEquipmentsArray)
	self._allEquipmentsArray = allEquipmentsArray
end

function Package:getAllEquipments()
	if self._allEquipmentsArray == nil then 
		self._allEquipmentsArray = {}
	end
	return self._allEquipmentsArray
end

--------
----  Getter & Setter for
----      Package._idleEquipmentsArray 
-------
--function Package:setIdleEquipments(idleEquipment)
--  self._idleEquipmentsArray = idleEquipment
--end

function Package:getIdleEquipments()
	self._idleEquipmentsArray = {}
	for k,v in pairs(self._allEquipmentsArray) do
		if v:getCard() == nil then
			table.insert(self._idleEquipmentsArray, v)
		end
	end
	return self._idleEquipmentsArray
end

------
--  Getter & Setter for
--      Package._weapon 
-----
function Package:setAllWeapons(weaponArray)
	self._weaponArray = weaponArray
end

function Package:getAllWeapons()
	return self._weaponArray
end

------
--  Getter & Setter for
--      Package._armorArray 
-----
function Package:setAllArmors(armorArray)
	self._armorArray = armorArray
end

function Package:getAllArmors()
	return self._armorArray
end

------
--  Getter & Setter for
--      Package._accessoryArray 
-----
function Package:setAllAccessories(accessoryArray)
	self._accessoryArray = accessoryArray
end

function Package:getAllAccessories()
	return self._accessoryArray
end

------
--  Getter & Setter for
--      Package._saleArray 
-----
function Package:setAllSales(saleArray)
	self._saleArray = saleArray
end

function Package:getAllSales()
	return self._saleArray
end

function Package:setSoulMarketSales(saleArray)
	self._soulSaleArray = saleArray
end

function Package:getSoulMarketSales()
	if self._soulSaleArray == nil then 
		self._soulSaleArray = {}
	end 
	return self._soulSaleArray
end

------
--  Getter & Setter for
--      Package._saleDiscountArray 
-----
function Package:setDiscountSales(saleArray)
	self._saleDiscountArray = saleArray
end

function Package:getDiscountSales()
	return self._saleDiscountArray
end

------
--  Getter & Setter for
--      Package._saleCollectArray
-----
function Package:setCollectSales(saleArray)
	self._saleCollectArray = saleArray
end

function Package:getCollectSales()
	return self._saleCollectArray
end

------
--  Getter & Setter for
--      Package._allCard 
-----
function Package:setAllCards(allCardArray)
	self._allCardArray = allCardArray
	self:sortingCards()
end

function Package:getAllCards()
	return self._allCardArray
end

-- if card is exis ,update, else add it
function Package:updateCard(card)
	local length = table.getn(self._allCardArray)
	local currentId = nil
	for i = 1, length do
		currentId = self._allCardArray[i]:getId()
		if currentId == card:getId() then
			self._allCardArray[i] = card
			break
		end
	end
	self:sortingCards()
end

function Package:getCardById(cardId)
	local length = table.getn(self._allCardArray)
	local currentId = nil
	local targetCard = nil
	
	for i = 1, length do
		currentId = self._allCardArray[i]:getId()
		if currentId == cardId then
			targetCard = self._allCardArray[i]
			break
		end
	end
	
	return targetCard
end

function Package:updateAllCards(allCardArray)
	self:setAllCards(allCardArray)
end

function Package:sortingCards()
  local currentAtkBattleFormationIdx = BattleFormation:Instance():getCurrentAttackBattleFormationIdx()
  local cardsFormation = BattleFormation:Instance():getCardsFormationByBattleIndex(currentAtkBattleFormationIdx)
  
  for key, card in pairs(self._allCardArray) do
    card:setIsOnBattle(false)
    card:setIsBoss(false)
    card:setPosition(0)
    for key, battleCardInfo in pairs(cardsFormation) do
      if battleCardInfo.card == card:getId() then
        print(battleCardInfo.card,battleCardInfo.pos,battleCardInfo.leader)
        card:setIsOnBattle(battleCardInfo.pos > 3)
        card:setIsBoss(battleCardInfo.leader > 0)
        card:setPosition(battleCardInfo.pos)
        break
      end
    end
  end
  
	local battleCardArray = {}
	local idleCardArray = {}
		for k,v in ipairs(self._allCardArray) do
		  local _,isOnAtkBattle = v:getIsOnBattle()
			if isOnAtkBattle == true then
				 -- Sort out the battle cards
				 table.insert(battleCardArray,v)
			else
				 -- Sort out the idle cards
				v:setPlayStagesPosition(0)
				if v:getCradIsWorkState() == false and v:getIsExpCard() == false then
					 table.insert(idleCardArray,v)
				end
			end
		end
   
   local function sortStatesTable(a, b)
    return a:getId() < b:getId()
   end
   table.sort(battleCardArray,sortStatesTable)
	 self:setBattleCards(battleCardArray)
	 self:setIdleCards(idleCardArray)
end

------
--  Getter & Setter for
--      Package._battleCardArray 
-----
function Package:setBattleCards(battleCardArray)
	self._battleCardArray = battleCardArray
end

function Package:getBattleCards()
	self:sortingCards()
	return self._battleCardArray
end

function Package:checkCardHasTip(Card)
  local enabledTip = false
  
  local equipTipTillLevel = 1
  local playerLevel = GameData:Instance():getCurrentPlayer():getLevel()
  
  local weaponLvUpEnabled = false
  if playerLevel < equipTipTillLevel then
    weaponLvUpEnabled = EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(Card,EquipmentReinforceConfig.EquipmentTypeWeapon) 
  end
  local weaponGradeUpEnabled = EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(Card,EquipmentReinforceConfig.EquipmentTypeWeapon) 
 
  local armorLvUpEnabled = false
  if playerLevel < equipTipTillLevel then
   armorLvUpEnabled = EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(Card,EquipmentReinforceConfig.EquipmentTypeArmor) 
  end
  local armorGradeUpEnabled = EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(Card,EquipmentReinforceConfig.EquipmentTypeArmor) 

  local accessoryLvUpEnabled = false
  if playerLevel < equipTipTillLevel then
   accessoryLvUpEnabled = EquipmentReinforce:Instance():getEquipmentsLvUpEnabled(Card,EquipmentReinforceConfig.EquipmentTypeAccessory) 
  end
  local accessoryGradeUpEnabled = EquipmentReinforce:Instance():getEquipmentsGradeUpEnabled(Card,EquipmentReinforceConfig.EquipmentTypeAccessory) 
    
  enabledTip = (Enhance:instance():isCardCanSurmounted(Card)
  or weaponLvUpEnabled == true 
  or weaponGradeUpEnabled == true
  or armorLvUpEnabled == true
  or armorGradeUpEnabled == true
  or accessoryLvUpEnabled == true 
  or accessoryGradeUpEnabled == true
  or (Card:getEnabledLevelUp() == true and GameData:Instance():getCurrentPlayer():getLevel() - Card:getLevel() >= 10)
  )
  
  if GameData:Instance():getLanguageType() == LanguageType.JPN then 
    enabledTip = Enhance:instance():isCardCanSurmounted(Card)
  end
  
 
 return enabledTip
end

function Package:getBattleCardsByPlaystagesPos()
	local battleCards =  self:getBattleCards()
	local function sortStatesTable(a, b)
		if a:getIsBoss() == true then
				return true
		elseif a:getIsBoss() == true and b:getIsBoss() == false then
				return true
		elseif a:getIsBoss() == false and b:getIsBoss() == true then
				return false
		elseif  a:getIsBoss() == false and b:getIsBoss() == false then
				return a:getPlayStagesPosition() < b:getPlayStagesPosition()
		else
				return a:getId() < b:getId()
		end
	end
	table.sort(battleCards, sortStatesTable)
	
	local idx = 1
	for key, card in pairs(battleCards) do
		card:setPlayStagesPosition(idx)
		idx = idx + 1
	end
	return battleCards
end

------
--  Getter & Setter for
--      Package._idleCardArray 
-----
function Package:setIdleCards(idleCardArray)
	self._idleCardArray = idleCardArray
end

function Package:getIdleCards()
	-- self:sortingCards()
	if self._idleCardArray ~= nil then 
		local len = #self._idleCardArray
		if len > 1 then 
			self:sortCards(self._idleCardArray,nil, SortType.RARE_DOWN)
		end
	end 

	return self._idleCardArray
end

function Package:getIdleCardsExt(exceptCardId)
	local allCards = self:getAllCards()
	local tbl = {}
	if allCards ~= nil then 
		for k, v in pairs(allCards) do 
		  local isOnCurAtkBattle,isOnAnyBattle,battleFormationIdxs = v:getIsOnBattle()
			if isOnAnyBattle == false and (v:getCradIsWorkState() == false) then
				if v:getId() ~= exceptCardId then 
					table.insert(tbl, v)
				end
			end
		end
	end
	return tbl
end

---------------------------------------- 卡牌/装备 -------------------------------------
SortType = enum({"DEFAULT", "RARE_DOWN", "RARE_UP", "LEVEL_UP","LEVEL_DOWN"})
function Package:sortItems(itemsTbl, startIdx, endIdx, sortType)

	if endIdx <= startIdx+1 then
		return
	end

	for i=startIdx, endIdx-1 do
		local k = i
		for j=i+1, endIdx do 
			if sortType == SortType.RARE_DOWN then
				if itemsTbl[k]:getMaxGrade() < itemsTbl[j]:getMaxGrade() then
					k = j
				end
			elseif sortType == SortType.RARE_UP or sortType == SortType.DEFAULT then
				if itemsTbl[k]:getMaxGrade() > itemsTbl[j]:getMaxGrade() then
					k = j
				end
			elseif sortType == SortType.LEVEL_UP then
				if itemsTbl[k]:getLevel() < itemsTbl[j]:getLevel() then
					k = j
				end
			elseif sortType == SortType.LEVEL_DOWN then
				if itemsTbl[k]:getLevel() > itemsTbl[j]:getLevel() then
					k = j
				end
			else 
				echo("Package:sortItems() --- invalid sort type !!! ", sortType)
			end
		end  

		if k > i then
			local tmp = itemsTbl[k]
			itemsTbl[k] = itemsTbl[i]
			itemsTbl[i] = tmp
		end
	end
end


function Package:sortCardByType(itemsTbl, startIdx, endIdx, rareType, levelType)
	local preType = nil 
	local curType = nil 
	local idx = nil 

	if endIdx <= startIdx+1 then
		return
	end

	if rareType == nil then 
		rareType = SortType.RARE_UP
	end

	if levelType == nil then 
		levelType = SortType.LEVEL_DOWN
	end 

	--1. sort by max rare
	for i=startIdx, endIdx-1 do
		local k = i
		for j=i+1, endIdx do 
			if rareType == SortType.RARE_DOWN then
				if itemsTbl[k]:getMaxGrade() < itemsTbl[j]:getMaxGrade() then
					k = j
				end
			else 
				if itemsTbl[k]:getMaxGrade() > itemsTbl[j]:getMaxGrade() then
					k = j
				end
			end
		end  

		if k > i then
			local tmp = itemsTbl[k]
			itemsTbl[k] = itemsTbl[i]
			itemsTbl[i] = tmp
		end
	end

	--2. sort by same root
	local function sortByRoot(tbl, idx_s, idx_e)
		if idx_e <= idx_s+1 then 
			return 
		end 

		for i = idx_s, idx_e-1 do 
			local k = i 
			for j=i+1, idx_e do 
				if tbl[k]:getUnitRoot() > tbl[j]:getUnitRoot() then 
					k = j 
				end 
			end 

			if k > i then
				local tmp = tbl[k]
				tbl[k] = tbl[i]
				tbl[i] = tmp
			end      
		end 
	end 

	preType = itemsTbl[startIdx]:getMaxGrade()
	idx = startIdx
	for i = startIdx+1, endIdx do
		curType = itemsTbl[i]:getMaxGrade()
		if i < endIdx then
			if curType ~= preType then
				sortByRoot(itemsTbl, idx, i-1)      
				idx = i
				preType = curType
			end
		else
			if curType ~= preType then
				sortByRoot(itemsTbl, idx, i-1)
			else 
				sortByRoot(itemsTbl, idx, i)
			end 
		end 
	end 

	--sort by level for same root 
	preType = itemsTbl[startIdx]:getUnitRoot()
	idx = startIdx
	for i = startIdx+1, endIdx do
		curType = itemsTbl[i]:getUnitRoot()
		if i < endIdx then
			if curType ~= preType then
				self:sortItems(itemsTbl, idx, i-1, levelType)
				idx = i
				preType = curType
			end
		else
			if curType ~= preType then
				self:sortItems(itemsTbl, idx, i-1, levelType)
			else 
				self:sortItems(itemsTbl, idx, i, levelType)
			end 
		end 
	end 
end 

function Package:sortCards(cardsTbl,levelType, rareType, isExpAtTheLast, justSortByLevel)

	local num = table.getn(cardsTbl)
	if num <= 1 then 
		return 
	end

	if rareType == nil then 
		rareType = SortType.RARE_UP
	end

	if levelType == nil then 
		levelType = SortType.LEVEL_DOWN
	end 
	--1.sort and set battle cards to the begining
	for i=1, num-1 do 
		local k = i 
		for j=i+1, num do 
			if (cardsTbl[k]:getIsOnBattle() == false) and (cardsTbl[j]:getIsOnBattle() == true) then
				k = j
			end
		end  

		if k > i then 
			local tmp = cardsTbl[k]
			cardsTbl[k] = cardsTbl[i]
			cardsTbl[i] = tmp 
		end
	end

	local battleCardsCount = 0
	for i=1, num do 
		if cardsTbl[i]:getIsOnBattle() == true then 
			battleCardsCount = battleCardsCount + 1
		else 
			break
		end
	end
	if battleCardsCount > 1 then 
		self:sortCardByType(cardsTbl, 1, battleCardsCount, rareType, levelType)
	end

	local startIdx = battleCardsCount + 1
	local endIdx = num

	if endIdx <= startIdx+1 then 
		return
	end

	--2. sort and set exp card to the end 
	if isExpAtTheLast == nil then 
		isExpAtTheLast = true 
	end 

	for i=startIdx, endIdx-1 do
		local k = i
		for j=i+1, endIdx do 
			if isExpAtTheLast == true then 
				if cardsTbl[k]:getIsExpCard()==true and cardsTbl[j]:getIsExpCard()==false then
					k = j
				end
			else 
				if cardsTbl[k]:getIsExpCard()==false and cardsTbl[j]:getIsExpCard()==true then
					k = j
				end        
			end 
		end  

		if k > i then
			local tmp = cardsTbl[k]
			cardsTbl[k] = cardsTbl[i]
			cardsTbl[i] = tmp
		end
	end

	local expCardCount = 0 
	for i=startIdx, endIdx do     
		if cardsTbl[i]:getIsExpCard()==true then 
			expCardCount = expCardCount + 1
		end 
	end 

	if isExpAtTheLast == true then 
		-- self:sortCardByType(cardsTbl, endIdx-expCardCount+1, endIdx, rareType)
		self:sortItems(cardsTbl, endIdx-expCardCount+1, endIdx, rareType)
		endIdx = endIdx - expCardCount
	else 
		self:sortItems(cardsTbl, startIdx, startIdx+expCardCount-1, rareType)
		startIdx = startIdx + expCardCount
	end 

	--3. sort by rare for mid-idle cards
	if justSortByLevel then 
		self:sortItems(cardsTbl, startIdx, endIdx, levelType)
	else 
		self:sortCardByType(cardsTbl, startIdx, endIdx, rareType, levelType)
	end 
end

function Package:sortSurmountCards(cardsTbl,levelType, rareType)

	local num = table.getn(cardsTbl)
	if num <= 1 then 
		return 
	end

	if rareType == nil then 
		rareType = SortType.RARE_UP
	end

	--1.sort by surmount flag
	for i=1, num-1 do 
		local k = i 
		for j=i+1, num do 
			if cardsTbl[k]:getSurmountFlag() > cardsTbl[j]:getSurmountFlag() then
				k = j
			end
		end  

		if k > i then 
			local tmp = cardsTbl[k]
			cardsTbl[k] = cardsTbl[i]
			cardsTbl[i] = tmp
		end
	end

	local surmountCardsCount = 0
	for i=1, num do 
		if cardsTbl[i]:getSurmountFlag() == 1 then --can surmounted
			surmountCardsCount = surmountCardsCount + 1
		else 
			break
		end
	end

	if surmountCardsCount > 1 then 
		self:sortItems(cardsTbl, 1, surmountCardsCount, rareType)
	end

	local startIdx = surmountCardsCount + 1
	local endIdx = num

	if startIdx > endIdx then 
		return
	end

	--2.sort by rare for idle cards
	self:sortItems(cardsTbl, startIdx, endIdx, rareType)

	--3.sort by level type for each same rare
	local preType = cardsTbl[startIdx]:getMaxGrade()

	for i = startIdx+1, endIdx do
		local curType = cardsTbl[i]:getMaxGrade()
		if i < endIdx then
			if curType ~= preType then
				self:sortItems(cardsTbl, startIdx, i-1, levelType)      
				startIdx = i
				preType = curType
			end
		else
			if curType ~= preType then
				self:sortItems(cardsTbl, startIdx, i-1, levelType)
			else 
				self:sortItems(cardsTbl, startIdx, i, levelType)
			end
		end
	end
end

function Package:sortCardsForRebornList(cardsTbl)
	if cardsTbl == nil or #cardsTbl <= 1 then 
		return 
	end	

	local battleTbl = {}
	local miningTbl = {}
	local idleTbl = {}
	for k, v in pairs(cardsTbl) do 
		if v:getIsOnBattle() then 
			table.insert(battleTbl, v)
		elseif v:getCradIsWorkState() then 
			table.insert(miningTbl, v)
		else 
			table.insert(idleTbl, v)
		end 
	end 

	self:sortItems(battleTbl, 1, #battleTbl, SortType.RARE_DOWN)
	self:sortItems(miningTbl, 1, #miningTbl, SortType.RARE_DOWN)
	self:sortItems(idleTbl, 1, #idleTbl, SortType.RARE_DOWN)

	local idx = 1 
	for k, v in pairs(idleTbl) do 
		cardsTbl[idx] = v 
		idx = idx + 1 
	end 

	for k, v in pairs(miningTbl) do 
		cardsTbl[idx] = v 
		idx = idx + 1 
	end 

	for k, v in pairs(battleTbl) do 
		cardsTbl[idx] = v 
		idx = idx + 1 
	end 
end 

function Package:sortEquipments(equipTbl, isDirUp, actEquRootId, isBottomTop)
	local startIdx = 1
	local endIdx = table.getn(equipTbl)

	if endIdx < startIdx + 1 then
		return
	end

	-- echo("==== sortEquipments, actEquRootId, isBottomTop=", actEquRootId, isBottomTop)

	--1. 佩戴的装备放在下面
	for i=startIdx, endIdx-1 do
		local k = i
		for j=i+1, endIdx do 
			if equipTbl[k]:hasCard()==true and equipTbl[j]:hasCard()==false then 
				k = j
				break 
			end
		end

		if k > i then
			local tmp = equipTbl[k]
			equipTbl[k] = equipTbl[i]
			equipTbl[i] = tmp
		end
	end 

	local equipsHasCard = 0 
	for i=1, endIdx do 
		if equipTbl[i]:hasCard() == true then 
			equipsHasCard = equipsHasCard + 1 
		end 
	end 
	if equipsHasCard > 0 then 
		self:sortEquipmentsExt(equipTbl, startIdx, endIdx-equipsHasCard, isDirUp)
	end 

	--2. 空闲的专属装备放前面
	local actEquCount = 0 
	if actEquRootId ~= nil and actEquRootId > 0 then 
		endIdx = endIdx - equipsHasCard
		for i=startIdx, endIdx-1 do
			local k = i
			for j=i+1, endIdx do 
				if equipTbl[k]:getRootId() ~= actEquRootId and equipTbl[j]:getRootId() == actEquRootId then 
					k = j
					break 
				end
			end

			if k > i then
				local tmp = equipTbl[k]
				equipTbl[k] = equipTbl[i]
				equipTbl[i] = tmp
			end
		end 

		for i=startIdx, endIdx do 
			if equipTbl[i]:getRootId() == actEquRootId then 
				actEquCount = actEquCount + 1
			end 
		end 

		if actEquCount > 0 then 
			self:sortEquipmentsExt(equipTbl, 1, actEquCount, isDirUp)
		end 
	end 

	startIdx = 1 + actEquCount
	endIdx = #equipTbl - equipsHasCard 
	--对剩余装备排序
	self:sortEquipmentsExt(equipTbl, startIdx, endIdx, isDirUp)

	--如果需要反序存放数据
	if isBottomTop ~= nil and isBottomTop == true then 
		local num = #equipTbl
		for i=1, math.floor(num/2) do 
			local tmp = equipTbl[i]
			equipTbl[i] = equipTbl[num+1-i]
			equipTbl[num+1-i] = tmp
		end 
	end 
	
	return equipTbl
end 

function Package:sortEquipmentsExt(equipTbl, startIdx, endIdx, isDirUp)
	local function sortForSameEquiType(tbl, idx_s, idx_e, isDirUp)
		local function sortByQuality(tbl, idx_s, idx_e, dirUp)
			if idx_e <= idx_s+1 then 
				return 
			end 

			for i = idx_s, idx_e-1 do 
				local k = i 
				for j=i+1, idx_e do 
					if dirUp == true then 
						if tbl[k]:getQuality() > tbl[j]:getQuality() then 
							k = j 
							break 
						end 
					else 
						if tbl[k]:getQuality() < tbl[j]:getQuality() then 
							k = j 
							break 
						end 
					end 
				end 

				if k > i then
					local tmp = tbl[k]
					tbl[k] = tbl[i]
					tbl[i] = tmp
				end      
			end 
		end 

		if idx_e <= idx_s+1 then 
			return 
		end 

		-- sort by rare
		if isDirUp == true then 
			self:sortItems(tbl, idx_s, idx_e, SortType.RARE_UP)
		else 
			self:sortItems(tbl, idx_s, idx_e, SortType.RARE_DOWN)
		end 

		--sort by quality for same rare
		local preType = tbl[idx_s]:getMaxGrade()
		for i = idx_s+1, idx_e do
			local curType = tbl[i]:getMaxGrade()
			if i < idx_e then
				if curType ~= preType then
					sortByQuality(tbl, idx_s, i-1, isDirUp)
					idx_s = i
					preType = curType
				end
			else
				if curType ~= preType then
					sortByQuality(tbl, idx_s, i-1, isDirUp)
				else
					sortByQuality(tbl, idx_s, i, isDirUp)
				end
			end
		end
	end 

	---- begin to sort
	if endIdx < startIdx + 1 then
		return
	end

	if isDirUp == nil then 
		isDirUp = false 
	end 

	--1. sort by type : weapon > armor > accessory
	for i=startIdx, endIdx-1 do
		local k = i
		for j=i+1, endIdx do 
			if equipTbl[k]:getEquipType() > equipTbl[j]:getEquipType() then 
				k = j
			end
		end

		if k > i then
			local tmp = equipTbl[k]
			equipTbl[k] = equipTbl[i]
			equipTbl[i] = tmp
		end
	end  

	-- 2. sort for each equip_type
	local preType = equipTbl[startIdx]:getEquipType()
	for i = startIdx+1, endIdx do
		local curType = equipTbl[i]:getEquipType()
		if i < endIdx then
			if curType ~= preType then
				sortForSameEquiType(equipTbl, startIdx, i-1, isDirUp)
				startIdx = i
				preType = curType
			end
		else
			if curType ~= preType then
				sortForSameEquiType(equipTbl, startIdx, i-1, isDirUp)
			else
				sortForSameEquiType(equipTbl, startIdx, i, isDirUp)
			end
		end
	end
end


function Package:getItemsByRare(itemTbl, itemRare)
	local num = table.getn(itemTbl)
	local tmpArray = {}

	if num < 1 then 
		return tmpArray
	end

	for i = 1, num do 
		if itemTbl[i]:getMaxGrade() == itemRare then 
			table.insert(tmpArray, itemTbl[i])
		end
	end

	return tmpArray
end

function Package:getExpCards(tbl)
	local tmpArray = {}
	if tbl ~= nil then 
		for k, v in pairs(tbl) do 
			if v:getIsExpCard() == true then 
				table.insert(tmpArray, v)
			end
		end
	end
	return tmpArray
end
----------------------------------------------------------------------------------


---------------------------------------- 道具--------------------------------------
function Package:setPropsArray(tbl)
	self._propsArray = tbl
end 

function Package:getPropsArray()
	if self._propsArray == nil then 
		self._propsArray = {}
	end
	return self._propsArray
end

function Package:getPropsExceptChips()
  local tbl = {}
  for k, v in pairs(self:getPropsArray()) do 
    if v:getItemType() ~= iType_CardChip and v:getItemType() ~= iType_EquipChip then
      table.insert(tbl, v) 
    end
  end
  
  return tbl
end

function Package:getMergedPropsArray()
	local array = self:getPropsArray()

	self._mergedArray = {}
	for k,v in pairs(array) do 
		if v:getIsMergedProps() == true then 
			table.insert(self._mergedArray, v)
		end
	end

	return self._mergedArray
end

function Package:updatePropsItem(id, count)
	local array = self:getPropsArray()
	for i=1, table.getn(array) do 
		if array[i]:getId() == id then 
			--echo("updatePropsItem:", id, count)
			if count == 0 then
				table.remove(array, i)
			else
				array[i]:setCount(count)
			end
			break
		end
	end
end

function Package:insertPropsItem(propItem)
	if propItem == nil then
		echo("insertPropsItem: empty item !") 
		return
	end

	local needInert = true
	local array = self:getPropsArray()

	for i=1, table.getn(array) do 
		if array[i]:getConfigId() == propItem.type_id then 
			needInert = false
			array[i]:setCount(propItem.count)
			break
		end
	end

	if needInert == true then 
		local props = Props.new(propItem.id, propItem.type_id, propItem.count)
		table.insert(self._propsArray, props)
	end
end

function Package:sortByRare(tbl, startIdx, endIdx)
	if endIdx < startIdx then 
		return 
	end

	for i=startIdx, endIdx-1 do 
		local k = i 
		for j=i+1, endIdx do 
			if tbl[k]:getGrade() > tbl[j]:getGrade() then 
				k = j
			end
		end  

		if k > i then 
			local tmp = tbl[k]
			tbl[k] = tbl[i]
			tbl[i] = tmp 
		end
	end
end

function Package:sortByItemType(tbl, startIdx, endIdx)
	if endIdx < startIdx then 
		return 
	end

	for i=startIdx, endIdx-1 do 
		local k = i 
		for j=i+1, endIdx do 
			if tbl[k]:getItemType() > tbl[j]:getItemType() then 
				k = j
			end
		end  

		if k > i then 
			local tmp = tbl[k]
			tbl[k] = tbl[i]
			tbl[i] = tmp 
		end
	end
end

function Package:sortBySeqType(tbl, startIdx, endIdx)
	if endIdx < startIdx then 
		return 
	end

	for i=startIdx, endIdx-1 do 
		local k = i 
		for j=i+1, endIdx do 
			if tbl[k]:getItemSequence() > tbl[j]:getItemSequence() then 
				k = j
			end
		end  

		if k > i then 
			local tmp = tbl[k]
			tbl[k] = tbl[i]
			tbl[i] = tmp 
		end
	end
end

function Package:sortById(tbl, startIdx, endIdx)
	if endIdx < startIdx then 
		return 
	end

	for i=startIdx, endIdx-1 do 
		local k = i 
		for j=i+1, endIdx do 
			if tbl[k]:getId() > tbl[j]:getId() then 
				k = j
			end
		end  

		if k > i then 
			local tmp =  tbl[k]
			tbl[k] = tbl[i]
			tbl[i] = tmp 
		end
	end
end

function Package:sortByConfigId(tbl, startIdx, endIdx)
	if endIdx <= startIdx then 
		return 
	end

	for i=startIdx, endIdx-1 do 
		local k = i 
		for j=i+1, endIdx do 
			if tbl[k]:getConfigId() > tbl[j]:getConfigId() then 
				k = j
			end
		end  

		if k > i then 
			local tmp =  tbl[k]
			tbl[k] = tbl[i]
			tbl[i] = tmp 
		end
	end
end

function Package:setPropsAtFront(tbl, startIdx, endIdx, iType)
	if endIdx < startIdx then 
		return 
	end

	for i=startIdx, endIdx-1 do 
		local k = i 
		for j=i+1, endIdx do 
			if tbl[k]:getItemType() ~= iType and tbl[j]:getItemType() == iType then 
				k = j
			end
		end  

		if k > i then 
			local tmp =  tbl[k]
			tbl[k] = tbl[i]
			tbl[i] = tmp 
		end
	end

	local count = 0 
	for i=startIdx, endIdx do 
		if tbl[i]:getItemType() == iType then 
			count = count + 1 
		end 
	end 
	--sort by configId 
	if count > 1 then 
		self:sortByConfigId(tbl, startIdx, startIdx+count-1)
	end 

	return count 
end

function Package:sortProsForChip(tbl, startIdx, endIdx)

	local function sortCombinedPros(tbl, startIdx, endIdx)
		if endIdx <= startIdx then 
			return 
		end

		for i=startIdx, endIdx-1 do 
			local k = i 
			for j=i+1, endIdx do 
				if tbl[k]:getChipCanCombined() == false and  tbl[j]:getChipCanCombined() == true then 
					k = j
				end
			end  

			if k > i then 
				local tmp = tbl[k]
				tbl[k] = tbl[i]
				tbl[i] = tmp 
			end
		end
	end 

	--find chip cards to sort
	local start3 = 0
	local end3 = 0
	local start4 = 0
	local end4 = 0

	if startIdx == nil then startIdx = 1 end 
	if endIdx == nil then endIdx = #tbl end 

	for i = startIdx, endIdx do
		self:updateChipCombinedState(tbl[i])

		local curType = tbl[i]:getItemType()
		if curType == iType_CardChip then --card chip      
			if start3 == 0 then 
				start3 = i
				end3 = start3
			else 
				end3 = end3 + 1
			end
		elseif curType == iType_EquipChip then --equip chip
			if start4 == 0 then
				start4 = i
				end4 = start4
			else 
				end4 = end4 + 1
			end
		end
	end

	if start3 > 0 then 
		sortCombinedPros(tbl, start3, end3)
	end
	if start4 > 0 then 
		sortCombinedPros(tbl, start4, end4)
	end
end

function Package:sortProps(tbl)
	if tbl == nil then 
		return 
	end

	local tblsize = table.getn(tbl)
	if tblsize <= 1 then 
		return 
	end

	local startIdx = 1 

	--1. 将Q卡好礼 和 经验药水 排在前面
	startIdx = startIdx + self:setPropsAtFront(tbl, startIdx, tblsize, iType_ItemBoxQKa)
	echo("=== q card", startIdx)
	startIdx = startIdx + self:setPropsAtFront(tbl, startIdx, tblsize, iType_ExpCard)
	echo("=== exp card", startIdx)

	--2. check the temprary package,make sure it's props at the last of table,no need to sort
	-- local maxbagCount = GameData:Instance():getCurrentPlayer():getMaxItemBagCount()
	-- if tblsize > maxbagCount then
	-- 	self:sortById(tbl, startIdx, tblsize)
	-- 	tblsize = maxbagCount
	-- end

	--3. sort by item type
	self:sortBySeqType(tbl, startIdx, tblsize)

	--4. sort by item type for same item_seqence
	local begin = startIdx
	local preType = tbl[begin]:getItemSequence()

	for i = begin+1, tblsize do
		local curType = tbl[i]:getItemSequence()
		if i < tblsize then 
			if curType ~= preType then 
				self:sortByItemType(tbl, begin, i-1)

				begin = i
				preType = curType
			end
		else 
			if curType ~= preType then 
				self:sortByItemType(tbl, begin, i-1)
			else
				self:sortByItemType(tbl, begin, i)
			end
		end
	end

	--5. sort by rare for same item type
	begin = startIdx
	local preType = tbl[begin]:getItemType()

	for i = begin+1, tblsize do
		local curType = tbl[i]:getItemType()
		if i < tblsize then 
			if curType ~= preType then 
				self:sortByRare(tbl, begin, i-1)

				begin = i
				preType = curType
			end
		else 
			if curType ~= preType then 
				self:sortByRare(tbl, begin, i-1)
			else
				self:sortByRare(tbl, begin, i)
			end
		end
	end

	--6. sort by combined state fot chip cards
	self:sortProsForChip(tbl, startIdx, tblsize)
end



--insert tbl2 into tbl, combine the same one, and then resort
function Package:combineProps(tbl, tbl2)
	if tbl == nil or tbl2 == nil then  
		return 
	end 
	local needResorted = false 

	for i=1, table.getn(tbl2) do 
		for j=1, table.getn(tbl) do 
			if tbl2[i]:getId() == tbl[j]:getId() then 
				local num = tbl[j]:getCount() + tbl2[i]:getCount()
				tbl[j]:setCount(num)
				tbl2[i]:setCount(0)
			end
		end

		if tbl2[i]:getCount() > 0 then 
			table.insert(tbl, tbl2[i])
			needResorted = true
		end
	end

	if needResorted then 
		self:sortProps(tbl)
	end
end

function Package:getPropsById(Id)
	local item = nil
	local array = self:getPropsArray()
	for i=1, table.getn(array) do 
		if array[i]:getId() == Id then 
			item = array[i]
			break
		end
	end
	return item  
end 

function Package:getPropsByConfigId(configId)
	local item = nil
	local array = self:getPropsArray()
	for i=1, table.getn(array) do 
		if array[i]:getConfigId() == configId then 
			item = array[i]
			break
		end
	end
	return item  
end 

function Package:getPropsNumByConfigId(configId)
	local num = 0
	local array = self:getPropsArray()
	for i=1, table.getn(array) do 
		if array[i]:getConfigId() == configId then 
			num = array[i]:getCount()
			break
		end
	end
	return num
end

function Package:getCardNumByConfigId(configId)
	local num = 0 
	local array = self:getAllCards() 
	for i=1, table.getn(array) do 
		if array[i]:getConfigId() == configId then 
			num = num + 1 
		end 
	end 

	return num
end

function Package:getEquipNumByConfigId(configId)
	local num = 0 
	local array = self:getAllEquipments() 
	for i=1, table.getn(array) do 
		if array[i]:getConfigId() == configId then 
			num = num + 1 
		end 
	end 
	
	return num
end

function Package:getSkillBooks()
	return self:getBooksByType(iType_SkillBook)
end

function Package:getBooksByType(_type)
	local booksArry = {}
	local array = self:getPropsArray()
	for i=1, table.getn(array) do 
		if array[i]:getItemType() == _type then 
			table.insert(booksArry, array[i])
		end
	end

	--sort 
	local num = table.getn(booksArry)
	if num > 1 then 
		self:sortItems(booksArry, 1, num, SortType.RARE_UP)
	end
	
	return booksArry
end

function Package:getBoxNumByKey(boxConfigId, exceptNum)
	local resultCount = 0 
	local item = AllConfig.item[boxConfigId]
	if item ~= nil then 
		local keyConfigId = item.item_use
		--find in props table
		for k, v in pairs(self:getPropsArray()) do 
			if v:getConfigId() == keyConfigId then 
				resultCount  = math.min(exceptNum, v:getCount())
				break 
			end
		end
	end

	return resultCount
end 

function Package:getIsBoxQCardValid()
	local level = GameData:Instance():getCurrentPlayer():getLevel()
	local array = self:getPropsArray()
	for k, v in pairs(array) do 
		if v:getItemType() == iType_ItemBoxQKa and level >= v:getRequireLevel() then 
			return true 
		end
	end

	return false 
end 

function Package:parseClientSyncMsg(clientSync)
	echo("--parseClientSyncMsg--:")
	if clientSync == nil then
		echo("invalid clientSync")
		return 
	end 

	if clientSync.common ~= nil then 
		--echo("updateBaseInfo")
		--level up
		if clientSync.common.level ~= GameData:Instance():getCurrentPlayer():getLevel()
			and ControllerFactory:Instance():getCurrentControllerType() ~= ControllerType.BATTLE_CONTROLLER then
				CCNotificationCenter:sharedNotificationCenter():postNotification(EventType.PLAYER_LEVEL_UP)
			end
			GameData:Instance():getCurrentPlayer():updateBaseInfo(clientSync.common)
		end

	if clientSync.item ~= nil then 
		for k,val in pairs(clientSync.item) do 
		 echo("item: action=", val.action, val.object.id, val.object.type_id, val.object.count)
			if val.action == "Add" then
				self:insertPropsItem(val.object)
			elseif val.action == "Remove" then 
				self:updatePropsItem(val.object.id, 0) 
			elseif val.action == "Update" then 
				self:updatePropsItem(val.object.id, val.object.count)        
			end
		end
	end

	if clientSync.equipment ~= nil then 
		for k,val in pairs(clientSync.equipment) do 
			echo("equipment: action=", val.action, val.object.id)
			if val.action == "Add" then 
				self:insertEquipItems(val.object)
			elseif val.action == "Remove" then 
				self:removeEquip(val.object.id)
			elseif val.action == "Update" then
--        self:removeEquip(val.object.id)
--        self:insertEquipItems(val.object)
				self:updateEquip(val.object)
			end
		end
	end 

	if clientSync.card ~= nil then
		for k,val in pairs(clientSync.card) do
		 echo("card: action=", val.action, val.object.id, val.object.config_id)
			if val.action == "Add" then
				self:insertCard(val.object)
			elseif val.action == "Remove" then
				self:removeCard(val.object.id)
			elseif val.action == "Update" then
				self:updateCardAttr(val.object)
			end
		end
	end

	-- 如果卡牌创建和装备创建在同一更新消息的时候，需要再次刷新卡牌和装备的属性
	if clientSync.equipment ~= nil then 
		for k,val in pairs(clientSync.equipment) do 
			if val.action ~= "Remove" then
				self:updateEquip(val.object)
			end
		end
	end 
	if clientSync.card ~= nil then
		for k,val in pairs(clientSync.card) do
		 	if val.action ~= "Remove" then
				self:updateCardAttr(val.object)
		 	end
		end
	end

	-- 如果卡牌创建和装备创建在同一更新消息的时候，需要再次刷新卡牌和装备的属性
	if clientSync.equipment ~= nil then 
		for k,val in pairs(clientSync.equipment) do 
			if val.action ~= "Remove" then
				self:updateEquip(val.object)
			end
		end
	end 
	if clientSync.card ~= nil then
		for k,val in pairs(clientSync.card) do
		 	if val.action ~= "Remove" then
				self:updateCardAttr(val.object)
		 	end
		end
	end
	
	if clientSync.vip_state ~= nil then
		GameData:Instance():getCurrentPlayer():updateVipState(clientSync.vip_state)
	end
	
	Scenario:Instance():parseClientSync(clientSync)
	GameData:Instance():getCurrentPlayer():getIllustratedInstance():parseClientSync(clientSync)
	Quest:Instance():reFreshTaskState()
	
	if clientSync.changed_information ~= nil then 
		GameData:Instance():getCurrentPlayer():updatePlayerDailyChangedInformation(clientSync.changed_information, true)
	end
	
	if (clientSync.talent~=nil and clientSync.talent.needSync) then
		GameData:Instance():getCurrentPlayer():updateTalentBank(clientSync.talent.talent)
	end
	
	if clientSync.rebate ~= nil then
		if #clientSync.rebate > 0 then
			local rebateData  = {}

			for k, v in pairs(clientSync.rebate) do
				table.insert(rebateData,v.object)
			end

			Mall:Instance():updateRebateData(rebateData)
			Activity:instance():setDaySurpriseRebateData(rebateData)
		end
	end
	
	if clientSync.award_record ~= nil then
	   if clientSync.award_record.needSync ~= nil and clientSync.award_record.needSync then
	     GameData:Instance():getCurrentPlayer():updateAwardsRecordSync(clientSync.award_record.award_record)
	   end
	end
	
	if clientSync.battle ~= nil then
     if clientSync.battle.needSync ~= nil and clientSync.battle.needSync then
       BattleFormation:Instance():update(clientSync.battle.battle)
       self:sortingCards()
     end
  end
	
	if clientSync.bable_info ~= nil then 
		echo("===bable_info.needSync", clientSync.bable_info.needSync)
		if clientSync.bable_info.needSync then 
			Bable:instance():setBableInfo(clientSync.bable_info.bable_info)
		end 
	end 
	
	if clientSync.append_buffer ~= nil then
	 if clientSync.append_buffer.needSync then 
      GameData:Instance():getCurrentPlayer():setAppendFighterBuffers(clientSync.append_buffer.append_buffer)
    end 
	end
end 

function Package:getGainedItems(clientSync)
	--echo("--getGainedItems--:")

	local gainedTable = {}

	if clientSync == nil then
		echo("invalid clientSync")
		return gainedTable
	end 

	if clientSync.common ~= nil then 
		local preCoin = GameData:Instance():getCurrentPlayer():getCoin()
		if clientSync.common.coin > preCoin then 
			local coinItem = {iType =88, configId=3050050, iconId=3050050, iconBg = nil, frameId=nil, count=clientSync.common.coin-preCoin}
			table.insert(gainedTable, coinItem)
		end

		local preMoney = GameData:Instance():getCurrentPlayer():getMoney()
		local curMoney = clientSync.common.money + clientSync.common.point
		if curMoney > preMoney then 
			local moneyItem = {iType =88, configId=3050049, iconId=3050049, iconBg = nil, frameId=nil, count=curMoney-preMoney}
			table.insert(gainedTable, moneyItem)
		end
	end

	-- item
	if clientSync.item ~= nil then 
		for k,val in pairs(clientSync.item) do 
			echo("--item: action=", val.action, val.object.id, val.object.type_id, val.object.count)
			
			if val.action == "Add" then
				local resId = AllConfig.item[val.object.type_id].item_resource
				local bgId = nil 
				if AllConfig.item[val.object.type_id].item_type == 4 then 
					bgId = 3059009 + AllConfig.item[val.object.type_id].rare - 1
				end        
				local frameBgId = 3021041 + AllConfig.item[val.object.type_id].rare - 1
				local item = {iType = math.floor(val.object.type_id/10000000), configId=val.object.type_id, iconId=resId, iconBg=bgId, frameId=frameBgId, count=val.object.count}
				table.insert(gainedTable, item)
			elseif val.action == "Update" then 
				local array = self:getPropsArray()
				for i=1, table.getn(array) do 
					if array[i]:getConfigId() == val.object.type_id then 
						local preCount = array[i]:getCount()
						if preCount < val.object.count then 
							local resId = AllConfig.item[val.object.type_id].item_resource
							local bgId = nil 
							if AllConfig.item[val.object.type_id].item_type == 4 then 
								bgId = 3059009 + AllConfig.item[val.object.type_id].rare - 1
							end 
							local frameBgId = 3021041 + AllConfig.item[val.object.type_id].rare - 1
							local cardItem = {iType = math.floor(val.object.type_id/10000000), configId=val.object.type_id, iconId=resId, iconBg=bgId, frameId=frameBgId, count=val.object.count-preCount}
							table.insert(gainedTable, cardItem)
							break
						end
					end
				end
			end
		end
	end

	-- equipment
	if clientSync.equipment ~= nil then 
		for k,val in pairs(clientSync.equipment) do 
			--echo("--equipment: action=", val.action, val.object.config_id)
			if val.action == "Add" then 
				local resId = AllConfig.equipment[val.object.config_id].equip_icon
				local bgId = 3059009 + AllConfig.equipment[val.object.config_id].equip_rank
				local frameBgId = 3021041 + AllConfig.equipment[val.object.config_id].equip_rank
				local equip = {iType = math.floor(val.object.config_id/10000000), configId=val.object.config_id, iconId=resId,iconBg = bgId, frameId=frameBgId, count=1}
				table.insert(gainedTable, equip)
			elseif val.action == "Update" then

			end
		end
	end  

	--card
	if clientSync.card ~= nil then
		for k,val in pairs(clientSync.card) do
		 -- echo("--card: action=", val.action, val.object.id, val.object.config_id)
			if val.action == "Add" then
				local resId = AllConfig.unit[val.object.config_id].unit_head_pic
				local frameBgId = 3021041 + AllConfig.unit[val.object.config_id].card_rank
				local item = {iType = math.floor(val.object.config_id/10000000), configId=val.object.config_id, iconId=resId, iconBg = nil, frameId=frameBgId,count=1}
				table.insert(gainedTable, item) 
			end
		end
	end

	if clientSync.changed_information ~= nil then 
		--spirit
		if clientSync.changed_information.spirit ~= nil then 
			local preSpirit = GameData:Instance():getCurrentPlayer():getSpirit()
			local curSpirit = clientSync.changed_information.spirit.current
			if curSpirit > preSpirit then 
				local spiritItem = {iType =88, configId=3059015, iconId=3059015, iconBg = nil, frameId=nil, count=curSpirit-preSpirit}
				table.insert(gainedTable, spiritItem)
			end
		end
		--token
		if clientSync.changed_information.command ~= nil then 
			local preToken = GameData:Instance():getCurrentPlayer():getToken()
			local curToken = clientSync.changed_information.command.current
			if curToken > preToken then 
				local tokenItem = {iType =88, configId=3059001, iconId=3059001, iconBg = nil, frameId=nil, count=curToken-preToken}
				table.insert(gainedTable, tokenItem)        
			end
		end
	end

	return gainedTable  
end 

function Package:getGainedItemsExt(clientSync)

	local gainedTable = {}

	if clientSync == nil then
		echo("invalid clientSync")
		return gainedTable
	end 
 
	if clientSync.common ~= nil then 
		local preCoin = GameData:Instance():getCurrentPlayer():getCoin()
		if clientSync.common.coin > preCoin then 
			local coinItem = {iType =88, configId=nil, iconId=3050050, count=clientSync.common.coin-preCoin}
			table.insert(gainedTable, coinItem)
		end

		local preMoney = GameData:Instance():getCurrentPlayer():getMoney()
		local curMoney = clientSync.common.money + clientSync.common.point
		if curMoney > preMoney then 
			local moneyItem = {iType =88, configId=nil, iconId=3050049, count=curMoney-preMoney}
			table.insert(gainedTable, moneyItem)
		end
		
		local preExp = GameData:Instance():getCurrentPlayer():getExperience()
		local curExp = clientSync.common.experience
		if curExp > preExp then 
			local expItem = {iType = 88, configId = nil, iconId = 3059022, count = curExp - preExp}
			table.insert(gainedTable, expItem)
		end
 
		local preSoul = GameData:Instance():getCurrentPlayer():getCardSoul() 
		if clientSync.common.jianghun > preSoul then 
			local coinItem = {iType =88, configId=nil, iconId=3059046, count=clientSync.common.jianghun-preSoul} 
			table.insert(gainedTable, coinItem) 
		end 

		--竞技场荣誉点
		local preRankPoint = GameData:Instance():getCurrentPlayer():getRankPoint()
		if clientSync.common.rank_point > preRankPoint then 
			local coinItem = {iType =88, configId=nil, iconId=3050070, count=clientSync.common.rank_point-preRankPoint} 
			table.insert(gainedTable, coinItem) 			
		end 

		--公会点
		local preGuildPoint = GameData:Instance():getCurrentPlayer():getGuildPoint()
		if clientSync.common.guild_point > preGuildPoint then 
			local coinItem = {iType =88, configId=nil, iconId=3050071, count=clientSync.common.guild_point-preGuildPoint} 
			table.insert(gainedTable, coinItem) 			
		end 

		--通天塔货币
		local preBablePoint = GameData:Instance():getCurrentPlayer():getBablePoint()
		if clientSync.common.bable_point > preBablePoint then 
			local coinItem = {iType =88, configId=nil, iconId=3059072, count=clientSync.common.bable_point-preBablePoint} 
			table.insert(gainedTable, coinItem) 			
		end 				
	end 

	--talent
	if clientSync.talent.talent ~= nil then 
		local prePoint = GameData:Instance():getCurrentPlayer():getTalentBankPoints()
		local curPoint = clientSync.talent.talent.talent_point
		if curPoint > prePoint then 
			local expItem = {iType = 88, configId = nil, iconId = 3059000, count = curPoint-prePoint}
			table.insert(gainedTable, expItem)      
		end 
	end 

	-- item
	if clientSync.item ~= nil then 
		for k,val in pairs(clientSync.item) do       
			if val.action == "Add" then
				local icd = self:getToastIconIdForItem(val.object.type_id)
				local item = {iType = 6, configId=val.object.type_id, iconId=icd, count=val.object.count}
				table.insert(gainedTable, item)
			elseif val.action == "Update" then 
				local array = self:getPropsArray()
				for i=1, table.getn(array) do 
					if array[i]:getConfigId() == val.object.type_id then 
						local preCount = array[i]:getCount()
						if preCount < val.object.count then 
							local icd = self:getToastIconIdForItem(val.object.type_id)
							local cardItem = {iType = 6, configId=val.object.type_id, iconId=icd, count=val.object.count-preCount}
							table.insert(gainedTable, cardItem)
							break
						end
					end
				end
			end
		end
	end

	-- equipment
	if clientSync.equipment ~= nil then 
		for k,val in pairs(clientSync.equipment) do 
			--echo("--equipment: action=", val.action, val.object.config_id)
			if val.action == "Add" then 
				local equip = {iType = 7, configId=val.object.config_id, iconId=nil, count=1}
				table.insert(gainedTable, equip)
			elseif val.action == "Update" then
			end
		end
	end  

	--card
	if clientSync.card ~= nil then
		for k,val in pairs(clientSync.card) do
		 -- echo("--card: action=", val.action, val.object.id, val.object.config_id)
			if val.action == "Add" then
				local item = {iType = 8, configId=val.object.config_id, iconId=nil, count=1}
				table.insert(gainedTable, item) 
			end
		end
	end

	if clientSync.changed_information ~= nil then 
		--spirit
		if clientSync.changed_information.spirit ~= nil then 
			local preSpirit = GameData:Instance():getCurrentPlayer():getSpirit()
			local curSpirit = clientSync.changed_information.spirit.current
			if curSpirit > preSpirit then 
				local spiritItem = {iType =88, configId=nil, iconId="#playstates-image-tili.png"--[[3059015]], count=curSpirit-preSpirit}
				table.insert(gainedTable, spiritItem)
			end
		end
		--token
		if clientSync.changed_information.command ~= nil then 
			local preToken = GameData:Instance():getCurrentPlayer():getToken()
			local curToken = clientSync.changed_information.command.current
			if curToken > preToken then 
				local tokenItem = {iType =88, configId=nil, iconId=3059001, count=curToken-preToken}
				table.insert(gainedTable, tokenItem)        
			end
		end
	end

	return gainedTable  
end 

function Package:getToastIconIdForItem(configId)
	local iconid = nil 
	if configId ~= nil then 
		local itemType = AllConfig.item[configId]
		if itemType == iType_TalentPoint then --计略点道具
			iconid = 3059000
		end
	end 

	return iconid
end 

function Package:checkItemBagEnoughSpace(needSpace)
	local playerObject = GameData:Instance():getCurrentPlayer()
	local ownItemMaxBagCount = playerObject:getMaxItemBagCount()
	local usedItemBag = #(self:getPropsExceptChips())

	local isEnough = false 
	if ownItemMaxBagCount >= usedItemBag + needSpace then 
		isEnough = true 
	end 

	return isEnough
end

function Package:checkCardBagEnoughSpace(needSpace)
	local playerObject = GameData:Instance():getCurrentPlayer()
	local ownCardMaxBagCount = playerObject:getMaxCardBagCount()
	local usedCardbag = #(self:getAllCards())

	local isEnough = false 
	if ownCardMaxBagCount >= usedCardbag + needSpace then 
		isEnough = true 
	end 

	return isEnough
end

function Package:checkEquipBagEnoughSpace(needSpace)
	local playerObject = GameData:Instance():getCurrentPlayer()
	local ownEquipMaxBagCount = playerObject:getMaxEquipBagCount()
	local usedEquipBag = #(self:getAllEquipments())

	local isEnough = false 
	if ownEquipMaxBagCount >= usedEquipBag + needSpace then 
		isEnough = true 
	end 

	return isEnough
end

function Package:getBagCellPrice(index)
	if self._bagCellCost == nil then 
		self._bagCellCost = {}
		for k, v in pairs(AllConfig.cost) do 
			if v.type == 1 then
				for i = v.min_count, v.max_count do 
					self._bagCellCost[i] = v.cost
				end
			end
		end
	end

	local len = table.getn(self._bagCellCost)
	if index > len then
		index = len
	end
	return self._bagCellCost[index]
end

function Package:updateChipCombinedState(item)
	if item == nil then
		return
	end

	item:setChipCanCombined(false)

	if item:getItemType() ~= 3 and item:getItemType() ~= 4 then
		return
	end

	local combineSummary = AllConfig.combinesummary[item:getConfigId()]
	if combineSummary == nil then
		echo("invalid combineSummary !!")
		return
	end

	local canCombine = true 
	local dataItem, needCount, ownCount 
  for k, v in pairs(combineSummary.consume) do 
    dataItem = v.array 
    if dataItem[1] == 6 then 
    	needCount = dataItem[3] 
    	ownCount = self:getPropsNumByConfigId(dataItem[2]) 
    	if ownCount < needCount then 
    		canCombine = false 
    		break 
    	end 
    end 
	end 
	
	item:setChipCanCombined(canCombine)
end 

--showTipsInfo: [table] example: {callbackFunc=tipsCallback, priority = -200}
function Package:getItemSprite(iconid, itemType, configId, count, isNumVisible, showTipsInfo)
	local sprite1 = nil 
	local frameId = nil 
	local qualityLevel = nil 
	local equipBg = nil 
	local suiPian = nil 
	local iconWidth = 95 

	-- echo("===getItemSprite:", itemType, configId, count)
	if iconid ~= nil then 
		sprite1 = _res(iconid)
	elseif configId < 100 then --针对非道具类型，比如计略点,将魂,各种货币..
		configId = itemType 
		local item = AllConfig.item[configId]
		if item then 
			sprite1 = _res(item.item_resource)
			frameId = 3021041 + item.rare - 1
		end 
		
		--props/tokent/card soul/talent/
	elseif itemType == 6 or itemType == 12 or itemType == 20 or itemType == 21 then 
		local item = AllConfig.item[configId]
		if item ~= nil then
			local resId = item.item_resource
			sprite1 = _res(resId)
			frameId = 3021041 + item.rare - 1
			qualityLevel = item.quality
			local subType = item.item_type
			--chip
			if subType == 3 or subType == 4 then 
				suiPian = CCSprite:create("img/common/suipian.png")
			end

			if subType == 4 then 
				equipBg = _res(3059009 + item.rare - 1)
			end
		else 
			echo(" invalid item !!!!! configId=", configId)
		end 

	elseif itemType == 7 then --equip

		sprite1 = _res(AllConfig.equipment[configId].equip_icon)

		local grade = AllConfig.equipment[configId].equip_rank + 1
		local subGrade = AllConfig.equipment[configId].quality
		local smoothGrade = math.max(0, (grade-3)*3) + grade-1 + subGrade 
		equipBg = _res(3059008 + grade)
		frameId = 3021051 + smoothGrade

	elseif itemType == 8 then --card
		 sprite1 = _res(AllConfig.unit[configId].unit_head_pic)
		 frameId = 3021041 + AllConfig.unit[configId].card_rank
	end 

	local node = CCNode:create()
	node:setContentSize(CCSizeMake(iconWidth, iconWidth))

	--bg
	if equipBg ~= nil then 
		node:addChild(equipBg)
	end

	--icon 
	if sprite1 ~= nil then 
		local scale = 1.0
		if sprite1:getContentSize().width > iconWidth then 
			scale = iconWidth/sprite1:getContentSize().width
			sprite1:setScale(scale)
		end 

		--reg tips event
		if showTipsInfo and configId then 
	    local touchPriority = showTipsInfo.priority or 0 
	    local touchLayer = CCLayer:create()
	    sprite1:addChild(touchLayer)
		  touchLayer:addTouchEventListener(function(event, x, y)
		                                if event == "began" then                                 
		                                  local size = sprite1:getContentSize()
		                                  local pos = sprite1:convertToNodeSpace(ccp(x, y))
		                                  if pos.x > 0 and pos.x < size.width and pos.y > 0 and pos.y < size.height then 
		                                  	if showTipsInfo.callbackFunc then 
		                                  		showTipsInfo.callbackFunc(sprite1, configId, ccp(0, iconWidth/2+10))
		                                  	else 
		                                  		TipsInfo:showTip(sprite1, configId, nil, ccp(0, iconWidth/2+10), nil, true)
		                                  	end 
		                                  end
		                                  return false 
		                                end
		                            end,
		              false, touchPriority, true)
		  touchLayer:setTouchEnabled(true)
		end 

		node:addChild(sprite1)
	end 

	--chip
	if suiPian ~= nil then 
		suiPian:setAnchorPoint(ccp(0,1))
		suiPian:setPosition(ccp(-iconWidth/2+7, iconWidth/2-7))
		node:addChild(suiPian)
	end 

	--quality
	if qualityLevel ~= nil and qualityLevel > 0 then 
		local qualityImg = _res(3036001+qualityLevel-1)
		if qualityImg ~= nil and sprite1 ~= nil then
			qualityImg:setAnchorPoint(ccp(1,1))
			qualityImg:setPosition(ccp(iconWidth/2-6, iconWidth/2-7))
			node:addChild(qualityImg)
		end 
	end 

	--frame
	if frameId ~= nil then 
		local frameBg = _res(frameId)
		if frameBg ~= nil then 
			node:addChild(frameBg)
		end
	end 

	if count ~= nil and (count > 1 or isNumVisible) then 
		local numStr = nil
		if count > 10000 then 
			if count%10000 >= 1000 then 
				numStr = string.format("%.1f", count/10000).._tr("wan")
			else 
				numStr = _tr("wan_%{count}", {count=count/10000})
			end
		else 
			numStr = string.format("%d", count)
		end

		local label = CCLabelBMFont:create(numStr, "client/widget/words/card_name/number_skillup.fnt")
		label:setAlignment(kCCTextAlignmentRight)
		label:setAnchorPoint(ccp(1.0, 0))
		-- local labelSize = tolua.cast(label:getContentSize(),"CCSize")  
		label:setPosition(ccp(iconWidth/2-2, -iconWidth/2+7))
		label:setTag(100)
		node:addChild(label)
	end 

	return node 
end 


------------------------------------------------------

return Package
