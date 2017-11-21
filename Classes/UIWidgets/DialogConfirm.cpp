#include "DialogConfirm.h"
#include "cocos-ext.h"

NS_GAME_FRM_BEGIN
USING_NS_CC_EXT;
DialogConfirm::~DialogConfirm()
{
}


 DialogConfirm::DialogConfirm()
 :mClickCallback(NULL) 
 ,clickObj(NULL)
 ,isShowing(false)
 {		
		
	 CCSize winSize = CCDirector::sharedDirector()->getWinSize();

	 this->setAnchorPoint(ccp(0.5,0.5));
	 //对话框背景图
	 CCScale9Sprite * bg = CCScale9Sprite::create("img/update/popup.png");
	 bg->setPreferredSize(CCSizeMake(550.0f,380.0f));
	 CCSize contentSize = bg->boundingBox().size;
	 bg->getContentSize();

	 CCScale9Sprite *blueBg = CCScale9Sprite::create("img/update/blue_bg2.png");
	 blueBg->setPreferredSize(CCSizeMake(520.0f,200.0f));
	 blueBg->setPosition(ccp(bg->boundingBox().size.width/2.0f,bg->boundingBox().size.height/2+30.0f));
	 bg->addChild(blueBg,1);

	 this->setContentSize(bg->getContentSize());
	 baseLayer = CCLayerColor::create();
	 baseLayer->setContentSize(bg->getContentSize());
	 this->addChild(baseLayer,1);


	 CCLayerColor * layerColor = CCLayerColor::create();
	 layerColor->initWithColor(ccc4(0, 0, 0, 150));
	 layerColor->setAnchorPoint(ccp(0.5,0.5));
	 this->addChild(layerColor,-1,-1);
	 layerColor->setPosition(ccp(-winSize.width/2 + this->getContentSize().width/2,-winSize.height/2 + this->getContentSize().height/2));


	 baseLayer->addChild(bg,0);
	 bg->setAnchorPoint(CCPointZero);

	 mInfoLayer = CCLayerColor::create();
	 mInfoLayer->initWithColor(ccc4(0,0,0,0));
	 mInfoLayer->setAnchorPoint(ccp(0.5,0.5));
	 mInfoLayer->setContentSize(CCSizeMake(contentSize.width*4/5,contentSize.height/2));
	 baseLayer->addChild(mInfoLayer,12);
	 mInfoLayer->setPosition(ccp(this->getContentSize().width/2 - mInfoLayer->getContentSize().width/2,this->getContentSize().height/2 - mInfoLayer->getContentSize().height/2+30.0f));
		
	 //确认按钮
	 confirmSp = CCSprite::create("img/update/queding.png");
	// CCSprite* wordConfirm = CCSprite::create("New_Graphics/UI_New_tanchu_002.png");
	// confirmSp->addChild(wordConfirm);
	// wordConfirm->setPosition(ccp(confirmSp->getContentSize().width/2,confirmSp->getContentSize().height/2));
	 baseLayer->addChild(confirmSp);
	 confirmSp->setPosition(ccp(this->getContentSize().width/2,confirmSp->getContentSize().height/2 + 20.0f));
	
}

void DialogConfirm::onEnter()
{
	CCNode::onEnter();
	
	CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this,kCCMenuHandlerPriority-212,true);
	baseLayer->setScale(0.1f);
	CCActionInterval*  actionTo = CCScaleTo::create(0.12f,1.0f);
	baseLayer->runAction(actionTo);
}

void DialogConfirm::onExit()
{
	mClickCallback = NULL; 
	clickObj = NULL;
	isShowing = false;
	CCDirector::sharedDirector()->getTouchDispatcher()->removeDelegate(this);
	CCNode::onExit();
}

bool DialogConfirm::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
	if (containConfirm(pTouch))
	{
		confirmSp->setScale(1.1f);
	}
	return true;
}

void DialogConfirm::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
	confirmSp->setScale(1.0f);
	
	if (containConfirm(pTouch))
	{
		confirmClick(this);
		dismiss();
		//	LoadingUI::getInstance()->dismiss();

	}
}

CCRect DialogConfirm::confirmRect()
{
	return CCRectMake( -confirmSp->getContentSize().width/2,  -this->getContentSize().height/2 + 20.0f,confirmSp->getContentSize().width,confirmSp->getContentSize().height);
}

bool DialogConfirm::containConfirm(CCTouch* pTouch)
{
	return confirmRect().containsPoint(convertTouchToNodeSpaceAR(pTouch));
}

void DialogConfirm::setDialogInfo(std::string infoStr)
{
	CCLabelTTF *infoLabel = CCLabelTTF::create(infoStr.c_str(),"Arial",24.0f);
	infoLabel->setDimensions(CCSizeMake(480,0));
	infoLabel->setPosition(ccp(mInfoLayer->getContentSize().width/2,mInfoLayer->getContentSize().height/2.0f));
	infoLabel->setColor(ccc3(255,239,165));
	mInfoLayer->addChild(infoLabel,1,1);
}

void DialogConfirm::dismiss()
{
	mClickCallback = NULL; 
	clickObj = NULL;
	mInfoLayer->removeAllChildrenWithCleanup(true);
	removeFromParentAndCleanup(false);
	isShowing = false;


}

bool DialogConfirm::isShow()
{
	return isShowing;
}

void DialogConfirm::show(std::string infoStr)
{
	if (!isShowing)
	{
		mInfoLayer->removeChildByTag(1,true);
		setDialogInfo(infoStr);
		CCSize winSize = CCDirector::sharedDirector()->getWinSize();
		CCScene* pScene = CCDirector::sharedDirector()->getRunningScene();
		pScene->addChild(this, 1001);
		this->setPosition(ccp(winSize.width/2,winSize.height/2));
		isShowing = true;
	}
}

void DialogConfirm::show(std::string infoStr,CCNode* node)
{
	if (!isShowing)
	{
		mInfoLayer->removeChildByTag(1,true);
		setDialogInfo(infoStr);
		CCSize winSize = CCDirector::sharedDirector()->getWinSize();
		//CCScene* pScene = CCDirector::sharedDirector()->getRunningScene();
		node->addChild(this,1001);
		this->setPosition(ccp(winSize.width/2,winSize.height/2));
		isShowing = true;
	}

}

void DialogConfirm::setConfirmCallback(SEL_CallFuncO cb, CCObject * obj)
{
	mClickCallback = cb; 
	clickObj = obj;
	/*clickObj->retain();*/
}

void DialogConfirm::confirmClick(CCNode *node)
{
	if (mClickCallback != NULL)
	{
		(clickObj->*mClickCallback)(this);
	}
}
NS_GAME_FRM_END