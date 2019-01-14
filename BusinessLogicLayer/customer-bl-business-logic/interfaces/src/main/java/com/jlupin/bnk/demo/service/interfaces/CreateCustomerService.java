package com.jlupin.bnk.demo.service.interfaces;

import com.jlupin.bnk.demo.service.pojo.CustomerCreationView;

import java.util.UUID;

public interface CreateCustomerService {

	String create(CustomerCreationView customerCreationView, UUID requestId);
}