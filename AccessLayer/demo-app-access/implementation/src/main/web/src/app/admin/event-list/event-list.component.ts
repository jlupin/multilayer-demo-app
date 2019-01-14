import {Component, OnInit} from '@angular/core';
import {EventView} from "./event.model";
import {EventListClientService} from "./event-list-client.service";

@Component({
  selector: 'app-event-list',
  templateUrl: './event-list.component.html',
  styleUrls: ['./event-list.component.css']
})
export class EventListComponent implements OnInit {

  public eventViews: EventView[] = [];
  public currentPage = 1;

  constructor(private eventListClient: EventListClientService) {
  }

  ngOnInit() {
  }

  loadEvents() {
    this.eventListClient.allEvents()
      .then(ev => {
        this.eventViews = ev;
      });
  }
}
