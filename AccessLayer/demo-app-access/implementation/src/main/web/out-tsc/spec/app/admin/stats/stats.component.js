import * as tslib_1 from "tslib";
import { Component } from '@angular/core';
import { Observable } from 'rxjs';
var StatsComponent = /** @class */ (function () {
    function StatsComponent() {
        this.lastEventName = '';
        this.ccr = 0;
        this.cc = 0;
        this.sc = 0;
        this.rc = 0;
    }
    StatsComponent.prototype.ngOnInit = function () {
        this.showUnsub = false;
    };
    StatsComponent.prototype.readEvents = function () {
        var _this = this;
        this.channel = Observable.create(function (observer) {
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
                console.log(_this.lastEventName);
                switch (_this.lastEventName) {
                    case 'CreateCustomerRequestEvent': {
                        _this.ccr += 1;
                        break;
                    }
                    case 'CreateCustomerEvent': {
                        _this.cc += 1;
                        break;
                    }
                    case 'SaveCustomerEvent': {
                        _this.sc += 1;
                        break;
                    }
                    case 'RegisterCustomerEvent': {
                        _this.rc += 1;
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
    StatsComponent = tslib_1.__decorate([
        Component({
            selector: 'app-stats',
            templateUrl: './stats.component.html',
            styleUrls: ['./stats.component.css']
        }),
        tslib_1.__metadata("design:paramtypes", [])
    ], StatsComponent);
    return StatsComponent;
}());
export { StatsComponent };
//# sourceMappingURL=stats.component.js.map