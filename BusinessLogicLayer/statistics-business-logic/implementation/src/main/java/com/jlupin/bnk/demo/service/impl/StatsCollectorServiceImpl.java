package com.jlupin.bnk.demo.service.impl;

import com.jlupin.impl.client.util.channel.JLupinClientChannelUtil;
import com.jlupin.impl.client.util.channel.exception.JLupinClientChannelUtilException;
import com.jlupin.bnk.demo.common.util.Zamulator;
import com.jlupin.bnk.demo.dao.pojo.CreateCustomerEvent;
import com.jlupin.bnk.demo.dao.pojo.CreateCustomerRequestEvent;
import com.jlupin.bnk.demo.dao.pojo.RegisterCustomerEvent;
import com.jlupin.bnk.demo.dao.pojo.SaveCustomerEvent;
import com.jlupin.bnk.demo.service.interfaces.StatsCollectorService;
import com.jlupin.bnk.demo.service.pojo.EventView;
import com.jlupin.interfaces.microservice.partofjlupin.asynchronous.storage.channel.status.type.JLupinStreamChannelStatusType;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.io.Serializable;
import java.security.SecureRandom;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.stream.Collectors;

@Service(value = "statsCollectorService")
public class StatsCollectorServiceImpl implements StatsCollectorService, Serializable {

	private final List<EventView> eventViews;
	private final Set<String> channelStreams;
	private final Zamulator zamulator;
	private final Random random;
	private final ExecutorService executorService;
	private final JLupinClientChannelUtil jLupinClientChannelUtil;


	public StatsCollectorServiceImpl(Zamulator zamulator,
	                                 @Qualifier("executorServiceForAdmChannel") ExecutorService executorService,
	                                 @Qualifier("jLupinClientChannelUtil") JLupinClientChannelUtil jLupinClientChannelUtil) {
		this.random = new SecureRandom();
		this.zamulator = zamulator;
		this.executorService = executorService;
		this.jLupinClientChannelUtil = jLupinClientChannelUtil;
		// TODO zmienić na strukturę bez emisji.
		// Pani Liskov wyraża się niepochleblnie o tym kodzie
		this.eventViews = new LinkedList<EventView>() {
			@Override
			public boolean add(EventView o) {
				emitForAll(o);
				return super.add(o);
			}
		}; // no z bezpieczeństwem wątków to jest nie do końca OK.
		this.channelStreams = new HashSet<>();
	}

	@Override
	public void createCustomerRequest(UUID systemId, String login, String type) {
		CreateCustomerRequestEvent ccre = new CreateCustomerRequestEvent(systemId, login, type);
		eventViews.add(new EventView(ccre.getClass().getSimpleName(), ccreToMap(ccre)));
	}

	@Override
	public void createCustomer(UUID requestId, String login, String type) {
		CreateCustomerEvent cce = new CreateCustomerEvent(requestId, login, type);
		eventViews.add(new EventView(cce.getClass().getSimpleName(), cceToMap(cce)));
	}

	@Override
	public void saveCustomer(UUID systemId, UUID createId, String login) {
		SaveCustomerEvent sce = new SaveCustomerEvent(systemId, createId, login);
		eventViews.add(new EventView(sce.getClass().getSimpleName(), sceToMap(sce)));
	}

	@Override
	public boolean registerCustomer(UUID systemId, String type) {
		RegisterCustomerEvent rce = new RegisterCustomerEvent(systemId, type);
		return eventViews.add(new EventView(rce.getClass().getSimpleName(), rceToMap(rce)));
	}

	@Override
	public List<EventView> getEvents() {
		// def copy with implementation change.
		return eventViews.stream().collect(Collectors.toList());
	}

	@Override
	public List<EventView> getEventsById(UUID eventId) {
		return eventViews.stream()
				.filter(ev -> eventId.toString().equalsIgnoreCase(String.valueOf(ev.getParams().get("request-id"))))
				.collect(Collectors.toList());
	}

	@Override
	public String makeChannelStreamReadable() throws JLupinClientChannelUtilException {
		String streamChannelId = jLupinClientChannelUtil.openStreamChannel();
		channelStreams.add(streamChannelId);
		return streamChannelId;
	}

	@Override
	public void closeChannel(String channelId) {
		try {
			JLupinStreamChannelStatusType status = jLupinClientChannelUtil.getJLupinStreamChannelStatusType(channelId);
			if (status == JLupinStreamChannelStatusType.STREAM_CHANNEL_OPEN) {
				jLupinClientChannelUtil.closeStreamChannel(channelId);
				channelStreams.remove(channelId);
			}
		} catch (JLupinClientChannelUtilException e) {
		}

	}

	private void emitForAll(EventView eventView) {
		channelStreams.forEach(channelId -> {
			executorService.submit((Callable<Void>) () -> {
				JLupinStreamChannelStatusType status = jLupinClientChannelUtil.getJLupinStreamChannelStatusType(channelId);
				if (status == JLupinStreamChannelStatusType.STREAM_CHANNEL_OPEN) {
					jLupinClientChannelUtil.putNextElementToStreamChannel(channelId, eventView);
				}
				return null;
			});

		});
	}

	private Map<String, ? extends Serializable> rceToMap(RegisterCustomerEvent rce) {
		Map<String, Serializable> params = new HashMap<>();
		params.put("request-id", rce.getUuid());
		params.put("type", rce.getType());
		return params;
	}

	private Map<String, ? extends Serializable> sceToMap(SaveCustomerEvent cce) {
		Map<String, Serializable> params = new HashMap<>();
		params.put("db-id", cce.getUuid());
		params.put("request-id", cce.getCreateCustomerId());
		params.put("login", cce.getLogin());
		return params;
	}

	private Map<String, ? extends Serializable> cceToMap(CreateCustomerEvent cce) {
		Map<String, Serializable> params = new HashMap<>();
		params.put("request-id", cce.getRequestId());
		params.put("login", cce.getLogin());
		params.put("type", cce.getType());
		return params;
	}

	private Map<String, ? extends Serializable> ccreToMap(CreateCustomerRequestEvent ccre) {
		Map<String, Serializable> params = new HashMap<>();
		params.put("request-id", ccre.getUuid());
		params.put("login", ccre.getLogin());
		params.put("type", ccre.getType());
		return params;
	}
}