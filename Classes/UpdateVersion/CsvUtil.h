#ifndef _CsvUtil_
#define _CsvUtil_

#include "cocos2d.h"
#include "FileLoadUtil.h"
#include "Common/CommonDefine.h"

NS_GAME_FRM_BEGIN

class CsvUtil: public cocos2d::CCObject
{
public:
	static CsvUtil* sharedCsvUtil();
	bool init();

	//���������ļ�
	bool loadFile(const char* sPath);
	//�ͷ������ļ�
	void releaseFile(const char* sPath);
	//��ȡĳ��ĳ�е�ֵ
	const char* get(int iRow, int iCol, const char* csvFilePath);
	//��ȡĳ��ĳ�е�ֵ��ת��Ϊ����
	const int getInt(int iRow, int iCol, const char* csvFilePath);
	//��ȡĳ��ĳ�е�ֵ��ת��Ϊ������
	const float getFloat(int iRow, int iCol, const char* csvFilePath);
	//��ȡ�ļ����к�����
	const cocos2d::CCSize getFileRowColNum(const char* csvFilePath);
	//��ȡ�ļ�������
	const int getFileRowNum(const char* csvFilePath);
	//����ĳ���е�ֵ�����Ҹ�ֵ���ڵ���
	const int findValueWithLine(const char* chValue, int iValueCol, const char* csvFilePath);
//private:
	//static CsvUtil* mCsvUtil;
	//���mCsvStrList-filePath���ֵ�
	//CCDictionary* mCsvDict;
};

NS_GAME_FRM_END

#endif