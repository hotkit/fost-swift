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

    file_loader_callback file_loader;
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


extern "C" void register_file_loader(file_loader_callback fp) {
    file_loader = fp;
}


namespace {


    /**
     * Returns data using the callback, or an empty buffer if not found.
     */
    auto assetdata(fostlib::string path) {
        /// TODO Change to unique with the freeing function later on
        NSData *file_bytes = file_loader(path.shrink_to_fit());
        if(file_bytes) {
            std::size_t const length = [file_bytes length];
            unsigned char const *data = reinterpret_cast<unsigned char const *>([file_bytes bytes]);
            f5::shared_buffer<unsigned char> buffer{length};
            std::copy(data, data + length, buffer.begin());
            return buffer;
        } else {
            return f5::shared_buffer<unsigned char>();
        }
    }


    /**
     * Returns the correct response for the provided data.
     */
    std::pair<boost::shared_ptr<fostlib::mime>, int> assetresponse(
            f5::shared_buffer<unsigned char> bytes,
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
                                            "<body><h1>404</h1><pre>" + path + "</pre></body></html>")),
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
            return assetresponse(assetdata(path), path);
        }
    } c_assets_view;


}
