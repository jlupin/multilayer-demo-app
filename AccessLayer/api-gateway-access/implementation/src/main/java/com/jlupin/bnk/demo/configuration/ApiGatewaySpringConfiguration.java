package com.jlupin.bnk.demo.configuration;

import com.jlupin.impl.client.delegator.balance.JLupinQueueLoadBalancerDelegatorImpl;
import com.jlupin.impl.client.util.JLupinClientUtil;
import com.jlupin.impl.client.util.publisher.JLupinClientPublisherUtil;
import com.jlupin.bnk.demo.common.util.Zamulator;
import com.jlupin.bnk.demo.common.util.ZamulatorImpl;
import com.jlupin.bnk.demo.service.interfaces.CreateCustomerService;
import com.jlupin.bnk.demo.service.interfaces.SearchCustomerService;
import com.jlupin.bnk.demo.service.queue.StatsQueue;
import com.jlupin.bnk.demo.service.queue.StatsQueueFactory;
import com.jlupin.interfaces.client.delegator.JLupinDelegator;
import com.jlupin.interfaces.common.enums.PortType;
import com.jlupin.interfaces.microservice.partofjlupin.asynchronous.service.queue.JLupinQueueManagerService;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
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
public class ApiGatewaySpringConfiguration {

    @Bean(name = "JlrmcJLupinDelegator")
    public JLupinDelegator getJLupinDelegator() {
        return JLupinClientUtil.generateInnerMicroserviceLoadBalancerDelegator(PortType.JLRMC);
    }


    @Bean(name = "createCustomerService")
    public CreateCustomerService createCustomerService(
            @Qualifier("JlrmcJLupinDelegator")
                    JLupinDelegator jLupinDelegator
    ) {
        return JLupinClientUtil.generateRemote(jLupinDelegator, "customer-bl", CreateCustomerService.class);
    }


    @Bean(name = "searchCustomerService")
    public SearchCustomerService searchCustomerService(
            @Qualifier("JlrmcJLupinDelegator")
                    JLupinDelegator jLupinDelegator
    ) {
        return JLupinClientUtil.generateRemote(jLupinDelegator, "customer-bl", SearchCustomerService.class);
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
        return JLupinClientUtil.generateRemote(getQueueJLupinDelegator(), "queueMicroservice", "jLupinQueueManagerService", JLupinQueueManagerService.class);
    }

    @Bean(name = "statsClientPublisherUtil")
    public JLupinClientPublisherUtil getStatsClientPublisherUtil(JLupinQueueManagerService jLupinQueueManagerService) {
        return new JLupinClientPublisherUtil("STATS", jLupinQueueManagerService);
    }

    @Bean(name = "statsQueue")
    public StatsQueue statsQueue(@Qualifier("statsClientPublisherUtil") JLupinClientPublisherUtil publisherUil) {
        return StatsQueueFactory.statsQueue(publisherUil);
    }

    @Bean
    public Zamulator zamulator(){
        return new ZamulatorImpl();
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