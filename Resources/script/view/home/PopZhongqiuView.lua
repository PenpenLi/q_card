
require("view.BaseView")



PopZhongqiuView = class("PopZhongqiuView", BaseView)

function PopZhongqiuView:ctor(flag)

  local pkg = ccbRegisterPkg.new(self)

  pkg:addFunc("closeCallback",PopZhongqiuView.closeCallback)
  pkg:addFunc("entryCallback",PopZhongqiuView.entryCallback)
  pkg:addProperty("node_content","CCNode")
  pkg:addProperty("bn_close","CCControlButton")
  pkg:addProperty("bn_enter","CCControlButton")

  local layer,owner = ccbHelper.load("PopZhongqiujieView.ccbi","popZhongqiuViewCCB","CCLayer",pkg)
  self:addChild(layer)
end

function PopZhongqiuView:init()
  local priority = -600
  self.bn_close:setTouchPriority(priority-1)
  self.bn_enter:setTouchPriority(priority-1)

  self:addTouchEventListener(function(event, x, y)
                                if event == "began" then
                                  return true
                                end
                            end,
              false, priority, true)
  self:setTouchEnabled(true)
end 

function PopZhongqiuView:create()
  local pop = PopZhongqiuView.new()
  pop:init()
  pop.node_content:setScale(0.2)
  pop.node_content:runAction(CCEaseElasticOut:create(CCScaleTo:create(0.5,1),0.6) )

  return pop 
end 

function PopZhongqiuView:closeCallback()
  self:removeFromParentAndCleanup(true)
end 

function PopZhongqiuView:entryCallback()
  self:closeCallback()
  
  Activity:instance():entryActView(ActMenu.ZHONG_QIU, false)
end 


