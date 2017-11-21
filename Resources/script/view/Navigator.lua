Navigator = {}

NavigatorType.SWITCH_SCENE = 1000
NavigatorType.SWITCH_CENTRE_VIEW = 1001

function Navigator.onSwitch(view)

  if view.getView() == NavigatorType.SWITCH_SCENE then
    
  else
  
  end


end


MarketView = {}

function MarketView.onSwitch(parent)
  --parent.replaceView(self)
  display:replaceScene(self)
end

local view = MarketView.new()
view.onSwitch(self)