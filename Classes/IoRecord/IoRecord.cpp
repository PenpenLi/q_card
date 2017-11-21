#include "IoRecord.h"
#include "DataEncrypt.h"
#ifdef FILE_SAVED_AS_JSON
#include "cocos-ext.h"
USING_NS_CC_EXT;
using namespace CSJson;
#endif

using namespace std;
USING_NS_CC;

IoRecord *pRecord = NULL;
IoRecord *IoRecord::sharedRecord()
{
    if (!pRecord)
    {
        pRecord = new IoRecord();
    }
    return pRecord;
}

#ifdef FILE_SAVED_AS_JSON
static Value getJsonFromFile()
{
    Value root;
    char *pFileContent = NULL;
    unsigned int contentlen = 0;
    unsigned long size = 0;
    std::string fullPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(JSON_FILE_NAME);
    const char *pStr = (char *)CCFileUtils::sharedFileUtils()->getFileData(fullPath.c_str() , "rb", &size);
    
    if (pStr && size > 0)
    {
        pFileContent = (char *)malloc(size);
        bool ret = DataEncrypt::sharedParser()->byteDecode((unsigned char *)pStr,  size, (unsigned char *)pFileContent, contentlen); 
        
        if(!ret)
        {
            CCLog("IoRecord:  decrypt error !!!");
            free(pFileContent);
            CC_SAFE_DELETE_ARRAY(pStr); 
            return root;
        }
    }
    CC_SAFE_DELETE_ARRAY(pStr); 
    
    CSJson::Reader reader;
    std::string jsonfile;
    if(pFileContent)
    {
        jsonfile.assign(pFileContent, size);
        free(pFileContent);
        
        if (!reader.parse(jsonfile, root, false ))
        {
            CCLog("parse CSJson file error !!!");
        }
    }

    return root;
}

static void SaveToJsonFile(CSJson::Value &root)
{
    FastWriter wr;
    std::string str = wr.write(root);
    
    if (str.length() <= 0) return;
    
    //encrypt 
    char *pOutStr = (char *)malloc(str.length()+20);
    unsigned int outLen = 0;
    bool ret = DataEncrypt::sharedParser()->byteEncode((unsigned char *)str.c_str(), str.length()+1, (unsigned char *)pOutStr, outLen);     
    if (!ret)
    {
        CCLog("IoRecord: encrypt error !!!");
        free(pOutStr);
        return;
    }
    //save to file
    std::string fullPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(JSON_FILE_NAME);
    FILE *fp = fopen(fullPath.c_str(), "wb");
    if (fp < 0)
    {
        CCLog("open file : %s  error !", JSON_FILE_NAME);
        return;
    }
    fwrite(pOutStr,1,outLen, fp);
    fclose(fp);
    free(pOutStr);
}
#endif

void IoRecord::setBoolForKey(int key, bool val)
{
    char keyBuf[32] = {0};
    char valBuf[32] = {0};

    if (val){
    	sprintf(valBuf, "%s", "true"); 
    }
    else{
    	sprintf(valBuf, "%s", "false"); 
    }
    sprintf(keyBuf, "%s%d", "IoRecord", key); 
#ifdef FILE_SAVED_AS_JSON
    CSJson::Value root = getJsonFromFile();
    root[keyBuf] = Value(val);
    SaveToJsonFile(root);
#else
    std::string value = string(valBuf);
    DataEncrypt::sharedParser()->encode(value);
    CCUserDefault::sharedUserDefault()->setStringForKey(keyBuf, value);
#endif
}

void IoRecord::setIntegerForKey(int key, int val)
{
    char keyBuf[32] = {0};
    char valBuf[32] = {0};

    sprintf(keyBuf, "%s%d", "IoRecord", key); 
    sprintf(valBuf, "%d", val); 
    std::string value = string(valBuf);
#ifdef FILE_SAVED_AS_JSON
    CSJson::Value root = getJsonFromFile();
    root[keyBuf] = Value(val);
    SaveToJsonFile(root);
#else    
    DataEncrypt::sharedParser()->encode(value);
    CCUserDefault::sharedUserDefault()->setStringForKey(keyBuf, value);
#endif    
}	

void IoRecord::setFloatForKey(int key, float val)
{
    char keyBuf[32] = {0};
    char valBuf[32] = {0};

    sprintf(keyBuf, "%s%d", "IoRecord", key);
#ifdef FILE_SAVED_AS_JSON
    CSJson::Value root = getJsonFromFile();
    root[keyBuf] = Value(val);
    SaveToJsonFile(root);
#else   	
    sprintf(valBuf, "%f", val);
    std::string value = string(valBuf);
    DataEncrypt::sharedParser()->encode(value);
    CCUserDefault::sharedUserDefault()->setStringForKey(keyBuf, value);
#endif    
}

void IoRecord::setStringForKey(int key, const std::string &val)
{
    char keyBuf[32] = {0};
    string valBuf = string(val);

    sprintf(keyBuf, "%s%d", "IoRecord", key); 
#ifdef FILE_SAVED_AS_JSON
    CSJson::Value root = getJsonFromFile();
    root[keyBuf] = Value(val);
    SaveToJsonFile(root);
#else       
    DataEncrypt::sharedParser()->encode(valBuf);
    CCUserDefault::sharedUserDefault()->setStringForKey(keyBuf, valBuf);
#endif    
}

bool IoRecord::getBoolForKey(int key)
{
    char keyBuf[32] = {0};

    sprintf(keyBuf, "%s%d", "IoRecord", key); 
#ifdef FILE_SAVED_AS_JSON
    CSJson::Value root = getJsonFromFile();
    return root[keyBuf].asBool();
#else    
    string str = CCUserDefault::sharedUserDefault()->getStringForKey(keyBuf);
    DataEncrypt::sharedParser()->decode(str);
    if (strcmp(str.c_str(), "true") == 0)
    {
    	return true;
    }
    return false;
#endif       
}

int IoRecord::getIntegerForKey(int key)
{
    char keyBuf[32] = {0};

    sprintf(keyBuf, "%s%d", "IoRecord", key); 
#ifdef FILE_SAVED_AS_JSON
    CSJson::Value root = getJsonFromFile();
    return root[keyBuf].asInt();
#else    
    string str = CCUserDefault::sharedUserDefault()->getStringForKey(keyBuf);
    DataEncrypt::sharedParser()->decode(str);
    return atoi(str.c_str());
#endif    
}

float IoRecord::getFloatForKey(int key)
{
    char keyBuf[32] = {0};

    sprintf(keyBuf, "%s%d", "IoRecord", key); 
#ifdef FILE_SAVED_AS_JSON
    CSJson::Value root = getJsonFromFile();
    return root[keyBuf].asFloat();
#else  
    string str = CCUserDefault::sharedUserDefault()->getStringForKey(keyBuf);
    DataEncrypt::sharedParser()->decode(str);
    return atof(str.c_str());
#endif    
}

std::string IoRecord::getStringForKey(int key)
{
    char keyBuf[32] = {0};

    sprintf(keyBuf, "%s%d", "IoRecord", key); 
#ifdef FILE_SAVED_AS_JSON
    CSJson::Value root = getJsonFromFile();
    return root[keyBuf].asString();
#else  
    string str = CCUserDefault::sharedUserDefault()->getStringForKey(keyBuf);
    DataEncrypt::sharedParser()->decode(str);
    return str;
#endif    
}


