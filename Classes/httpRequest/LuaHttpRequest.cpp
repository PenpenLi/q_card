#include "LuaHttpRequest.h"
#include "CCLuaEngine.h"
#include <sys/types.h>
#include <errno.h>
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <dirent.h>
#include <sys/stat.h>
#else
#include <direct.h>
#endif

CCLuaHttpRequest::CCLuaHttpRequest() :
		mHandler(0)
{
	
}

CCLuaHttpRequest::~CCLuaHttpRequest()
{
}

CCLuaHttpRequest* CCLuaHttpRequest::create()
{
	return new CCLuaHttpRequest;
}

bool CCLuaHttpRequest::mkdirs(std::string aDir)
{
	if (aDir.size() == 0)
	{
		return true;
	}

	CCLOG("creating dir:%s", aDir.c_str());
	bool isFirst = aDir[0] == '/';
	bool isLast = false;
	for (unsigned int i = 1; i < aDir.size(); i++)
	{
		if (aDir[i] == '/')
		{
			if (isLast)
			{
				continue;
			}
			isLast = true;

			if (isFirst)
			{
				isFirst = false;
				continue;
			}

			std::string path = aDir.substr(0, i);
			if (CCFileUtils::sharedFileUtils()->isFileExist(path.c_str()))
			{
				CCLOG("path:%s exist", path.c_str());
				continue;
			}

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
      int ret = mkdir(path.c_str(),0700);
      if (ret && (errno != EEXIST))
      {
        CCLOG("mkdir:%s failed", path.c_str());
        return false;
      }
#else
      int ret = _mkdir(path.c_str());
      if (ret == 0)
      {
        CCLOG("mkdir:%s failed", path.c_str());
        return false;
      }
#endif

			/*int ret = mkdir(path.c_str(),0700);
			if (ret && errno != EEXIST)
			{
				CCLOG("mkdir:%s failed", path.c_str());
				return false;
			}
			else
			{
				CCLOG("path:%s created", path.c_str());
			}*/
		}
		else
		{
			isLast = false;
		}
	}
	return true;
}

void CCLuaHttpRequest::setResponseScriptCallback(unsigned int aHandler)
{
	mHandler = aHandler;
	setResponseCallback(this, httpresponse_selector(CCLuaHttpRequest::responseScriptCallback));
}

void CCLuaHttpRequest::responseScriptCallback(CCHttpClient* apClient, CCHttpResponse* apResponse)
{
	CCLuaEngine* pEngine =
			dynamic_cast<CCLuaEngine*>(CCScriptEngineManager::sharedManager()->getScriptEngine());
	CCLuaStack* pStack = pEngine->getLuaStack();
	bool isSucceed = apResponse->isSucceed();
	int status = apResponse->getResponseCode();
	const char* errorBuffer = apResponse->getErrorBuffer();
	std::vector<char>* headerBuffer = apResponse->getResponseHeader();
	std::vector<char>* bodyBuffer = apResponse->getResponseData();
	std::string header(headerBuffer->begin(), headerBuffer->end());
	std::string body(bodyBuffer->begin(), bodyBuffer->end());
	pStack->pushCCObject(apResponse->getHttpRequest(), "CCHttpRequest");
	pStack->pushBoolean(isSucceed); //是否成功
	pStack->pushString(body.c_str(), body.size()); //body
	pStack->pushString(header.c_str()); //header
	pStack->pushInt(status); //状态码
	pStack->pushString(errorBuffer); //错误描述
	pStack->executeFunctionByHandler(mHandler, 6);
	pStack->clean();
}