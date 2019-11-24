/**
    Copyright 2019 Red Anchor Trading Co. Ltd.

    Distributed under the Boost Software License, Version 1.0.
    See <http://www.boost.org/LICENSE_1_0.txt>
 */



#include <fost/swift/messaging.h>
#include <fost/swift/messaging.hpp>

#include <functional>

#include <fost/insert>


namespace {


    std::function<void(NSString *)> g_send_message_callback;


}


void fostlib::display(f5::u8view d) {
    fostlib::json msg;
    insert(msg, "display", d);
    send_message(msg);
}



void fostlib::send_message(fostlib::json payload) {
    g_send_message_callback([NSString stringWithUTF8String:fostlib::json::unparse(payload, false).shrink_to_fit()]);
}


extern "C" void register_send_message_callback(send_message_callback smcb){
    g_send_message_callback = smcb;
    fostlib::display("Messaging callback installed");
}
