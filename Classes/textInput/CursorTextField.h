

#ifndef CURSORTEXTFIELD_H
#define CURSORTEXTFIELD_H

#include "cocos2d.h"

USING_NS_CC;

class CursorTextField: public CCTextFieldTTF, public CCTextFieldDelegate, public CCTouchDelegate
{
private:
    //�㿪ʼλ��
    CCPoint m_beginPos;
    
    //��꾫��
    CCSprite *m_pCursorSprite;
    
    //��궯��
    CCAction *m_pCursorAction;
                 
    // ���λ��
    int m_cursorPos;
    
    //����ÿһ�п�ʼ�ַ�������λ��
    int totalRow[100];
    //�к�����
    int rowIndex;
    
    //���������
    std::string *m_pInputText;
    
    //���ô��������Դ������뷨
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
    
    // ��ʼ����꾫��
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
    
    //�ж��Ƿ�����text field ��
    bool isInTextField(CCTouch *pTouch);
    // �õ�textfield ����
    CCRect getRect();
    
    //�����뷨
    void openIME();
    //�ر����뷨
    void closeIME();

    void setEnabled(bool isEnable);
    
    bool getEnabled();
    
};

#endif
