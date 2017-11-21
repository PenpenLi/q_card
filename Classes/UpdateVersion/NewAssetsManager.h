#ifndef __NewAssetsManager__
#define __NewAssetsManager__

#include <string>
#include <curl/curl.h>
#include <pthread.h>
#include <iostream>
#include <fstream>

#include "cocos2d.h"
#include "ExtensionMacros.h"
#include "Common/CommonDefine.h"

NS_GAME_FRM_BEGIN

class NewAssetsManagerDelegateProtocol;
class NetUpdateLayer;

enum checkVersionType
{
	eNoNewVersion,
	eNewVersion,
	eNewMajorVersion,
    eNetWorkError,
};
#define ASSETSMANAGER_MESSAGE_UPDATE_SUCCEED                0     // ���³ɹ�
#define ASSETSMANAGER_MESSAGE_RECORD_DOWNLOADED_VERSION		1     // ��¼����˵İ汾��
#define ASSETSMANAGER_MESSAGE_PROGRESS                      2     // ��ʾ����
#define ASSETSMANAGER_MESSAGE_ERROR							3     // error
#define ASSETSMANAGER_MESSAGE_DOWNLOAD_SERVERLIST		    4     // �����ļ��б��ļ�
#define ASSETSMANAGER_MESSAGE_NEW_VERSION                   5     // ���°汾
#define ASSETSMANAGER_MESSAGE_PREPARE_DOWNLOAD_SERVER_LIST  6
class NewAssetsManager
{
public:
    enum
    {
        // Error caused by creating a file to store downloaded data
        kCreateFile,
        /** Error caused by network
         -- network unavaivable
         -- timeout
         -- ...
         */
        kNetwork,
        /** There is not a new version
         */
        kNoNewVersion,
        /** Error caused in uncompressing stage
         -- can not open zip file
         -- can not read file global information
         -- can not read file information
         -- can not create a directory
         -- ...
         */
        kUncompress,

		/** There is a new version
         */
		kNewVersion,

		kDownLoadFinished,

		kDownloadServerList,
    };

	//���غ��ļ��Ĵ洢λ�ú�Ҫ���صķ����������ļ��б�
    NewAssetsManager(const char* serverListPath, const char* storagePath);
	
	NewAssetsManager(const char* serverListPath, const char* versionFileUrl, const char* storagePath);
    
    virtual ~NewAssetsManager();

	void sendErrorMessage(int what,int code);
	
	void downLoadServerUpdateList();

	bool downLoadSingleFile(std::string fileUrl, std::string storePath,long *httpCode);
	
	bool uncompress(std::string filename);

	bool createDirectory(const char *path);
	void setSearchPath();
	void setDelegate(NewAssetsManagerDelegateProtocol *delegate);
	void setConnectionTimeout(unsigned int timeout);
	void deleteVersion();
	
	std::string getNewVersionCode(){return _version;}

	bool checkDownLoadFinished() {return m_bIsDownLoadFinished; }; //�ж������Ƿ����

	void downLoadResource(std::vector<std::string>vFileurl,std::vector<std::string> StorgePath); //������Դ
	
	void downLoadResource();
    
	CC_SYNTHESIZE(int,m_nDownLoadFileNum,DownLoadFileNum);
	
	CC_SYNTHESIZE(int,m_nDownLoadSize,DownLoadSize);				// ��Ҫ�����ļ����ܴ�С
	
	CC_SYNTHESIZE(double,mLastDownloadedSize,LastDownloadedSize);	// ��¼�����ص��ļ���С

	CC_SYNTHESIZE(double,mDownloadedTotalSize,DownloadedTotalSize);	// ��¼��������

	

	/* @brief Check out if there is a new version resource.
     *        You may use this method before updating, then let user determine whether
     *        he wants to update resources.
     */
    virtual checkVersionType checkUpdate();

    /* @brief Download new package if there is a new version, and uncompress downloaded zip file.
     *        Ofcourse it will set search path that stores downloaded files.
     */
    virtual void update();

	std::string _storagePath;	//��ȡ���ش洢·��
	std::string _serverListUrl; //������Ҫ���µ��ļ��б�
	std::string _fileName;		//��ǰ�������ļ���

	typedef struct _Message
	{
	public:
		_Message() : what(0), obj(NULL){}
		unsigned int what; // message type
		void* obj;
	} Message;

	class Helper : public cocos2d::CCObject
	{
	public:
		Helper();
		~Helper();

		virtual void update(float dt);
		void sendMessage(Message *msg);
		void stopTimer();

	private:
		void handleUpdateSucceed(Message *msg);

		std::list<Message*> *_messageQueue;
		pthread_mutex_t _messageQueueMutex;
	};
	Helper *_schedule;

	pthread_t *_tid;
	
	std::vector<std::string> m_vNeed2DownLoadFileUrl;
	
	std::vector<std::string> m_vNeed2DownLoadFileStorgePath;
	
	bool m_bIsDownLoadFinished;
    
	bool versionIsDownLoading;
	
	bool serverListIsDownLoading;
	
	bool resourceIsDownLoading;
    

private:

	//�����ļ�
	void makeDirOrFile(std::string dirPath);
	void checkStoragePath();

	//! The version of downloaded resources.
	std::string _version;	
	std::string _versionFileUrl;
	std::string _downloadedVersion;

	CURL *_curl;
	
	unsigned int _connectionTimeout;

	NewAssetsManagerDelegateProtocol *_delegate; // weak reference

	bool verCompare(std::string recordVersion,std::string serverVersion,bool &isMajorVersionUpdate);
};

class NewAssetsManagerDelegateProtocol
{
public:
    /* @brief Call back function for error
       @param errorCode Type of error
     */
    virtual void onError(int errorCode) {};
    /** @brief Call back function for recording downloading percent
        @param percent How much percent downloaded
        @warn This call back function just for recording downloading percent.
              AssetsManager will do some other thing after downloading, you should
              write code in onSuccess() after downloading. 
     */
    virtual void onProgress(int percent) {};
    /** @brief Call back function for success
     */
    virtual void onSuccess(int errorCode) {};

	
	virtual void onServerListDownLoadSuccess() {};
	
	virtual void onReconnectionDownloadVersion(){};

	virtual void onReconnectionDownloadResource(){};

	virtual void prepareToDownloadServerList(){};
};
struct NormalMessage
{
	int code;
	NewAssetsManager* manager;
};

struct ProgressMessage
{
	int percent;
	NewAssetsManager* manager;
};
NS_GAME_FRM_END;

#endif 
