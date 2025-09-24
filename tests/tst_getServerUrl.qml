import QtQuick 2.15
import QtTest 1.3
import "../contents/js/utils.js" as Utils

TestCase {
    name: "GetServerUrlTests"

    function test_default_base() {
        compare(Utils.getServerUrl(undefined, 'tags'), 'http://127.0.0.1:11434/api/tags');
    }

    function test_custom_base() {
        compare(Utils.getServerUrl('http://example.com', 'models'), 'http://example.com/api/models');
    }

    function test_trailing_slash_base() {
        compare(Utils.getServerUrl('http://example.com/', 'models'), 'http://example.com/api/models');
    }

    function test_empty_endpoint() {
        compare(Utils.getServerUrl('http://example.com', ''), 'http://example.com/api/');
    }

    function test_endpoint_leading_slash() {
        compare(Utils.getServerUrl('http://example.com', '/models'), 'http://example.com/api/models');
    }

    function test_undefined_endpoint() {
        // undefined should be treated like an empty endpoint
        compare(Utils.getServerUrl('http://example.com', undefined), 'http://example.com/api/');
    }

    function test_null_endpoint() {
        // null should be treated like an empty endpoint
        compare(Utils.getServerUrl('http://example.com', null), 'http://example.com/api/');
    }
}
