/****************************************************************************
	询问对话框
***************************************************************************/
#ifndef __DIALOG_INQUIRE_H__
#define __DIALOG_INQUIRE_H__

#include "cocos2d.h"


#include "Common/Singleton.h"

#include "Common/CommonDefine.h"
#include "RichLabel.h"
USING_NS_CC;

NS_GAME_FRM_BEGIN

class DialogInquire : public CCNode, public CCTargetedTouchDelegate,public Singleton<DialogInquire>
{
public:
	DialogInquire();
	virtual ~DialogInquire();
	
	void onEnter();
	void onExit();
	CCRect confirmRect();
	CCRect cancelRect();
	bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	bool containConfirm(CCTouch* pTouch);
	bool containCancel(CCTouch* pTouch);
	/**************** 设置点击回调 **********************/
	void setConfirmCallback(SEL_CallFuncO cb, CCObject * obj);//设置点击回调
	void setCancelCallback(SEL_CallFuncO cb, CCObject * obj);//设置取消回调
	void show(std::string infoStr);
	void show(std::string infoStr,CCNode *node);

	
	void dismiss();
	bool isShow();

	CCLayerColor* baseLayer;


private:
	void setDialogInfo(std::string infoStr);
	void confirmClick(CCNode *node);
	void cancelClick(CCNode* node);
	CCLayerColor* mInfoLayer;//定义文本内容大小


	CCSprite* confirmSp;
	CCSprite* cancelSp;
	SEL_CallFuncO mClickCallback;
	CCObject *clickObj;
	SEL_CallFuncO mCancelCallback;
	CCObject *cancelObj;
	CCSprite *bg;
	bool isShowing;

	
	bool isOnEnterAnimation;
	void setAnimationEnd(CCNode* obj);
};

NS_GAME_FRM_END

#endif