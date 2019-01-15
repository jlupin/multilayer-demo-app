import {EventView} from "../../admin/event-list/event.model";

export class CustomerReadView {

  public systemId: string;
  public login: string;
  public type: string;
  private events: EventView[];

  constructor(systemId: string, login: string, type: string, events:EventView[]) {
    this.systemId = systemId;
    this.login = login;
    this.type = type;
    this.events = events;
  }
}
