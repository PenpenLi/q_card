
require("model.mail.Mail")

MailBox = class("MailBox")

MailBox._instance = nil 

function MailBox:ctor()
  net.registMsgCallback(PbMsgId.MsgS2CMailList,self,MailBox.updateMailsResult)
  net.registMsgCallback(PbMsgId.MailGetAdjunctResultS2C,self,MailBox.fetchAttachmentResutl)
end

function MailBox:instance()
  if MailBox._instance == nil then 
    MailBox._instance = MailBox.new()
  end
  return MailBox._instance
end

function MailBox:reset()
  self:setSystemMails({})
  self:setPrivateMails({})
end 

-- function MailBox:reqMails()
--   echo("---MailBox:reqMails---")
--   self.sysMails = {}
--   self.privateMails = {}

--   local data = PbRegist.pack(PbMsgId.MsgC2SQueryRelation,{query = "QUERY_MAIL"})
--   net.sendMessage(PbMsgId.MsgC2SQueryRelation,data)

--   -- --show waiting
--   -- self.loading = Loading:show()   
-- end

function MailBox:exit()
  echo("---MailBox:exit---")
  --net.unregistAllCallback(self)
end

function MailBox:insertMails(mailListdata)
  if mailListdata == nil then 
    return
  end

  for k, v in pairs(mailListdata) do
    local tbl = nil
    if v.sender <= 0 then --system mail
      tbl = self:getSystemMails()
    else 
      tbl = self:getPrivateMails()
    end

    local actionUpdate = false
    local mail = nil 
    local isRepeatEmail = false --断网后重复发的相同邮件标志
    for i=1, table.getn(tbl) do
      if v.id == tbl[i]:getId() then
        mail = tbl[i]
        if v.flag > 0 and mail:getIsNew() == true then --has read mail, just update
          echo(" update mail...")
          actionUpdate = true
        else 
          echo("=== repeate email, do noning...")
          isRepeatEmail = true  
        end 
        break
      end
    end

    if isRepeatEmail == false then 
      
      if mail == nil then
        mail = Mail.new()
        actionUpdate = false
      end
      
      mail:setId(v.id)
      mail:setSenderId(v.sender)
      mail:setTitle(v.title)
      mail:setContent(v.content)

      if v.flag == 0 then --new mail
        mail:setIsNew(true)
      else 
        mail:setIsNew(false)
      end
      mail:setCreatedTime(v.time)

      --attachment
      if v.adjuncts ~= nil then 
        local attArray = {}
        for m, t in pairs(v.adjuncts.adjuncts) do 
          mail:setAttachmentId(t.id)
          -- echo("===t.type", t.type, t.id, t.configId, t.count)
          local itemtype = nil 
          if t.type == "ADJ_COIN" then 
            itemtype = 4
          elseif t.type == "ADJ_MONEY" then 
            itemtype = 5            
          elseif t.type == "ADJ_ITEM" then 
            itemtype = 6
          elseif t.type == "ADJ_EQUIPMENT" then 
            itemtype = 7
          elseif t.type == "ADJ_CARD" then 
            itemtype = 8            
          elseif t.type=="ADJ_JIANGHUN" then --将魂
            itemtype = 20             
          elseif t.type=="ADJ_RANK_POINT" then --竞技场
            itemtype = 25 
          elseif t.type=="ADJ_GUILD_POINT" then --公会点
            itemtype = 26 
          elseif t.type=="ADJ_BABLE_POINT" then --通天塔货币
            itemtype = 27 
          elseif t.type == "ADJ_LOYALTY" then --民心
            itemtype = 28
          else 
            echo("invalid type of mail attachment !!")
          end
          
          if itemtype ~= nil then 
            if t.configId < 100 then 
              t.configId = itemtype 
            end 
            local attItem = {iType = itemtype, configId = t.configId, num = t.count}
            table.insert(attArray, attItem)
          end 
        end
        mail:setAttachment(attArray)
      end
      
      if actionUpdate == false then --new mail 
        table.insert(tbl, mail)
      end
    end 
  end
end 


function MailBox:updateMailsResult(action,msgId,msg)
  echo("MailBox:updateMailsResult: len=", #msg.mail.data)
  self:insertMails(msg.mail.data)
end

function MailBox:setSystemMails(tbl)
  self.sysMails = tbl
end 

function MailBox:getSystemMails()
  if self.sysMails == nil then 
    self.sysMails = {}
  end
  return self.sysMails
end

function MailBox:deleteMail(mail)
  if mail == nil then 
    return 
  end 

  local tbl = nil 
  if mail:getSenderId() <= 0 then --sys mail
    tbl = self:getSystemMails()
  else 
    tbl = self:getPrivateMails()
  end 

  for k, v in pairs(tbl) do 
    if v:getId() == mail:getId() then 
      table.remove(tbl, k)
      break
    end
  end
end 


function MailBox:getValidSystemMails() --news in 7 days

  return self:getSystemMails()
end 

function MailBox:setPrivateMails(tbl)
  self.privateMails = tbl
end 

function MailBox:getPrivateMails()
  if self.privateMails == nil then 
    self.privateMails = {}
  end
  return self.privateMails
end

function MailBox:getHasNewMailForSys()
 local tbl = self:getSystemMails()

  local hasNew = false 
  for i=1, table.getn(tbl) do 
    if tbl[i]:getIsNew() == true then 
      hasNew = true
      break
    end
  end
  
  return hasNew
end 

function MailBox:getHasNewMailForPriv()
  local tbl = self:getPrivateMails()

  local hasNew = false 
  for i=1, table.getn(tbl) do 
    if tbl[i]:getIsNew() == true then 
      hasNew = true
      break
    end
  end

  return hasNew
end

function MailBox:getNewestMails(tbl, NumLimit)
  if tbl == nil then 
    return
  end

  local endIdx = table.getn(tbl)
  if endIdx <= NumLimit then 
    return
  end

  --sort by time
  for i=1, endIdx-1 do 
    local k = i 
    for j=i+1, endIdx do 
      if tbl[k]:getCreatedTime() < tbl[j]:getCreatedTime() then 
        k = j
      end
    end  
    if k > i then 
      local tmp = tbl[k]
      tbl[k] = tbl[i]
      tbl[i] = tmp 
    end
  end

  for i = NumLimit+1, endIdx do 
    tbl[i] = nil
  end
end


function MailBox:sortMails(mailArray)
  if mailArray == nil or table.getn(mailArray) < 1 then 
    return
  end

  local function sortByTime(tbl, startIdx, endIdx)
    if endIdx <= startIdx then 
      return 
    end
    for i=startIdx, endIdx-1 do 
      local k = i 
      for j=i+1, endIdx do 
        if tbl[k]:getCreatedTime() < tbl[j]:getCreatedTime() then 
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

  --sort by attachment
  local num = table.getn(mailArray)
  for i=1, num-1 do 
    local k = i 
    for j=i+1, num do 
      if table.getn(mailArray[k]:getAttachment()) == 0 and table.getn(mailArray[j]:getAttachment()) > 0 then 
        k = j
      end
    end  
    if k > i then 
      local tmp = mailArray[k]
      mailArray[k] = mailArray[i]
      mailArray[i] = tmp 
    end
  end

  --sort for attachment and normal mails
  local startIdx = 1 
  local preType = table.getn(mailArray[startIdx]:getAttachment()) > 0 
  for i = startIdx+1, num do
    local curType = table.getn(mailArray[i]:getAttachment()) > 0 
    if i < num then 
      if curType ~= preType then 
        sortByTime(mailArray, startIdx, i-1)

        startIdx = i
        preType = curType
      end
    else 
      if curType ~= preType then 
        sortByTime(mailArray, startIdx, i-1)
      else
        sortByTime(mailArray, startIdx, i)
      end
    end
  end   
end 


function MailBox:setView(view)
  self._curView = view 
end 

function MailBox:getView()
  return self._curView 
end

function MailBox:fetchAttachmentResutl(action,msgId,msg)
  echo("---fetchAttachmentResutl: result=", msg.error)

  if msg.error == "NO_ERROR_CODE" then 
    local tbl = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client)
    if tbl ~= nil then
      local offsetY = (table.getn(tbl) - 1) * 50
      for k,v in pairs(tbl) do 
        local numStr = string.format("+%d", v.count)
        offsetY = offsetY - 90
        Toast:showIconNumWithDelay(numStr, v.iconId, v.iType, v.configId, ccp(display.cx, display.cy + offsetY), 0.5*(k-1))
      end
      
      _playSnd(SFX_ITEM_ACQUIRED)
    end

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)

  elseif msg.error == "NOT_FOUND_MAIL" then 
    Toast:showString(self, _tr("no such mail"), ccp(display.cx, display.cy))
  elseif msg.error == "NOT_FOUND_ADJUNCT" then 
    Toast:showString(self, _tr("no attach"), ccp(display.cx, display.cy))
  elseif msg.error == "ITEM_BAG_FULL" then 
    Toast:showString(self, _tr("bag is full"), ccp(display.cx, display.cy))
  elseif msg.error == "CARD_BAG_FULL" then 
    Toast:showString(self, _tr("card bag is full"), ccp(display.cx, display.cy))
  elseif msg.error == "EQUIP_BAG_FULL" then
    Toast:showString(self, _tr("equip bag is full"), ccp(display.cx, display.cy))
  end

  if self:getView() then 
    self:getView():updateForFetch(msg.error)
  end 
end