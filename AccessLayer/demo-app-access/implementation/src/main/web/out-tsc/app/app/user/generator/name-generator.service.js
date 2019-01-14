import * as tslib_1 from "tslib";
import { Injectable } from '@angular/core';
var NameGeneratorService = /** @class */ (function () {
    function NameGeneratorService() {
        this.dwavenNameGen = new DwavenNameGenerator();
    }
    NameGeneratorService.prototype.generateName = function () {
        return this.dwavenNameGen.randomName();
    };
    NameGeneratorService = tslib_1.__decorate([
        Injectable({
            providedIn: 'root'
        }),
        tslib_1.__metadata("design:paramtypes", [])
    ], NameGeneratorService);
    return NameGeneratorService;
}());
export { NameGeneratorService };
var DwavenNameGenerator = /** @class */ (function () {
    function DwavenNameGenerator() {
        this.names = ['Adkuhm', 'Akadum', 'Anin', 'Anspori', 'Anvari', 'Ari', 'Aurar', 'Austi', 'Avaldur',
            'Baerdal', 'Balin', 'Balskjald', 'Balthrasir', 'Bandan', 'Bangrim', 'Bardagul', 'Beldrum', 'Bendain', 'Bendan',
            'Beris', 'Bhalkyl', 'Bhalmun', 'Bharrom', 'Bhelkam', 'Bilbur', 'Bjarki', 'Bofar', 'Bragi', 'Bramdahr', 'Bramdur',
            'Branmand', 'Brusy', 'Brynjolvur', 'Dagur', 'Dain', 'Dalnur', 'Darmond', 'Daskjald', 'Djoni', 'Doldram', 'Dorvari',
            'Draupin', 'Dufin', 'Ebdrus', 'Ebgran', 'Edmundur', 'Eiki', 'Eilivur', 'Elindur', 'Ermrig', 'Filar', 'Finn',
            'Fjalin', 'Floi', 'Floki', 'Fraeg', 'Frostar', 'Fulla', 'Fundar', 'Galren', 'Galthrum', 'Gargrom', 'Garman',
            'Geirfinnur', 'Geirur', 'Gimmyl', 'Gimren', 'Gisli', 'Glovari', 'Gormur', 'Graim', 'Graldor', 'Gralkyl',
            'Gralram', 'Gramdahr', 'Grandrum', 'Graniggs', 'Grenbek', 'Grilmek', 'Gusti', 'Gylvia', 'Hagbarthur',
            'Hallbergur', 'Hannskjald', 'Harfur', 'Harum', 'Haugin', 'Heptin', 'Hjolman', 'Hjolmor', 'Hlevari', 'Hloin',
            'Horar', 'Horkahm', 'Hurram', 'Ingivald', 'Isakur', 'Ithi', 'Ithleviur', 'Jarvari', 'Jaspur', 'Jatmundur', 'Justi',
            'Kari', 'Karrak', 'Kartni', 'Kiljald', 'Killin', 'Kramnom', 'Kromgrun', 'Krumgrom', 'Krumkohm', 'Leiki', 'Leivur',
            'Lithri', 'Lofar', 'Lonin', 'Lonlin', 'Lonvari', 'Lythur', 'Malmun', 'Maur', 'Melnur', 'Mjothi', 'Modsognir',
            'Morgus', 'Morram', 'Motar', 'Muiradin', 'Naglur', 'Nalskjald', 'Narvari', 'Nipthrasir', 'Njalur', 'Noi',
            'Northrasit', 'Nyrath', 'Nyvari', 'Oddfinnur', 'Offleivur', 'Oilulvur', 'Onin', 'Onundur', 'Paitur', 'Patrin',
            'Petrur', 'Ragnur', 'Ragvaldur', 'Regvari', 'Reinardun', 'Rikkin', 'Robekur', 'Roi', 'Rorin', 'Rothbar', 'Servin',
            'Sigmundur', 'Sigvaldur', 'Sjurthi', 'Skafith', 'Skirfar', 'Skofti', 'Sorkvi', 'Steinfinnur', 'Steinur', 'Stigur',
            'Sudri', 'Suthradir', 'Sveinur', 'Svjar', 'Taurun', 'Teitur', 'Thekkin', 'Thelron', 'Thelryl', 'Thelthrun',
            'Thorar', 'Thrain', 'Throar', 'Thuldohr', 'Thulgrun', 'Thurnar', 'Thydohr', 'Thymand', 'Thymin', 'Thymur', 'Tjalvi',
            'Toki', 'Toraldur', 'Torrus', 'Tyrur', 'Vagnur', 'Valbergur', 'Valdi', 'Viggar', 'Viggskjald', 'Vindalf', 'Virfi',
            'Voggur', 'Yngvi'];
    }
    DwavenNameGenerator.prototype.randomName = function () {
        return this.names[Math.floor(Math.random() * this.names.length)]
            + ' '
            + this.names[Math.floor(Math.random() * this.names.length)] + 'son';
    };
    return DwavenNameGenerator;
}());
//# sourceMappingURL=name-generator.service.js.map