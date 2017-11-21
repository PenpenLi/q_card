#ifndef CCLUAHTTPREQUEST_H_
#define CCLUAHTTPREQUEST_H_

#include <network/HttpClient.h>

USING_NS_CC;
USING_NS_CC_EXT;

class CCLuaHttpRequest: public CCHttpRequest
{
	public:

		CCLuaHttpRequest();

		virtual ~CCLuaHttpRequest();

	public:

		static CCLuaHttpRequest* create();

		static bool mkdirs(std::string aDir);

		/**
		 * 设置一个用于回调的lua函数
		 */
		void setResponseScriptCallback(unsigned int aHandler);

	private:

		/**
		 * 默认的用于c++的回调，由这里统一处理到lua的回调
		 */
		void responseScriptCallback(CCHttpClient* apClient, CCHttpResponse* apResponse);

	private:

		/**
		 * 当前保存的handler
		 */
		unsigned int mHandler;
};

#endif /* CCLUAHTTPREQUEST_H_ */