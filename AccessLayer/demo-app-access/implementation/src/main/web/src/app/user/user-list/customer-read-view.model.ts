export class CustomerReadView {

  public systemId: string;
  public login: string;
  public type: string;

  constructor(systemId: string, login: string, type: string) {
    this.systemId = systemId;
    this.login = login;
    this.type = type;
  }
}
