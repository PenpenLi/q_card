/********************************************************************
	created:	2014/01/20
	created:	20:1:2014   9:52
	file base:	NetRingBuff
	file ext:	h
	author:		Kevin
	
*********************************************************************/

#ifndef _H_NETRINGBUFF_H_  
#define _H_NETRINGBUFF_H_  


#include "Common/CommonDefine.h"
#include "NetCommon.h"
#include "NetManager.h"

NS_GAME_FRM_BEGIN

class NetRingBuff
{
private:
  char m_buff[MAX_BUFF_SIZE];
  size_t m_begin;
  size_t m_end;
  size_t m_size;

  // for parsing
  NetHeaderData m_tempHeader;
  bool m_pickedHeader;

public:

  NetRingBuff():m_begin(0),m_end(0),m_size(0){
    memset(this,0,sizeof(NetRingBuff));
  }

  void fill(char* pSrc,size_t len)
  {
    assert(len != 0);
    assert(MAX_BUFF_SIZE - m_size >= len);

    if(m_end + len > MAX_BUFF_SIZE)
    {
      assert(m_end < MAX_BUFF_SIZE);
      size_t count = MAX_BUFF_SIZE - m_end;
      memcpy(m_buff + m_end,pSrc,count);
      assert(len > count);
      memcpy(m_buff,pSrc + count,len - count);
    }else
    {
      memcpy(m_buff + m_end,pSrc,len);
    }
    m_size += len;
    m_end = m_begin + m_size;
    m_end = (m_end >= MAX_BUFF_SIZE ? m_end - MAX_BUFF_SIZE : m_end);
  }

  void read(char* pDst,size_t len)
  {
    assert(len != 0);
    assert(m_size >= len);
    if(m_begin + len > MAX_BUFF_SIZE)
    {
      size_t count = MAX_BUFF_SIZE - m_begin;
      memcpy(pDst,m_buff + m_begin,count);
      assert(len > count);
      memcpy(pDst + count,m_buff,len - count);
    }else
    {
      memcpy(pDst,m_buff + m_begin,len);
    }
    assert(m_size >= len);
    m_size -= len;
    m_begin += len;
    m_begin = (m_begin >= MAX_BUFF_SIZE ? m_begin - MAX_BUFF_SIZE : m_begin);
  }

  bool hasHeader() const
  {
    if(m_size < kHeaderSize) return false;
    return true;
  }

  void pickHeader() 
  {
    read((char*)&m_tempHeader,kHeaderSize);
    m_pickedHeader = true;
  }

  bool hasResponse()
  {
    if(!m_pickedHeader)
    {
      if(!hasHeader()) return false;
      pickHeader();
    }
    if(m_size < m_tempHeader.size) return false;
    return true;
  }

  void pickResponse(NetNotifyEnum action,PtrNetNotify notify)
  {
    assert(m_pickedHeader);
    notify->action = action;
    notify->msgId = m_tempHeader.type;
    if(m_tempHeader.size != 0)
    {
      // pkg body has data
      char* buff = new char[m_tempHeader.size + 1];
      read(buff,m_tempHeader.size);
      buff[m_tempHeader.size] = 0;
      notify->data.assign(buff,m_tempHeader.size);
    }
    m_pickedHeader = false;
  }
};

/*
char buf[6] begin 2,end 2+3 = 5,size 3
[0][0][1][1][1][0]
push src 3
[2][2][1][1][1][2] begin 2,end 2
read 4
[2][2][0][0][0][0] begin 0,end 2

char buf[6] begin 2,end 2+1 = 3,size 1
[0][0][1][0][0][0]
push src 3
[0][0][1][2][2][2] begin 2,end 0,size 4
read 4
[0][0][0][0][0][0] begin 0,end 0
*/




NS_GAME_FRM_END //namespace


#endif //_H_NETRINGBUFF_H_  