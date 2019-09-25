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
    fostlib::http::server *g_webserver = nullptr;
    file_loader_callback file_loader;
    free_memory_callback free_memory;
}


extern "C" void webserver_start() {
    /// Start the web server and set the termination condition
    webserver_stop();
    g_server = std::thread{[]() {
        try {
            fostlib::http::server server(fostlib::host(0), 2555);
            g_webserver = &server;
            server(fostlib::urlhandler::service, []() -> bool {
                return false;
            });
        } catch (...) {
            /// In case of any exception getting this far we just allow
            /// the thread to quietly exit. Ideally we should log or
            /// something at this point.
        }
    }};
}

extern "C" void webserver_stop() {
    //Stop webserver
    if(g_webserver){
        g_webserver->stop_server();
        g_webserver = nullptr;
        g_server.join();
    };
}


extern "C" void register_file_loader(file_loader_callback fp) {
    file_loader = fp;
}

extern "C" void register_free_memory(free_memory_callback fm) {
    free_memory = fm;
}


namespace {


    /**
     * Returns data using the callback, or an empty buffer if not found.
     */
    auto assetdata(fostlib::string path) {
        /// TODO Change to unique with the freeing function later on

        NSData *file_bytes = file_loader([NSString stringWithUTF8String:path.shrink_to_fit()]);
        
        std::shared_ptr<NSData> bytes_ptr{file_bytes, [](NSData *p) { free_memory(p); }};
        if(file_bytes) {
            std::size_t const length = [file_bytes length];
            std::shared_ptr<unsigned char const> data{bytes_ptr, reinterpret_cast<unsigned char const *>([file_bytes bytes])};
            f5::shared_buffer<unsigned char const> buffer{data, length};
            return buffer;
        } else {
            return f5::shared_buffer<unsigned char const>();
        }
    }


    /**
     * Returns the correct response for the provided data.
     */
    std::pair<boost::shared_ptr<fostlib::mime>, int> assetresponse(
            f5::shared_buffer<unsigned char const> bytes,
            const fostlib::string path
    ) {
        if ( bytes.data() ) {
            return std::make_pair(
                    boost::shared_ptr<fostlib::mime>(
                            new fostlib::binary_body(
                                    bytes.begin(), bytes.end(),
                                    fostlib::mime::mime_headers(),
                                    fostlib::urlhandler::mime_type(
                                            fostlib::coerce<fostlib::fs::path>(path)))),
                    200);
        } else {
            return std::make_pair(
                    boost::shared_ptr<fostlib::mime>(
                            new fostlib::text_body(
                                    "<html><head><title>404</title></head>"
                                                   "<body><h1>404</h1><pre>" + path + "</pre></body></html>", fostlib::mime::mime_headers(), "text/html")),
                    404);
        }
    }


    /**
     * View that assumes a directory structure is available in the to be loaded
     * by the callback. Handles working out the correct path to find the file at.
     */
    const class assets : public fostlib::urlhandler::view {
    public:
        assets()
        : view("fost.ios.assets") {
        }

        std::pair<boost::shared_ptr<fostlib::mime>, int> operator () (
            const fostlib::json &config, const fostlib::string &requested_path,
            fostlib::http::server::request &req,
            const fostlib::host &
        ) const {
            fostlib::string path(
                fostlib::coerce<fostlib::string>(config["asset"]) + requested_path);
            if ( requested_path.empty() || requested_path.endswith("/") ) {
                /// **TODO** This filename should be read from the configuration
                path += "index.html";
            }
            std::pair<boost::shared_ptr<fostlib::mime>, int> asset = assetresponse(assetdata(path), path);
            return asset;
        }
    } c_assets_view;


}
