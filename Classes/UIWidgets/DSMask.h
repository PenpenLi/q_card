/*************************************************************
		通用遮罩层
*************************************************************/


#ifndef __DS_MASK_H__
#define __DS_MASK_H__

#include "cocos2d.h"
#include "Common/CommonDefine.h"
NS_GAME_FRM_BEGIN
USING_NS_CC;

class DSMask : public CCLayerColor
{
public:
	DSMask(){};
	virtual ~DSMask(){};
	static DSMask* createMask(CCSize contentSize,CCSprite *bg);
	static DSMask* createMask(CCSize contentSize);
	virtual void visit();
	CC_SYNTHESIZE(CCSize ,mMaskSize,MaskSize);
	CCRect rect();

	bool containsTouchLocation(CCTouch* pTouch);
protected:
	bool init(CCSize contentSize,CCSprite *bg);
};

class DrawCricleMask : public CCNode
{
public:
	DrawCricleMask(){};
	virtual ~DrawCricleMask(){};
	static DrawCricleMask* create(float fRadius,CCNode *node);
protected:
	bool init(float fRadius,CCNode *node);
};

NS_GAME_FRM_END
#endif