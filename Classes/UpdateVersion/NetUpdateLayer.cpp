#include <iostream>
#include <fstream>

#include "CsvUtil.h"
#include "md5.h"

#include "UIWidgets/RichLabel.h"
#include "UIWidgets/DSMask.h"
#include "UIWidgets/GuideLayer.h"
#include "UIWidgets/GraySprite.h"
#include "UIWidgets/DSMask.h"
#include "UIWidgets/AnimatePacker.h"
#include "UIWidgets/Button.h"
#include "UIWidgets/DialogInquire.h"
#include "UIWidgets/DialogConfirm.h"

#include "GameEntry.h"
#include "NetUpdateLayer.h"

#if ENABLE_LOCAL_FIGHT
#include "Fight/LocalFight.h"
#endif

#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include <jni.h> 
#include "platform/android/jni/JniHelper.h" 
#include <android/log.h> 
#endif

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#else
#include <direct.h>
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "LinkManager.h"
#endif

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#define LOCAL_UPDATE_FILE_LIST "update/local_md5.csv"
#define SERVER_UPDATE_FILE_LIST "update/serverlist.csv"
#else
#define LOCAL_UPDATE_FILE_LIST "update\\local_md5.csv"
#define SERVER_UPDATE_FILE_LIST "update\\serverlist.csv"
#endif


NS_GAME_FRM_BEGIN

USING_NS_CC;
USING_NS_CC_EXT;

using namespace std;



NetUpdateLayer::NetUpdateLayer()
	:m_pLblEnter(NULL)
	,m_pLblReset(NULL)
	,m_pLblUpdate(NULL)
	,m_pAssetsManager(NULL)
	,m_bisUpdateLblClicked(false)
	,m_pUpdateBar(NULL)
	,m_nDownLoadSize(0)
	,m_nDownLoadFileNum(0)
	,m_pLoadingAnim(NULL)
	,m_pLoadingRenAnim(NULL)
    ,m_barBg(NULL)
    ,m_pFileProgressLabel(NULL)
	,progressAction(NULL)
	,personAction(NULL)

{
	
}

NetUpdateLayer::~NetUpdateLayer()
{
	if (m_pAssetsManager!=NULL)
	{
		CC_SAFE_DELETE(m_pAssetsManager);
	}
	mStringDict->release();
}


NetUpdateLayer* NetUpdateLayer::createNetUpdateLayer()
{
	NetUpdateLayer *pNetUpdateLayer = new NetUpdateLayer();
	if(pNetUpdateLayer && pNetUpdateLayer->init())
	{
		pNetUpdateLayer->autorelease();
		return pNetUpdateLayer;
	}
	else
	{
		CC_SAFE_DELETE(pNetUpdateLayer);
		return NULL;
	}
}

void NetUpdateLayer::showUpdateUI(bool alertPop = true)
{

  if (!m_pUpdateBar)
  {
	  m_pUpdateBar = CCSprite::create("img/update/updata_loading_bar.png");
	  m_pUpdateBar->setPosition(ccp(m_barBg->getContentSize().width/2.0f-m_pUpdateBar->getContentSize().width/2.0f,m_barBg->getContentSize().height/2.0f+2.0f));
	  m_pUpdateBar->setAnchorPoint(ccp(0.0f,0.5f));
	  m_pUpdateBar->setTextureRect(CCRectMake(0,0,0,19));
	  m_barBg->addChild(m_pUpdateBar);
	  m_pUpdateBar->setVisible(false);
	  m_barBg->setVisible(false);
  }  
  if (!m_pLoadingAnim)
  {
    AnimatePacker::Instance()->loadAnimations("img/client/animate/loading_jindutiao/jindutiao.xml");
    m_pLoadingAnim = CCSprite::createWithSpriteFrameName("jindutiao_0001.png");
    m_pLoadingAnim->setAnchorPoint(ccp(0,0.5));
    m_pLoadingAnim->setPosition(ccp(0,m_pUpdateBar->getContentSize().height/2.0f-2.5f));
    m_pUpdateBar->addChild(m_pLoadingAnim,10);
	m_pLoadingAnim->setVisible(false);
  }
  
  if (!m_pLoadingRenAnim)
  {
    AnimatePacker::Instance()->loadAnimations("img/client/animate/loading_guanyurun/loading_run.xml");  
    m_pLoadingRenAnim =CCSprite::createWithSpriteFrameName("loading_guanyurun0001.png"); 
    m_pLoadingRenAnim->setAnchorPoint(ccp(0.5f,0));
    m_pLoadingRenAnim->setScale(0.3f);
    m_pLoadingRenAnim->setPosition(ccp(0.0f,m_pUpdateBar->getContentSize().height));
    m_pUpdateBar->addChild(m_pLoadingRenAnim,10);
    m_pLoadingRenAnim->setVisible(false);
  }

  if (alertPop)
  {
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
		string str =  getString("newVesion");
		DialogConfirm::Instance()->show(str,this);
		DialogConfirm::Instance()->setConfirmCallback(callfuncO_selector(NetUpdateLayer::prepareToDownloadServerList), this);
	#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		string str = getString("newVesion");
		DialogInquire::Instance()->show(str,this);
		DialogInquire::Instance()->setConfirmCallback(callfuncO_selector(NetUpdateLayer::prepareToDownloadServerList), this);
		DialogInquire::Instance()->setCancelCallback(callfuncO_selector(NetUpdateLayer::ExitGame), this);
	#endif
  }
  else 
  {
	  goUpdateCallBack(NULL);
  }
	
}

void NetUpdateLayer::entryWebAndExitGame(CCObject *pSender)
{
	CCDirector::sharedDirector()->end();
	std::string url= getString(INST_UPDATE_URL_KEY);
	if (url.length() == 0)
	{
		return;
	}

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID

	bool hasMethod;
	JniMethodInfo  t;

	hasMethod = JniHelper::getStaticMethodInfo( t,
		"com/dst/sanguocard/SanguoCardMain",
		"openIntentWithUrl",
		"(Ljava/lang/String;)V");
	if (hasMethod)
	{
		CCLOG("URL ================ %s",url.c_str());
		jstring urlpath =   t.env->NewStringUTF(url.c_str());
		t.env->CallStaticVoidMethod( t.classID, t.methodID,urlpath);
		CCLOG("openIntentWithUrl METHOD BE CALLED");
	}
	else
	{
		CCLOG("NO openIntentWithUrl METHOD");
	}

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

	LinkManager::openUpdateUrlAndExitApp(url);

#endif

}

void NetUpdateLayer::ExitGame(CCObject *pSender)
{
	CCDirector::sharedDirector()->end();	
}

void NetUpdateLayer::entryGame()
{
	CCSize size = CCDirector::sharedDirector()->getWinSize();

	Button *pSignBtn = Button::createBtn("img/update/select_btn.png","img/update/fast_game.png");
	
	pSignBtn->setPosition(ccp(size.width*3/4,100));
	
	pSignBtn->setOnClickCallback(callfuncO_selector(NetUpdateLayer::entryGameCallBack),this);
	
	this->addChild(pSignBtn,1,ENTRY_BTN_TAG); 	
}

void NetUpdateLayer::updateBar(int cur)
{	
	m_pUpdateBar->setTextureRect( CCRectMake(0 , 0 , cur , 39));
}

void NetUpdateLayer::goUpdateCallBack(CCObject *pSender)
{
	CCLOG("update app version.............");
	
	m_pUpdateBar->setVisible(true);
	
	m_barBg->setVisible(true);
	
	m_pLoadingAnim->setVisible(true);

	m_pLoadingRenAnim->setVisible(true);

	m_pLoadingAnim->runAction(CCRepeatForever::create(AnimatePacker::Instance()->getAnimate("jindutiao")));

	m_pLoadingRenAnim->runAction(CCRepeatForever::create(AnimatePacker::Instance()->getAnimate("loading_run")));

	//Initialize the local MD5 file
	createLocalCsvFile();
	
	// Read local csv content
	readLocalCsvFile();

	m_pProgressLabel->setString("");

	m_pNetWorkTips->setString("");

	m_pAssetsManager->downLoadServerUpdateList();

	m_bisUpdateLblClicked = true;
}

void NetUpdateLayer::entryGameCallBack(CCObject *pSender)
{
	enter(NULL);
	CCLOG("entryGameCallBack");
}

NewAssetsManager* NetUpdateLayer::getAssetsManager()
{
	if (!m_pAssetsManager)
	{
		// version URL
		std::string verUrl = getString("update_url");
		
		CCLOG("version Url = %s",verUrl.c_str());
		
		// serverlist.csv URL
		std::string serverResourceListUrl = getString("resource_url");
		
		CCLOG("serverlist.csv Url = %s",serverResourceListUrl.c_str());

		m_pAssetsManager = new NewAssetsManager(serverResourceListUrl.c_str(),verUrl.c_str(), m_strPathToSave.c_str());
		
		m_pAssetsManager->setDelegate(this);
		
		m_pAssetsManager->setConnectionTimeout(10);  
	}
	return m_pAssetsManager;
}

void NetUpdateLayer::createDownloadDir()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
	{
		m_strPathToSave = CCFileUtils::sharedFileUtils()->getWritablePath();
		
		DIR *pDir = NULL;

		pDir = opendir(m_strPathToSave.c_str());
		if (!pDir)
		{
			mkdir(m_strPathToSave.c_str(), S_IRWXU | S_IRWXG | S_IRWXO);
		}

		string updatePath("");
		
		updatePath.append(m_strPathToSave).append("update/");
		
		makeDirOrFile(updatePath);
		
		closedir(pDir);
	}
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	{
		m_strPathToSave = CCFileUtils::sharedFileUtils()->getWritablePath();
		
		string updatePath("");
		
		if(m_strPathToSave.length() > 0)
		{
			m_strPathToSave.append("sanguoRes\\");
			
			updatePath.append(m_strPathToSave).append("update\\");
		}
		
		makeDirOrFile(updatePath);
	}
#endif
	
	// Add writable path to app search path
	vector<string> searchPaths = CCFileUtils::sharedFileUtils()->getSearchPaths();
	
	searchPaths.insert(searchPaths.begin(), m_strPathToSave);
	
	CCFileUtils::sharedFileUtils()->setSearchPaths(searchPaths);
}

bool NetUpdateLayer::init()
{
	
	string appVersion = CCUserDefault::sharedUserDefault()->getStringForKey("app-version");
	
	if (APP_VERSION.compare(appVersion) != 0)
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		
		string updatePath = CCFileUtils::sharedFileUtils()->getWritablePath();
		
		cleanDir(updatePath.c_str());
		
		CCLOG("Clean online update directory : %s", updatePath.c_str());
#endif		
		CCLOG("Update app-version = %s", APP_VERSION.c_str());
		
		CCUserDefault::sharedUserDefault()->setStringForKey("app-version",APP_VERSION);
		
		CCUserDefault::sharedUserDefault()->setStringForKey("current-version-code","");
		
		CCUserDefault::sharedUserDefault()->flush();
	}

	
	if(!CCLayerColor::initWithColor(ccc4(0,0,0,0)))
	{
		return false;
	}

	// Create update directory in writable path if necessary
	createDownloadDir();
    
    setKeypadEnabled(true);

	// Read config XML
	mStringDict  = CCDictionary::createWithContentsOfFile("fonts/strings.xml");

	mStringDict->retain();

	// Show splash image
	CCSize size = CCDirector::sharedDirector()->getWinSize();
	
	CCSprite *mainBg =NULL;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID  || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

	// Load company logo
	CCSprite *pLogIcon = CCSprite::create("img/update/default_log_icon.png");

	if(pLogIcon)
	{
		pLogIcon->setPosition(ccp(size.width/2.0f,size.height/2.0f));
	
		pLogIcon->setOpacity(255);
	
		this->addChild(pLogIcon,99999);
	
		CCActionInterval *actionFadeOut = CCFadeTo::create(0.5f,0);
	
		pLogIcon->runAction(CCSequence::createWithTwoActions(CCDelayTime::create(1.5f),actionFadeOut));
	}
	mainBg = CCSprite::create("img/regist/loadingBg.png");

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

	mainBg = CCSprite::create("img/regist/loadingBG-ip5.png");

#endif

	if (mainBg != NULL)
	{
		mainBg->setPosition(ccp(size.width / 2.0f, size.height / 2.0f));
		
		this->addChild(mainBg);
	}

	m_pNetWorkTips = CCLabelTTF::create("", "Arial", 30);

	m_pNetWorkTips->setColor(ccGRAY);

	m_pNetWorkTips->setPosition(ccp(size.width/2.0f,30.0f));

	this->addChild(m_pNetWorkTips,10);

	m_barBg = CCSprite::create("img/update/updata_loading_bar_bg.png");
    
	if(m_barBg)
	{
		m_barBg->setPosition(ccp(size.width/2.0f,65.0f));
	    this->addChild(m_barBg);
		m_barBg->setVisible(false);
	}

	m_pProgressLabel = CCLabelBMFont::create("","fonts/number.fnt");
	
	m_pFileProgressLabel = CCLabelBMFont::create("","img/client/widget/words/card_name/update_number.fnt");

	m_pProgressLabel->setPosition(ccp(m_barBg->getContentSize().width/2.0f,m_barBg->getContentSize().height/2.0f - 2.0f));
	
	m_barBg->addChild(m_pProgressLabel,1); 
	
	m_pFileProgressLabel->setPosition(ccp(m_barBg->getContentSize().width/2.0f,-20.0f));
	
	m_barBg->addChild(m_pFileProgressLabel,2);

	string localVersion = CCUserDefault::sharedUserDefault()->getStringForKey("current-version-code");
	
	string defaultResVer = getString("default_res_ver");
	
	if (localVersion.length() == 0)
	{
		// Init app version from strings.xml at first run
		CCUserDefault::sharedUserDefault()->setStringForKey("current-version-code",defaultResVer);
		
		CCUserDefault::sharedUserDefault()->flush();
	}
	else
	{
		// In case APP upgrade
		if (verCompare(localVersion,defaultResVer) < 0)
		{
			// Update current version to user setting
			CCUserDefault::sharedUserDefault()->setStringForKey("current-version-code",defaultResVer);
			
			CCUserDefault::sharedUserDefault()->flush();
		}
	}

  // Get assets manager instant
  m_pAssetsManager = getAssetsManager();

  if(m_pAssetsManager == NULL)
  {
	  return false;
  }

  checkVersion(NULL);

  return true;
}

void NetUpdateLayer::checkVersion(CCObject *pSender)
{
  
  checkVersionType checkResult = m_pAssetsManager->checkUpdate();
  
  if(checkResult == eNoNewVersion)//no new version ,send message to notify that enter game
  {
	sendMessage(ASSETSMANAGER_MESSAGE_ERROR,NewAssetsManager::kNoNewVersion);
  }
  else if(checkResult == eNewVersion)//have new version to update
  {
	sendMessage(ASSETSMANAGER_MESSAGE_NEW_VERSION,NewAssetsManager::kNewVersion);
  }
  else if(checkResult ==eNetWorkError)//network error occur
  {
	sendMessage(ASSETSMANAGER_MESSAGE_ERROR,NewAssetsManager::kNetwork);
  }
  else if(checkResult == eNewMajorVersion )//new major version,must update app 
  {
	if(m_barBg)
	{
		m_barBg->setVisible(false);
	}
	#if CC_TARGET_PLATFORM != CC_PLATFORM_WIN32
    
    string updatePath = CCFileUtils::sharedFileUtils()->getWritablePath();
    
	cleanDir(updatePath.c_str());
    
	CCLOG("Clean online update directory : %s", updatePath.c_str());

    #endif
    std::string str = getString("newMajorVesion");

    DialogConfirm::Instance()->show(str,this);

    DialogConfirm::Instance()->setConfirmCallback(callfuncO_selector(NetUpdateLayer::entryWebAndExitGame), this);
  }
  
}



void NetUpdateLayer::update(CCObject *pSender)
{
	m_pAssetsManager = getAssetsManager();
	
	if(m_pAssetsManager==NULL)
	{
		return;
	}
	
	m_pProgressLabel->setString("");
	
	m_pAssetsManager->downLoadServerUpdateList();
	
	m_bisUpdateLblClicked = true;	
}

void NetUpdateLayer::reset(CCObject *pSender)
{
	m_pProgressLabel->setString(" ");

	getAssetsManager()->deleteVersion();
	
	CCUserDefault::sharedUserDefault()->setStringForKey("downloaded-version-code", "");
	
	createDownloadDir();
	
	m_bisUpdateLblClicked = false;
}

void NetUpdateLayer::enter(CCObject *pSender)
{
	if (m_bisUpdateLblClicked)
	{
		vector<string> searchPaths = CCFileUtils::sharedFileUtils()->getSearchPaths();
		
		searchPaths.insert(searchPaths.begin(), m_strPathToSave);
		
		CCFileUtils::sharedFileUtils()->setSearchPaths(searchPaths);
	}

	// Release download manager
	if (m_pAssetsManager)
	{
		delete m_pAssetsManager;
		
		m_pAssetsManager = NULL;
	}

	GameEntry::instance()->runGame();
}

void NetUpdateLayer::onProgress(int percent)
{
	
	if(!m_pLoadingAnim->isVisible())
	{
		m_pLoadingAnim->setVisible(true);
	}
	if(!m_pLoadingRenAnim->isVisible())
	{
		m_pLoadingRenAnim->setVisible(true);
	}

	if(!m_barBg->isVisible())
	{
		m_barBg->setVisible(true);      
	}

	if (percent < 0)
	{
		percent = 0;
	}

	char progress[16] = {0};
	
	snprintf(progress, sizeof(progress), "%d%%",percent);
	
	m_pProgressLabel->setString(progress);
	
	m_pProgressLabel->setVisible(true);

	int totalDownLoadSize = m_pAssetsManager->getDownLoadSize()/1024; //KB

	int alreadyDownLoadSize = percent*totalDownLoadSize/100; //KB

	char fileProgress[40] = {0};

	snprintf(fileProgress, sizeof(fileProgress), "%dKB/%dKB", alreadyDownLoadSize,totalDownLoadSize);

	m_pFileProgressLabel->setString(fileProgress);

	m_pFileProgressLabel->setVisible(true);

	int barPercent = 522.0f *percent/100;

	m_pUpdateBar->setTextureRect(CCRectMake(0,0,barPercent,20));

	m_pLoadingRenAnim->setPosition(ccp(barPercent,m_pUpdateBar->getContentSize().height));
}

void NetUpdateLayer::onSuccess(int errorCode)
{
	
	if(errorCode == NewAssetsManager::kNewVersion)
	{
		std::ostringstream ossNewVersionCode;
		ossNewVersionCode << "V" << m_pAssetsManager->getNewVersionCode();
		m_pNetWorkTips->setString(ossNewVersionCode.str().c_str());
		m_pNetWorkTips->setVisible(true);
		showUpdateUI(true);
	}
	else if(errorCode == NewAssetsManager::kDownLoadFinished)
	{
		prepareEnterGame();
	}
}



void NetUpdateLayer::onServerListDownLoadSuccess()
{
  
	bool bReadServer = readServerCsvFile(SERVER_UPDATE_FILE_LIST);
		
	if(!bReadServer)
	{
		CCLog("ERROR : Read Server File List in 'update' directory failed!");
		return;
	}

	//Server file name and the MD5 list
	string sPath = ""; 
		
	string sMd5 = "";

	//A local file name and the MD5 list
	string lPath = ""; 
		
	string lMd5 = ""; 

	//Modify the local configuration file MD5
	map<string, string> mdLocalTempTable;

	mdLocalTempTable.clear();

	// Download again flag
	bool bIsUpdAgain = this->isUpdating();

	//File round robin comparison, if the local MD5 codes and its not the same without also download, Download
	for (map<string, ServerFileInfo>::const_iterator itS = mdServerTable.begin(); itS != mdServerTable.end(); itS++)
	{
		bool bTarget = false;
			
		sPath = itS->first;
			
		ServerFileInfo info = itS->second;
			
		sMd5 = info.md5;

		//Look for local file exists 
		map<string, string>::iterator itL = mdLocalTable.find(sPath);

		if (itL != mdLocalTable.end()) //got it
		{
			// Compare MD5 code
			lMd5 = itL->second;
			if (sMd5.compare(lMd5) != 0)
			{
				bTarget = true;
			}
		}
		else //couldn't found it
		{
			bTarget = true;
		}

		if (bTarget)
		{
			// Check local file MD5 if download again
			if (bIsUpdAgain)
			{
					
				string localFileMD5 = this->getLocalFileMD5(sPath.c_str());
					
				if (localFileMD5 == sMd5)
				{
					CCLOG("***Time to update the previous execution has updated the file=%s",sPath.c_str());
					bTarget = false;
				}
				CCLOG("***Local file [%s] Target?=%s",sPath.c_str(), bTarget?"YES":"NO");
			}
			// Add to download list
			if (bTarget)
			{
				m_nDownLoadSize += info.fileSize;
				m_nDownLoadFileNum++;
				m_vNeed2DownLoadFileUrl.push_back(info.serverUrl);
				m_vNeed2DownLoadFileStorgePath.push_back(info.storgePath);
			}
		}
		mdLocalTempTable.insert(pair<string, string>(sPath, sMd5));
	} 

	mdLocalTable.swap(mdLocalTempTable);

	CCLog("---------- Need to download file count = %d , total size = %d",m_nDownLoadFileNum, m_nDownLoadSize);

	if (m_nDownLoadFileNum > 0)
	{
			
		m_pAssetsManager->setDownLoadFileNum(m_nDownLoadFileNum);//Set download file number

		m_pAssetsManager->setDownLoadSize(m_nDownLoadSize);//Set the total number of bytes	

		m_pAssetsManager->downLoadResource(m_vNeed2DownLoadFileUrl, m_vNeed2DownLoadFileStorgePath);

		this->setUpdStartFlag();			
	}
	else if (m_nDownLoadFileNum == 0) //No update file
	{

		prepareEnterGame();
		
	}

	
}

void NetUpdateLayer::onError(int errorCode)
{

	if (errorCode == NewAssetsManager::kNoNewVersion)
	{
		runAction(CCSequence::createWithTwoActions(CCDelayTime::create(1.0f), CCCallFuncO::create(this, callfuncO_selector(NetUpdateLayer::enter),NULL)));	
	}
	else if (errorCode == NewAssetsManager::kNetwork)
	{
		string tips = getString("network_error");
		
		m_pNetWorkTips->setVisible(false);
		
		m_barBg->setVisible(false);
	
		if (m_pFileProgressLabel != NULL)
		{
		   m_pFileProgressLabel->setVisible(false);
		}
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
		if (m_pAssetsManager->resourceIsDownLoading)
		{
			DialogConfirm::Instance()->show(tips,this);
     
			DialogConfirm::Instance()->setConfirmCallback(callfuncO_selector(NetUpdateLayer::reDownloadResource),this);
		}
		else if(m_pAssetsManager->versionIsDownLoading)
		{
			DialogConfirm::Instance()->show(tips,this);
        
			DialogConfirm::Instance()->setConfirmCallback(callfuncO_selector(NetUpdateLayer::checkVersion), this);
		}
		else if(m_pAssetsManager->serverListIsDownLoading){
            
			DialogConfirm::Instance()->show(tips,this);
        
			DialogConfirm::Instance()->setConfirmCallback(callfuncO_selector(NetUpdateLayer::prepareToDownloadServerList), this);
		}


	#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		if (m_pAssetsManager->resourceIsDownLoading)
		{
			DialogInquire::Instance()->show(tips,this);
        
			DialogInquire::Instance()->setConfirmCallback(callfuncO_selector(NetUpdateLayer::reDownloadResource), this);
        
			DialogInquire::Instance()->setCancelCallback(callfuncO_selector(NetUpdateLayer::ExitGame), this);
		}
		else if(m_pAssetsManager->versionIsDownLoading)
		{
		  DialogInquire::Instance()->show(tips,this);
      
		  DialogInquire::Instance()->setConfirmCallback(callfuncO_selector(NetUpdateLayer::checkVersion), this);
      
		  DialogInquire::Instance()->setCancelCallback(callfuncO_selector(NetUpdateLayer::ExitGame), this);
		}
		else if(m_pAssetsManager->serverListIsDownLoading)
		{
		  
		  DialogInquire::Instance()->show(tips,this);
      
		  DialogInquire::Instance()->setConfirmCallback(callfuncO_selector(NetUpdateLayer::prepareToDownloadServerList), this);
      
		  DialogInquire::Instance()->setCancelCallback(callfuncO_selector(NetUpdateLayer::ExitGame), this);
		}
	#endif

	}
	
	
}

bool NetUpdateLayer::updateLocalCsvFile()
{
	
	bool bExist = isLocalFileExist(LOCAL_UPDATE_FILE_LIST);
	
	if (!bExist)
	{
		
		createEmptyCsv(LOCAL_UPDATE_FILE_LIST);
	}

	if (mdLocalTable.size() > 0)
	{
		

		string filename = CCFileUtils::sharedFileUtils()->fullPathForFilename(LOCAL_UPDATE_FILE_LIST);

		fstream outfile;
		
		outfile.open(filename.c_str(), ios::out | ios::trunc);
		
		if(!outfile)
		{
			return false;
		}
			
		string fPath = "";
		
		string sMd5 = "";		
		
		for (map<string, string>::iterator it = mdLocalTable.begin(); it != mdLocalTable.end(); it++)
		{
			fPath = it->first;
			
			sMd5 = it->second;
			
			outfile << fPath << "," << sMd5 << ",0" << endl;
		}
		outfile.close();
		
		return true;
	}

	return false;
}

bool NetUpdateLayer::createLocalCsvFile()
{
	const char* sPath = LOCAL_UPDATE_FILE_LIST;

    #if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	  bool bExist =CCFileUtils::sharedFileUtils()->isFileExist(CCFileUtils::sharedFileUtils()->getWritablePath().append("sanguoRes\\").append(sPath));
	#else
       bool bExist =CCFileUtils::sharedFileUtils()->isFileExist(CCFileUtils::sharedFileUtils()->getWritablePath().append(sPath));
    #endif
	
	if (!bExist) 
	{
		CCLog("local_md5.csv does not exist. Copy Package's file to writable path.");

		string strAssetsCsvPath = CCFileUtils::sharedFileUtils()->fullPathForFilename("local_md5.csv");
		
		CCLOG("Package's MD5 CSV path = %s", strAssetsCsvPath.c_str());

		string strLocalCsvPath;

		#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
				strLocalCsvPath = CCFileUtils::sharedFileUtils()->getWritablePath().append("sanguoRes\\").append(sPath);
		#else
				strLocalCsvPath = CCFileUtils::sharedFileUtils()->getWritablePath().append(sPath);
		#endif

		CCLOG("Local MD5 CSV path = %s", strLocalCsvPath.c_str());
		
		// Open loacl CSV file
		FILE *fp = fopen(strLocalCsvPath.c_str(),"w+");

		if (!fp)
		{
			CCLog("ERROR : Open Local MD5 CSV file %s failed!", strLocalCsvPath.c_str());

			return false;
		}
		// Open Package CSV file and read data from it
		unsigned long len = 0;

		unsigned char *data = NULL;

 		data = CCFileUtils::sharedFileUtils()->getFileData(strAssetsCsvPath.c_str(),"rb",&len);

		if (!data)
		{
			CCLog("ERROR : Open Package's MD5 CSV file %s failed!", strAssetsCsvPath.c_str());
			return false;
		}
		
		fwrite(data,sizeof(char),len,fp);

		fclose(fp);
		
		if (!data)
		{
			delete []data;

			data = NULL;
		}

		CCLOG("Local MD5 CSV copy completed.");
	}
	else
	{
		CCLOG("local_md5.csv is already exist.");
	}

	return true;
}

void NetUpdateLayer::readLocalCsvFile()
{
	const char* sPath = LOCAL_UPDATE_FILE_LIST;
	
	string localMd5Path;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	localMd5Path = CCFileUtils::sharedFileUtils()->getWritablePath().append("sanguoRes\\").append(sPath);
#else
	localMd5Path = CCFileUtils::sharedFileUtils()->getWritablePath().append(sPath);
#endif

	bool bSucc = CsvUtil::sharedCsvUtil()->loadFile(localMd5Path.c_str());
	
	if (bSucc)
	{
		int row = CsvUtil::sharedCsvUtil()->getFileRowNum(localMd5Path.c_str());
		
		CCLOG("Local MD5 CSV = %s, rows = %d", localMd5Path.c_str(),row);
		
		if (row > 0)
		{
			string fileName;
			
			string strMd5;
			
			CsvUtil *csvUtil = CsvUtil::sharedCsvUtil();
			
			for (int i = 0; i < row; i++)
			{
				fileName = csvUtil->get(i, 0, localMd5Path.c_str()); 

				strMd5 = csvUtil->get(i, 1, localMd5Path.c_str());

				mdLocalTable.insert(pair<string, string>(fileName, strMd5));
			}
		}
	}
	else
	{
		CCLog("ERROR : Local MD5 CSV = %s, Read failed!", localMd5Path.c_str());
	}
}

bool NetUpdateLayer::readServerCsvFile(string strCsv) 
{
	mdServerTable.clear();

	bool bExist = CsvUtil::sharedCsvUtil()->loadFile(strCsv.c_str());
	
	if(!bExist)
	{
		createEmptyCsv(strCsv);
		return false;
	}
    
	int row = CsvUtil::sharedCsvUtil()->getFileRowNum(strCsv.c_str());
	
	CCLOG("Server List files = %s, rows = %d",strCsv.c_str(), row);
 
	if (row > 0)
	{
		string fileName ="";
		
		string strMd5 = "";
		
		string strUrl = "";
		
		int fileSize = 0;

		string sRelativePath = "";

		CsvUtil *csvUtil = CsvUtil::sharedCsvUtil();

		for (int i=0; i < row; i++)
		{
			fileName = csvUtil->get(i,   0, strCsv.c_str());
			
			strMd5   = csvUtil->get(i,   1, strCsv.c_str());
			
			strUrl   = csvUtil->get(i,   2, strCsv.c_str());
			
			fileSize = csvUtil->getInt(i,3, strCsv.c_str());

			ServerFileInfo info;
			
			info.md5 = strMd5;
			
			info.serverUrl = strUrl;
			
			info.fileSize = fileSize;

			
			int nIndex = fileName.find_last_of('/');  

			if(nIndex > 0)
			{
				sRelativePath = fileName.substr(0, nIndex);
			}

			info.storgePath = sRelativePath;

			mdServerTable.insert(pair<string, ServerFileInfo>(fileName, info)); 
		} 
	}

	return true;
}

bool NetUpdateLayer::createEmptyCsv(string strCsv)
{
	string sWritablePath  = CCFileUtils::sharedFileUtils()->getWritablePath();
	string filename;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) 
	filename = sWritablePath + "sanguoRes\\" + strCsv;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
	filename = sWritablePath + strCsv;
#endif 

	fstream outfile;
	outfile.open(filename.c_str(), ios::out);

	if(outfile.is_open())
	{
		outfile.close();
	}

	return true;
}

bool NetUpdateLayer::isLocalFileExist(const char* pFileName)
{
	if( !pFileName ) 
	{
		return false;
	}
    string filePath = CCFileUtils::sharedFileUtils()->getWritablePath() + pFileName;
 
    FILE *fp = fopen(filePath.c_str(),"r");
    if(fp)
    {
        fclose(fp);
        return true;
    }
    return false;
}

void NetUpdateLayer::makeDirOrFile(std::string dirPath)
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
			_mkdir(subdir.c_str());
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

const char * NetUpdateLayer::getString(const char* en)
{
	if (!mStringDict)
	{
		return en;
	}
	if(!mStringDict->objectForKey(en))
	{ 
		return en;
	}
	else
	{
		return ((CCString*)mStringDict->objectForKey(en))->m_sString.c_str();
	}
}

void NetUpdateLayer::keyBackClicked()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
    string str = getString("exit_game");
	DialogInquire::Instance()->show(str,this);
	DialogInquire::Instance()->setConfirmCallback(callfuncO_selector(NetUpdateLayer::ExitGame), this);
#else
	DialogInquire::Instance()->show("exit_game",this);
	DialogInquire::Instance()->setConfirmCallback(callfuncO_selector(NetUpdateLayer::ExitGame), this);
#endif	
}

int NetUpdateLayer::verCompare(std::string localVersion,std::string resVersion)
{
	int ret = 0;

	CCArray * localVersionArr = StringUtil::sharedStrUtil()->split(localVersion.c_str(), ".");

	CCArray * resVersionArr = StringUtil::sharedStrUtil()->split(resVersion.c_str(), ".");

	int count1 =  localVersionArr->count();

	int count2 =  resVersionArr->count();

	int count = count1 < count2 ? count1:count2;

	CCString *char1 = NULL;

	CCString *char2 = NULL;

	for (int i = 0;i < count;i++)
	{
		char1 = (CCString *)localVersionArr->objectAtIndex(i);
		char2 = (CCString *)resVersionArr->objectAtIndex(i);
		if (char1->intValue() == char2->intValue())
		{
			continue;
		}
		else 
		{
			ret = (char1->intValue()) - (char2->intValue());
			break;
		}
	}

	return ret;
}

string NetUpdateLayer::getLocalFileMD5(string fileName)
{
	string retMD5 = "";

	MD5 md5;

	string rPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(fileName.c_str());

#if(CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)

	ifstream in(rPath.c_str(),std::ios::binary);
	md5.update(in);
	retMD5 = md5.toString();

#else

	unsigned long size = 0;
	
	char* pData = 0;
	
	pData = (char*)CCFileUtils::sharedFileUtils()->getFileData(rPath.c_str(), "rb", &size);

	if (pData == NULL) 
	{
		CCLog("ERROR : Read local file error when MD5. file=[%s]",rPath.c_str());
	}
	else
	{
		string in(pData);

		md5.update(pData,size);

		retMD5 = md5.toString();

		if (size >0 && pData)
		{
			 delete[] pData;
		}
	}

#endif
	
	return retMD5;
}

/*
 *Delete the specified subdirectories and files
 *
 */
void NetUpdateLayer::cleanDir(const char *path)
{
#if CC_TARGET_PLATFORM != CC_PLATFORM_WIN32
	
	DIR *dp;
	
	struct dirent *entry;
	
	struct stat statbuf;
	
	char sub_path[PATH_MAX];
	
	if((dp = opendir(path)) == NULL)
	{
		CCLog("ERROR : Clean directory failed. DIR=[%s]", path);
		return;
	}
	
	while ((entry = readdir(dp)) != NULL)
	{
		
		if(strcmp(".", entry->d_name) == 0 || strcmp("..", entry->d_name) == 0)
		{
			continue;
		}
		
		strcpy(sub_path, path);

		if (sub_path[strlen(sub_path) - 1] != '/')
		{
			strcat(sub_path, "/");
		}
		strcat(sub_path, entry->d_name);
		
		lstat(sub_path, &statbuf);
		
		if(S_ISDIR(statbuf.st_mode))
		{	
			cleanDir(sub_path);
			
			rmdir(sub_path);
		}
		else
		{
			remove(sub_path);
		}
	}
	closedir(dp);
#endif
}

void NetUpdateLayer::setUpdStartFlag()
{
	CCUserDefault::sharedUserDefault()->setStringForKey("update_status","1");
	CCUserDefault::sharedUserDefault()->flush();
}

void NetUpdateLayer::setUpdEndFlag()
{
	CCUserDefault::sharedUserDefault()->setStringForKey("update_status","0");
	CCUserDefault::sharedUserDefault()->flush();
}

bool NetUpdateLayer::isUpdating()
{
	bool ret = false;
	
	string updateStatus = CCUserDefault::sharedUserDefault()->getStringForKey("update_status");

	if (updateStatus.length() == 0)
	{
		ret = false;
	}		
	else if (updateStatus == "1")
	{
		ret = true;
	}

	return ret;
}
void NetUpdateLayer::reDownloadResource(cocos2d::CCObject *pSender){
  if(m_pAssetsManager)
  {
   if(!personAction)
	{
		personAction=CCRepeatForever::create(AnimatePacker::Instance()->getAnimate("loading_run"));
		m_pLoadingRenAnim->runAction(personAction);
	}
	if(!progressAction)
	{
		progressAction=CCRepeatForever::create(AnimatePacker::Instance()->getAnimate("jindutiao"));
		m_pLoadingAnim->runAction(progressAction);
	} 
    m_pFileProgressLabel->setVisible(true);
	
	m_pAssetsManager->setLastDownloadedSize(0);
	
	m_pProgressLabel->setString("");

	m_pNetWorkTips->setString("");
	
	m_pUpdateBar->setVisible(true);
	
	m_barBg->setVisible(true);
	
	m_pLoadingAnim->setVisible(true);

	m_pLoadingRenAnim->setVisible(true);

    m_pAssetsManager->downLoadResource();
  }
}
void NetUpdateLayer::prepareToDownloadServerList(CCObject *pSender)
{
	sendMessage(ASSETSMANAGER_MESSAGE_PREPARE_DOWNLOAD_SERVER_LIST,NewAssetsManager::kDownloadServerList);
}
	
void NetUpdateLayer::prepareToDownloadServerList()
{
	
	m_pProgressLabel->setString("");

	if(!personAction)
	{
		personAction=CCRepeatForever::create(AnimatePacker::Instance()->getAnimate("loading_run"));
		m_pLoadingRenAnim->runAction(personAction);
	}
	if(!progressAction)
	{
		progressAction=CCRepeatForever::create(AnimatePacker::Instance()->getAnimate("jindutiao"));
		m_pLoadingAnim->runAction(progressAction);
	}

	m_pNetWorkTips->setString("");
	
	m_pUpdateBar->setVisible(true);
	
	m_barBg->setVisible(true);
	
	m_pLoadingAnim->setVisible(true);

	m_pLoadingRenAnim->setVisible(true);
   
	createLocalCsvFile();
	
	readLocalCsvFile();

	m_pAssetsManager->downLoadServerUpdateList();

	m_bisUpdateLblClicked = true;
}

void NetUpdateLayer::sendMessage(int what,int code)
{
	if(m_pAssetsManager)
	{
		NewAssetsManager::Message *msg = new NewAssetsManager::Message();
		msg->what = what;
		NormalMessage *errorMessage = new NormalMessage();
		errorMessage->manager = m_pAssetsManager;
		errorMessage->code =code; 
		msg->obj = errorMessage;
		m_pAssetsManager->_schedule->sendMessage(msg);
	}
}
void NetUpdateLayer::prepareEnterGame()
{
	onProgress(100);
	updateLocalCsvFile();
	this->setUpdEndFlag();
	std::string newVersion = m_pAssetsManager->getNewVersionCode();
	CCUserDefault::sharedUserDefault()->setStringForKey("current-version-code",newVersion.c_str());
	CCUserDefault::sharedUserDefault()->flush();
	runAction(CCSequence::createWithTwoActions(CCDelayTime::create(0.01f), CCCallFuncO::create(this, callfuncO_selector(NetUpdateLayer::enter),NULL)));	
}
NS_GAME_FRM_END
