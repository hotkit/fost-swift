/**
    Copyright 2019 Red Anchor Trading Co. Ltd.

    Distributed under the Boost Software License, Version 1.0.
    See <http://www.boost.org/LICENSE_1_0.txt>
 */



#include <Foundation/Foundation.h>


#ifdef __cplusplus
extern "C" {
#endif


    typedef void (*send_message_callback)(NSString * _Nonnull);
    void register_send_message_callback(send_message_callback _Nonnull);


#ifdef __cplusplus
}
#endif
