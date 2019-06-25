/**
    Copyright 2019, Felspar Co Ltd. <https://support.felspar.com/>

    Distributed under the Boost Software License, Version 1.0.
    See <http://www.boost.org/LICENSE_1_0.txt>
*/


#pragma once

#ifndef fost_swift_webserver_hpp
#define fost_swift_webserver_hpp


#import <Foundation/Foundation.h>


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


/**
 * This is used to register the callback for returning data that has been
 * bundled with the application. It should be set on program start, and
 * must be called before the web server is started with a configuration
 * that makes use of the view.
 *
 * The callback is called with a string that represents the filename to be
 * loaded. The returned NSData may be `NULL` if the file does not exist
 * or otherwise cannot be loaded.
 */
typedef NSData*(*file_loader_callback)(NSString * _Nonnull);
void register_file_loader(file_loader_callback);


#ifdef __cplusplus
}
#endif


#endif
