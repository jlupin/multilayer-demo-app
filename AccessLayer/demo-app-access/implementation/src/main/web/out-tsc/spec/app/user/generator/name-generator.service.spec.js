import { TestBed } from '@angular/core/testing';
import { NameGeneratorService } from './name-generator.service';
describe('NameGeneratorService', function () {
    beforeEach(function () { return TestBed.configureTestingModule({}); });
    it('should be created', function () {
        var service = TestBed.get(NameGeneratorService);
        expect(service).toBeTruthy();
    });
});
//# sourceMappingURL=name-generator.service.spec.js.map