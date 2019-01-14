package com.jlupin.bnk.demo.service.queue;

import com.jlupin.impl.client.util.publisher.JLupinClientPublisherUtil;
import io.vavr.control.Try;

import java.util.UUID;

public class StatsQueueFactory {

    public static StatsQueue statsQueue(JLupinClientPublisherUtil publisherUtil) {
        return new StatsQueue() {
            @Override
            public String createCustomerRequest(UUID systemId, String login, String type) {
                return Try.of(() -> publisherUtil.
                        publishTaskToAllSubscribers("statistics",
                                "statsCollectorService",
                                "createCustomerRequest",
                                new Object[]{
                                        systemId,
                                        login,
                                        type
                                })).getOrNull();
            }

            @Override
            public String createCustomer(UUID requestId, String login, String type) {
                return Try.of(() -> publisherUtil.
                        publishTaskToAllSubscribers("statistics", "statsCollectorService", "createCustomer",
                                new Object[]{
                                        requestId,
                                        login,
                                        type
                                })).getOrNull();
            }

            @Override
            public String saveCustomer(UUID systemId, UUID createId, String login) {
                return Try.of(() -> publisherUtil.
                        publishTaskToAllSubscribers("statistics", "statsCollectorService", "saveCustomer",
                                new Object[]{
                                        systemId,
                                        createId,
                                        login
                                })).getOrNull();
            }

            @Override
            public String registerCustomer(UUID systemId, String type) {
                return Try.of(() -> publisherUtil. publishTaskToAllSubscribers("statistics", "statsCollectorService", "registerCustomer",
                        new Object[]{
                                systemId,
                                type
                })).getOrNull();
            }
        };
    }
}
