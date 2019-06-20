/**
    Copyright 2019, Felspar Co Ltd. <https://support.felspar.com/>

    Distributed under the Boost Software License, Version 1.0.
    See <http://www.boost.org/LICENSE_1_0.txt>
*/


#pragma once

#ifndef fost_swift_settings_hpp
#define fost_swift_settings_hpp


#import <Foundation/Foundation.h>


#ifdef __cplusplus
extern "C" {
#endif


/**
    ## Settings management
 */

/**
    Add an integer setting. This should be a 64 bit int, but Macs....
 */
void set_int_setting(
        char const *domain,
        char const *section,
        char const *name,
        int value);

/**
    Add a string setting.
 */
void set_string_setting(
        char const *domain,
        char const *section,
        char const *name,
        char const *value);

/**
    Add a JSON setting. The value will be parsed as JSON and then set.
 */
void set_json_setting(
        char const *domain,
        char const *section,
        char const *name,
        char const *json_value);


/**
    Read a setting. Returns a JSON string, or the specified default if the setting
    doesn't exist.
 */

NSString * _Nonnull read_setting(
    char const *section,
    char const *name,
    char const *default_);


#ifdef __cplusplus
}
#endif


#endif
