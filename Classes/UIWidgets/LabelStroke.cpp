
#include "LabelStroke.h"

NS_GAME_FRM_BEGIN

LabelStroke * LabelStroke::create(const char* string, const char* fontName, const int fontSize, int strokeSize, ccColor3B color)
{
	LabelStroke *label = new LabelStroke();
	if (label && label->init(string, fontName, fontSize, strokeSize, color))
	{
		label->autorelease();
		return label;
	}
	CC_SAFE_DELETE(label);
	return NULL;
}

bool LabelStroke::init(const char* string, const char* fontName, const int fontSize, int strokeSize, ccColor3B color)
{
	CCLabelTTF::initWithString(string, fontName, fontSize);
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	enableShadow(CCSizeMake(1.5, -1.5), 0.9, 0.3);
#endif
	return true;
}

LabelStroke * LabelStroke::create(const char* string, const char* fontName, const int fontSize, const CCSize& dimensions, 
							CCTextAlignment hAlignment, int strokeSize, ccColor3B color)
{
	LabelStroke *label = new LabelStroke();
	if (label && label->init(string, fontName, fontSize, dimensions, hAlignment, strokeSize, color))
	{
		label->autorelease();
		return label;
	}
	CC_SAFE_DELETE(label);
	return NULL;
}

bool LabelStroke::init(const char* string, const char* fontName, const int fontSize, const CCSize& dimensions, CCTextAlignment hAlignment, int strokeSize, ccColor3B color)
{
	CCLabelTTF::initWithString(string, fontName, fontSize, dimensions, hAlignment);
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	enableShadow(CCSizeMake(1.5, -1.5), 0.9, 0.3);
#endif
	return true;
}

NS_GAME_FRM_END
