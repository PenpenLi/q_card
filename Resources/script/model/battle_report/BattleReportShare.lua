BattleReportShare = class("BattleReportShare")

--[[
enum FightType{
  PVE_NORMAL = 0;       //副本
  PVP_NORMAL = 1;     //征战
  PVE_BOSS   = 2;     //BOSS战
  PVE_ACTIVITY = 3;     //活动副本
  PVP_REAL_TIME = 4;    //PVP实时战斗
  PVP_RANK_MATCH = 5;   //竞技场
  PVE_GUILD = 6;      //公会副本
  PVE_BABLE = 7;      //通天塔副本
}
]]

function BattleReportShare:ctor()
  local reports = {}
  self._reports = reports
  self._sharedReport = {}
end

function BattleReportShare:Instance()
  if BattleReportShare._BattleReportShareInstance == nil then
    BattleReportShare._BattleReportShareInstance = BattleReportShare.new()
    BattleReportShare._BattleReportShareInstance:regirstNetServer()
  end
  return BattleReportShare._BattleReportShareInstance
end

function BattleReportShare:regirstNetServer()
  net.registMsgCallback(PbMsgId.ReportShareS2C,self,BattleReportShare.onReportShareS2C)
  net.registMsgCallback(PbMsgId.PVPQueryReportReviewResult,self,BattleReportShare.onBattleReviewResult)
end

------
--  Getter & Setter for
--      BattleReportShare._IsFromChat 
-----
function BattleReportShare:setIsFromChat(IsFromChat)
	self._IsFromChat = IsFromChat
end

function BattleReportShare:getIsFromChat()
	return self._IsFromChat
end

------
--  Getter & Setter for
--      BattleReportShare._ReviewFightType 
-----
function BattleReportShare:setReviewFightType(ReviewFightType)
  self._ReviewFightType = ReviewFightType
end

function BattleReportShare:getReviewFightType()
  return self._ReviewFightType
end

function BattleReportShare:reqBattleReview(reviewId,fightType)
  if reviewId == nil then
    return
  end
  
  print("BattleReportShare:reqBattleReview,id:",reviewId)
  self:setReviewFightType(fightType)
  _showLoading()
  local data = PbRegist.pack(PbMsgId.PVPQueryReportReview,{review_id = reviewId})
  net.sendMessage(PbMsgId.PVPQueryReportReview,data)
end 

function BattleReportShare:appendReportShare(id,fightType)
  if self._sharedReport[fightType] == nil then
    self._sharedReport[fightType] = {}
  end
  table.insert(self._sharedReport[fightType],id)
end

function BattleReportShare:checkCanShare(id,fightType)
  local canShare = true
  if self._sharedReport[fightType] == nil then
    return canShare
  end
  
  for key, rid in pairs(self._sharedReport[fightType]) do
  	if rid == id then
  	 canShare = false
  	 break
  	end
  end
  
  return canShare
end


function BattleReportShare:onBattleReviewResult(action,msgId,msg)
  --[[enum ErrorCode{
   NO_ERROR_CODE = 1;
   NOT_FOUND_REVIEW = 2 ;
   SYSTEM_ERROR = 3;
  }
  required ErrorCode error = 1;
  optional ReportReview view = 2;]]
  
  print("BattleReportShare:onBattleReviewResult:",msg.error)
  _hideLoading()
  if msg.error == "NO_ERROR_CODE" then
    GameData:Instance():getCurrentScene():getDisplayContainer():removeAllChildrenWithCleanup(true)
    local controller = ControllerFactory:Instance():create(ControllerType.BATTLE_CONTROLLER)
    controller:enter(false,false,false)  
    controller:startReviewBattleWithResult(msg.view.result)
    --msg.view.result
  else
    print("Error:",msg.error)
  end
end 

function BattleReportShare:reqShareBattleReportShare(id,fightType)

  local canShare = self:checkCanShare(id,fightType)
  if canShare == true then
    self:appendReportShare(id,fightType)
    local data = PbRegist.pack(PbMsgId.ShareReportC2S,{ ft = fightType,report = id })
    net.sendMessage(PbMsgId.ShareReportC2S,data)
  end  
  Toast:showString(GameData:Instance():getCurrentScene(),_tr("report_shared"), ccp(display.cx, display.cy))
end

function BattleReportShare:onReportShareS2C(action,msgId,msg)
  --[[
  message ShareReport{
    enum ReportSource{
      SYSTEM = 1;   //来自玩家
      PLAYER = 2;   //来自系统
    }
    optional FightType ft = 1;        //战报类型
    optional int32 view = 2;        //录像Id
    optional RelationData attacker = 3;   //进攻方
    optional RelationData defender = 4;   //防守方
    optional int32 other = 5;       //附带数据  如果FightType = Protocal::PVE_NORMAL  other = 副本ID
    optional ReportSource source = 6;     //来源
  }
  message ReportShareS2C{
    enum traits{ value = 5208;}
    repeated ShareReport share = 1;   //分享战报列表
    optional RelationData player = 2; //分享者
  }
  
  
  message RelationData{

  enum MDOperator{
    op_init = 0;
    op_add = 1;
    op_update = 2;
    op_remove = 3;
  }

  optional int32  id = 1;
  optional string name = 2;
  optional int32  level = 3;
  optional int32  avatar = 4;
  optional bool   is_on_line=5;
 
  optional int32  vip_level = 6;         //VIP
    
  optional int32  minerIdlePos = 7;   //空闲的矿场位置
  optional int32  minerPosCount = 8;  // 总计矿场位置 
  optional int32  last_logout_time = 9; // 最后一次登录时间
  
  optional int32 fight_value = 10; //战斗力
  optional int32 vip_exp = 11;  //vip exp 
  optional FriendHelpSimpleInfo help_info = 12;
  }
  ]]
  
  printf("BattleReportShare:onReportShareS2C")
  dump(msg.share)
  
  local share = msg.share
  for key, shareReport in pairs(share) do
  	if shareReport.ft == "PVE_NORMAL" then
  	  local stage = Scenario:Instance():getStageById(shareReport.other)
  	  if stage ~= nil then
  	   stage:setReportInfo(shareReport)
  	  end
  	else
  	  local targetContainer = self._reports
      targetContainer[#targetContainer + 1] = shareReport
      
      local chatmsg = {}
      chatmsg.reportInfo = shareReport
      
      local sayer = msg.player
      if shareReport.source == "SYSTEM" then
        sayer = {}
        sayer.id = 1
        sayer.name = "SYSTEM"
        sayer.level = 100
        sayer.avatar = 0
        sayer.is_on_line = true
        sayer.vip_level = 0
        sayer.minerIdlePos = 0
        sayer.minerPosCount = 0
        sayer.last_logout_time = 0
        sayer.fight_value = 0
        sayer.vip_exp = 0
      end
      
      chatmsg.sayer = sayer
      chatmsg.channel = Chat.ChannelWorld
      --chatmsg.content = _tr("攻方【"..shareReport.attacker.name.."】 VS守方【"..shareReport.defender.name.."】")
      chatmsg.content = _tr("report_share_content",{attacker = shareReport.attacker.name,defender = shareReport.defender.name})
      Chat:Instance():onChatShareReport(chatmsg)
  	end
  end
  
end


function BattleReportShare:getReportsByFightType(fightType)
end
