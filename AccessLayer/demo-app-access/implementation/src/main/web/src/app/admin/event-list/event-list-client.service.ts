import {Injectable} from '@angular/core';
import {EventView} from "./event.model";
import {HttpClient, HttpHeaders} from "@angular/common/http";

@Injectable({
  providedIn: 'root'
})
export class EventListClientService {

  private serviceAddress = 'http://127.0.0.1:8000/admin-gateway/events/all';

  constructor(private http: HttpClient) {
  }

  public allEvents(): Promise<EventView[]> {
    const httpOptions = {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      })
    };
    return this.http.get(
      this.serviceAddress,
      httpOptions
    ).toPromise()
      .then(response => response as Promise<EventView[]>)
      .catch((reason: any) => {
        console.error(reason.toString());
        return [];
      });
  }
}
