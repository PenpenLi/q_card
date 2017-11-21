

Bag = class("Bag")

function Bag:ctor()

end

function Bag:enter()
  echo("---Bag:enter---")
  -- net.registMsgCallback(PbMsgId.SellItemToSystemResult, self, BagPropsView.sellToSystemResult)
  -- net.registMsgCallback(PbMsgId.ItemCombineToItemResult, self, BagPropsView.combineResult)
end

function Bag:exit()
  echo("---Bag:exit---")
  -- net.unregistAllCallback(self)

  -- BagPropsView.target = nil
  -- BagMergeView.target = nil
end



