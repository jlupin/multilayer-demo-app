package com.jlupin.bnk.demo.service.interfaces;

import com.jlupin.bnk.demo.service.pojo.Customer;

import java.util.Collection;
import java.util.Optional;
import java.util.UUID;

public interface CustomerService {

	String SERVICE_NAME= "customerService";

	Customer save(Customer customer, UUID correlationId);

	Optional<Customer> read(UUID customerId);

	Optional<Customer> readByLogin(String login);

	Customer delete(Customer customer);

	Collection<Customer> all();
}