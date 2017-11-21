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

	/**用分割符分割字符串,结果存放在一个列表中,列表中的对象为CCString*/
    cocos2d::CCArray* split(const char* srcStr, const char* sSep);
private:
	static StringUtil* mStringUtil;
};

NS_GAME_FRM_END

#endif