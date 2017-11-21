

#include "CursorTextField.h"
#include "GameEntry.h"


const static float DELTA = 15.0f;

CursorTextField::CursorTextField()
{
    CCTextFieldTTF();
    
    m_pCursorSprite = NULL;
    m_pCursorAction = NULL;
    
    m_pInputText = NULL;
    m_pDisplayText = NULL;

    m_pLineString = NULL;

    m_cursorPos = 0;
    rowIndex = 0;
    memset(totalRow, 0, sizeof(totalRow));

    setDesignedSize(CCSizeMake(100, 30));
    
    m_enabled = true;

    
    
}

CursorTextField::~CursorTextField()
{
    delete m_pInputText;
    delete m_pDisplayText;
    delete m_pLineString;

    this->m_pLineText->release();
    
    GameEntry::instance()->setKeypadForUser(false);
}

void CursorTextField::onEnter()
{
    CCLOG("CursorTextField::onEnter");
    CCTextFieldTTF::onEnter();
    CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, -301, false);
    this->setDelegate(this);
}

void CursorTextField::onExit()
{
    CCLOG("CursorTextField::onExit");
    CCTextFieldTTF::onExit();
    CCDirector::sharedDirector()->getTouchDispatcher()->removeDelegate(this);
    CCScene *curScene = CCDirector::sharedDirector()->getRunningScene();
    curScene->setPosition(ccp(0, 0));     
}

CursorTextField * CursorTextField::textFieldWithPlaceHolder(const char *placeholder, const char *fontName, float fontSize)
{
    CursorTextField *pRet = new CursorTextField();
    
    if(pRet && pRet->initWithString("", fontName, fontSize))
    {
        pRet->autorelease();
        if (placeholder)
        {
            pRet->setPlaceHolder(placeholder);
        }
        
        pRet->setAnchorPoint(ccp(0,1)); //must be set to (0,1)
        
        pRet->setHorizontalAlignment(kCCTextAlignmentLeft);
        pRet->initCursorSprite(fontSize);
        pRet->setCursorColor(ccc3(0,255,0));

        pRet->m_pLineText = CCTextFieldTTF::create("", fontName, fontSize);
        pRet->m_pLineText->retain();
        return pRet;
    }
    
    CC_SAFE_DELETE(pRet);
    
    return NULL;
}

void CursorTextField::initCursorSprite(int nHeight)
{
    //初始化光标
    int column = 4;
    int pixels[50][4];
    for (int i=0; i<nHeight; ++i) 
    {
        for (int j=0; j<column; ++j) 
        {
            //ABGR
             pixels[i][j] = 0xffffffff;
        }
    }

    CCTexture2D *texture = new CCTexture2D();
    texture->initWithData(pixels, kCCTexture2DPixelFormat_RGB888, 1, 1, CCSizeMake(column, nHeight));
    
    m_pCursorSprite = CCSprite::createWithTexture(texture);
    m_pCursorSprite->setPosition( ccp(0, nHeight / 2));
    m_pCursorSprite->setVisible(false);
    this->addChild(m_pCursorSprite);
    
    m_pCursorAction = CCRepeatForever::create((CCActionInterval *) CCSequence::create(CCFadeOut::create(0.25f), CCFadeIn::create(0.25f), NULL));
    
    m_pCursorSprite->runAction(m_pCursorAction);
    m_cursorPos = 0;
    
    m_pInputText = new std::string();
    m_pDisplayText = new std::string();
    m_pLineString = new std::string();

}

void CursorTextField::setCursorColor(const ccColor3B& color3)
{
    updateColor();
    m_pCursorSprite->setColor(color3);
}

bool CursorTextField::ccTouchBegan(cocos2d::CCTouch *pTouch, cocos2d::CCEvent *pEvent)
{    
     m_beginPos = pTouch->getLocation();

    return m_enabled;
}

void CursorTextField::ccTouchEnded(cocos2d::CCTouch *pTouch, cocos2d::CCEvent *pEvent)
{
    //CCPoint endPos = CCDirector::sharedDirector()->convertToGL(pTouch->getLocationInView());
    CCPoint endPos = pTouch->getLocation();
    
    // 判断是否为点击事件
    if (::abs(endPos.x - m_beginPos.x) > DELTA || 
        ::abs(endPos.y - m_beginPos.y) > DELTA) 
    {
        CCLOG(" not touch event !!");
        //不是点击事件
        m_beginPos.x = m_beginPos.y = -1;        
        return;
    }

    CCPoint pp = convertTouchToNodeSpaceAR(pTouch);
    
    //判断打开还是关闭输入法
    bool ret = isInTextField(pTouch);
    CCLOG("--- touch x=%f, y=%f,  isInRect=%d", pp.x, pp.y, ret);
    if (ret)
    {
        openIME();
        m_cursorPos = getCharIndexByPosition(pTouch);
     }
     else 
     {
        closeIME();
     }
}

void CursorTextField::setDesignedSize(CCSize size)
{
    CCLOG("setDesignedSize:%f, %f", size.width, size.height);
    m_designedSize = size;
    this->setDimensions(CCSizeMake(size.width, 0));
}

CCSize CursorTextField::getDesignedSize()
{
    return m_designedSize;
}

const char* CursorTextField::getString(void)
{
    return m_pInputText->c_str();
}

CCRect CursorTextField::getRect()
{
    CCSize size;
    if (m_designedSize.width > 0 && m_designedSize.height > 0) 
    {
         size = m_designedSize;
    }
    else 
    {
        size = getContentSize();
    }
    
    return  CCRectMake(0 - size.width * getAnchorPoint().x, 0 - size.height * getAnchorPoint().y, size.width, size.height);
}

bool CursorTextField::isInTextField(cocos2d::CCTouch *pTouch)
{
    return getRect().containsPoint(convertTouchToNodeSpaceAR(pTouch));
}


bool CursorTextField::rearrangeTextDisplay()
{
    //rerange text display
    m_pDisplayText->resize(0);
    
    char *startIdx = (char *)m_pInputText->c_str();
    char *endIdx = startIdx + m_pInputText->size();
    char *p = startIdx;
    
    rowIndex = 0;
    totalRow[0] = 0;

    int charNum = 0; //用于快速计算字串宽度; 中文是英文字符宽度的2倍.
    while(p < endIdx)
    {
       //get one line str
       int bytes = 0;
        if (*p >= 0x00 && *p <= 0x7f) /*该字符只有1 个字节*/
        {
            bytes = 1;
        }
        else if ((*p & 0xe0)== 0xc0)  /*该字符包含2 个字节*/
        {
            bytes = 2;
        }
        else if ((*p & 0xf0)== 0xe0) /*该字符包含3 个字节*/
        {
            bytes = 3;
        }        

        if (p[0] == '\n')
        {
            totalRow[++rowIndex] = p-startIdx+1;
            charNum = 0;
        }
        else
        {
            charNum += (bytes ==1 ? 1: 2);
            int subLen = charNum * getFontSize()/2;
            // CCLOG("subLen =%d ", subLen);
            
            if (subLen > m_designedSize.width)
            {
                float lineHeight =getContentSize().height/(rowIndex+1);
                //out of max range. do not insert any more.
                if ((rowIndex+1)*lineHeight > getDesignedSize().height)
                {
                    return false;
                }
                
                //start new line
                totalRow[++rowIndex] = p-startIdx;           
                m_pDisplayText->append("\n");
                charNum = (bytes ==1 ? 1: 2);
            }     
        }
        m_pDisplayText->append(p, bytes);
       

        
        p += bytes;
    }

    return true;
}

int CursorTextField::getCharIndexByPosition(cocos2d::CCTouch *pTouch)
{
   int index = 0;
   CCPoint cursorPos;
   float lineHeight =getContentSize().height/(rowIndex+1);
   CCPoint pos = convertTouchToNodeSpaceAR(pTouch);
   CCRect rect = getRect();

   int row = -pos.y/lineHeight;
   int offsetX = pos.x - rect.origin.x;
   CCLOG("touch_y=%f, row=%d,offsetX=%d", pos.y, row,offsetX);

    if (m_pInputText->empty())
    {
        return 0;
    }
    //when out of max row ,then set the last row
    if (row >rowIndex)
    {
         row = rowIndex;
    }
    
    //one line str max len
    char *startIdx = (char *)m_pInputText->c_str();
    char *p = startIdx + totalRow[row];
    char *pBackup = p;
    char *endIdx = p + (m_pInputText->size()-totalRow[row]);
    if (row < rowIndex)
    {  
        endIdx = p+ (totalRow[row+1] - totalRow[row]);
    }
    
    CCLOG("cur line string = %s", p);
    
    //the last of current line 
    index = endIdx-startIdx;
    
    bool found = false;
    int charNum = 0; 
    
    while (p < endIdx)
    {       
       int bytes = 0;
       
        if (*p == '\n')
        {
            break;
        }
        else if (*p >= 0x00 && *p <= 0x7f) 
        {
            bytes = 1;
        }
        else if ((*p & 0xe0)== 0xc0) 
        {
            bytes = 2;
        }
        else if ((*p & 0xf0)== 0xe0) 
        {
            bytes = 3;
        } 
        
        float preW = charNum * getFontSize()/2;
        charNum += (bytes ==1 ? 1: 2);
        float curW = charNum * getFontSize()/2;

        if (curW >= offsetX)
        {
            found = true;
            if ((offsetX-preW) > (curW-offsetX))
            {
                //index = totalRow[row] + totalBytes;
                index = p - startIdx + bytes;
                cursorPos.x = curW;
            }
            else
            {
               // index = totalRow[row] + totalBytes - bytes;
                index = p - startIdx;
                cursorPos.x = preW;
            }
            
            break;
        }
        p += bytes;            
    }


    if (!found) 
    {
        cursorPos.x = charNum * getFontSize()/2;
        CCLOG(" set the last position: charNum=%d", charNum);
    }
    
    m_cursorPos = totalRow[row]+charNum;
    cursorPos.y = (rowIndex-row)*lineHeight+lineHeight/2; 

    CCLOG("--demension height=%f, fontheight=%f", getContentSize().height, lineHeight);
    CCLOG("--rowIndex row= %d, %d", rowIndex, row);
    m_pCursorSprite->setPosition(cursorPos); 

    
#if 0    
    pos.y = (rowIndex-row)*getFontSize()+getFontSize()/2; 
    CCLOG("cursor position = (%f, %f) to  ( %f, %f)", m_pCursorSprite->getPositionX(), m_pCursorSprite->getPositionY(), pos.x, pos.y);
    m_pCursorSprite->setPosition(pos);        

    CCLOG("index=%d", index);
#endif 

    return index;
}

bool CursorTextField::onTextFieldAttachWithIME(cocos2d::CCTextFieldTTF *pSender)
{
    CCScene *curScene = CCDirector::sharedDirector()->getRunningScene();
    curScene->setPosition(ccp(0, 300));       
    
    if (m_pInputText->empty()) {
        return false;
    }
    
    m_pCursorSprite->setPositionX(this->m_pLineText->getContentSize().width);
     
    return false;
}

bool CursorTextField::onTextFieldDetachWithIME(cocos2d::CCTextFieldTTF *pSender)
{
    CCScene *curScene = CCDirector::sharedDirector()->getRunningScene();
    curScene->setPosition(ccp(0, 0));      
    return false;
}

/*
void CursorTextField::insertText(const char * text, int len)
{
    bool ret = onTextFieldInsertText(NULL, text, len);
    if (ret)
    {
        
    }
}
*/

bool CursorTextField::onTextFieldInsertText(cocos2d::CCTextFieldTTF *pSender, const char *text, int nLen)
{
    
    float lineHeight = getContentSize().height/(rowIndex+1);
    
    //check whether out of range or not.
    if (text[0] == '\n')
    {
      #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID||(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32))   
        if ((rowIndex+1)*lineHeight > getDesignedSize().height)
        {
            CCLOG("out of designedSize height");
            return true;
        }
     #else
        closeIME();
        return true;
     #endif
    }

    
    m_pInputText->insert(m_cursorPos, text, nLen);
    m_cursorPos += nLen;
    
    bool ret = rearrangeTextDisplay();

    if (ret)
    {
        //calc cursor position
        int cursorRow = rowIndex;
        for(int i=0; i<=rowIndex;i++)
        {
            if (totalRow[i] > m_cursorPos)
            {
                cursorRow = i-1;
                break;
            }
        }

         
        if (text[0] == '\n')
        {
            m_pDisplayText->append(" ", 1);  
            setString(m_pDisplayText->c_str());
            m_pCursorSprite->setPosition(ccp(0, (rowIndex-cursorRow)*lineHeight + lineHeight/2)); 
        }
        else 
        {            
            setString(m_pDisplayText->c_str());
            m_pLineString->assign((char *)m_pInputText->c_str()+totalRow[cursorRow], m_cursorPos-totalRow[cursorRow]);
            this->m_pLineText->setString(m_pLineString->c_str());
            CCPoint point = ccp(m_pLineText->getContentSize().width, (rowIndex-cursorRow)*lineHeight + lineHeight/2);
            m_pCursorSprite->setPosition(point);
            CCLOG("cursorRow=%d, pos=(%f, %f)", cursorRow, point.x, point.y);
        }
    }
    else
    {
        m_cursorPos -= nLen;
        m_pInputText->erase(m_cursorPos, nLen);
        CCLOG("out of designedSize");
    }

    return true;
}

bool CursorTextField::onTextFieldDeleteBackward(cocos2d::CCTextFieldTTF *pSender, const char *delText, int nLen)
{
    //m_pInputText->resize(m_pInputText->size() - nLen);
    
    if (m_cursorPos > 0)
    {
        // get the delete byte number
        int nDeleteLen = 1;    // default, erase 1 byte
        while(0x80 == (0xC0 & m_pInputText->at(m_cursorPos-nDeleteLen)))
        {
            ++nDeleteLen;
        }
        
        //delete bytes
        m_pInputText->erase(m_cursorPos - nDeleteLen, nDeleteLen);
        m_cursorPos  -= nDeleteLen;
        
        bool ret = rearrangeTextDisplay();
        if (ret)
        {
            float lineHeight =getContentSize().height/(rowIndex+1);
            setString(m_pDisplayText->c_str());
            if (m_pDisplayText->empty())
            {
                m_pCursorSprite->setPosition(ccp(0, lineHeight/2));
            }
            else
            {
                //calc cursor position
                int cursorRow = rowIndex;
                for(int i=0; i<=rowIndex;i++)
                {
                    if (totalRow[i] > m_cursorPos)
                    {
                        cursorRow = i-1;
                        break;
                    }
                }
                m_pLineString->assign((char *)m_pInputText->c_str()+totalRow[cursorRow], m_cursorPos-totalRow[cursorRow]);
                this->m_pLineText->setString(m_pLineString->c_str());
                CCPoint point = ccp(m_pLineText->getContentSize().width, (rowIndex-cursorRow)*lineHeight + lineHeight/2);
                m_pCursorSprite->setPosition(point);    
            }
        }
        
        return false;
    }
    
    return true; //not delete
}



void CursorTextField::openIME()
{
    CCLOG("----openIME");
    GameEntry::instance()->setKeypadForUser(true);
    
    setPlaceHolder(" ");
    m_pCursorSprite->setVisible(true);
    this->attachWithIME();
}

void CursorTextField::closeIME()
{
    CCLOG("----closeIME");
    GameEntry::instance()->setKeypadForUser(false);
    
    m_pCursorSprite->setVisible(false);
    this->detachWithIME();
    
    CCScene *curScene = CCDirector::sharedDirector()->getRunningScene();
    curScene->setPosition(ccp(0, 0)); 
}

void CursorTextField::setEnabled(bool isEnable)
{

    m_enabled = isEnable;

}

bool CursorTextField::getEnabled()
{
    return m_enabled;
}
