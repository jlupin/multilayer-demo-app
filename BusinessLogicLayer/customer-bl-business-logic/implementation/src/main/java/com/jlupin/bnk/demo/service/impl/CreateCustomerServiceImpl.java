package com.jlupin.bnk.demo.service.impl;

import com.jlupin.impl.client.util.queue.JLupinClientQueueUtil;
import com.jlupin.bnk.demo.common.util.Zamulator;
import com.jlupin.bnk.demo.service.interfaces.CreateCustomerService;
import com.jlupin.bnk.demo.service.interfaces.CustomerService;
import com.jlupin.bnk.demo.service.pojo.Customer;
import com.jlupin.bnk.demo.service.pojo.CustomerCreationView;
import com.jlupin.bnk.demo.service.pojo.LedgerCustomer;
import com.jlupin.bnk.demo.service.queue.StatsQueue;
import io.vavr.control.Try;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service(value = "createCustomerService")
public class CreateCustomerServiceImpl implements CreateCustomerService {
    private final StatsQueue statsQueue;
    private final JLupinClientQueueUtil ledgerQueue;

    private final CustomerService customerService;
    private final Zamulator zamulator;

    @Autowired
    CreateCustomerServiceImpl(
            @Qualifier("statsQueue") StatsQueue statsQueue,
            @Qualifier("ledgerQueueClientUtil") JLupinClientQueueUtil ledgerQueue,
            @Qualifier(CustomerService.SERVICE_NAME) CustomerService customerService,
            Zamulator zamulator) {
        this.statsQueue = statsQueue;
        this.ledgerQueue = ledgerQueue;
        this.customerService = customerService;
        this.zamulator = zamulator;
    }

    @Override
    public String create(CustomerCreationView customer, UUID requestId) {
        statsQueue.createCustomer(
                requestId,
                customer.getLogin(),
                customer.getType()
        );
        this.zamulator.zamul(1000);
        String ledgerOrNull = Try.of(() -> ledgerQueue.putTaskInput(
                "ledger-bl", "customerRegistryService", "registerCustomer",
                        new Object[]{
                                new LedgerCustomer(requestId, customer.getLogin(), customer.getType())
                        })).getOrNull();

        Customer customerModel = new Customer(requestId, customer.getLogin());
        this.zamulator.zamul(1000);
        customerService.save(customerModel, requestId);
        return requestId.toString();
    }
}