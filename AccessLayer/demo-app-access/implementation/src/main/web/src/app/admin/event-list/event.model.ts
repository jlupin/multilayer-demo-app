export class EventView {

  public name: string;
  public params: {[key:string]:string}


  constructor(name: string, params: { [p: string]: string }) {
    this.name = name;
    this.params = params;
  }
}
