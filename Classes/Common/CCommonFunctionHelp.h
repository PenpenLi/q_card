#ifndef __GRAY_SPRITE_H__
#define __GRAY_SPRITE_H__

#include "cocos2d.h"
#include "cocos-ext.h"
#include "Common/CommonDefine.h"

NS_GAME_FRM_BEGIN
USING_NS_CC;
USING_NS_CC_EXT;

class CCCommonFunctionHelp
{
public:
	static const char* kCCShaderExt_PositionTextureGrayColor;

	//static CCTexture2D* ConvertTextureToGray(CCTexture2D*);
	//static CCTexture2D* ConvertTextureToHighlight(CCTexture2D*);

	static CCGLProgram* getProgram(char* shardName);
	static CCImage* graylightWithTexture2D(CCTexture2D* tex, bool isLight);
	static CCImage* graylightWithCCSprite(CCSprite* oldSprite, bool isLight);


	static CCScale9Sprite* createScal9SpriteWithImage(CCImage* image);
	static CCSprite* createSpriteWithImage(CCImage* image);

	static CCScale9Sprite* graylightScale9SpriteWithTexture2D(CCTexture2D* tex, bool isLight);
	static CCSprite* graylightSpriteWithTexture2D(CCTexture2D* tex, bool isLight);
	static void initShaderGlay();
};

NS_GAME_FRM_END
#endif

