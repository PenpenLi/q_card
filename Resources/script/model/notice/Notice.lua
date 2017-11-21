Notice = class("Notice")
--NoticeMessageType = table({"item","card","equip","money","coin","name","card_star","keep_win","boss_id})
function Notice:ctor()
   net.registMsgCallback(PbMsgId.NoticeS2C,self,Notice.getedNotice)
   net.registMsgCallback(PbMsgId.SysNoticeBroadCast,self,Notice.sysNoticeBroadCastHandler)
   self:setNotices({})
end

function Notice:getedNotice(action,msgId,msg)
     echo("~~~~~~~~~~~~~~~~~~get notice~~~~~~~~~~~~~~~~~")
     local tag = {"{^1}", "{^2}","{^3}","{^4}","{^5}"}
     local coulorTag = "{^s}"
--     local noticMessages = {"{^1}打开{^2}获得了{^3}",
--     "{^1}通过祭天点将获得了1张{^2}",
--     "{^1}将{^2}星武将{^3}转生至{^4}星",
--     "{^1}征战中打败了{^2}获得了{^3}连胜",
--     "{^1}征战中终结了{^2}的{^3}连胜"
--     }
--     if msg.notice ~= nil then
      --assert(false)
      
--      local descStr = noticMessages[msg.notice.id]
--      for key, noticeData in pairs( msg.notice.data) do
--         local str = ""
--         if noticeData.type == "name" then
--            echo("playName:",noticeData.str)
--            str = noticeData.str
--         elseif noticeData.type == "item" then
--            str = AllConfig.item[noticeData.data].item_name
--         elseif noticeData.type == "card" then
--            echo("cardId",noticeData.data)
--            local unitName = AllConfig.unit[noticeData.data].unit_name
--            str = unitName
--         elseif  noticeData.type == "card_star" then
--            str = tostring(noticeData.data)
--         elseif noticeData.type == "equip" then
--            local equipName = AllConfig.equipment[noticeData.data].name
--            str = equipName
--         elseif noticeData.type == "money" then
--            str = tostring(noticeData.data)
--         elseif noticeData.type == "coin" then
--            str = tostring(noticeData.data)
--         end
--         descStr = string.gsub(descStr, tag[key],str)
--      end
--      
--      echo(descStr)
   if msg.notice ~= nil then
      local descStr = AllConfig.desc[msg.notice.id].desc
      for key, noticeData in pairs(msg.notice.data) do
         local str = ""
         if noticeData.type == "name" then
            str = AllConfig.colour[1].word_colour
            str = string.gsub(str, coulorTag,noticeData.str)
            echo("name:",noticeData.str)
         elseif noticeData.type == "item" then
            str = AllConfig.colour[2].word_colour
      	    str = string.gsub(str, coulorTag,AllConfig.item[noticeData.data].item_name)
      	 elseif noticeData.type == "card" then
      	    local unitName = AllConfig.unit[noticeData.data].unit_name
      	    if AllConfig.unit[noticeData.data].card_rank == 2 then
      	       str = AllConfig.colour[3].word_colour
      	    elseif AllConfig.unit[noticeData.data].card_rank == 3 then
      	       str = AllConfig.colour[4].word_colour
      	    elseif AllConfig.unit[noticeData.data].card_rank == 4 then
      	       str = AllConfig.colour[5].word_colour
      	    end
      	    str = string.gsub(tostring(str), coulorTag,unitName)
      	 elseif  noticeData.type == "card_star" then
            str = tostring(noticeData.data + 1)
         elseif noticeData.type == "keep_win" then
            str = tostring(noticeData.data)
         elseif noticeData.type == "equip" then
            --str = AllConfig.unit[noticeData.data].name
            local equipName = AllConfig.equipment[noticeData.data].name
            if AllConfig.equipment[noticeData.data].equip_rank == 2 then
               str = AllConfig.colour[3].word_colour
            elseif AllConfig.equipment[noticeData.data].equip_rank == 3 then
               str = AllConfig.colour[4].word_colour
            elseif AllConfig.equipment[noticeData.data].equip_rank == 4 then
               str = AllConfig.colour[5].word_colour
            end
            str = string.gsub(str, coulorTag,equipName)
         elseif noticeData.type == "money" then
            str = tostring(noticeData.data)
         elseif noticeData.type == "coin" then
            str = tostring(noticeData.data)
         elseif noticeData.type == "boss_id" then
            str = AllConfig.bossinitdata[noticeData.data].event_name
         end
         --echo("str:~~~~~~~~~~~~~~~~~~~~~~~~~",noticeData.type,str)
      	 descStr = string.gsub(descStr, tag[key],str)
      	 --echo(descStr)
      end
      
      --descStr = string.gsub(AllConfig.colour[7].word_colour, coulorTag,descStr)
      table.insert(self:getNotices(),descStr)
      echo(descStr)
   end
   
end

function Notice:sysNoticeBroadCastHandler(action,msgId,msg)
   echo("~~~~~~~~~~~~~~~~~~get GM notice~~~~~~~~~~~~~~~~~",msg.str)
   if msg.str ~= nil then
      table.insert(self:getNotices(),msg.str)
   end
end

------
--  Getter & Setter for
--      Notice._Notices 
-----
function Notice:setNotices(Notices)
	self._Notices = Notices
end

function Notice:getNotices()
	return self._Notices
end

function Notice:getRandomLocalNotice()
  local randomId = math.random(1,#AllConfig.help_notice)
  return AllConfig.help_notice[randomId].desc
end

return Notice