
#ifndef CARDATAPARSE_H
#define CARDATAPARSE_H
#include <string>

class DataEncrypt
{
public:
	static DataEncrypt *sharedParser();
	/*
	* 	inBuff , inBufLen ----�����ܵ�ԭʼ������Ϣ
	*	outBuff --���ڴ洢���ܺ������, ��������������outBuff  >= inBuff +16    ,�м�!!!!
	*     outLen -- ���ڱ��淵�صļ������ݳ�����Ϣ.
	*/
	bool byteEncode(unsigned char *inBuff,unsigned int inBufLen, unsigned char *outBuff, unsigned int &outLen);

	/*
	* 	inBuff , inBufLen ----�������ܵ�ԭʼ������Ϣ
	*	outBuff --���ڴ洢���ܺ������, ������outBuff  >= inBuff    
	*     outLen -- ���صĽ��ܺ�����ݳ���.
	*/
	bool byteDecode(unsigned char *inBuff,unsigned int inBufLen, unsigned char *outBuff, unsigned int &outLen);
	
	bool fileEncode(char *fileName);
	bool fileDecode(char *fileName);
	
	void encode(std::string & str);
	void decode(std::string & str);
};
#endif

