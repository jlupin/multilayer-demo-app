package com.jlupin.bnk.demo;

import com.jlupin.bnk.demo.configuration.DemoAppSpringConfiguration;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SpringBootApplicationStarter {
	public static void main(String[] args) throws Exception {
		SpringApplication.run(DemoAppSpringConfiguration.class, args);
	}
}

