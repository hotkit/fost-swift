/**
    Copyright 2019, Felspar Co Ltd. <https://support.felspar.com/>

    Distributed under the Boost Software License, Version 1.0.
    See <http://www.boost.org/LICENSE_1_0.txt>
*/


#include <fost/swift/settings.h>
#include <fost/core>


namespace {


    std::mutex g_mutex;
    auto &g_settings() {
        static std::map<f5::u8string, std::map<f5::u8string, std::unique_ptr<fostlib::setting<fostlib::json>>>> settings;
        return settings;
    }
    auto &g_file_setttings() {
        static std::vector<fostlib::settings> settings;
        return settings;
    }


}


extern "C" void set_int_setting(char const *domain, char const *section, char const *name, int value) {
    std::lock_guard lock{g_mutex};
    f5::u8string d{std::string{domain}}, s{std::string{section}}, n{std::string{name}};
    g_settings()[s][n] = std::make_unique<fostlib::setting<int64_t>>(d, s, n, value);
}


extern "C" void set_string_setting(char const *domain, char const *section, char const *name, char const *value) {
    std::lock_guard lock{g_mutex};
    f5::u8string d{std::string{domain}}, s{std::string{section}}, n{std::string{name}}, v{std::string{value}};
    g_settings()[s][n] = std::make_unique<fostlib::setting<fostlib::string>>(d, s, n, v);
}

//section = webserver , name = MIME types
extern "C" void set_json_setting(char const *domain, char const *section, char const *name, char const *json_value) {
    std::lock_guard lock{g_mutex};
    f5::u8string d{std::string{domain}}, s{std::string{section}}, n{std::string{name}}, jv{std::string{json_value}};
    auto const v{fostlib::json::parse(jv)};
    g_settings()[s][n] = std::make_unique<fostlib::setting<fostlib::json>>(d, s, n, v);
}


extern "C" void set_settings_from_file(char const *domain, char const *file_content) {
    std::lock_guard lock{g_mutex};
    auto parsed = fostlib::json::parse(file_content);
    g_file_setttings().push_back(fostlib::settings(domain, parsed));
}


extern "C" NSString * _Nonnull read_setting(char const *section, char const *name, char const *default_) {
    auto current = fostlib::setting<fostlib::json>::value(section, name, fostlib::null);
    if (current) {
        return [NSString stringWithUTF8String:fostlib::json::unparse(current.value(), true).shrink_to_fit()];
    } else {
        return [NSString stringWithUTF8String:default_];
    }
}
