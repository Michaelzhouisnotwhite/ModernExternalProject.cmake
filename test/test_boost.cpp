#include <boost/asio.hpp>
#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/beast/version.hpp>
#include <boost/bind/bind.hpp>
#include <iostream>
#include "fmt/core.h"
namespace beast = boost::beast;    // from <boost/beast.hpp>
namespace http = beast::http;      // from <boost/beast/http.hpp>
namespace net = boost::asio;       // from <boost/asio.hpp>
using tcp = boost::asio::ip::tcp;  // from <boost/asio/ip/tcp.hpp>
std::string header_string{
    "GET /index.php HTTP/1.1\r\nHost: www.example.com\r\nUser-Agent: Mozilla/5\r\n"};
std::array<char, 100> buf1{
    "GET /index.html HTTP/1.1\r\nHost: www.example.com\r\nUser-Agent: Mozilla/5\r\n"};
std::array<char, 200> buf2{
    "GET /index.html HTTP/1.1\r\nHost: www.example.com\r\nUser-Agent: Mozilla/5\r\nAccept: "
    "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n"};

std::string header_post =
    "POST /post-test HTTP/1.1\r\n"
    "Host: 127.0.0.1:8080\r\n"
    "User-Agent: Apifox/1.0.0 (https://apifox.com)\r\n"
    "Content-Type: application/json\r\n"
    "Accept: */*\r\n"
    "Host: 127.0.0.1:8080\r\n"
    "Connection: keep-alive\r\n"
    "Content-Length: 67\r\n"
    "\r\n"
    "{\"name\":\"Foo\",\"description\":\"The pretender\",\"price\":42.0,\"tax\":3.2}";
using socket_ptr = std::shared_ptr<tcp::socket>;

void request_parser_test() {
    http::request_parser<http::string_body> parser;
    parser.eager(false);
    auto parse_buf = beast::flat_buffer();
    beast::ostream(parse_buf) << std::string(header_post.begin(), header_post.end() - 11);
    beast::error_code ec;
    // parser.put(net::buffer(buf1), ec);

    // toy::print_if_debug(ec.message());
    std::cout << parse_buf.size() << "\n";
    auto put_size = parser.put(net::buffer(parse_buf.data(), parse_buf.size()), ec);

    fmt::println("put size: {}", put_size);
    fmt::println("parser header done: {}", parser.is_header_done());
    fmt::println("parser done: {}", parser.is_done());
    parse_buf.consume(put_size);

    put_size = parser.put(net::buffer(parse_buf.data(), parse_buf.size() - 11), ec);
    fmt::println("parser header done: {}", parser.is_header_done());
    fmt::println("parser done: {}", parser.is_done());
    parse_buf.consume(put_size);
    // for (const auto& map : parser.get()) {
    // toy::print_if_debug("{}: {}", std::string(map.name_string()), std::string(map.value()));
    // }
    beast::ostream(parse_buf) << std::string(header_post.end() - 11, header_post.end());
    put_size = parser.put(net::buffer(parse_buf.data(), parse_buf.size()), ec);
    auto http_res = parser.get();
    auto header = parser.get().base();
    for (const auto& map : header) {
        fmt::println("{}: {}", std::string(map.name_string()), std::string(map.value()));
    }
    auto body = parser.get().body();
    std::cout << body << "\n";
}
void http_parser_test_2() {
    auto mb = beast::multi_buffer{};
}
int main(int args, char* argv[]) {
    request_parser_test();

    return 0;
}