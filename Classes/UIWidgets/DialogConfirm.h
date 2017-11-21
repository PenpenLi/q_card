/****************************************************************************
	询问对话框
***************************************************************************/
#ifndef __DIALOG_CONFIRM_H__
#define __DIALOG_CONFIRM_H__

#include "cocos2d.h"
USING_NS_CC;
#include "Common/Singleton.h"
#include "RichLabel.h"

NS_GAME_FRM_BEGIN
class DialogConfirm  : public CCNode, public CCTargetedTouchDelegate,public Singleton<DialogConfirm>
{
public:

	DialogConfirm();
	virtual ~DialogConfirm();
	
	void onEnter();
	void onExit();
	CCRect confirmRect();
	
	bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	bool containConfirm(CCTouch* pTouch);

	void show(std::string infoStr);
	void show(std::string infoStr,CCNode* node);
	void dismiss();
	bool isShow();
	void setConfirmCallback(SEL_CallFuncO cb, CCObject * obj);//设置点击回调
	CCLayerColor* baseLayer;
private:
	void setDialogInfo(std::string infoStr);

	void confirmClick(CCNode *node);
	CCSprite* confirmSp;

	SEL_CallFuncO mClickCallback;
	CCObject *clickObj;

	CCSprite *bg;
	CCLayerColor* mInfoLayer;//定义文本内容大小
	bool isShowing;
};

NS_GAME_FRM_END

#endif