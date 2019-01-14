import * as tslib_1 from "tslib";
import { Injectable } from '@angular/core';
import { v4 as uuid } from 'uuid';
import { NameGeneratorService } from "./name-generator.service";
var GeneratorService = /** @class */ (function () {
    function GeneratorService(nameGen) {
        this.nameGen = nameGen;
        this.uuidGen = uuid;
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
    GeneratorService = tslib_1.__decorate([
        Injectable({
            providedIn: 'root'
        }),
        tslib_1.__metadata("design:paramtypes", [NameGeneratorService])
    ], GeneratorService);
    return GeneratorService;
}());
export { GeneratorService };
//# sourceMappingURL=generator.service.js.map