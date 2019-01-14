package com.jlupin.bnk.demo.service.queue;

import java.util.UUID;

public interface StatsQueue {

    String createCustomerRequest(UUID systemId, String login, String type);

    String createCustomer(UUID requestId, String login, String type);

    String saveCustomer(UUID systemId, UUID createId, String login);

    String registerCustomer(UUID systemId, String type);

}
