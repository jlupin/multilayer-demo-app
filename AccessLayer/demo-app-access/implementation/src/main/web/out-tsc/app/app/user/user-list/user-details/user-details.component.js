import * as tslib_1 from "tslib";
import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from "@angular/material";
var UserDetailsComponent = /** @class */ (function () {
    function UserDetailsComponent(dialogRef, data) {
        this.dialogRef = dialogRef;
        this.data = data;
    }
    UserDetailsComponent.prototype.ngOnInit = function () {
        this.user = this.data.user;
        this.saga = this.data.saga;
    };
    UserDetailsComponent = tslib_1.__decorate([
        Component({
            templateUrl: './user-details.component.html'
        }),
        tslib_1.__param(1, Inject(MAT_DIALOG_DATA)),
        tslib_1.__metadata("design:paramtypes", [MatDialogRef, Object])
    ], UserDetailsComponent);
    return UserDetailsComponent;
}());
export { UserDetailsComponent };
//# sourceMappingURL=user-details.component.js.map