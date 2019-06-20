/**
    Copyright 2019, Felspar Co Ltd. <https://support.felspar.com/>

    Distributed under the Boost Software License, Version 1.0.
    See <http://www.boost.org/LICENSE_1_0.txt>
*/


#pragma once

#ifndef settings_hpp
#define settings_hpp


#ifdef __cplusplus
extern "C" {
#endif


/**
    ## Settings managment
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


#ifdef __cplusplus
}
#endif


#endif
