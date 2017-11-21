#ifndef _StringUtil_
#define _StringUtil_

#include "cocos2d.h"
#include "Common/CommonDefine.h"

NS_GAME_FRM_BEGIN

class StringUtil:public cocos2d::CCObject
{
public:
	static StringUtil* sharedStrUtil();
	bool init();

	/**�÷ָ���ָ��ַ���,��������һ���б���,�б��еĶ���ΪCCString*/
    cocos2d::CCArray* split(const char* srcStr, const char* sSep);
private:
	static StringUtil* mStringUtil;
};

NS_GAME_FRM_END

#endif