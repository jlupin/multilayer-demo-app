import * as tslib_1 from "tslib";
import { Component } from '@angular/core';
import { EventListClientService } from "./event-list-client.service";
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
    EventListComponent = tslib_1.__decorate([
        Component({
            selector: 'app-event-list',
            templateUrl: './event-list.component.html',
            styleUrls: ['./event-list.component.css']
        }),
        tslib_1.__metadata("design:paramtypes", [EventListClientService])
    ], EventListComponent);
    return EventListComponent;
}());
export { EventListComponent };
//# sourceMappingURL=event-list.component.js.map