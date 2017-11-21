

#ifndef CURSORTEXTFIELD_H
#define CURSORTEXTFIELD_H

#include "cocos2d.h"

USING_NS_CC;

class CursorTextField: public CCTextFieldTTF, public CCTextFieldDelegate, public CCTouchDelegate
{
private:
    //点开始位置
    CCPoint m_beginPos;
    
    //光标精灵
    CCSprite *m_pCursorSprite;
    
    //光标动画
    CCAction *m_pCursorAction;
                 
    // 光标位置
    int m_cursorPos;
    
    //保存每一行开始字符的索引位置
    int totalRow[100];
    //行号索引
    int rowIndex;
    
    //输入框内容
    std::string *m_pInputText;
    
    //设置触摸区域以触发输入法
    CCSize m_designedSize;
    
    //ccColor3B m_sColor;
    std::string *m_pDisplayText;

    std::string *m_pLineString;
    CCLabelTTF *m_pLineText;
    bool m_enabled;
public:
    CursorTextField();
    ~CursorTextField();
    
    // static
    static CursorTextField* textFieldWithPlaceHolder(const char *placeholder, const char *fontName, float fontSize);
    
    // CCLayer
    void onEnter();
    void onExit();
    
    // 初始化光标精灵
    void initCursorSprite(int nHeight);
    bool rearrangeTextDisplay();
    int getCharIndexByPosition(cocos2d::CCTouch *pTouch);
    
protected:
    virtual bool onTextFieldAttachWithIME(CCTextFieldTTF *pSender);
    virtual bool onTextFieldDetachWithIME(CCTextFieldTTF * pSender);
    virtual bool onTextFieldInsertText(CCTextFieldTTF * pSender, const char * text, int nLen);
    virtual bool onTextFieldDeleteBackward(CCTextFieldTTF * pSender, const char * delText, int nLen);

    // CCLayer Touch
    bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
    void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
    
public:
    void setDesignedSize(CCSize size);

    CCSize getDesignedSize();

    void setCursorColor(const ccColor3B& color3);

    const char* getString(void);
    
    //判断是否点击在text field 处
    bool isInTextField(CCTouch *pTouch);
    // 得到textfield 区域
    CCRect getRect();
    
    //打开输入法
    void openIME();
    //关闭输入法
    void closeIME();

    void setEnabled(bool isEnable);
    
    bool getEnabled();
    
};

#endif
