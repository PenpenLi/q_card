require("view.BaseView")
require("view.component.DropItemView")
require("model.Activity")
require("view.component.Toast")

ActivityShootView = class("ActivityShootView",BaseView)

local _count = 1

local _move = false

local speed = 0.5

local pointList = {}

local _actCount = 1

function ActivityShootView:ctor()

    ActivityShootView.super.ctor(self)
    
    local pkg = ccbRegisterPkg.new(self)
    
    pkg:addProperty("btnTong", "CCMenuItemImage")
    pkg:addProperty("btnYin", "CCMenuItemImage")
    pkg:addProperty("btnJin", "CCMenuItemImage")
    
    for i=1,12 do
        pkg:addProperty("txtItem"..i.."Name", "CCLabelTTF")
        pkg:addProperty("item"..i, "CCSprite")
    end
    
    pkg:addProperty("txtTime","CCLabelTTF")

    pkg:addProperty("txtPriceOne", "CCLabelTTF")
    pkg:addProperty("txtPriceTen", "CCLabelTTF")

    pkg:addProperty("txtFTimes", "CCLabelTTF")
    pkg:addProperty("txtSTimes", "CCLabelTTF")
    pkg:addProperty("txtTTimes", "CCLabelTTF")
    
    pkg:addProperty("btnShootOne", "CCMenuItemImage")
    pkg:addProperty("btnShootTen", "CCMenuItemImage")
    
    pkg:addProperty("btnHelp", "CCMenuItemImage")
    
    pkg:addProperty("spPro", "CCScale9Sprite")
    
    local layer,owner = ccbHelper.load("ActivityShootview.ccbi","activity_shoot_view","CCLayer",pkg)
    
    self:addChild(layer)
    
    self:showItem()
    
    self:addEvent()
    
    self:addNetEvent()
    
    self:getState()

    --self:getRewardState()

    --self.btnShootOne:selected()
end

function ActivityShootView:onExit()

    _move = false
    _count = 1
    speed = 0.5
    pointList = {}
    _actCount = 1

    net.unregistAllCallback(self)
    ActivityShootView.super.onExit(self)
    
end

function ActivityShootView:getRewardState()

    local info = GameData:Instance():getCurrentPlayer():getAllGetedAwards()

    if info and info.bigwheel then
        for k, v in pairs(info.bigwheel) do 
            echo("===============bigwheel award_id, type:", v.id, v.type, v.data)
            if v.type == "BIGWHEEL_AWARD" then 
                
            end 
        end 
    end
end

local function createEffect(type, target)
    local light,offsetX,offsetY,duration = _res(type)
    if light ~= nil then
        --light:setPosition(ccp(60,60))
        target:addChild(light)
        light:getAnimation():play("default")
    end
end

local function formatTime(data, value)
    local month = string.sub(data,1,1)

    local t = ""

    if month == "0" then
        t = t..string.sub(data,2,2)
    else
        t = t..string.sub(data,1,2)
    end

    t = t.."月"

    local day = string.sub(data,3,3)

    if day == "0" then
        t = t..(string.sub(data,4,4) - value)
    else
        t = t..(string.sub(data,3,4) - value)
    end

    t = t.."日"

    return t
end

function ActivityShootView:shootArrow(target, callback)
    local winSize = CCDirector:sharedDirector():getWinSize()
    self._actArrow = display.newNode()
    createEffect(5020212,self._actArrow)
    
    self:addChild(self._actArrow)
    
    if target ~= nil then
        self._actArrow:setPosition(target:getPositionX()+winSize.width/2, target:getPositionY()+winSize.height/2)
    else
        self._actArrow:setPosition(math.random(self.item1:getPositionX()+winSize.width/2,self.item12:getPositionX()+winSize.width/2), 
            math.random(self.item1:getPositionY()+winSize.height/2,self.item12:getPositionY()+winSize.height/2))
    end

    self._schedule = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback,0.2,false)

end

function ActivityShootView:nextOne(step, getTarget)
    local winSize = CCDirector:sharedDirector():getWinSize()
    self._actCross:setPosition(ccp(self["item"..step]:getPositionX()+winSize.width/2,self["item"..step]:getPositionY()+winSize.height/2))

    local array = CCArray:create()
    
    local call = CCCallFuncN:create(getTarget)

    local moveTo = CCMoveTo:create(speed,ccp(self["item"..step]:getPositionX()+winSize.width/2, self["item"..step]:getPositionY()+winSize.height/2))

    if #pointList - _count > 10 then
        speed = speed - 0.1
        if speed < 0.1 then
            speed = 0.03
        end
    else
        speed = speed + 0.05
        if speed > 2 then
            speed = 2
        end
    end

    array:addObject(moveTo)
        
    array:addObject(call)

    self._actCross:runAction(CCSequence:create(array))
end

function ActivityShootView:startMove(targetPos)

    local winSize = CCDirector:sharedDirector():getWinSize()

    local config = targetPos[1].configId
    local count = targetPos[1].count
    
    self._actCross = display.newNode()
    self._actCross:setAnchorPoint(ccp(0,0))
    createEffect(5020213,self._actCross)
    self:addChild(self._actCross,50)

    local index = 0
    --特殊处理道具
    if table.getn(targetPos) == 1 then
        for i=1,table.getn(self._awaryList) do
            if self._awaryList[i][1] == config and count == self._awaryList[i][2] then
                index = i
                break
            end
        end
    else
        index = math.random(2,12)
    end
    

    pointList = {1,2,3,4,8,7,6,5,9,10,11,12,8,7,6,5}

    for i=1,#pointList*3 do
        table.insert(pointList,pointList[i])
    end
    
    for i=1,#pointList do
        table.insert(pointList,pointList[i])
        if pointList[i] == index then
            break
        end
    end

    local arrowCont = 0

    local function callback()

        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self._schedule)

        if table.getn(targetPos) > 1 then
            arrowCont = arrowCont + 1

            if arrowCont < 10 then
                self:shootArrow(nil, callback)
                return
            else
                local data = self:formatArrayData(targetPos)

                local pop = PopupView:createRewardPopup(data[1].bonus)
                local title = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("act_title_huodejiangli.png")
                if title ~= nil then 
                    pop.sprite5_title:setDisplayFrame(title)
                end
                self:addChild(pop)
            end

            
        else
            local str = string.format("+%d", targetPos[1].count)
            Toast:showIconNumWithDelay(str, targetPos[1].iconId, targetPos[1].iType, targetPos[1].configId, ccp(display.width/2,display.height*0.4), 0)
        end

        _move = false

        self.effectNode = display.newNode()
        self:addChild(self.effectNode)


        local pkg = ccbRegisterPkg.new(self)
        pkg:addProperty("mAnimationManager","CCBAnimationManager")
        pkg:addProperty("effectNode","CCNode")
        pkg:addProperty("spLevelUp","CCSprite")
        pkg:addFunc("playCompleteHandler",function()
            self.effectNode:removeAllChildrenWithCleanup(true)
        end)
        pkg:addFunc("playEffect",function() 
                  
        end)
        local layer,owner = ccbHelper.load("LevelUp.ccbi","LevelUpAnimationCCB","CCLayer",pkg)
        self:addChild(layer)
        self.spLevelUp:setVisible(false)
    end

    local count = 0
    local function getTarget(pSend)
        count = count + 1

        if count == #pointList then
            speed = 0.5
            _count = 1

            self:removeChild(self._actCross, true)

            if table.getn(targetPos) == 1 then
                self:shootArrow(self["item"..index], callback)
            else
                self:shootArrow(nil, callback)
            end
            

            self:getState()
        else
            _count = _count + 1
            self:nextOne(pointList[_count], getTarget)
        end
    end

    self:nextOne(pointList[_count], getTarget)
end

function ActivityShootView:showHelp()
    local help = HelpView.new()
    help:addHelpBox(1060, ccp(0,-150))
    help:addHelpItem(1015, self.node_largeheader, ccp(60,20), ArrowDir.LeftLeftUp)
    help:addHelpItem(1016, self.sprite_book2, ccp(40,-80), ArrowDir.RightUp)
    help:addHelpItem(1017, self.menu_startSkillUp, ccp(40,20), ArrowDir.RightDown)
    self:addChild(help, 1000)
end

function ActivityShootView:getState()

    local count = 0
    count = Activity:instance():getActProgress(ACT_ID_BIG_WHEEL)
    _actCount = count

    local max_count = AllConfig.bigwheel_award[#AllConfig.bigwheel_award].count

    local scale = count/max_count;

    if scale > 1 then
        scale = 1
    end

    self.spPro:setScaleX(scale)
end

function ActivityShootView:showItem()

    local function tipsCallback(obj, configId, pos)
        TipsInfo:showTip(obj, configId, nil, pos, nil, true)
    end 
    
    local wheelList = {}
    
    local num = 1;
    
    for key, value in pairs(AllConfig.bigwheel) do
    
        local drop_data = AllConfig.drop[value.first_drop].drop_data
        
        for i=1,#drop_data do
        
            local node = self["item"..num]
            
            if node == nil then
                break
            end

            echo(drop_data[i].array[2], drop_data[i].array[3], drop_data[i].array[1])
        
            local icon1 = DropItemView.new(drop_data[i].array[2], drop_data[i].array[3], drop_data[i].array[1])

            local tipArgs = {callbackFunc=tipsCallback}

            local icon = GameData:Instance():getCurrentPackage():getItemSprite(nil, drop_data[i].array[1],drop_data[i].array[2],drop_data[i].array[3], true, tipArgs)

            local bord = display.newSprite("#act_kuang.png")
            
            table.insert(wheelList,{drop_data[i].array[2],drop_data[i].array[3]})
            
            node:addChild(icon)

            node:addChild(bord)

            node:setScale(0.8)
            
            self["txtItem"..num.."Name"]:setString(icon1:getName())
            
            num = num + 1
        end
    end
    
    self._awaryList = wheelList

    self.txtFTimes:setString(AllConfig.bigwheel_award[1].count.."次")
    self.txtSTimes:setString(AllConfig.bigwheel_award[2].count.."次")
    self.txtTTimes:setString(AllConfig.bigwheel_award[3].count.."次")

    local time = ""
    for key, activity in pairs(AllConfig.activity) do
        if activity.activity_id == 5014 then
            time = _tr("startTime:%{count1} -- endTime:%{count2}", {count1 = formatTime(string.sub(activity.open_date,5,8), 0),count2 = formatTime(string.sub(activity.close_date,5,8), 1).."23点59分"})
        end
    end

    self.txtTime:setString(time)
    
    local winSize = CCDirector:sharedDirector():getWinSize()

    --按钮的例子效果
    if self._btn_shebao_effect ~= nil then
        self._btn_shebao_effect:removeAllChildrenWithCleanup(true)
    else
        self._btn_shebao_effect = display.newNode()
        self:addChild(self._btn_shebao_effect)
    end
    
    createEffect(5020214, self._btn_shebao_effect)

    self._btn_shebao_effect:setPosition(ccp(self.btnShootOne:getPositionX()+winSize.width/2,
        self.btnShootOne:getPositionY()+winSize.height/2))
    

    if self._btn_shilianshe_effect ~= nil then
        self._btn_shilianshe_effect:removeAllChildrenWithCleanup(true)
    else
        self._btn_shilianshe_effect = display.newNode()
        self._btn_shilianshe_effect:setPosition(ccp(self.btnShootTen:getPositionX()+winSize.width/2,
            self.btnShootTen:getPositionY()+winSize.height/2))
        self:addChild(self._btn_shilianshe_effect)
    end
    
    createEffect(5020215, self._btn_shilianshe_effect)
    
    --添加按钮文字
    self._btn_shebao_wenzi = display.newSprite("#act_btn_shebao.png")
    self._btn_shilianshe_wenzi = display.newSprite("#act_btn_shilianshe.png")
    
    self:addChild(self._btn_shebao_wenzi)
    self:addChild(self._btn_shilianshe_wenzi)
    
    self._btn_shebao_wenzi:setPosition(ccp(self.btnShootOne:getPositionX()+winSize.width/2,self._btn_shebao_effect:getPositionY()))
    self._btn_shilianshe_wenzi:setPosition(ccp(self.btnShootTen:getPositionX()+winSize.width/2,self._btn_shilianshe_effect:getPositionY()))
    
    --显示单价
    self.txtPriceOne:setString((AllConfig.bigwheel[1].quick_money_cost))
    self.txtPriceTen:setString((10 * AllConfig.bigwheel[1].quick_money_cost))
end

function ActivityShootView:formatArrayData(gainItems)
    self.bonus = {}
        local tbl = {}
        for i=1,table.getn(gainItems) do
        --local str = string.format("+%d", gainItems[i].count)
        --Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.4), 0.3*(i-1))
            local v = {gainItems[i].iType, gainItems[i].configId, gainItems[i].count}

            if v[1] == 1 or v[1] == 2 or v[1] == 3 then  -- player/card/skill exp
                bonusItem = {iType = 88, configId = nil, iconId = 3059022, count = v[3]}
            elseif v[1] == 4 then --coin
                bonusItem = {iType = 88, configId = nil, iconId = 3050050, count = v[3]}
            elseif v[1] == 5 then --money
                bonusItem = {iType = 88, configId = nil, iconId = 3050049, count = v[3]}
            elseif v[1] >= 6 and v[1] <= 8 then 
                bonusItem = {iType = v[1], configId = v[2], iconId = nil, count = v[3]}
            elseif v[1] == 11 then --spirit
                bonusItem = {iType = 88, configId = nil, iconId = 3059015, count = v[3]}
            elseif v[1] == 12 then --token
                bonusItem = {iType = 88, configId = nil, iconId = 3050003, count = v[3]}
            end

            table.insert(tbl, bonusItem)
        end

        local tmp = {value=100, bonus = tbl}
        table.insert(self.bonus, tmp)
    
    return self.bonus
end

function ActivityShootView:formatData()
  self.livenessBonus = {}
    local dropItem

    for i=1, table.getn(AllConfig.bigwheel_award) do 

        local tbl = {}
        local dropArray = AllConfig.bigwheel_award[i].bonus
        for k, dropId in pairs(dropArray) do 
          dropItem = AllConfig.drop[dropId]
            for m, v in pairs(dropItem.drop_data) do
              v = v.array
              local bonusItem = nil

              if v[1] == 1 or v[1] == 2 or v[1] == 3 then  -- player/card/skill exp
                bonusItem = {iType = 88, configId = nil, iconId = 3059022, count = v[3]}
              elseif v[1] == 4 then --coin
                bonusItem = {iType = 88, configId = nil, iconId = 3050050, count = v[3]}
              elseif v[1] == 5 then --money
                bonusItem = {iType = 88, configId = nil, iconId = 3050049, count = v[3]}

              elseif v[1] >= 6 and v[1] <= 8 then 
                bonusItem = {iType = v[1], configId = v[2], iconId = nil, count = v[3]}

              elseif v[1] == 11 then --spirit
                bonusItem = {iType = 88, configId = nil, iconId = 3059015, count = v[3]}
              elseif v[1] == 12 then --token
                bonusItem = {iType = 88, configId = nil, iconId = 3050003, count = v[3]}
              end

              table.insert(tbl, bonusItem)
            end
        end 

        local tmp = {value=type, bonus = tbl}
        table.insert(self.livenessBonus, tmp)
    end

  return self.livenessBonus
end

function ActivityShootView:addEvent()

    local _type = 0

    local function sendNet(isok)
        echo(isok,_type)
        if isok == true then
            if _type == 1 then
                _type = AllConfig.bigwheel_award[1].count
             elseif _type == 2 then
                _type = AllConfig.bigwheel_award[2].count
            else
                _type = AllConfig.bigwheel_award[3].count
            end

            if _actCount < _type then
                Toast:showString(self, _tr("NotEnoughTimes"),ccp(display.width/2,display.height*0.4))
                return
            end

            local data = PbRegist.pack(PbMsgId.ReqBigWheelAward,{var = _type})
            net.sendMessage(PbMsgId.ReqBigWheelAward, data)
        end
    end

    local function showItemView(type)
        _type = type
        local data = self:formatData()
        local pop = PopupView:createBonusPopup(data[type].bonus, sendNet, false)
        local title = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("act_title_lingqujiangli.png")
        if title ~= nil then 
            pop.sprite5_title:setDisplayFrame(title)
        end

        self:addChild(pop)
    end
    
    local function btnShowTong()
        showItemView(1)
    end
    
    local function btnShowYin()
        showItemView(2)
    end
    
    local function btnShowJin()
        showItemView(3)
    end
    
    --抽一次
    local function btnShootOne()
        self:reqUseBigWheel(1)
    end
    
    --十连抽
    local function btnShootTen()
        self:reqUseBigWheel(10)
    end
    
    local function showHelp()
        self:showHelp()
    end

    self.btnTong:registerScriptTapHandler(btnShowTong)
    self.btnYin:registerScriptTapHandler(btnShowYin)
    self.btnJin:registerScriptTapHandler(btnShowJin)
    
    self.btnShootOne:registerScriptTapHandler(btnShootOne)
    self.btnShootTen:registerScriptTapHandler(btnShootTen)
    
    self.btnHelp:registerScriptTapHandler(showHelp)
end

function ActivityShootView:reqUseBigWheel(type)
    if _move == false then
        _move = true
        local data = PbRegist.pack(PbMsgId.ReqUseBigWheel,{times = type})
        net.sendMessage(PbMsgId.ReqUseBigWheel, data)
    end
end

function ActivityShootView:addNetEvent()
    net.registMsgCallback(PbMsgId.ReqBigWheelAwardResult,self,ActivityShootView.onReqBigWheelRewardResult)
    net.registMsgCallback(PbMsgId.ReqUseBigWheelResult,self,ActivityShootView.onReqUseBigWheelResult)
end

function ActivityShootView:onReqBigWheelRewardResult(action,msgId,msg)
    if msg.state ~= "Success" then
        Toast:showString(self,_tr(msg.state),ccp(display.width/2,display.height*0.4))
        return
    end
    
    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    
    for i = 1,table.getn(gainItems) do
        local str = string.format("+%d", gainItems[i].count)
        Toast:showIconNumWithDelay(str, gainItems[i].iconId, gainItems[i].iType, gainItems[i].configId, ccp(display.width/2,display.height*0.4), 0.3*(i-1))
    end

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
end

function ActivityShootView:onReqUseBigWheelResult(action,msgId,msg)
    if msg.state ~= "Success" then
        _move = false
        Toast:showString(self,_tr(msg.state),ccp(display.width/2,display.height*0.4))
        return
    end

    local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client_sync)
    
    self:startMove(gainItems)

    GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client_sync)
end

return ActivityShootView