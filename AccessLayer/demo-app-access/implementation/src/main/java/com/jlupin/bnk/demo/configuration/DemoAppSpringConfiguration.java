package com.jlupin.bnk.demo.configuration;

import com.jlupin.impl.client.util.JLupinClientUtil;
import com.jlupin.interfaces.client.delegator.JLupinDelegator;
import com.jlupin.interfaces.common.enums.PortType;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@ComponentScan({
		"com.jlupin.bnk.demo",
		"com.jlupin.servlet.monitor.configuration"
})
public class DemoAppSpringConfiguration {
	@Bean
	public JLupinDelegator getJLupinDelegator() {

		return JLupinClientUtil.generateInnerMicroserviceLoadBalancerDelegator(PortType.JLRMC);
	}

	// @Bean(name = "exampleService")
	// public ExampleService getExampleService() {
	//     return JLupinClientUtil.generateRemote(getJLupinDelegator(), "example-microservice", ExampleService.class);
	// }
}

