TalentData = class("TalentData",{Instance = Object.getInstance})
local talentData = {
	talentConfigInit = function ()

		if (AllConfig.talentTree ==nil) then
			local thisConfig={}
			local rootMap={}
			local rootStartID={}

			local function _newItem(root_id,start_id)
				return {["start_id"] = start_id,["ID"] = root_id }
			end
			--wait for real data

			for k,v in pairs(AllConfig.talent_initial_id) do
				thisConfig[k] = _newItem(k,v.start_id)
			end

			for k,v in pairs(AllConfig.talent) do
				local mainkey = tonumber(v.talent_root)
				thisConfig[mainkey] = thisConfig[mainkey] or  _newItem(v.talent_root,0)

				local item = Object.Extend(v,{
					sum_talent_point_for_pre = 0,
					levelup_time = {
						talent_next_level_time = v.talent_next_level_time,
						clear_cd_cost = v.clear_cd_cost
					}, --AllConfig.talent_levelup_time[v.level],
					skill_item = (function ()
						--if(v.type~=3 and v.type~=4) then
						--	return AllConfig.cardskill[v.skill]	 or false
						--else
						--	local item =  AllConfig.talentskill[v.skill]
						--	if (item) then
						--		return Object.Extend(item,{["skill_type"]=v.type})
						--	end
						--	return false						
						--end
					
						local ret = AllConfig.cardskill[v.skill]
						if (v.type==3 or v.type==4) then
							local talentSkillPara =  AllConfig.talentskill[v.skill]
							talentSkillPara = talentSkillPara and talentSkillPara.para or nil
							ret= Object.Extend(ret,{["para"] = talentSkillPara }) 
						end
						return ret
					end)(),

					root=false,
					next=false,
					pre=false
				})
				if (not (item.skill_item)) then
					printf("talent %d is not found , type is %d",v.skill,v.type)
					item.skill_item = AllConfig.talentskill[530101]
				end
				thisConfig[mainkey][v.level]=item
				thisConfig[mainkey].max_level = item.max_level
				rootMap[tonumber(k)] = item
			end

			for rootid,rootitem in pairs(thisConfig) do
				for level,item in ipairs(rootitem) do
					item.sum_talent_point_for_pre =	 item.sum_talent_point_for_pre or 0
					item.root = rootitem
					local nextid = item.next_id
					if (nextid and nextid ~=0)  then
						local nextitem = rootMap[nextid]
						assert(nextitem and nextitem.talent_root == item.talent_root,"talent_root id of next talent is not same")
						nextitem.pre = item
						item.next = nextitem

						nextitem.sum_talent_point_for_pre = item.sum_talent_point_for_pre + item.talent_point
					end
				end
			end

			local init_config={}
			for k,v in pairs(AllConfig.talent_init) do
				init_config[v.name] = v.data 
			end
			--AllConfig.talent = nil
			AllConfig.talentTree = thisConfig
			AllConfig.talentRootMap = rootMap
			AllConfig.talentSystemConfig = init_config
		end
		--return AllConfig.talentTree,AllConfig.talentRootMap 
	end
}

function TalentData:ctor()
	talentData.talentConfigInit()
end

function TalentData.GetTalentConfig()
	return AllConfig.talentTree,AllConfig.talentRootMap
end

