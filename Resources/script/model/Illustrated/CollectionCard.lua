CollectionCard = class("CollectionCard",Card)
function CollectionCard:ctor(cardPictureState)
  CollectionCard.super.ctor(self)
  self:setState("NotMeeted")
end
-- required int32 id = 1;
--  enum State {
--    HasMeeted = 0;
--    HasOwned = 1;
--  };
--  required State state = 2;

function CollectionCard:setState(State)
	self._State = State
end

function CollectionCard:getState()
	return self._State
end

return CollectionCard