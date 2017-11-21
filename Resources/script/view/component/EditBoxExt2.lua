
--此输入框主要是针对IOS输入法无法处理 \n 换行符 而设计!!

--[[
    说明: 1. 编辑框 EditBox 扩展, 具有原始编辑框特性
          2. 支持多行输入(对应的参数 multiLineDimension)
          3. 如果参数scale9Sprite有父节点,则创建的EditBox自动替换该scale9Sprite并被add到scale9Sprite的父节点; 
             反之，返回一个新的 EditBox 对象, 外部使用前需要调用addChild()
--]]        
EditBoxExt2 = {}


local dispLabel = nil   --创建CCLabelTTF来显示输入的字串，不用自己手动排版
local filterLayer = nil --触摸层，优先级别编辑框高，当点击输入区域时，隐藏 dispLabel ，而显示 编辑框，以便打开输入法




--手动重新排版,越界则舍弃多余的字串 (目前不采用此方法了)
local function checkInputTextRegion(oldstr, dimSize, fontSize, lineGap)

  local fixStr = "\n"


  --1.将之前添加的换行符号去掉
  local str = string.gsub(oldstr, fixStr, "")


  --2.重新排版
  local pos = 1
  local charW = 1 
  local bytes = 1 
  local newStr = ""
  local point = ccp(0, dimSize.height)
  while pos <= str:len() do

    -- if string.byte(str, pos) < 0x80 then 
    --   bytes = 1
    --   charW = fontSize*0.5
    -- else 
    --   bytes = 3
    --   charW = fontSize 
    -- end 

    local ch = string.byte(str, pos) 
    if ch <= 0x7f then 
      bytes = 1
      charW = fontSize*0.5
    elseif bit.band(ch, 0xe0) == 0xc0 then 
      bytes = 2
      charW = fontSize
    elseif bit.band(ch, 0xf0) == 0xe0 then 
      bytes = 3
      charW = fontSize
    end 

    -- echo("===",point.x, charW, newStr)
    if point.x + charW > dimSize.width then --越界换行 
      point.y = point.y - (fontSize + lineGap)
      --插入换行符
      newStr = newStr..fixStr

      --如果高度越界则退出
      if point.y < fontSize then
        echo("=== out of region..")
        break 
      end 

      --保存当前字符
      point.x = charW 
      newStr = newStr..string.sub(str, pos, pos+bytes-1)

    else 
      --保存当前字符
      point.x = point.x + charW 
      newStr = newStr..string.sub(str, pos, pos+bytes-1)
    end 

    pos = pos + bytes 
  end 

  return newStr 
end 


function EditBoxExt2.converImgToEditBox(scale9Sprite, fontName, fontSize, fontColor, multiLineDimension)

  if scale9Sprite == nil then
    return nil 
  end 
  
  --针对不同平台计算行间距
  -- local tmplabel = CCLabelTTF:create("A\nB", "Courier-Bold", fontSize)
  -- local lineGap = tmplabel:getContentSize().height - fontSize*2

  --备份scale9Sprite原始信息
  local imgSize = scale9Sprite:getContentSize()
  local ap = scale9Sprite:getAnchorPoint() 
  local oldPos = ccp(scale9Sprite:getPosition())
  local oldPosLeftUp = ccp(oldPos.x - ap.x*imgSize.width, oldPos.y + (1-ap.y)*imgSize.height)

  --从父节点移除后用它来创建编辑框
  local imgParent = scale9Sprite:getParent()
  if imgParent ~= nil then
    scale9Sprite:removeFromParentAndCleanup(false)
  end

  --创建编辑框
  local editBox = CCEditBox:create(scale9Sprite:getContentSize(), scale9Sprite)
  editBox:setAnchorPoint(ccp(0,0))
  editBox:setFontName(fontName)
  editBox:setFontSize(fontSize)
  editBox:setPlaceholderFontSize(fontSize)
  -- editBox:setPlaceHolder(plHolderStr or "")
  -- editBox:setPlaceholderFontColor(plHolderColor or ccc3(255, 255, 255))
  editBox:setFontColor(fontColor or ccc3(255,255,255))
  editBox:setReturnType(kKeyboardReturnTypeDone)
  editBox:setPosition(oldPos)

  -- if maxLength ~= nil then
  --   editBox:setMaxLength(maxLength)
  -- end

  -- if isPassword == true  then
  --   editBox:setInputFlag(0) --kEditBoxInputFlagPassword =0
  -- end

  local function editBoxTextEventHandle(strEventName,pSender)
    echo("strEventName:", strEventName)
    if strEventName == "began" then
      if dispLabel then 
        dispLabel:setVisible(false)
      end 

    elseif strEventName == "return" then
      local edit = tolua.cast(pSender,"CCEditBox")
      --方法1
      -- local str = checkInputTextRegion(edit:getText(), multiLineDimension, fontSize, lineGap)
      -- editBox:setText(str)

      --方法2 
      if dispLabel then 
        editBox:setVisible(false)
        dispLabel:setVisible(true)
        dispLabel:setString(edit:getText())
      end 
    end
  end

  --多行输入情况下
  if multiLineDimension ~= nil then 
    editBox:registerScriptEditBoxHandler(editBoxTextEventHandle)

    --重新调整显示区域
    if multiLineDimension.width > fontSize + 20 then 
      multiLineDimension.width = multiLineDimension.width - 20 
      oldPosLeftUp.x = oldPosLeftUp.x + 10 
    end 
    if multiLineDimension.height > fontSize + 20 then 
      multiLineDimension.height = multiLineDimension.height - 20
      oldPosLeftUp.y = oldPosLeftUp.y - 10 
    end 

    --创建label来显示输入返回后的字符串，
    if imgParent ~= nil then 
      dispLabel = CCLabelTTF:create("", "Courier-Bold", fontSize, multiLineDimension, kCCTextAlignmentLeft)
      dispLabel:setAnchorPoint(ccp(0, 1))
      dispLabel:setPosition(oldPosLeftUp)
      imgParent:addChild(dispLabel)

      filterLayer = CCLayer:create()
      imgParent:addChild(filterLayer)
      filterLayer:addTouchEventListener(function(event, x, y)
                                    if event == "began" then                                   
                                      local size = scale9Sprite:getContentSize()
                                      local pos = scale9Sprite:convertToNodeSpace(ccp(x, y))
                                      if pos.x > 0 and pos.x < size.width and pos.y > 0 and pos.y < size.height then 
                                        editBox:setVisible(true)
                                      end 

                                      return false 
                                    end
                                end,
                  false, -300, true)
      filterLayer:setTouchEnabled(true)  
    end 
  end 

  if imgParent ~= nil then
    imgParent:addChild(editBox)
  end 

  return editBox
end

function EditBoxExt.getOrgText(str)
  return string.gsub(str, "\n", "")
end 
