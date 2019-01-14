import {Component, Inject, OnInit} from '@angular/core';
import {CustomerReadView} from "../customer-read-view.model";
import {MAT_DIALOG_DATA, MatDialogRef} from "@angular/material";
import {EventView} from "../../../admin/event-list/event.model";

@Component({
  templateUrl: './user-details.component.html'
})
export class UserDetailsComponent implements OnInit {

  user: CustomerReadView;
  saga: EventView[]

  constructor(private dialogRef: MatDialogRef<UserDetailsComponent>,
              @Inject(MAT_DIALOG_DATA) private data) {
  }

  ngOnInit() {
    this.user = this.data.user;
    this.saga = this.data.saga;
  }

}
