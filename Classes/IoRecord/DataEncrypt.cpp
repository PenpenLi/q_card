
#include "cocos2d.h"
#include "DataEncrypt.h"
#include "Aes.h"


using namespace std;
USING_NS_CC;


DataEncrypt *pCarDecode = NULL;
DataEncrypt *DataEncrypt::sharedParser()
{
	if (!pCarDecode)
	{
		pCarDecode = new DataEncrypt();
	}

	return pCarDecode;
}


/*
* 	inBuff , inBufLen ----待加密的原始数据信息
*	outBuff --用于存储加密后的数据, 其容量必须满足outBuff  >= inBuff +16    ,切记!!!!
*     outLen -- 用于保存返回的加密数据长度信息.
*/
bool DataEncrypt::byteEncode(unsigned char *inBuff,unsigned int inBufLen, unsigned char *outBuff, unsigned int &outLen)
{
	unsigned char *ptrIn = inBuff;
	unsigned char *ptrOut = outBuff;
	unsigned char tmpIn[16];
	
	Aes aes(24,(unsigned char*)"\x10\x11\x12\x13\x14\x15\x16\x17\x0\x1\x2\x3\x4\x5\x6\x7\x8\x9\xa\xb\xc\xd\xe\xf");


	unsigned int blocknum = inBufLen/16;
	unsigned int leftnum = inBufLen%16;


	for(unsigned int i=0;i<blocknum;i++)
	{
		aes.Cipher(ptrIn,ptrOut);
		ptrIn += 16;
		ptrOut += 16;
	}
	
	if(leftnum)
	{
		
		memset(tmpIn,0,16);
		memcpy(tmpIn, ptrIn, leftnum);
		for (int i=leftnum; i < 16; i++) //不足16 字节的在后面插入数据16-leftnum
		{
			tmpIn[i] = 16 - leftnum;
		}
		aes.Cipher(tmpIn, ptrOut);
	}
	else /*数据正好是16 的倍数，则在后面添加16个字节，内容为16*/
	{
		memset(tmpIn,16,16);
		aes.Cipher(tmpIn, ptrOut);
	}
	
	outLen = inBufLen + 16 - leftnum;

	//CCLog("encode: inLen=%d, outLen=%d", inBufLen, outLen);

	return true;
}

/*
* 	inBuff , inBufLen ----待解密密的原始数据信息
*	outBuff --用于存储解密后的数据, 其容量outBuff  >= inBuff    
*     outLen -- 返回的解密后的数据长度.
*/
bool DataEncrypt::byteDecode(unsigned char *inBuff,unsigned int inBufLen, unsigned char *outBuff, unsigned int &outLen)
{
	unsigned char *ptrIn = inBuff;
	unsigned char *ptrOut = outBuff;

	Aes aes(24,(unsigned char*)"\x10\x11\x12\x13\x14\x15\x16\x17\x0\x1\x2\x3\x4\x5\x6\x7\x8\x9\xa\xb\xc\xd\xe\xf");

	unsigned int blocknum = (inBufLen)/16;
	unsigned int leftnum = (inBufLen)%16;

	if (leftnum > 0)
	{
		CCLog("DataEncrypt: decode: data error !!!!! filelen=%d", inBufLen);
		outLen = 0;
		return false;
	}

	if(blocknum > 1)
	{
		for(unsigned int i=0; i < blocknum-1; i++)
		{
			
			aes.InvCipher(ptrIn,ptrOut);
			ptrIn += 16;
			ptrOut += 16;
		}
	}
	outLen = inBufLen;
	//对最后一个数据包解密后进行解析, 如最后一个字节为16,  直接丢弃, 如果为n < 16, 则返回16-n 个数据
	unsigned char tmpOut[16] = {0};
	aes.InvCipher(ptrIn,tmpOut);
	unsigned int extraNum = tmpOut[15];
	if (extraNum < 16)
	{
		memcpy(ptrOut, tmpOut,  16 - extraNum);
		outLen -= extraNum;
	}
	else
	{
		outLen -= 16;
	}
	//CCLog("decode: inLen=%d, outLen=%d", inBufLen, outLen);
	return true;
	
}


/*
* fileName: 待加密的文件全路径名
*/
bool DataEncrypt::fileEncode(char *fileName)
{
	FILE* finput;
	FILE* foutput;
	char outName[256] = {0};
	unsigned int lFileLen;
	unsigned int blocknum;
	unsigned int leftnum;
	//Aes aes(16,(unsigned char*)"\x0\x1\x2\x3\x4\x5\x6\x7\x8\x9\xa\xb\xc\xd\xe\xf");


	finput = fopen(fileName,"rb");
	if (!finput)
	{
		CCLog("open %s  error !", fileName);
		return false;
	}
	
	fseek(finput,0,SEEK_END);
	lFileLen = ftell(finput);
	fseek(finput,0,SEEK_SET);
	blocknum = lFileLen/16;
	leftnum = lFileLen%16;


	unsigned char *inBuf = (unsigned char *)malloc(lFileLen*2+32);
	memset(inBuf, 0, lFileLen*2+32);
	unsigned char *outBuf = inBuf + lFileLen;
	unsigned int outLen = 0;
	
	fread(inBuf,1,lFileLen, finput);
	fclose(finput);
	
	sprintf(outName, "%s%s",fileName, ".en");
	foutput = fopen(outName,"wb");
	if(!foutput)
	{
		free(inBuf);
		CCLog("open output file name:  %s  error !", outName);
		return false;
	}
	
	if(byteEncode(inBuf, lFileLen, outBuf, outLen))
	{
		fwrite(outBuf,1,outLen,foutput);
	}
	else
	{
		free(inBuf);
		fclose(foutput);
		return false;
	}
	
	free(inBuf);
	fclose(foutput);

	return true;
}

/*
* fileName: 待解密的文件全路径名
*/
bool DataEncrypt::fileDecode(char *fileName)
{
	FILE* finput;
	FILE* foutput;
	char outName[256] = {0};
	unsigned int lFileLen;
	unsigned int blocknum;
	unsigned int leftnum;
	//Aes aes(16,(unsigned char*)"\x0\x1\x2\x3\x4\x5\x6\x7\x8\x9\xa\xb\xc\xd\xe\xf");


	finput = fopen(fileName,"rb");
	if (!finput)
	{
		CCLog("open %s  error !", fileName);
		return false;
	}
	
	fseek(finput,0,SEEK_END);
	lFileLen = ftell(finput);
	fseek(finput,0,SEEK_SET);
	blocknum = lFileLen/16;
	leftnum = lFileLen%16;

	unsigned char *inBuf = (unsigned char *)malloc(lFileLen*2);
	memset(inBuf, 0, lFileLen*2);
	unsigned char *outBuf = inBuf + lFileLen;
	unsigned int outLen = 0;
	
	fread(inBuf,1,lFileLen, finput);
	fclose(finput);

	sprintf(outName, "%s",fileName);
	int nameLen = strlen(outName);
	if ( nameLen > 3 && outName[nameLen-3] == '.')
	{
		outName[nameLen-3] = '\0';
	}

	foutput = fopen(outName,"wb");
	if(!foutput)
	{
		free(inBuf);
		CCLog("open output file name:  %s  error !", outName);
		return false;
	}
	
	if(byteDecode(inBuf, lFileLen, outBuf, outLen))
	{
		fwrite(outBuf,1,outLen,foutput);
	}
	else
	{
		free(inBuf);
		fclose(foutput);
		return false;
	}
	
	free(inBuf);
	fclose(foutput);

	return true;
}



//othe encrypt method
void DataEncrypt::encode(std::string &str)
{
	for (unsigned int i = 0; i < str.length(); i++)
	{
		unsigned char ch = str[i];
		ch = 0xff & (((ch & (1<<7)) >> 7) | (ch << 1)); 
		ch = ((ch & 0xf0)>>4) | ((ch & 0x0f)<<4)	;
                
		str[i] = ch;
	}
}

void DataEncrypt::decode(std::string &str)
{
	for (unsigned int i = 0; i < str.length(); i++)
	{
		unsigned char ch = str[i];
		ch = ((ch & 0xf0)>>4) | ((ch & 0x0f)<<4);
		ch = 0xff & ((( ch & (1)) << 7) | (ch >> 1));
		str[i] = ch;
	}
}



/*						  
void encryTest(void)
{
	
	unsigned char srcbuf[] = "0123456789abcdef0123456789abcde";
	unsigned char out1[128] = {0};
	unsigned char out2[128] = {0};
	unsigned int len = sizeof(srcbuf);
	unsigned int outLen = 0;
	unsigned int outLen2 = 0;

	string str = "hlbchen";
	str = str.substr(0, 3);
	
	DataEncrypt::sharedParser()->byteEncode(srcbuf, len, out1, outLen);
	CCLog("encode:----outLen=%d", outLen);
	for (int i=0;i<outLen;i++)
	{
		CCLog("%c", out1[i]);

	}

	DataEncrypt::sharedParser()->byteDecode(out1, outLen, out2, outLen2);
	CCLog("decode: ----outLen2 = %d", outLen2);
	for (int i=0;i<outLen2;i++)
	{
		CCLog("%c", out2[i]);
	}
	
	//DataEncrypt::sharedParser()->byteEncode(mystr.c_str(), mystr.length(), out1, outLen);

	DataEncrypt::sharedParser()->fileEncode("hlb.cpp");
	DataEncrypt::sharedParser()->fileDecode("hlb.cpp.en");
}
*/

