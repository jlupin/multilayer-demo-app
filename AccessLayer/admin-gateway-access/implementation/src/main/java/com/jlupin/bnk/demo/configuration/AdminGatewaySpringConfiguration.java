package com.jlupin.bnk.demo.configuration;

import com.jlupin.bnk.demo.service.interfaces.SearchCustomerService;
import com.jlupin.impl.client.util.JLupinClientUtil;
import com.jlupin.impl.client.util.channel.JLupinClientChannelIterableProducer;
import com.jlupin.bnk.demo.service.interfaces.StatsCollectorService;
import com.jlupin.interfaces.client.delegator.JLupinDelegator;
import com.jlupin.interfaces.common.enums.PortType;
import com.jlupin.interfaces.microservice.partofjlupin.asynchronous.service.channel.JLupinChannelManagerService;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.config.EnableWebFlux;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

@Configuration
@ComponentScan({
		"com.jlupin.bnk.demo",
		"com.jlupin.servlet.monitor.configuration"
})
@EnableWebFlux
public class AdminGatewaySpringConfiguration {
	@Bean("JlrmcJLupinDelegator")
	public JLupinDelegator getJLupinDelegator() {
		return JLupinClientUtil.generateInnerMicroserviceLoadBalancerDelegator(PortType.JLRMC);
	}

	@Bean(name = "statsCollectorService")
	public StatsCollectorService statsCollectorService(JLupinDelegator jLupinDelegator) {
		return JLupinClientUtil.generateRemote(jLupinDelegator, "statistics", StatsCollectorService.class);
	}

	@Bean
	public JLupinChannelManagerService getJLupinChannelManagerService(JLupinDelegator jLupinDelegator) {
		return JLupinClientUtil.generateRemote(jLupinDelegator, "channelMicroservice", "jLupinChannelManagerService", JLupinChannelManagerService.class);
	}

	@Bean
	public JLupinClientChannelIterableProducer getJLupinClientChannelIterableProducer(JLupinChannelManagerService jLupinChannelManagerService) {
		return new JLupinClientChannelIterableProducer(jLupinChannelManagerService);
	}

	@Bean(name = "searchCustomerService")
	public SearchCustomerService searchCustomerService(
			@Qualifier("JlrmcJLupinDelegator")
					JLupinDelegator jLupinDelegator
	) {
		return JLupinClientUtil.generateRemote(jLupinDelegator, "customer-bl", SearchCustomerService.class);
	}

}

@Configuration
@EnableSwagger2
class SwaggerConfig {
	@Bean
	public Docket api() {
		return new Docket(DocumentationType.SWAGGER_2)
				.select()
				.apis(RequestHandlerSelectors.any())
				.paths(PathSelectors.any())
				.build();
	}
}