import * as tslib_1 from "tslib";
import { Component } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from "@angular/common/http";
import { MatDialog } from "@angular/material";
import { UserDetailsComponent } from "./user-details/user-details.component";
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
            var searchParams = new HttpParams();
            searchParams = searchParams.set("customerName", searchValue);
            var httpHeaders = new HttpHeaders({
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
        var searchParams = new HttpParams();
        searchParams = searchParams.set("eventId", user.systemId);
        var httpHeaders = new HttpHeaders({
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
            _this.userDialog = _this.dialog.open(UserDetailsComponent, {
                data: {
                    user: user,
                    saga: ev
                }
            });
        });
    };
    UserListComponent = tslib_1.__decorate([
        Component({
            selector: 'app-user-list',
            templateUrl: './user-list.component.html',
            styleUrls: ['./user-list.component.css']
        }),
        tslib_1.__metadata("design:paramtypes", [HttpClient, MatDialog])
    ], UserListComponent);
    return UserListComponent;
}());
export { UserListComponent };
//# sourceMappingURL=user-list.component.js.map