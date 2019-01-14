package com.jlupin.bnk.demo.configuration;

import com.jlupin.impl.client.delegator.balance.JLupinQueueLoadBalancerDelegatorImpl;
import com.jlupin.impl.client.util.JLupinClientUtil;
import com.jlupin.impl.client.util.channel.JLupinClientChannelUtil;
import com.jlupin.impl.client.util.publisher.JLupinClientPublisherUtil;
import com.jlupin.impl.client.util.queue.JLupinClientQueueUtil;
import com.jlupin.bnk.demo.service.LedgerConst;
import com.jlupin.bnk.demo.common.util.Zamulator;
import com.jlupin.bnk.demo.common.util.ZamulatorImpl;
import com.jlupin.bnk.demo.service.interfaces.LedgerCustomerService;
import com.jlupin.bnk.demo.service.queue.StatsQueue;
import com.jlupin.bnk.demo.service.queue.StatsQueueFactory;
import com.jlupin.interfaces.client.delegator.JLupinDelegator;
import com.jlupin.interfaces.common.enums.PortType;
import com.jlupin.interfaces.microservice.partofjlupin.asynchronous.service.channel.JLupinChannelManagerService;
import com.jlupin.interfaces.microservice.partofjlupin.asynchronous.service.queue.JLupinQueueManagerService;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;

@Configuration
@ComponentScan("com.jlupin.bnk.demo")
public class LedgerBlSpringConfiguration {
    @Bean(name = "jlrmcJLupinDelegator")
    public JLupinDelegator getJLupinDelegator() {
        return JLupinClientUtil.generateInnerMicroserviceLoadBalancerDelegator(PortType.JLRMC);
    }

    // @Bean(name = "exampleService")
    // public ExampleService getExampleService() {
    //     return JLupinClientUtil.generateRemote(getJLupinDelegator(), "example-microservice", ExampleService.class);
    // }

    @Bean(name = LedgerCustomerService.SERVICE_NAME)
    public LedgerCustomerService getLedgerCustomerService(
            @Qualifier("jlrmcJLupinDelegator") JLupinDelegator jrlmcJLupinDelegator) {
        return JLupinClientUtil.generateRemote(jrlmcJLupinDelegator, LedgerConst.MICROSERVICE_NAME, LedgerCustomerService.class);
    }

    @Bean(name = "jLupinRegularExpressionToRemotelyEnabled")
    public List getRemotelyBeanList() {
        List<String> list = new ArrayList<>();
        list.add("customerRegistryService");
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

    @Bean(name = "statsQueueClientUtil")
    public JLupinClientQueueUtil getSampleQueueClientUtil(JLupinQueueManagerService jLupinQueueManagerService) {
        return new JLupinClientQueueUtil("STATS", jLupinQueueManagerService);
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

    @Bean(name = "statsQueue")
    public StatsQueue statsQueue(@Qualifier("statsClientPublisherUtil") JLupinClientPublisherUtil publisherUil) {
        return StatsQueueFactory.statsQueue(publisherUil);
    }

    @Bean
    public Zamulator zamulator(){
        return new ZamulatorImpl();
    }
}

