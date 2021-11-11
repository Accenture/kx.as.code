webpackHotUpdate("main_window",{

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
/* harmony import */ var _MyDashboard_scss__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./MyDashboard.scss */ "./src/components/dashboard/MyDashboard.scss");
/* harmony import */ var _MyDashboard_scss__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(_MyDashboard_scss__WEBPACK_IMPORTED_MODULE_2__);
/* harmony import */ var _material_ui_core__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @material-ui/core */ "./node_modules/@material-ui/core/esm/index.js");
/* harmony import */ var react_intl_universal__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! react-intl-universal */ "./node_modules/react-intl-universal/lib/index.js");
/* harmony import */ var react_intl_universal__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(react_intl_universal__WEBPACK_IMPORTED_MODULE_4__);
/* harmony import */ var _home_ProfileCard__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ../home/ProfileCard */ "./src/components/home/ProfileCard.jsx");
/* harmony import */ var react_redux__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! react-redux */ "./node_modules/react-redux/es/index.js");
/* harmony import */ var _redux_actions__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ../../redux/actions */ "./src/redux/actions.js");
(function () {
  var enterModule = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal.enterModule : undefined;
  enterModule && enterModule(module);
})();

var __signature__ = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal["default"].signature : function (a) {
  return a;
};










var MyDashboard = function MyDashboard(props) {
  var history = Object(react_router_dom__WEBPACK_IMPORTED_MODULE_1__["useHistory"])();

  var handleClick = function handleClick() {
    props.setNextView();
    history.push("/new-profile-general");
  };

  return /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_3__["Box"], {
    id: "Home"
  }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("h1", null, "Rabbitmq POC"), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_3__["Box"], null, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_3__["Button"], {
    onClick: handleClick
  }, react_intl_universal__WEBPACK_IMPORTED_MODULE_4___default.a.get("HOME_NEW_PROFILE_BUTTON")), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_3__["Button"], null, react_intl_universal__WEBPACK_IMPORTED_MODULE_4___default.a.get("HOME_IMPORT_CONFIG_BUTTON"))), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_3__["Box"], {
    className: "profile-cards"
  }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_home_ProfileCard__WEBPACK_IMPORTED_MODULE_5__["default"], {
    subVmCategory: "VMWare vSphere",
    profileName: "Profile Name",
    domainName: "Domain Name",
    ipAddress: "IP Address"
  }), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_home_ProfileCard__WEBPACK_IMPORTED_MODULE_5__["default"], {
    subVmCategory: "VMWare vSphere",
    profileName: "Profile Name",
    domainName: "Domain Name",
    ipAddress: "IP Address"
  }), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_home_ProfileCard__WEBPACK_IMPORTED_MODULE_5__["default"], {
    subVmCategory: "VMWare vSphere",
    profileName: "Profile Name",
    domainName: "Domain Name",
    ipAddress: "IP Address"
  }), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_home_ProfileCard__WEBPACK_IMPORTED_MODULE_5__["default"], {
    subVmCategory: "VMWare vSphere",
    profileName: "Profile Name",
    domainName: "Domain Name",
    ipAddress: "IP Address"
  })));
};

__signature__(MyDashboard, "useHistory{history}", function () {
  return [react_router_dom__WEBPACK_IMPORTED_MODULE_1__["useHistory"]];
});

var mapDispatchToProps = function mapDispatchToProps(dispatch) {
  return {
    setNextView: function setNextView() {
      dispatch(Object(_redux_actions__WEBPACK_IMPORTED_MODULE_7__["setNextView"])());
    }
  };
};

var _default = Object(react_redux__WEBPACK_IMPORTED_MODULE_6__["connect"])(null, mapDispatchToProps)(MyDashboard);

/* harmony default export */ __webpack_exports__["default"] = (_default);
;

(function () {
  var reactHotLoader = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal.default : undefined;

  if (!reactHotLoader) {
    return;
  }

  reactHotLoader.register(MyDashboard, "MyDashboard", "/Users/burak.kayaalp/dev/kx.as.code/client/src/components/dashboard/MyDashboard.jsx");
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
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vLi9zcmMvY29tcG9uZW50cy9kYXNoYm9hcmQvTXlEYXNoYm9hcmQuanN4Il0sIm5hbWVzIjpbIk15RGFzaGJvYXJkIiwicHJvcHMiLCJoaXN0b3J5IiwidXNlSGlzdG9yeSIsImhhbmRsZUNsaWNrIiwic2V0TmV4dFZpZXciLCJwdXNoIiwiaW50bCIsImdldCIsIm1hcERpc3BhdGNoVG9Qcm9wcyIsImRpc3BhdGNoIiwiY29ubmVjdCJdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7OztBQUFBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7O0FBRUEsSUFBTUEsV0FBVyxHQUFHLFNBQWRBLFdBQWMsQ0FBQ0MsS0FBRCxFQUFXO0FBQzNCLE1BQU1DLE9BQU8sR0FBR0MsbUVBQVUsRUFBMUI7O0FBQ0EsTUFBTUMsV0FBVyxHQUFHLFNBQWRBLFdBQWMsR0FBTTtBQUN0QkgsU0FBSyxDQUFDSSxXQUFOO0FBQ0FILFdBQU8sQ0FBQ0ksSUFBUixDQUFhLHNCQUFiO0FBQ0gsR0FIRDs7QUFJQSxzQkFDSSwyREFBQyxxREFBRDtBQUFLLE1BQUUsRUFBQztBQUFSLGtCQUNJLHNGQURKLGVBRUksMkRBQUMscURBQUQscUJBQ0ksMkRBQUMsd0RBQUQ7QUFBUSxXQUFPLEVBQUVGO0FBQWpCLEtBQ0tHLDJEQUFJLENBQUNDLEdBQUwsQ0FBUyx5QkFBVCxDQURMLENBREosZUFJSSwyREFBQyx3REFBRCxRQUFTRCwyREFBSSxDQUFDQyxHQUFMLENBQVMsMkJBQVQsQ0FBVCxDQUpKLENBRkosZUFRSSwyREFBQyxxREFBRDtBQUFLLGFBQVMsRUFBQztBQUFmLGtCQUNJLDJEQUFDLHlEQUFEO0FBQ0ksaUJBQWEsRUFBQyxnQkFEbEI7QUFFSSxlQUFXLEVBQUMsY0FGaEI7QUFHSSxjQUFVLEVBQUMsYUFIZjtBQUlJLGFBQVMsRUFBQztBQUpkLElBREosZUFPSSwyREFBQyx5REFBRDtBQUNJLGlCQUFhLEVBQUMsZ0JBRGxCO0FBRUksZUFBVyxFQUFDLGNBRmhCO0FBR0ksY0FBVSxFQUFDLGFBSGY7QUFJSSxhQUFTLEVBQUM7QUFKZCxJQVBKLGVBYUksMkRBQUMseURBQUQ7QUFDSSxpQkFBYSxFQUFDLGdCQURsQjtBQUVJLGVBQVcsRUFBQyxjQUZoQjtBQUdJLGNBQVUsRUFBQyxhQUhmO0FBSUksYUFBUyxFQUFDO0FBSmQsSUFiSixlQW1CSSwyREFBQyx5REFBRDtBQUNJLGlCQUFhLEVBQUMsZ0JBRGxCO0FBRUksZUFBVyxFQUFDLGNBRmhCO0FBR0ksY0FBVSxFQUFDLGFBSGY7QUFJSSxhQUFTLEVBQUM7QUFKZCxJQW5CSixDQVJKLENBREo7QUFxQ0gsQ0EzQ0Q7O2NBQU1SLFc7VUFDY0csMkQ7OztBQTRDcEIsSUFBTU0sa0JBQWtCLEdBQUcsU0FBckJBLGtCQUFxQixDQUFDQyxRQUFELEVBQWM7QUFDckMsU0FBTztBQUNITCxlQUFXLEVBQUUsdUJBQU07QUFDZkssY0FBUSxDQUFDTCxrRUFBVyxFQUFaLENBQVI7QUFDSDtBQUhFLEdBQVA7QUFLSCxDQU5EOztlQVFlTSwyREFBTyxDQUFDLElBQUQsRUFBT0Ysa0JBQVAsQ0FBUCxDQUFrQ1QsV0FBbEMsQzs7QUFBQTs7Ozs7Ozs7OzswQkFyRFRBLFc7MEJBNkNBUyxrQiIsImZpbGUiOiJtYWluX3dpbmRvdy4yNzY0ZTFhOTc1ZmQ4Nzc3ZmE4ZC5ob3QtdXBkYXRlLmpzIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IFJlYWN0IGZyb20gXCJyZWFjdFwiO1xuaW1wb3J0IHsgdXNlSGlzdG9yeSB9IGZyb20gXCJyZWFjdC1yb3V0ZXItZG9tXCI7XG5pbXBvcnQgXCIuL015RGFzaGJvYXJkLnNjc3NcIjtcbmltcG9ydCB7IEJveCwgQnV0dG9uIH0gZnJvbSBcIkBtYXRlcmlhbC11aS9jb3JlXCI7XG5pbXBvcnQgaW50bCBmcm9tIFwicmVhY3QtaW50bC11bml2ZXJzYWxcIjtcbmltcG9ydCBQcm9maWxlQ2FyZCBmcm9tIFwiLi4vaG9tZS9Qcm9maWxlQ2FyZFwiXG5pbXBvcnQgeyBjb25uZWN0IH0gZnJvbSBcInJlYWN0LXJlZHV4XCI7XG5pbXBvcnQgeyBzZXROZXh0VmlldyB9IGZyb20gXCIuLi8uLi9yZWR1eC9hY3Rpb25zXCI7XG5cbmNvbnN0IE15RGFzaGJvYXJkID0gKHByb3BzKSA9PiB7XG4gICAgY29uc3QgaGlzdG9yeSA9IHVzZUhpc3RvcnkoKTtcbiAgICBjb25zdCBoYW5kbGVDbGljayA9ICgpID0+IHtcbiAgICAgICAgcHJvcHMuc2V0TmV4dFZpZXcoKTtcbiAgICAgICAgaGlzdG9yeS5wdXNoKFwiL25ldy1wcm9maWxlLWdlbmVyYWxcIilcbiAgICB9O1xuICAgIHJldHVybiAoXG4gICAgICAgIDxCb3ggaWQ9XCJIb21lXCI+XG4gICAgICAgICAgICA8aDE+UmFiYml0bXEgUE9DPC9oMT5cbiAgICAgICAgICAgIDxCb3g+XG4gICAgICAgICAgICAgICAgPEJ1dHRvbiBvbkNsaWNrPXtoYW5kbGVDbGlja30+XG4gICAgICAgICAgICAgICAgICAgIHtpbnRsLmdldChcIkhPTUVfTkVXX1BST0ZJTEVfQlVUVE9OXCIpfVxuICAgICAgICAgICAgICAgIDwvQnV0dG9uPlxuICAgICAgICAgICAgICAgIDxCdXR0b24+e2ludGwuZ2V0KFwiSE9NRV9JTVBPUlRfQ09ORklHX0JVVFRPTlwiKX08L0J1dHRvbj5cbiAgICAgICAgICAgIDwvQm94PlxuICAgICAgICAgICAgPEJveCBjbGFzc05hbWU9XCJwcm9maWxlLWNhcmRzXCI+XG4gICAgICAgICAgICAgICAgPFByb2ZpbGVDYXJkXG4gICAgICAgICAgICAgICAgICAgIHN1YlZtQ2F0ZWdvcnk9XCJWTVdhcmUgdlNwaGVyZVwiXG4gICAgICAgICAgICAgICAgICAgIHByb2ZpbGVOYW1lPVwiUHJvZmlsZSBOYW1lXCJcbiAgICAgICAgICAgICAgICAgICAgZG9tYWluTmFtZT1cIkRvbWFpbiBOYW1lXCJcbiAgICAgICAgICAgICAgICAgICAgaXBBZGRyZXNzPVwiSVAgQWRkcmVzc1wiXG4gICAgICAgICAgICAgICAgLz5cbiAgICAgICAgICAgICAgICA8UHJvZmlsZUNhcmRcbiAgICAgICAgICAgICAgICAgICAgc3ViVm1DYXRlZ29yeT1cIlZNV2FyZSB2U3BoZXJlXCJcbiAgICAgICAgICAgICAgICAgICAgcHJvZmlsZU5hbWU9XCJQcm9maWxlIE5hbWVcIlxuICAgICAgICAgICAgICAgICAgICBkb21haW5OYW1lPVwiRG9tYWluIE5hbWVcIlxuICAgICAgICAgICAgICAgICAgICBpcEFkZHJlc3M9XCJJUCBBZGRyZXNzXCJcbiAgICAgICAgICAgICAgICAvPlxuICAgICAgICAgICAgICAgIDxQcm9maWxlQ2FyZFxuICAgICAgICAgICAgICAgICAgICBzdWJWbUNhdGVnb3J5PVwiVk1XYXJlIHZTcGhlcmVcIlxuICAgICAgICAgICAgICAgICAgICBwcm9maWxlTmFtZT1cIlByb2ZpbGUgTmFtZVwiXG4gICAgICAgICAgICAgICAgICAgIGRvbWFpbk5hbWU9XCJEb21haW4gTmFtZVwiXG4gICAgICAgICAgICAgICAgICAgIGlwQWRkcmVzcz1cIklQIEFkZHJlc3NcIlxuICAgICAgICAgICAgICAgIC8+XG4gICAgICAgICAgICAgICAgPFByb2ZpbGVDYXJkXG4gICAgICAgICAgICAgICAgICAgIHN1YlZtQ2F0ZWdvcnk9XCJWTVdhcmUgdlNwaGVyZVwiXG4gICAgICAgICAgICAgICAgICAgIHByb2ZpbGVOYW1lPVwiUHJvZmlsZSBOYW1lXCJcbiAgICAgICAgICAgICAgICAgICAgZG9tYWluTmFtZT1cIkRvbWFpbiBOYW1lXCJcbiAgICAgICAgICAgICAgICAgICAgaXBBZGRyZXNzPVwiSVAgQWRkcmVzc1wiXG4gICAgICAgICAgICAgICAgLz5cbiAgICAgICAgICAgIDwvQm94PlxuICAgICAgICA8L0JveD5cbiAgICApO1xufTtcblxuY29uc3QgbWFwRGlzcGF0Y2hUb1Byb3BzID0gKGRpc3BhdGNoKSA9PiB7XG4gICAgcmV0dXJuIHtcbiAgICAgICAgc2V0TmV4dFZpZXc6ICgpID0+IHtcbiAgICAgICAgICAgIGRpc3BhdGNoKHNldE5leHRWaWV3KCkpXG4gICAgICAgIH1cbiAgICB9XG59XG5cbmV4cG9ydCBkZWZhdWx0IGNvbm5lY3QobnVsbCwgbWFwRGlzcGF0Y2hUb1Byb3BzKShNeURhc2hib2FyZCk7XG4iXSwic291cmNlUm9vdCI6IiJ9