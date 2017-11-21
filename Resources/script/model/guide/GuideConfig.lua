GuideConfig = {}

-- player guide type
GuideConfig.GuideTypeLevel = 0
GuideConfig.GuideTypeMission = 1
GuideConfig.GuideTypeFinishedStage = 2
GuideConfig.GuideTypeEnterStage = 3
GuideConfig.GuideTrigger = "GUIDE_TRIGGER"
GuideConfig.GuideLayerRemoved = "GUIDE_LAYER_REMOVED"
GuideConfig.SendGuideId2Server ="SEND_GUIDEID_2_SEVERE"
GuideConfig.GuideEffectTypeNone = 0
GuideConfig.GuideEffectTypeCyle = 1
GuideConfig.GuideEffectTypeRect = 2

GuideConfig.GuideManagerTypeComponent = 1  --组件容器类型
GuideConfig.GuideManagerTypeStepModuleGroup = 2 --模块分类类型


GuidePosOffsetX = (display.width - 640)/2

GuideConfig.RangeTypeComponent = 0  --控件定位
GuideConfig.RangeTypeRectFullScreen = 2 --全屏定位（点击屏幕继续）
GuideConfig.RangeTypeBattleCardMove = 3 --战斗卡牌位置移动
GuideConfig.RangeTypeRectConfig = 1 --配置定位  以下为定位配置
GuideConfig.RangeTypeBattleFormationCardMove = 5 --布阵卡牌位置移动

GuideConfig.HomeBtnRect = CCRectMake(10 + GuidePosOffsetX,-5,105,105) 
GuideConfig.ScenarioBtnRect = CCRectMake(158 + GuidePosOffsetX,-5,105,110)
GuideConfig.ExpeditionBtnRect = CCRectMake(265 + GuidePosOffsetX,-5,105,110)
GuideConfig.ActivityBtnRect = CCRectMake(360 + GuidePosOffsetX,-5,120,120)
GuideConfig.LastBtnRect = CCRectMake(480 + GuidePosOffsetX,-5,120,120)


GuideConfig.RangeType = {}
GuideConfig.RangeType[1] = GuideConfig.HomeBtnRect
GuideConfig.RangeType[2] = GuideConfig.ScenarioBtnRect
GuideConfig.RangeType[3] = GuideConfig.ExpeditionBtnRect
GuideConfig.RangeType[4] = GuideConfig.ActivityBtnRect
