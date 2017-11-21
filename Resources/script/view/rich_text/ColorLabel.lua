ColorLabel = class("ColorLabel",function()
    return display.newSprite()
end)

function ColorLabel:ctor(w,h,fontSize)
    self.mSize = CCSize( w , h )
    self.mPoint = ccp(0,h)
    self.rt = CCRenderTexture:create( w , h )
    self.fontSize = fontSize
    self:setContentSize( CCSize( w , h ) )
    self:addChild(self.rt )
end

function ColorLabel:addString( str , fontName , fontColor )
    
    local pos = 1
    local fontSize = self.fontSize
    local width = self.fontSize
    local point = self.mPoint
    while pos <= str:len() do
        local l = 2
        if string.byte(str, pos) >0x80 then
            l=3
            width = fontSize
        else
            l=1
            width = fontSize / 2
        end
        local label = CCLabelTTF:create(str:sub(pos , pos+l-1),fontName,fontSize)
        label:setColor(fontColor)
        label:setAnchorPoint( ccp(0,1) )
        self.rt:begin()
        label:setPosition( point )
        label:visit()
        self.rt:endToLua()
        pos = pos + l
        point.x = point.x + width
        if point.x > self.mSize.width - width then
            point.x = 0
            point.y = point.y - fontSize
        end
     
    end
    self.mPoint = point
end
return ColorLabel