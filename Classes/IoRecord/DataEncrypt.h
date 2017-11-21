
#ifndef CARDATAPARSE_H
#define CARDATAPARSE_H
#include <string>

class DataEncrypt
{
public:
	static DataEncrypt *sharedParser();
	/*
	* 	inBuff , inBufLen ----待加密的原始数据信息
	*	outBuff --用于存储加密后的数据, 其容量必须满足outBuff  >= inBuff +16    ,切记!!!!
	*     outLen -- 用于保存返回的加密数据长度信息.
	*/
	bool byteEncode(unsigned char *inBuff,unsigned int inBufLen, unsigned char *outBuff, unsigned int &outLen);

	/*
	* 	inBuff , inBufLen ----待解密密的原始数据信息
	*	outBuff --用于存储解密后的数据, 其容量outBuff  >= inBuff    
	*     outLen -- 返回的解密后的数据长度.
	*/
	bool byteDecode(unsigned char *inBuff,unsigned int inBufLen, unsigned char *outBuff, unsigned int &outLen);
	
	bool fileEncode(char *fileName);
	bool fileDecode(char *fileName);
	
	void encode(std::string & str);
	void decode(std::string & str);
};
#endif

