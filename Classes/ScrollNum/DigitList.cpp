
#include "DigitList.h"



USING_NS_CC;


DigitList *DigitList::create(char *fontName, float fontSize,cocos2d::ccColor3B& color3, int defaultDigit)
{
    DigitList *numList = new DigitList();
    numList->initLabel(fontName, fontSize, color3, defaultDigit);
    numList->autorelease();

    return numList;
}

DigitList *DigitList::create(char *fileName)
{
    DigitList *numList = new DigitList();
    numList->initImg(fileName);
    numList->autorelease();

    return numList;
}


bool DigitList::initLabel(char *fontName, float fontSize, ccColor3B& color3, int defaultDigit)
{
    m_leaderNode = CCNode::create();
    m_gap = 2;
    
    
    //add 10 label
    for(int i = 0; i < 10; i++)
    {
        CCLabelTTF *digit = CCLabelTTF::create(CCString::createWithFormat("%d", i)->getCString(), fontName, fontSize);
        m_digitSize = digit->getContentSize();
        digit->setPosition(ccp(m_digitSize.width/2,  m_digitSize.height * i + m_digitSize.height/2 - m_gap));
        digit->setColor(color3);
        m_leaderNode->addChild(digit, 0, i);
    }
    
    this->addChild(m_leaderNode);
    this->setDigit(defaultDigit);
    
    return true;

}


bool DigitList::initImg(char *fileName)
{
    if (!fileName)
    {
        return false;
    }
    
    m_leaderNode = CCNode::create();
    m_gap = 0;
    
    CCSprite *num = CCSprite::createWithSpriteFrameName(fileName);
    //CCSprite *num = CCSprite::create(fileName);
    if (num)
    {
        num->setAnchorPoint(CCPointZero);
        m_digitSize = CCSizeMake(num->getContentSize().width, num->getContentSize().height/10);
        m_leaderNode->addChild(num);
        this->addChild(m_leaderNode);
        return true;
    }
    
    return false;
}

bool DigitList::setDigit(int digit)
{
    if(m_digit != digit)
    {
        m_digit = digit;

        //show scroll animation
        CCMoveTo *moveTo = CCMoveTo::create(0.3,  ccp(0,  - m_digitSize.height * digit));
        m_leaderNode->stopAllActions();
        m_leaderNode->runAction(moveTo);
        return true;
    }

    return false;
}

int DigitList::getDigit(void)
{
    return m_digit;
}

void DigitList::visit(void)
{
    glEnable(GL_SCISSOR_TEST);

    CCPoint location = this->getParent()->convertToWorldSpace(this->getPosition());

/*
    glScissor: ��������ǿ���CCListView������ʾ����Ļ�ϵķ�Χ����������ʹ��������ģʽ��
    ��CC_CONTENT_SCALE_FACTORû�����κ��޸ģ�������������ķ�Χ�Ƕ�Ӧ��DesignResolutionSize
    �趨��ԭʼ��ƻ����С�ģ�������Ļ�ߴ緢���˱仯������CCDirector�����ŵ�����£�
    ���rectSelf  ȴû�����κθı䣬���Ծ͵����������ı��г�һ���ֵ����⡣
    �������:��CCEGLView::sharedOpenGLView()->setScissorInPoints�����滻glScissor����,�����κεط������䡣
*/

    CCEGLView::sharedOpenGLView()->setScissorInPoints(location.x-5, location.y-m_gap, m_digitSize.width+10, m_digitSize.height+2*m_gap);
    //glScissor(location.x, location.y, m_digitSize.width, m_digitSize.height);

    
    CCNode::visit();
    
    glDisable(GL_SCISSOR_TEST);
}

