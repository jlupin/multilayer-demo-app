package com.jlupin.bnk.demo.service.impl;

import com.jlupin.impl.client.util.channel.JLupinClientChannelUtil;
import com.jlupin.impl.client.util.queue.JLupinClientQueueUtil;
import com.jlupin.bnk.demo.common.util.Zamulator;
import com.jlupin.bnk.demo.service.interfaces.CustomerRegistryService;
import com.jlupin.bnk.demo.service.interfaces.LedgerCustomerService;
import com.jlupin.bnk.demo.service.pojo.LedgerCustomer;
import com.jlupin.bnk.demo.service.pojo.LedgerRecord;
import com.jlupin.bnk.demo.service.queue.StatsQueue;
import com.jlupin.interfaces.function.JLupinQueueReactiveFunction;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.ExecutorService;

@Service(value = "customerRegistryService")
public class CustomerRegistryServiceImpl implements CustomerRegistryService {

    private final List<LedgerCustomer> privateCustomers = new LinkedList<>();
    private final List<LedgerCustomer> publicCustomers = new LinkedList<>();

    private final Zamulator zamulator;
    private final Random random;
    private final StatsQueue statsQueue;
    private final JLupinClientQueueUtil statsQueueClientUtil;
    private final LedgerCustomerService ledgerCustomerService;
    private final ExecutorService executorService;

    private final JLupinClientChannelUtil jLupinClientChannelUtil;


    @Autowired
    public CustomerRegistryServiceImpl(Zamulator zamulator,
                                       @Qualifier("statsQueue") StatsQueue statsQueue,
                                       @Qualifier("statsQueueClientUtil") JLupinClientQueueUtil statsQueueClientUtil,
                                       @Qualifier(LedgerCustomerService.SERVICE_NAME) LedgerCustomerService ledgerCustomerService,
                                       @Qualifier("executorServiceForAdmChannel") ExecutorService executorService,
                                       @Qualifier("jLupinClientChannelUtil") JLupinClientChannelUtil jLupinClientChannelUtil) {
        this.zamulator = zamulator;
        this.statsQueue = statsQueue;
        this.statsQueueClientUtil = statsQueueClientUtil;
        this.ledgerCustomerService = ledgerCustomerService;
        this.executorService = executorService;
        this.jLupinClientChannelUtil = jLupinClientChannelUtil;
        this.random = new SecureRandom();
    }

    @Override
    public void registerCustomer(LedgerCustomer ledgerCustomer) {
        UUID id = UUID.randomUUID();
        String statsOrNull = statsQueue.registerCustomer(
                ledgerCustomer.getCustomerId(),
                ledgerCustomer.getType()
        );

        statsQueueClientUtil.registerFunctionOnTaskResult(statsOrNull, 1000L, new JLupinQueueReactiveFunction() {

            @Override
            public void onSuccess(String queueId, Object o) {
                System.out.printf("Operation %s finish with result %s \n", queueId, o);
            }

            @Override
            public void onError(String s, Throwable throwable) {

            }
        });

        if ("priv".equalsIgnoreCase(ledgerCustomer.getType())) {
            privateCustomers.add(ledgerCustomer);
        }
        if ("pub".equalsIgnoreCase(ledgerCustomer.getType())) {
            publicCustomers.add(ledgerCustomer);
        }

        ledgerCustomerService.save(new LedgerRecord(id, statsOrNull));
    }

}