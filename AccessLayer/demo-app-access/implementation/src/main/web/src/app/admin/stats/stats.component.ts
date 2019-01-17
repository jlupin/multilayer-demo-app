import {Component, OnInit} from '@angular/core';
import {Observable, Subscription} from 'rxjs';

@Component({
  selector: 'app-stats',
  templateUrl: './stats.component.html',
  styleUrls: ['./stats.component.css']
})
export class StatsComponent implements OnInit {
  lastEventName = '';

  ccr = 0;
  cc = 0;
  sc = 0;
  rc = 0;
  ccrParams: { [key: string]: string } = {};
  ccParams: { [key: string]: string } = {};
  scParams: { [key: string]: string } = {};
  rcParams: { [key: string]: string } = {};
  private channel: Observable<any>;
  private activeSubscription: Subscription;
  private showUnsub: boolean;

  constructor() {
  }

  ngOnInit() {
    this.showUnsub = false;
  }

  readEvents() {
    this.channel = Observable.create(observer => {
        const eventSource = new EventSource('http://127.0.0.1:8000/admin-gateway/list'); // Cannot find EventSource
        eventSource.onmessage = x => observer.next(x.data);
        eventSource.onerror = x => observer.error(x);

        return () => {
          eventSource.close();
        };
      }
    );

    this.activeSubscription = this.channel.subscribe({
      next: guid => {
        const responseJson = JSON.parse(guid);
        this.lastEventName = responseJson.name;
        console.log(responseJson)
        console.log(responseJson.params)
        switch (this.lastEventName) {
          case 'CreateCustomerRequestEvent': {
            this.ccr += 1;
            this.ccrParams = responseJson.params;
            break;
          }
          case 'CreateCustomerEvent': {
            this.cc += 1;
            this.ccParams = responseJson.params;
            break;
          }
          case 'SaveCustomerEvent': {
            this.sc += 1;
            this.scParams = responseJson.params;
            break;
          }
          case 'RegisterCustomerEvent': {
            this.rc += 1;
            this.rcParams = responseJson.params;
            break;
          }
          default: {
            break;
          }
        }
      },
      error: err => console.error('something wrong occurred: ' + err)
    });
    this.showUnsub = true;
  }

  stopEvents() {
    this.activeSubscription.unsubscribe();
    this.showUnsub = false;
  }

  resetCounters() {
    this.ccr = 0;
    this.cc = 0;
    this.sc = 0;
    this.rc = 0;
  }
}
