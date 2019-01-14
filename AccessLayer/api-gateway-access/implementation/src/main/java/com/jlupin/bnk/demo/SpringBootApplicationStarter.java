package com.jlupin.bnk.demo;

import com.jlupin.bnk.demo.configuration.ApiGatewaySpringConfiguration;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SpringBootApplicationStarter {
	public static void main(String[] args) throws Exception {
		SpringApplication.run(ApiGatewaySpringConfiguration.class, args);
	}
}

