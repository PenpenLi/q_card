
Mail = class("Mail")


function Mail:ctor()
end


function Mail:setId(id)
  self._id = id
end 

function Mail:getId()
  return self._id
end 

function Mail:setSenderId(id)
  self._senderId = id

  --default
  self:setSenderIconId(3011401)
  self:setSenderName("")

  if id == 0 then --system mail
    self:setSenderName(_tr("sys msg"))
  elseif id == -1 then 
    self:setSenderName(_tr("guild_message"))
  else 
    local friendListArray = Friend:Instance():getCurrentFriend()
    if friendListArray ~= nil then 
      for i=1, table.getn(friendListArray) do 
        if friendListArray[i]:getFriendId() == id then 
          self:setSenderIconId(friendListArray[i]:getAvatarId())
          self:setSenderName(friendListArray[i]:getName())
          break
        end
      end
    end 
  end
end 

function Mail:getSenderId()
  return self._senderId
end 

function Mail:setSenderIconId(id)
  self._iconId = id
end 

function Mail:getSenderIconId()
  if self._iconId == nil then 
    echo("nil iconid !!!!!, use default icon.")
    self._iconId = 3011401
  end

  return self._iconId
end 

function Mail:setSenderName(name)
  self._senderName = name
end

function Mail:getSenderName()
  return self._senderName or ""
end

function Mail:setContent(str)
  self._content = str
end

function Mail:getContent()
  return self._content or ""
end

function Mail:setTitle(title)
  self._title = title
end

function Mail:getTitle()
  return self._title or ""
end 

function Mail:setAttachmentId(id)
  self._attachmentId = id
end 

function Mail:getAttachmentId()
  return self._attachmentId
end

function Mail:setAttachment(attachArray)
  self._attachmentArray = attachArray
end

function Mail:getAttachment()
  if self._attachmentArray == nil then 
    self._attachmentArray = {}
  end
  return self._attachmentArray
end

function Mail:setIsNew(isNew)
  self._isNew = isNew
end 

function Mail:getIsNew()
  return self._isNew
end 

function Mail:setCreatedTime(time)
  self._createdTime = time
end

function Mail:getCreatedTime()
  return self._createdTime
end

function Mail:getLeftHours()
  local leftHours = 0
  local curTime = Clock:Instance():getCurServerUtcTime()
  local endTime = 168 * 3600 + self._createdTime
  local leftSec = endTime - curTime
  if curTime < endTime then 
    leftHours = math.ceil((endTime - curTime)/3600)
  end

  return leftHours, leftSec
end










