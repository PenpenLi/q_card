require("model.Card")
MiningCard = class("Mining",Card)

function MiningCard:ctor()
	MiningCard.super.ctor(self)
	--index value
	self._ower = nil
	self._miners = 0        -- 打工所在矿主的 UserId
	self._minerName = nil   -- 打工所在矿主的昵称
	self._pos = 0           --打工的矿位下标
	self._start = 0         --打工开始时间
	self._duration = 0      --打工持续时间
	self._cardInfo = {}
end

function MiningCard:initCardInfo(miningCardInfo)
	--self._configId = miningCardInfo.card
	--dump(miningCardInfo,"??????????")
	local cardInfo =  miningCardInfo.info --card CommanderCard
	if cardInfo.config_id == 0 then
		assert(false,"config_id is error")
	end

	self._cardInfo = Card.new()
	self._cardInfo:initAttrById(cardInfo.config_id)
	self._cardInfo:setId(cardInfo.id)
	self._cardInfo:setIsBoss(cardInfo.is_leader)
	self._cardInfo:setExperience(cardInfo.experience)
	self._cardInfo:setIsOnBattle(cardInfo.is_active)
	self._cardInfo:getSkill():update(cardInfo.config_id, cardInfo.skill_experience)

	if cardInfo.state ~= nil then
		self._cardInfo:setWorkState(cardInfo.state)
	end
--	self._cardInfo:setThumbnailTextureName("ren.png")
	self._cardInfo:setIntegrityTextureName("shop_card_tu.png")

	self._ower = miningCardInfo.ower
	self._miners = miningCardInfo.miners
	self._pos = miningCardInfo.pos
	self._start = miningCardInfo.start
	self._duration = miningCardInfo.duration

end

function MiningCard:getOwer()
	return self._ower
end

function MiningCard:getCardInfo()
	return self._cardInfo
end

return MiningCard




