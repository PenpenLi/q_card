--ArenaConfig=setmetatable(
--	{
--		UPDATE_EVENT = "arena_update_event",
--		reset=function()
--			ArenaConfig._lastLevel = nil
--			ArenaConfig._laststate = nil
--		end,
--		CanOpenCheck=function ()
--			local level = GameData:Instance():getCurrentPlayer():getLevel()
--
--			local reqLevel = AllConfig.systemopen[22].type_value
--			local ret = level >= reqLevel
--			return  ret, ret and "" or string.format(Consts.Strings.HIT_OPEN_FEATURE,reqLevel,string._tran(Consts.Strings.HIT_CONTEST_NAME))
--		end,
--		setState =function(state,opendate,opentime)
--			if(ArenaConfig._laststate == state and ArenaConfig._lastopendate == opendate and ArenaConfig._lastopentime ==opentime ) then
--				return
--			end
--			ArenaConfig._laststate = state 
--			ArenaConfig._lastopentime = opentime
--			ArenaConfig._lastopendate = opendate
--			ArenaConfig._lastLevel = GameData:Instance():getCurrentPlayer():getLevel()
--		end
--	}
--	,{
--	__index=function(self,key)
--		if (key == "CurrentRankInfo")	then 
--			local level = self.CurrentLevel
--
--			for n,v in pairs(AllConfig.arena_rank) do
--				if (level>=v.rank_min_lv and level<=v.rank_max_lv) then
--					return v
--				end
--			end
--			ArenaConfig._laststate = nil
--			ArenaConfig._lastLevel= nil
--			return nil
--		elseif(key == "TotalSearchTimes")	then 
--			return self.CurrentRankInfo.search_max_count
--		elseif(key=="CurrentLevel") then
--			local level
--			if(ArenaConfig._laststate == 2 and ArenaConfig._lastLevel and ArenaConfig._lastLevel>=AllConfig.systemopen[22].type_value) then
--				level = ArenaConfig._lastLevel
--			else
--				level = GameData:Instance():getCurrentPlayer():getLevel()
--			end
--			return level
--		end
--	end
--	})
	
ArenaConfig = {}
	
ArenaConfig.UPDATE_EVENT = "arena_update_event"



