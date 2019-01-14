import * as tslib_1 from "tslib";
import { Component, Input } from '@angular/core';
import { EventView } from "../event.model";
var EventItemComponent = /** @class */ (function () {
    function EventItemComponent() {
    }
    EventItemComponent.prototype.ngOnInit = function () {
    };
    tslib_1.__decorate([
        Input(),
        tslib_1.__metadata("design:type", EventView)
    ], EventItemComponent.prototype, "eventView", void 0);
    EventItemComponent = tslib_1.__decorate([
        Component({
            selector: 'app-event-item',
            templateUrl: './event-item.component.html',
            styleUrls: ['./event-item.component.css']
        }),
        tslib_1.__metadata("design:paramtypes", [])
    ], EventItemComponent);
    return EventItemComponent;
}());
export { EventItemComponent };
//# sourceMappingURL=event-item.component.js.map