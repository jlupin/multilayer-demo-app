import * as tslib_1 from "tslib";
import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from "@angular/common/http";
var EventListClientService = /** @class */ (function () {
    function EventListClientService(http) {
        this.http = http;
        this.serviceAddress = 'http://127.0.0.1:8000/admin-gateway/events/all';
    }
    EventListClientService.prototype.allEvents = function () {
        var httpOptions = {
            headers: new HttpHeaders({
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
    EventListClientService = tslib_1.__decorate([
        Injectable({
            providedIn: 'root'
        }),
        tslib_1.__metadata("design:paramtypes", [HttpClient])
    ], EventListClientService);
    return EventListClientService;
}());
export { EventListClientService };
//# sourceMappingURL=event-list-client.service.js.map