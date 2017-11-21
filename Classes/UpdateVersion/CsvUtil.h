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

	//加载配置文件
	bool loadFile(const char* sPath);
	//释放配置文件
	void releaseFile(const char* sPath);
	//获取某行某列的值
	const char* get(int iRow, int iCol, const char* csvFilePath);
	//获取某行某列的值，转换为整型
	const int getInt(int iRow, int iCol, const char* csvFilePath);
	//获取某行某列的值，转换为浮点型
	const float getFloat(int iRow, int iCol, const char* csvFilePath);
	//获取文件的行和列数
	const cocos2d::CCSize getFileRowColNum(const char* csvFilePath);
	//获取文件的行数
	const int getFileRowNum(const char* csvFilePath);
	//根据某个列的值，查找该值所在的行
	const int findValueWithLine(const char* chValue, int iValueCol, const char* csvFilePath);
//private:
	//static CsvUtil* mCsvUtil;
	//存放mCsvStrList-filePath的字典
	//CCDictionary* mCsvDict;
};

NS_GAME_FRM_END

#endif