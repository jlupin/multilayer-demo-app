package com.jlupin.bnk.demo.configuration;

import com.jlupin.impl.client.delegator.balance.JLupinQueueLoadBalancerDelegatorImpl;
import com.jlupin.impl.client.util.JLupinClientUtil;
import com.jlupin.impl.client.util.publisher.JLupinClientPublisherUtil;
import com.jlupin.bnk.demo.service.interfaces.LedgerCustomerService;
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
public class LedgerDlSpringConfiguration {

	@Bean(name = "jlrmcJLupinDelegator")
	public JLupinDelegator getJLupinDelegator() {
		return JLupinClientUtil.generateInnerMicroserviceLoadBalancerDelegator(PortType.JLRMC);
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


	// @Bean(name = "exampleService")
	// public ExampleService getExampleService() {
	//     return JLupinClientUtil.generateRemote(getJLupinDelegator(), "example-microservice", ExampleService.class);
	// }

	@Bean(name = "jLupinRegularExpressionToRemotelyEnabled")
	public List getRemotelyBeanList() {
		List<String> list = new ArrayList<>();
		 list.add(LedgerCustomerService.SERVICE_NAME);
		return list;
	}
}

