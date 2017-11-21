#ifndef __GRAY_SPRITE_H__
#define __GRAY_SPRITE_H__

#include "cocos2d.h"
#include "Common/CommonDefine.h"
NS_GAME_FRM_BEGIN
USING_NS_CC;


class GraySprite : public CCSprite
{
public:
	GraySprite(){}
	virtual ~GraySprite(){}
	static GraySprite* create(const char* pszFileName);
	static GraySprite* createWithSpriteFrameName(const char *pszSpriteFrameName);
	static GraySprite* createWithTexture(CCTexture2D *pTexture);
	bool initWithTexture(CCTexture2D* pTexture, const CCRect& tRect);
	bool initWithTexture(CCTexture2D *pTexture);
	virtual void draw();
};

NS_GAME_FRM_END
#endif

