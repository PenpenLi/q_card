require("view.component.MessageBox")

Common.CommonFastBuy=function(configId)
		-- local flag, _ = GameData:Instance():checkSystemOpenCondition(16, true)
		-- if flag == false then
		-- 	return
		-- end

		local shopItem = Shop:instance():getShopItemByConfigId(ShopCurViewType.DianCang, configId)
		if shopItem == nil then 
			assert(false,"item not found..")
		end 

		local canBuy = true
		local owner = nil 
		local price = nil 
		
		local tipStr = string._tran(configId == ShopItem.Spirit and Consts.Strings.FASTBUY_HIT_SPRITE or Consts.Strings.FASTBUY_HIT_TOKEN)
		if configId ~= ShopItem.Spirit
		and configId ~= ShopItem.Token
		then
		  tipStr = _tr("ask_fast_buy_item%{name}",{name = shopItem:getName()})
		end
		
		local lbl_hit_sum_Str = string._tran(Consts.Strings.FASTBUG_HIT_HAVE)
		if configId == ShopItem.ExpeditionBuffer then
		  lbl_hit_sum_Str = ""
		end
		
		
		MessageBox.showCommonFastBuy({
			lbl_hit={init=MessageBox.Help.bindStringTTF(tipStr)},
			lbl_hit_sum={init=MessageBox.Help.bindStringTTF(lbl_hit_sum_Str)},
			},

		{
			event_NOMB_ENTER=function(self)
				owner = self:getComponentsAndEvents()
	
				owner.lbl_sum = tolua.cast(owner.lbl_sum,"CCLabelTTF")
				owner.lbl_price = tolua.cast(owner.lbl_price,"CCLabelTTF")
				owner.spr_icon = tolua.cast(owner.spr_icon,"CCSprite")
				owner.money_icon = tolua.cast(owner.money_icon,"CCSprite")
				owner.btn_use = tolua.cast(owner.btn_use,"CCMenuItemImage")
				owner.btn_buy = tolua.cast(owner.btn_buy,"CCMenuItemImage")
				
				if configId == ShopItem.ExpeditionBuffer then
				  local offsetX = 100
				
				  owner.lbl_price:setPositionX(owner.lbl_price:getPositionX() - offsetX)
				  owner.money_icon:setPositionX(owner.money_icon:getPositionX() - offsetX)
				  owner.btn_buy:setPositionX(owner.btn_buy:getPositionX() - offsetX - 25)
				  owner.btn_use:setVisible(false)
				end

				-- local itemIcon = GameData:Instance():getCurrentPackage():getItemSprite(nil, 6, configId, 1)
				local itemIcon = AllConfig.item[configId] and AllConfig.item[configId].item_resource  or nil
				itemIcon = itemIcon and _res(itemIcon) or nil
				if(itemIcon) then
					MessageBox.Help.changeSpriteObj(owner.spr_icon,itemIcon)
					local rare = AllConfig.item[configId].rare or nil
					if(rare>0) then
						local rarebg =_res(3021040+ rare) 
						if rarebg ~= nil then 
							local size= itemIcon:getContentSize()
							rarebg:setPosition(ccp(size.width/2,size.height/2))
							owner.spr_icon:addChild(rarebg, 2)
						end
					end
				end

				local _left_count = -1
				local function checkAndUpdate()

					local left_count = GameData:Instance():getCurrentPackage():getPropsNumByConfigId(configId)
					if(left_count ~=_left_count) then
						owner.lbl_sum:stopAllActions()
						owner.lbl_sum:setScale(1)
						local arr = CCArray:create()
						arr:addObject(CCDelayTime:create(0.3))
						arr:addObject(CCScaleBy:create(0.3, 2))
						arr:addObject(CCScaleBy:create(0.6, 0.5))
						local seq = CCSequence:create(arr)
						owner.lbl_sum:runAction(seq)

						_left_count = left_count
					end
					owner.lbl_sum:setString(""..left_count)
					owner.btn_use:setEnabled(left_count>0)
					
					if configId == ShopItem.ExpeditionBuffer then
					 owner.lbl_sum:setString("")
					end

					if(left_count == 0) then
						owner.lbl_sum:setColor(ccc3(0xff,0,0))
					else
						owner.lbl_sum:setColor(ccc3(0,0xf3,0x2d))
					end

					price = shopItem:getDiscountPrice()
					owner.lbl_price:setString(""..price)
					if(GameData:Instance():getCurrentPlayer():getMoney()< price) then
						owner.lbl_price:setColor(ccc3(0xff,0,0))
					else
						owner.lbl_price:setColor(ccc3(0,0xf3,0x2d))
					end

					owner.btn_buy:setEnabled(canBuy)
				end

				checkAndUpdate()

				net.registMsgCallback(PbMsgId.PlayerBuyFormStoreResultS2C,self,function(self,action,msgId,msg)
					_hideLoading()
					if msg.error == "NO_ERROR_CODE" then
						GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
						checkAndUpdate()
						--use right now
						owner.btn_use:setEnabled(false)
            local propsItem = GameData:Instance():getCurrentPackage():getPropsByConfigId(configId)
            if propsItem ~= nil then 
              _showLoading()
              local data = PbRegist.pack(PbMsgId.UseItemC2S, {item = propsItem:getId(), count = 1})
              net.sendMessage(PbMsgId.UseItemC2S, data) 
            end 
					else 
						Shop:instance():handleErrorCode(msg.error)
						self:close()
					end
				end)

				net.registMsgCallback(PbMsgId.UseItemResultS2C,self,function(self,action,msgId,msg)
						_hideLoading()
						echo("===use result:", msg.error)
						if msg.error == "NO_ERROR_CODE" then 
							local gainItems = GameData:Instance():getCurrentPackage():getGainedItemsExt(msg.client)
								--show toast
							if table.getn(gainItems) == 1 then 
								local numStr = string.format("+%d", gainItems[1].count)
								Toast:showIconNum(numStr, gainItems[1].iconId, gainItems[1].iType, gainItems[1].configId, ccp(display.cx, display.cy))

							elseif table.getn(gainItems) >= 2 then
								local pop = PopupView:createRewardPopup(gainItems)
								self:addChild(pop)
							end 
							
					    local action = transition.sequence({
                CCDelayTime:create(0.85),
                CCCallFunc:create(function()
                  Toast:showString(self, _tr("use_item_success"), ccp(display.cx, display.cy))
                end),
                })
              GameData:Instance():getCurrentScene():runAction(action)
							
							GameData:Instance():getCurrentPackage():parseClientSyncMsg(msg.client)
							if Scenario:Instance():getView() ~= nil and Scenario:Instance():getView():getPopQuickFightView() ~= nil then
							  Scenario:Instance():getView():getPopQuickFightView():reset()
							end
              
							self:close()
							return
						else 
							Toast:showString(self, _tr("system error"), ccp(display.cx, display.cy))
						end

						checkAndUpdate()
				end)
			end,

			event_NOMB_LEAVE=function(self)
												net.unregistAllCallback(self)
											 end,

			event_buy =function(pop)
				owner.btn_buy:setEnabled(false)
				if(GameData:Instance():getCurrentPlayer():getMoney() < price) then
					pop:close()
					Common.Jump4AddMoney()
					return
				end

				_showLoading()
				local data = PbRegist.pack(PbMsgId.PlayerBuyFormStoreC2S, {type=shopItem:getStoreType(), store_item=shopItem:getId(),count=1})
				net.sendMessage(PbMsgId.PlayerBuyFormStoreC2S, data)				
			end,

			event_use =function(pop)
				owner.btn_use:setEnabled(false)
				local propsItem = GameData:Instance():getCurrentPackage():getPropsByConfigId(configId)
				if propsItem ~= nil then 
					_showLoading()
					local data = PbRegist.pack(PbMsgId.UseItemC2S, {item = propsItem:getId(), count = 1})
					net.sendMessage(PbMsgId.UseItemC2S, data) 
				end 
			end
		},nil,MessageBox.Align.CENTER_SCREEN)
	end
	

	Common.Jump4AddMoney = function()
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("img/common/pop.plist","img/common/pop.png")
		local spr = display.newSprite("#bg_3.png")
		spr:setAnchorPoint(ccp(0,0))
		local size = spr:getContentSize()
		local  label = tolua.cast(CCLabelTTF:create(_tr("money_limit_ask"),"Courier-Bold",24.0),"CCLabelTTF")
		label:setPosition(ccp(size.width/2,size.height/2+30))
		label:setColor(ccc3(0,0,0))
		spr:addChild(label)

		return MessageBox.showPannel1(spr,{
				event_NOMB_INSIDE=function()
					return true
				end,
				event_NOMB_LEAVE=function(self)
					CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("img/common/pop.plist")
				end,
				event_MB_OK=function(self)
					self:close()
					local shopController = ControllerFactory:Instance():create(ControllerType.SHOP_CONTROLLER)
					shopController:enter(ShopCurViewType.PAY)
				end
			},-1000)
	end


Common.CommonFastBuySpirit = Object.FunctionBinder(Common.CommonFastBuy,nil,ShopItem.Spirit)
Common.CommonFastBuyToken = Object.FunctionBinder(Common.CommonFastBuy,nil,ShopItem.Token)
