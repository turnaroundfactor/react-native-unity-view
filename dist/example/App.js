"use strict";
/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */
Object.defineProperty(exports, "__esModule", { value: true });
var react_1 = require("react");
var react_native_1 = require("react-native");
var NewAppScreen_1 = require("react-native/Libraries/NewAppScreen");
var react_native_unity_view_1 = require("@asmadsen/react-native-unity-view");
var App = function () {
    var _a = (0, react_1.useState)(0), count = _a[0], setClickCount = _a[1];
    console.log(count);
    var onUnityMessage = function (hander) {
        console.log({ hander: hander });
    };
    var onClick = function () {
        react_native_unity_view_1.UnityModule.postMessageToUnityManager({
            name: 'ToggleRotate',
            data: '',
            callBack: function (data) {
                react_native_1.Alert.alert('Tip', JSON.stringify(data));
            }
        });
    };
    return (react_1.default.createElement(react_native_1.View, { style: { flex: 1 } },
        react_1.default.createElement(react_native_1.View, { style: { flex: 1 } },
            react_1.default.createElement(react_native_unity_view_1.default, { style: { flex: 1 }, onMessage: onUnityMessage, onUnityMessage: onUnityMessage })),
        react_1.default.createElement(react_native_1.Button, { style: { width: '100%' }, title: "Toggle rotation", onPress: onClick })));
};
var styles = react_native_1.StyleSheet.create({
    scrollView: {
        backgroundColor: NewAppScreen_1.Colors.lighter,
    },
    engine: {
        position: 'absolute',
        right: 0,
    },
    body: {
        backgroundColor: NewAppScreen_1.Colors.white,
    },
    sectionContainer: {
        marginTop: 32,
        paddingHorizontal: 24,
    },
    sectionTitle: {
        fontSize: 24,
        fontWeight: '600',
        color: NewAppScreen_1.Colors.black,
    },
    sectionDescription: {
        marginTop: 8,
        fontSize: 18,
        fontWeight: '400',
        color: NewAppScreen_1.Colors.dark,
    },
    highlight: {
        fontWeight: '700',
    },
    footer: {
        color: NewAppScreen_1.Colors.dark,
        fontSize: 12,
        fontWeight: '600',
        padding: 4,
        paddingRight: 12,
        textAlign: 'right',
    },
});
exports.default = App;
