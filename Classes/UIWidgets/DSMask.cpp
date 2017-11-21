#include "DSMask.h"

NS_GAME_FRM_BEGIN

DSMask* DSMask::createMask(CCSize contentSize,CCSprite *bg)
{
	DSMask *mask  = new DSMask;
	if (mask && mask->init(contentSize,bg))
	{
		mask->autorelease();
		return mask;
	}

	CC_SAFE_DELETE(mask);
	return NULL;
}



DSMask* DSMask::createMask(CCSize contentSize)
{
	return createMask(contentSize,NULL);
}

bool DSMask::init(CCSize contentSize,CCSprite *bg)
{
	bool  bRet = false;
	do 
	{
		if ( !CCLayerColor::initWithColor(ccc4(0, 0, 0,0)))
		{
			return false;
		}
		mMaskSize = contentSize;
		this->setContentSize(mMaskSize);
		if (bg != NULL)
		{
			this->addChild(bg);
			bg->setPosition(ccp(mMaskSize.width/2,mMaskSize.height/2));

		}
		//this->setAnchorPoint(ccp(0,0));
		bRet = true;
	} while (0);
	return bRet;
}

void DSMask::visit()
{
	//CCPoint screenPos = this->convertToWorldSpace(this->getParent()->getPosition());
	CCPoint pos = this->getPosition();
	CCPoint posparent = this->getParent()->getPosition();
	CCPoint screenPos = this->getParent()->convertToWorldSpace(this->getPosition());
	glEnable(GL_SCISSOR_TEST);
	float s = this->getScale();

	CCEGLView::sharedOpenGLView()->setScissorInPoints(screenPos.x*s, screenPos.y*s, mMaskSize.width*s, mMaskSize.height*s);

	CCNode::visit();
	glDisable(GL_SCISSOR_TEST);
}

CCRect DSMask::rect()
{
	return CCRectMake(-mMaskSize.width/2.0f,-mMaskSize.height/2.0f,mMaskSize.width,mMaskSize.height);
	//return CCRectMake(0,0,mMaskSize.width,mMaskSize.height);
}

bool DSMask::containsTouchLocation(CCTouch* pTouch)
{
	return rect().containsPoint(convertTouchToNodeSpaceAR(pTouch));
}

DrawCricleMask *DrawCricleMask::create(float fRadius,CCNode *node)
{

	DrawCricleMask *drawCricleMask = new DrawCricleMask;
	if(drawCricleMask && drawCricleMask->init(fRadius,node))
	{
		drawCricleMask->autorelease();
		return drawCricleMask;
	}
	CC_SAFE_DELETE(drawCricleMask);
	return NULL;
}

bool DrawCricleMask::init(float fRadius,CCNode *childNode)
{
	bool bRet = false;
	do 
	{
		CCDrawNode *shape = CCDrawNode::create();
		static ccColor4F green = {0, 1, 0, 1};	
		const int nCount= 300;
		const float coef = 2.0f * (float)M_PI/nCount;
		static CCPoint circle[nCount];	

		for(unsigned int i = 0;i <nCount; i++) 
		{  
			float rads = i*coef;					
			circle[i].x = fRadius * cosf(rads);			
			circle[i].y = fRadius * sinf(rads);		
		}  
		shape->drawPolygon(circle, nCount, green, 0, green);
		CCClippingNode *clipper = CCClippingNode::create();
		clipper->setAnchorPoint(ccp(0.5, 0.5));
		clipper->setStencil(shape);
		this->addChild(clipper);

		clipper->addChild(childNode);
		bRet = true;

	} while (0);
	return bRet;
}

NS_GAME_FRM_END