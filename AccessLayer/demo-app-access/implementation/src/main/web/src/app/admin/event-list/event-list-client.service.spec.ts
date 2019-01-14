import { TestBed } from '@angular/core/testing';

import { EventListClientService } from './event-list-client.service';

describe('EventListClientService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: EventListClientService = TestBed.get(EventListClientService);
    expect(service).toBeTruthy();
  });
});
