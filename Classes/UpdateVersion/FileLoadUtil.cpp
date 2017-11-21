#include "FileLoadUtil.h"
#include "StringUtil.h"

NS_GAME_FRM_BEGIN

USING_NS_CC;

FileLoadUtil* FileLoadUtil::mFileLoadUtil = NULL;

FileLoadUtil* FileLoadUtil::sharedFileLoadUtil()
{
	if (mFileLoadUtil==NULL)
	{
		mFileLoadUtil = new FileLoadUtil();
		if (mFileLoadUtil && mFileLoadUtil->init())
		{
			mFileLoadUtil->autorelease();
		}
		else
			CC_SAFE_DELETE(mFileLoadUtil);
	}

	return mFileLoadUtil;
}

bool FileLoadUtil::init()
{
	return true;
}

CCArray* FileLoadUtil::getDataLines(const char* sFilePath)
{
	CCArray* linesList = CCArray::create();

	//��ȡ�ı�����
	unsigned long pSize = 0;
	unsigned char* chDatas = CCFileUtils::sharedFileUtils()->getFileData(sFilePath, "r", &pSize);
	if(!chDatas || pSize == 0)
		return NULL;

	//������ת��Ϊ�ַ�������
	CCString* str = CCString::createWithData(chDatas, pSize);

	linesList = StringUtil::sharedStrUtil()->split(str->getCString(), "\n");

	return linesList;
}

NS_GAME_FRM_END