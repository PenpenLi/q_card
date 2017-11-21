

--[[
    说明: 1. 编辑框 EditBox 扩展, 具有原始编辑框特性
          2. 支持多行输入(对应的参数multiLineDimension=true)
          3. 如果参数scale9Sprite有父节点,则创建的EditBox自动替换该scale9Sprite并被add到scale9Sprite的父节点; 
             反之，返回一个新的 EditBox 对象, 外部使用前需要调用addChild()
          4. 此方法实现的输入框不实用IOS设备, 因为IOS 会忽略 \n 换行符, 无法手动排版,请实用控件 EditBoxExt2 
--]]        
EditBoxExt = {}


--重新排版,越界则舍弃多余的字串
local function checkInputTextRegion(oldstr, dimSize, fontSize, lineGap)

  --1.将之前添加的换行符号去掉
  local str = string.gsub(oldstr, "\n", "")

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
      newStr = newStr.."\n"

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


function EditBoxExt.converImgToEditBox(scale9Sprite, fontName, fontSize, fontColor, multiLineDimension)

  if scale9Sprite == nil then
    return nil 
  end 
  
  --针对不同平台计算行间距
  local tmplabel = CCLabelTTF:create("A\nB", "Courier-Bold", fontSize)
  local lineGap = tmplabel:getContentSize().height - fontSize*2
  echo("lineGap =", lineGap)

  local imgParent = scale9Sprite:getParent()
  if imgParent ~= nil then
    scale9Sprite:removeFromParentAndCleanup(false)
  end
  --创建编辑框
  local oldPos = ccp(scale9Sprite:getPosition())
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
    if strEventName == "return" then
      local edit = tolua.cast(pSender,"CCEditBox")
      local str = checkInputTextRegion(edit:getText(), multiLineDimension, fontSize, lineGap)
      editBox:setText(str)
    end
  end

  if multiLineDimension ~= nil then 
    editBox:registerScriptEditBoxHandler(editBoxTextEventHandle)
  end 

  if imgParent ~= nil then
    imgParent:addChild(editBox)
  end 

  return editBox
end

function EditBoxExt.getOrgText(str)
  return string.gsub(str, "\n", "")
end 
