/**
    Copyright 2019, Felspar Co Ltd. <https://support.felspar.com/>

    Distributed under the Boost Software License, Version 1.0.
    See <http://www.boost.org/LICENSE_1_0.txt>
*/


#include <fost/swift/webserver.h>
#include <fost/internet>
#include <fost/http.server.hpp>
#include <fost/urlhandler>


namespace {
    std::thread g_server;
}


extern "C" void webserver_start() {
    /// Start the web server and set the termination condition
    g_server = std::thread{[]() {
        fostlib::http::server server(fostlib::host(0), 2555);
        server(fostlib::urlhandler::service, []() -> bool {
            return false;
        });
    }};
}
