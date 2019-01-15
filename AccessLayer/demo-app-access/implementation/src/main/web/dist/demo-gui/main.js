(window["webpackJsonp"] = window["webpackJsonp"] || []).push([["main"],{

/***/ "./src/$$_lazy_route_resource lazy recursive":
/*!**********************************************************!*\
  !*** ./src/$$_lazy_route_resource lazy namespace object ***!
  \**********************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

function webpackEmptyAsyncContext(req) {
	// Here Promise.resolve().then() is used instead of new Promise() to prevent
	// uncaught exception popping up in devtools
	return Promise.resolve().then(function() {
		var e = new Error("Cannot find module '" + req + "'");
		e.code = 'MODULE_NOT_FOUND';
		throw e;
	});
}
webpackEmptyAsyncContext.keys = function() { return []; };
webpackEmptyAsyncContext.resolve = webpackEmptyAsyncContext;
module.exports = webpackEmptyAsyncContext;
webpackEmptyAsyncContext.id = "./src/$$_lazy_route_resource lazy recursive";

/***/ }),

/***/ "./src/app/admin/admin.component.css":
/*!*******************************************!*\
  !*** ./src/app/admin/admin.component.css ***!
  \*******************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "\n/*# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IiIsImZpbGUiOiJzcmMvYXBwL2FkbWluL2FkbWluLmNvbXBvbmVudC5jc3MifQ== */"

/***/ }),

/***/ "./src/app/admin/admin.component.html":
/*!********************************************!*\
  !*** ./src/app/admin/admin.component.html ***!
  \********************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "<h3 class=\"text-center\">\n  Admin GUI - Admin Gateway\n</h3>\n<div class=\"lead\">\n  <p>This side of page represents access to <kbd>admin-gateway</kbd> controllers.</p>\n</div>\n<app-stats></app-stats>\n"

/***/ }),

/***/ "./src/app/admin/admin.component.ts":
/*!******************************************!*\
  !*** ./src/app/admin/admin.component.ts ***!
  \******************************************/
/*! exports provided: AdminComponent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "AdminComponent", function() { return AdminComponent; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");


var AdminComponent = /** @class */ (function () {
    function AdminComponent() {
    }
    AdminComponent.prototype.ngOnInit = function () {
    };
    AdminComponent = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Component"])({
            selector: 'app-admin',
            template: __webpack_require__(/*! ./admin.component.html */ "./src/app/admin/admin.component.html"),
            styles: [__webpack_require__(/*! ./admin.component.css */ "./src/app/admin/admin.component.css")]
        }),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:paramtypes", [])
    ], AdminComponent);
    return AdminComponent;
}());



/***/ }),

/***/ "./src/app/admin/event-list/event-item/event-item.component.css":
/*!**********************************************************************!*\
  !*** ./src/app/admin/event-list/event-item/event-item.component.css ***!
  \**********************************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "\n/*# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IiIsImZpbGUiOiJzcmMvYXBwL2FkbWluL2V2ZW50LWxpc3QvZXZlbnQtaXRlbS9ldmVudC1pdGVtLmNvbXBvbmVudC5jc3MifQ== */"

/***/ }),

/***/ "./src/app/admin/event-list/event-item/event-item.component.html":
/*!***********************************************************************!*\
  !*** ./src/app/admin/event-list/event-item/event-item.component.html ***!
  \***********************************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "<div class=\"row clearfix\">\n\n  <div class=\"col-md-4 pull-left\">\n    <h4 class=\"list-group-item-heading\">Event</h4>\n    <p class=\"list-group-item-text\">{{eventView.name}}</p>\n  </div>\n  <div class=\"col-md-8 pull-right\">\n    <h4 class=\"list-group-item-heading\">Properties</h4>\n    <ul class=\"list-group-item-text\">\n      <li *ngFor=\"let item of eventView.params | keyvalue\">\n        {{item.key}}:{{item.value}}\n      </li>\n    </ul>\n  </div>\n\n</div>\n"

/***/ }),

/***/ "./src/app/admin/event-list/event-item/event-item.component.ts":
/*!*********************************************************************!*\
  !*** ./src/app/admin/event-list/event-item/event-item.component.ts ***!
  \*********************************************************************/
/*! exports provided: EventItemComponent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "EventItemComponent", function() { return EventItemComponent; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var _event_model__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../event.model */ "./src/app/admin/event-list/event.model.ts");



var EventItemComponent = /** @class */ (function () {
    function EventItemComponent() {
    }
    EventItemComponent.prototype.ngOnInit = function () {
    };
    tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Input"])(),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:type", _event_model__WEBPACK_IMPORTED_MODULE_2__["EventView"])
    ], EventItemComponent.prototype, "eventView", void 0);
    EventItemComponent = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Component"])({
            selector: 'app-event-item',
            template: __webpack_require__(/*! ./event-item.component.html */ "./src/app/admin/event-list/event-item/event-item.component.html"),
            styles: [__webpack_require__(/*! ./event-item.component.css */ "./src/app/admin/event-list/event-item/event-item.component.css")]
        }),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:paramtypes", [])
    ], EventItemComponent);
    return EventItemComponent;
}());



/***/ }),

/***/ "./src/app/admin/event-list/event-list-client.service.ts":
/*!***************************************************************!*\
  !*** ./src/app/admin/event-list/event-list-client.service.ts ***!
  \***************************************************************/
/*! exports provided: EventListClientService */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "EventListClientService", function() { return EventListClientService; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var _angular_common_http__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @angular/common/http */ "./node_modules/@angular/common/fesm5/http.js");



var EventListClientService = /** @class */ (function () {
    function EventListClientService(http) {
        this.http = http;
        this.serviceAddress = 'http://127.0.0.1:8000/admin-gateway/events/all';
    }
    EventListClientService.prototype.allEvents = function () {
        var httpOptions = {
            headers: new _angular_common_http__WEBPACK_IMPORTED_MODULE_2__["HttpHeaders"]({
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            })
        };
        return this.http.get(this.serviceAddress, httpOptions).toPromise()
            .then(function (response) { return response; })
            .catch(function (reason) {
            console.error(reason.toString());
            return [];
        });
    };
    EventListClientService = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Injectable"])({
            providedIn: 'root'
        }),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:paramtypes", [_angular_common_http__WEBPACK_IMPORTED_MODULE_2__["HttpClient"]])
    ], EventListClientService);
    return EventListClientService;
}());



/***/ }),

/***/ "./src/app/admin/event-list/event-list.component.css":
/*!***********************************************************!*\
  !*** ./src/app/admin/event-list/event-list.component.css ***!
  \***********************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "\n/*# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IiIsImZpbGUiOiJzcmMvYXBwL2FkbWluL2V2ZW50LWxpc3QvZXZlbnQtbGlzdC5jb21wb25lbnQuY3NzIn0= */"

/***/ }),

/***/ "./src/app/admin/event-list/event-list.component.html":
/*!************************************************************!*\
  !*** ./src/app/admin/event-list/event-list.component.html ***!
  \************************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "<div class=\"row\">\n  <div class=\"col-xs-12\">\n    <button class=\"btn btn-success\" (click)=\"loadEvents()\">Load Events</button>\n  </div>\n</div>\n<hr/>\n<div class=\"row\">\n  <div class=\"col-md-12\">\n\n    <app-event-item *ngFor=\"let ev of eventViews | paginate: {\n    id: 'pag-events',\n    itemsPerPage: 5,\n    currentPage: currentPage\n    }\"\n                     [eventView]=\"ev\"></app-event-item>\n    <pagination-controls (pageChange)=\"currentPage = $event\" id=\"pag-events\"></pagination-controls>\n  </div>\n</div>\n\n"

/***/ }),

/***/ "./src/app/admin/event-list/event-list.component.ts":
/*!**********************************************************!*\
  !*** ./src/app/admin/event-list/event-list.component.ts ***!
  \**********************************************************/
/*! exports provided: EventListComponent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "EventListComponent", function() { return EventListComponent; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var _event_list_client_service__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./event-list-client.service */ "./src/app/admin/event-list/event-list-client.service.ts");



var EventListComponent = /** @class */ (function () {
    function EventListComponent(eventListClient) {
        this.eventListClient = eventListClient;
        this.eventViews = [];
        this.currentPage = 1;
    }
    EventListComponent.prototype.ngOnInit = function () {
    };
    EventListComponent.prototype.loadEvents = function () {
        var _this = this;
        this.eventListClient.allEvents()
            .then(function (ev) {
            _this.eventViews = ev;
        });
    };
    EventListComponent = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Component"])({
            selector: 'app-event-list',
            template: __webpack_require__(/*! ./event-list.component.html */ "./src/app/admin/event-list/event-list.component.html"),
            styles: [__webpack_require__(/*! ./event-list.component.css */ "./src/app/admin/event-list/event-list.component.css")]
        }),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:paramtypes", [_event_list_client_service__WEBPACK_IMPORTED_MODULE_2__["EventListClientService"]])
    ], EventListComponent);
    return EventListComponent;
}());



/***/ }),

/***/ "./src/app/admin/event-list/event.model.ts":
/*!*************************************************!*\
  !*** ./src/app/admin/event-list/event.model.ts ***!
  \*************************************************/
/*! exports provided: EventView */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "EventView", function() { return EventView; });
var EventView = /** @class */ (function () {
    function EventView(name, params) {
        this.name = name;
        this.params = params;
    }
    return EventView;
}());



/***/ }),

/***/ "./src/app/admin/stats/stats.component.css":
/*!*************************************************!*\
  !*** ./src/app/admin/stats/stats.component.css ***!
  \*************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "\n/*# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IiIsImZpbGUiOiJzcmMvYXBwL2FkbWluL3N0YXRzL3N0YXRzLmNvbXBvbmVudC5jc3MifQ== */"

/***/ }),

/***/ "./src/app/admin/stats/stats.component.html":
/*!**************************************************!*\
  !*** ./src/app/admin/stats/stats.component.html ***!
  \**************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "<div class=\"row\">\n  <div class=\"col-md-4\">\n    <button (click)=\"readEvents()\" class=\"btn btn-primary\">Read Event Stream\n    </button>\n  </div>\n  <div class=\"col-md-4\" *ngIf=\"showUnsub\">\n    <button (click)=\"stopEvents()\" class=\"btn btn-danger\">Stop Event Stream\n    </button>\n  </div><div class=\"col-md-4\" [ngClass]=\"{'col-md-offset-4': !showUnsub }\">\n    <button (click)=\"resetCounters()\" class=\"btn btn-info\">Reset counters\n    </button>\n  </div>\n</div>\n\n<div class=\"row\">\n  <div class=\"col-md-3\">\n    Event name:\n  </div>\n  <div class=\"col-md-9\" [ngSwitch]=\"lastEventName\">\n    <div class=\"row\" *ngSwitchCase=\"'CreateCustomerRequestEvent'\">\n      <div class=\"col-md-3 active\">Create Customer Request {{ccr}}</div>\n      <div class=\"col-md-3\">Create Customer {{cc}}</div>\n      <div class=\"col-md-3\">Save Customer {{sc}}</div>\n      <div class=\"col-md-3\">Register Customer {{rc}}</div>\n    </div>\n    <div class=\"row\" *ngSwitchCase=\"'CreateCustomerEvent'\">\n      <div class=\"col-md-3\">Create Customer Request {{ccr}}</div>\n      <div class=\"col-md-3 active\">Create Customer  {{cc}}</div>\n      <div class=\"col-md-3\">Save Customer {{sc}}</div>\n      <div class=\"col-md-3\">Register Customer {{rc}}</div>\n    </div>\n    <div class=\"row\" *ngSwitchCase=\"'SaveCustomerEvent'\">\n      <div class=\"col-md-3\">Create Customer Request {{ccr}}</div>\n      <div class=\"col-md-3\">Create Customer  {{cc}}</div>\n      <div class=\"col-md-3 active\">Save Customer {{sc}}</div>\n      <div class=\"col-md-3\">Register Customer {{rc}}</div>\n    </div>\n    <div class=\"row\" *ngSwitchCase=\"'RegisterCustomerEvent'\">\n      <div class=\"col-md-3\">Create Customer Request {{ccr}}</div>\n      <div class=\"col-md-3\">Create Customer  {{cc}}</div>\n      <div class=\"col-md-3\">Save Customer {{sc}}</div>\n      <div class=\"col-md-3 active\">Register Customer {{rc}}</div>\n    </div>\n    <div class=\"row\" *ngSwitchDefault>\n      <div class=\"col-md-3\">Create Customer Request {{ccr}}</div>\n      <div class=\"col-md-3\">Create Customer  {{cc}}</div>\n      <div class=\"col-md-3\">Save Customer {{sc}}</div>\n      <div class=\"col-md-3\">Register Customer {{rc}}</div>\n    </div>\n  </div>\n</div>\n\n<div class=\"row\">\n  <div class=\"col-md-4 pull-left\">\n    <h4 class=\"list-group-item-heading\">Event</h4>\n    <p class=\"list-group-item-text\">Create Customer Request</p>\n  </div>\n  <div class=\"col-md-8 pull-right\">\n    <h4 class=\"list-group-item-heading\">Properties</h4>\n    <ul class=\"list-group-item-text\">\n      <li *ngFor=\"let item of ccrParams.params | keyvalue\">\n        {{item.key}}:{{item.value}}\n      </li>\n    </ul>\n  </div>\n</div>\n<div class=\"row\">\n  <div class=\"col-md-4 pull-left\">\n    <h4 class=\"list-group-item-heading\">Event</h4>\n    <p class=\"list-group-item-text\">Create Customer</p>\n  </div>\n  <div class=\"col-md-8 pull-right\">\n    <h4 class=\"list-group-item-heading\">Properties</h4>\n    <ul class=\"list-group-item-text\">\n      <li *ngFor=\"let item of ccParams.params | keyvalue\">\n        {{item.key}}:{{item.value}}\n      </li>\n    </ul>\n  </div>\n</div>\n<div class=\"row\">\n  <div class=\"col-md-4 pull-left\">\n    <h4 class=\"list-group-item-heading\">Event</h4>\n    <p class=\"list-group-item-text\">Save Customer</p>\n  </div>\n  <div class=\"col-md-8 pull-right\">\n    <h4 class=\"list-group-item-heading\">Properties</h4>\n    <ul class=\"list-group-item-text\">\n      <li *ngFor=\"let item of scParams.params | keyvalue\">\n        {{item.key}}:{{item.value}}\n      </li>\n    </ul>\n  </div>\n</div>\n<div class=\"row\">\n  <div class=\"col-md-4 pull-left\">\n    <h4 class=\"list-group-item-heading\">Event</h4>\n    <p class=\"list-group-item-text\">Register Customer</p>\n  </div>\n  <div class=\"col-md-8 pull-right\">\n    <h4 class=\"list-group-item-heading\">Properties</h4>\n    <ul class=\"list-group-item-text\">\n      <li *ngFor=\"let item of rcParams.params | keyvalue\">\n        {{item.key}}:{{item.value}}\n      </li>\n    </ul>\n  </div>\n</div>\n"

/***/ }),

/***/ "./src/app/admin/stats/stats.component.ts":
/*!************************************************!*\
  !*** ./src/app/admin/stats/stats.component.ts ***!
  \************************************************/
/*! exports provided: StatsComponent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "StatsComponent", function() { return StatsComponent; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var rxjs__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! rxjs */ "./node_modules/rxjs/_esm5/index.js");



var StatsComponent = /** @class */ (function () {
    function StatsComponent() {
        this.lastEventName = '';
        this.ccr = 0;
        this.cc = 0;
        this.sc = 0;
        this.rc = 0;
        this.ccrParams = {};
        this.ccParams = {};
        this.scParams = {};
        this.rcParams = {};
    }
    StatsComponent.prototype.ngOnInit = function () {
        this.showUnsub = false;
    };
    StatsComponent.prototype.readEvents = function () {
        var _this = this;
        this.channel = rxjs__WEBPACK_IMPORTED_MODULE_2__["Observable"].create(function (observer) {
            var eventSource = new EventSource('http://127.0.0.1:8000/admin-gateway/list'); // Cannot find EventSource
            eventSource.onmessage = function (x) { return observer.next(x.data); };
            eventSource.onerror = function (x) { return observer.error(x); };
            return function () {
                eventSource.close();
            };
        });
        this.activeSubscription = this.channel.subscribe({
            next: function (guid) {
                var responseJson = JSON.parse(guid);
                _this.lastEventName = responseJson.name;
                console.log(responseJson);
                console.log(responseJson.params);
                switch (_this.lastEventName) {
                    case 'CreateCustomerRequestEvent': {
                        _this.ccr += 1;
                        _this.ccrParams = responseJson.params;
                        break;
                    }
                    case 'CreateCustomerEvent': {
                        _this.cc += 1;
                        _this.ccParams = responseJson.params;
                        break;
                    }
                    case 'SaveCustomerEvent': {
                        _this.sc += 1;
                        _this.scParams = responseJson.params;
                        break;
                    }
                    case 'RegisterCustomerEvent': {
                        _this.rc += 1;
                        _this.rcParams = responseJson.params;
                        break;
                    }
                    default: {
                        break;
                    }
                }
            },
            error: function (err) { return console.error('something wrong occurred: ' + err); }
        });
        this.showUnsub = true;
    };
    StatsComponent.prototype.stopEvents = function () {
        this.activeSubscription.unsubscribe();
        this.showUnsub = false;
    };
    StatsComponent.prototype.resetCounters = function () {
        this.ccr = 0;
        this.cc = 0;
        this.sc = 0;
        this.rc = 0;
    };
    StatsComponent = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Component"])({
            selector: 'app-stats',
            template: __webpack_require__(/*! ./stats.component.html */ "./src/app/admin/stats/stats.component.html"),
            styles: [__webpack_require__(/*! ./stats.component.css */ "./src/app/admin/stats/stats.component.css")]
        }),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:paramtypes", [])
    ], StatsComponent);
    return StatsComponent;
}());



/***/ }),

/***/ "./src/app/app.component.css":
/*!***********************************!*\
  !*** ./src/app/app.component.css ***!
  \***********************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "\n/*# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IiIsImZpbGUiOiJzcmMvYXBwL2FwcC5jb21wb25lbnQuY3NzIn0= */"

/***/ }),

/***/ "./src/app/app.component.html":
/*!************************************!*\
  !*** ./src/app/app.component.html ***!
  \************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "<!--The content below is only a placeholder and can be replaced.-->\n<div class=\"container\">\n  <div class=\"row\">\n    <h1 class=\"col-md-12 text-center text-primary\">\n      Welcome to {{ title }}!\n    </h1></div>\n  <div class=\"row\">\n    <div class=\"col-md-6 user\">\n      <app-user></app-user>\n    </div>\n    <div class=\"col-md-6 admin\">\n      <app-admin></app-admin>\n    </div>\n    <div class=\"col-md-12 user\">\n      <app-user-list></app-user-list>\n    </div>\n  </div>\n</div>\n"

/***/ }),

/***/ "./src/app/app.component.ts":
/*!**********************************!*\
  !*** ./src/app/app.component.ts ***!
  \**********************************/
/*! exports provided: AppComponent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "AppComponent", function() { return AppComponent; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");


var AppComponent = /** @class */ (function () {
    function AppComponent() {
        this.title = 'JLupin Demo App';
    }
    AppComponent = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Component"])({
            selector: 'app-root',
            template: __webpack_require__(/*! ./app.component.html */ "./src/app/app.component.html"),
            styles: [__webpack_require__(/*! ./app.component.css */ "./src/app/app.component.css")]
        })
    ], AppComponent);
    return AppComponent;
}());



/***/ }),

/***/ "./src/app/app.module.ts":
/*!*******************************!*\
  !*** ./src/app/app.module.ts ***!
  \*******************************/
/*! exports provided: AppModule */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "AppModule", function() { return AppModule; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_platform_browser__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/platform-browser */ "./node_modules/@angular/platform-browser/fesm5/platform-browser.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var _app_component__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./app.component */ "./src/app/app.component.ts");
/* harmony import */ var _user_user_component__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./user/user.component */ "./src/app/user/user.component.ts");
/* harmony import */ var _user_user_list_user_details_user_details_component__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./user/user-list/user-details/user-details.component */ "./src/app/user/user-list/user-details/user-details.component.ts");
/* harmony import */ var _admin_admin_component__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ./admin/admin.component */ "./src/app/admin/admin.component.ts");
/* harmony import */ var _admin_stats_stats_component__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ./admin/stats/stats.component */ "./src/app/admin/stats/stats.component.ts");
/* harmony import */ var _user_generator_generator_component__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! ./user/generator/generator.component */ "./src/app/user/generator/generator.component.ts");
/* harmony import */ var _angular_common_http__WEBPACK_IMPORTED_MODULE_9__ = __webpack_require__(/*! @angular/common/http */ "./node_modules/@angular/common/fesm5/http.js");
/* harmony import */ var _admin_event_list_event_list_component__WEBPACK_IMPORTED_MODULE_10__ = __webpack_require__(/*! ./admin/event-list/event-list.component */ "./src/app/admin/event-list/event-list.component.ts");
/* harmony import */ var _admin_event_list_event_item_event_item_component__WEBPACK_IMPORTED_MODULE_11__ = __webpack_require__(/*! ./admin/event-list/event-item/event-item.component */ "./src/app/admin/event-list/event-item/event-item.component.ts");
/* harmony import */ var _angular_platform_browser_animations__WEBPACK_IMPORTED_MODULE_12__ = __webpack_require__(/*! @angular/platform-browser/animations */ "./node_modules/@angular/platform-browser/fesm5/animations.js");
/* harmony import */ var _ng_bootstrap_ng_bootstrap__WEBPACK_IMPORTED_MODULE_13__ = __webpack_require__(/*! @ng-bootstrap/ng-bootstrap */ "./node_modules/@ng-bootstrap/ng-bootstrap/fesm5/ng-bootstrap.js");
/* harmony import */ var ngx_pagination__WEBPACK_IMPORTED_MODULE_14__ = __webpack_require__(/*! ngx-pagination */ "./node_modules/ngx-pagination/dist/ngx-pagination.js");
/* harmony import */ var _user_user_list_user_list_component__WEBPACK_IMPORTED_MODULE_15__ = __webpack_require__(/*! ./user/user-list/user-list.component */ "./src/app/user/user-list/user-list.component.ts");
/* harmony import */ var _material_module__WEBPACK_IMPORTED_MODULE_16__ = __webpack_require__(/*! ./material.module */ "./src/app/material.module.ts");

















var AppModule = /** @class */ (function () {
    function AppModule() {
    }
    AppModule = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_2__["NgModule"])({
            declarations: [
                _app_component__WEBPACK_IMPORTED_MODULE_3__["AppComponent"],
                _user_user_component__WEBPACK_IMPORTED_MODULE_4__["UserComponent"],
                _admin_admin_component__WEBPACK_IMPORTED_MODULE_6__["AdminComponent"],
                _admin_stats_stats_component__WEBPACK_IMPORTED_MODULE_7__["StatsComponent"],
                _user_generator_generator_component__WEBPACK_IMPORTED_MODULE_8__["GeneratorComponent"],
                _admin_event_list_event_list_component__WEBPACK_IMPORTED_MODULE_10__["EventListComponent"],
                _admin_event_list_event_item_event_item_component__WEBPACK_IMPORTED_MODULE_11__["EventItemComponent"],
                _user_user_list_user_list_component__WEBPACK_IMPORTED_MODULE_15__["UserListComponent"],
                _user_user_list_user_details_user_details_component__WEBPACK_IMPORTED_MODULE_5__["UserDetailsComponent"]
            ],
            imports: [
                _angular_platform_browser__WEBPACK_IMPORTED_MODULE_1__["BrowserModule"],
                _angular_common_http__WEBPACK_IMPORTED_MODULE_9__["HttpClientModule"],
                _angular_platform_browser_animations__WEBPACK_IMPORTED_MODULE_12__["BrowserAnimationsModule"],
                _angular_platform_browser_animations__WEBPACK_IMPORTED_MODULE_12__["NoopAnimationsModule"],
                _material_module__WEBPACK_IMPORTED_MODULE_16__["MaterialModule"],
                ngx_pagination__WEBPACK_IMPORTED_MODULE_14__["NgxPaginationModule"],
                _ng_bootstrap_ng_bootstrap__WEBPACK_IMPORTED_MODULE_13__["NgbModalModule"]
            ],
            providers: [],
            bootstrap: [_app_component__WEBPACK_IMPORTED_MODULE_3__["AppComponent"]],
            entryComponents: [_user_user_list_user_details_user_details_component__WEBPACK_IMPORTED_MODULE_5__["UserDetailsComponent"]],
            exports: [_user_user_list_user_details_user_details_component__WEBPACK_IMPORTED_MODULE_5__["UserDetailsComponent"]]
        })
    ], AppModule);
    return AppModule;
}());



/***/ }),

/***/ "./src/app/material.module.ts":
/*!************************************!*\
  !*** ./src/app/material.module.ts ***!
  \************************************/
/*! exports provided: MaterialModule */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "MaterialModule", function() { return MaterialModule; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var _angular_cdk_a11y__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @angular/cdk/a11y */ "./node_modules/@angular/cdk/esm5/a11y.es5.js");
/* harmony import */ var _angular_cdk_bidi__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @angular/cdk/bidi */ "./node_modules/@angular/cdk/esm5/bidi.es5.js");
/* harmony import */ var _angular_cdk_observers__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! @angular/cdk/observers */ "./node_modules/@angular/cdk/esm5/observers.es5.js");
/* harmony import */ var _angular_cdk_overlay__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! @angular/cdk/overlay */ "./node_modules/@angular/cdk/esm5/overlay.es5.js");
/* harmony import */ var _angular_cdk_platform__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! @angular/cdk/platform */ "./node_modules/@angular/cdk/esm5/platform.es5.js");
/* harmony import */ var _angular_cdk_portal__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! @angular/cdk/portal */ "./node_modules/@angular/cdk/esm5/portal.es5.js");
/* harmony import */ var _angular_cdk_scrolling__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! @angular/cdk/scrolling */ "./node_modules/@angular/cdk/esm5/scrolling.es5.js");
/* harmony import */ var _angular_cdk_stepper__WEBPACK_IMPORTED_MODULE_9__ = __webpack_require__(/*! @angular/cdk/stepper */ "./node_modules/@angular/cdk/esm5/stepper.es5.js");
/* harmony import */ var _angular_cdk_table__WEBPACK_IMPORTED_MODULE_10__ = __webpack_require__(/*! @angular/cdk/table */ "./node_modules/@angular/cdk/esm5/table.es5.js");
/* harmony import */ var _angular_material__WEBPACK_IMPORTED_MODULE_11__ = __webpack_require__(/*! @angular/material */ "./node_modules/@angular/material/esm5/material.es5.js");












var MaterialModule = /** @class */ (function () {
    function MaterialModule() {
    }
    MaterialModule = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["NgModule"])({
            exports: [
                // CDK
                _angular_cdk_a11y__WEBPACK_IMPORTED_MODULE_2__["A11yModule"],
                _angular_cdk_bidi__WEBPACK_IMPORTED_MODULE_3__["BidiModule"],
                _angular_cdk_observers__WEBPACK_IMPORTED_MODULE_4__["ObserversModule"],
                _angular_cdk_overlay__WEBPACK_IMPORTED_MODULE_5__["OverlayModule"],
                _angular_cdk_platform__WEBPACK_IMPORTED_MODULE_6__["PlatformModule"],
                _angular_cdk_portal__WEBPACK_IMPORTED_MODULE_7__["PortalModule"],
                _angular_cdk_scrolling__WEBPACK_IMPORTED_MODULE_8__["ScrollDispatchModule"],
                _angular_cdk_stepper__WEBPACK_IMPORTED_MODULE_9__["CdkStepperModule"],
                _angular_cdk_table__WEBPACK_IMPORTED_MODULE_10__["CdkTableModule"],
                // Material
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatAutocompleteModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatButtonModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatButtonToggleModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatCardModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatCheckboxModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatChipsModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatDatepickerModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatDialogModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatExpansionModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatGridListModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatIconModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatInputModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatListModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatMenuModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatProgressBarModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatProgressSpinnerModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatRadioModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatRippleModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatSelectModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatSidenavModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatSlideToggleModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatSliderModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatSnackBarModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatStepperModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatTableModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatTabsModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatToolbarModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatTooltipModule"],
                _angular_material__WEBPACK_IMPORTED_MODULE_11__["MatNativeDateModule"],
            ]
        })
    ], MaterialModule);
    return MaterialModule;
}());



/***/ }),

/***/ "./src/app/user/generator/generator.component.css":
/*!********************************************************!*\
  !*** ./src/app/user/generator/generator.component.css ***!
  \********************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "\n/*# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IiIsImZpbGUiOiJzcmMvYXBwL3VzZXIvZ2VuZXJhdG9yL2dlbmVyYXRvci5jb21wb25lbnQuY3NzIn0= */"

/***/ }),

/***/ "./src/app/user/generator/generator.component.html":
/*!*********************************************************!*\
  !*** ./src/app/user/generator/generator.component.html ***!
  \*********************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "<div class=\"row\">\n  <div class=\"col-md-3\">\n    <p>\n      <button class=\"btn btn-primary\"\n              (click)=\"startGenerate()\"\n              mat-raised-button\n              matTooltip=\"Start generating random customers\"\n              aria-label=\"\"\n      >Start generator\n      </button>\n    </p>\n  </div>\n  <div class=\"col-md-3\">\n    <p>\n      <button class=\"btn btn-secondary\"\n              mat-raised-button\n              matTooltip=\"Generate single customer\"\n              aria-label=\"\"\n              (click)=\"generateSingle()\">Generate single\n      </button>\n    </p>\n  </div>\n  <div class=\"col-md-3\">\n    <p>\n      <button class=\"btn btn-danger\"\n              (click)=\"stopGenerator()\">Stop generator\n      </button>\n    </p>\n  </div>\n</div>\n\n\n<div *ngIf=\"currentUser != null\">\n  <h4>current user is</h4>\n  <div class=\"row\">\n    <div class=\"col-md-6\">login:</div>\n    <div class=\"col-md-6\">{{currentUser.login}}</div>\n  </div>\n  <div class=\"row\">\n    <div class=\"col-md-6\">type:</div>\n    <div class=\"col-md-6\">{{currentUser.type}}</div>\n  </div>\n</div>\n"

/***/ }),

/***/ "./src/app/user/generator/generator.component.ts":
/*!*******************************************************!*\
  !*** ./src/app/user/generator/generator.component.ts ***!
  \*******************************************************/
/*! exports provided: GeneratorComponent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "GeneratorComponent", function() { return GeneratorComponent; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var _generator_service__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./generator.service */ "./src/app/user/generator/generator.service.ts");
/* harmony import */ var _angular_common_http__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @angular/common/http */ "./node_modules/@angular/common/fesm5/http.js");
/* harmony import */ var _user__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ../user */ "./src/app/user/user.ts");
/* harmony import */ var rxjs__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! rxjs */ "./node_modules/rxjs/_esm5/index.js");






var GeneratorComponent = /** @class */ (function () {
    function GeneratorComponent(generatorService, httpClient) {
        this.generatorService = generatorService;
        this.httpClient = httpClient;
        this.baseUrl = 'http://127.0.0.1:8000/api-gateway/customer/create/';
    }
    GeneratorComponent.prototype.ngOnInit = function () {
    };
    GeneratorComponent.prototype.startGenerate = function () {
        var _this = this;
        var source = Object(rxjs__WEBPACK_IMPORTED_MODULE_5__["interval"])(1000);
        this.generator = source.subscribe(function (val) { return _this.generate(); });
    };
    GeneratorComponent.prototype.generateSingle = function () {
        this.generate();
    };
    GeneratorComponent.prototype.stopGenerator = function () {
        this.generator.unsubscribe();
    };
    GeneratorComponent.prototype.generate = function () {
        var id = this.generatorService.generateId();
        var type = this.generatorService.generateType();
        var httpOptions = {
            headers: new _angular_common_http__WEBPACK_IMPORTED_MODULE_3__["HttpHeaders"]({
                'Content-Type': 'application/json'
            })
        };
        this.currentUser = new _user__WEBPACK_IMPORTED_MODULE_4__["User"](this.generatorService.generateName(), type);
        this.httpClient.put(this.baseUrl + id, this.currentUser, httpOptions).subscribe();
    };
    GeneratorComponent = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Component"])({
            selector: 'app-generator',
            template: __webpack_require__(/*! ./generator.component.html */ "./src/app/user/generator/generator.component.html"),
            styles: [__webpack_require__(/*! ./generator.component.css */ "./src/app/user/generator/generator.component.css")]
        }),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:paramtypes", [_generator_service__WEBPACK_IMPORTED_MODULE_2__["GeneratorService"],
            _angular_common_http__WEBPACK_IMPORTED_MODULE_3__["HttpClient"]])
    ], GeneratorComponent);
    return GeneratorComponent;
}());



/***/ }),

/***/ "./src/app/user/generator/generator.service.ts":
/*!*****************************************************!*\
  !*** ./src/app/user/generator/generator.service.ts ***!
  \*****************************************************/
/*! exports provided: GeneratorService */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "GeneratorService", function() { return GeneratorService; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var uuid__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! uuid */ "./node_modules/uuid/index.js");
/* harmony import */ var uuid__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(uuid__WEBPACK_IMPORTED_MODULE_2__);
/* harmony import */ var _name_generator_service__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./name-generator.service */ "./src/app/user/generator/name-generator.service.ts");




var GeneratorService = /** @class */ (function () {
    function GeneratorService(nameGen) {
        this.nameGen = nameGen;
        this.uuidGen = uuid__WEBPACK_IMPORTED_MODULE_2__["v4"];
    }
    GeneratorService.prototype.generateName = function () {
        return this.nameGen.generateName();
    };
    GeneratorService.prototype.generateType = function () {
        if (Math.random() > 0.5) {
            return 'pub';
        }
        else {
            return 'priv';
        }
    };
    GeneratorService.prototype.generateId = function () {
        return this.uuidGen.v4();
    };
    GeneratorService = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Injectable"])({
            providedIn: 'root'
        }),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:paramtypes", [_name_generator_service__WEBPACK_IMPORTED_MODULE_3__["NameGeneratorService"]])
    ], GeneratorService);
    return GeneratorService;
}());



/***/ }),

/***/ "./src/app/user/generator/name-generator.service.ts":
/*!**********************************************************!*\
  !*** ./src/app/user/generator/name-generator.service.ts ***!
  \**********************************************************/
/*! exports provided: NameGeneratorService */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "NameGeneratorService", function() { return NameGeneratorService; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");


var NameGeneratorService = /** @class */ (function () {
    function NameGeneratorService() {
        this.dwavenNameGen = new DwavenNameGenerator();
    }
    NameGeneratorService.prototype.generateName = function () {
        return this.dwavenNameGen.randomName();
    };
    NameGeneratorService = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Injectable"])({
            providedIn: 'root'
        }),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:paramtypes", [])
    ], NameGeneratorService);
    return NameGeneratorService;
}());

var DwavenNameGenerator = /** @class */ (function () {
    function DwavenNameGenerator() {
        this.names = ['Adkuhm', 'Akadum', 'Anin', 'Anspori', 'Anvari', 'Ari', 'Aurar', 'Austi', 'Avaldur',
            'Baerdal', 'Balin', 'Balskjald', 'Balthrasir', 'Bandan', 'Bangrim', 'Bardagul', 'Beldrum', 'Bendain', 'Bendan',
            'Beris', 'Bhalkyl', 'Bhalmun', 'Bharrom', 'Bhelkam', 'Bilbur', 'Bjarki', 'Bofar', 'Bragi', 'Bramdahr', 'Bramdur',
            'Branmand', 'Brusy', 'Brynjolvur', 'Dagur', 'Dain', 'Dalnur', 'Darmond', 'Daskjald', 'Djoni', 'Doldram', 'Dorvari',
            'Draupin', 'Dufin', 'Ebdrus', 'Ebgran', 'Edmundur', 'Eiki', 'Eilivur', 'Elindur', 'Ermrig', 'Filar', 'Finn',
            'Fjalin', 'Floi', 'Floki', 'Fraeg', 'Frostar', 'Fulla', 'Fundar', 'Galren', 'Galthrum', 'Gargrom', 'Garman',
            'Geirfinnur', 'Geirur', 'Gimmyl', 'Gimren', 'Gisli', 'Glovari', 'Gormur', 'Graim', 'Graldor', 'Gralkyl',
            'Gralram', 'Gramdahr', 'Grandrum', 'Graniggs', 'Grenbek', 'Grilmek', 'Gusti', 'Gylvia', 'Hagbarthur',
            'Hallbergur', 'Hannskjald', 'Harfur', 'Harum', 'Haugin', 'Heptin', 'Hjolman', 'Hjolmor', 'Hlevari', 'Hloin',
            'Horar', 'Horkahm', 'Hurram', 'Ingivald', 'Isakur', 'Ithi', 'Ithleviur', 'Jarvari', 'Jaspur', 'Jatmundur', 'Justi',
            'Kari', 'Karrak', 'Kartni', 'Kiljald', 'Killin', 'Kramnom', 'Kromgrun', 'Krumgrom', 'Krumkohm', 'Leiki', 'Leivur',
            'Lithri', 'Lofar', 'Lonin', 'Lonlin', 'Lonvari', 'Lythur', 'Malmun', 'Maur', 'Melnur', 'Mjothi', 'Modsognir',
            'Morgus', 'Morram', 'Motar', 'Muiradin', 'Naglur', 'Nalskjald', 'Narvari', 'Nipthrasir', 'Njalur', 'Noi',
            'Northrasit', 'Nyrath', 'Nyvari', 'Oddfinnur', 'Offleivur', 'Oilulvur', 'Onin', 'Onundur', 'Paitur', 'Patrin',
            'Petrur', 'Ragnur', 'Ragvaldur', 'Regvari', 'Reinardun', 'Rikkin', 'Robekur', 'Roi', 'Rorin', 'Rothbar', 'Servin',
            'Sigmundur', 'Sigvaldur', 'Sjurthi', 'Skafith', 'Skirfar', 'Skofti', 'Sorkvi', 'Steinfinnur', 'Steinur', 'Stigur',
            'Sudri', 'Suthradir', 'Sveinur', 'Svjar', 'Taurun', 'Teitur', 'Thekkin', 'Thelron', 'Thelryl', 'Thelthrun',
            'Thorar', 'Thrain', 'Throar', 'Thuldohr', 'Thulgrun', 'Thurnar', 'Thydohr', 'Thymand', 'Thymin', 'Thymur', 'Tjalvi',
            'Toki', 'Toraldur', 'Torrus', 'Tyrur', 'Vagnur', 'Valbergur', 'Valdi', 'Viggar', 'Viggskjald', 'Vindalf', 'Virfi',
            'Voggur', 'Yngvi'];
    }
    DwavenNameGenerator.prototype.randomName = function () {
        return this.names[Math.floor(Math.random() * this.names.length)]
            + ' '
            + this.names[Math.floor(Math.random() * this.names.length)] + 'son';
    };
    return DwavenNameGenerator;
}());


/***/ }),

/***/ "./src/app/user/user-list/user-details/user-details.component.html":
/*!*************************************************************************!*\
  !*** ./src/app/user/user-list/user-details/user-details.component.html ***!
  \*************************************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "<div mat-dialog-title>Saga of {{user.login}}</div>\n\n<mat-dialog-content>\n  <div *ngIf=\"saga.length == 0\">There is no Saga of {{user.login}}</div>\n  <div *ngIf=\"saga.length > 0\">\n    <p>Lon, long time ago</p>\n    <div *ngFor=\"let tail of saga\">\n      {{tail.name}} happends when\n      <ul class=\"list-group-item-text\">\n        <li *ngFor=\"let item of tail.params | keyvalue\">\n          {{item.key}}:{{item.value}}\n        </li>\n      </ul>\n    </div>\n  </div>\n</mat-dialog-content>\n\n<mat-dialog-actions>\n  <button mat-button type=\"button\" class=\"btn btn-primary\" mat-dialog-close>\n    Close\n  </button>\n</mat-dialog-actions>\n\n"

/***/ }),

/***/ "./src/app/user/user-list/user-details/user-details.component.ts":
/*!***********************************************************************!*\
  !*** ./src/app/user/user-list/user-details/user-details.component.ts ***!
  \***********************************************************************/
/*! exports provided: UserDetailsComponent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "UserDetailsComponent", function() { return UserDetailsComponent; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var _angular_material__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @angular/material */ "./node_modules/@angular/material/esm5/material.es5.js");



var UserDetailsComponent = /** @class */ (function () {
    function UserDetailsComponent(dialogRef, data) {
        this.dialogRef = dialogRef;
        this.data = data;
    }
    UserDetailsComponent.prototype.ngOnInit = function () {
        this.user = this.data.user;
        this.saga = this.data.saga;
    };
    UserDetailsComponent = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Component"])({
            template: __webpack_require__(/*! ./user-details.component.html */ "./src/app/user/user-list/user-details/user-details.component.html")
        }),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__param"](1, Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Inject"])(_angular_material__WEBPACK_IMPORTED_MODULE_2__["MAT_DIALOG_DATA"])),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:paramtypes", [_angular_material__WEBPACK_IMPORTED_MODULE_2__["MatDialogRef"], Object])
    ], UserDetailsComponent);
    return UserDetailsComponent;
}());



/***/ }),

/***/ "./src/app/user/user-list/user-list.component.css":
/*!********************************************************!*\
  !*** ./src/app/user/user-list/user-list.component.css ***!
  \********************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "\n/*# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IiIsImZpbGUiOiJzcmMvYXBwL3VzZXIvdXNlci1saXN0L3VzZXItbGlzdC5jb21wb25lbnQuY3NzIn0= */"

/***/ }),

/***/ "./src/app/user/user-list/user-list.component.html":
/*!*********************************************************!*\
  !*** ./src/app/user/user-list/user-list.component.html ***!
  \*********************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "<div class=\"lead\">\n  <p>This component show th <kbd> API Composition</kbd> pattern. We use both\n    endpoints to get data.</p>\n</div>\n\n<div class=\"col-md-12\">\n\n\n  <input (keyup)=\"findUsers(userNameInput)\" placeholder=\"User login\"\n         #userNameInput/>\n\n  <div\n    *ngFor=\"let user of users | paginate: {\n    id: 'pag-users',\n    itemsPerPage: 5,\n    currentPage: currentPage\n    }\"\n    (click)=\"openUserDialog(user)\" class=\"lead\">{{user.login}}</div>\n  <pagination-controls id=\"pag-users\"\n                       (pageChange)=\"currentPage = $event\"></pagination-controls>\n</div>\n"

/***/ }),

/***/ "./src/app/user/user-list/user-list.component.ts":
/*!*******************************************************!*\
  !*** ./src/app/user/user-list/user-list.component.ts ***!
  \*******************************************************/
/*! exports provided: UserListComponent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "UserListComponent", function() { return UserListComponent; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var _angular_common_http__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @angular/common/http */ "./node_modules/@angular/common/fesm5/http.js");
/* harmony import */ var _angular_material__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @angular/material */ "./node_modules/@angular/material/esm5/material.es5.js");
/* harmony import */ var _user_details_user_details_component__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./user-details/user-details.component */ "./src/app/user/user-list/user-details/user-details.component.ts");





var UserListComponent = /** @class */ (function () {
    function UserListComponent(httpClient, dialog) {
        this.httpClient = httpClient;
        this.dialog = dialog;
        this.users = [];
        this.apiUrl = 'http://127.0.0.1:8000/api-gateway/customer/find/';
        this.statsUrl = 'http://127.0.0.1:8000/admin-gateway/events/allById/';
    }
    UserListComponent.prototype.ngOnInit = function () {
    };
    UserListComponent.prototype.findUsers = function (userNameInput) {
        var _this = this;
        var searchValue = userNameInput.value;
        console.error(searchValue);
        if (searchValue.length >= 3) {
            var searchParams = new _angular_common_http__WEBPACK_IMPORTED_MODULE_2__["HttpParams"]();
            searchParams = searchParams.set("customerName", searchValue);
            var httpHeaders = new _angular_common_http__WEBPACK_IMPORTED_MODULE_2__["HttpHeaders"]({
                'Content-Type': 'application/json'
            });
            var httpOptions = {
                headers: httpHeaders,
                params: searchParams
            };
            this.httpClient.get(this.apiUrl, httpOptions)
                .toPromise()
                .then(function (cst) {
                return cst;
            }).then(function (c) {
                _this.users = c;
            });
        }
    };
    UserListComponent.prototype.openUserDialog = function (user) {
        var _this = this;
        var searchParams = new _angular_common_http__WEBPACK_IMPORTED_MODULE_2__["HttpParams"]();
        searchParams = searchParams.set("eventId", user.systemId);
        var httpHeaders = new _angular_common_http__WEBPACK_IMPORTED_MODULE_2__["HttpHeaders"]({
            'Content-Type': 'application/json'
        });
        var httpOptions = {
            headers: httpHeaders,
            params: searchParams
        };
        this.httpClient.get(this.statsUrl, httpOptions)
            .toPromise()
            .then(function (eventsArray) {
            return eventsArray;
        }).then(function (ev) {
            _this.userDialog = _this.dialog.open(_user_details_user_details_component__WEBPACK_IMPORTED_MODULE_4__["UserDetailsComponent"], {
                data: {
                    user: user,
                    saga: ev
                }
            });
        });
    };
    UserListComponent = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Component"])({
            selector: 'app-user-list',
            template: __webpack_require__(/*! ./user-list.component.html */ "./src/app/user/user-list/user-list.component.html"),
            styles: [__webpack_require__(/*! ./user-list.component.css */ "./src/app/user/user-list/user-list.component.css")]
        }),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:paramtypes", [_angular_common_http__WEBPACK_IMPORTED_MODULE_2__["HttpClient"], _angular_material__WEBPACK_IMPORTED_MODULE_3__["MatDialog"]])
    ], UserListComponent);
    return UserListComponent;
}());



/***/ }),

/***/ "./src/app/user/user.component.css":
/*!*****************************************!*\
  !*** ./src/app/user/user.component.css ***!
  \*****************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "\n/*# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IiIsImZpbGUiOiJzcmMvYXBwL3VzZXIvdXNlci5jb21wb25lbnQuY3NzIn0= */"

/***/ }),

/***/ "./src/app/user/user.component.html":
/*!******************************************!*\
  !*** ./src/app/user/user.component.html ***!
  \******************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "<h3 class=\"text-center\">\n  User GUI – API Gateway\n</h3>\n<div class=\"lead\">\n  <p>This side of page represents access to <kbd>api-gateway</kbd> controllers.</p>\n</div>\n<app-generator></app-generator>\n"

/***/ }),

/***/ "./src/app/user/user.component.ts":
/*!****************************************!*\
  !*** ./src/app/user/user.component.ts ***!
  \****************************************/
/*! exports provided: UserComponent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "UserComponent", function() { return UserComponent; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");


var UserComponent = /** @class */ (function () {
    function UserComponent() {
    }
    UserComponent.prototype.ngOnInit = function () {
    };
    UserComponent = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Component"])({
            selector: 'app-user',
            template: __webpack_require__(/*! ./user.component.html */ "./src/app/user/user.component.html"),
            styles: [__webpack_require__(/*! ./user.component.css */ "./src/app/user/user.component.css")]
        }),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:paramtypes", [])
    ], UserComponent);
    return UserComponent;
}());



/***/ }),

/***/ "./src/app/user/user.ts":
/*!******************************!*\
  !*** ./src/app/user/user.ts ***!
  \******************************/
/*! exports provided: User */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "User", function() { return User; });
var User = /** @class */ (function () {
    function User(login, type) {
        this.login = login;
        this.type = type;
    }
    return User;
}());



/***/ }),

/***/ "./src/environments/environment.ts":
/*!*****************************************!*\
  !*** ./src/environments/environment.ts ***!
  \*****************************************/
/*! exports provided: environment */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "environment", function() { return environment; });
// This file can be replaced during build by using the `fileReplacements` array.
// `ng build --prod` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.
var environment = {
    production: false
};
/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/dist/zone-error';  // Included with Angular CLI.


/***/ }),

/***/ "./src/main.ts":
/*!*********************!*\
  !*** ./src/main.ts ***!
  \*********************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var _angular_platform_browser_dynamic__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/platform-browser-dynamic */ "./node_modules/@angular/platform-browser-dynamic/fesm5/platform-browser-dynamic.js");
/* harmony import */ var _app_app_module__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./app/app.module */ "./src/app/app.module.ts");
/* harmony import */ var _environments_environment__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./environments/environment */ "./src/environments/environment.ts");




if (_environments_environment__WEBPACK_IMPORTED_MODULE_3__["environment"].production) {
    Object(_angular_core__WEBPACK_IMPORTED_MODULE_0__["enableProdMode"])();
}
Object(_angular_platform_browser_dynamic__WEBPACK_IMPORTED_MODULE_1__["platformBrowserDynamic"])().bootstrapModule(_app_app_module__WEBPACK_IMPORTED_MODULE_2__["AppModule"])
    .catch(function (err) { return console.error(err); });


/***/ }),

/***/ 0:
/*!***************************!*\
  !*** multi ./src/main.ts ***!
  \***************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(/*! /home/koziolek/workspace/jlupin/incat-demo/AccessLayer/demo-app-access/implementation/src/main/web/src/main.ts */"./src/main.ts");


/***/ })

},[[0,"runtime","vendor"]]]);
//# sourceMappingURL=main.js.map