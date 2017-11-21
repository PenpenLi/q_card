#include "cocos2d.h"
#include <curl/curl.h>
#include <curl/easy.h>
#include "support/zip_support/unzip.h"
#include "json_lib.h"
#include <stdio.h>
#include <vector>

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <dirent.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <stdlib.h>
#else
#include <direct.h>
#endif

#include "StringUtil.h"
#include "NewAssetsManager.h"
#include "NetUpdateLayer.h"

NS_GAME_FRM_BEGIN

using namespace cocos2d;

using namespace std;

#define KEY_OF_VERSION               "current-version-code"

#define KEY_OF_DOWNLOADED_VERSION    "downloaded-version-code"

#define TEMP_PACKAGE_FILE_NAME       "cocos2dx-update-temp-package.zip"

#define BUFFER_SIZE    8192

#define MAX_FILENAME   512

#define LOW_SPEED_LIMIT     1L

#define LOW_SPEED_TIME      5L

// 下载服务器列表文件
void* serverListDownload(void *data);

// 下载资源文件
void* resourceFileDown(void *data);

// 下载过程保存下载文件
static size_t downLoadPackage(void *ptr, size_t size, size_t nmemb, void *userdata);

// 下载过程处理进度条数据用于显示
int assetsNewManagerProgressFunc(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded);


void NewAssetsManager::checkStoragePath()
{
	if (_storagePath.size() > 0 && _storagePath[_storagePath.size() - 1] != '/' && _storagePath[_storagePath.size() - 1] != '\\')
	{
		_storagePath.append("\\");
	}
}

NewAssetsManager::NewAssetsManager(const char* serverListPath, const char* storagePath)
{
	_storagePath = storagePath;
	_serverListUrl = serverListPath;
	_version = "";
	_fileName = "";
	_downloadedVersion = "";
	_curl = NULL;
	_tid = NULL;
	_delegate = NULL;
	_connectionTimeout = 0;
	checkStoragePath();
	_schedule = new Helper();
	m_bIsDownLoadFinished = false;
	m_nDownLoadFileNum = 0;
	mLastDownloadedSize= 0;
	versionIsDownLoading= false;
	serverListIsDownLoading= false;
	resourceIsDownLoading= false;
	mDownloadedTotalSize=0.0f;
}

NewAssetsManager::NewAssetsManager(const char* serverListPath, const char* versionFileUrl, const char* storagePath)
	:  _storagePath(storagePath)
	, _version("")
	,_serverListUrl(serverListPath)
	,_fileName("")
	, _versionFileUrl(versionFileUrl)
	, _downloadedVersion("")
	, _curl(NULL)
	, _tid(NULL)
	, _connectionTimeout(0)
	, _delegate(NULL)
	,m_bIsDownLoadFinished(false)
	,m_nDownLoadFileNum(0)
	,mLastDownloadedSize(0)
	,versionIsDownLoading(false)
	,serverListIsDownLoading(false)
	,resourceIsDownLoading(false)
	,mDownloadedTotalSize(0.0f)
{
	checkStoragePath();
	_schedule = new Helper();
}

NewAssetsManager::~NewAssetsManager()
{
	if (_schedule)
	{
		_schedule->stopTimer();
		_schedule->release();
	}
}

// 下载要更新的文件列表
void NewAssetsManager::downLoadServerUpdateList()
{
	if (_tid) return;

	if (_serverListUrl.size() == 0)
	{
		CCLog("ERROR : Server list file url is empty.");
		return;
	}
	_tid = new pthread_t();
	pthread_create(&(*_tid), NULL, serverListDownload, this);
}

// 下载资源文件
void NewAssetsManager::downLoadResource(std::vector<std::string>vFileurl,std::vector<std::string> StorgePath)
{
	m_vNeed2DownLoadFileUrl = vFileurl;
	
	m_vNeed2DownLoadFileStorgePath = StorgePath;

	if (m_vNeed2DownLoadFileUrl.size() == 0)
	{
		CCLog("ERROR : Resource file url is empty.");
		return;
	}
	_tid = new pthread_t();
	pthread_create(&(*_tid), NULL, resourceFileDown, this);
}

void NewAssetsManager::downLoadResource()
{
    
      if (m_vNeed2DownLoadFileUrl.size() == 0)
      {
        CCLog("ERROR : Resource file url is empty.");
        return;
      }
      _tid = new pthread_t();
       pthread_create(&(*_tid), NULL, resourceFileDown, this);
   
}

void NewAssetsManager::setDelegate(NewAssetsManagerDelegateProtocol *delegate)
{
	_delegate = delegate;
}

void NewAssetsManager::setConnectionTimeout(unsigned int timeout)
{
	_connectionTimeout = timeout;
}

void NewAssetsManager::deleteVersion()
{
	CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_VERSION, "");
}

void NewAssetsManager::sendErrorMessage(int what,int code){
	Message *msg = new Message();
	msg->what = what;
	NormalMessage *errorMessage = new NormalMessage();
	errorMessage->code =code;
	errorMessage->manager =this;
	msg->obj = errorMessage;
	this->_schedule->sendMessage(msg);
}

//
void* serverListDownload(void *data)
{
	NewAssetsManager* self = (NewAssetsManager*)data;
	do
	{
		// Create a file to save package.
		string serverListUrl = self->_serverListUrl;
		
		int nIndex = serverListUrl.find_last_of('/');
		
		if (nIndex < 0)
		{
			CCLog("ERROR : Server file url format is not correct.[%s]",serverListUrl.c_str());
			return NULL;
		}
		string fileName = serverListUrl.substr(nIndex+1, serverListUrl.length()-nIndex);
        
        self->_fileName = fileName;

        long httpCode=0;

		self->serverListIsDownLoading=true;
       
		if (!self->downLoadSingleFile(self->_serverListUrl,"update",&httpCode))
		{
			
            if(httpCode==0)
            {
                if(!self->downLoadSingleFile(self->_serverListUrl,"update",&httpCode))
                {
					self->sendErrorMessage(ASSETSMANAGER_MESSAGE_ERROR,NewAssetsManager::kNetwork);
                    break;
                }
            }
			else
			{
                self->sendErrorMessage(ASSETSMANAGER_MESSAGE_ERROR,NewAssetsManager::kNetwork);
                break;
            }
		}
		self->serverListIsDownLoading=false;
		NewAssetsManager::Message *msg1 = new NewAssetsManager::Message();
		msg1->what = ASSETSMANAGER_MESSAGE_DOWNLOAD_SERVERLIST;
		msg1->obj = self;
		self->_schedule->sendMessage(msg1);

	} while (0);

	if (self->_tid)
	{
		delete self->_tid;
		self->_tid = NULL;
	}

	return NULL;
}


void *resourceFileDown(void *data)
{
	
    NewAssetsManager* self = (NewAssetsManager*)data;
    
    std::vector<std::string> tempNeed2DownLoadFileUrl;
    
    std::vector<std::string> tempNeed2DownLoadFileStorgePath;

	self->resourceIsDownLoading=true;

	bool hasError=false;

	for (int i =0; i < self->m_vNeed2DownLoadFileUrl.size(); i++)
	{
		std::string firleUrl = self->m_vNeed2DownLoadFileUrl[i];
        
		std::string storepath = self->m_vNeed2DownLoadFileStorgePath[i];
		
        CCLOG("================================================");
		
        CCLOG("Download No.%d url=%s",i+1,firleUrl.c_str());

		if(hasError)
		{
			 tempNeed2DownLoadFileUrl.push_back(firleUrl);
             tempNeed2DownLoadFileStorgePath.push_back(storepath);
			 continue;
		}
	    
        long httpCode=0;
		
        if(!self->downLoadSingleFile(firleUrl,storepath,&httpCode))
		{
            tempNeed2DownLoadFileUrl.push_back(firleUrl);
            tempNeed2DownLoadFileStorgePath.push_back(storepath);
            hasError=true;
        }
	}
    if(hasError)
    {   
		 hasError=false;
         self->sendErrorMessage(ASSETSMANAGER_MESSAGE_ERROR,NewAssetsManager::kNetwork);
         self->m_vNeed2DownLoadFileUrl.swap(tempNeed2DownLoadFileUrl);
         self->m_vNeed2DownLoadFileStorgePath.swap(tempNeed2DownLoadFileStorgePath);
    }
	else
	{
		self->resourceIsDownLoading=false;
		NewAssetsManager::Message *msg = new NewAssetsManager::Message();
		NormalMessage *normal = new NormalMessage();
		normal->code = NewAssetsManager::kDownLoadFinished;
		normal->manager = self;
		msg->what = ASSETSMANAGER_MESSAGE_UPDATE_SUCCEED;
		msg->obj = normal;
		self->_schedule->sendMessage(msg);
		CCLOG("====all Resource download successful=====");
	}
	if (self->_tid)
	{
		delete self->_tid;
		self->_tid = NULL;
	}
	return NULL;
}

bool NewAssetsManager::downLoadSingleFile(string fileUrl, string storePath,long *httpCode)
{
	_curl = curl_easy_init();
	if (! _curl)
	{
		CCLog("ERROR : Can not init curl library.");
		return false;
	}

	// Create a file to save package.
	int nIndex = fileUrl.find_last_of('/');
	if (nIndex < 0)
	{
		CCLog("ERROR : Download url is not correct. [%s]", fileUrl.c_str());
		return false;
	}
	string fileName = fileUrl.substr(nIndex + 1, fileUrl.length() - nIndex);
	_fileName = fileName;
	string outFileDir = _storagePath + storePath + "/";

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32) 	
	string searchString("\\");
	string replaceString("/");
#else 
	string searchString("/");
	string replaceString("\\");
#endif

	string::size_type pos = 0;
	while((pos = outFileDir.find(searchString, pos)) != string::npos)
	{
		outFileDir.replace(pos, searchString.size(), replaceString);
		pos++;
	}
	makeDirOrFile(outFileDir);

	string outFileName = _storagePath + storePath + "/" + fileName;
	FILE *fp = fopen(outFileName.c_str(), "wb");
	if (!fp)
	{
		sendErrorMessage(ASSETSMANAGER_MESSAGE_ERROR,NewAssetsManager::kCreateFile);
		CCLog("ERROR : Can not create file %s for download.", outFileName.c_str());
		return false;
	}

	// Download file
	curl_easy_setopt(_curl, CURLOPT_URL, fileUrl.c_str());
	
	curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, downLoadPackage);
	
	curl_easy_setopt(_curl, CURLOPT_WRITEDATA, fp);
	
	curl_easy_setopt(_curl, CURLOPT_SSL_VERIFYPEER, 0L);
    
	curl_easy_setopt(_curl, CURLOPT_CONNECTTIMEOUT, 10);
    
	curl_easy_setopt(_curl, CURLOPT_TIMEOUT, 300);
   
	curl_easy_setopt(_curl, CURLOPT_FOLLOWLOCATION, 1L);
    
	curl_easy_setopt(_curl, CURLOPT_MAXREDIRS, 10);
    
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
      curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_LIMIT, LOW_SPEED_LIMIT);
      curl_easy_setopt(_curl, CURLOPT_LOW_SPEED_TIME, LOW_SPEED_TIME);
    #endif
	
	if (getDownLoadFileNum() == 0)
	{
		curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, true);	
	}
	else
	{
		curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, false);
	}
	
	curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, assetsNewManagerProgressFunc);
	
    curl_easy_setopt(_curl, CURLOPT_PROGRESSDATA, this);
	
	CURLcode res = curl_easy_perform(_curl);

	long http_code = 0;
	
    curl_easy_getinfo(_curl, CURLINFO_RESPONSE_CODE, &http_code);
	
	double speedDownload=0.0;
    
	curl_easy_getinfo(_curl, CURLINFO_SPEED_DOWNLOAD, &speedDownload);
	
    curl_easy_cleanup(_curl);
    
    *httpCode=http_code;
    
    fclose(fp);
	
    if ((res==0)&&(http_code==200))
	{
		CCLOG("Succeed downloaded file=%s ,speedDownload=%0.2f KB/S", fileUrl.c_str(),speedDownload/1024);
		return true;
    }
    else
    {
        CCLog("ERROR : Download file=%s. HttpCode=%ld", fileUrl.c_str(), http_code);
        return false;
    }
}

bool NewAssetsManager::uncompress(string filename)
{
	// Open the zip file
	string outFileName = filename;//_storagePath + TEMP_PACKAGE_FILE_NAME;
	
	unzFile zipfile = unzOpen(outFileName.c_str());
	
	if (! zipfile)
	{
		CCLog("can not open downloaded zip file %s", outFileName.c_str());
		return false;
	}

	// Get info about the zip file
	unz_global_info global_info;

	if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
	{
		CCLog("can not read file global info of %s", outFileName.c_str());
		unzClose(zipfile);
		return false;
	}

	// Buffer to hold data read from the zip file
	char readBuffer[BUFFER_SIZE];

	CCLOG("start uncompressing");

	// Loop to extract all files.
	uLong i;

	for (i = 0; i < global_info.number_entry; ++i)
	{
		// Get info about current file.
		unz_file_info fileInfo;
		char fileName[MAX_FILENAME];
		if (unzGetCurrentFileInfo(zipfile,
			&fileInfo,
			fileName,
			MAX_FILENAME,
			NULL,
			0,
			NULL,
			0) != UNZ_OK)
		{
			CCLog("can not read file info");
			unzClose(zipfile);
			return false;
		}

		string fullPath = _storagePath + fileName;

		// Check if this entry is a directory or a file.
		const size_t filenameLength = strlen(fileName);
		if (fileName[filenameLength-1] == '/')
		{
			// Entry is a direcotry, so create it.
			// If the directory exists, it will failed scilently.
			if (!createDirectory(fullPath.c_str()))
			{
				CCLog("can not create directory %s", fullPath.c_str());
				unzClose(zipfile);
				return false;
			}
		}
		else
		{
			

			// Open current file.
			if (unzOpenCurrentFile(zipfile) != UNZ_OK)
			{
				CCLog("can not open file %s", fileName);
				unzClose(zipfile);
				return false;
			}

			// Create a file to store current file.
			FILE *out = fopen(fullPath.c_str(), "wb");
			if (! out)
			{
				CCLog("can not open destination file %s", fullPath.c_str());
				unzCloseCurrentFile(zipfile);
				unzClose(zipfile);
				return false;
			}

			// Write current file content to destinate file.
			int error = UNZ_OK;
			do
			{
				error = unzReadCurrentFile(zipfile, readBuffer, BUFFER_SIZE);
				if (error < 0)
				{
					CCLog("can not read zip file %s, error code is %d", fileName, error);
					unzCloseCurrentFile(zipfile);
					unzClose(zipfile);
					return false;
				}

				if (error > 0)
				{
					fwrite(readBuffer, error, 1, out);
				}
			} while(error > 0);

			fclose(out);
		}

		unzCloseCurrentFile(zipfile);

		// Goto next entry listed in the zip file.
		if ((i+1) < global_info.number_entry)
		{
			if (unzGoToNextFile(zipfile) != UNZ_OK)
			{
				CCLog("can not read next file");
				unzClose(zipfile);
				return false;
			}
		}
	}

	CCLOG("end uncompressing");

	return true;
}

void NewAssetsManager::makeDirOrFile(std::string dirPath)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32

	int e_pos = dirPath.length();
	int f_pos = dirPath.find("\\",0);
	std::string subdir;

	do
	{
		e_pos = dirPath.find("\\",f_pos+2);
		if(e_pos != -1)
		{
			subdir = dirPath.substr(0,e_pos);
			mkdir(subdir.c_str());
		}
		f_pos = e_pos;
	} while (f_pos != -1);

#else

	int e_pos = dirPath.length();
	
	int f_pos = dirPath.find("/",0);
	
	std::string subdir;

	do
	{
		e_pos = dirPath.find("/",f_pos+1);
		if(e_pos != -1)
		{
			subdir = dirPath.substr(0,e_pos);
            mkdir(subdir.c_str(),S_IRWXU);
		}
		f_pos = e_pos;
	} while (f_pos != -1);

#endif
}


// Implementation of AssetsManagerHelper
NewAssetsManager::Helper::Helper()
{
	_messageQueue = new list<Message*>();
	pthread_mutex_init(&_messageQueueMutex, NULL);
	CCDirector::sharedDirector()->getScheduler()->scheduleUpdateForTarget(this, 0, false);
}

NewAssetsManager::Helper::~Helper()
{
	if (_messageQueue) delete _messageQueue;
}

void NewAssetsManager::Helper::stopTimer()
{
	CCDirector::sharedDirector()->getScheduler()->unscheduleAllForTarget(this);
	_messageQueue->clear();
}

void NewAssetsManager::Helper::sendMessage(Message *msg)
{
	pthread_mutex_lock(&_messageQueueMutex);

	// For adding progress message, firstly check the last message of current message queue.
	// If the last message is progress message and is not being processed, 
	// then drop it and add new progress message.
	// The goal is reduce length of message queue.
	if ((_messageQueue->size() > 0) && (msg->what == ASSETSMANAGER_MESSAGE_PROGRESS))
	{
		if (_messageQueue->back()->what == ASSETSMANAGER_MESSAGE_PROGRESS)
		{
			_messageQueue->pop_back();
		}
	}
	_messageQueue->push_back(msg);

	pthread_mutex_unlock(&_messageQueueMutex);
}

// 定时器消息处理函数
void NewAssetsManager::Helper::update(float dt)
{
	Message *msg = NULL;

	// Returns quickly if no message
	pthread_mutex_lock(&_messageQueueMutex);
	if (_messageQueue->empty())
	{
		pthread_mutex_unlock(&_messageQueueMutex);
		return;
	}

	// Gets message
	msg = *(_messageQueue->begin());
	_messageQueue->pop_front();
	pthread_mutex_unlock(&_messageQueueMutex);
	switch (msg->what) 
	{
	case ASSETSMANAGER_MESSAGE_UPDATE_SUCCEED:
		if (((NormalMessage*)msg->obj)->manager->_delegate)
		{
			((NormalMessage*)msg->obj)->manager->_delegate->onSuccess(((NormalMessage*)msg->obj)->code);
		}
		delete (NormalMessage*)msg->obj;
		break;

		//The list of servers to download success
	case ASSETSMANAGER_MESSAGE_DOWNLOAD_SERVERLIST: 
		if (((NewAssetsManager*)(msg->obj))->_delegate)
		{
			((NewAssetsManager*)(msg->obj))->_delegate->onServerListDownLoadSuccess();
		}

		break;

	case ASSETSMANAGER_MESSAGE_RECORD_DOWNLOADED_VERSION:
		CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_DOWNLOADED_VERSION,
			((NewAssetsManager*)msg->obj)->_version.c_str());
		CCUserDefault::sharedUserDefault()->flush();
		break;

	case ASSETSMANAGER_MESSAGE_PROGRESS:
		if (((ProgressMessage*)msg->obj)->manager->_delegate)
		{
			((ProgressMessage*)msg->obj)->manager->_delegate->onProgress(((ProgressMessage*)msg->obj)->percent);
		}
		delete (ProgressMessage*)msg->obj;
		break;

	case ASSETSMANAGER_MESSAGE_ERROR:
		if (((NormalMessage*)msg->obj)->manager->_delegate)
		{
			((NormalMessage*)msg->obj)->manager->_delegate->onError(((NormalMessage*)msg->obj)->code);
		}
		delete ((NormalMessage*)msg->obj);
		break;

	case ASSETSMANAGER_MESSAGE_NEW_VERSION:
		if (((NormalMessage*)msg->obj)->manager->_delegate)
		{
			((NormalMessage*)msg->obj)->manager->_delegate->onSuccess(((NormalMessage*)msg->obj)->code);
		}
		delete (NormalMessage*)msg->obj;
		break;
   case ASSETSMANAGER_MESSAGE_PREPARE_DOWNLOAD_SERVER_LIST:
		if (((NormalMessage*)msg->obj)->manager->_delegate)
		{
			((NormalMessage*)msg->obj)->manager->_delegate->prepareToDownloadServerList();
		}
		delete (NormalMessage*)msg->obj;
		break;
	default:
		break;
	}

	delete msg;
}

void NewAssetsManager::Helper::handleUpdateSucceed(Message *msg)
{
	NewAssetsManager* manager = (NewAssetsManager*)msg->obj;

	// Record new version code.
	CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_VERSION, manager->_version.c_str());

	// Unrecord downloaded version code.
	CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_DOWNLOADED_VERSION, "");
	
	CCUserDefault::sharedUserDefault()->flush();

	// Delete unloaded zip file.
	string zipfileName = manager->_storagePath + manager->_fileName;
	if (std::string::npos == zipfileName.find(".zip")) 
	{
		if (remove(zipfileName.c_str()) != 0)
		{
			CCLog("can not remove downloaded zip file %s", zipfileName.c_str());
		}
	}

	if (manager) manager->_delegate->onSuccess(-1);
}

static size_t downLoadPackage(void *ptr, size_t size, size_t nmemb, void *userdata)
{
	FILE *fp = (FILE*)userdata;
	size_t written = fwrite(ptr, size, nmemb, fp);
	return written;
}


static int show_percent = 0; // Show download percent in progress bar

int assetsNewManagerProgressFunc(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded)
{
	
	NewAssetsManager* newAssetsManager = (NewAssetsManager*)ptr;

	NewAssetsManager::Message *msg = new NewAssetsManager::Message();

	if (totalToDownload <= 0)
	{
		newAssetsManager->setLastDownloadedSize(0);
		return 0;
	}
	
	// Get total downloaded size
	double singleFileLastDownloadedSize = newAssetsManager->getLastDownloadedSize();

	// Downloaded size of current notification
	double persize = nowDownloaded - singleFileLastDownloadedSize;
	
	if(persize > 0)
	{
		//Record this download size for next size count
		newAssetsManager->setLastDownloadedSize(nowDownloaded);
		double totalSize=newAssetsManager->getDownloadedTotalSize();
		totalSize=totalSize+persize;
		newAssetsManager->setDownloadedTotalSize(totalSize);
	}
	else
	{
		return 0;
	}

	double downloadedTotalSize=newAssetsManager->getDownloadedTotalSize();//had downloaded

	float totalDownloadSize = newAssetsManager->getDownLoadSize();//all to downloaded
	
	float percent = downloadedTotalSize/totalDownloadSize;

	if (percent < 0)
	{
		percent = 0.0f;
	}
	else if (percent >= 1.0f)
	{
		percent = 1.0f;
	}
    if (percent <= 1)
	{
		// Set show percent data and check if necessary to update progress bar for decrease message handle
		
		int current_percent = (int)(percent*100);
		
		if (current_percent <= show_percent)
		{
			return 0;
		}
		else
		{
			show_percent = current_percent;
		}

		ProgressMessage *progressData = new ProgressMessage();
		progressData->percent = show_percent;
		progressData->manager = newAssetsManager;
		msg->what = ASSETSMANAGER_MESSAGE_PROGRESS;
		msg->obj = progressData;
		newAssetsManager->_schedule->sendMessage(msg);
	}

	return 0;
}

/*
 * Create a direcotry is platform depended.
 */
bool NewAssetsManager::createDirectory(const char *path)
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
    mode_t processMask = umask(0);
    int ret = mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
    umask(processMask);
    if (ret != 0 && (errno != EEXIST))
    {
        return false;
    }
    
    return true;
#else
    BOOL ret = CreateDirectoryA(path, NULL);
	if (!ret && ERROR_ALREADY_EXISTS != GetLastError())
	{
		return false;
	}
    return true;
#endif
}

void NewAssetsManager::setSearchPath()
{
    vector<string> searchPaths = CCFileUtils::sharedFileUtils()->getSearchPaths();
    vector<string>::iterator iter = searchPaths.begin();
    searchPaths.insert(iter, _storagePath);
    CCFileUtils::sharedFileUtils()->setSearchPaths(searchPaths);
}

static size_t getVersionCode(void *ptr, size_t size, size_t nmemb, void *userdata)
{
	string *version = (string*)userdata;
	version->append((char*)ptr, size * nmemb);

	return (size * nmemb);
}


checkVersionType NewAssetsManager::checkUpdate()
{
	
	if (_versionFileUrl.size() == 0) 
	{
		return eNoNewVersion;
	}
	_curl = curl_easy_init();

	if (! _curl)
	{
		CCLog("ERROR : Can not init curl library.");
		return eNoNewVersion;
	}
	_version.clear();

	std::string versionAndServerlist;

	CURLcode res;

	curl_easy_setopt(_curl, CURLOPT_URL, _versionFileUrl.c_str());

	curl_easy_setopt(_curl, CURLOPT_SSL_VERIFYPEER, 0L);

	curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, getVersionCode);

	curl_easy_setopt(_curl, CURLOPT_WRITEDATA, &versionAndServerlist);

	if (_connectionTimeout)
	{
        curl_easy_setopt(_curl, CURLOPT_CONNECTTIMEOUT, _connectionTimeout);
	}

    curl_easy_setopt(_curl, CURLOPT_TIMEOUT, 30);
    
	res = curl_easy_perform(_curl);
	
	long http_code = 0;
    
	curl_easy_getinfo(_curl, CURLINFO_RESPONSE_CODE, &http_code);
	
	versionIsDownLoading=true;
	
	if (res != CURLE_OK || http_code != 200)
	{
		CCLog("ERROR : Can not get version file content, curl code = %d, http code = %ld", res,http_code);
		curl_easy_cleanup(_curl);
		return eNetWorkError;
	}
	
	versionIsDownLoading=false;

	std::string recordedVersion = CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_VERSION);
	
	std::fstream outfile;
	
	string outFileName = _storagePath + "/" + "version";
	
	outfile.open(outFileName.c_str(), ios::out);
	
	if(outfile)
	{
		outfile<<versionAndServerlist<<endl;
		outfile.close();
	}
	CSJson::Reader reader;

	CSJson::Value root;

	reader.parse(versionAndServerlist, root);

	_version = root["version"].asString();

	CCLog("local versin=%s ,server version=%s",recordedVersion.c_str(),_version.c_str());

	bool isMajorVersionUpdate = false;

	bool needUptate = verCompare(recordedVersion,_version,isMajorVersionUpdate);

	if (needUptate && isMajorVersionUpdate == false )
	{
		CCLOG("There is a new online update version : %s", _version.c_str());
		return eNewVersion;
	}
	else if(needUptate && isMajorVersionUpdate)
	{
		CCLOG("There is a new Package update version : %s", _version.c_str());
		CCUserDefault::sharedUserDefault()->setStringForKey("current-version-code","");
		CCUserDefault::sharedUserDefault()->flush();
		return eNewMajorVersion;
	}
	else
	{
		CCLOG("There is no new version.");
		return eNoNewVersion;
	}
}

// 版本比较
bool NewAssetsManager::verCompare(std::string recordVersion,std::string serverVersion,bool &isMajorVersionUpdate)
{
	CCLOG("recordVersion = %s,serverVersion = %s",recordVersion.c_str(),serverVersion.c_str());

	CCArray * recordVersionArr = StringUtil::sharedStrUtil()->split(recordVersion.c_str(), ".");
	
	CCArray * serverVersionArr = StringUtil::sharedStrUtil()->split(serverVersion.c_str(), ".");

	int count1 =  recordVersionArr->count();

	int count2 =  serverVersionArr->count();

	int count = count1 < count2 ? count1:count2 ;

	CCString *char1 = NULL;

	CCString *char2 = NULL;

	for (int i = 0; i < count; i++)
	{
		char1 = (CCString *)recordVersionArr->objectAtIndex(i);
		char2 = (CCString *)serverVersionArr->objectAtIndex(i);
		if (char1->intValue() == char2->intValue())
		{
			continue;
		}
		else if (char1->intValue() != char2->intValue())
		{
			if (i == 1)
			{
				isMajorVersionUpdate = true;
			}
			return true;
		}
	}

	return false;
}

void NewAssetsManager::update()
{
	if (_tid) return;

	// 1. Urls of package and version should be valid;
	
	if (_versionFileUrl.size() == 0 || _serverListUrl.size() == 0 || std::string::npos == _serverListUrl.find(".csv"))
	{
		CCLog("no version file url, or no package url, or the package is not a zip file");
		return;
	}

	// Check if there is a new version.
	if (!checkUpdate()) 
	{
		return;
	}
	// Is package already downloaded?
	_downloadedVersion = CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_DOWNLOADED_VERSION);
}

NS_GAME_FRM_END