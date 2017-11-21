/********************************************************************
	created:	2014/01/17
	created:	17:1:2014   11:15
	file base:	NetCommon
	file ext:	h
	author:		Kevin
	
*********************************************************************/

#ifndef _H_NETCOMMON_H_  
#define _H_NETCOMMON_H_  

#include "Common/CommonDefine.h"
#include "PassiveSocket.h"
#include <string>
#include <memory>
#include <cassert>
#ifdef COCOS2D
#include "cocos2d.h"
#define LOG CCLOG
#endif

NS_GAME_FRM_BEGIN


enum {
    MAX_BUFF_SIZE = 256 * 1024,
    MAX_RECV_BUFF_SIZE = 1024
};

enum {
    kNetStateNone,
    kNetStateConnectingLoginServer,
    kNetStateConnectedLoginServer,
    kNetStateConnectingGameServer,
    kNetStateConnectedGameServer,
    kNetStateDisconnectingFromGameServer,
    kNetStateDisconnectedFromGameServer,
};

typedef enum tagNetActionEnum{
    kNetActionNone = 0,
    kNetActionToConnectLoginServer = 200001,
    kNetActionToConnectGameServer,
    kNetActionToRequest,
    kNetActionToDisconnect
} NetActionEnum;

typedef enum tagNetNotifyEnum{
    kNetNotifyNone = 0,
    kNetNotifyConnectingLoginServer = 100001,
    kNetNotifyConnectingLoginServerFailed,
    kNetNotifyConnectedLoginServer,
    kNetNotifyConnectingGameServer,
    kNetNotifyConnectingGameServerFailed,
    kNetNotifyConnectedGameServer,
    kNetNotifyDisconnecting,
    kNetNotifyDisconnect,
    kNetNotifyOnResponse,
} NetNotifyEnum;

#pragma pack(1)
typedef struct tagNetHeaderData
{
    char p1;
    int size;
    char p2;
    int type;
    char p3;
    int id;

} NetHeaderData;
#pragma pack()

enum
{
    kHeaderP1 = 13,
    kHeaderP2 = 21,
    kHeaderP3 = 29,
};

enum {
    kHeaderSize = 15
};

typedef struct tagNetThreadData
{
    void* pInstance;
    
} NetThreadData;

typedef struct tagNetConfig
{
    std::string serverAddr;
    short int port;
} NetConfig;



class NetAction
{
public:
    NetActionEnum action;
    int msgId;
    int userId;
    char* pData;
    int szBody;
    int szPkg;

    //NetAction():action(kNetActionNone),msgId(0),userId(0),pData(NULL),size(0){}

    NetAction(NetActionEnum _action):action(_action),msgId(0),userId(0),pData(NULL),szBody(0),szPkg(0){}

    NetAction(NetActionEnum _action,int _msgId,int _userId,const char* _pData,int _szBody):action(_action),msgId(_msgId),userId(_userId),pData(NULL),szBody(_szBody)
    {
        assert(pData == NULL);
        szPkg = szBody + kHeaderSize;
        pData = new char[szPkg + 1];
        // pack header
        NetHeaderData header;
        memset(&header,0,sizeof(header));
        header.type = msgId;
        header.id = userId;
        header.size = szBody; // body size
        header.p1 = kHeaderP1;
        header.p2 = kHeaderP2;
        header.p3 = kHeaderP3;
        memcpy(pData,&header,kHeaderSize);
        // copy body data
        memcpy(pData + kHeaderSize,_pData,szBody);
        pData[szPkg] = 0;
    }

    ~NetAction(){ delete[] pData;}
};

class NetNotify
{
public:
    NetNotifyEnum action;
    int msgId;
    std::string data;

    NetNotify():action(kNetNotifyNone),msgId(0){}

    NetNotify(NetNotifyEnum _action):action(_action),msgId(0){}

    NetNotify(NetNotifyEnum _action,int _msgId,const char* pData):action(_action),msgId(_msgId),data(pData){}

    NetNotify(NetNotifyEnum _action,int _msgId,const std::string& _data):action(_action),msgId(_msgId),data(_data){}
};

typedef std::shared_ptr<NetAction> PtrNetAction;

typedef std::shared_ptr<NetNotify> PtrNetNotify;

class NetPkg
{
public:
    std::string data;
    size_t size;
    int msgId;
    int userId;
    NetPkg():size(0),msgId(0),userId(0){}
    NetPkg(int _msgId,int _userId,const std::string& _data):msgId(_msgId),userId(_userId),data(_data){ size = data.size(); }
};

NS_GAME_FRM_END //namespace


#endif //_H_NETCOMMON_H_  