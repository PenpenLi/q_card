
#ifndef SCROLLNUMBER_H
#define SCROLLNUMBER_H

#include "cocos2d.h"

USING_NS_CC;

class ScrollNumberl:public CCNode
{
public:
    //���� λ��ΪlistCount �����ֹ�����, Ĭ����ʾ����0 
    static ScrollNumberl *createScrollLabel( char *fontName, float fontSize, ccColor3B& color3, int maxCols = 8);
    static ScrollNumberl *createScrollImg(char *fileName, int maxCols = 8);
    //����Ҫ��ʾ������
    void setNumber(int number);
    void setNumberExt(int number, const char *strSuffix); /*����4λ����ʾ����Ϊ��λ*/
private:
    bool initLabelList( char *fontName, float fontSize, ccColor3B& color3, int maxCols);
    bool initImgList(char *fileName, int maxCols);
    CCNode *pNodeHeader;
    CCSize m_digitSize;
    int maxListCount; 
};

#endif

