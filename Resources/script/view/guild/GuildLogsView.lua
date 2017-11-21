GuildLogsView = class("GuildLogsView",PopModule)
local touchPriority = -256
function GuildLogsView:ctor()
  local size = CCSizeMake(615,880)
  self._popSize = size
  GuildLogsView.super.ctor(self,size)
  self:setNodeEventEnabled(true)
  self:setAutoDisposeEnabled(false)
  
  self:setTouchEnabled(true)
  self:addTouchEventListener(function() return true end,false, touchPriority, true)
end

function GuildLogsView:onEnter()
  GuildLogsView.super.onEnter(self)
  
  self:setTitleWithSprite(display.newSprite("#guild_log_title.png"))
  local guildStageRecords = Guild:Instance():getStageRecords() 
  --dump(guildStageRecords)
  
  local strs = {}
  if guildStageRecords ~= nil then
    for key, stages in pairs(guildStageRecords) do
      for key, logs in pairs(stages) do
      	 table.insert(strs,logs)
      end
    end
  end
  
  
  --[[local strs = {}
  for key, record in pairs(guildStageRecords) do
  	print("stage:",record.stage)
  	local stage = Scenario:Instance():getStageById(record.stage)
  	if stage ~= nil then
  	  for key, recordInfo in pairs(record.record) do
    	 	 local strTime = ""
         if recordInfo.time ~= nil then 
            local sec = os.time() - recordInfo.time
            if sec >= 0 then 
              if sec < 60 then
                strTime = _tr("just_now")
              elseif sec < 3600 then  --1小时内 
                strTime = _tr("%{miniute}ago", {miniute=math.max(1, math.floor(sec/60))})
              elseif sec < 24*3600 then --今天
                strTime = _tr("%{hour}hour_ago", {hour=math.floor(sec/3660)})
              elseif sec < 48*3600 then --昨天
                strTime = _tr("yesterday")
              elseif sec < 72*3600 then --前天
                strTime = _tr("before_yesterday")
              else 
                strTime = _tr("%{day}day_ago", {day=math.min(7, math.ceil(sec/(24*3660)))}) 
              end 
            end 
        end 
        --local str = recordInfo.name.."攻打了"..stage:getStageName(true).."造成了"..tostring(recordInfo.damage).."点伤害  "..strTime
        local stageName = stage:getStageName(false)
        local str = _tr("guild_log",{name = recordInfo.name,stage = stageName, damage = tostring(recordInfo.damage),time = strTime})
        table.insert(strs,str)
  	  end
  	end
  end
  ]]
  
  --[[
  message GuildInstanceRecord{
  message Record{
    optional int32 player = 2;      //玩家ID
    optional string name = 3;     //玩家名字
    optional int32 damage = 4;      //伤害
    optional int32 time = 5;      //时间
    optional int32 kill = 6;      //击杀
  }
  optional int32 stage = 1;   //副本ID
  repeated Record record = 2;   //副本记录
  }]]
  
  local function buildStr(str)
    local labelDesc = RichText.new(str, 520, 0, "Courier-Bold", 21)
    local textSize = labelDesc:getTextSize()
    return labelDesc,textSize
  end
  
  
  local function tableCellTouched(table,cell)
  end

  local function cellSizeForTable(table,idx)
    local str = strs[idx + 1]
    local _,size = buildStr(str)
    return size.height + 10,size.width
  end

  local function tableCellAtIndex(table, idx)
    print("tableCellAtIndex")
    local cell = table:cellAtIndex(idx)
    if nil ~= cell then
      cell:removeFromParentAndCleanup(true)
    end
    
    cell = CCTableViewCell:new()
    local str = strs[idx + 1]
    local label,size = buildStr(str)
    cell:addChild(label)
  
    return cell
  end

  local function numberOfCellsInTableView(val)
    return #strs
  end
  
  --build tableview
  local size = CCSizeMake(550,790)
  local tableView = CCTableView:create(size)
  --tableView:setContentSize(size)
  tableView:setDirection(kCCScrollViewDirectionVertical)
  --registerScriptHandler functions must be before the reloadData function
  --tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
  --tableView:registerScriptHandler(scrollViewDidZoom,CCTableView.kTableViewZoom)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
  
  self:getPopBg():addChild(tableView)
  tableView:setPositionX(40)
  tableView:setPositionY(20)

  tableView:setTouchPriority(-256)
  
end



return GuildLogsView