#include "GuideLayer.h"
#include "UIWidgets/RichLabel.h"

NS_GAME_FRM_BEGIN


CCPoint GuideLayer::m_ArrowPos = ccp(CCDirector::sharedDirector()->getWinSize().width/2.0f,CCDirector::sharedDirector()->getWinSize().height/2.0f);


GuideLayer* GuideLayer::createGuideLayer()
{
	GuideLayer *guideLayer  = new GuideLayer;
	if (guideLayer && guideLayer->init())
	{
		guideLayer->autorelease();
		return guideLayer;
	}

	CC_SAFE_DELETE(guideLayer);
	return NULL;
}

//指导遮罩
bool GuideLayer::init()
{
	if( CCLayer::init() ) 
	{
		setKeypadEnabled(true);
		setTouchEnabled(true);

		for (int i = 0; i<sizeof(m_pSquareVertexes) / sizeof( m_pSquareVertexes[0]); i++ ) 
		{
			m_pSquareVertexes[i].x = 0.0f;
			m_pSquareVertexes[i].y = 0.0f;
		}

		setMaskColorsWithA(0.0);
		setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionColor));

		return true;
	}

	return false;
}

void GuideLayer::onEnter()
{
	CCLayer::onEnter();
}

void GuideLayer::draw()
{
	CC_NODE_DRAW_SETUP();

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );

	//
	// Attributes
	//
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, m_pSquareVertexes);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, 0, m_pSquareColors);

	//ccGLBlendFunc( m_tBlendFunc.src, m_tBlendFunc.dst );

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 10);
	CC_INCREMENT_GL_DRAWS(1);
}

void GuideLayer::setMaskRect(CCRect rect)
{

	CCSize winSize = CCDirector::sharedDirector()->getWinSize();
	if(rect.size.width == winSize.width || rect.size.height == winSize.height || rect.size.width == 0 ||rect .size.height == 0)
	{
		m_bIsHideArrowsw = true;
	}
	else
	{
		m_bIsHideArrowsw = false;
	}

	float midHeight = rect.origin.y + rect.size.height/2.0f;

	if(midHeight <= winSize.height/2)
	{
		m_fGirlPosY = midHeight+ rect.size.height/2.0f + 120 ;
	}
	else if(midHeight > winSize.height/2 && midHeight <winSize.height ) 
	{
		m_fGirlPosY = midHeight - rect.size.height/2.0f - 220 ;
	}
	else
	{
		 m_fGirlPosY = winSize.height/3.0;
	}

	m_showRect = rect;
	m_pSquareVertexes[0].x = rect.origin.x;
	m_pSquareVertexes[0].y = rect.origin.y;
	m_pSquareVertexes[1].x = 0;
	m_pSquareVertexes[1].y = 0;
	m_pSquareVertexes[2].x = rect.origin.x+rect.size.width;
	m_pSquareVertexes[2].y = rect.origin.y;
	m_pSquareVertexes[3].x = winSize.width;
	m_pSquareVertexes[3].y = 0;
	m_pSquareVertexes[4].x = rect.origin.x+rect.size.width;
	m_pSquareVertexes[4].y = rect.origin.y+rect.size.height;
	m_pSquareVertexes[5].x = winSize.width;
	m_pSquareVertexes[5].y = winSize.height;
	m_pSquareVertexes[6].x = rect.origin.x;
	m_pSquareVertexes[6].y = rect.origin.y+rect.size.height;
	m_pSquareVertexes[7].x = 0;
	m_pSquareVertexes[7].y = winSize.height;
	m_pSquareVertexes[8] = m_pSquareVertexes[0];
	m_pSquareVertexes[9] = m_pSquareVertexes[1];
	
	if(rect.size.width == 0 || rect.size.height == winSize.width)
	{
		setMaskColorsWithA(0.5);
	}

}

void GuideLayer::setMaskColorsWithA(float a)
{
	m_pSquareColors[0] =ccc4f(0,0,0, a);
	m_pSquareColors[1] =ccc4f(0,0,0, a);
	m_pSquareColors[2] =ccc4f(0,0,0, a);
	m_pSquareColors[3] =ccc4f(0,0,0, a);
	m_pSquareColors[4] =ccc4f(0,0,0, a);
	m_pSquareColors[5] =ccc4f(0,0,0, a);
	m_pSquareColors[6] =ccc4f(0,0,0, a);

	m_pSquareColors[7] =ccc4f(0,0,0, a);
	m_pSquareColors[8] =ccc4f(0,0,0, a);
	m_pSquareColors[9] =ccc4f(0,0,0, a);
}

//配置提示图片的路径
void GuideLayer::setMaskPicturePath(const char*guideInfo,const char *guideTips, CCPoint poxPoint,emStandDir dirStand, emPromptDirection dir )
{
	dirStand = emLeft; //默认都是左方向
	dir = emUpArrow;  // 默认方向
	CCSize winSize = CCDirector::sharedDirector()->getWinSize();
	CCSprite* tipArrow = CCSprite::create("img/guide/guide_finger.png");
	tipArrow->setAnchorPoint(ccp(0.5,0.5));
	if(m_bIsHideArrowsw == true)
	{
		tipArrow->setVisible(false);
	}

	CCLayerColor *tipIconNode = CCLayerColor::create(ccc4(0,0,0,0));
	tipIconNode->setContentSize(CCSizeMake(310,150));

	CCSprite *playerGuideBg = NULL;
	{

		playerGuideBg = CCSprite::create("img/guide/guide_bg.png"); 
		playerGuideBg->setAnchorPoint(ccp(0,0.5));
		if (poxPoint.y != 0)
		{
			playerGuideBg->setPosition(ccp(20.0f,poxPoint.y ));
		}
		else
		{
			playerGuideBg->setPosition(ccp(20.0f,m_fGirlPosY ));
		}
		addChild(playerGuideBg,10);

	}
	
	CCPoint pos= CCPointZero;
	switch(dir)
	{
	case emUpArrow:
		
		tipArrow->setAnchorPoint(ccp(0.5,0.5));
		tipArrow->setPosition(m_ArrowPos);
		pos = CCPointMake(m_showRect.origin.x + m_showRect.size.width/2+tipArrow->getContentSize().width/2.0,m_showRect.origin.y + m_showRect.size.height/2-tipArrow->getContentSize().height/2.0);
		m_ArrowPos = pos ;// CCPointMake(m_showRect.origin.x + m_showRect.size.width,m_showRect.origin.y+m_showRect.size.height);
		//tipArrow->setPosition(ccp(m_showRect.origin.x + m_showRect.size.width/2,m_showRect.origin.y+m_showRect.size.height));
		break;
	case emDownArrow:
		tipArrow->setAnchorPoint(ccp(0.5,1.0));
		tipArrow->setPosition(m_ArrowPos);	
		tipArrow->setScaleY(-1);
		pos = ccp(m_showRect.origin.x + m_showRect.size.width/2,m_showRect.origin.y -tipArrow->getContentSize().height);
		m_ArrowPos = pos;
		//tipArrow->setPosition(ccp(m_showRect.origin.x + m_showRect.size.width/2,m_showRect.origin.y -tipArrow->getContentSize().height));
		break;
	case emLeftArrow:
		tipArrow->setAnchorPoint(ccp(0.5,0.5));
		tipArrow->setPosition(m_ArrowPos);
		tipArrow->setRotation(270);
		pos = ccp(m_showRect.origin.x - tipArrow->getContentSize().height/2 ,m_showRect.origin.y + m_showRect.size.height/2);
		m_ArrowPos = pos;
		//tipArrow->setPosition(ccp(m_showRect.origin.x - tipArrow->getContentSize().height/2 ,m_showRect.origin.y + m_showRect.size.height/2));
		break;
	case emRightArrow:
		tipArrow->setAnchorPoint(ccp(0.5,0.5));
		tipArrow->setPosition(m_ArrowPos);
		tipArrow->setRotation(90);
		pos = ccp(m_showRect.origin.x + m_showRect.size.width + tipArrow->getContentSize().height/2,m_showRect.origin.y+m_showRect.size.height/2);
		m_ArrowPos = pos;
		//tipArrow->setPosition(ccp(m_showRect.origin.x + m_showRect.size.width + tipArrow->getContentSize().height/2,m_showRect.origin.y+m_showRect.size.height/2));
		break;
	default:
		break;
	}
	CCActionInterval *action = CCMoveTo::create(0.6f,pos);
	tipArrow->runAction(action);

	// TODO:手指运动
	if(dir == emUpArrow || dir == emDownArrow)
	{
		tipArrow->runAction(CCRepeatForever::create(CCSequence::createWithTwoActions(CCScaleBy::create(0.3f, 0.95f),
			CCScaleTo::create(0.325f, 1))));
	}
	else
	{
		CCActionInterval*  actionBy = CCMoveBy::create(0.2f, CCPointMake(8,0));
		CCActionInterval*  actionByBack = actionBy->reverse();

		tipArrow->runAction( CCRepeatForever::create(CCSequence::createWithTwoActions(actionBy, actionByBack)));
	}
	addChild(tipArrow,100);

	CCSprite *tipsIcon = CCSprite::create("img/guide/arrow.png"); 
	tipsIcon->setPosition(ccp(playerGuideBg->getContentSize().width - 40.0f,120.0f));
	CCActionInterval*  actionUp = CCJumpBy::create(2, CCPointMake(0,0), 5, 4);
	tipsIcon->runAction(CCRepeatForever::create(actionUp));
	playerGuideBg->addChild(tipsIcon,10);

	// 计算文字框的背景用图以及位置
	tipIconNode->setAnchorPoint(CCPointZero);
	tipIconNode->setPosition(ccp(275,102));
	playerGuideBg->addChild(tipIconNode,0);

	if(strlen(guideInfo) == 0 && strlen(guideTips) == 0)
	{
		playerGuideBg->removeFromParentAndCleanup(true);
	}
	else
	{
		CCLabelTTF * label = CCLabelTTF::create(guideInfo, "黑体", 22, CCSizeMake(295, 110),kCCTextAlignmentLeft);
		label->setAnchorPoint(ccp(0,0));
		//RichLabel * label = RichLabel::create(guideDesc.str().c_str(), "fzcyjt", 20, CCSizeMake(255, 150),true,false);
		label->setPosition(ccp(0,5)); 
		label->setColor(ccc3(69,20,1)); 
		
		CCLabelTTF *tipsLabel = CCLabelTTF::create(guideTips,"黑体",22/*,CCSizeMake(250, 30),kCCTextAlignmentLeft*/); 
		//RichLabel *tipsLabel = RichLabel::create(guideTips,"fzcyjt",20,CCSizeMake(255, 30),true,false); 
		
		tipsLabel->setAnchorPoint(ccp(0,0.5));
		tipsLabel->setPosition(ccp(0,130));
		tipsLabel->setColor(ccc3(255, 240, 0));
		tipIconNode->addChild(label);
		tipIconNode->addChild(tipsLabel);
	}
}

bool GuideLayer::ccTouchBegan(CCTouch* touch, CCEvent* event)
{
	CCPoint p = touch->getLocation();
	if(m_showRect.containsPoint(p) || mSkipBtnRect.containsPoint(p))
	{
		//CCDirector::sharedDirector()->getTouchDispatcher()->removeDelegate(this);
		//CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this,kCCMenuHandlerPriority-1000,false);
		//removeFromParentAndCleanup(true);
		CCNotificationCenter::sharedNotificationCenter()->postNotification("SEND_GUIDEID_2_SEVERE");
		return false;
	}
	else if(m_showRect.size.width == 0 || m_showRect.size.height == 0)
	{
		//removeFromParentAndCleanup(true);
    CCNotificationCenter::sharedNotificationCenter()->postNotification("SEND_GUIDEID_2_SEVERE");
		CCNotificationCenter::sharedNotificationCenter()->postNotification("GUIDE_LAYER_REMOVED");
    //CCNotificationCenter::sharedNotificationCenter()->postNotification("LEVEL_TRIGGER_REMOVED");
		return true;
	}
	else
	{
		return true;
	}

}

void GuideLayer::registerWithTouchDispatcher()
{
	CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this,kCCMenuHandlerPriority-1000,true);
}

void GuideLayer::ccTouchEnded(CCTouch* touch, CCEvent* event)
{
	//CCPoint p = touch->getLocation();
	//if(m_showRect.containsPoint(p))
	//{
	//	removeFromParentAndCleanup(true);
	//}
}

void GuideLayer::keyBackClicked()
{

	//DialogInquire::getInstance()->show(Global::getInstance()->getString("exit_prompt"));
	//DialogInquire::getInstance()->setConfirmCallback(callfuncO_selector(GuideMask::exitGame),this);

	//Global::getInstance()->playEffect(15);

	/*SRoleInfo * roleInfo = RoleDataManager::getInstance()->getRoleInfo();
	int lastGuideId = roleInfo->otherData.nRemainVar[eRemainGuide];

	int nextGuide = 0, condType = 0, condValue = 0;
	int menuOpen = 0;
	Resource::sharedResource()->getNextGuideCondition(lastGuideId, nextGuide, condType, condValue, menuOpen);*/
	//ServerMessageHandler::sharedMessageHandler()->setGuideTagId(mCurGuideId);

	//mFilterLayer->removeFromParentAndCleanup(true);
	//removeFromParentAndCleanup(true);
}

void GuideLayer::exitGame(CCObject* pSender)
{
	CCDirector::sharedDirector()->end();
}

void GuideLayer::skip()
{
	//keyBackClicked();
	CCDirector::sharedDirector()->end();
}

NS_GAME_FRM_END