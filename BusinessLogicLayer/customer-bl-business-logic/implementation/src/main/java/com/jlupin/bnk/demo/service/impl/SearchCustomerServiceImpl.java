package com.jlupin.bnk.demo.service.impl;

import com.jlupin.bnk.demo.service.interfaces.CustomerService;
import com.jlupin.bnk.demo.service.interfaces.SearchCustomerService;
import com.jlupin.bnk.demo.service.pojo.CustomerReadView;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.stream.Collectors;

@Service(value = "searchCustomerService")
public class SearchCustomerServiceImpl implements SearchCustomerService {

	private final CustomerService customerService;

	public SearchCustomerServiceImpl(@Qualifier(CustomerService.SERVICE_NAME) CustomerService customerService) {
		this.customerService = customerService;
	}

	@Override
	public Collection<CustomerReadView> searchByLogin(String loginPart) {
		return customerService.all()
				.stream()
				.filter(cst -> cst.getLogin().toLowerCase().contains(loginPart.toLowerCase()))
				.map(c -> new CustomerReadView(c.getId().toString(), c.getLogin(), ""))
				.collect(Collectors.toList());
	}
}