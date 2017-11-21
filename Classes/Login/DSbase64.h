/*
 * base64.h
 */

#ifndef DS_BASE64_H_
#define DS_BASE64_H_
#include <string>
#include "Common/CommonDefine.h"
NS_GAME_FRM_BEGIN
class Base64 {
public:
	static std::string encode(unsigned char const*, unsigned int len);
	static std::string decode(std::string const& s);
private:
	static std::string base64_chars;
	static bool is_base64(unsigned char c) {
		return (isalnum(c) || (c == '+') || (c == '/'));
	}
};
NS_GAME_FRM_END
#endif /* DS_BASE64_H_ */
