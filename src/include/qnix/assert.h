#ifndef QNIX_ASSERT_H
#define QNIX_ASSERT_H
void assertion_failure(char* exp, char* file, char * base,const char * func, int line);

#define assert(exp) \
    if (!(exp)) \
        assertion_failure(#exp, __FILE__, __BASE_FILE__,__func__, __LINE__)

void panic(const char* fmt,...);
#endif //QNIX_ASSERT_H
