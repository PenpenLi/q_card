/*
 * CAutoLock.h
 *
 *  Created on: Jun 27, 2012
 *      Author: kevin
 */

#ifndef CAUTOLOCK_H_
#define CAUTOLOCK_H_

#include "pthread.h"
#include "Common/CommonDefine.h"
#include "cocos2d.h"


NS_GAME_FRM_BEGIN

typedef pthread_mutex_t CAutoLockMutex;

class CAutoLock
{
private:
    CAutoLockMutex* m_ptLock;
public:
    
    
    CAutoLock(CAutoLockMutex* ptLock)
    {
        m_ptLock = ptLock;

        pthread_mutex_lock(m_ptLock);

    }
    ~CAutoLock()
    {
        pthread_mutex_unlock(m_ptLock);

    }

};

NS_GAME_FRM_END

#endif /* CAUTOLOCK_H_ */
