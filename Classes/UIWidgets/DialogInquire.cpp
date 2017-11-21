#include "DialogInquire.h"
#include "cocos-ext.h"


NS_GAME_FRM_BEGIN
USING_NS_CC_EXT;

DialogInquire::~DialogInquire()
{
	
}

DialogInquire::DialogInquire()
:mClickCallback(NULL) 
,clickObj(NULL)
,mCancelCallback(NULL)
,cancelObj(NULL)
,isShowing(false)
,isOnEnterAnimation(false)
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
	baseLayer->addChild(confirmSp);
	confirmSp->setPosition(ccp(this->getContentSize().width - confirmSp->getContentSize().width/2-65.0f,confirmSp->getContentSize().height/2+40.0f));

	//取消按钮
	cancelSp = CCSprite::create("img/update/bn_cancel0.png");
	baseLayer->addChild(cancelSp);
	cancelSp->setPosition(ccp(cancelSp->getContentSize().width/2+65.0f,cancelSp->getContentSize().height/2+40.0f));	
}


void DialogInquire::setConfirmCallback(SEL_CallFuncO cb, CCObject * obj)
{
	mClickCallback = cb; 
	clickObj = obj;
}

void DialogInquire::setCancelCallback(SEL_CallFuncO cb, CCObject * obj)
{
	mCancelCallback = cb; 
	cancelObj = obj;
}

void DialogInquire::onEnter()
{
	CCNode::onEnter();
	CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this,kCCMenuHandlerPriority-312,true);
	baseLayer->setScale(0.1f);
	CCActionInterval*  actionTo = CCScaleTo::create(0.15f,1.0f);
	CCFiniteTimeAction*  action2 = CCSequence::create(
		actionTo,
		CCCallFuncN::create(this, callfuncN_selector(DialogInquire::setAnimationEnd)), 
		NULL);
	baseLayer->runAction(action2);
}

void DialogInquire::onExit()
{
	isOnEnterAnimation = false;
	isShowing = false;
	mClickCallback = NULL; 
	clickObj = NULL;
	mCancelCallback = NULL;
	cancelObj = NULL;
	
	CCDirector::sharedDirector()->getTouchDispatcher()->removeDelegate(this);
	CCNode::onExit();
	
}

bool DialogInquire::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
	if (isOnEnterAnimation)
	{
		return true;
	}
	if (containConfirm(pTouch))
	{
		confirmSp->setScale(1.1f);
	}else if (containCancel(pTouch))
	{
		cancelSp->setScale(1.1f);
	}
	return true;
}

void DialogInquire::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
	if (isOnEnterAnimation)
	{
		return;
	}
	confirmSp->setScale(1.0f);
	cancelSp->setScale(1.0f);
	if (containConfirm(pTouch))
	{
		confirmClick(this);
		dismiss();
	}else if (containCancel(pTouch))
	{
		cancelClick(this);
		dismiss();
	}
}

void DialogInquire::confirmClick(CCNode *node)
{
	if (mClickCallback != NULL)
	{
		(clickObj->*mClickCallback)(this);
	}
}

void DialogInquire::cancelClick(CCNode *node)
{
	if (mCancelCallback != NULL)
	{
		(cancelObj->*mCancelCallback)(this);
	}
}

CCRect DialogInquire::cancelRect()
{
	
	return CCRectMake( 
		cancelSp->getPositionX()-this->getContentSize().width/2 - cancelSp->getContentSize().width/2,
		cancelSp->getPositionY()-this->getContentSize().height/2-cancelSp->getContentSize().height/2,
		cancelSp->getContentSize().width,
		cancelSp->getContentSize().height
		);
}

CCRect DialogInquire::confirmRect()
{
	return CCRectMake(
		confirmSp->getPositionX() - this->getContentSize().width/2-confirmSp->getContentSize().width/2,  
		confirmSp->getPositionY()-this->getContentSize().height/2-confirmSp->getContentSize().height/2,
		confirmSp->getContentSize().width,
		confirmSp->getContentSize().height
		);
}

bool DialogInquire::containConfirm(CCTouch* pTouch)
{
	return confirmRect().containsPoint(convertTouchToNodeSpaceAR(pTouch));
}

bool DialogInquire::containCancel(CCTouch* pTouch)
{
	return cancelRect().containsPoint(convertTouchToNodeSpaceAR(pTouch));
}

void DialogInquire::show(std::string infoStr)
{
	if (isOnEnterAnimation)
	{
		return;
	}
	if (isShowing)
	{
		dismiss();
	}
	
	mInfoLayer->removeChildByTag(1,true);
	setDialogInfo(infoStr);
	CCSize winSize = CCDirector::sharedDirector()->getWinSize();
	CCScene* pScene = CCDirector::sharedDirector()->getRunningScene();

	pScene->addChild(this,1001,100000);
	this->setPosition(ccp(winSize.width/2,winSize.height/2));
	isShowing = true;	
	isOnEnterAnimation = true;
}

void DialogInquire::show(std::string infoStr,CCNode *node)
{
	if (isShowing)
	{
		dismiss();
	}
	mInfoLayer->removeChildByTag(1,true);
	setDialogInfo(infoStr);
	CCSize winSize = CCDirector::sharedDirector()->getWinSize();
	//CCScene* pScene = CCDirector::sharedDirector()->getRunningScene();
	node->addChild(this,1001);
	this->setPosition(ccp(winSize.width/2,winSize.height/2));
	isShowing = true;
}

void DialogInquire::setDialogInfo(std::string infoStr) 
{
	CCLabelTTF *infoLabel = CCLabelTTF::create(infoStr.c_str(),"Arial",24.0f);
	infoLabel->setDimensions(CCSizeMake(480,0));
	infoLabel->setPosition(ccp(mInfoLayer->getContentSize().width/2,mInfoLayer->getContentSize().height/2.0f));
	infoLabel->setColor(ccc3(255,239,165));
	mInfoLayer->addChild(infoLabel,1,1); 
}

void DialogInquire::dismiss()
{
  if (isShowing == false)
  {
    return;
  }
	CCNode* node = getParent();
	mClickCallback = NULL; 
	clickObj = NULL;
	mCancelCallback = NULL;
	cancelObj = NULL;
	mInfoLayer->removeAllChildrenWithCleanup(true);
	removeFromParentAndCleanup(true);
	isOnEnterAnimation = false;
	isShowing = false;
}

bool DialogInquire::isShow()
{
	return isShowing;
}



void DialogInquire::setAnimationEnd(CCNode *obj)
{
	isOnEnterAnimation = false;
}

NS_GAME_FRM_END
