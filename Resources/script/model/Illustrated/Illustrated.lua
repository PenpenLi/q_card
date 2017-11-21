require("model.Illustrated.CollectionCard") 
require("model.Illustrated.CollectionEquipment") 
Illustrated = class("Illustrated")
function Illustrated:ctor()

end

function Illustrated:initCards()
  local unitRootCards = {}
  for key, unit in pairs(AllConfig.unit) do
      --echo("unit_id:",key,"unit_root:",unit.unit_root)
      if unit.is_exp_card == 0 then
--          local hasCard = false
--          for key, mUnit in pairs(unitRootCards) do
--            if mUnit:getUnitRoot() == unit.unit_root then
--               hasCard = true
--               break
--            end
--          end
          --if unitRootCards[unit.unit_root] == nil then
          if unit.card_rank == unit.card_max_rank then
            local unitCard = CollectionCard.new()
            unitCard:initAttrById(key)
            unitCard:setGrade(unitCard:getMaxGrade())
            unitRootCards[unit.unit_root] = unitCard
          end
      end
  end
  self:setCollectionCards(unitRootCards)
end

--function Illustrated:initCards()
--  local unitRootCards = {}
--  for key, unit in pairs(AllConfig.unit) do
--      --echo("unit_id:",key,"unit_root:",unit.unit_root)
--      if unit.is_exp_card == 0 then
--          local hasCard = false
--          for key, mUnit in pairs(unitRootCards) do
--            if mUnit:getUnitRoot() == unit.unit_root then
--               hasCard = true
--               break
--            end
--          end
--          
--          if hasCard == false then
--            local unitCard = CollectionCard.new()
--            unitCard:initAttrById(key)
--            unitCard:setGrade(unitCard:getMaxGrade())
--            table.insert(unitRootCards,unitCard)
--          end
--      end
--  end
--  self:setCollectionCards(unitRootCards)
--  
-- 
--end

function Illustrated:initEquipments()
  local equipments = {}
  for equipmentId, equipment in pairs(AllConfig.equipment) do
      if AllConfig.equipment[equipmentId].rare == 5 then
          local hasEquipment = false
          local equipmentRoot = 0
          for key, mEquip in pairs(equipments) do
             if mEquip:getEquipRoot() == equipment.equip_root then
                hasEquipment = true
                break
             end
          end
          
          if hasEquipment == false then
             equipments[AllConfig.equipment[equipmentId].equip_root] = CollectionEquipment.new(equipmentId)
          end
      end
      
  end
  self:setEquipments(equipments)
end

function Illustrated:updateCollection(collection) --collection from PlayerBaseInformation ---> optional PictureInformation collection = 9; // card you see and owned
   self:initCards()
   for key, cardPictureState in pairs(collection.object) do
   	  local cardUnit = self:getCardByUnitRoot(cardPictureState.id)
   	  if cardUnit ~= nil then
   	    cardUnit:setState(cardPictureState.state)
   	  end
--   	  print("rootId:",cardPictureState.id)
--   	  print("state:",cardPictureState.state)
   end
  
  -- assert(false,"Illustrated debug")
end

function Illustrated:getCollectionCardsOwend()
   local cardsOwend = {}
   for key, card in pairs(self:getCollectionCards()) do
   	   if card:getState() == "HasOwned" then
   	      table.insert(cardsOwend,card)
   	   end
   end
   return cardsOwend
end


function Illustrated:insertEquipmentToIllustrated(configId)
   print(configId)
   local equipmentRootId = AllConfig.equipment[configId].equip_root
   if self._Equipments[equipmentRootId] == nil then
      self._Equipments[equipmentRootId] = CollectionEquipment.new(configId)
   end
   self._Equipments[equipmentRootId]:setHasOwend(true)
end
------
--  Getter & Setter for
--      Illustrated._Equipments 
-----
function Illustrated:setEquipments(Equipments)
	self._Equipments = Equipments
end

function Illustrated:getEquipments()
	return self._Equipments
end

function Illustrated:updateEquipment(equipment) --collection from PlayerBaseInformation --->  optional EquipmentStatics equipment_statics = 12;
--  message EquipmentStatics {
--  enum traits { value = 2154;}
--  repeated int32 armor_config_id = 1;
--  repeated int32 weapon_config_id = 2;
--  repeated int32 adornment_config_id = 3;
--}
   self:initEquipments()

   for a_key, a_configId in pairs(equipment.armor_config_id) do
       self:insertEquipmentToIllustrated(a_configId)
   end
   
   for w_key, w_configId in pairs(equipment.weapon_config_id) do
       self:insertEquipmentToIllustrated(w_configId)
   end
   
   for key, ad_configId in pairs(equipment.adornment_config_id) do
       self:insertEquipmentToIllustrated(ad_configId)
   end
  
end

function Illustrated:getEquipmentByEquipRoot(equipmentRootId)
   return self._Equipments[equipmentRootId]
end

function Illustrated:getEquipmentsByGradeAndEquipEype(grade,equipType)
   local equipments = {}
   for key, equipment in pairs(self:getEquipments()) do
   	   if equipment:getRank() == grade and equipment:getEquipType() == equipType then
   	      table.insert(equipments,equipment)
   	   end
   end
   return equipments
end


function Illustrated:setCollectionCards(CollectionCards)
	self._CollectionCards = CollectionCards
end

function Illustrated:getCollectionCards()
	return self._CollectionCards
end

function Illustrated:getCardsByCountry(country)
  local cards = {}
  for key, card in pairs(self:getCollectionCards()) do
    if card:getCountry() == country then
       table.insert(cards,card)
    end
  end
  return cards
end

function Illustrated:getCardsByGradeAndCountry(grade,country)
  local cards = {}
  for key, card in pairs(self:getCollectionCards()) do
  	if card:getMaxGrade() == grade and card:getCountry() == country then
  	   table.insert(cards,card)
  	end
  end
  return cards
end

function Illustrated:parseClientSync(clientSync)
   echo("Illustrated:------parseClientSync")
   if clientSync.collection ~= nil then 
    local collectionCard = nil
    for k,val in pairs(clientSync.collection) do 
      echo("collection: action=", val.action, val.object)
      if val.action == "Add" then 
--         collectionCard = CollectionCard.new(val.object)
--         self:insertCollectionCard(collectionCard)
         collectionCard = self:getCardByUnitRoot(val.object.id)
         if collectionCard ~= nil then
            collectionCard:setState(val.object.state)
         end
      elseif val.action == "Remove" then 
         
      elseif val.action == "Update" then
--         collectionCard = CollectionCard.new(val.object)
--         self:updateCollectionCard(collectionCard)
         collectionCard = self:getCardByUnitRoot(val.object.id)
         if collectionCard ~= nil then
            collectionCard:setState(val.object.state)
         end
      end
    end
  end
  
end

function Illustrated:insertCollectionCard(collectionCard)
  local hasCard = false
  for key, mCollectionCard in pairs(self:getCollectionCards()) do
    if collectionCard:getConfigId() == mCollectionCard:getConfigId() then
       hasCard = true
       mCollectionCard = collectionCard
       break
    end
  end
  
  if hasCard == false then
     table.insert(self:getCollectionCards(),collectionCard)
  end
end

function Illustrated:getCardByConfigId(configId)
  local card = nil
  for k,v in pairs(self:getCollectionCards()) do
    if v:getConfigId() == configId then
      card = v
      break
    end
  end
  return card
end

function Illustrated:getCardByUnitRoot(unitRootId)
  return self:getCollectionCards()[unitRootId]
end

return Illustrated