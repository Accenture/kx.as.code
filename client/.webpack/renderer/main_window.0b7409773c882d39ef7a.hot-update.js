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
  }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("h1", null, react_intl_universal__WEBPACK_IMPORTED_MODULE_4___default.a.get("HOME_TITLE")), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("p", null, react_intl_universal__WEBPACK_IMPORTED_MODULE_4___default.a.get("HOME_SUBTITLE")), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_3__["Box"], null, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_3__["Button"], {
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
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vLi9zcmMvY29tcG9uZW50cy9kYXNoYm9hcmQvTXlEYXNoYm9hcmQuanN4Il0sIm5hbWVzIjpbIk15RGFzaGJvYXJkIiwicHJvcHMiLCJoaXN0b3J5IiwidXNlSGlzdG9yeSIsImhhbmRsZUNsaWNrIiwic2V0TmV4dFZpZXciLCJwdXNoIiwiaW50bCIsImdldCIsIm1hcERpc3BhdGNoVG9Qcm9wcyIsImRpc3BhdGNoIiwiY29ubmVjdCJdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7OztBQUFBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7O0FBRUEsSUFBTUEsV0FBVyxHQUFHLFNBQWRBLFdBQWMsQ0FBQ0MsS0FBRCxFQUFXO0FBQzdCLE1BQU1DLE9BQU8sR0FBR0MsbUVBQVUsRUFBMUI7O0FBQ0EsTUFBTUMsV0FBVyxHQUFHLFNBQWRBLFdBQWMsR0FBTTtBQUN4QkgsU0FBSyxDQUFDSSxXQUFOO0FBQ0FILFdBQU8sQ0FBQ0ksSUFBUixDQUFhLHNCQUFiO0FBQ0QsR0FIRDs7QUFJQSxzQkFDRSwyREFBQyxxREFBRDtBQUFLLE1BQUUsRUFBQztBQUFSLGtCQUNBLHVFQUFLQywyREFBSSxDQUFDQyxHQUFMLENBQVMsWUFBVCxDQUFMLENBREEsZUFFQSxzRUFBSUQsMkRBQUksQ0FBQ0MsR0FBTCxDQUFTLGVBQVQsQ0FBSixDQUZBLGVBSUEsMkRBQUMscURBQUQscUJBQ0UsMkRBQUMsd0RBQUQ7QUFBUSxXQUFPLEVBQUVKO0FBQWpCLEtBQ0dHLDJEQUFJLENBQUNDLEdBQUwsQ0FBUyx5QkFBVCxDQURILENBREYsZUFJRSwyREFBQyx3REFBRCxRQUFTRCwyREFBSSxDQUFDQyxHQUFMLENBQVMsMkJBQVQsQ0FBVCxDQUpGLENBSkEsZUFVQSwyREFBQyxxREFBRDtBQUFLLGFBQVMsRUFBQztBQUFmLGtCQUNFLDJEQUFDLHlEQUFEO0FBQ0UsaUJBQWEsRUFBQyxnQkFEaEI7QUFFRSxlQUFXLEVBQUMsY0FGZDtBQUdFLGNBQVUsRUFBQyxhQUhiO0FBSUUsYUFBUyxFQUFDO0FBSlosSUFERixlQU9FLDJEQUFDLHlEQUFEO0FBQ0UsaUJBQWEsRUFBQyxnQkFEaEI7QUFFRSxlQUFXLEVBQUMsY0FGZDtBQUdFLGNBQVUsRUFBQyxhQUhiO0FBSUUsYUFBUyxFQUFDO0FBSlosSUFQRixlQWFFLDJEQUFDLHlEQUFEO0FBQ0UsaUJBQWEsRUFBQyxnQkFEaEI7QUFFRSxlQUFXLEVBQUMsY0FGZDtBQUdFLGNBQVUsRUFBQyxhQUhiO0FBSUUsYUFBUyxFQUFDO0FBSlosSUFiRixlQW1CRSwyREFBQyx5REFBRDtBQUNFLGlCQUFhLEVBQUMsZ0JBRGhCO0FBRUUsZUFBVyxFQUFDLGNBRmQ7QUFHRSxjQUFVLEVBQUMsYUFIYjtBQUlFLGFBQVMsRUFBQztBQUpaLElBbkJGLENBVkEsQ0FERjtBQXVDRCxDQTdDRDs7Y0FBTVIsVztVQUNZRywyRDs7O0FBOENsQixJQUFNTSxrQkFBa0IsR0FBRyxTQUFyQkEsa0JBQXFCLENBQUNDLFFBQUQsRUFBYztBQUN2QyxTQUFPO0FBQ0xMLGVBQVcsRUFBRSx1QkFBTTtBQUNiSyxjQUFRLENBQUNMLGtFQUFXLEVBQVosQ0FBUjtBQUNIO0FBSEUsR0FBUDtBQUtELENBTkQ7O2VBUWVNLDJEQUFPLENBQUMsSUFBRCxFQUFPRixrQkFBUCxDQUFQLENBQWtDVCxXQUFsQyxDOztBQUFBOzs7Ozs7Ozs7OzBCQXZEVEEsVzswQkErQ0FTLGtCIiwiZmlsZSI6Im1haW5fd2luZG93LjBiNzQwOTc3M2M4ODJkMzllZjdhLmhvdC11cGRhdGUuanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgUmVhY3QgZnJvbSBcInJlYWN0XCI7XG5pbXBvcnQgeyB1c2VIaXN0b3J5IH0gZnJvbSBcInJlYWN0LXJvdXRlci1kb21cIjtcbmltcG9ydCBcIi4vTXlEYXNoYm9hcmQuc2Nzc1wiO1xuaW1wb3J0IHsgQm94LCBCdXR0b24gfSBmcm9tIFwiQG1hdGVyaWFsLXVpL2NvcmVcIjtcbmltcG9ydCBpbnRsIGZyb20gXCJyZWFjdC1pbnRsLXVuaXZlcnNhbFwiO1xuaW1wb3J0IFByb2ZpbGVDYXJkIGZyb20gXCIuLi9ob21lL1Byb2ZpbGVDYXJkXCJcbmltcG9ydCB7IGNvbm5lY3QgfSBmcm9tIFwicmVhY3QtcmVkdXhcIjtcbmltcG9ydCB7IHNldE5leHRWaWV3IH0gZnJvbSBcIi4uLy4uL3JlZHV4L2FjdGlvbnNcIjtcblxuY29uc3QgTXlEYXNoYm9hcmQgPSAocHJvcHMpID0+IHtcbiAgY29uc3QgaGlzdG9yeSA9IHVzZUhpc3RvcnkoKTtcbiAgY29uc3QgaGFuZGxlQ2xpY2sgPSAoKSA9PiB7XG4gICAgcHJvcHMuc2V0TmV4dFZpZXcoKTtcbiAgICBoaXN0b3J5LnB1c2goXCIvbmV3LXByb2ZpbGUtZ2VuZXJhbFwiKVxuICB9O1xuICByZXR1cm4gKFxuICAgIDxCb3ggaWQ9XCJIb21lXCI+XG4gICAgPGgxPntpbnRsLmdldChcIkhPTUVfVElUTEVcIil9PC9oMT5cbiAgICA8cD57aW50bC5nZXQoXCJIT01FX1NVQlRJVExFXCIpfTwvcD5cblxuICAgIDxCb3g+XG4gICAgICA8QnV0dG9uIG9uQ2xpY2s9e2hhbmRsZUNsaWNrfT5cbiAgICAgICAge2ludGwuZ2V0KFwiSE9NRV9ORVdfUFJPRklMRV9CVVRUT05cIil9XG4gICAgICA8L0J1dHRvbj5cbiAgICAgIDxCdXR0b24+e2ludGwuZ2V0KFwiSE9NRV9JTVBPUlRfQ09ORklHX0JVVFRPTlwiKX08L0J1dHRvbj5cbiAgICA8L0JveD5cbiAgICA8Qm94IGNsYXNzTmFtZT1cInByb2ZpbGUtY2FyZHNcIj5cbiAgICAgIDxQcm9maWxlQ2FyZFxuICAgICAgICBzdWJWbUNhdGVnb3J5PVwiVk1XYXJlIHZTcGhlcmVcIlxuICAgICAgICBwcm9maWxlTmFtZT1cIlByb2ZpbGUgTmFtZVwiXG4gICAgICAgIGRvbWFpbk5hbWU9XCJEb21haW4gTmFtZVwiXG4gICAgICAgIGlwQWRkcmVzcz1cIklQIEFkZHJlc3NcIlxuICAgICAgLz5cbiAgICAgIDxQcm9maWxlQ2FyZFxuICAgICAgICBzdWJWbUNhdGVnb3J5PVwiVk1XYXJlIHZTcGhlcmVcIlxuICAgICAgICBwcm9maWxlTmFtZT1cIlByb2ZpbGUgTmFtZVwiXG4gICAgICAgIGRvbWFpbk5hbWU9XCJEb21haW4gTmFtZVwiXG4gICAgICAgIGlwQWRkcmVzcz1cIklQIEFkZHJlc3NcIlxuICAgICAgLz5cbiAgICAgIDxQcm9maWxlQ2FyZFxuICAgICAgICBzdWJWbUNhdGVnb3J5PVwiVk1XYXJlIHZTcGhlcmVcIlxuICAgICAgICBwcm9maWxlTmFtZT1cIlByb2ZpbGUgTmFtZVwiXG4gICAgICAgIGRvbWFpbk5hbWU9XCJEb21haW4gTmFtZVwiXG4gICAgICAgIGlwQWRkcmVzcz1cIklQIEFkZHJlc3NcIlxuICAgICAgLz5cbiAgICAgIDxQcm9maWxlQ2FyZFxuICAgICAgICBzdWJWbUNhdGVnb3J5PVwiVk1XYXJlIHZTcGhlcmVcIlxuICAgICAgICBwcm9maWxlTmFtZT1cIlByb2ZpbGUgTmFtZVwiXG4gICAgICAgIGRvbWFpbk5hbWU9XCJEb21haW4gTmFtZVwiXG4gICAgICAgIGlwQWRkcmVzcz1cIklQIEFkZHJlc3NcIlxuICAgICAgLz5cbiAgICA8L0JveD5cbiAgPC9Cb3g+XG4gICk7XG59O1xuXG5jb25zdCBtYXBEaXNwYXRjaFRvUHJvcHMgPSAoZGlzcGF0Y2gpID0+IHtcbiAgcmV0dXJuIHtcbiAgICBzZXROZXh0VmlldzogKCkgPT4ge1xuICAgICAgICAgIGRpc3BhdGNoKHNldE5leHRWaWV3KCkpXG4gICAgICB9XG4gIH1cbn1cblxuZXhwb3J0IGRlZmF1bHQgY29ubmVjdChudWxsLCBtYXBEaXNwYXRjaFRvUHJvcHMpKE15RGFzaGJvYXJkKTtcbiJdLCJzb3VyY2VSb290IjoiIn0=