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
    props.setNextView(); // history.push("/new-profile-general")
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
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vLi9zcmMvY29tcG9uZW50cy9kYXNoYm9hcmQvTXlEYXNoYm9hcmQuanN4Il0sIm5hbWVzIjpbIk15RGFzaGJvYXJkIiwicHJvcHMiLCJoaXN0b3J5IiwidXNlSGlzdG9yeSIsImhhbmRsZUNsaWNrIiwic2V0TmV4dFZpZXciLCJpbnRsIiwiZ2V0IiwibWFwRGlzcGF0Y2hUb1Byb3BzIiwiZGlzcGF0Y2giLCJjb25uZWN0Il0sIm1hcHBpbmdzIjoiOzs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7O0FBQUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTs7QUFFQSxJQUFNQSxXQUFXLEdBQUcsU0FBZEEsV0FBYyxDQUFDQyxLQUFELEVBQVc7QUFDM0IsTUFBTUMsT0FBTyxHQUFHQyxtRUFBVSxFQUExQjs7QUFDQSxNQUFNQyxXQUFXLEdBQUcsU0FBZEEsV0FBYyxHQUFNO0FBQ3RCSCxTQUFLLENBQUNJLFdBQU4sR0FEc0IsQ0FFdEI7QUFDSCxHQUhEOztBQUlBLHNCQUNJLDJEQUFDLHFEQUFEO0FBQUssTUFBRSxFQUFDO0FBQVIsa0JBQ0ksc0ZBREosZUFFSSwyREFBQyxxREFBRCxxQkFDSSwyREFBQyx3REFBRDtBQUFRLFdBQU8sRUFBRUQ7QUFBakIsS0FDS0UsMkRBQUksQ0FBQ0MsR0FBTCxDQUFTLHlCQUFULENBREwsQ0FESixlQUlJLDJEQUFDLHdEQUFELFFBQVNELDJEQUFJLENBQUNDLEdBQUwsQ0FBUywyQkFBVCxDQUFULENBSkosQ0FGSixlQVFJLDJEQUFDLHFEQUFEO0FBQUssYUFBUyxFQUFDO0FBQWYsa0JBQ0ksMkRBQUMseURBQUQ7QUFDSSxpQkFBYSxFQUFDLGdCQURsQjtBQUVJLGVBQVcsRUFBQyxjQUZoQjtBQUdJLGNBQVUsRUFBQyxhQUhmO0FBSUksYUFBUyxFQUFDO0FBSmQsSUFESixlQU9JLDJEQUFDLHlEQUFEO0FBQ0ksaUJBQWEsRUFBQyxnQkFEbEI7QUFFSSxlQUFXLEVBQUMsY0FGaEI7QUFHSSxjQUFVLEVBQUMsYUFIZjtBQUlJLGFBQVMsRUFBQztBQUpkLElBUEosZUFhSSwyREFBQyx5REFBRDtBQUNJLGlCQUFhLEVBQUMsZ0JBRGxCO0FBRUksZUFBVyxFQUFDLGNBRmhCO0FBR0ksY0FBVSxFQUFDLGFBSGY7QUFJSSxhQUFTLEVBQUM7QUFKZCxJQWJKLGVBbUJJLDJEQUFDLHlEQUFEO0FBQ0ksaUJBQWEsRUFBQyxnQkFEbEI7QUFFSSxlQUFXLEVBQUMsY0FGaEI7QUFHSSxjQUFVLEVBQUMsYUFIZjtBQUlJLGFBQVMsRUFBQztBQUpkLElBbkJKLENBUkosQ0FESjtBQXFDSCxDQTNDRDs7Y0FBTVAsVztVQUNjRywyRDs7O0FBNENwQixJQUFNSyxrQkFBa0IsR0FBRyxTQUFyQkEsa0JBQXFCLENBQUNDLFFBQUQsRUFBYztBQUNyQyxTQUFPO0FBQ0hKLGVBQVcsRUFBRSx1QkFBTTtBQUNmSSxjQUFRLENBQUNKLGtFQUFXLEVBQVosQ0FBUjtBQUNIO0FBSEUsR0FBUDtBQUtILENBTkQ7O2VBUWVLLDJEQUFPLENBQUMsSUFBRCxFQUFPRixrQkFBUCxDQUFQLENBQWtDUixXQUFsQyxDOztBQUFBOzs7Ozs7Ozs7OzBCQXJEVEEsVzswQkE2Q0FRLGtCIiwiZmlsZSI6Im1haW5fd2luZG93LjM3ZDRlNmZlNjE5MmJmNGI1ZDZhLmhvdC11cGRhdGUuanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgUmVhY3QgZnJvbSBcInJlYWN0XCI7XG5pbXBvcnQgeyB1c2VIaXN0b3J5IH0gZnJvbSBcInJlYWN0LXJvdXRlci1kb21cIjtcbmltcG9ydCBcIi4vTXlEYXNoYm9hcmQuc2Nzc1wiO1xuaW1wb3J0IHsgQm94LCBCdXR0b24gfSBmcm9tIFwiQG1hdGVyaWFsLXVpL2NvcmVcIjtcbmltcG9ydCBpbnRsIGZyb20gXCJyZWFjdC1pbnRsLXVuaXZlcnNhbFwiO1xuaW1wb3J0IFByb2ZpbGVDYXJkIGZyb20gXCIuLi9ob21lL1Byb2ZpbGVDYXJkXCJcbmltcG9ydCB7IGNvbm5lY3QgfSBmcm9tIFwicmVhY3QtcmVkdXhcIjtcbmltcG9ydCB7IHNldE5leHRWaWV3IH0gZnJvbSBcIi4uLy4uL3JlZHV4L2FjdGlvbnNcIjtcblxuY29uc3QgTXlEYXNoYm9hcmQgPSAocHJvcHMpID0+IHtcbiAgICBjb25zdCBoaXN0b3J5ID0gdXNlSGlzdG9yeSgpO1xuICAgIGNvbnN0IGhhbmRsZUNsaWNrID0gKCkgPT4ge1xuICAgICAgICBwcm9wcy5zZXROZXh0VmlldygpO1xuICAgICAgICAvLyBoaXN0b3J5LnB1c2goXCIvbmV3LXByb2ZpbGUtZ2VuZXJhbFwiKVxuICAgIH07XG4gICAgcmV0dXJuIChcbiAgICAgICAgPEJveCBpZD1cIkhvbWVcIj5cbiAgICAgICAgICAgIDxoMT5SYWJiaXRtcSBQT0M8L2gxPlxuICAgICAgICAgICAgPEJveD5cbiAgICAgICAgICAgICAgICA8QnV0dG9uIG9uQ2xpY2s9e2hhbmRsZUNsaWNrfT5cbiAgICAgICAgICAgICAgICAgICAge2ludGwuZ2V0KFwiSE9NRV9ORVdfUFJPRklMRV9CVVRUT05cIil9XG4gICAgICAgICAgICAgICAgPC9CdXR0b24+XG4gICAgICAgICAgICAgICAgPEJ1dHRvbj57aW50bC5nZXQoXCJIT01FX0lNUE9SVF9DT05GSUdfQlVUVE9OXCIpfTwvQnV0dG9uPlxuICAgICAgICAgICAgPC9Cb3g+XG4gICAgICAgICAgICA8Qm94IGNsYXNzTmFtZT1cInByb2ZpbGUtY2FyZHNcIj5cbiAgICAgICAgICAgICAgICA8UHJvZmlsZUNhcmRcbiAgICAgICAgICAgICAgICAgICAgc3ViVm1DYXRlZ29yeT1cIlZNV2FyZSB2U3BoZXJlXCJcbiAgICAgICAgICAgICAgICAgICAgcHJvZmlsZU5hbWU9XCJQcm9maWxlIE5hbWVcIlxuICAgICAgICAgICAgICAgICAgICBkb21haW5OYW1lPVwiRG9tYWluIE5hbWVcIlxuICAgICAgICAgICAgICAgICAgICBpcEFkZHJlc3M9XCJJUCBBZGRyZXNzXCJcbiAgICAgICAgICAgICAgICAvPlxuICAgICAgICAgICAgICAgIDxQcm9maWxlQ2FyZFxuICAgICAgICAgICAgICAgICAgICBzdWJWbUNhdGVnb3J5PVwiVk1XYXJlIHZTcGhlcmVcIlxuICAgICAgICAgICAgICAgICAgICBwcm9maWxlTmFtZT1cIlByb2ZpbGUgTmFtZVwiXG4gICAgICAgICAgICAgICAgICAgIGRvbWFpbk5hbWU9XCJEb21haW4gTmFtZVwiXG4gICAgICAgICAgICAgICAgICAgIGlwQWRkcmVzcz1cIklQIEFkZHJlc3NcIlxuICAgICAgICAgICAgICAgIC8+XG4gICAgICAgICAgICAgICAgPFByb2ZpbGVDYXJkXG4gICAgICAgICAgICAgICAgICAgIHN1YlZtQ2F0ZWdvcnk9XCJWTVdhcmUgdlNwaGVyZVwiXG4gICAgICAgICAgICAgICAgICAgIHByb2ZpbGVOYW1lPVwiUHJvZmlsZSBOYW1lXCJcbiAgICAgICAgICAgICAgICAgICAgZG9tYWluTmFtZT1cIkRvbWFpbiBOYW1lXCJcbiAgICAgICAgICAgICAgICAgICAgaXBBZGRyZXNzPVwiSVAgQWRkcmVzc1wiXG4gICAgICAgICAgICAgICAgLz5cbiAgICAgICAgICAgICAgICA8UHJvZmlsZUNhcmRcbiAgICAgICAgICAgICAgICAgICAgc3ViVm1DYXRlZ29yeT1cIlZNV2FyZSB2U3BoZXJlXCJcbiAgICAgICAgICAgICAgICAgICAgcHJvZmlsZU5hbWU9XCJQcm9maWxlIE5hbWVcIlxuICAgICAgICAgICAgICAgICAgICBkb21haW5OYW1lPVwiRG9tYWluIE5hbWVcIlxuICAgICAgICAgICAgICAgICAgICBpcEFkZHJlc3M9XCJJUCBBZGRyZXNzXCJcbiAgICAgICAgICAgICAgICAvPlxuICAgICAgICAgICAgPC9Cb3g+XG4gICAgICAgIDwvQm94PlxuICAgICk7XG59O1xuXG5jb25zdCBtYXBEaXNwYXRjaFRvUHJvcHMgPSAoZGlzcGF0Y2gpID0+IHtcbiAgICByZXR1cm4ge1xuICAgICAgICBzZXROZXh0VmlldzogKCkgPT4ge1xuICAgICAgICAgICAgZGlzcGF0Y2goc2V0TmV4dFZpZXcoKSlcbiAgICAgICAgfVxuICAgIH1cbn1cblxuZXhwb3J0IGRlZmF1bHQgY29ubmVjdChudWxsLCBtYXBEaXNwYXRjaFRvUHJvcHMpKE15RGFzaGJvYXJkKTtcbiJdLCJzb3VyY2VSb290IjoiIn0=