require("model.PlayerRelation")
FriendData = class("FriendData",PlayerRelation)

function FriendData:ctor()
  FriendData.super.ctor(self)
end

function FriendData:setFriendId(id)
	self._id = id
end

function FriendData:getFriendId()
	return self._id
end

function FriendData:setName(name)
	self._name = name
end

function FriendData:getName()
	return self._name
end

function FriendData:setLevel(lv)
	self._friendLv = lv
end

function FriendData:getLevel()
	return self._friendLv
end

function FriendData:setAvatar(avatarId)
	local unitRoot = avatarId -- GameData:Instance():getCurrentPlayer():getAvatar()
	local unit_head_pic = 0
	if unitRoot <= 1 then
		unit_head_pic = 3012502
	else
		local cardConfigId = tonumber(unitRoot.."01")
		unit_head_pic = AllConfig.unit[cardConfigId].unit_head_pic
	end
	self._avatarId = unit_head_pic
end

function FriendData:getAvatarId()
	return self._avatarId
end

function FriendData:setIsOnLine(isOnLine)
	self._isOnLine = isOnLine
end

function FriendData:getIsOnLine()
	return self._isOnLine
end

function FriendData:setRankId(id) --军衔id
	self._rankId = id
end

function FriendData:getRankId()
	return self._rankId
end

function FriendData:setAchievement(num)
	self._achievement = num
end 

function FriendData:getAchievement()
	return self._achievement
end 

function FriendData:setScore(score)
	self._score = score
end 

function FriendData:getScore()
	return self._score
end 

function FriendData:setMaxScore(score)
	self._maxScore = score
end

function FriendData:getMaxScore()
	return self._maxScore
end

function FriendData:setVipLevel(level)
	self._vipLevel = level
end

function FriendData:getVipLevel()
	return self._vipLevel or 0 
end

function FriendData:setMinerIdleCount(count)
	self._idelMinerCount = count
end

function FriendData:getMinerIdleCount()
	return self._idelMinerCount
end


function FriendData:setMinerMaxCount(count)
	self._maxMinerCount = count
end

function FriendData:getMinerMaxCount()
	return self._maxMinerCount
end

function FriendData:getMaxRank() --最高军衔
	local maxRankName = ""
	local maxScore = self:getMaxScore()
	if maxScore ~= nil then 
		for k, v in pairs(AllConfig.rank) do 
			if maxScore >= v.min_point and maxScore <= v.max_point then 
				maxRankName = v.sub_rank_name
				break
			end
		end
	end 
	return maxRankName
end

function FriendData:getOfficialTitle() --官职
	local point = self:getAchievement()
	local positionData = AllConfig.position
	local len = #positionData 
	local curIdx = 0 
	for i=1, len do 
		if point >= positionData[i].achievement_point then 
			curIdx = i 
		end 
	end 

	if curIdx < 1 then 
		return _tr("none")
	end 
	
	return positionData[curIdx].position_name
end

function FriendData:setLastLogoutTime(time)
	self._lastLogoutTime = time
end

function FriendData:getLastLogoutTime()
	return self._lastLogoutTime 
end


return FriendData