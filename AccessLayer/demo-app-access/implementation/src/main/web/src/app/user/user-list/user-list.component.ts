import {Component, OnInit} from '@angular/core';
import {HttpClient, HttpHeaders, HttpParams} from "@angular/common/http";
import {CustomerReadView} from "./customer-read-view.model";
import {MatDialog, MatDialogRef} from "@angular/material";
import {UserDetailsComponent} from "./user-details/user-details.component";
import {EventView} from "../../admin/event-list/event.model";

@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html',
  styleUrls: ['./user-list.component.css']
})
export class UserListComponent implements OnInit {

  users: CustomerReadView[] = [];
  userDialog: MatDialogRef<UserDetailsComponent>;
  private apiUrl = 'http://127.0.0.1:8000/api-gateway/customer/find/';
  private statsUrl = 'http://127.0.0.1:8000/admin-gateway/events/allById/';

  constructor(private httpClient: HttpClient, private dialog: MatDialog) {
  }

  ngOnInit() {
  }

  findUsers(userNameInput: HTMLInputElement) {
    const searchValue = userNameInput.value;
    console.error(searchValue);
    if (searchValue.length >= 3) {
      let searchParams = new HttpParams();
      searchParams = searchParams.set("customerName", searchValue);
      const httpHeaders = new HttpHeaders({
        'Content-Type': 'application/json'
      });
      const httpOptions = {
        headers: httpHeaders,
        params: searchParams
      };
      this.httpClient.get(this.apiUrl, httpOptions)
        .toPromise()
        .then(cst => {
          return cst as Promise<CustomerReadView[]>;
        }).then(c => {
        this.users = c;
      });
    }
  }

  openUserDialog(user: CustomerReadView) {
    let searchParams = new HttpParams();
    searchParams = searchParams.set("eventId", user.systemId);
    const httpHeaders = new HttpHeaders({
      'Content-Type': 'application/json'
    });
    const httpOptions = {
      headers: httpHeaders,
      params: searchParams
    };
    this.httpClient.get(this.statsUrl, httpOptions)
      .toPromise()
      .then(eventsArray => {
        return eventsArray as Promise<EventView[]>;
      }).then(ev => {
      this.userDialog = this.dialog.open(UserDetailsComponent, {
        data: {
          user: user,
          saga: ev
        }
      });
    });

  }
}
