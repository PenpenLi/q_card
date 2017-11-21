#ifndef __LABELSTROKE_H__
#define __LABELSTROKE_H__

#include "cocos2d.h"
#include "Common/CommonDefine.h"
NS_GAME_FRM_BEGIN

USING_NS_CC;

class LabelStroke : public CCLabelTTF //public CCNodeRGBA/*, public CCRGBAProtocol*/
{
public:
	LabelStroke() {}
	~LabelStroke() {}

	static LabelStroke * create(const char* string, const char* fontName, const int fontSize, int strokeSize = 1, ccColor3B color = ccc3(0, 0, 0));
	static LabelStroke * create(const char* string, const char* fontName, const int fontSize, const CCSize& dimensions, 
									CCTextAlignment hAlignment = kCCTextAlignmentLeft, int strokeSize = 1, ccColor3B color = ccc3(0, 0, 0));
	
private:
	bool init(const char* string, const char* fontName, const int fontSize, int strokeSize, ccColor3B color);
	bool init(const char* string, const char* fontName, const int fontSize, const CCSize& dimensions, CCTextAlignment hAlignment, int strokeSize, ccColor3B color);

};

NS_GAME_FRM_END
#endif // __LABELSTROKE_H__
