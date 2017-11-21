#include "CCommonFunctionHelp.h"
NS_GAME_FRM_BEGIN
USING_NS_CC;
USING_NS_CC_EXT;
const char* CCCommonFunctionHelp::kCCShaderExt_PositionTextureGrayColor = "kCCShaderExt_PositionTextureGrayColor";

const char * ccPositionTextureGrayColor_vert =  ccPositionTextureColor_vert;
const char * ccPositionTextureGrayColor_frag =
"#ifdef GL_ES\n\
precision mediump float; \n\
#endif\n\
uniform sampler2D CC_Texture0; \n\
varying vec2 v_texCoord; \n\
varying vec4 v_fragmentColor; \n\
void main(void)\n\
{ \n\
vec4 col = texture2D(CC_Texture0, v_texCoord); \n\
float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114)); \n\
gl_FragColor = vec4(grey, grey, grey, col.a); \n\
}";

bool bIsinitShaderGlay = false;
CCGLProgram* CCCommonFunctionHelp::getProgram(char* shardName){
	if (!bIsinitShaderGlay){
		bIsinitShaderGlay = true;
		initShaderGlay();
	}
	return CCShaderCache::sharedShaderCache()->programForKey(shardName);
}
void CCCommonFunctionHelp::initShaderGlay(){
	CCGLProgram *p = CCShaderCache::sharedShaderCache()->programForKey(kCCShaderExt_PositionTextureGrayColor);
	if (p)
		return;

	p = new CCGLProgram();
	p->initWithVertexShaderByteArray(ccPositionTextureGrayColor_vert, ccPositionTextureGrayColor_frag);

	p->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
	p->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
	p->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);

	p->link();
	p->updateUniforms();

	CHECK_GL_ERROR_DEBUG();

	CCShaderCache::sharedShaderCache()->addProgram(p, kCCShaderExt_PositionTextureGrayColor);
	p->release();

	//return p;
}
CCImage* CCCommonFunctionHelp::graylightWithTexture2D(CCTexture2D* tex, bool isLight){
	CCSprite *temporarySprite = CCSprite::createWithTexture(tex);
	return graylightWithCCSprite(temporarySprite, isLight);
}
CCImage* CCCommonFunctionHelp::graylightWithCCSprite(CCSprite* oldSprite, bool isLight)
{
    //CCSprite转成CCimage  
    //CCPoint p = oldSprite->getAnchorPoint();
    //oldSprite->setAnchorPoint(ccp(0, 0));
    CCRenderTexture *outTexture = CCRenderTexture::create((int)oldSprite->getContentSize().width, (int)oldSprite->getContentSize().height);
    outTexture->begin();
    oldSprite->visit();
    outTexture->end();
    //oldSprite->setAnchorPoint(p);

    CCImage* finalImage = outTexture->newCCImage();
    unsigned char *pData = finalImage->getData();
    int iIndex = 0;

    if (isLight)
    {
        for (int i = 0; i < finalImage->getHeight(); i++)
        {
            for (int j = 0; j < finalImage->getWidth(); j++)
            {
                // highlight  
                int iHightlightPlus = 50;
                int iBPos = iIndex;
                unsigned int iB = pData[iIndex];
                iIndex++;
                unsigned int iG = pData[iIndex];
                iIndex++;
                unsigned int iR = pData[iIndex];
                iIndex++;
                //unsigned int o = pData[iIndex];  
                iIndex++;  //原来的示例缺少  
                iB = (iB + iHightlightPlus > 255 ? 255 : iB + iHightlightPlus);
                iG = (iG + iHightlightPlus > 255 ? 255 : iG + iHightlightPlus);
                iR = (iR + iHightlightPlus > 255 ? 255 : iR + iHightlightPlus);
                //            iR = (iR < 0 ? 0 : iR);  
                //            iG = (iG < 0 ? 0 : iG);  
                //            iB = (iB < 0 ? 0 : iB);  
                pData[iBPos] = (unsigned char)iB;
                pData[iBPos + 1] = (unsigned char)iG;
                pData[iBPos + 2] = (unsigned char)iR;
            }
        }
    }else{
        for (int i = 0; i < finalImage->getHeight(); i++)
        {
            for (int j = 0; j < finalImage->getWidth(); j++)
            {
                // gray  
                int iBPos = iIndex;
                unsigned int iB = pData[iIndex];
                iIndex++;
                unsigned int iG = pData[iIndex];
                iIndex++;
                unsigned int iR = pData[iIndex];
                iIndex++;
                //unsigned int o = pData[iIndex];  
                iIndex++; //原来的示例缺少  
                unsigned int iGray = 0.3 * iR + 0.4 * iG + 0.2 * iB;
                pData[iBPos] = pData[iBPos + 1] = pData[iBPos + 2] = (unsigned char)iGray;
            }
        }
	}
	return finalImage;


}

CCScale9Sprite* CCCommonFunctionHelp::createScal9SpriteWithImage(CCImage* image)
{
	CCTexture2D *texture = new CCTexture2D;
	texture->initWithImage(image);

	CCRect rect;
	rect.origin.x = rect.origin.y = 0;
	rect.size = texture->getContentSize();

	CCScale9Sprite* ret = CCScale9Sprite::createWithSpriteFrame(CCSpriteFrame::createWithTexture(texture, rect));
	texture->release();
	return ret;
}
CCSprite* CCCommonFunctionHelp::createSpriteWithImage(CCImage* image)
{
	CCTexture2D *texture = new CCTexture2D;
	texture->initWithImage(image);

	CCRect rect;
	rect.origin.x = rect.origin.y = 0;
	rect.size = texture->getContentSize();

	CCSprite* ret = CCSprite::createWithTexture(texture);
	texture->release();
	return ret;
}

CCScale9Sprite* CCCommonFunctionHelp::graylightScale9SpriteWithTexture2D(CCTexture2D* tex, bool isLight)
{
	CCImage* image = graylightWithTexture2D(tex, isLight);
	return createScal9SpriteWithImage(image);
}
CCSprite* CCCommonFunctionHelp::graylightSpriteWithTexture2D(CCTexture2D* tex, bool isLight)
{
	CCImage* image = graylightWithTexture2D(tex, isLight);
	return createSpriteWithImage(image);
}

namespace CommonFunctionLua
{

}
NS_GAME_FRM_END