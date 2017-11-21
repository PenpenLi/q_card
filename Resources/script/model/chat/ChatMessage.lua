require("model.PlayerRelation")
ChatMessage = class("ChatMessage")
function ChatMessage:ctor(msg)
  --[[
    message ChatS2C{
      enum traits{value = 5192;}
      optional RelationData sayer = 1;
      optional string content = 2;
      optional ChatC2S.Channel channel = 3;
  }
  ]]
  local player = PlayerRelation.new(msg.sayer)
  self:setPlayer(player)
  self:setContent(msg.content)
  self:setChannel(msg.channel)
  self:setTime(os.time())
end

------
--  Getter & Setter for
--      ChatMessage._ShareInfo 
-----
function ChatMessage:setShareInfo(ShareInfo)
	self._ShareInfo = ShareInfo
end

function ChatMessage:getShareInfo()
	return self._ShareInfo
end

------
--  Getter & Setter for
--      ChatMessage._Player 
-----
function ChatMessage:setPlayer(Player)
	self._Player = Player
end

function ChatMessage:getPlayer()
	return self._Player
end

------
--  Getter & Setter for
--      ChatMessage._Time 
-----
function ChatMessage:setTime(Time)
	self._Time = Time
end

function ChatMessage:getTime()
	return self._Time
end

------
--  Getter & Setter for
--      ChatMessage._Content 
-----
function ChatMessage:setContent(Content)
	self._Content = Content
end

function ChatMessage:getContent()
	return self._Content
end

------
--  Getter & Setter for
--      ChatMessage._Channel 
-----
function ChatMessage:setChannel(Channel)
	self._Channel = Channel
end

function ChatMessage:getChannel()
	return self._Channel
end

return ChatMessage