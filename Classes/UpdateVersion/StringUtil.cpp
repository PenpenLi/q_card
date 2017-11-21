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

	//���ݷָ���ָ��ַ���������ӵ��б���
	while (endIndex > 0)
	{
		spliStr = CCString::create("");

		//��ȡ�ַ���
		spliStr->m_sString = str->m_sString.substr(startIndex, endIndex);

		//����ַ������б�
		stringList->addObject(spliStr);

		//��ȡʣ�µ��ַ���
		str->m_sString = str->m_sString.substr(endIndex+1, size);

		endIndex = str->m_sString.find(sSep);
		if(endIndex==-1 && str->m_sString != "") //û�ҵ����Ͱ�ʣ��Ķ��ӻ�ȥ
		{
			stringList->addObject(str);
			break;
		}
	}

	return stringList;
}

NS_GAME_FRM_END