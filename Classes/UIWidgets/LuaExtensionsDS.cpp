/*
** Lua binding: Cocos2d
** Generated automatically by tolua++-1.0.92 on 02/10/14 14:41:11.
*/

/****************************************************************************
 Copyright (c) 2011 cocos2d-x.org

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

extern "C" {
#include "tolua_fix.h"
}

#include <map>
#include <string>
#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos-ext.h"
#include "string.h"
#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif
#include "Common/CommonDefine.h"


#include "UIWidgets/DSMask.h"
#include "UIWidgets/RichLabel.h"
#include "UIWidgets/GuideLayer.h"
#include "UIWidgets/GraySprite.h"

using namespace cocos2d;
using namespace cocos2d::extension;
using namespace CocosDenshion;
using namespace DianshiTech;


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"CCLayerRGBA");
 tolua_usertype(tolua_S,"CCSize");
 tolua_usertype(tolua_S,"ccColor3B");
 tolua_usertype(tolua_S,"RichLabel");
  tolua_usertype(tolua_S,"GuideLayer");
 tolua_usertype(tolua_S,"DSMask");
 tolua_usertype(tolua_S,"CCSprite");
 tolua_usertype(tolua_S,"CCLayerColor");
  tolua_usertype(tolua_S,"GraySprite");
   tolua_usertype(tolua_S,"DrawCricleMask");
}

/* method: create of class  RichLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_RichLabel_create00
static int tolua_Cocos2d_RichLabel_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"RichLabel",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,5,&tolua_err) || !tolua_isusertype(tolua_S,5,"CCSize",0,&tolua_err)) ||
     !tolua_isboolean(tolua_S,6,1,&tolua_err) ||
     !tolua_isboolean(tolua_S,7,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,8,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const char* str = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* fontName = ((const char*)  tolua_tostring(tolua_S,3,0));
  const int fontSize = ((const int)  tolua_tonumber(tolua_S,4,0));
  CCSize labelSize = *((CCSize*)  tolua_tousertype(tolua_S,5,0));
  bool appendString = ((bool)  tolua_toboolean(tolua_S,6,false));
  bool enableShadow = ((bool)  tolua_toboolean(tolua_S,7,true));
  {
   RichLabel* tolua_ret = (RichLabel*)  RichLabel::create(str,fontName,fontSize,labelSize,appendString,enableShadow);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"RichLabel");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setColor of class  RichLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_RichLabel_setColor00
static int tolua_Cocos2d_RichLabel_setColor00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"RichLabel",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !tolua_isusertype(tolua_S,2,"const ccColor3B",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  RichLabel* self = (RichLabel*)  tolua_tousertype(tolua_S,1,0);
  const ccColor3B* color3 = ((const ccColor3B*)  tolua_tousertype(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setColor'", NULL);
#endif
  {
   self->setColor(*color3);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setColor'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getString of class  RichLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_RichLabel_getString00
static int tolua_Cocos2d_RichLabel_getString00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"RichLabel",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  RichLabel* self = (RichLabel*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getString'", NULL);
#endif
  {
   char* tolua_ret = (char*)  self->getString();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getString'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getTextSize of class  RichLabel */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_RichLabel_getTextSize00
static int tolua_Cocos2d_RichLabel_getTextSize00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"RichLabel",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  RichLabel* self = (RichLabel*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getTextSize'", NULL);
#endif
  {
   CCSize tolua_ret = (CCSize)  self->getTextSize();
   {
#ifdef __cplusplus
    void* tolua_obj = Mtolua_new((CCSize)(tolua_ret));
     tolua_pushusertype(tolua_S,tolua_obj,"CCSize");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
#else
    void* tolua_obj = tolua_copy(tolua_S,(void*)&tolua_ret,sizeof(CCSize));
     tolua_pushusertype(tolua_S,tolua_obj,"CCSize");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
#endif
   }
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getTextSize'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE



/* method: createMask of class  DSMask */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_DSMask_createMask00
static int tolua_Cocos2d_DSMask_createMask00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"DSMask",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !tolua_isusertype(tolua_S,2,"CCSize",0,&tolua_err)) ||
     !tolua_isusertype(tolua_S,3,"CCSprite",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCSize contentSize = *((CCSize*)  tolua_tousertype(tolua_S,2,0));
  CCSprite* bg = ((CCSprite*)  tolua_tousertype(tolua_S,3,0));
  {
   DSMask* tolua_ret = (DSMask*)  DSMask::createMask(contentSize,bg);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"DSMask");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'createMask'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: createMask of class  DSMask */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_DSMask_createMask01
static int tolua_Cocos2d_DSMask_createMask01(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"DSMask",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !tolua_isusertype(tolua_S,2,"CCSize",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  CCSize contentSize = *((CCSize*)  tolua_tousertype(tolua_S,2,0));
  {
   DSMask* tolua_ret = (DSMask*)  DSMask::createMask(contentSize);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"DSMask");
  }
 }
 return 1;
tolua_lerror:
 return tolua_Cocos2d_DSMask_createMask00(tolua_S);
}
#endif //#ifndef TOLUA_DISABLE

/* method: createGuideLayer of class  GuideLayer */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GuideLayer_createGuideLayer00
static int tolua_Cocos2d_GuideLayer_createGuideLayer00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"GuideLayer",0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,2,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		{
			GuideLayer* tolua_ret = (GuideLayer*)  GuideLayer::createGuideLayer();
			tolua_pushusertype(tolua_S,(void*)tolua_ret,"GuideLayer");
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'createGuideLayer'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setMaskRect of class  GuideLayer */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GuideLayer_setMaskRect00
static int tolua_Cocos2d_GuideLayer_setMaskRect00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"GuideLayer",0,&tolua_err) ||
		(tolua_isvaluenil(tolua_S,2,&tolua_err) || !tolua_isusertype(tolua_S,2,"CCRect",0,&tolua_err)) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		GuideLayer* self = (GuideLayer*)  tolua_tousertype(tolua_S,1,0);
		CCRect rect = *((CCRect*)  tolua_tousertype(tolua_S,2,0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setMaskRect'", NULL);
#endif
		{
			self->setMaskRect(rect);
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'setMaskRect'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setMaskPicturePath of class  GuideLayer */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GuideLayer_setMaskPicturePath00
static int tolua_Cocos2d_GuideLayer_setMaskPicturePath00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"GuideLayer",0,&tolua_err) ||
		!tolua_isstring(tolua_S,2,0,&tolua_err) ||
		!tolua_isstring(tolua_S,3,0,&tolua_err) ||
		(tolua_isvaluenil(tolua_S,4,&tolua_err) || !tolua_isusertype(tolua_S,4,"CCPoint",0,&tolua_err)) ||
		!tolua_isnumber(tolua_S,5,0,&tolua_err) ||
		!tolua_isnumber(tolua_S,6,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,7,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		GuideLayer* self = (GuideLayer*)  tolua_tousertype(tolua_S,1,0);
		const char* guideInfo = ((const char*)  tolua_tostring(tolua_S,2,0));
		const char* guideTips = ((const char*)  tolua_tostring(tolua_S,3,0));
		CCPoint poxPoint = *((CCPoint*)  tolua_tousertype(tolua_S,4,0));
		emStandDir dirStand = ((emStandDir) (int)  tolua_tonumber(tolua_S,5,0));
		emPromptDirection dir = ((emPromptDirection) (int)  tolua_tonumber(tolua_S,6,0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setMaskPicturePath'", NULL);
#endif
		{
			self->setMaskPicturePath(guideInfo,guideTips,poxPoint,dirStand,dir);
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'setMaskPicturePath'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: skip of class  GuideLayer */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GuideLayer_skip00
static int tolua_Cocos2d_GuideLayer_skip00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"GuideLayer",0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,2,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		GuideLayer* self = (GuideLayer*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(tolua_S,"invalid 'self' in function 'skip'", NULL);
#endif
		{
			self->skip();
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'skip'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class  GraySprite */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GraySprite_create00
static int tolua_Cocos2d_GraySprite_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"GraySprite",0,&tolua_err) ||
		!tolua_isstring(tolua_S,2,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		const char* pszFileName = ((const char*)  tolua_tostring(tolua_S,2,0));
		{
			GraySprite* tolua_ret = (GraySprite*)  GraySprite::create(pszFileName);
			tolua_pushusertype(tolua_S,(void*)tolua_ret,"GraySprite");
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: createWithSpriteFrameName of class  GraySprite */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GraySprite_createWithSpriteFrameName00
static int tolua_Cocos2d_GraySprite_createWithSpriteFrameName00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"GraySprite",0,&tolua_err) ||
		!tolua_isstring(tolua_S,2,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		const char* pszSpriteFrameName = ((const char*)  tolua_tostring(tolua_S,2,0));
		{
			GraySprite* tolua_ret = (GraySprite*)  GraySprite::createWithSpriteFrameName(pszSpriteFrameName);
			tolua_pushusertype(tolua_S,(void*)tolua_ret,"GraySprite");
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'createWithSpriteFrameName'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: createWithTexture of class  GraySprite */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_GraySprite_createWithTexture00
static int tolua_Cocos2d_GraySprite_createWithTexture00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"GraySprite",0,&tolua_err) ||
		!tolua_isusertype(tolua_S,2,"CCTexture2D",0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		CCTexture2D* pTexture = ((CCTexture2D*)  tolua_tousertype(tolua_S,2,0));
		{
			GraySprite* tolua_ret = (GraySprite*)  GraySprite::createWithTexture(pTexture);
			tolua_pushusertype(tolua_S,(void*)tolua_ret,"GraySprite");
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'createWithTexture'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class  DrawCricleMask */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_DrawCricleMask_create00
static int tolua_Cocos2d_DrawCricleMask_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"DrawCricleMask",0,&tolua_err) ||
		!tolua_isnumber(tolua_S,2,0,&tolua_err) ||
		!tolua_isusertype(tolua_S,3,"CCNode",0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,4,&tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		float fRadius = ((float)  tolua_tonumber(tolua_S,2,0));
		CCNode* node = ((CCNode*)  tolua_tousertype(tolua_S,3,0));
		{
			DrawCricleMask* tolua_ret = (DrawCricleMask*)  DrawCricleMask::create(fRadius,node);
			tolua_pushusertype(tolua_S,(void*)tolua_ret,"DrawCricleMask");
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
	return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


/* Open function */
TOLUA_API int tolua_Cocos2d_open_for_ExtensionsDS (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"RichLabel","RichLabel","CCLayerRGBA",NULL);
  tolua_beginmodule(tolua_S,"RichLabel");
   tolua_function(tolua_S,"create",tolua_Cocos2d_RichLabel_create00);
   tolua_function(tolua_S,"setColor",tolua_Cocos2d_RichLabel_setColor00);
   tolua_function(tolua_S,"getString",tolua_Cocos2d_RichLabel_getString00);
   tolua_function(tolua_S,"getTextSize",tolua_Cocos2d_RichLabel_getTextSize00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"DSMask","DSMask","CCLayerColor",NULL);
  tolua_beginmodule(tolua_S,"DSMask");
   tolua_function(tolua_S,"createMask",tolua_Cocos2d_DSMask_createMask00);
   tolua_function(tolua_S,"createMask",tolua_Cocos2d_DSMask_createMask01);
  tolua_endmodule(tolua_S);
  tolua_constant(tolua_S,"emUpArrow",emUpArrow);
  tolua_constant(tolua_S,"emDownArrow",emDownArrow);
  tolua_constant(tolua_S,"emLeftArrow",emLeftArrow);
  tolua_constant(tolua_S,"emRightArrow",emRightArrow);
  tolua_constant(tolua_S,"emLeft",emLeft);
  tolua_constant(tolua_S,"emRight",emRight);
  tolua_cclass(tolua_S,"GuideLayer","GuideLayer","CCLayer",NULL);
  tolua_beginmodule(tolua_S,"GuideLayer");
  tolua_function(tolua_S,"createGuideLayer",tolua_Cocos2d_GuideLayer_createGuideLayer00);
  tolua_function(tolua_S,"setMaskRect",tolua_Cocos2d_GuideLayer_setMaskRect00);
  tolua_function(tolua_S,"setMaskPicturePath",tolua_Cocos2d_GuideLayer_setMaskPicturePath00);
  tolua_function(tolua_S,"skip",tolua_Cocos2d_GuideLayer_skip00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"GraySprite","GraySprite","CCSprite",NULL);
  tolua_beginmodule(tolua_S,"GraySprite");
  tolua_function(tolua_S,"create",tolua_Cocos2d_GraySprite_create00);
  tolua_function(tolua_S,"createWithSpriteFrameName",tolua_Cocos2d_GraySprite_createWithSpriteFrameName00);
  tolua_function(tolua_S,"createWithTexture",tolua_Cocos2d_GraySprite_createWithTexture00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"DrawCricleMask","DrawCricleMask","CCNode",NULL);
  tolua_beginmodule(tolua_S,"DrawCricleMask");
  tolua_function(tolua_S,"create",tolua_Cocos2d_DrawCricleMask_create00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}



