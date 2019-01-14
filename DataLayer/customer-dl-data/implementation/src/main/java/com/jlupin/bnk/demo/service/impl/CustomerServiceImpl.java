package com.jlupin.bnk.demo.service.impl;

import com.jlupin.bnk.demo.service.interfaces.CustomerService;
import com.jlupin.bnk.demo.service.pojo.Customer;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

class CustomerServiceImpl implements CustomerService, Serializable {
	private static final long serialVersionUID = -6612674656420194029L;

	private final ConcurrentHashMap<UUID, Customer> storage;

	CustomerServiceImpl() {
		this.storage = new ConcurrentHashMap<>();
	}

	@Override
	public Customer save(Customer customer, UUID correlationId) {
		storage.put(customer.getId(), customer);
		return customer;
	}

	@Override
	public Optional<Customer> read(UUID customerId) {
		return Optional.ofNullable(storage.get(customerId));
	}

	@Override
	public Optional<Customer> readByLogin(String login) {
		return storage.values().stream().filter(c -> c.getLogin().equals(login)).findFirst();
	}

	@Override
	public Customer delete(Customer customer) {
		return storage.remove(customer.getId());
	}

	@Override
	public Collection<Customer> all() {
		return new ArrayList<>(storage.values());
	}
}