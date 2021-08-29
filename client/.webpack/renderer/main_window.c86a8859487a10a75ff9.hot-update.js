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
/* harmony import */ var _components_dashboard_MyDashboard__WEBPACK_IMPORTED_MODULE_13___default = /*#__PURE__*/__webpack_require__.n(_components_dashboard_MyDashboard__WEBPACK_IMPORTED_MODULE_13__);
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

/***/ })

})
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vLi9zcmMvQXBwLmpzeCJdLCJuYW1lcyI6WyJ3aW5kb3ciLCJJbnRsIiwiSW50bFBvbHlmaWxsIiwicmVxdWlyZSIsIlNVUFBPUlRFRF9MT0NBTEVTIiwibmFtZSIsInZhbHVlIiwibGlicmFyeSIsImFkZCIsImZhQ2hldnJvblJpZ2h0IiwiZmFTcGlubmVyIiwiZmFJbmZvQ2lyY2xlIiwiZmFCYXJzIiwiQXBwIiwiY3VycmVudExvY2FsZSIsImludGwiLCJpbml0IiwibG9jYWxlcyIsIkNvbXBvbmVudCIsImhvdCIsIm1vZHVsZSJdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7OztBQUFBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFHQUEsTUFBTSxDQUFDQyxJQUFQLEdBQWNDLDJDQUFkOztBQUNBQyxtQkFBTyxDQUFDLHVGQUFELENBQVA7O0FBQ0FBLG1CQUFPLENBQUMsdUZBQUQsQ0FBUDs7QUFFQSxJQUFNQyxpQkFBaUIsR0FBRyxDQUN4QjtBQUNFQyxNQUFJLEVBQUUsU0FEUjtBQUVFQyxPQUFLLEVBQUU7QUFGVCxDQUR3QixFQUt4QjtBQUNFRCxNQUFJLEVBQUUsU0FEUjtBQUVFQyxPQUFLLEVBQUU7QUFGVCxDQUx3QixDQUExQjtBQVdBQyx5RUFBTyxDQUFDQyxHQUFSLENBQVlDLGdGQUFaLEVBQTJCQywyRUFBM0IsRUFBcUNDLDhFQUFyQyxFQUFtREMsd0VBQW5EOztJQUVNQyxHOzs7OztBQUNKLGlCQUFjO0FBQUE7O0FBQUE7O0FBQ1o7QUFDQSxRQUFNQyxhQUFhLEdBQUdWLGlCQUFpQixDQUFDLENBQUQsQ0FBakIsQ0FBcUJFLEtBQTNDLENBRlksQ0FFc0M7O0FBQ2xEUywrREFBSSxDQUFDQyxJQUFMLENBQVU7QUFDUkYsbUJBQWEsRUFBYkEsYUFEUTtBQUVSRyxhQUFPLHNCQUNKSCxhQURJLEVBQ1lYLHNFQUFRLFlBQWFXLGFBQWQsV0FEbkI7QUFGQyxLQUFWO0FBSFk7QUFTYjs7Ozs2QkFFUTtBQUNQLDBCQUNFLDJEQUFDLHFEQUFEO0FBQUssVUFBRSxFQUFDO0FBQVIsc0JBRUUsMkRBQUMscURBQUQ7QUFBSyxVQUFFLEVBQUM7QUFBUixzQkFDRSwyREFBQyw0REFBRCxxQkFDRSwyREFBQyxtRUFBRCxPQURGLENBREYsQ0FGRixlQVFFLDJEQUFDLHFEQUFEO0FBQUssVUFBRSxFQUFDLE1BQVI7QUFBZSxZQUFJLEVBQUM7QUFBcEIsc0JBQ0UsMkRBQUMscURBQUQ7QUFBSyxVQUFFLEVBQUM7QUFBUixzQkFFRSwyREFBQyxxREFBRDtBQUFLLFVBQUUsRUFBQztBQUFSLHNCQUNFLDJEQUFDLG9FQUFELE9BREYsQ0FGRixlQU1FLDJEQUFDLHFEQUFEO0FBQUssVUFBRSxFQUFDO0FBQVIsc0JBQ0UsMkRBQUMsNERBQUQscUJBQ0UscUZBRUUsMkRBQUMsdURBQUQ7QUFBTyxZQUFJLEVBQUM7QUFBWixzQkFDRSwyREFBQyw0RUFBRCxPQURGLENBRkYsZUFLRSwyREFBQyx1REFBRDtBQUFPLFlBQUksRUFBQztBQUFaLHNCQUNFLDJEQUFDLDZFQUFELE9BREYsQ0FMRixlQVFFLDJEQUFDLHVEQUFEO0FBQU8sWUFBSSxFQUFDO0FBQVosc0JBQ0UsMkRBQUMsNEVBQUQsT0FERixDQVJGLGVBV0UsMkRBQUMsdURBQUQ7QUFBTyxZQUFJLEVBQUM7QUFBWixzQkFDRSwyREFBQyw2RUFBRCxPQURGLENBWEYsZUFjRSwyREFBQyx1REFBRDtBQUFPLFlBQUksRUFBQztBQUFaLHNCQUNFLDJEQUFDLDJFQUFELE9BREYsQ0FkRixlQWlCRSwyREFBQyx1REFBRDtBQUFPLFlBQUksRUFBQztBQUFaLHNCQUNFLDJEQUFDLDJFQUFELE9BREYsQ0FqQkYsZUFvQkUsMkRBQUMsdURBQUQ7QUFBTyxZQUFJLEVBQUM7QUFBWixzQkFDRSwyREFBQywyRUFBRCxPQURGLENBcEJGLGVBdUJFLDJEQUFDLHVEQUFEO0FBQU8sWUFBSSxFQUFDO0FBQVosc0JBQ0UsMkRBQUMsMEVBQUQsT0FERixDQXZCRixDQURGLENBREYsQ0FORixDQURGLENBUkYsQ0FERjtBQW1ERDs7Ozs7Ozs7Ozs7RUFoRWVJLCtDOztlQW1FSEMsNERBQUcsQ0FBQ0MsTUFBRCxDQUFILENBQVlQLEdBQVosQzs7QUFBQTs7Ozs7Ozs7OzswQkFoRlRULGlCOzBCQWFBUyxHIiwiZmlsZSI6Im1haW5fd2luZG93LmM4NmE4ODU5NDg3YTEwYTc1ZmY5LmhvdC11cGRhdGUuanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgeyBob3QgfSBmcm9tIFwicmVhY3QtaG90LWxvYWRlclwiO1xuaW1wb3J0IFJlYWN0LCB7IENvbXBvbmVudCB9IGZyb20gXCJyZWFjdFwiO1xuaW1wb3J0IHsgbGlicmFyeSB9IGZyb20gXCJAZm9ydGF3ZXNvbWUvZm9udGF3ZXNvbWUtc3ZnLWNvcmVcIjtcbmltcG9ydCB7IGZhQ2hldnJvblJpZ2h0LGZhU3Bpbm5lciwgZmFJbmZvQ2lyY2xlLCBmYUJhcnMgfSBmcm9tIFwiQGZvcnRhd2Vzb21lL2ZyZWUtc29saWQtc3ZnLWljb25zXCI7XG5pbXBvcnQgeyBCb3ggfSBmcm9tIFwiQG1hdGVyaWFsLXVpL2NvcmVcIjtcbmltcG9ydCBpbnRsIGZyb20gXCJyZWFjdC1pbnRsLXVuaXZlcnNhbFwiO1xuaW1wb3J0IEludGxQb2x5ZmlsbCBmcm9tIFwiaW50bFwiO1xuaW1wb3J0IFwiLi9BcHAuc2Nzc1wiO1xuaW1wb3J0IFRvcFBhbmVsIGZyb20gXCIuL2xheW91dC9jb21wb25lbnRzL1RvcFBhbmVsXCI7XG5pbXBvcnQgTGVmdFBhbmVsIGZyb20gXCIuL2xheW91dC9jb21wb25lbnRzL0xlZnRQYW5lbFwiO1xuaW1wb3J0IHsgSGFzaFJvdXRlciwgUm91dGUgfSBmcm9tIFwicmVhY3Qtcm91dGVyLWRvbVwiO1xuaW1wb3J0IEhvbWUgZnJvbSBcIi4vY29tcG9uZW50cy9ob21lL0hvbWVcIjtcbmltcG9ydCB7IE5ld1Byb2ZpbGVHZW5lcmFsLCBOZXdQcm9maWxlUmVzb3VyY2UsIE5ld1Byb2ZpbGVTdG9yYWdlLCBOZXdQcm9maWxlUmV2aWV3LCBOZXdQcm9maWxlT3B0aW9uYWwsIEt1YmVybmV0ZXNJbnN0YWxsYXRpb24sIExpc3RBcHBsaWNhdGlvbiB9IGZyb20gXCIuL2NvbXBvbmVudHMvcHJvZmlsZS9pbmRleFwiO1xuaW1wb3J0IE15RGFzaGJvYXJkIGZyb20gXCIuL2NvbXBvbmVudHMvZGFzaGJvYXJkL015RGFzaGJvYXJkXCI7XG5cblxud2luZG93LkludGwgPSBJbnRsUG9seWZpbGw7XG5yZXF1aXJlKFwiaW50bC9sb2NhbGUtZGF0YS9qc29ucC9lbi1VUy5qc1wiKTtcbnJlcXVpcmUoXCJpbnRsL2xvY2FsZS1kYXRhL2pzb25wL2RlLURFLmpzXCIpO1xuXG5jb25zdCBTVVBQT1JURURfTE9DQUxFUyA9IFtcbiAge1xuICAgIG5hbWU6IFwiRW5nbGlzaFwiLFxuICAgIHZhbHVlOiBcImVuLVVTXCIsXG4gIH0sXG4gIHtcbiAgICBuYW1lOiBcIkRldXRzY2hcIixcbiAgICB2YWx1ZTogXCJkZS1ERVwiLFxuICB9LFxuXTtcblxubGlicmFyeS5hZGQoZmFDaGV2cm9uUmlnaHQsZmFTcGlubmVyLGZhSW5mb0NpcmNsZSwgZmFCYXJzKTtcblxuY2xhc3MgQXBwIGV4dGVuZHMgQ29tcG9uZW50IHtcbiAgY29uc3RydWN0b3IoKSB7XG4gICAgc3VwZXIoKTtcbiAgICBjb25zdCBjdXJyZW50TG9jYWxlID0gU1VQUE9SVEVEX0xPQ0FMRVNbMF0udmFsdWU7IC8vIERldGVybWluZSB1c2VyJ3MgbG9jYWxlIGhlcmVcbiAgICBpbnRsLmluaXQoe1xuICAgICAgY3VycmVudExvY2FsZSxcbiAgICAgIGxvY2FsZXM6IHtcbiAgICAgICAgW2N1cnJlbnRMb2NhbGVdOiByZXF1aXJlKGAuL2xvY2FsZXMvJHtjdXJyZW50TG9jYWxlfS5qc29uYCksXG4gICAgICB9LFxuICAgIH0pO1xuICB9XG5cbiAgcmVuZGVyKCkge1xuICAgIHJldHVybiAoXG4gICAgICA8Qm94IGlkPVwiQXBwXCI+XG4gICAgICAgIHsvKiBUb3AgcGFuZWwgKi99XG4gICAgICAgIDxCb3ggaWQ9XCJUb3BQYW5lbC13cmFwcGVyXCI+XG4gICAgICAgICAgPEhhc2hSb3V0ZXI+XG4gICAgICAgICAgICA8VG9wUGFuZWwgLz5cbiAgICAgICAgICA8L0hhc2hSb3V0ZXI+XG4gICAgICAgIDwvQm94PlxuICAgICAgICB7LyogTWFpbiBzZWN0aW9uIC0gYmVsb3cgdG9wIHBhbmVsICovfVxuICAgICAgICA8Qm94IGlkPVwibWFpblwiIGZsZXg9XCIxXCI+XG4gICAgICAgICAgPEJveCBpZD1cIm1haW4tY29udGFpbmVyXCI+XG4gICAgICAgICAgICB7LyogTGVmdCBwYW5lbCAqL31cbiAgICAgICAgICAgIDxCb3ggaWQ9XCJMZWZ0UGFuZWwtd3JhcHBlclwiPlxuICAgICAgICAgICAgICA8TGVmdFBhbmVsIC8+XG4gICAgICAgICAgICA8L0JveD5cbiAgICAgICAgICAgIHsvKiBDb250ZW50ICovfVxuICAgICAgICAgICAgPEJveCBpZD1cImNvbnRlbnRcIiA+XG4gICAgICAgICAgICAgIDxIYXNoUm91dGVyPlxuICAgICAgICAgICAgICAgIDxkaXY+XG4gICAgICAgICAgICAgICAgICB7LyogPFJvdXRlIHBhdGg9XCIvXCIgZXhhY3Q9e3RydWV9IGNvbXBvbmVudD17TXlEYXNoYm9hcmR9IC8+ICovfVxuICAgICAgICAgICAgICAgICAgPFJvdXRlIHBhdGg9XCIvbmV3LXByb2ZpbGUtZ2VuZXJhbFwiPlxuICAgICAgICAgICAgICAgICAgICA8TmV3UHJvZmlsZUdlbmVyYWwvPlxuICAgICAgICAgICAgICAgICAgPC9Sb3V0ZT5cbiAgICAgICAgICAgICAgICAgIDxSb3V0ZSBwYXRoPVwiL25ldy1wcm9maWxlLXJlc291cmNlXCI+XG4gICAgICAgICAgICAgICAgICAgIDxOZXdQcm9maWxlUmVzb3VyY2UvPlxuICAgICAgICAgICAgICAgICAgPC9Sb3V0ZT5cbiAgICAgICAgICAgICAgICAgIDxSb3V0ZSBwYXRoPVwiL25ldy1wcm9maWxlLXN0b3JhZ2VcIj5cbiAgICAgICAgICAgICAgICAgICAgPE5ld1Byb2ZpbGVTdG9yYWdlLz5cbiAgICAgICAgICAgICAgICAgIDwvUm91dGU+XG4gICAgICAgICAgICAgICAgICA8Um91dGUgcGF0aD1cIi9uZXctcHJvZmlsZS1vcHRpb25hbFwiPlxuICAgICAgICAgICAgICAgICAgICA8TmV3UHJvZmlsZU9wdGlvbmFsLz5cbiAgICAgICAgICAgICAgICAgIDwvUm91dGU+XG4gICAgICAgICAgICAgICAgICA8Um91dGUgcGF0aD1cIi9uZXctcHJvZmlsZS1yZXZpZXdcIj5cbiAgICAgICAgICAgICAgICAgICAgPE5ld1Byb2ZpbGVSZXZpZXcvPlxuICAgICAgICAgICAgICAgICAgPC9Sb3V0ZT5cbiAgICAgICAgICAgICAgICAgIDxSb3V0ZSBwYXRoPVwiL25ldy1wcm9maWxlLXJldmlld0FcIj5cbiAgICAgICAgICAgICAgICAgICAgPE5ld1Byb2ZpbGVSZXZpZXcvPlxuICAgICAgICAgICAgICAgICAgPC9Sb3V0ZT5cbiAgICAgICAgICAgICAgICAgIDxSb3V0ZSBwYXRoPVwiL2t1YmVybmV0ZXMtaW5zdGFsbGF0aW9uXCI+XG4gICAgICAgICAgICAgICAgICAgIDxOZXdQcm9maWxlUmV2aWV3Lz5cbiAgICAgICAgICAgICAgICAgIDwvUm91dGU+XG4gICAgICAgICAgICAgICAgICA8Um91dGUgcGF0aD1cIi9saXN0LWFwcGxpY2F0aW9uXCI+XG4gICAgICAgICAgICAgICAgICAgIDxMaXN0QXBwbGljYXRpb24vPlxuICAgICAgICAgICAgICAgICAgPC9Sb3V0ZT5cbiAgICAgICAgICAgICAgICA8L2Rpdj5cbiAgICAgICAgICAgICAgPC9IYXNoUm91dGVyPlxuICAgICAgICAgICAgPC9Cb3g+XG4gICAgICAgICAgPC9Cb3g+XG4gICAgICAgIDwvQm94PlxuICAgICAgPC9Cb3g+XG4gICAgKTtcbiAgfVxufVxuXG5leHBvcnQgZGVmYXVsdCBob3QobW9kdWxlKShBcHApO1xuIl0sInNvdXJjZVJvb3QiOiIifQ==