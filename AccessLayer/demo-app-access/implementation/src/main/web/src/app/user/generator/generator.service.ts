import {Injectable} from '@angular/core';
import {v4 as uuid} from 'uuid';
import {NameGeneratorService} from "./name-generator.service";

@Injectable({
  providedIn: 'root'
})
export class GeneratorService {

  private uuidGen: uuid;

  constructor(private nameGen: NameGeneratorService) {
    this.uuidGen = uuid;
  }

  generateName(): string {
    return this.nameGen.generateName();
  }

  generateType(): string {
    if (Math.random() > 0.5) {
      return 'pub';
    } else {
      return 'priv';
    }
  }

  generateId() {
    return this.uuidGen.v4();
  }
}
