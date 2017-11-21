#ifndef  _NETUPDATELAYER_
#define  _NETUPDATELAYER_

#include "cocos2d.h"
#include "cocos-ext.h"
#include "Common/CommonDefine.h"
#include "NewAssetsManager.h"
#include <string>
#include <map>

USING_NS_CC;

#define UPDATE_BTN_TAG 123
#define ENTRY_BTN_TAG 567

using namespace std;

struct ServerFileInfo
{
	string md5;        
	string serverUrl;   
	string storgePath;  
	int fileSize;       
};

NS_GAME_FRM_BEGIN

class NetUpdateLayer : public cocos2d::CCLayerColor, public NewAssetsManagerDelegateProtocol
{
public:

	NetUpdateLayer();
	
	virtual ~NetUpdateLayer();

	static NetUpdateLayer* createNetUpdateLayer();

	void enter(cocos2d::CCObject *pSender);
	
	void reset(cocos2d::CCObject *pSender);
	
	void update(cocos2d::CCObject *pSender);

	CC_SYNTHESIZE(int,m_nDownLoadSize,DownLoadSize);
	
	CC_SYNTHESIZE(int,m_nDownLoadFileNum,DownLoadFileNum);
	
	CC_SYNTHESIZE(std::vector<std::string>,m_vNeed2DownLoadFileUrl,Need2DownLoadFileUrl);
	
	CC_SYNTHESIZE(std::vector<std::string>,m_vNeed2DownLoadFileStorgePath,Need2DownLoadFileStorgePath);

	virtual void onError(int errorCode);
	
	virtual void onProgress(int percent);
	
	virtual void onServerListDownLoadSuccess();
	
	virtual void onSuccess(int errorCode);
	
	bool createLocalCsvFile();
	
	void readLocalCsvFile();

	void prepareToDownloadServerList(CCObject *pSender);
	
	void prepareToDownloadServerList();

	void sendMessage(int what,int code);

	void prepareEnterGame();

private:

	virtual bool init();

	NewAssetsManager* getAssetsManager();

	void createDownloadDir();
	
	bool readServerCsvFile(string strCsv);

	bool createEmptyCsv(string strCsv);

	bool updateLocalCsvFile();

	void showUpdateUI(bool alertPop);

	void updateBar(int cur);

	void goUpdateCallBack(cocos2d::CCObject *pSender);
    
    void checkVersion(cocos2d::CCObject *pSender);
    
    void reDownloadResource(cocos2d::CCObject *pSender);

	void ExitGame(cocos2d::CCObject *pSender);
	
void entryWebAndExitGame(cocos2d::CCObject *pSender);
	
	void entryGame();
	
	void entryGameCallBack(cocos2d::CCObject *pSender);

	bool isLocalFileExist(const char* pFileName);
	
	void makeDirOrFile(std::string dirPath);

	void keyBackClicked();

	NewAssetsManager *m_pAssetsManager;

	cocos2d::CCMenuItemFont *m_pLblEnter; //进入标签
	
	cocos2d::CCMenuItemFont *m_pLblReset; //重置标签
	
	cocos2d::CCMenuItemFont *m_pLblUpdate;//更新标签

	cocos2d::CCLabelBMFont *m_pProgressLabel; 

	cocos2d::CCLabelBMFont *m_pFileProgressLabel;

	cocos2d::CCLabelTTF    *m_pNetWorkTips;

	string m_strPathToSave;		   //文件保存路径

	bool m_bisUpdateLblClicked;   //更新标签是否按过

	map<string, string> mdLocalTable; //md5本地文件MD表 map<string filePath, string md5>
	
	map<string, ServerFileInfo> mdServerTable;//服务器的MD文件更新列表 
	

	CCSprite *m_pUpdateBar;
	
	CCSprite *m_pLoadingAnim;
	
	CCSprite *m_pLoadingRenAnim;
    
	CCSprite *m_barBg;

	cocos2d::CCRepeatForever *progressAction;

	cocos2d::CCRepeatForever *personAction;

	cocos2d::CCDictionary *mStringDict;
	
	const char * getString(const char* en);

	int verCompare(string localVersion,string resVersion);

	string getLocalFileMD5(string fileName);

	void cleanDir(const char* path);

	// 设定下载的状态，便于下载中断后依靠本地MD5计算来减少下载量
	void setUpdStartFlag();
	
	void setUpdEndFlag();
	
	bool isUpdating();
};

NS_GAME_FRM_END

#endif
