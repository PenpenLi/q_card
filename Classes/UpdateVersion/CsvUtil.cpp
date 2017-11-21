#include "CsvUtil.h"
#include <stdlib.h>

NS_GAME_FRM_BEGIN

USING_NS_CC;

static CsvUtil *mCsvUtil = NULL;
static CCDictionary* mCsvDict = NULL;

CsvUtil* CsvUtil::sharedCsvUtil()
{
	if (mCsvUtil==NULL)
	{
		mCsvUtil = new CsvUtil();
		if (mCsvUtil && mCsvUtil->init())
		{
			mCsvUtil->autorelease();
		}
		else
		{
			CC_SAFE_DELETE(mCsvUtil);
			mCsvUtil = NULL;
		}
	}

	return mCsvUtil;
}

bool CsvUtil::init()
{
	
	mCsvDict = CCDictionary::create();
	mCsvDict->retain();

	return true;
}

bool CsvUtil::loadFile(const char* sPath)
{
	//���һ��csv�ַ����б�
	CCArray* csvStrList = CCArray::create();

	CCArray* lineList = FileLoadUtil::sharedFileLoadUtil()->getDataLines(sPath);
	if(!lineList) //����ļ������ڣ�����false
		return false;

	CCObject* obj;
	CCString* tString = NULL;
	CCARRAY_FOREACH(lineList, obj)
	{
		tString = (CCString*)obj;

		if (tString)
		{
			//��һ���ַ�����Ϣ�����ŷָȻ����ڱ���
			CCArray* tArr = StringUtil::sharedStrUtil()->split(tString->getCString(), ",");
			csvStrList->addObject(tArr);
		}
	}
	//����б��ֵ���
	mCsvDict->setObject(csvStrList, sPath); 
	return true;
}

const CCSize CsvUtil::getFileRowColNum(const char* csvFilePath)
{
	CCSize size = CCSize(CCSizeZero);
	CCArray* csvStrList = (CCArray*)mCsvDict->objectForKey(csvFilePath);

	//����
	if (csvStrList)
	{
		int iRowNum = csvStrList->count();
		int iColNum = 0;

		if(iRowNum==0)
			return CCSize(0,0);

		//��ȡ��0������
		CCObject* rowObj = csvStrList->objectAtIndex(0);
		CCArray* rowArr = (CCArray *)rowObj;

		//��������
		iColNum = rowArr->count();

		size = CCSize(iRowNum, iColNum);	
	}

	return size;
}

const int CsvUtil::getFileRowNum(const char* csvFilePath)
{
	CCSize csvSize = getFileRowColNum(csvFilePath);
	int row = csvSize.width;
	return row;
}

const char* CsvUtil::get(int iRow, int iCol, const char* csvFilePath)
{
	//ȡ�������ļ��Ķ�ά���
	CCArray* csvStrList = (CCArray *)mCsvDict->objectForKey(csvFilePath);

	CCSize size = getFileRowColNum(csvFilePath);

	int iRowNum = size.width;
	int iColNum = size.height;

	//��ȡ��iRow������
	CCArray* rowArr = (CCArray*)csvStrList->objectAtIndex(iRow);
	
	//��ȡ��iCol������
	CCString* colStr = (CCString *)rowArr->objectAtIndex(iCol);
	return colStr->getCString();
}

const float CsvUtil::getFloat(int iRow, int iCol, const char* csvFilePath)
{
	const char* str = get(iRow, iCol, csvFilePath);
	float result = atof(str);
	return result;
}

const int CsvUtil::getInt(int iRow, int iCol, const char* csvFilePath)
{
	const char* str = get(iRow, iCol, csvFilePath);
	int result = atoi(str);
	return result;
}

const int CsvUtil::findValueWithLine(const char* chValue, int iValueCol, const char* csvFilePath)
{
	CCSize csvSize = getFileRowColNum(csvFilePath);

	int iLine = -1;
	for (int i=0; i<csvSize.width; i++)
	{
		const char* ID = get(i, iValueCol, csvFilePath);
		CCString* IDStr = CCString::createWithFormat(ID,"");
		if(IDStr->m_sString.compare(chValue)==0)
		{
			iLine = i;
			break;
		}
	}
	return iLine;
}

void CsvUtil::releaseFile(const char* sPath)
{
	mCsvDict->removeObjectForKey(sPath);
}


NS_GAME_FRM_END

