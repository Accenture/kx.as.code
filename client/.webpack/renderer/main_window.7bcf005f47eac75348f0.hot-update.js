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
  }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("h1", null, "Rabbitmq POC"), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_3__["Box"], {
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
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vLi9zcmMvY29tcG9uZW50cy9kYXNoYm9hcmQvTXlEYXNoYm9hcmQuanN4Il0sIm5hbWVzIjpbIk15RGFzaGJvYXJkIiwicHJvcHMiLCJoaXN0b3J5IiwidXNlSGlzdG9yeSIsImhhbmRsZUNsaWNrIiwic2V0TmV4dFZpZXciLCJtYXBEaXNwYXRjaFRvUHJvcHMiLCJkaXNwYXRjaCIsImNvbm5lY3QiXSwibWFwcGluZ3MiOiI7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7QUFBQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBOztBQUVBLElBQU1BLFdBQVcsR0FBRyxTQUFkQSxXQUFjLENBQUNDLEtBQUQsRUFBVztBQUMzQixNQUFNQyxPQUFPLEdBQUdDLG1FQUFVLEVBQTFCOztBQUNBLE1BQU1DLFdBQVcsR0FBRyxTQUFkQSxXQUFjLEdBQU07QUFDdEJILFNBQUssQ0FBQ0ksV0FBTixHQURzQixDQUV0QjtBQUNILEdBSEQ7O0FBSUEsc0JBQ0ksMkRBQUMscURBQUQ7QUFBSyxNQUFFLEVBQUM7QUFBUixrQkFDSSxzRkFESixlQUVJLDJEQUFDLHFEQUFEO0FBQUssYUFBUyxFQUFDO0FBQWYsa0JBQ0ksMkRBQUMseURBQUQ7QUFDSSxpQkFBYSxFQUFDLGdCQURsQjtBQUVJLGVBQVcsRUFBQyxjQUZoQjtBQUdJLGNBQVUsRUFBQyxhQUhmO0FBSUksYUFBUyxFQUFDO0FBSmQsSUFESixlQU9JLDJEQUFDLHlEQUFEO0FBQ0ksaUJBQWEsRUFBQyxnQkFEbEI7QUFFSSxlQUFXLEVBQUMsY0FGaEI7QUFHSSxjQUFVLEVBQUMsYUFIZjtBQUlJLGFBQVMsRUFBQztBQUpkLElBUEosZUFhSSwyREFBQyx5REFBRDtBQUNJLGlCQUFhLEVBQUMsZ0JBRGxCO0FBRUksZUFBVyxFQUFDLGNBRmhCO0FBR0ksY0FBVSxFQUFDLGFBSGY7QUFJSSxhQUFTLEVBQUM7QUFKZCxJQWJKLGVBbUJJLDJEQUFDLHlEQUFEO0FBQ0ksaUJBQWEsRUFBQyxnQkFEbEI7QUFFSSxlQUFXLEVBQUMsY0FGaEI7QUFHSSxjQUFVLEVBQUMsYUFIZjtBQUlJLGFBQVMsRUFBQztBQUpkLElBbkJKLENBRkosQ0FESjtBQStCSCxDQXJDRDs7Y0FBTUwsVztVQUNjRywyRDs7O0FBc0NwQixJQUFNRyxrQkFBa0IsR0FBRyxTQUFyQkEsa0JBQXFCLENBQUNDLFFBQUQsRUFBYztBQUNyQyxTQUFPO0FBQ0hGLGVBQVcsRUFBRSx1QkFBTTtBQUNmRSxjQUFRLENBQUNGLGtFQUFXLEVBQVosQ0FBUjtBQUNIO0FBSEUsR0FBUDtBQUtILENBTkQ7O2VBUWVHLDJEQUFPLENBQUMsSUFBRCxFQUFPRixrQkFBUCxDQUFQLENBQWtDTixXQUFsQyxDOztBQUFBOzs7Ozs7Ozs7OzBCQS9DVEEsVzswQkF1Q0FNLGtCIiwiZmlsZSI6Im1haW5fd2luZG93LjdiY2YwMDVmNDdlYWM3NTM0OGYwLmhvdC11cGRhdGUuanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgUmVhY3QgZnJvbSBcInJlYWN0XCI7XG5pbXBvcnQgeyB1c2VIaXN0b3J5IH0gZnJvbSBcInJlYWN0LXJvdXRlci1kb21cIjtcbmltcG9ydCBcIi4vTXlEYXNoYm9hcmQuc2Nzc1wiO1xuaW1wb3J0IHsgQm94LCBCdXR0b24gfSBmcm9tIFwiQG1hdGVyaWFsLXVpL2NvcmVcIjtcbmltcG9ydCBpbnRsIGZyb20gXCJyZWFjdC1pbnRsLXVuaXZlcnNhbFwiO1xuaW1wb3J0IFByb2ZpbGVDYXJkIGZyb20gXCIuLi9ob21lL1Byb2ZpbGVDYXJkXCJcbmltcG9ydCB7IGNvbm5lY3QgfSBmcm9tIFwicmVhY3QtcmVkdXhcIjtcbmltcG9ydCB7IHNldE5leHRWaWV3IH0gZnJvbSBcIi4uLy4uL3JlZHV4L2FjdGlvbnNcIjtcblxuY29uc3QgTXlEYXNoYm9hcmQgPSAocHJvcHMpID0+IHtcbiAgICBjb25zdCBoaXN0b3J5ID0gdXNlSGlzdG9yeSgpO1xuICAgIGNvbnN0IGhhbmRsZUNsaWNrID0gKCkgPT4ge1xuICAgICAgICBwcm9wcy5zZXROZXh0VmlldygpO1xuICAgICAgICAvLyBoaXN0b3J5LnB1c2goXCIvbmV3LXByb2ZpbGUtZ2VuZXJhbFwiKVxuICAgIH07XG4gICAgcmV0dXJuIChcbiAgICAgICAgPEJveCBpZD1cIkhvbWVcIj5cbiAgICAgICAgICAgIDxoMT5SYWJiaXRtcSBQT0M8L2gxPlxuICAgICAgICAgICAgPEJveCBjbGFzc05hbWU9XCJwcm9maWxlLWNhcmRzXCI+XG4gICAgICAgICAgICAgICAgPFByb2ZpbGVDYXJkXG4gICAgICAgICAgICAgICAgICAgIHN1YlZtQ2F0ZWdvcnk9XCJWTVdhcmUgdlNwaGVyZVwiXG4gICAgICAgICAgICAgICAgICAgIHByb2ZpbGVOYW1lPVwiUHJvZmlsZSBOYW1lXCJcbiAgICAgICAgICAgICAgICAgICAgZG9tYWluTmFtZT1cIkRvbWFpbiBOYW1lXCJcbiAgICAgICAgICAgICAgICAgICAgaXBBZGRyZXNzPVwiSVAgQWRkcmVzc1wiXG4gICAgICAgICAgICAgICAgLz5cbiAgICAgICAgICAgICAgICA8UHJvZmlsZUNhcmRcbiAgICAgICAgICAgICAgICAgICAgc3ViVm1DYXRlZ29yeT1cIlZNV2FyZSB2U3BoZXJlXCJcbiAgICAgICAgICAgICAgICAgICAgcHJvZmlsZU5hbWU9XCJQcm9maWxlIE5hbWVcIlxuICAgICAgICAgICAgICAgICAgICBkb21haW5OYW1lPVwiRG9tYWluIE5hbWVcIlxuICAgICAgICAgICAgICAgICAgICBpcEFkZHJlc3M9XCJJUCBBZGRyZXNzXCJcbiAgICAgICAgICAgICAgICAvPlxuICAgICAgICAgICAgICAgIDxQcm9maWxlQ2FyZFxuICAgICAgICAgICAgICAgICAgICBzdWJWbUNhdGVnb3J5PVwiVk1XYXJlIHZTcGhlcmVcIlxuICAgICAgICAgICAgICAgICAgICBwcm9maWxlTmFtZT1cIlByb2ZpbGUgTmFtZVwiXG4gICAgICAgICAgICAgICAgICAgIGRvbWFpbk5hbWU9XCJEb21haW4gTmFtZVwiXG4gICAgICAgICAgICAgICAgICAgIGlwQWRkcmVzcz1cIklQIEFkZHJlc3NcIlxuICAgICAgICAgICAgICAgIC8+XG4gICAgICAgICAgICAgICAgPFByb2ZpbGVDYXJkXG4gICAgICAgICAgICAgICAgICAgIHN1YlZtQ2F0ZWdvcnk9XCJWTVdhcmUgdlNwaGVyZVwiXG4gICAgICAgICAgICAgICAgICAgIHByb2ZpbGVOYW1lPVwiUHJvZmlsZSBOYW1lXCJcbiAgICAgICAgICAgICAgICAgICAgZG9tYWluTmFtZT1cIkRvbWFpbiBOYW1lXCJcbiAgICAgICAgICAgICAgICAgICAgaXBBZGRyZXNzPVwiSVAgQWRkcmVzc1wiXG4gICAgICAgICAgICAgICAgLz5cbiAgICAgICAgICAgIDwvQm94PlxuICAgICAgICA8L0JveD5cbiAgICApO1xufTtcblxuY29uc3QgbWFwRGlzcGF0Y2hUb1Byb3BzID0gKGRpc3BhdGNoKSA9PiB7XG4gICAgcmV0dXJuIHtcbiAgICAgICAgc2V0TmV4dFZpZXc6ICgpID0+IHtcbiAgICAgICAgICAgIGRpc3BhdGNoKHNldE5leHRWaWV3KCkpXG4gICAgICAgIH1cbiAgICB9XG59XG5cbmV4cG9ydCBkZWZhdWx0IGNvbm5lY3QobnVsbCwgbWFwRGlzcGF0Y2hUb1Byb3BzKShNeURhc2hib2FyZCk7XG4iXSwic291cmNlUm9vdCI6IiJ9