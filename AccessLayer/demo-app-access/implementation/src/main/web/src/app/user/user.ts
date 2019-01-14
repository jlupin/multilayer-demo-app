export class User {
  login: string;
  type: string

  constructor(login: string, type: string) {
    this.login = login;
    this.type = type;
  }
}
