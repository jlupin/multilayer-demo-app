package com.jlupin.bnk.demo.controller;

import com.jlupin.bnk.demo.service.interfaces.StatsCollectorService;
import com.jlupin.bnk.demo.service.pojo.EventView;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.UUID;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/events")
class EventListController {

	private final StatsCollectorService statsCollectorService;

	@Autowired
	EventListController(
			@Qualifier("statsCollectorService")
			StatsCollectorService statsCollectorService) {
		this.statsCollectorService = statsCollectorService;
	}

	@GetMapping("/all")
	public @ResponseBody List<EventView> allEvents(HttpServletResponse response){
		response.setHeader("Access-Control-Allow-Origin", "*");
		return statsCollectorService.getEvents();
	}

	@GetMapping("/allById")
	public @ResponseBody List<EventView> allEventsById(
			@RequestParam("eventId") String eventId,
			HttpServletResponse response){
		response.setHeader("Access-Control-Allow-Origin", "*");
		return statsCollectorService.getEventsById(UUID.fromString(eventId));
	}


}
