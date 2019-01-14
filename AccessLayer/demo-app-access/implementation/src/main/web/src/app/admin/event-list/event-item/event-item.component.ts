import {Component, Input, OnInit} from '@angular/core';
import {EventView} from "../event.model";

@Component({
  selector: 'app-event-item',
  templateUrl: './event-item.component.html',
  styleUrls: ['./event-item.component.css']
})
export class EventItemComponent implements OnInit {

  @Input() eventView:EventView;

  constructor() { }

  ngOnInit() {
  }

}
