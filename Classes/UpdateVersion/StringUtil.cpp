#include "StringUtil.h"

NS_GAME_FRM_BEGIN

USING_NS_CC;

StringUtil* StringUtil::mStringUtil = NULL;

StringUtil* StringUtil::sharedStrUtil()
{
	if (mStringUtil==NULL)
	{
		mStringUtil = new StringUtil();
		if (mStringUtil && mStringUtil->init())
		{
			mStringUtil->autorelease();
		}
		else
		{
			CC_SAFE_DELETE(mStringUtil);
		}
	}
	return mStringUtil;
}

bool StringUtil::init()
{
	return true;
}

CCArray* StringUtil::split(const char* srcStr, const char* sSep)
{
	CCArray* stringList = CCArray::create();

	int size = strlen(srcStr);

	CCString* str = CCString::create(srcStr);

	int startIndex = 0;
	int endIndex = 0;
	endIndex = str->m_sString.find(sSep);

	CCString *spliStr = NULL;

	//根据分割符分割字符串，并添加到列表中
	while (endIndex > 0)
	{
		spliStr = CCString::create("");

		//截取字符串
		spliStr->m_sString = str->m_sString.substr(startIndex, endIndex);

		//添加字符串到列表
		stringList->addObject(spliStr);

		//截取剩下的字符串
		str->m_sString = str->m_sString.substr(endIndex+1, size);

		endIndex = str->m_sString.find(sSep);
		if(endIndex==-1 && str->m_sString != "") //没找到，就把剩余的都加回去
		{
			stringList->addObject(str);
			break;
		}
	}

	return stringList;
}

NS_GAME_FRM_END