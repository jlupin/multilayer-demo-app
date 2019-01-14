import * as tslib_1 from "tslib";
import { Component } from '@angular/core';
import { GeneratorService } from './generator.service';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { User } from '../user';
import { interval } from "rxjs";
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
        var source = interval(1000);
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
            headers: new HttpHeaders({
                'Content-Type': 'application/json'
            })
        };
        this.currentUser = new User(this.generatorService.generateName(), type);
        this.httpClient.put(this.baseUrl + id, this.currentUser, httpOptions).subscribe();
    };
    GeneratorComponent = tslib_1.__decorate([
        Component({
            selector: 'app-generator',
            templateUrl: './generator.component.html',
            styleUrls: ['./generator.component.css']
        }),
        tslib_1.__metadata("design:paramtypes", [GeneratorService,
            HttpClient])
    ], GeneratorComponent);
    return GeneratorComponent;
}());
export { GeneratorComponent };
//# sourceMappingURL=generator.component.js.map