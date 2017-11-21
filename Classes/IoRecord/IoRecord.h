#ifndef CARRECORD_H
#include "cocos2d.h"

#define FILE_SAVED_AS_JSON

#define JSON_FILE_NAME "CarRecord.json"




class IoRecord
{
public:
	void setBoolForKey(int key, bool val);
	void setIntegerForKey(int key, int val);
	void setFloatForKey(int key, float val);
	void setStringForKey(int key, const std::string &val);

	bool getBoolForKey(int key);
	int getIntegerForKey(int key);
	float getFloatForKey(int key);
	std::string getStringForKey(int key);

	static IoRecord *sharedRecord();

};
#endif

