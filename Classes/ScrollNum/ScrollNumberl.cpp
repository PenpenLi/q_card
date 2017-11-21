
#include "ScrollNumberl.h"
#include "DigitList.h"


USING_NS_CC;


//label number scroller
ScrollNumberl *ScrollNumberl::createScrollLabel(char *fontName, float fontSize, ccColor3B& color3, int maxCols)
{
    ScrollNumberl *panel = new ScrollNumberl();
    panel->initLabelList(fontName, fontSize,color3, maxCols);
    panel->autorelease();

    return panel;
}

//image number scroller
ScrollNumberl *ScrollNumberl::createScrollImg(char *fileName, int maxCols)
{
    ScrollNumberl *panel = new ScrollNumberl();
    panel->initImgList(fileName, maxCols);
    panel->autorelease();

    return panel;
}

bool ScrollNumberl::initLabelList(char *fontName, float fontSize, ccColor3B& color3, int maxCols)
{
    pNodeHeader = CCNode::create();
    //pNodeHeader->removeAllChildren();
    maxListCount = maxCols;
    for(int index = 0; index < maxCols; index++)
    {
        DigitList *digitList = DigitList::create(fontName, fontSize, color3); 
        m_digitSize = digitList->getDigitSize();
        digitList->setPosition(ccp(m_digitSize.width * index , 0));
        pNodeHeader->addChild(digitList, 0, index);
    }

    //init ext str
    
    CCLabelTTF *labelExt = CCLabelTTF::create("W", fontName, fontSize);
    labelExt->setColor(color3);
    labelExt->setVisible(false);
    pNodeHeader->addChild(labelExt, 0, 100);
    
    this->addChild(pNodeHeader);
    
    return true;
}



bool ScrollNumberl::initImgList(char *fileName, int maxCols)
{
    pNodeHeader = CCNode::create();

    if(fileName != NULL)
    {
        maxListCount = maxCols;
        for(int index = 0; index < maxCols; index++)
        {
            DigitList *digitList = DigitList::create(fileName); 
            m_digitSize = digitList->getDigitSize();
            digitList->setPosition(ccp(m_digitSize.width * index , 0));
            pNodeHeader->addChild(digitList, 1, index);
        }
        
        //init ext str
        CCLabelTTF *labelExt = CCLabelTTF::create("W", "Asial", m_digitSize.height);
        labelExt->setVisible(false);
        pNodeHeader->addChild(labelExt, 1, 100);

        this->addChild(pNodeHeader);
        return true;
    }

    return false;
}


void ScrollNumberl::setNumber(int number)
{
    int listCount = 1;
    bool needScale = false; 
    
    while(number >= pow(10.0, listCount))
    {
        listCount++;
    }    

    if (listCount > maxListCount)
    {
        listCount = maxListCount;
    }

    for(int i = 0; i < maxListCount; i++)
    {
        DigitList *digitList = (DigitList *)pNodeHeader->getChildByTag(i);
        if (digitList)
        {
            if (i < listCount)
            {
                digitList->setVisible(true);

                 //set digit from high to low
                int digit = (number/(int)(pow(10.0, listCount-i-1))) % 10;
                bool flag = digitList->setDigit(digit);
                if (flag)
                {
                    needScale = flag;
                }
            }
            else 
            {
                digitList->setVisible(false);
            }
        }
    }

    pNodeHeader->setPosition(ccp(-listCount*m_digitSize.width/2, -m_digitSize.height/2));
    
    pNodeHeader->stopAllActions();
    pNodeHeader->setScale(1.0);
        
    //scale number when scroll finished.
    if (needScale)
    {
        CCDelayTime *act0 = CCDelayTime::create(0.3);
        CCScaleBy *act1 = CCScaleBy::create(0.3, 1.3);
        CCFiniteTimeAction *act2 = act1->reverse();
        
        CCArray *arr = CCArray::create();
        arr->addObject(act0);
        arr->addObject(act1);
        arr->addObject(act2);
        CCSequence *seq = CCSequence::create(arr);
        pNodeHeader->runAction(seq);
    }
}

void ScrollNumberl::setNumberExt(int number, const char *strSuffix)
{
    int listCount = 1;
    bool haxExt = false;
    bool needScale = false;
    
    if (number > 99999)
    {
        number /= 10000;
        haxExt = true;
    }
    
    while(number >= pow(10.0, listCount))
    {
        listCount++;
    }    

    if (listCount > maxListCount)
    {
        listCount = maxListCount;
    }

    for(int i = 0; i < maxListCount; i++)
    {
        DigitList *digitList = (DigitList *)pNodeHeader->getChildByTag(i);
        if (digitList)
        {
            if (i < listCount)
            {
                digitList->setVisible(true);
                
                 //set digit from high to low
                int digit = (number/(int)(pow(10.0, listCount-i-1))) % 10;
                bool flag = digitList->setDigit(digit);
                if (flag)
                {
                    needScale = flag;
                }
            }
            else 
            {
                digitList->setVisible(false);
            }
        }
    }

    
    CCLabelTTF *suffix = (CCLabelTTF *)pNodeHeader->getChildByTag(100);   
    if (haxExt)
    {
        if(suffix)
        {
            suffix->setVisible(true);
            suffix->setString(strSuffix);
            suffix->setPosition(ccp(listCount*m_digitSize.width +suffix->getContentSize().width, m_digitSize.height/2));
        }
        pNodeHeader->setPosition(ccp(-listCount*m_digitSize.width/2, -m_digitSize.height/2));
    }
    else 
    {
        if(suffix)
        {
            suffix->setVisible(false);
        }
        pNodeHeader->setPosition(ccp(-listCount*m_digitSize.width/2, -m_digitSize.height/2));
    }

    
    pNodeHeader->setScale(1.0);
        
    if (needScale)
    {
        pNodeHeader->stopAllActions();
        CCDelayTime *act0 = CCDelayTime::create(0.3);
        CCScaleBy *act1 = CCScaleBy::create(0.3, 1.3);
        CCFiniteTimeAction *act2 = act1->reverse();
        
        CCArray *arr = CCArray::create();
        arr->addObject(act0);
        arr->addObject(act1);
        arr->addObject(act2);
        CCSequence *seq = CCSequence::create(arr);
        pNodeHeader->runAction(seq);
    }
    
}


