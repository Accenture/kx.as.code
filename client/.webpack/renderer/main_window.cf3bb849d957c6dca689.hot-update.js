webpackHotUpdate("main_window",{

/***/ "./src/App.jsx":
/*!*********************!*\
  !*** ./src/App.jsx ***!
  \*********************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* WEBPACK VAR INJECTION */(function(module) {/* harmony import */ var react_hot_loader__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react-hot-loader */ "./node_modules/react-hot-loader/index.js");
/* harmony import */ var react_hot_loader__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react_hot_loader__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! react */ "./node_modules/react/index.js");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _fortawesome_fontawesome_svg_core__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @fortawesome/fontawesome-svg-core */ "./node_modules/@fortawesome/fontawesome-svg-core/index.es.js");
/* harmony import */ var _fortawesome_free_solid_svg_icons__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @fortawesome/free-solid-svg-icons */ "./node_modules/@fortawesome/free-solid-svg-icons/index.es.js");
/* harmony import */ var _material_ui_core__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! @material-ui/core */ "./node_modules/@material-ui/core/esm/index.js");
/* harmony import */ var react_intl_universal__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! react-intl-universal */ "./node_modules/react-intl-universal/lib/index.js");
/* harmony import */ var react_intl_universal__WEBPACK_IMPORTED_MODULE_5___default = /*#__PURE__*/__webpack_require__.n(react_intl_universal__WEBPACK_IMPORTED_MODULE_5__);
/* harmony import */ var intl__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! intl */ "./node_modules/intl/index.js");
/* harmony import */ var intl__WEBPACK_IMPORTED_MODULE_6___default = /*#__PURE__*/__webpack_require__.n(intl__WEBPACK_IMPORTED_MODULE_6__);
/* harmony import */ var _App_scss__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ./App.scss */ "./src/App.scss");
/* harmony import */ var _App_scss__WEBPACK_IMPORTED_MODULE_7___default = /*#__PURE__*/__webpack_require__.n(_App_scss__WEBPACK_IMPORTED_MODULE_7__);
/* harmony import */ var _layout_components_TopPanel__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! ./layout/components/TopPanel */ "./src/layout/components/TopPanel.jsx");
/* harmony import */ var _layout_components_LeftPanel__WEBPACK_IMPORTED_MODULE_9__ = __webpack_require__(/*! ./layout/components/LeftPanel */ "./src/layout/components/LeftPanel.jsx");
/* harmony import */ var react_router_dom__WEBPACK_IMPORTED_MODULE_10__ = __webpack_require__(/*! react-router-dom */ "./node_modules/react-router-dom/esm/react-router-dom.js");
/* harmony import */ var _components_home_Home__WEBPACK_IMPORTED_MODULE_11__ = __webpack_require__(/*! ./components/home/Home */ "./src/components/home/Home.jsx");
/* harmony import */ var _components_profile_index__WEBPACK_IMPORTED_MODULE_12__ = __webpack_require__(/*! ./components/profile/index */ "./src/components/profile/index.js");
/* harmony import */ var _components_dashboard_MyDashboard__WEBPACK_IMPORTED_MODULE_13__ = __webpack_require__(/*! ./components/dashboard/MyDashboard */ "./src/components/dashboard/MyDashboard.jsx");
function _typeof(obj) { "@babel/helpers - typeof"; if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

(function () {
  var enterModule = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal.enterModule : undefined;
  enterModule && enterModule(module);
})();

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function"); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, writable: true, configurable: true } }); if (superClass) _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }

function _createSuper(Derived) { var hasNativeReflectConstruct = _isNativeReflectConstruct(); return function _createSuperInternal() { var Super = _getPrototypeOf(Derived), result; if (hasNativeReflectConstruct) { var NewTarget = _getPrototypeOf(this).constructor; result = Reflect.construct(Super, arguments, NewTarget); } else { result = Super.apply(this, arguments); } return _possibleConstructorReturn(this, result); }; }

function _possibleConstructorReturn(self, call) { if (call && (_typeof(call) === "object" || typeof call === "function")) { return call; } return _assertThisInitialized(self); }

function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

function _isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Date.prototype.toString.call(Reflect.construct(Date, [], function () {})); return true; } catch (e) { return false; } }

function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }

var __signature__ = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal["default"].signature : function (a) {
  return a;
};















window.Intl = intl__WEBPACK_IMPORTED_MODULE_6___default.a;

__webpack_require__(/*! intl/locale-data/jsonp/en-US.js */ "./node_modules/intl/locale-data/jsonp/en-US.js");

__webpack_require__(/*! intl/locale-data/jsonp/de-DE.js */ "./node_modules/intl/locale-data/jsonp/de-DE.js");

var SUPPORTED_LOCALES = [{
  name: "English",
  value: "en-US"
}, {
  name: "Deutsch",
  value: "de-DE"
}];
_fortawesome_fontawesome_svg_core__WEBPACK_IMPORTED_MODULE_2__["library"].add(_fortawesome_free_solid_svg_icons__WEBPACK_IMPORTED_MODULE_3__["faChevronRight"], _fortawesome_free_solid_svg_icons__WEBPACK_IMPORTED_MODULE_3__["faSpinner"], _fortawesome_free_solid_svg_icons__WEBPACK_IMPORTED_MODULE_3__["faInfoCircle"], _fortawesome_free_solid_svg_icons__WEBPACK_IMPORTED_MODULE_3__["faBars"]);

var App = /*#__PURE__*/function (_Component) {
  _inherits(App, _Component);

  var _super = _createSuper(App);

  function App() {
    var _this;

    _classCallCheck(this, App);

    _this = _super.call(this);
    var currentLocale = SUPPORTED_LOCALES[0].value; // Determine user's locale here

    react_intl_universal__WEBPACK_IMPORTED_MODULE_5___default.a.init({
      currentLocale: currentLocale,
      locales: _defineProperty({}, currentLocale, __webpack_require__("./src/locales sync recursive ^\\.\\/.*\\.json$")("./".concat(currentLocale, ".json")))
    });
    return _this;
  }

  _createClass(App, [{
    key: "render",
    value: function render() {
      return /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_4__["Box"], {
        id: "App"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_4__["Box"], {
        id: "TopPanel-wrapper"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(react_router_dom__WEBPACK_IMPORTED_MODULE_10__["HashRouter"], null, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_layout_components_TopPanel__WEBPACK_IMPORTED_MODULE_8__["default"], null))), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_4__["Box"], {
        id: "main",
        flex: "1"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_4__["Box"], {
        id: "main-container"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_4__["Box"], {
        id: "LeftPanel-wrapper"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_layout_components_LeftPanel__WEBPACK_IMPORTED_MODULE_9__["default"], null)), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_4__["Box"], {
        id: "content"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(react_router_dom__WEBPACK_IMPORTED_MODULE_10__["HashRouter"], null, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement("div", null, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(react_router_dom__WEBPACK_IMPORTED_MODULE_10__["Route"], {
        path: "/new-profile-general"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_components_profile_index__WEBPACK_IMPORTED_MODULE_12__["NewProfileGeneral"], null)), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(react_router_dom__WEBPACK_IMPORTED_MODULE_10__["Route"], {
        path: "/new-profile-resource"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_components_profile_index__WEBPACK_IMPORTED_MODULE_12__["NewProfileResource"], null)), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(react_router_dom__WEBPACK_IMPORTED_MODULE_10__["Route"], {
        path: "/new-profile-storage"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_components_profile_index__WEBPACK_IMPORTED_MODULE_12__["NewProfileStorage"], null)), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(react_router_dom__WEBPACK_IMPORTED_MODULE_10__["Route"], {
        path: "/new-profile-optional"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_components_profile_index__WEBPACK_IMPORTED_MODULE_12__["NewProfileOptional"], null)), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(react_router_dom__WEBPACK_IMPORTED_MODULE_10__["Route"], {
        path: "/new-profile-review"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_components_profile_index__WEBPACK_IMPORTED_MODULE_12__["NewProfileReview"], null)), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(react_router_dom__WEBPACK_IMPORTED_MODULE_10__["Route"], {
        path: "/new-profile-reviewA"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_components_profile_index__WEBPACK_IMPORTED_MODULE_12__["NewProfileReview"], null)), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(react_router_dom__WEBPACK_IMPORTED_MODULE_10__["Route"], {
        path: "/kubernetes-installation"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_components_profile_index__WEBPACK_IMPORTED_MODULE_12__["NewProfileReview"], null)), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(react_router_dom__WEBPACK_IMPORTED_MODULE_10__["Route"], {
        path: "/list-application"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_1___default.a.createElement(_components_profile_index__WEBPACK_IMPORTED_MODULE_12__["ListApplication"], null))))))));
    }
  }, {
    key: "__reactstandin__regenerateByEval",
    // @ts-ignore
    value: function __reactstandin__regenerateByEval(key, code) {
      // @ts-ignore
      this[key] = eval(code);
    }
  }]);

  return App;
}(react__WEBPACK_IMPORTED_MODULE_1__["Component"]);

var _default = Object(react_hot_loader__WEBPACK_IMPORTED_MODULE_0__["hot"])(module)(App);

/* harmony default export */ __webpack_exports__["default"] = (_default);
;

(function () {
  var reactHotLoader = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal.default : undefined;

  if (!reactHotLoader) {
    return;
  }

  reactHotLoader.register(SUPPORTED_LOCALES, "SUPPORTED_LOCALES", "/Users/burak.kayaalp/dev/kx.as.code/client/src/App.jsx");
  reactHotLoader.register(App, "App", "/Users/burak.kayaalp/dev/kx.as.code/client/src/App.jsx");
  reactHotLoader.register(_default, "default", "/Users/burak.kayaalp/dev/kx.as.code/client/src/App.jsx");
})();

;

(function () {
  var leaveModule = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal.leaveModule : undefined;
  leaveModule && leaveModule(module);
})();
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./../node_modules/webpack/buildin/harmony-module.js */ "./node_modules/webpack/buildin/harmony-module.js")(module)))

/***/ }),

/***/ "./src/components/dashboard/MyDashboard.jsx":
/*!**************************************************!*\
  !*** ./src/components/dashboard/MyDashboard.jsx ***!
  \**************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* WEBPACK VAR INJECTION */(function(module) {/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "./node_modules/react/index.js");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var react_router_dom__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! react-router-dom */ "./node_modules/react-router-dom/esm/react-router-dom.js");
!(function webpackMissingModule() { var e = new Error("Cannot find module './Home.scss'"); e.code = 'MODULE_NOT_FOUND'; throw e; }());
/* harmony import */ var _material_ui_core__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @material-ui/core */ "./node_modules/@material-ui/core/esm/index.js");
/* harmony import */ var react_intl_universal__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! react-intl-universal */ "./node_modules/react-intl-universal/lib/index.js");
/* harmony import */ var react_intl_universal__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(react_intl_universal__WEBPACK_IMPORTED_MODULE_4__);
!(function webpackMissingModule() { var e = new Error("Cannot find module './ProfileCard'"); e.code = 'MODULE_NOT_FOUND'; throw e; }());
/* harmony import */ var react_redux__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! react-redux */ "./node_modules/react-redux/es/index.js");
/* harmony import */ var _redux_actions__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ../../redux/actions */ "./src/redux/actions.js");
(function () {
  var enterModule = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal.enterModule : undefined;
  enterModule && enterModule(module);
})();

var __signature__ = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal["default"].signature : function (a) {
  return a;
};










var Home = function Home(props) {
  var history = Object(react_router_dom__WEBPACK_IMPORTED_MODULE_1__["useHistory"])();

  var handleClick = function handleClick() {
    props.setNextView();
    history.push("/new-profile-general");
  };

  return /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("div", null, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("h1", null, "AB"));
};

__signature__(Home, "useHistory{history}", function () {
  return [react_router_dom__WEBPACK_IMPORTED_MODULE_1__["useHistory"]];
});

var mapDispatchToProps = function mapDispatchToProps(dispatch) {
  return {
    setNextView: function setNextView() {
      dispatch(Object(_redux_actions__WEBPACK_IMPORTED_MODULE_6__["setNextView"])());
    }
  };
};

var _default = Object(react_redux__WEBPACK_IMPORTED_MODULE_5__["connect"])(null, mapDispatchToProps)(Home);

/* harmony default export */ __webpack_exports__["default"] = (_default);
;

(function () {
  var reactHotLoader = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal.default : undefined;

  if (!reactHotLoader) {
    return;
  }

  reactHotLoader.register(Home, "Home", "/Users/burak.kayaalp/dev/kx.as.code/client/src/components/dashboard/MyDashboard.jsx");
  reactHotLoader.register(mapDispatchToProps, "mapDispatchToProps", "/Users/burak.kayaalp/dev/kx.as.code/client/src/components/dashboard/MyDashboard.jsx");
  reactHotLoader.register(_default, "default", "/Users/burak.kayaalp/dev/kx.as.code/client/src/components/dashboard/MyDashboard.jsx");
})();

;

(function () {
  var leaveModule = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal.leaveModule : undefined;
  leaveModule && leaveModule(module);
})();
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./../../../node_modules/webpack/buildin/harmony-module.js */ "./node_modules/webpack/buildin/harmony-module.js")(module)))

/***/ })

})
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vLi9zcmMvQXBwLmpzeCIsIndlYnBhY2s6Ly8vLi9zcmMvY29tcG9uZW50cy9kYXNoYm9hcmQvTXlEYXNoYm9hcmQuanN4Il0sIm5hbWVzIjpbIndpbmRvdyIsIkludGwiLCJJbnRsUG9seWZpbGwiLCJyZXF1aXJlIiwiU1VQUE9SVEVEX0xPQ0FMRVMiLCJuYW1lIiwidmFsdWUiLCJsaWJyYXJ5IiwiYWRkIiwiZmFDaGV2cm9uUmlnaHQiLCJmYVNwaW5uZXIiLCJmYUluZm9DaXJjbGUiLCJmYUJhcnMiLCJBcHAiLCJjdXJyZW50TG9jYWxlIiwiaW50bCIsImluaXQiLCJsb2NhbGVzIiwiQ29tcG9uZW50IiwiaG90IiwibW9kdWxlIiwiSG9tZSIsInByb3BzIiwiaGlzdG9yeSIsInVzZUhpc3RvcnkiLCJoYW5kbGVDbGljayIsInNldE5leHRWaWV3IiwicHVzaCIsIm1hcERpc3BhdGNoVG9Qcm9wcyIsImRpc3BhdGNoIiwiY29ubmVjdCJdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7O0FBQUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUdBQSxNQUFNLENBQUNDLElBQVAsR0FBY0MsMkNBQWQ7O0FBQ0FDLG1CQUFPLENBQUMsdUZBQUQsQ0FBUDs7QUFDQUEsbUJBQU8sQ0FBQyx1RkFBRCxDQUFQOztBQUVBLElBQU1DLGlCQUFpQixHQUFHLENBQ3hCO0FBQ0VDLE1BQUksRUFBRSxTQURSO0FBRUVDLE9BQUssRUFBRTtBQUZULENBRHdCLEVBS3hCO0FBQ0VELE1BQUksRUFBRSxTQURSO0FBRUVDLE9BQUssRUFBRTtBQUZULENBTHdCLENBQTFCO0FBV0FDLHlFQUFPLENBQUNDLEdBQVIsQ0FBWUMsZ0ZBQVosRUFBMkJDLDJFQUEzQixFQUFxQ0MsOEVBQXJDLEVBQW1EQyx3RUFB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Ozs7Ozs7OzBCQXJCVEEsSTswQkFhQU8sa0IiLCJmaWxlIjoibWFpbl93aW5kb3cuY2YzYmI4NDlkOTU3YzZkY2E2ODkuaG90LXVwZGF0ZS5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7IGhvdCB9IGZyb20gXCJyZWFjdC1ob3QtbG9hZGVyXCI7XG5pbXBvcnQgUmVhY3QsIHsgQ29tcG9uZW50IH0gZnJvbSBcInJlYWN0XCI7XG5pbXBvcnQgeyBsaWJyYXJ5IH0gZnJvbSBcIkBmb3J0YXdlc29tZS9mb250YXdlc29tZS1zdmctY29yZVwiO1xuaW1wb3J0IHsgZmFDaGV2cm9uUmlnaHQsZmFTcGlubmVyLCBmYUluZm9DaXJjbGUsIGZhQmFycyB9IGZyb20gXCJAZm9ydGF3ZXNvbWUvZnJlZS1zb2xpZC1zdmctaWNvbnNcIjtcbmltcG9ydCB7IEJveCB9IGZyb20gXCJAbWF0ZXJpYWwtdWkvY29yZVwiO1xuaW1wb3J0IGludGwgZnJvbSBcInJlYWN0LWludGwtdW5pdmVyc2FsXCI7XG5pbXBvcnQgSW50bFBvbHlmaWxsIGZyb20gXCJpbnRsXCI7XG5pbXBvcnQgXCIuL0FwcC5zY3NzXCI7XG5pbXBvcnQgVG9wUGFuZWwgZnJvbSBcIi4vbGF5b3V0L2NvbXBvbmVudHMvVG9wUGFuZWxcIjtcbmltcG9ydCBMZWZ0UGFuZWwgZnJvbSBcIi4vbGF5b3V0L2NvbXBvbmVudHMvTGVmdFBhbmVsXCI7XG5pbXBvcnQgeyBIYXNoUm91dGVyLCBSb3V0ZSB9IGZyb20gXCJyZWFjdC1yb3V0ZXItZG9tXCI7XG5pbXBvcnQgSG9tZSBmcm9tIFwiLi9jb21wb25lbnRzL2hvbWUvSG9tZVwiO1xuaW1wb3J0IHsgTmV3UHJvZmlsZUdlbmVyYWwsIE5ld1Byb2ZpbGVSZXNvdXJjZSwgTmV3UHJvZmlsZVN0b3JhZ2UsIE5ld1Byb2ZpbGVSZXZpZXcsIE5ld1Byb2ZpbGVPcHRpb25hbCwgS3ViZXJuZXRlc0luc3RhbGxhdGlvbiwgTGlzdEFwcGxpY2F0aW9uIH0gZnJvbSBcIi4vY29tcG9uZW50cy9wcm9maWxlL2luZGV4XCI7XG5pbXBvcnQgTXlEYXNoYm9hcmQgZnJvbSBcIi4vY29tcG9uZW50cy9kYXNoYm9hcmQvTXlEYXNoYm9hcmRcIjtcblxuXG53aW5kb3cuSW50bCA9IEludGxQb2x5ZmlsbDtcbnJlcXVpcmUoXCJpbnRsL2xvY2FsZS1kYXRhL2pzb25wL2VuLVVTLmpzXCIpO1xucmVxdWlyZShcImludGwvbG9jYWxlLWRhdGEvanNvbnAvZGUtREUuanNcIik7XG5cbmNvbnN0IFNVUFBPUlRFRF9MT0NBTEVTID0gW1xuICB7XG4gICAgbmFtZTogXCJFbmdsaXNoXCIsXG4gICAgdmFsdWU6IFwiZW4tVVNcIixcbiAgfSxcbiAge1xuICAgIG5hbWU6IFwiRGV1dHNjaFwiLFxuICAgIHZhbHVlOiBcImRlLURFXCIsXG4gIH0sXG5dO1xuXG5saWJyYXJ5LmFkZChmYUNoZXZyb25SaWdodCxmYVNwaW5uZXIsZmFJbmZvQ2lyY2xlLCBmYUJhcnMpO1xuXG5jbGFzcyBBcHAgZXh0ZW5kcyBDb21wb25lbnQge1xuICBjb25zdHJ1Y3RvcigpIHtcbiAgICBzdXBlcigpO1xuICAgIGNvbnN0IGN1cnJlbnRMb2NhbGUgPSBTVVBQT1JURURfTE9DQUxFU1swXS52YWx1ZTsgLy8gRGV0ZXJtaW5lIHVzZXIncyBsb2NhbGUgaGVyZVxuICAgIGludGwuaW5pdCh7XG4gICAgICBjdXJyZW50TG9jYWxlLFxuICAgICAgbG9jYWxlczoge1xuICAgICAgICBbY3VycmVudExvY2FsZV06IHJlcXVpcmUoYC4vbG9jYWxlcy8ke2N1cnJlbnRMb2NhbGV9Lmpzb25gKSxcbiAgICAgIH0sXG4gICAgfSk7XG4gIH1cblxuICByZW5kZXIoKSB7XG4gICAgcmV0dXJuIChcbiAgICAgIDxCb3ggaWQ9XCJBcHBcIj5cbiAgICAgICAgey8qIFRvcCBwYW5lbCAqL31cbiAgICAgICAgPEJveCBpZD1cIlRvcFBhbmVsLXdyYXBwZXJcIj5cbiAgICAgICAgICA8SGFzaFJvdXRlcj5cbiAgICAgICAgICAgIDxUb3BQYW5lbCAvPlxuICAgICAgICAgIDwvSGFzaFJvdXRlcj5cbiAgICAgICAgPC9Cb3g+XG4gICAgICAgIHsvKiBNYWluIHNlY3Rpb24gLSBiZWxvdyB0b3AgcGFuZWwgKi99XG4gICAgICAgIDxCb3ggaWQ9XCJtYWluXCIgZmxleD1cIjFcIj5cbiAgICAgICAgICA8Qm94IGlkPVwibWFpbi1jb250YWluZXJcIj5cbiAgICAgICAgICAgIHsvKiBMZWZ0IHBhbmVsICovfVxuICAgICAgICAgICAgPEJveCBpZD1cIkxlZnRQYW5lbC13cmFwcGVyXCI+XG4gICAgICAgICAgICAgIDxMZWZ0UGFuZWwgLz5cbiAgICAgICAgICAgIDwvQm94PlxuICAgICAgICAgICAgey8qIENvbnRlbnQgKi99XG4gICAgICAgICAgICA8Qm94IGlkPVwiY29udGVudFwiID5cbiAgICAgICAgICAgICAgPEhhc2hSb3V0ZXI+XG4gICAgICAgICAgICAgICAgPGRpdj5cbiAgICAgICAgICAgICAgICAgIHsvKiA8Um91dGUgcGF0aD1cIi9cIiBleGFjdD17dHJ1ZX0gY29tcG9uZW50PXtNeURhc2hib2FyZH0gLz4gKi99XG4gICAgICAgICAgICAgICAgICA8Um91dGUgcGF0aD1cIi9uZXctcHJvZmlsZS1nZW5lcmFsXCI+XG4gICAgICAgICAgICAgICAgICAgIDxOZXdQcm9maWxlR2VuZXJhbC8+XG4gICAgICAgICAgICAgICAgICA8L1JvdXRlPlxuICAgICAgICAgICAgICAgICAgPFJvdXRlIHBhdGg9XCIvbmV3LXByb2ZpbGUtcmVzb3VyY2VcIj5cbiAgICAgICAgICAgICAgICAgICAgPE5ld1Byb2ZpbGVSZXNvdXJjZS8+XG4gICAgICAgICAgICAgICAgICA8L1JvdXRlPlxuICAgICAgICAgICAgICAgICAgPFJvdXRlIHBhdGg9XCIvbmV3LXByb2ZpbGUtc3RvcmFnZVwiPlxuICAgICAgICAgICAgICAgICAgICA8TmV3UHJvZmlsZVN0b3JhZ2UvPlxuICAgICAgICAgICAgICAgICAgPC9Sb3V0ZT5cbiAgICAgICAgICAgICAgICAgIDxSb3V0ZSBwYXRoPVwiL25ldy1wcm9maWxlLW9wdGlvbmFsXCI+XG4gICAgICAgICAgICAgICAgICAgIDxOZXdQcm9maWxlT3B0aW9uYWwvPlxuICAgICAgICAgICAgICAgICAgPC9Sb3V0ZT5cbiAgICAgICAgICAgICAgICAgIDxSb3V0ZSBwYXRoPVwiL25ldy1wcm9maWxlLXJldmlld1wiPlxuICAgICAgICAgICAgICAgICAgICA8TmV3UHJvZmlsZVJldmlldy8+XG4gICAgICAgICAgICAgICAgICA8L1JvdXRlPlxuICAgICAgICAgICAgICAgICAgPFJvdXRlIHBhdGg9XCIvbmV3LXByb2ZpbGUtcmV2aWV3QVwiPlxuICAgICAgICAgICAgICAgICAgICA8TmV3UHJvZmlsZVJldmlldy8+XG4gICAgICAgICAgICAgICAgICA8L1JvdXRlPlxuICAgICAgICAgICAgICAgICAgPFJvdXRlIHBhdGg9XCIva3ViZXJuZXRlcy1pbnN0YWxsYXRpb25cIj5cbiAgICAgICAgICAgICAgICAgICAgPE5ld1Byb2ZpbGVSZXZpZXcvPlxuICAgICAgICAgICAgICAgICAgPC9Sb3V0ZT5cbiAgICAgICAgICAgICAgICAgIDxSb3V0ZSBwYXRoPVwiL2xpc3QtYXBwbGljYXRpb25cIj5cbiAgICAgICAgICAgICAgICAgICAgPExpc3RBcHBsaWNhdGlvbi8+XG4gICAgICAgICAgICAgICAgICA8L1JvdXRlPlxuICAgICAgICAgICAgICAgIDwvZGl2PlxuICAgICAgICAgICAgICA8L0hhc2hSb3V0ZXI+XG4gICAgICAgICAgICA8L0JveD5cbiAgICAgICAgICA8L0JveD5cbiAgICAgICAgPC9Cb3g+XG4gICAgICA8L0JveD5cbiAgICApO1xuICB9XG59XG5cbmV4cG9ydCBkZWZhdWx0IGhvdChtb2R1bGUpKEFwcCk7XG4iLCJpbXBvcnQgUmVhY3QgZnJvbSBcInJlYWN0XCI7XG5pbXBvcnQgeyB1c2VIaXN0b3J5IH0gZnJvbSBcInJlYWN0LXJvdXRlci1kb21cIjtcbmltcG9ydCBcIi4vSG9tZS5zY3NzXCI7XG5pbXBvcnQgeyBCb3gsIEJ1dHRvbiB9IGZyb20gXCJAbWF0ZXJpYWwtdWkvY29yZVwiO1xuaW1wb3J0IGludGwgZnJvbSBcInJlYWN0LWludGwtdW5pdmVyc2FsXCI7XG5pbXBvcnQgUHJvZmlsZUNhcmQgZnJvbSBcIi4vUHJvZmlsZUNhcmRcIjtcbmltcG9ydCB7IGNvbm5lY3QgfSBmcm9tIFwicmVhY3QtcmVkdXhcIjtcbmltcG9ydCB7IHNldE5leHRWaWV3IH0gZnJvbSBcIi4uLy4uL3JlZHV4L2FjdGlvbnNcIjtcblxuY29uc3QgSG9tZSA9IChwcm9wcykgPT4ge1xuICBjb25zdCBoaXN0b3J5ID0gdXNlSGlzdG9yeSgpO1xuICBjb25zdCBoYW5kbGVDbGljayA9ICgpID0+IHtcbiAgICBwcm9wcy5zZXROZXh0VmlldygpO1xuICAgIGhpc3RvcnkucHVzaChcIi9uZXctcHJvZmlsZS1nZW5lcmFsXCIpXG4gIH07XG4gIHJldHVybiAoXG4gICAgICA8ZGl2PlxuICAgICAgICAgIDxoMT5BQjwvaDE+XG4gICAgICA8L2Rpdj5cbiAgKTtcbn07XG5cbmNvbnN0IG1hcERpc3BhdGNoVG9Qcm9wcyA9IChkaXNwYXRjaCkgPT4ge1xuICByZXR1cm4ge1xuICAgIHNldE5leHRWaWV3OiAoKSA9PiB7XG4gICAgICAgICAgZGlzcGF0Y2goc2V0TmV4dFZpZXcoKSlcbiAgICAgIH1cbiAgfVxufVxuXG5leHBvcnQgZGVmYXVsdCBjb25uZWN0KG51bGwsIG1hcERpc3BhdGNoVG9Qcm9wcykoSG9tZSk7XG4iXSwic291cmNlUm9vdCI6IiJ9