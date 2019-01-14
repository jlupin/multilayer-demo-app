package com.jlupin.bnk.demo.configuration;

import com.jlupin.impl.client.delegator.balance.JLupinQueueLoadBalancerDelegatorImpl;
import com.jlupin.impl.client.util.JLupinClientUtil;
import com.jlupin.impl.client.util.channel.JLupinClientChannelUtil;
import com.jlupin.impl.client.util.publisher.JLupinClientPublisherUtil;
import com.jlupin.bnk.demo.common.util.Zamulator;
import com.jlupin.bnk.demo.common.util.ZamulatorImpl;
import com.jlupin.interfaces.client.delegator.JLupinDelegator;
import com.jlupin.interfaces.common.enums.PortType;
import com.jlupin.interfaces.microservice.partofjlupin.asynchronous.service.channel.JLupinChannelManagerService;
import com.jlupin.interfaces.microservice.partofjlupin.asynchronous.service.queue.JLupinQueueManagerService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;

@Configuration
@ComponentScan("com.jlupin.bnk.demo")
public class StatisticsSpringConfiguration {
	@Bean
	public JLupinDelegator getJLupinDelegator() {
		return JLupinClientUtil.generateInnerMicroserviceLoadBalancerDelegator(PortType.JLRMC);
	}

	// @Bean(name = "exampleService")
	// public ExampleService getExampleService() {
	//     return JLupinClientUtil.generateRemote(getJLupinDelegator(), "example-microservice", ExampleService.class);
	// }

	@Bean(name = "jLupinRegularExpressionToRemotelyEnabled")
	public List getRemotelyBeanList() {
		List<String> list = new ArrayList<>();
		list.add("statsCollectorService");
		// list.add("<REMOTE_SERVICE_NAME>");
		return list;
	}


	@Bean(name = "jLupinClientChannelUtil")
	public JLupinClientChannelUtil getJLupinClientChannelUtil() {
		JLupinChannelManagerService jLupinChannelManagerService =
				JLupinClientUtil.generateRemote(
						getJLupinDelegator(),
						"channelMicroservice",
						"jLupinChannelManagerService",
						JLupinChannelManagerService.class);

		return new JLupinClientChannelUtil("ADM", jLupinChannelManagerService);
	}

	@Bean(name = "executorServiceForAdmChannel")
	public ExecutorService getExecutorService() {
		return JLupinClientUtil.getExecutorServiceByNameManagedByJLupin("THREAD_POOL_1");
	}

	@Bean
	public Zamulator zamulator(){
		return new ZamulatorImpl();
	}
}

