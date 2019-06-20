/**
    Copyright 2019, Felspar Co Ltd. <https://support.felspar.com/>

    Distributed under the Boost Software License, Version 1.0.
    See <http://www.boost.org/LICENSE_1_0.txt>
*/


#pragma once

#ifndef fost_swift_webserver_hpp
#define fost_swift_webserver_hpp


#ifdef __cplusplus
extern "C" {
#endif


/**
 * Starts the web server. The configuration works exactly like the
 * `fost-webserver`. Everything must be configured into the settings
 * database so that the server knows what to do.
 *
 * The port number is fixed and hard coded as 2555.
 */
void webserver_start();


#ifdef __cplusplus
}
#endif


#endif
