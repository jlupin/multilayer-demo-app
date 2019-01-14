import * as tslib_1 from "tslib";
import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { AppComponent } from './app.component';
import { UserComponent } from './user/user.component';
import { UserDetailsComponent } from './user/user-list/user-details/user-details.component';
import { AdminComponent } from './admin/admin.component';
import { StatsComponent } from './admin/stats/stats.component';
import { GeneratorComponent } from './user/generator/generator.component';
import { HttpClientModule } from "@angular/common/http";
import { EventListComponent } from './admin/event-list/event-list.component';
import { EventItemComponent } from './admin/event-list/event-item/event-item.component';
import { BrowserAnimationsModule, NoopAnimationsModule } from "@angular/platform-browser/animations";
import { NgbModalModule } from '@ng-bootstrap/ng-bootstrap';
import { NgxPaginationModule } from 'ngx-pagination';
import { UserListComponent } from './user/user-list/user-list.component';
import { MaterialModule } from "./material.module";
var AppModule = /** @class */ (function () {
    function AppModule() {
    }
    AppModule = tslib_1.__decorate([
        NgModule({
            declarations: [
                AppComponent,
                UserComponent,
                AdminComponent,
                StatsComponent,
                GeneratorComponent,
                EventListComponent,
                EventItemComponent,
                UserListComponent,
                UserDetailsComponent
            ],
            imports: [
                BrowserModule,
                HttpClientModule,
                BrowserAnimationsModule,
                NoopAnimationsModule,
                MaterialModule,
                NgxPaginationModule,
                NgbModalModule
            ],
            providers: [],
            bootstrap: [AppComponent],
            entryComponents: [UserDetailsComponent],
            exports: [UserDetailsComponent]
        })
    ], AppModule);
    return AppModule;
}());
export { AppModule };
//# sourceMappingURL=app.module.js.map