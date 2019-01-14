package com.jlupin.bnk.demo.controller;

import com.jlupin.bnk.demo.common.util.Zamulator;
import com.jlupin.bnk.demo.service.interfaces.CreateCustomerService;
import com.jlupin.bnk.demo.service.interfaces.SearchCustomerService;
import com.jlupin.bnk.demo.service.pojo.CustomerCreationView;
import com.jlupin.bnk.demo.service.pojo.CustomerReadView;
import com.jlupin.bnk.demo.service.queue.StatsQueue;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletResponse;
import java.util.Collection;
import java.util.UUID;

// This controller ignores CORS rules!
// Don't do that on production.
@RestController()
@CrossOrigin(origins = "*")
@RequestMapping("/customer")
class CudCustomerController {

	private final StatsQueue statsQueue;
	private final CreateCustomerService createCustomerService;
	private final SearchCustomerService searchCustomerService;
	private final Zamulator zamulator;

	@Autowired
	CudCustomerController(
			@Qualifier("statsQueue") StatsQueue statsQueue,
			@Qualifier("createCustomerService") CreateCustomerService createCustomerService,
			@Qualifier("searchCustomerService") SearchCustomerService searchCustomerService,
			Zamulator zamulator) {
		this.statsQueue = statsQueue;
		this.createCustomerService = createCustomerService;
		this.searchCustomerService = searchCustomerService;

		this.zamulator = zamulator;
	}


	@PutMapping("/create/{id}")
	@ResponseBody
	CustomerReadView createCustomer(@PathVariable("id") UUID id,
	                                @RequestBody CustomerCreationView customer,
	                                HttpServletResponse response) {
		response.setHeader("Access-Control-Allow-Origin", "*");
		String queueProcessId = statsQueue.
				createCustomerRequest(
						id,
						customer.getLogin(),
						customer.getType()
				);
		this.zamulator.zamul(500);
		String createId = createCustomerService.create(customer, id);
		return new CustomerReadView(createId, customer.getLogin(), customer.getType());
	}

	@GetMapping("/find")
	@ResponseBody
	Collection<CustomerReadView> findByName(@RequestParam("customerName") String name,
	                                        HttpServletResponse response) {
		response.setHeader("Access-Control-Allow-Origin", "*");

		return searchCustomerService.searchByLogin(name);
	}
}
