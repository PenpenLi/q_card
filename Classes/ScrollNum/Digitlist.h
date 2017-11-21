
#ifndef NUMBERLIST_H
#define NUMBERLIST_H
#include "cocos2d.h"

class DigitList:public cocos2d::CCNode
{
public:

    //10 个(文本或图片) 数字垂直排成一列，默认显示的数字是defaultDigit
    static DigitList *create(char *fontName, float fontSize, cocos2d::ccColor3B& color3, int defaultDigit = 0);
    static DigitList *create(char *fileName);
    bool initLabel(char *fontName, float fontSize, cocos2d::ccColor3B& color3, int defaultDigit);
    bool initImg(char *fileName);
    bool setDigit(int digit);
    int getDigit(void);
    
    //CC_PROPERTY(int, m_digit, Digit);
    CC_SYNTHESIZE_READONLY(cocos2d::CCSize, m_digitSize, DigitSize);
    
protected:
    //调用OpenGL 接口遮罩显示指定的位置
    void visit();   
private:
    int m_digit;
    int m_gap;
    cocos2d::CCNode *m_leaderNode; 
    
};
#endif

