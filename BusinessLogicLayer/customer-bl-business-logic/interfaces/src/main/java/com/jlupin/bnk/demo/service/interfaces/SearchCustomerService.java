package com.jlupin.bnk.demo.service.interfaces;

import com.jlupin.bnk.demo.service.pojo.CustomerReadView;

import java.util.Collection;

public interface SearchCustomerService {

	Collection<CustomerReadView> searchByLogin(String loginPart);
}