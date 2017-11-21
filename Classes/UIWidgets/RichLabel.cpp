#include <cstdlib>
#include "RichLabel.h"
#include "LabelStroke.h"
#include "Common/conv.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID )
#include "jni/JniHelper.h"
#include <android/log.h>
#include <string.h>
#include <jni.h>
#endif

NS_GAME_FRM_BEGIN

 const int FONT_HEIGHT_GAP = 6;
 
 const char *TAG_END = "</>";
 const char *TAG_VALUE = "<value>";
 
 const char *TAG_COLOR = "<color>";
 const char *TAG_FONT = "<font>";
 
 const char *TAG_NEWLINE = "<n/>";
 const char *TAG_TAB = "<t/>";
 
 const char *TAG_FONTNAME = "<fontname>";
 const char *TAG_FONTSIZE = "<fontsize>";


RichLabel * RichLabel::create(const char* string, const char* fontName, const int fontSize, CCSize labelSize, bool appendString, bool enableShadow)
{
	RichLabel *label = new RichLabel();
	if (label && label->init(string, fontName, fontSize, labelSize, appendString, enableShadow))
	{
		label->autorelease();
		return label;
	}
	CC_SAFE_DELETE(label);
	return NULL;
}


const char * RichLabel::getRichString() 
{ 
	return mString.c_str();
}

const char *RichLabel::getString()
{
	return mShowString.c_str();
}


bool RichLabel::init(const char* string, const char* fontName, const int fontSize, CCSize labelSize, bool appendString, bool enableShadow)
{
    mLabelOffsetX = 0.0;
    mLabelOffsetY = 0.0;

    mNoneTagFound = false;
	mColorTagFound = false;
	mFontTagFound = false;
	mLinkTagFound = false;
	mEmojTagFound = false;
	mFontSizeTagFound = false;
	mEnableShadow = enableShadow;
	
	mNoneTagFound = false;

	mSize = labelSize;
	
	std::string tmpStr = string;

	int offset = tmpStr.find('\n');
	if (offset)
	{
		while (offset > 0)
		{
			tmpStr.replace(offset, 1, TAG_NEWLINE);
			offset = tmpStr.find('\n', offset);
		}
	}
	
	mString = tmpStr;
	
	//setColor(ccWHITE);//默认白色字体
	const ccColor3B& color3 = ccWHITE; 
	m_sColor = ccWHITE;
	mColor = (color3.r << 16 | color3.g << 8 | color3.b);
	mDefaultColor = mColor;

	mAllowAppendString = appendString;

	if (!CCLayerRGBA::init())
		return false;

	setContentSize(labelSize);
	setTouchEnabled(true);

	mLabelOffsetX = 0;
	mLabelOffsetY = labelSize.height - (fontSize + FONT_HEIGHT_GAP);

	mFontName = mDefaultFontName = fontName;
	mFontSize = mDefaultFontSize = fontSize;

	mContentSize.width = 0;
	mContentSize.height = mFontSize + FONT_HEIGHT_GAP;

	if (!mAllowAppendString)
	{
		parse(mString.c_str(), true);
		mParsed = true;
		//setContentSize(mContentSize);
	}

	//registerWithTouchDispatcher();

	return true;
}

void RichLabel::onEnter()
{
 	if (!mParsed)
 	{
 		parse(mString.c_str(), true);
 		mParsed = true;
 		//setContentSize(mContentSize);
 	}

	CCLayerRGBA::onEnter();
	//registerWithTouchDispatcher();
}

ccColor3B _color(int color)
{
	GLubyte r, g, b;

	r = (color >> 16);
	g = (color >> 8);
	b = color;

	return ccc3(r, g, b);
}

//void RichLabel::setColor(ccColor3B color)
//{
//	mColor = (color.r << 16 | color.g << 8 | color.b);
//}

void RichLabel::appendString(const char* string)
{
	mString.append(string);
}

bool RichLabel::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
	CCPoint point = convertToNodeSpace(pTouch->getLocation());

	std::vector<Link>::const_iterator i = mLinkMap.begin(), i_end = mLinkMap.end();
	for (; i!=i_end; ++i)
	{
		if ((*i).rect.containsPoint(point))
		{
			return true;
		}
	}
	
	return false;
}

void RichLabel::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
	CCPoint point = convertToNodeSpace(pTouch->getLocation());

	std::vector<Link>::const_iterator i = mLinkMap.begin(), i_end = mLinkMap.end();
	for (; i!=i_end; ++i)
	{
		if ((*i).rect.containsPoint(point))
		{
			//Global::getInstance()->playEffect(1, false);
			if (mLinkDelegate)
				mLinkDelegate->linkClick(this, (*i).linkType, (*i).linkTarget);
			break;
		}
	}
	
}

void RichLabel::registerWithTouchDispatcher()
{
	CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, kCCMenuHandlerPriority - 20, false);
}

const char * RichLabel::parse(const char* string, bool recurse)
{
	int pos = 0;
	TagType tag = None;
	const char * temp = string;
	
	do
	{
		if (temp == NULL || strlen(temp) == 0)
			return NULL;

		tag = searchTag(temp, pos);
		switch (tag)
		{
		case None:
			createLabel(temp, -1, !mFontTagFound);
			return NULL;
		case EndTag:
			{
				if (pos)
					createLabel(temp, pos, !mFontTagFound);
				return (temp + pos);
			}
			break;
		case LineTag:
			{
				if (pos)
					createLabel(temp, pos, !mFontTagFound);
				temp = parseLine(temp + pos);
			}
			break;
		case FontTag:
			{
				if (pos)
					createLabel(temp, pos, !mFontTagFound);
				temp = parseFont(temp + pos);
			}
			break;
		case ColorTag:
			{
				if (pos)
					createLabel(temp, pos, !mFontTagFound);
				temp = parseColor(temp + pos);
			}
			break;
        case TabTag:
            {
                // Do nothing
            }
            break;
        default:
            break;
		}
	}
	while (recurse && temp && strlen(temp) != 0);

	return temp;
}

RichLabel::TagType RichLabel::searchTag(const char* string, int & pos)
{
	const char * temp = string;
	int i = 0, len = strlen(string);

	while (i < len)
	{
		if (temp[i] == '<')
		{
			pos = i;
			if (strncmp(TAG_FONT, temp+i, strlen(TAG_FONT)) == 0)
				return FontTag;
			else if (strncmp(TAG_COLOR, temp+i, strlen(TAG_COLOR)) == 0)
				return ColorTag;
			else if (strncmp(TAG_TAB, temp+i, strlen(TAG_TAB)) == 0)
				return TabTag;
			else if (strncmp(TAG_NEWLINE, temp+i, strlen(TAG_NEWLINE)) == 0)
				return LineTag;
			else if (strncmp(TAG_END, temp+i, strlen(TAG_END)) == 0)
				return EndTag;
			else
				i++;
		}
		else
			i++;
	}

	return None;
}


#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID )

static int measureWidth = 0;
static int measurenHeight = 0;

extern "C"
{
	void Java_org_cocos2dx_lib_Cocos2dxBitmap_nativeTextProperty(JNIEnv*  env, jobject thiz, int width, int height)
	{
		measureWidth = width;
		measurenHeight = height;
	}
};
#endif

void RichLabel::measureString(const char* string, float &width, float &height)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID )

	measureWidth = width;
	measurenHeight = height;

	JniMethodInfo methodInfo;
        if (! JniHelper::getStaticMethodInfo(methodInfo, "org/cocos2dx/lib/Cocos2dxBitmap", "computeTextProperty", 
            "(Ljava/lang/String;Ljava/lang/String;IIII)V"))
        {
            CCLOG("%s %d: error to get methodInfo", __FILE__, __LINE__);
            return;
        }

        jstring jstrText = methodInfo.env->NewStringUTF(string);
        jstring jstrFont = methodInfo.env->NewStringUTF(mFontName.c_str());

        methodInfo.env->CallStaticVoidMethod(methodInfo.classID, methodInfo.methodID, jstrText, 
            jstrFont, (int)mFontSize, CCImage::kAlignTopLeft, 0, 0);

        methodInfo.env->DeleteLocalRef(jstrText);
        methodInfo.env->DeleteLocalRef(jstrFont);
        methodInfo.env->DeleteLocalRef(methodInfo.classID);

	width = measureWidth;
	height = measurenHeight;

#else//if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 )

	CCImage image;
	CCImage::ETextAlign eAlign = CCImage::kAlignTopLeft;

	if (!image.initWithString(string, 0, 0, eAlign, mFontName.c_str(), (int)mFontSize))
	{
		width = getContentSize().width;
		height = mFontSize + FONT_HEIGHT_GAP;
	}
	else
	{
		width = image.getWidth();
		height = image.getHeight();
	}

#endif
}

size_t RichLabel::searchTruncatePos(const char *string, int pixelWidth)
{
	size_t pos = 0;
	size_t len = strlen(string);

	if (len == 0)
		return 0;

    // 多字节字符串在折半查找过程中无法判断字符编码边界，因此统一转成ucs2宽字符进行折半查找
	uint16_t *wdest = new uint16_t[len+2];
	memset(wdest, 0, (len+2)*sizeof(uint16_t));
	utf82ucs2((char*)string, len, (char*)wdest, len*sizeof(uint16_t));
	
	int wlen = 0;
	for(int i=0; i<len+2; i++)
    {
		if (wdest[i] == 0)
		{
			wlen = i;
			break;
		}
    }
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) 
	// libicuuc.so - first unicode char is 0xFEFF
	wlen -= 1;
	uint16_t *wchar = wdest + 1; 
#else
	uint16_t *wchar = wdest; 
#endif

	if (wlen <= 1)
	{
		delete []wdest;

		float width = 0, height = 0;
		measureString(string, width, height);
		if (width > pixelWidth)
			return 0;
		else
			return len;
	}
	
	uint16_t truncateChar = wchar[wlen/2];
	wchar[wlen/2] = 0;
	
#if 0
	CCLOG("part1:");
	for(int i=0; i<wlen/2; i++)
	{
		CCLOG("%X", wchar[i]);
	}
	CCLOG("part2:");
	for(int i=wlen/2 + 1; i<wlen; i++)
	{
		CCLOG("%X", wchar[i]);
	}
#endif

	char *dest = new char[len+1];
	memset(dest, 0, len+1);
	ucs22utf8((char*)wdest, wlen*sizeof(uint16_t), dest, len);

#if 0
	CCLOG("1:");
	for(int i=0; i<len; i++)
	{
		CCLOG("%X", dest[i]);
	}
#endif

	float width = 0, height = 0;
	measureString(dest, width, height);

	if (width > pixelWidth)
	{
		pos = searchTruncatePos(dest, pixelWidth);
	}
	else if (width < pixelWidth)
	{
		pos = strlen(dest);
		
		wchar[wlen/2] = truncateChar;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID )
		// libicuuc.so - first unicode char is 0xFEFF
		wchar[wlen/2-1] = 0xFEFF;
		wchar += (wlen/2-1);
#else
		wchar += wlen/2;
#endif

		memset(dest, 0, len+1);
		ucs22utf8((char*)wchar, (wlen/2)*sizeof(uint16_t), dest, len);
		
#if 0
		CCLOG("2:");
		for(int i=0; i<len; i++)
		{
			CCLOG("%X", dest[i]);
		}
#endif

		int leftWidth = pixelWidth - (int)width;
		pos += searchTruncatePos(dest, leftWidth);
	}
	else
	{
		pos = strlen(dest);
	}

    delete []wdest;
    delete []dest;
    
	return pos;
}

void RichLabel::createLabel(const char * string, int length, bool defaultFont)
{
	std::string str;

	if (length == -1)
		str = string;
	else
		str = std::string(string, length);

	if (defaultFont)
	{
		mFontName = mDefaultFontName;
	}
	if (mFontSizeTagFound)
    {
		mFontSize = mDefaultFontSize;
	}

	if (str.length())
	{
        int iWidth = (int)(mSize.width - mLabelOffsetX);
        int pos = searchTruncatePos(str.c_str(), iWidth);
		
        if (pos < str.length()) // 字符串显示超过行边界，折断分成两行分别用两个label处理
		{
			if (pos == 0) // 此行已无法完全显示一个字符,则从下一行创建label
			{
				mLabelOffsetX = 0;
				mLabelOffsetY -= (mFontSize + FONT_HEIGHT_GAP);
				mContentSize.width = mSize.width;
				mContentSize.height += mFontSize + FONT_HEIGHT_GAP;

				createLabel(str.c_str(), -1, false);
				
				if (mLabelOffsetY < 0)
					setContentSize(CCSizeMake(mSize.width, mSize.height - mLabelOffsetY + FONT_HEIGHT_GAP));
			}
			else
			{
				createLabel(str.c_str(), pos, false);
				//mLabelOffsetX = 0;
				//mLabelOffsetY -= (mFontSize + FONT_HEIGHT_GAP);
				createLabel(str.c_str()+pos, -1, false);
			}
		}
		else // 单行即可完全显示
		{
			CCSize labelSize;

			if (mEnableShadow == true)
			{
				LabelStroke * label = LabelStroke::create(str.c_str(), mFontName.c_str(), mFontSize);
				//label->setAnchorPoint(CCPointZero);
				label->setPosition(ccp(mLabelOffsetX + getAnchorPoint().x * label->getContentSize().width, 
					mLabelOffsetY + getAnchorPoint().y * label->getContentSize().height));
				addChild(label);

				//if (mColorTagFound)
				label->setColor(_color(mColor));
				//else
				//	label->setColor(ccWHITE);
				labelSize = label->getContentSize();
				mShowString.append(str);
			}
			else
			{
				CCLabelTTF * label = CCLabelTTF::create(str.c_str(), mFontName.c_str(), mFontSize);
				label->setPosition(ccp(mLabelOffsetX + getAnchorPoint().x * label->getContentSize().width, 
					mLabelOffsetY + getAnchorPoint().y * label->getContentSize().height));
				addChild(label);

				label->setColor(_color(mColor));
				labelSize = label->getContentSize();
				mShowString.append(str);
			}
			

			//CCSize labelSize = label->getContentSize();
			mContentSize.width += labelSize.width;
			if (mContentSize.width > getContentSize().width)
				mContentSize.width = getContentSize().width;

			if (mLinkTagFound)
			{
				CCRect rect = CCRectMake(mLabelOffsetX /*+ getAnchorPoint().x * label->getContentSize().width*/,
						mLabelOffsetY /*+ getAnchorPoint().y * label->getContentSize().height*/, labelSize.width, labelSize.height);
				mLink.rect = rect;
				mLinkMap.push_back(Link(mLink));
			}

			mLabelOffsetX += labelSize.width;

			if (mLabelOffsetX >= getContentSize().width)
			{
				mLabelOffsetX = 0;
				mLabelOffsetY -= (mFontSize + FONT_HEIGHT_GAP);

				mContentSize.height += mFontSize + FONT_HEIGHT_GAP;
			}
		}
		
	}
}

const char * RichLabel::parseFont(const char* string)
{
	const char * fontBegin = strstr(string, TAG_FONT);  // <font>

	const char * tempBegin = fontBegin;
	const char * tempEnd = NULL;
    
    tempEnd = strstr(fontBegin, TAG_FONTNAME); //<fontname>
	if (tempEnd)
	{
		const char* fontNameBegin=tempEnd + strlen(TAG_FONTNAME);
		//tempBegin = 
		const char* fontNameEnd = strstr(fontNameBegin, TAG_END);

		mFontName = std::string(fontNameBegin, fontNameEnd - fontNameBegin);
		tempBegin = fontNameEnd + strlen(TAG_END);
		mFontTagFound = true;
	}
    
    tempEnd = strstr(tempBegin, TAG_FONTSIZE); //<fontsize>
	if (tempEnd)
	{
		const char* fontSizeBegin = tempEnd + strlen(TAG_FONTSIZE);
		const char* fontSizeEnd = strstr(fontSizeBegin, TAG_END);

		std::string fontSize(fontSizeBegin, fontSizeEnd - fontSizeBegin);
		std::istringstream is(fontSize);
		is >> mFontSize;
		mFontSizeTagFound = true;

		tempBegin = fontSizeEnd + strlen(TAG_END);
	}
	
	if (mFontTagFound || mFontSizeTagFound) {

		tempEnd = parse(tempBegin, true);
		mFontTagFound = false;
		mFontSizeTagFound = false;

		tempEnd = strstr(tempEnd, TAG_END);
		return tempEnd + strlen(TAG_END);
	}

	return tempBegin + strlen(TAG_FONT);
}


const char * RichLabel::parseColor(const char* string)
{
	const char * tempBegin = strstr(string, TAG_COLOR);  // <color>
	const char * tempEnd = NULL;

    tempEnd = strstr(tempBegin, TAG_VALUE); //<value>
	if (tempEnd)
	{
		tempBegin = tempEnd + strlen(TAG_VALUE);
		tempEnd = strstr(tempBegin, TAG_END);

		std::string color(tempBegin, tempEnd - tempBegin);
		std::istringstream is(color);
		is >> mColor;
	}
    
	mColorTagFound = true;
	if (tempEnd) {

		tempBegin = tempEnd + strlen(TAG_END);
		//tempEnd = strstr(tempBegin, TAG_END);

		//std::string str(tempBegin/*, tempEnd-tempBegin*/);
		tempEnd = parse(tempBegin, true);
		mColorTagFound = false;
		mColor = mDefaultColor;

		tempEnd = strstr(tempEnd, TAG_END);
		return tempEnd + strlen(TAG_END);
	}
	//else
	//	mColorTagFound = false;
	return tempBegin + strlen(TAG_FONT);
}

const char * RichLabel::parseLine(const char* string)
{
	mLabelOffsetX = 0;
	mLabelOffsetY -= (mFontSize + FONT_HEIGHT_GAP);
	mContentSize.height += mFontSize + FONT_HEIGHT_GAP;

	return string + strlen(TAG_NEWLINE);
}


const char * RichLabel::parseTab(const char* string)
{
	mLabelOffsetX += 40;

	return string + strlen(TAG_TAB);
}

GLubyte RichLabel::getOpacity(void)
{
	CCObject* child;
	CCARRAY_FOREACH(getChildren(), child)
	{
		CCRGBAProtocol* pNode = dynamic_cast<CCRGBAProtocol*>(child);
		if (pNode)
		{
			return pNode->getOpacity();
		}
	}

	return 0;
}

void RichLabel::setOpacity(GLubyte opacity)
{
	CCObject* child;
	CCARRAY_FOREACH(getChildren(), child)
	{
		CCRGBAProtocol* pNode = dynamic_cast<CCRGBAProtocol*>(child);
		if (pNode)
		{
			pNode->setOpacity(opacity);
		}
	}
}

const ccColor3B& RichLabel::getColor(void)
{
	return m_sColor;
}

void RichLabel::setColor(const ccColor3B& color3)
{
	m_sColor = color3;
	mColor = (color3.r << 16 | color3.g << 8 | color3.b);
	mDefaultColor = mColor;

	if (!mParsed)
	{
		parse(mString.c_str(), true);
		mParsed = true;
	}
}

void RichLabel::setOpacityModifyRGB(bool bValue)
{
}

bool RichLabel::isOpacityModifyRGB(void)
{
	return true;
}

NS_GAME_FRM_END