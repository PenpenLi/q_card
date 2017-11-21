require("view.chat.ChatView")
require("model.chat.ChatMessage")
Chat = class("Chat")
Chat.ChannelPlayer = "TO_PLAYER"
Chat.ChannelWorld = "TO_WORLD"
Chat.ChannelGuild = "TO_GUILD"
function Chat:ctor()
  local messages = {}
  messages[Chat.ChannelPlayer] = {}
  messages[Chat.ChannelWorld] = {}
  messages[Chat.ChannelGuild] = {}
  self._messages = messages
  self:setHasNewMessage(false)
end

function Chat:Instance()
  if Chat._ChatInstance == nil then
    Chat._ChatInstance = Chat.new()
    Chat._ChatInstance:regirstNetServer()
  end
  return Chat._ChatInstance
end

function Chat:regirstNetServer()
  net.registMsgCallback(PbMsgId.ChatS2C,self,Chat.onChatS2C)
end

------
--  Getter & Setter for
--      Chat._ChatView 
-----
function Chat:setChatView(ChatView)
	self._ChatView = ChatView
end

function Chat:getChatView()
	return self._ChatView
end

------
--  Getter & Setter for
--      Chat._HasNewMessage 
-----
function Chat:setHasNewMessage(HasNewMessage)
	self._HasNewMessage = HasNewMessage
end

function Chat:getHasNewMessage()
	return self._HasNewMessage
end

function Chat:onChatShareReport(msg)
  local message = ChatMessage.new(msg)
  message:setShareInfo(msg.reportInfo)
  table.insert(self._messages[msg.channel],message)
  
  self:setHasNewMessage(true)
  
  if self:getChatView() ~= nil then
    self:getChatView():updateView(msg.channel)
  end
  
end

function Chat:onChatS2C(action,msgId,msg)
  print("Chat:onChatS2C")
  print("channel:"..msg.channel)
  print("content:"..msg.content)
  print("time:"..os.time())
  local message = ChatMessage.new(msg)
  table.insert(self._messages[msg.channel],message)
  
  self:setHasNewMessage(true)
  
  if self:getChatView() ~= nil then
    self:getChatView():updateView(msg.channel)
  end
  --[[
    message ChatS2C{
      enum traits{value = 5192;}
      optional RelationData sayer = 1;
      optional string content = 2;
      optional ChatC2S.Channel channel = 3;
  }
  ]]
end

function Chat:reqChatC2S(content,player,channel)
--[[
  message ChatC2S{
  enum traits{value = 5191;}
  enum Channel{
    TO_PLAYER = 1;    //玩家私聊
    TO_WORLD = 2;   //全服
    TO_GUILD = 3;   //公会
  }
  optional string content = 2;
  optional int32 player = 1;
  optional Channel channel = 3;
  }
]]
  
  local data = PbRegist.pack(PbMsgId.ChatC2S,{content = content,player = player,channel = channel})
  net.sendMessage(PbMsgId.ChatC2S,data)
end

function Chat:getMessagesByChannel(channel)
  return self._messages[channel]
end

return Chat