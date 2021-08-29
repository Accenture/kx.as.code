webpackHotUpdate("main_window",{

/***/ "./src/components/applications/ApplicationCard.jsx":
/*!*********************************************************!*\
  !*** ./src/components/applications/ApplicationCard.jsx ***!
  \*********************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* WEBPACK VAR INJECTION */(function(module) {/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react */ "./node_modules/react/index.js");
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _home_ProfileCard_scss__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../home/ProfileCard.scss */ "./src/components/home/ProfileCard.scss");
/* harmony import */ var _home_ProfileCard_scss__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_home_ProfileCard_scss__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _material_ui_core__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @material-ui/core */ "./node_modules/@material-ui/core/esm/index.js");
function _typeof(obj) { "@babel/helpers - typeof"; if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

(function () {
  var enterModule = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal.enterModule : undefined;
  enterModule && enterModule(module);
})();

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





var ApplicationCard = /*#__PURE__*/function (_Component) {
  _inherits(ApplicationCard, _Component);

  var _super = _createSuper(ApplicationCard);

  function ApplicationCard() {
    var _this;

    _classCallCheck(this, ApplicationCard);

    _this = _super.call(this);
    _this.state = {};
    return _this;
  }

  _createClass(ApplicationCard, [{
    key: "render",
    value: function render() {
      return /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_2__["Box"], {
        className: "ProfileCard"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_2__["Box"], {
        className: "info-column"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("span", null, props.subVmCategory), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("span", null, props.profileName), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("span", null, props.domainName), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("span", null, props.ipAddress)), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_2__["Box"], {
        className: "action-column"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_2__["Button"], {
        className: "prof-card-btn-duplicate"
      }, "DUPLICATE"), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_2__["Button"], {
        className: "prof-card-btn-delete"
      }, "DELETE"), /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_material_ui_core__WEBPACK_IMPORTED_MODULE_2__["Button"], {
        className: "prof-card-btn-chevron-right"
      }, /*#__PURE__*/react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(FontAwesomeIcon, {
        icon: "chevron-right"
      }))));
    }
  }, {
    key: "__reactstandin__regenerateByEval",
    // @ts-ignore
    value: function __reactstandin__regenerateByEval(key, code) {
      // @ts-ignore
      this[key] = eval(code);
    }
  }]);

  return ApplicationCard;
}(react__WEBPACK_IMPORTED_MODULE_0__["Component"]);

var _default = ApplicationCard;
/* harmony default export */ __webpack_exports__["default"] = (_default);
;

(function () {
  var reactHotLoader = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal.default : undefined;

  if (!reactHotLoader) {
    return;
  }

  reactHotLoader.register(ApplicationCard, "ApplicationCard", "/Users/burak.kayaalp/dev/kx.as.code/client/src/components/applications/ApplicationCard.jsx");
  reactHotLoader.register(_default, "default", "/Users/burak.kayaalp/dev/kx.as.code/client/src/components/applications/ApplicationCard.jsx");
})();

;

(function () {
  var leaveModule = typeof reactHotLoaderGlobal !== 'undefined' ? reactHotLoaderGlobal.leaveModule : undefined;
  leaveModule && leaveModule(module);
})();
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./../../../node_modules/webpack/buildin/harmony-module.js */ "./node_modules/webpack/buildin/harmony-module.js")(module)))

/***/ })

})
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vLi9zcmMvY29tcG9uZW50cy9hcHBsaWNhdGlvbnMvQXBwbGljYXRpb25DYXJkLmpzeCJdLCJuYW1lcyI6WyJBcHBsaWNhdGlvbkNhcmQiLCJzdGF0ZSIsInByb3BzIiwic3ViVm1DYXRlZ29yeSIsInByb2ZpbGVOYW1lIiwiZG9tYWluTmFtZSIsImlwQWRkcmVzcyIsIkNvbXBvbmVudCJdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7QUFBQTtBQUNBO0FBQ0E7O0lBRU1BLGU7Ozs7O0FBQ0YsNkJBQWM7QUFBQTs7QUFBQTs7QUFDVjtBQUNBLFVBQUtDLEtBQUwsR0FBYSxFQUFiO0FBRlU7QUFHYjs7Ozs2QkFDUTtBQUNMLDBCQUNJLDJEQUFDLHFEQUFEO0FBQUssaUJBQVMsRUFBQztBQUFmLHNCQUNBLDJEQUFDLHFEQUFEO0FBQUssaUJBQVMsRUFBQztBQUFmLHNCQUNFLHlFQUFPQyxLQUFLLENBQUNDLGFBQWIsQ0FERixlQUVFLHlFQUFPRCxLQUFLLENBQUNFLFdBQWIsQ0FGRixlQUdFLHlFQUFPRixLQUFLLENBQUNHLFVBQWIsQ0FIRixlQUlFLHlFQUFPSCxLQUFLLENBQUNJLFNBQWIsQ0FKRixDQURBLGVBT0EsMkRBQUMscURBQUQ7QUFBSyxpQkFBUyxFQUFDO0FBQWYsc0JBQ0UsMkRBQUMsd0RBQUQ7QUFBUSxpQkFBUyxFQUFDO0FBQWxCLHFCQURGLGVBRUUsMkRBQUMsd0RBQUQ7QUFBUSxpQkFBUyxFQUFDO0FBQWxCLGtCQUZGLGVBR0UsMkRBQUMsd0RBQUQ7QUFBUSxpQkFBUyxFQUFDO0FBQWxCLHNCQUNFLDJEQUFDLGVBQUQ7QUFBaUIsWUFBSSxFQUFDO0FBQXRCLFFBREYsQ0FIRixDQVBBLENBREo7QUFpQkg7Ozs7Ozs7Ozs7O0VBdkJ5QkMsK0M7O2VBMEJmUCxlO0FBQUE7Ozs7Ozs7Ozs7MEJBMUJUQSxlIiwiZmlsZSI6Im1haW5fd2luZG93LjU4NGMyNGRhNTY3NWEyMTc1NDZhLmhvdC11cGRhdGUuanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgUmVhY3QsIHsgQ29tcG9uZW50IH0gZnJvbSBcInJlYWN0XCI7XG5pbXBvcnQgXCIuLi9ob21lL1Byb2ZpbGVDYXJkLnNjc3NcIlxuaW1wb3J0IHsgQm94LCBCdXR0b24gfSBmcm9tIFwiQG1hdGVyaWFsLXVpL2NvcmVcIjtcblxuY2xhc3MgQXBwbGljYXRpb25DYXJkIGV4dGVuZHMgQ29tcG9uZW50IHtcbiAgICBjb25zdHJ1Y3RvcigpIHtcbiAgICAgICAgc3VwZXIoKTtcbiAgICAgICAgdGhpcy5zdGF0ZSA9IHsgIH1cbiAgICB9XG4gICAgcmVuZGVyKCkgeyBcbiAgICAgICAgcmV0dXJuICggIFxuICAgICAgICAgICAgPEJveCBjbGFzc05hbWU9XCJQcm9maWxlQ2FyZFwiPlxuICAgICAgICAgICAgPEJveCBjbGFzc05hbWU9XCJpbmZvLWNvbHVtblwiID5cbiAgICAgICAgICAgICAgPHNwYW4+e3Byb3BzLnN1YlZtQ2F0ZWdvcnl9PC9zcGFuPlxuICAgICAgICAgICAgICA8c3Bhbj57cHJvcHMucHJvZmlsZU5hbWV9PC9zcGFuPlxuICAgICAgICAgICAgICA8c3Bhbj57cHJvcHMuZG9tYWluTmFtZX08L3NwYW4+XG4gICAgICAgICAgICAgIDxzcGFuPntwcm9wcy5pcEFkZHJlc3N9PC9zcGFuPiBcbiAgICAgICAgICAgIDwvQm94PlxuICAgICAgICAgICAgPEJveCBjbGFzc05hbWU9XCJhY3Rpb24tY29sdW1uXCI+XG4gICAgICAgICAgICAgIDxCdXR0b24gY2xhc3NOYW1lPVwicHJvZi1jYXJkLWJ0bi1kdXBsaWNhdGVcIj5EVVBMSUNBVEU8L0J1dHRvbj5cbiAgICAgICAgICAgICAgPEJ1dHRvbiBjbGFzc05hbWU9XCJwcm9mLWNhcmQtYnRuLWRlbGV0ZVwiPkRFTEVURTwvQnV0dG9uPlxuICAgICAgICAgICAgICA8QnV0dG9uIGNsYXNzTmFtZT1cInByb2YtY2FyZC1idG4tY2hldnJvbi1yaWdodFwiPlxuICAgICAgICAgICAgICAgIDxGb250QXdlc29tZUljb24gaWNvbj1cImNoZXZyb24tcmlnaHRcIiAvPlxuICAgICAgICAgICAgICA8L0J1dHRvbj5cbiAgICAgICAgICAgIDwvQm94PlxuICAgICAgICAgIDwvQm94PlxuICAgICAgICApO1xuICAgIH1cbn1cbiBcbmV4cG9ydCBkZWZhdWx0IEFwcGxpY2F0aW9uQ2FyZDsiXSwic291cmNlUm9vdCI6IiJ9