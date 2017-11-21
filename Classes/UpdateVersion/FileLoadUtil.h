#ifndef _FileLoadUtil_
#define _FileLoadUtil_

#include "cocos2d.h"
#include "StringUtil.h"
#include "Common/CommonDefine.h"

NS_GAME_FRM_BEGIN

class FileLoadUtil:public cocos2d::CCObject
{
public:
	static FileLoadUtil* sharedFileLoadUtil();
	bool init();

	//��ȡ�ļ���ÿһ�е����ݣ����д�ŵ��б���
	cocos2d::CCArray* getDataLines(const char* sFilePath);
private:
	static FileLoadUtil* mFileLoadUtil;
};

NS_GAME_FRM_END
#endif