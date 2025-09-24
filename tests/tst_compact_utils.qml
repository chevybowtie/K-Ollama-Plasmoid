import QtQuick 2.15
import QtTest 1.3
import "../contents/js/utils.js" as Utils

TestCase {
    name: "CompactUtilsTests"

    function test_contrast_dark() {
        compare(Utils.getBackgroundColorContrastFromHex('#ffffff'), 'dark');
    }

    function test_contrast_light() {
        compare(Utils.getBackgroundColorContrastFromHex('#000000'), 'light');
    }

    function test_chooseIcon_default() {
        var cfg = { useFilledDarkIcon: false, useFilledLightIcon: false, useOutlinedDarkIcon: false, useOutlinedLightIcon: false, useOutlinedIcon: false };
        compare(Utils.chooseIconPath(cfg, 'dark'), 'assets/logo-filled-dark.svg');
    }

    function test_chooseIcon_outlined() {
        var cfg = { useOutlinedIcon: true };
        compare(Utils.chooseIconPath(cfg, 'light'), 'assets/logo-outlined-light.svg');
    }
}
