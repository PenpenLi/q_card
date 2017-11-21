
#ifndef __GUIDE_LAYER_H__
#define __GUIDE_LAYER_H__

#include "cocos2d.h"
#include "Common/CommonDefine.h"
NS_GAME_FRM_BEGIN
USING_NS_CC;

enum emPromptDirection
{
	emUpArrow =0,	//上
	emDownArrow,	//下
	emLeftArrow,	//左
	emRightArrow,	//右
};

enum emStandDir
{
	emLeft = 0, 
	emRight, 
};

class GuideLayer : public CCLayer
{
public:

	GuideLayer()  {m_bIsHideArrowsw = false,m_fGirlPosY = 0.0;};
	virtual ~GuideLayer()
	{
		CCSize winSize = CCDirector::sharedDirector()->getWinSize() ;
		m_ArrowPos = ccp(winSize.width/2.0f,winSize.height/2.0f);
	}
	//CREATE_FUNC(GuideLayer);

	static GuideLayer* createGuideLayer();
	virtual void registerWithTouchDispatcher();

	virtual bool ccTouchBegan(CCTouch* touch, CCEvent* event);
	virtual void ccTouchEnded(CCTouch* touch, CCEvent* event);
	//virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void keyBackClicked();		//物理键强制退出游戏

	virtual bool isSwallowsTouches() {return false;}
	virtual void onEnter();


	void exitGame(CCObject* pSender);	//强制退出游戏
	

private:
	bool init();
	virtual void draw();//重写draw
	void setMaskColorsWithA(float a);

	ccVertex2F m_pSquareVertexes[10];//顺序设置遮罩区域
	ccColor4F  m_pSquareColors[10];
	CCRect m_showRect;
	CCRect mSkipBtnRect;
	static CCPoint m_ArrowPos;
	bool m_bIsHideArrowsw;
	float m_fGirlPosY;
	
public:

	void setMaskRect(CCRect rect);
	//系统id、操作步骤id
	void setMaskPicturePath(const char*guideInfo,const char *guideTips, CCPoint poxPoint,emStandDir dirStand, emPromptDirection dir = emUpArrow);
	void skip();
};

NS_GAME_FRM_END
#endif
