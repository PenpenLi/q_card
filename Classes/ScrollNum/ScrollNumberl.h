
#ifndef SCROLLNUMBER_H
#define SCROLLNUMBER_H

#include "cocos2d.h"

USING_NS_CC;

class ScrollNumberl:public CCNode
{
public:
    //创建 位数为listCount 的数字滚动盘, 默认显示数字0 
    static ScrollNumberl *createScrollLabel( char *fontName, float fontSize, ccColor3B& color3, int maxCols = 8);
    static ScrollNumberl *createScrollImg(char *fileName, int maxCols = 8);
    //设置要显示的数字
    void setNumber(int number);
    void setNumberExt(int number, const char *strSuffix); /*超过4位则显示以万为单位*/
private:
    bool initLabelList( char *fontName, float fontSize, ccColor3B& color3, int maxCols);
    bool initImgList(char *fileName, int maxCols);
    CCNode *pNodeHeader;
    CCSize m_digitSize;
    int maxListCount; 
};

#endif

