local error_type = enum({"USERDEFINED","GLOBAL","TALENT_BLANK","EQUIPMENT","ARENA","ACTIVITYBOSS"} )
local errlist={
	[error_type.GLOBAL] ={
		NEED_MORE_COIN = "need_more_coin",
		NEED_MORE_MONEY= "need_more_money",
		NEED_MORE_POINT= "need_more_tallent",
		PLAYER_LEVEL_LIMIT = "player_level_limit",	
		SYSTEM_ERROR= "system error"
	},
	[error_type.TALENT_BLANK] = {
		BANK_IN_LEVEL_UP= Consts.Strings.ERROR_BANK_IN_LEVEL_UP,
		BANK_NOT_LEVEL_UP = Consts.Strings.ERROR_BANK_NOT_LEVEL_UP,
		BANK_MAX_LEVEL=	Consts.Strings.ERROR_BANK_MAX_LEVEL, 
		ERROR_BANK_FULL = Consts.Strings.ERROR_BANK_FULL,
		NEED_USED_MORE_POINT= Consts.Strings.ERROR_TALENT_NEED_MORE,
		NEED_CONDITION_TALENT = Consts.Strings.ERROR_TALENT_NEED_CONDITION, 
		OTHER_TALENT_LEVEL_UP= Consts.Strings.ERROR_TALENT_OTHER_LEVEL_UP,
		TALENT_NOT_LEVEL_UP	= Consts.Strings.ERROR_TALENT_NOT_LEVEL_UP,
		NOT_FOUND_TALENT = Consts.Strings.ERROR_TALENT_NOT_FOUND,
		TALENT_IS_LEARED= Consts.Strings.ERROR_TALENT_IS_LEARED,
		ERROR_NO_PRODUCT = Consts.Strings.ERROR_TALENT_NO_PRODUCT,
		TALENT_ID_NOT_LEARN = Consts.Strings.ERROR_TALENT_ID_NOT_LEARN 
	},
	[error_type.EQUIPMENT] = {
		NotEnoughCurrency = Consts.Strings.ERROR_EQUIPMENT_NOTENOUGHCURRENCY,
		CouldNotEatAnyMore = Consts.Strings.ERROR_EQUIPMENT_COULDNOTEATANYMORE,
		ItemCannotEat = Consts.Strings.ERROR_EQUIPMENT_ITEMCANNOTEAT,
		NotHaveItemToEat  = Consts.Strings.ERROR_EQUIPMENT_NOTHAVEITEMTOEAT,
		EquipCanNotUpgrade = Consts.Strings.ERROR_EQUIPMENT_EQUIPCANNOTUPGRADE,
		CouldNotEatAnyMoreSuc = Consts.Strings.ERROR_EQUIPMENT_COULDNOTEATANYMORESUC, 
		ExpNotEnough = Consts.Strings.ERROR_EQUIPMENT_EXPNOTENOUGH,
		NoSuchEquip = Consts.Strings.ERROR_EQUIPMENT_NOSUCHEQUIP,
		NeedMoreItem = Consts.Strings.ERROR_EQUIPMENT_NEEDMOREITEM, 
		NoSuchConfigId = Consts.Strings.ERROR_EQUIPMENT_NOSUCHCONFIGID,	
		CanNotAllLocked = Consts.Strings.ERROR_EQUIPMENT_CANNOTALLLOCKED, 
		CanNotXiLian = Consts.Strings.ERROR_EQUIPMENT_CANNOTXILIAN, 
		PropIndexError = Consts.Strings.ERROR_EQUIPMENT_PROPINDEXERROR, 
		QualityLimit = Consts.Strings.ERROR_EQUIPMENT_QUALITYLIMIT 
	},
	[error_type.ARENA] = {
		NOT_OPEN_TIME = "NOT_OPEN_TIME",
		LEVEL_LIMIT   = "player_level_limit",
		LIMIT_SEARCH = "LIMIT_SEARCH"
	},
	[error_type.ACTIVITYBOSS] = {
		NOT_NEED_CLEAR = "noneed_clear_again",
		NOT_ENABLE = "boss_not_open"
	}
}
local is_not_init=true
ServerError={
	Type=error_type,
	_init_check=function()
		if(is_not_init) then
			for n,sub in pairs(errlist) do
				for n,v in pairs(sub) do
					sub[n] = _tr(v)
				end
			end
			is_not_init = nil
		end
	end,
	GetOrShowDescrible=function(codeOrMsg,bShow,type)
		--ServerError._init_check()
		local str
		if (type==nil or type ==error_type.USERDEFINED ) then
			str = codeOrMsg 
		end

		local msgtype = errlist[type] 
		if (msgtype) then
			str = msgtype[codeOrMsg]
		end
		if (str == nil) then
			str = errlist[error_type.GLOBAL][codeOrMsg]
		end

		local ret=true

		if (str == nil)	then
			str = _tr("system error").."(" .. codeOrMsg ..")"
			ret = false
		end
		if (bShow) then
			Toast:showString(GameData:Instance():getCurrentScene(),str, ccp(display.cx, display.cy))
		else
			str = string._tran(str)
		end
		return ret ,str
	end
}
