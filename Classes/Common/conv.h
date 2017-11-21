
//UNICODE码转为GB2312码
int utf82gb2312(char *inbuf,int inlen,char *outbuf,int outlen);
//GB2312码转为UNICODE码
int gb23122utf8(char *inbuf,size_t inlen,char *outbuf,size_t outlen);
//UTF8码转为UCS2码
int utf82ucs2(char *inbuf,size_t inlen,char *outbuf,size_t outlen);
//UCS2码转为UTF8码
int ucs22utf8(char *inbuf,size_t inlen,char *outbuf,size_t outlen);

int gbk2utf8(char *inbuf, size_t inlen, char* outbuf, size_t outlen);
int utf82gbk(char *inbuf, size_t inlen, char* outbuf, size_t outlen);

int icuuc_init();
int icuuc_uninit();