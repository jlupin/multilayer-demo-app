package com.jlupin.bnk.demo.service.interfaces;

import com.jlupin.bnk.demo.service.pojo.EventView;

import java.util.List;
import java.util.UUID;

public interface StatsCollectorService {

	void createCustomerRequest(UUID systemId, String login, String type);

	void createCustomer(UUID requestId, String login, String type);

	void saveCustomer(UUID systemId, UUID createId, String login);

	boolean registerCustomer(UUID systemId, String type);

	List<EventView> getEvents();

	List<EventView> getEventsById(UUID eventId);

	String makeChannelStreamReadable() throws Throwable;

	void closeChannel(String channelId);
}