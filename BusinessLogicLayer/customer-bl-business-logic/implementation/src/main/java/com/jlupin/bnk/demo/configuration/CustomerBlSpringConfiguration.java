package com.jlupin.bnk.demo.configuration;

import com.jlupin.impl.client.delegator.balance.JLupinQueueLoadBalancerDelegatorImpl;
import com.jlupin.impl.client.util.JLupinClientUtil;
import com.jlupin.impl.client.util.publisher.JLupinClientPublisherUtil;
import com.jlupin.impl.client.util.queue.JLupinClientQueueUtil;
import com.jlupin.bnk.demo.common.util.Zamulator;
import com.jlupin.bnk.demo.common.util.ZamulatorImpl;
import com.jlupin.bnk.demo.service.Const;
import com.jlupin.bnk.demo.service.interfaces.CustomerService;
import com.jlupin.bnk.demo.service.queue.StatsQueue;
import com.jlupin.bnk.demo.service.queue.StatsQueueFactory;
import com.jlupin.interfaces.client.delegator.JLupinDelegator;
import com.jlupin.interfaces.common.enums.PortType;
import com.jlupin.interfaces.microservice.partofjlupin.asynchronous.service.queue.JLupinQueueManagerService;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

import java.util.ArrayList;
import java.util.List;

@Configuration
@ComponentScan("com.jlupin.bnk.demo")
public class CustomerBlSpringConfiguration {

	@Bean(name = "jlrmcJLupinDelegator")
	public JLupinDelegator getJLupinDelegator() {
		return JLupinClientUtil.generateInnerMicroserviceLoadBalancerDelegator(PortType.JLRMC);
	}

	@Bean(name = CustomerService.SERVICE_NAME)
	public CustomerService customerService(
			@Qualifier("jlrmcJLupinDelegator") JLupinDelegator jlrmcJLupinDelegator) {
		return JLupinClientUtil.generateRemote(jlrmcJLupinDelegator,
				Const.MICROSERVICE_NAME,
				CustomerService.class);
	}

	@Bean(name = "jLupinRegularExpressionToRemotelyEnabled")
	public List getRemotelyBeanList() {
		List<String> list = new ArrayList<>();
		list.add("createCustomerService");
		list.add("searchCustomerService");
		return list;
	}

	@Bean(name = "QueueJLupinDelegator")
	public JLupinDelegator getQueueJLupinDelegator() {
		final JLupinDelegator jLupinDelegator = JLupinClientUtil.generateInnerMicroserviceLoadBalancerDelegator(PortType.QUEUE);
		((JLupinQueueLoadBalancerDelegatorImpl) jLupinDelegator).setGetStatusAnalyseAndChooseHighestFromAllEnvironment(true);
		return jLupinDelegator;
	}

	@Bean
	public JLupinQueueManagerService getJLupinQueueManagerService(
			@Qualifier("QueueJLupinDelegator")
					JLupinDelegator queueJLupinDelegator) {
		return JLupinClientUtil.generateRemote(queueJLupinDelegator, "queueMicroservice", "jLupinQueueManagerService", JLupinQueueManagerService.class);
	}

	@Bean(name = "statsClientPublisherUtil")
	public JLupinClientPublisherUtil getStatsClientPublisherUtil(JLupinQueueManagerService jLupinQueueManagerService) {
		return new JLupinClientPublisherUtil("STATS", jLupinQueueManagerService);
	}

	@Bean(name = "statsQueue")
	public StatsQueue statsQueue(@Qualifier("statsClientPublisherUtil") JLupinClientPublisherUtil publisherUil) {
		return StatsQueueFactory.statsQueue(publisherUil);
	}

	@Bean(name = "ledgerClientPublisherUtil")
	public JLupinClientPublisherUtil getLedgerClientPublisherUtil(JLupinQueueManagerService jLupinQueueManagerService) {
		return new JLupinClientPublisherUtil("LEDGER", jLupinQueueManagerService);
	}

	@Bean(name = "ledgerQueueClientUtil")
	public JLupinClientQueueUtil getSampleQueueClientUtil(JLupinQueueManagerService jLupinQueueManagerService) {
		return new JLupinClientQueueUtil("LEDGER", jLupinQueueManagerService);
	}


	@Bean
	public Zamulator zamulator(){
		return new ZamulatorImpl();
	}
}

