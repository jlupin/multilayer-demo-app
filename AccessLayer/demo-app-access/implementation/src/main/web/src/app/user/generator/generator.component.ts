import {Component, OnInit} from '@angular/core';
import {GeneratorService} from './generator.service';
import {HttpClient, HttpHeaders} from '@angular/common/http';
import {User} from '../user';
import {interval, Subscription} from "rxjs";

@Component({
  selector: 'app-generator',
  templateUrl: './generator.component.html',
  styleUrls: ['./generator.component.css']
})
export class GeneratorComponent implements OnInit {

  private baseUrl = 'http://127.0.0.1:8000/api-gateway/customer/create/';
  currentUser: User;
  private generator: Subscription;


  constructor(private generatorService: GeneratorService,
              private httpClient: HttpClient) {
  }

  ngOnInit(): void {
  }

  startGenerate() {
    const source = interval(1000);
    this.generator = source.subscribe(val => this.generate());
  }

  generateSingle() {
    this.generate();
  }

  stopGenerator() {
    this.generator.unsubscribe();
  }

  private generate() {
    const id = this.generatorService.generateId();
    const type = this.generatorService.generateType();
    const httpOptions = {
      headers: new HttpHeaders({
        'Content-Type': 'application/json'
      })
    };

    this.currentUser = new User(this.generatorService.generateName(), type);

    this.httpClient.put(
      this.baseUrl + id,
      this.currentUser,
      httpOptions
    ).subscribe();
  }
}
