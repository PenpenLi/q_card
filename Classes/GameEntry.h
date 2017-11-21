#ifndef UCENTRY_H
#define UCENTRY_H

#include "cocos2d.h"
#include "Common/CommonDefine.h"
#include "SimpleAudioEngine.h"
#include "time.h"

USING_NS_CC;


typedef struct
{
    int year;
    int mon;
    int day;
    int hour;
    int min;
    int sec;
}dateInfo;

class GameEntry:public CCObject
//class GameEntry    
{
public:
    static GameEntry *instance();
    void runGame();
    void runResUpdate();    
    const char *getUserName();
    const char *getPassword();
    const char *getChannel();
    const char *getSign();
    bool isUcPlatform();
    void gotoLoginWin();
    void exitGame();
    
    void setKeypadForUser(bool enable);
    bool isKeypadForUser();
    dateInfo GetDayTime(long timeOffset);
    
private:
    bool m_isKeypadForUser;
    std::string ucUrl;
    std::string m_userName;
    std::string m_password;
    std::string m_channel;
    std::string m_sign;    
    int m_ucLoginState; // 0 : none;  1: get account ok;  2: will exit game
};


#endif

