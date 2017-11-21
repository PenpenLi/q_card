
require("view.BaseView")
require("view.component.TipsInfo")


PopupType = enum({"NONE", "INPUT_NUMBER_BUY","INPUT_NUMBER_SALE","INPUT_NUMBER_USE", 
                  "INPUT_NUMBER_MERGE", "INPUT_NUMBER_EXCHANGE", "REWORD_SOMETHING", "BONUS","TEXT_STRING",
                  "FILTER_ITEMS", "RANK_LIST", "WORKING_TIME","FRIEND_INFO"})






PopupView = class("PopupView",BaseView)

PopupView.popType = PopupType.NONE
PopupView.number = 1
PopupView.maxNum = 1
PopupView.price = 0
PopupView.confirmCallback = nil 

PopupView.propsArray = {}
PopupView.totalCells = 0
PopupView.cellWidth = 0
PopupView.cellHeight = 0
PopupView.isTouchEnd = true 
PopupView.touchMoveDirection = 1  ---1:down  , 2: up

PopupView.PRIORITY = -300

local startScale = 0.5
local duration = 0.5

function PopupView:ctor()
  self:setNodeEventEnabled(true)
  local pkg = ccbRegisterPkg.new(self)
  pkg:addProperty("layer_mask","CCLayerColor")
  pkg:addProperty("node_pop1","CCNode")
  pkg:addProperty("node_pop2","CCNode")  
  pkg:addProperty("node_pop3","CCNode")
  pkg:addProperty("node_pop4","CCNode")
  pkg:addProperty("node_pop5","CCNode")
  pkg:addProperty("node_pop6","CCNode")
  pkg:addProperty("node_pop7","CCNode")
  pkg:addProperty("node_pop8","CCNode")

  pkg:addProperty("node4_expFilter","CCNode")

  pkg:addProperty("node_content","CCNode")
  pkg:addProperty("node5_content","CCNode")
  pkg:addProperty("pop_bg1","CCScale9Sprite")
  pkg:addProperty("pop_bg2","CCScale9Sprite")
  pkg:addProperty("pop_bg3","CCScale9Sprite")
  pkg:addProperty("pop_bg4","CCScale9Sprite")
  pkg:addProperty("pop_bg5","CCScale9Sprite")
  pkg:addProperty("pop_bg6","CCScale9Sprite")
  pkg:addProperty("pop_bg7","CCScale9Sprite")
  pkg:addProperty("pop_bg8","CCScale9Sprite")
  pkg:addProperty("sprite_input","CCScale9Sprite")

  pkg:addProperty("pop1_titleSprite","CCSprite")
  pkg:addProperty("pop1_coin","CCSprite")
  pkg:addProperty("pop1_money","CCSprite")
  pkg:addProperty("label_sub_1","CCLabelTTF")
  pkg:addProperty("label_sub_2","CCLabelTTF")
  pkg:addProperty("label_sub_3","CCLabelTTF")
  pkg:addProperty("label_pop1_buy_num","CCLabelTTF")
  pkg:addProperty("label_desc1","CCLabelTTF")
  pkg:addProperty("label_desc2","CCLabelTTF")
  pkg:addProperty("menu_pop1","CCMenuItemSprite")
  pkg:addProperty("bn_startReward","CCMenuItemSprite")
  pkg:addProperty("label_time","CCLabelTTF")
  pkg:addProperty("pop3_node","CCNode")
  pkg:addProperty("lable_pop3_content","CCLabelTTF")
  pkg:addProperty("lable3_taskName","CCLabelTTF")
  pkg:addProperty("label3_costMoney","CCLabelTTF")
  pkg:addProperty("title","CCSprite")
  pkg:addProperty("sprite2_arrow","CCSprite")
  pkg:addProperty("sprite5_title","CCSprite")
  pkg:addProperty("sprite5_arrow","CCSprite")
  pkg:addProperty("leftMenuItem","CCMenuItemSprite")
  pkg:addProperty("rightMenuItem","CCMenuItemSprite")

  pkg:addProperty("popup2RewardTitle","CCSprite")
  pkg:addProperty("confirmMenu","CCMenuItemSprite")

  pkg:addProperty("label3_complete","CCLabelTTF")
  pkg:addProperty("label3_coinCost","CCLabelTTF")
  pkg:addProperty("label4_expCard","CCLabelTTF")
  pkg:addProperty("label4_star1","CCLabelTTF")
  pkg:addProperty("label4_star2","CCLabelTTF")
  pkg:addProperty("label4_star3","CCLabelTTF")
  pkg:addProperty("label4_star4","CCLabelTTF")
  pkg:addProperty("label4_star5","CCLabelTTF")
  pkg:addProperty("label6_name1","CCLabelTTF")
  pkg:addProperty("label6_name2","CCLabelTTF")
  pkg:addProperty("label6_name3","CCLabelTTF")
  pkg:addProperty("label6_name4","CCLabelTTF")
  pkg:addProperty("label6_name5","CCLabelTTF")
  pkg:addProperty("label6_name6","CCLabelTTF")
  pkg:addProperty("label6_name7","CCLabelTTF")
  pkg:addProperty("label6_name8","CCLabelTTF")
  pkg:addProperty("label6_name9","CCLabelTTF")
  pkg:addProperty("label6_name10","CCLabelTTF")
  pkg:addProperty("label6_name11","CCLabelTTF")
  pkg:addProperty("label6_hurt1","CCLabelTTF")
  pkg:addProperty("label6_hurt2","CCLabelTTF")
  pkg:addProperty("label6_hurt3","CCLabelTTF")
  pkg:addProperty("label6_hurt4","CCLabelTTF")
  pkg:addProperty("label6_hurt5","CCLabelTTF")
  pkg:addProperty("label6_hurt6","CCLabelTTF")
  pkg:addProperty("label6_hurt7","CCLabelTTF")
  pkg:addProperty("label6_hurt8","CCLabelTTF")
  pkg:addProperty("label6_hurt9","CCLabelTTF")
  pkg:addProperty("label6_hurt10","CCLabelTTF")
  pkg:addProperty("label6_hurt11","CCLabelTTF")
  pkg:addProperty("label_order11","CCLabelTTF")

  pkg:addProperty("node8_head","CCNode")
  pkg:addProperty("label8_preName","CCLabelTTF")
  pkg:addProperty("label8_preId","CCLabelTTF")
  pkg:addProperty("label8_preRank","CCLabelTTF")
  pkg:addProperty("label8_preLevel","CCLabelTTF")
  pkg:addProperty("label8_preScore","CCLabelTTF")
  pkg:addProperty("label8_preMaxRank","CCLabelTTF")
  pkg:addProperty("label8_preWallHp","CCLabelTTF")  
  pkg:addProperty("label8_preHouseHp","CCLabelTTF")
  pkg:addProperty("label8_name","CCLabelTTF")
  pkg:addProperty("label8_Id","CCLabelTTF")
  pkg:addProperty("label8_rank","CCLabelTTF")
  pkg:addProperty("label8_level","CCLabelTTF")
  pkg:addProperty("label8_score","CCLabelTTF")
  pkg:addProperty("label8_maxRank","CCLabelTTF")
  pkg:addProperty("label8_wallHp","CCLabelTTF")
  pkg:addProperty("label8_houseHp","CCLabelTTF")
  pkg:addFunc("pop8SendMail",PopupView.sendMailCallback)
  pkg:addFunc("pop8DeleteFriend",PopupView.deleteFriendCallback)

  pkg:addFunc("decreseCallback",PopupView.decreseCallback)
  pkg:addFunc("increseCallback",PopupView.increseCallback)
  pkg:addFunc("maxCallback",PopupView.maxCallback)
  pkg:addFunc("OkCallback",PopupView.OkCallback)
  pkg:addFunc("inputCallback",PopupView.inputCallback)
  pkg:addFunc("closeCallback",PopupView.close)
  pkg:addFunc("rightCallback",PopupView.rightCallback)
  pkg:addFunc("pop4Confirm",PopupView.pop4Confirm)
  pkg:addFunc("pop4Callback1",PopupView.pop4Callback1)
  pkg:addFunc("pop4Callback2",PopupView.pop4Callback2)
  pkg:addFunc("pop4Callback3",PopupView.pop4Callback3)
  pkg:addFunc("pop4Callback4",PopupView.pop4Callback4)
  pkg:addFunc("pop4Callback5",PopupView.pop4Callback5)
  pkg:addFunc("pop4Callback6",PopupView.pop4Callback6)

  pkg:addFunc("startFetchReward",PopupView.startRewardCallback)
  pkg:addFunc("dismissCallback",PopupView.onDismissCallkback)

  pkg:addProperty("label7_time1","CCLabelTTF")
  pkg:addProperty("label7_time2","CCLabelTTF")
  pkg:addProperty("label7_time3","CCLabelTTF")
  pkg:addProperty("label7_time4","CCLabelTTF")

  local workRewardInfo = { "tq1", "mx1" ,"tq2","mx2","tq3" ,"mx3","tq4","mx4" , }
  local workRewardInfoNumLabels = table.getn(workRewardInfo)
  for i = workRewardInfoNumLabels,1,-1 do
	  pkg:addProperty(workRewardInfo[i],"CCLabelTTF")
  end

  pkg:addFunc("timeCallback1",PopupView.timeCallback1)
  pkg:addFunc("timeCallback2",PopupView.timeCallback2)
  pkg:addFunc("timeCallback3",PopupView.timeCallback3)
  pkg:addFunc("timeCallback4",PopupView.timeCallback4)
  pkg:addFunc("OKCallback7",PopupView.OKCallback7)

  pkg:addProperty("pop4Selected1","CCSprite")
  pkg:addProperty("pop4Selected2","CCSprite")
  pkg:addProperty("pop4Selected3","CCSprite")
  pkg:addProperty("pop4Selected4","CCSprite")
  pkg:addProperty("pop4Selected5","CCSprite")
  pkg:addProperty("pop4Selected6","CCSprite")

  pkg:addProperty("selectImg1","CCSprite")
  pkg:addProperty("selectImg2","CCSprite")
  pkg:addProperty("selectImg3","CCSprite")
  pkg:addProperty("selectImg4","CCSprite")
  pkg:addProperty("menu_Ok7","CCMenuItemSprite")
  
  pkg:addProperty("menu11","CCMenu")
  pkg:addProperty("menu12","CCMenu")
  pkg:addProperty("menu13","CCMenu")
  pkg:addProperty("menu14","CCMenu")
  pkg:addProperty("menu15","CCMenu")
  pkg:addProperty("menu2","CCMenu")
  pkg:addProperty("menu31","CCMenu")
  pkg:addProperty("menu32","CCMenu")
  pkg:addProperty("menu33","CCMenu")
  pkg:addProperty("menu41","CCMenu")
  pkg:addProperty("menu42","CCMenu")
  pkg:addProperty("menu43","CCMenu")
  pkg:addProperty("menu44","CCMenu")
  pkg:addProperty("menu51","CCMenu")
  pkg:addProperty("menu52","CCMenu")
  pkg:addProperty("menu6","CCMenu")
  pkg:addProperty("menu71","CCMenu")
  pkg:addProperty("menu72","CCMenu")
  pkg:addProperty("menu73","CCMenu")
  pkg:addProperty("menu81","CCMenu")
  pkg:addProperty("menu82","CCMenu")
  pkg:addProperty("menu83","CCMenu")

  local layer,owner = ccbHelper.load("PopupView.ccbi","PopupViewCCB","CCLayer",pkg)
  self:addChild(layer)

  self.label_pop1_buy_num:setString(string.format("%d",self.number))
  
  _registNewBirdComponent(111002,self.confirmMenu)
  
end


function PopupView:onEnter()
  if self.enabledExecuteNewBird ~= false then
    _executeNewBird(ControllerType.BAG_CONTROLLER)
  end
end


-------------------------------------------- User Api -------------------------------------------------
function PopupView:createInputPopup(popType, itemName, itemPrice, maxNum, confirmCallback, currencyType)
  local pop = PopupView.new()
  pop:init(1)
  pop:setMaxNum(maxNum)
  pop.confirmCallback = confirmCallback
  pop.price = itemPrice

  local menuSprite = nil  
  local frame = nil 
  local preFixStr = "\""
  if GameData:Instance():getLanguageType() == LanguageType.JPN then 
    preFixStr = ""
  end 
  local str3 = preFixStr.._tr("number")

  if popType == PopupType.INPUT_NUMBER_BUY then 
    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("shop-image-goumaiwupin.png")
    pop.label_sub_1:setString(_tr("buy")..preFixStr)
    pop.label_desc1:setString(_tr("total_cost"))
    pop.menu_pop1:setNormalImage(CCSprite:createWithSpriteFrameName("goumai.png"))
    pop.menu_pop1:setSelectedImage(CCSprite:createWithSpriteFrameName("goumai1.png"))
    
  elseif popType == PopupType.INPUT_NUMBER_SALE then
    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("inventory-image-chushouwupin.png")
    pop.label_sub_1:setString(_tr("sale")..preFixStr)
    pop.label_desc1:setString(_tr("total_sale"))
    pop.menu_pop1:setNormalImage(CCSprite:createWithSpriteFrameName("chushou.png"))
    pop.menu_pop1:setSelectedImage(CCSprite:createWithSpriteFrameName("chushou1.png"))

  elseif popType == PopupType.INPUT_NUMBER_USE then
    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("inventory-image-shiyongwupin.png")
    pop.label_sub_1:setString(_tr("use")..preFixStr)
    pop.label_desc1:setVisible(false)
    pop.label_desc2:setVisible(false)
    -- pop.label_desc1:setString("")
    -- pop.label_desc2:setString("")
    pop.menu_pop1:setNormalImage(CCSprite:createWithSpriteFrameName("shiyong.png"))
    pop.menu_pop1:setSelectedImage(CCSprite:createWithSpriteFrameName("shiyong1.png"))   

  elseif popType == PopupType.INPUT_NUMBER_MERGE then
    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("inventory-image-hechengwupin.png")
    pop.label_sub_1:setString(_tr("combine")..preFixStr)
    pop.label_desc1:setString(_tr("combine_cost"))
    pop.menu_pop1:setNormalImage(CCSprite:createWithSpriteFrameName("hecheng.png"))
    pop.menu_pop1:setSelectedImage(CCSprite:createWithSpriteFrameName("hecheng1.png"))

  elseif popType == PopupType.INPUT_NUMBER_EXCHANGE then
    frame = nil
    pop.label_sub_1:setString(_tr("exchange")..preFixStr)
    pop.label_desc1:setVisible(false)
    pop.label_desc2:setVisible(false)
    pop.menu_pop1:setNormalImage(CCSprite:createWithSpriteFrameName("bn_queding0.png"))
    pop.menu_pop1:setSelectedImage(CCSprite:createWithSpriteFrameName("bn_queding1.png"))    
  end
  if frame == nil then 
    pop.pop1_titleSprite:removeFromParentAndCleanup(true)
  else 
    pop.pop1_titleSprite:setDisplayFrame(frame)
  end 
  pop.label_sub_2:setString(itemName)

  pop.label_sub_3:setString(str3)

  

  local x1 = pop.label_sub_1:getPositionX()
  local w1 = pop.label_sub_1:getContentSize().width
  local w2 = pop.label_sub_2:getContentSize().width
  if GameData:Instance():getLanguageType() == LanguageType.JPN then 
    pop.label_sub_2:setPositionX(x1)
    pop.label_sub_1:setPositionX(x1+w2)
    pop.label_sub_3:setPositionX(pop.label_sub_1:getPositionX()+w1)
  else 
    pop.label_sub_2:setPositionX(x1+w1)
    pop.label_sub_3:setPositionX(x1+w1+w2)
  end 

  if popType ~= PopupType.INPUT_NUMBER_USE then
    pop.label_desc2:setString(string.format("%d", pop.number*itemPrice))
    local x, y = pop.label_desc1:getPosition()
    pop.label_desc2:setPosition(ccp(x+pop.label_desc1:getContentSize().width, y))

    if currencyType ~= nil then 
      if currencyType == 1 then  --coin 
        pop.pop1_coin:setVisible(true)
        pop.pop1_coin:setPositionX(pop.label_desc2:getPositionX()+pop.label_desc2:getContentSize().width+16)
      else 
        pop.pop1_money:setVisible(true)
        pop.pop1_money:setPositionX(pop.label_desc2:getPositionX()+pop.label_desc2:getContentSize().width+16)
      end 
    end 
  end
  pop:setPopVisible(popType)
  pop:initInputBox()



  --如下代码放到外面执行，否则引起输入框光标错位
  -- pop:setScale(startScale)
  -- pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
  return pop
end

function PopupView:createRewardPopup(propsTable)
  local pop = PopupView.new()
  pop:init(2)
  pop:setPopVisible(PopupType.REWORD_SOMETHING)
  pop:showRewordList(propsTable)
  pop:setScale(startScale)
  pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
  return pop
end

function PopupView:createBonusPopup(propsTable, confirmCallback, bShowLeftTime)
  local pop = PopupView.new()
  pop:init(2)
  pop.confirmCallback = confirmCallback
  pop:setPopVisible(PopupType.BONUS)
  pop:showRewordList(propsTable)
  if bShowLeftTime == nil or bShowLeftTime == true then 
    pop:showCountDownTime()
  end 
  pop:setScale(startScale)
  pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
  return pop
end


function PopupView:createTextPopup(textString, confirmCallback, oneBtn)
  local pop = PopupView.new()
  pop:init(3)
  pop.confirmCallback = confirmCallback
  pop:setPopVisible(PopupType.TEXT_STRING)
  pop:reAdjustHeightByText(textString)

  if oneBtn == true then 
    local x1 = pop.leftMenuItem:getPositionX()
    local x2 = pop.rightMenuItem:getPositionX()
    pop.rightMenuItem:setVisible(false)
    pop.leftMenuItem:setPositionX(x1 + (x2-x1)/2)
    pop.menu31:setTouchPriority(-1998)
    pop.menu32:setTouchPriority(-1999)
  end

  pop:setScale(startScale)
  pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
  return pop
end

function PopupView:createTaskPopup(taskName, money, confirmCallback)
  local pop = PopupView.new()
  pop:init(3)
  pop.confirmCallback = confirmCallback
  pop:setPopVisible(PopupType.TEXT_STRING)

  pop.pop3_node:setVisible(true)
  pop.lable_pop3_content:setVisible(false)
  pop.lable3_taskName:setString(taskName)
  pop.label3_costMoney:setString(string.format("%d", money))

  pop:setScale(startScale)
  pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
  return pop
end

function PopupView:createFilterPopup(confirmCallback)
  local pop = PopupView.new()
  pop:init(4)
  pop:setPopVisible(PopupType.FILTER_ITEMS)
  pop.confirmCallback = confirmCallback
  pop:pop4SelectIdx(-1)
  pop.node4_expFilter:setVisible(false)
  pop:setScale(startScale)
  pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
  return pop
end

function PopupView:createTextPopupWithPath(args)
	local args = args or {}
	local leftNorBtnPath = args.leftNorBtn or nil
	local leftSelBtnPath = args.leftSelBtn or nil
	local rightNorBtnPath = args.rightNorBtn or nil
	local rightSelBtnPath = args.rightSelBtn or nil
	local textString = args.text or nil
  local closeVisible = args.btnCloseVisible

	local pop = PopupView.new()
	pop.confirmCallback = args.leftCallBack or nil
	pop.rightCallBack = args.rightCallBack or nil
	pop:init(3)
  pop:setPopVisible(PopupType.TEXT_STRING)

  if closeVisible ~= nil and closeVisible == true then 
    pop.menu33:setVisible(true)
  end 

	if leftNorBtnPath ~= nil and leftSelBtnPath ~= nil then
		pop.leftMenuItem:setNormalImage(display.newSprite("#" .. leftNorBtnPath) )  --CCSprite:createWithSpriteFrameName(leftNorBtnPath)
		pop.leftMenuItem:setSelectedImage(display.newSprite("#" .. leftSelBtnPath)) --CCSprite:createWithSpriteFrameName(leftSelBtnPath)
	end

	if rightNorBtnPath ~= nil and rightSelBtnPath ~= nil then
		pop.rightMenuItem:setNormalImage(display.newSprite("#" ..rightNorBtnPath)) --CCSprite:createWithSpriteFrameName(rightNorBtnPath)
		pop.rightMenuItem:setSelectedImage(display.newSprite("#" ..rightSelBtnPath)) -- CCSprite:createWithSpriteFrameName(rightSelBtnPath)
	end

	if textString ~= nil then
		pop:reAdjustHeightByText(textString)
	end
	pop:setScale(startScale)
	pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )
	return pop
end

function PopupView:createRankListPopup(tbl, playerItem)
  local pop = PopupView.new()
  pop:init(6)
  pop:setPopVisible(PopupType.RANK_LIST)

  --show name and hurt info
  local nameArr = {pop.label6_name1, pop.label6_name2,pop.label6_name3,pop.label6_name4,pop.label6_name5,
                   pop.label6_name6, pop.label6_name7,pop.label6_name8,pop.label6_name9,pop.label6_name10}

  local hurtArr = {pop.label6_hurt1, pop.label6_hurt2,pop.label6_hurt3,pop.label6_hurt4,pop.label6_hurt5,
                   pop.label6_hurt6, pop.label6_hurt7,pop.label6_hurt8,pop.label6_hurt9,pop.label6_hurt10}


  local len = math.min(10, table.getn(tbl))
  if len >= 1 then 
    for i=1, len do
      nameArr[i]:setString(tbl[i].name)
      hurtArr[i]:setString(string.format(tbl[i].hurt))
    end

    -- pop.label_order11:setString(string.format(tbl[len].order))
     pop.label6_name11:setString(playerItem.name)
     pop.label6_hurt11:setString(playerItem.hurt)
  end
  
  return pop
end

function PopupView:createWorkTimePopup(confirmCallback)
  local pop = PopupView.new()
  pop.timeSelect1 = false
  pop.timeSelect2 = false
  pop.timeSelect3 = false
  pop.timeSelect4 = false
  pop.selectedIndex = 1

  pop:init(7)
  pop.confirmCallback = confirmCallback
  pop:setPopVisible(PopupType.WORKING_TIME)

  --set working time string
  local item = AllConfig.mineinitdata
  local tbl = {pop.label7_time1, pop.label7_time2, pop.label7_time3, pop.label7_time4 }
  local tbCoins = {pop.tq1,pop.tq2,pop.tq3,pop.tq4 }
  local tbLoyalty = {pop.mx1,pop.mx2,pop.mx3,pop.mx4}
  for i =1, math.min(4, table.getn(item)) do 
    if item[i].time < 3600 then 
      tbl[i]:setString(string.format("%d%s", item[i].time/60, _tr("minute")))
    else 
      tbl[i]:setString(string.format("%d%s", item[i].time/3600, _tr("hour")))
    end
  	local coins ,loyaltys = Mining:Instance():getRewardByTime(i)
  	tbCoins[i]:setString(coins)
  	tbLoyalty[i]:setString(loyaltys)
  end

  pop:setScale(startScale)
  pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))
  return pop
end

function PopupView:createFriendInfoPopup(friendMode, deleteCallback, bHideMenu)
  local pop = PopupView.new()
  pop:init(8)
  pop.deleteCallback = deleteCallback
  pop:setPopVisible(PopupType.FRIEND_INFO)
  --init info
  pop:initFriendInfo(friendMode, bHideMenu)
  pop:setScale(startScale)
  pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6))

  return pop
end
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------




function PopupView:init(popIndex)
  local menuTbl = {self.menu11, self.menu12, self.menu13, self.menu14, self.menu15, 
                    self.menu2, self.menu31, self.menu32, self.menu33, self.menu41,self.menu42,
                    self.menu43,self.menu44, self.menu51, self.menu52, self.menu6, self.menu71,
                    self.menu72,self.menu73, self.menu81, self.menu82, self.menu83
                  }

  for i=1, #menuTbl do 
    menuTbl[i]:setTouchPriority(PopupView.PRIORITY)
  end

  self:initLabel(popIndex)
  self:setInputMinVal(1)
  self:setPopIndex(popIndex)
  self.popBgArray = {self.pop_bg1,self.pop_bg2,self.pop_bg3,self.pop_bg4,self.pop_bg5,self.pop_bg6,self.pop_bg7,self.pop_bg8}

  self:setTouchCloseEnable(true)
  self:addTouchEventListener(function(event, x, y)

                                if event == "began" then
                                  self.isOutViewPre = self:checkTouchPosition(x, y)
                                  return true
                                elseif event == "ended" then
                                  local isOutView = self:checkTouchPosition(x, y)
                                  if isOutView == true and self.isOutViewPre == true then 
                                    self:close()
                                  end
                                end
                            end,
              false, PopupView.PRIORITY, true)

  self:setTouchEnabled(true)
end

function PopupView:initLabel(index)
  if index == 3 then 
    self.label3_complete:setString(_tr("pop_complete"))
    self.label3_coinCost:setString(_tr("pop_coinCost"))
  elseif index == 4 then 
    self.label4_expCard:setString(_tr("pop_expCard"))
    self.label4_star1:setString(_tr("pop_star_%{count}", {count=1}))
    self.label4_star2:setString(_tr("pop_star_%{count}", {count=2}))
    self.label4_star3:setString(_tr("pop_star_%{count}", {count=3}))
    self.label4_star4:setString(_tr("pop_star_%{count}", {count=4}))
    self.label4_star5:setString(_tr("pop_star_%{count}", {count=5}))
  elseif index == 8 then
	self.label8_preId:setString(_tr("unitName"))
    self.label8_preName:setString(_tr("pop_nickName"))
    self.label8_preRank:setString(_tr("pop_rank"))
    self.label8_preLevel:setString(_tr("pop_level"))
    self.label8_preScore:setString(_tr("pop_score"))
    self.label8_preMaxRank:setString(_tr("pop_official"))
    self.label8_preWallHp:setString(_tr("pop_wallHp"))
    self.label8_preHouseHp:setString(_tr("pop_houseHp"))
  end 
end 

function PopupView:checkTouchPosition(x, y)
  if self:getTouchCloseEnable() ~= true then 
    return false
  end

  local popIdx = self:getPopIndex()
  if popIdx <= #self.popBgArray then
    local bg = self.popBgArray[popIdx]
    local size = bg:getContentSize()
    local pos = bg:convertToNodeSpace(ccp(x,y))
    if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then 
      -- self:close()
      return true
    end
  end

  return false
end 

function PopupView:setPopIndex(idx)
  self._popIdx = idx
end 

function PopupView:getPopIndex()
  return self._popIdx
end 

function PopupView:setTouchCloseEnable(isEnable)
  self._touchCloseEnable = isEnable
end 

function PopupView:getTouchCloseEnable()
  return self._touchCloseEnable
end

function PopupView:setMaskColorAndOpacity(color, opacity)
  self.layer_mask:setColor(color)
  self.layer_mask:setOpacity(opacity)
end



function PopupView:initInputBox()

  local function editBoxTextEventHandle(strEventName,pSender)
  echo("==========================",strEventName)
    if strEventName == "began" then

    elseif strEventName == "changed" then
      --self.inputNum = toint(self.inputBox:getText())
      --self:updateBooks()
    elseif strEventName == "ended" then

    elseif strEventName == "return" then
      self.number = toint(self.inputBox:getText())
      if self.number > self.maxNum then 
        self.number = self.maxNum
      elseif self.number <= 0 then 
        self.number = self:getInputMinVal()
      end

      echo("---self.number=", self.number, self.price)
      self.label_pop1_buy_num:setString(string.format("%d",self.number))
      self.inputBox:setText(string.format("%d",self.number))
      self.label_desc2:setString(string.format("%d", self.number*self.price))
      self.pop1_coin:setPositionX(self.label_desc2:getPositionX()+self.label_desc2:getContentSize().width+16)   
      self.pop1_money:setPositionX(self.label_desc2:getPositionX()+self.label_desc2:getContentSize().width+16)        
    end
  end

  self.inputBox = UIHelper.convertBgToEditBox(self.sprite_input,string.format("%d",self.number),22,ccc3(69,20,1))
  self.inputBox:setMaxLength(6)
  self.inputBox:setInputMode(kEditBoxInputModeNumeric)
  self.inputBox:setTouchPriority(PopupView.PRIORITY)
  self.inputBox:registerScriptEditBoxHandler(editBoxTextEventHandle)
end 



function PopupView:showCountDownTime()

  local bonusInfo = GameData:Instance():getOnlineBonusArray()
  local curRecvIdx = GameData:Instance():getCurrentPlayer():getOnlineRewardCount() + 1
  if curRecvIdx > table.getn(bonusInfo) then 
    echo("showCountDownTime: has receive all rewards !!")
    self.bn_startReward:setEnabled(false)
    return
  end

  local player = GameData:Instance():getCurrentPlayer()
  local curTime = Clock:Instance():getCurServerUtcTime()
  local elapseTime = curTime - player:getOnlineRewardStartTime() + player:getOnlineRewardTime()
  local leftTime = bonusInfo[curRecvIdx].time - elapseTime

  if leftTime > 0 then
    self.bn_startReward:setEnabled(false)
    
    local function timerCallback(dt)
      leftTime = leftTime -1
      if leftTime <= 0 then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
        self.scheduler = nil 

        self.label_time:setString("")
        self.bn_startReward:setEnabled(true)
      else          
        local min = math.floor(leftTime/60.0)
        local sec = math.floor(leftTime%60.0)
        self.label_time:setString(string.format("%02d:%02d", min,sec))
      end
    end

    local _min = math.floor(leftTime/60.0)
    local _sec = math.floor(leftTime%60.0)
    self.label_time:setString(string.format("%02d:%02d", _min,_sec))

    self.scheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timerCallback, 1.0, false)
  end
end

function PopupView:setPopVisible(popType)
  echo("popType = ", popType)
  if PopupType.INPUT_NUMBER_BUY==popType or PopupType.INPUT_NUMBER_SALE==popType 
    or PopupType.INPUT_NUMBER_USE==popType or PopupType.INPUT_NUMBER_MERGE==popType
    or PopupType.INPUT_NUMBER_EXCHANGE ==popType then
    self.node_pop1:setVisible(true)
    self.node_pop2:setVisible(false)
    self.node_pop3:setVisible(false)
    self.node_pop4:setVisible(false)
    self.node_pop5:setVisible(false)
    self.node_pop6:setVisible(false)
    self.node_pop7:setVisible(false)
    self.node_pop8:setVisible(false)
  elseif PopupType.REWORD_SOMETHING == popType then
    self.node_pop1:setVisible(false)
    self.node_pop2:setVisible(true)
    self.node_pop3:setVisible(false)
    self.node_pop4:setVisible(false)
    self.node_pop5:setVisible(false)
    self.node_pop6:setVisible(false)
    self.node_pop7:setVisible(false)
    self.node_pop8:setVisible(false)
  elseif PopupType.TEXT_STRING == popType then
    self.node_pop1:setVisible(false)
    self.node_pop2:setVisible(false)
    self.node_pop3:setVisible(true)
    self.node_pop4:setVisible(false)
    self.node_pop5:setVisible(false)
    self.node_pop6:setVisible(false)
    self.node_pop7:setVisible(false)
    self.node_pop8:setVisible(false)
  elseif PopupType.FILTER_ITEMS == popType then
    self.node_pop1:setVisible(false)
    self.node_pop2:setVisible(false)
    self.node_pop3:setVisible(false)
    self.node_pop4:setVisible(true)
    self.node_pop5:setVisible(false)   
    self.node_pop6:setVisible(false)  
    self.node_pop7:setVisible(false)
    self.node_pop8:setVisible(false)
  elseif PopupType.BONUS == popType then
    self.node_pop1:setVisible(false)
    self.node_pop2:setVisible(false)
    self.node_pop3:setVisible(false)
    self.node_pop4:setVisible(false)  
    self.node_pop5:setVisible(true)
    self.node_pop6:setVisible(false)
    self.node_pop7:setVisible(false)
    self.node_pop8:setVisible(false)
  elseif PopupType.RANK_LIST == popType then
    self.node_pop1:setVisible(false)
    self.node_pop2:setVisible(false)
    self.node_pop3:setVisible(false)
    self.node_pop4:setVisible(false)  
    self.node_pop5:setVisible(false)
    self.node_pop6:setVisible(true)
    self.node_pop7:setVisible(false)
    self.node_pop8:setVisible(false)
  elseif PopupType.WORKING_TIME == popType then
    self.node_pop1:setVisible(false)
    self.node_pop2:setVisible(false)
    self.node_pop3:setVisible(false)
    self.node_pop4:setVisible(false)  
    self.node_pop5:setVisible(false)
    self.node_pop6:setVisible(false)    
    self.node_pop7:setVisible(true)
    self.node_pop8:setVisible(false)
  elseif PopupType.FRIEND_INFO == popType then
    self.node_pop1:setVisible(false)
    self.node_pop2:setVisible(false)
    self.node_pop3:setVisible(false)
    self.node_pop4:setVisible(false)  
    self.node_pop5:setVisible(false)
    self.node_pop6:setVisible(false)    
    self.node_pop7:setVisible(false)
    self.node_pop8:setVisible(true) 
  end
  self.popType = popType
end

function PopupView:getPopVisible()
  return self.popType
end 

function PopupView:setMaxNum(num)
  self.maxNum = num
end

function PopupView:reAdjustHeightByText(textString)
  if textString ~= nil then 
    self.lable_pop3_content:setString(textString)
    local oldW = self.lable_pop3_content:getContentSize().width
    local oldH = self.lable_pop3_content:getContentSize().height 

    local label = CCLabelTTF:create(textString, "Courier-Bold", 20)
    label:setDimensions(CCSizeMake(oldW,0))
    local newH = label:getContentSize().height

    if newH > oldH then 
      local bgWidth = self.pop_bg3:getPreferredSize().width
      local bgHeight = self.pop_bg3:getPreferredSize().height
      self.pop_bg3:setPreferredSize(CCSizeMake(bgWidth, bgHeight + newH - oldH))

      self.lable_pop3_content:setDimensions(CCSizeMake(oldW, newH))
    end
  end
end





function PopupView:close()
  echo("PopupView:close")
  if self.enabledExecuteNewBird ~= false then
    _executeNewBird()
  end
  if self.scheduler ~= nil then 
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
    self.scheduler = nil
  end

  --for bonus pop to resume count down time visible
  if PopupType.BONUS == self.popType then 
    if self.confirmCallback ~= nil then
      self.confirmCallback(false)
    end
  end

  self:removeFromParentAndCleanup(true)
end

function PopupView:rightCallback()
  if self.rightCallBack ~= nil then
    self.rightCallBack()
  end  
  self:close()
end

function PopupView:onDismissCallkback()
	print("PopupView:onDismissCallkback")
	self:getParent():removeChild(self, true)
	if self.scheduler ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
		self.scheduler = nil
	end

	--for bonus pop to resume count down time visible
	if PopupType.BONUS == self.popType then
		if self.confirmCallback ~= nil then
			self.confirmCallback(false)
		end
	end
end


function PopupView:decreseCallback()
  if self.number > 0 then
    self.number = self.number - 1
    if self.number <= 0 then 
      self.number = self:getInputMinVal()
    end 
    self.label_pop1_buy_num:setString(string.format("%d",self.number))
    --if PopupType.INPUT_NUMBER_MERGE==self.popType then 
      if self.inputBox ~= nil then 
        self.inputBox:setText(string.format("%d",self.number))
      end
    --end
  end

  if PopupType.INPUT_NUMBER_BUY==self.popType or PopupType.INPUT_NUMBER_SALE==self.popType or PopupType.INPUT_NUMBER_MERGE==self.popType then
    self.label_desc2:setString(string.format("%d", self.number*self.price))
    self.pop1_coin:setPositionX(self.label_desc2:getPositionX()+self.label_desc2:getContentSize().width+16)   
    self.pop1_money:setPositionX(self.label_desc2:getPositionX()+self.label_desc2:getContentSize().width+16)      
  end
end

function PopupView:increseCallback()

  self.number = self.number + 1
  if self.number > self.maxNum then 
    self.number = self.maxNum
  end

  self.label_pop1_buy_num:setString(string.format("%d",self.number))
  --if PopupType.INPUT_NUMBER_MERGE==self.popType then 
    if self.inputBox ~= nil then 
      self.inputBox:setText(string.format("%d",self.number))
    end
  --end


  if PopupType.INPUT_NUMBER_BUY==self.popType or PopupType.INPUT_NUMBER_SALE==self.popType or PopupType.INPUT_NUMBER_MERGE==self.popType then
    self.label_desc2:setString(string.format("%d", self.number*self.price))

    self.pop1_coin:setPositionX(self.label_desc2:getPositionX()+self.label_desc2:getContentSize().width+16)   
    self.pop1_money:setPositionX(self.label_desc2:getPositionX()+self.label_desc2:getContentSize().width+16)    
  end
end

function PopupView:maxCallback()
  if self.maxNum > 0 then 
    self.number = self.maxNum
    self.label_pop1_buy_num:setString(string.format("%d",self.number))

    --if PopupType.INPUT_NUMBER_MERGE==self.popType then 
      if self.inputBox ~= nil then 
        self.inputBox:setText(string.format("%d",self.number))
      end
    --end
  end


  if PopupType.INPUT_NUMBER_BUY==self.popType or PopupType.INPUT_NUMBER_SALE==self.popType or PopupType.INPUT_NUMBER_MERGE==self.popType then
    self.label_desc2:setString(string.format("%d", self.number*self.price))
    self.pop1_coin:setPositionX(self.label_desc2:getPositionX()+self.label_desc2:getContentSize().width+16)   
    self.pop1_money:setPositionX(self.label_desc2:getPositionX()+self.label_desc2:getContentSize().width+16)      
  end
end

function PopupView:inputCallback()
  echo("inputCallback:",self.number)
  if self.confirmCallback ~= nil then 
    self.confirmCallback(self.number)
  end
  self:close()
end 

function PopupView:OkCallback()
  echo("OkCallback")
  if self.confirmCallback ~= nil then 
    self.confirmCallback()
  end

  if self.rightCallBack ~= nil  then
    self:removeFromParentAndCleanup(true)
  else
	  self:close()
  end
end

function PopupView:pop4Confirm()
  self:close()
  if self.confirmCallback ~= nil then
    echo("pop4Confirm:", self.selectedIndex)
    self.confirmCallback(self.selectedIndex)
  end
end


function PopupView:pop4SelectIdx(index)
 

  if index < 0 then --init
    self.pop4Flag = {false, false,false, false, false, false}
    self.pop4Imgs = {self.pop4Selected1, self.pop4Selected2, self.pop4Selected3,
                    self.pop4Selected4, self.pop4Selected5, self.pop4Selected6}  
    for i=1, 6 do 
      self.pop4Imgs[i]:setVisible(false)
    end

    self.selectedIndex = -1
    return 
  end

                    
  for i=1, 6 do 
    if i == index then 
      self.pop4Flag[i] = not self.pop4Flag[i]
      self.pop4Imgs[i]:setVisible(self.pop4Flag[i])

      if self.pop4Flag[i] == false then 
        self.selectedIndex = -1
      else 
        self.selectedIndex = index
      end
    else 
      self.pop4Flag[i] = false
      self.pop4Imgs[i]:setVisible(false)
    end 
  end                          
end 

function PopupView:pop4Callback1()
  self:pop4SelectIdx(1)
end 

function PopupView:pop4Callback2()
  self:pop4SelectIdx(2)
end 

function PopupView:pop4Callback3()
  self:pop4SelectIdx(3)
end 

function PopupView:pop4Callback4()
  self:pop4SelectIdx(4)
end 

function PopupView:pop4Callback5()
  self:pop4SelectIdx(5)
end 

function PopupView:pop4Callback6()
  self:pop4SelectIdx(6)
end


function PopupView:startRewardCallback()
  echo("startRewardCallback")
  if self.confirmCallback ~= nil then
    self.confirmCallback(true)
    self.confirmCallback = nil 
  end  
  self:close()
end

function PopupView:showRewordList(propsTable)

  --init 
  if propsTable == nil then 
    return 
  end

  local arrow = nil 
  if PopupType.REWORD_SOMETHING == self.popType then 
    self.nodeContainer = self.node_content
    arrow = self.sprite2_arrow 
  elseif PopupType.BONUS == self.popType then 
    self.nodeContainer = self.node5_content
    arrow = self.sprite5_arrow 
  end

  if arrow then 
    arrow:setVisible(#propsTable >= 4)
  end 

  self.propsArray = propsTable
  self.totalCells = table.getn(self.propsArray)
  self.cellHeight = self.nodeContainer:getContentSize().height 
  self.cellWidth = self.nodeContainer:getContentSize().width/4

  echo("totalCells=: "..self.totalCells.."cellWidth= "..self.cellWidth.."cellHeight = "..self.cellHeight)


  local function tableCellTouched(tableview,cell)
    echo("tableCellTouched, idx=", cell:getIdx())
    --for tip menu   
    local x = cell:getIdx()*self.cellWidth + tableview:getContentOffset().x + self.cellWidth/2
    local pos = ccp(x, self.cellHeight+10)
    local index = cell:getIdx() + 1
    if index > table.getn(propsTable) then
      echo("invalid intemIdx")
      return
    end
    local configId = propsTable[index].configId
    echo(" configId = ", configId)
    TipsInfo:showTip(self.nodeContainer, configId, nil, pos)
  end
  
  local function cellSizeForTable(tableview,idx)
    return self.cellHeight,self.cellWidth
  end
  
  local function tableCellAtIndex(tableview, idx)
    echo("cell index= ", idx)

    local cell = tableview:dequeueCell()
    if nil == cell then
      cell = CCTableViewCell:new()
    else
      cell:removeAllChildrenWithCleanup(true)
    end 

    local item = self.propsArray[idx+1]
    local node = GameData:Instance():getCurrentPackage():getItemSprite(item.iconId, item.iType, item.configId, item.count)
    node:setPosition(ccp(self.cellWidth/2, self.cellHeight/2))
    cell:addChild(node)

    return cell
  end
  
  local function numberOfCellsInTableView(tableview)
    return self.totalCells
  end





  --create tableview
  if self.nodeContainer:getChildByTag(126) ~= nil then
    echo("remove old tableview")
    self.nodeContainer:removeChildByTag(126,true)
  end

  local tableView = CCTableView:create(self.nodeContainer:getContentSize())
  tableView:setDirection(kCCScrollViewDirectionHorizontal)
  tableView:setTag(126)
  tableView:setTouchPriority(PopupView.PRIORITY)
  self.nodeContainer:addChild(tableView)
  tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
  tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
  tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
  tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
  tableView:reloadData()
end






function PopupView:timeCallback1()
  self.timeSelect1 = not self.timeSelect1
  self.selectImg1:setVisible(self.timeSelect1)

  self.timeSelect2 = false
  self.timeSelect3 = false
  self.timeSelect4 = false
  self.selectImg2:setVisible(false)
  self.selectImg3:setVisible(false)
  self.selectImg4:setVisible(false)

  if self.timeSelect1 == false then 
    self.menu_Ok7:setEnabled(false)
  else 
    self.menu_Ok7:setEnabled(true)
  end

  self.selectedIndex = 1
end

function PopupView:timeCallback2()
  self.timeSelect2 = not self.timeSelect2
  self.selectImg2:setVisible(self.timeSelect2)

  self.timeSelect1 = false
  self.timeSelect3 = false
  self.timeSelect4 = false
  self.selectImg1:setVisible(false)
  self.selectImg3:setVisible(false)
  self.selectImg4:setVisible(false)  

  if self.timeSelect2 == false then 
    self.menu_Ok7:setEnabled(false)
  else 
    self.menu_Ok7:setEnabled(true)
  end

  self.selectedIndex = 2
end

function PopupView:timeCallback3()
  self.timeSelect3 = not self.timeSelect3
  self.selectImg3:setVisible(self.timeSelect3)

  self.timeSelect1 = false
  self.timeSelect2 = false
  self.timeSelect4 = false
  self.selectImg1:setVisible(false)
  self.selectImg2:setVisible(false)
  self.selectImg4:setVisible(false)   

  if self.timeSelect3 == false then 
    self.menu_Ok7:setEnabled(false)
  else 
    self.menu_Ok7:setEnabled(true)
  end

  self.selectedIndex = 3
end

function PopupView:timeCallback4()
  self.timeSelect4 = not self.timeSelect4
  self.selectImg4:setVisible(self.timeSelect4)

  self.timeSelect1 = false
  self.timeSelect2 = false
  self.timeSelect3 = false
  self.selectImg1:setVisible(false)
  self.selectImg2:setVisible(false)
  self.selectImg3:setVisible(false)  

  if self.timeSelect4 == false then 
    self.menu_Ok7:setEnabled(false)
  else 
    self.menu_Ok7:setEnabled(true)
  end

  self.selectedIndex = 4
end

function PopupView:OKCallback7()
  if self.confirmCallback ~= nil then
    local sec = AllConfig.mineinitdata[self.selectedIndex].time
    self.confirmCallback(sec)
  end

  if self.rightCallBack ~= nil  then
    self:getParent():removeChild(self, true)
  else
    self:close()
  end
end

function PopupView:initFriendInfo(friendMode, isHideMenu)
  if friendMode ~= nil then 
    --show head icon
    local resId = friendMode:getAvatarId()
    if resId ~= nil then 
      local sprite = _res(resId)
      if sprite ~= nil then
        local scale = 95/sprite:getContentSize().width
        sprite:setScale(scale)
        self.node8_head:addChild(sprite)
        -- if friendMode:getIsVip() == true then 
        --   local vip = CCSprite:createWithSpriteFrameName("common-image-vip.png")
        --   local x = -sprite:getContentSize().width*scale/2 + 10
        --   local y = sprite:getContentSize().height*scale/2 - 10
        --   vip:setPosition(ccp(x, y))
        --   self.node8_head:addChild(vip)
        -- end
      end
    end
    local level = friendMode:getLevel()
    self.label8_name:setString(friendMode:getName())

    local strId = GameData:Instance():getCurrentPlayer():pidToCode( tonumber(friendMode:getFriendId()))
    self.label8_Id:setString(strId)
    self.label8_level:setString(level)
    self.label8_rank:setString(friendMode:getOfficialTitle())
    if friendMode:getScore() ~= nil then
      self.label8_score:setString(friendMode:getScore())
    end
    self.label8_maxRank:setString(friendMode:getMaxRank())
    local gate1Hp = AllConfig.charlevel[level].gate_hp
    local gate2Hp = AllConfig.charlevel[level].gate2_hp
    self.label8_wallHp:setString(gate1Hp)
    self.label8_houseHp:setString(gate2Hp)

    if isHideMenu == true then 
      self.menu81:setVisible(false)
      self.menu82:setVisible(false)

    end
  end
end

function PopupView:sendMailCallback()
  echo("sendMailCallback")
  self:close()

  local mailController = ControllerFactory:Instance():create(ControllerType.MAIL_CONTROLLER)
  mailController:enterWriteView(self.label8_name:getString())
end 

function PopupView:deleteFriendCallback()
  echo("deleteFriendCallback")
  self:close()
  if self.deleteCallback ~= nil then 
    self.deleteCallback()
  end
end

function PopupView:setInputMinVal(val)
  self._inputMinVal = val
end 

function PopupView:getInputMinVal()
  return self._inputMinVal
end 

--examples 
--[[
  local function okCallback(n)
    echo("okCallback=",n)
  end
  local function okCallback2()
   
  end

  --local pop = PopupView:createInputPopup(PopupType.INPUT_NUMBER_SALE,"杀人蜂",100, 200,okCallback)
  --self:addChild(pop)
  --pop:setScale(startScale)
  --pop:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )   
          
  local pop = PopupView:createTextPopup("兽王吊坠", okCallback2)
  self:addChild(pop)

  --local mytable = {{2, "baoshi.png"},{30, "baoshi2.png"}}
  --local pop = PopupView:createRewardPopup(mytable)
  --self:addChild(pop)

  local function selecetedCallback(index)
    echo("index = ", index)
  end
  local pop = PopupView:createWorkTimePopup(selecetedCallback)
  self:addChild(pop) 
--]]