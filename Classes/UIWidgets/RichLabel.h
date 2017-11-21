#ifndef __RICHLABEL_H__
#define __RICHLABEL_H__

#include "cocos2d.h"

#include "Common/CommonDefine.h"
NS_GAME_FRM_BEGIN
USING_NS_CC;

enum LinkType
{
	LinkItem = 0,
	LinkBeing = 1,
};

class RichLabel;
class RichLabelDelegate
{
public:
	virtual ~RichLabelDelegate() {}
	virtual void linkClick(RichLabel* label, const LinkType linkType, const int targetId) = 0;
};

class RichLabel : public CCLayerRGBA /*public CCTouchDelegate, public CCRGBAProtocol*/
{
public:
	RichLabel() : mLinkDelegate(NULL), mParsed(false), mAllowAppendString(false) {}
	~RichLabel() {}

	static RichLabel * create(const char* string, const char* fontName, const int fontSize, CCSize labelSize, bool appendString = false, bool enableShadow = true);
	bool init(const char* string, const char* fontName, const int fontSize, CCSize labelSize, bool appendString = false, bool enableShadow = true);

	const char * getRichString(); //{ return mString.c_str();}
	const char * getString();
	CCSize getTextSize() { return mContentSize;};
	void setLinkDelegate(RichLabelDelegate * delegate) { mLinkDelegate = delegate; }

	//void setColor(ccColor3B color);
	void appendString(const char* string);

	//virtual void setOpacity(GLubyte opacity);
	//virtual GLubyte getOpacity(void);

	/** Opacity: conforms to CCRGBAProtocol protocol */
	CC_PROPERTY(GLubyte, m_nOpacity, Opacity);
	/** Color: conforms with CCRGBAProtocol protocol */
	CC_PROPERTY_PASS_BY_REF(ccColor3B, m_sColor, Color);
	//void setColor(const ccColor3B& color3);
	//const ccColor3B& getColor();
	// RGBAProtocol
	/** opacity: conforms to CCRGBAProtocol protocol */
	virtual void setOpacityModifyRGB(bool bValue);
	virtual bool isOpacityModifyRGB(void);

	virtual void registerWithTouchDispatcher();

	virtual void onEnter();

	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent) {}
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);

	enum TagType {
		None,
		FontTag, 
		ColorTag,
		LineTag,
		TabTag, 
		EndTag,
	};



private:
	const char *  parse(const char* string, bool recurse = false);
	const char * parseFont(const char* string);
	const char * parseLine(const char* string);
	const char * parseColor(const char* string);
	const char * parseTab(const char* string);
	
	TagType searchTag(const char* string, int & pos);
	void createLabel(const char * string, int length = -1, bool defaultFont = true);
	size_t searchTruncatePos(const char *string, int pixelWidth);
	
	void measureString(const char* string, float &width, float &height);

	CCSize mSize;
	bool mParsed;

	std::string mString;
	std::string mShowString;
	RichLabelDelegate * mLinkDelegate;

	struct Link {
		LinkType linkType;
		int linkTarget;
		CCRect rect;

		Link() {}
		Link(CCRect _rect, LinkType _type, int target) 
		{
			rect = _rect;
			linkType = _type;
			linkTarget = target;
		}
		Link(const Link & link) 
		{
			rect = link.rect;
			linkType = link.linkType;
			linkTarget = link.linkTarget;
		}
	};

	std::vector<Link> mLinkMap;

	std::string mDefaultFontName;
	int mDefaultFontSize;
	int mDefaultColor;

	std::string mFontName;
	int mFontSize;
	int mColor;

	bool mNoneTagFound;
	bool mColorTagFound;
	bool mFontTagFound;
	bool mFontSizeTagFound;
	bool mLinkTagFound;
	bool mEmojTagFound;

	float mLabelOffsetX;
	float mLabelOffsetY;

	Link mLink;

	CCSize mContentSize;

	bool mAllowAppendString;
	bool mEnableShadow;
};

NS_GAME_FRM_END

#endif // __RICHLABEL_H__
