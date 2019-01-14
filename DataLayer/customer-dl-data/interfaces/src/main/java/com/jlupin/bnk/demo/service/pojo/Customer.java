package com.jlupin.bnk.demo.service.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.io.Serializable;
import java.util.UUID;

@Data
@AllArgsConstructor
public class Customer implements Serializable {

	private static final long serialVersionUID = 5551016736962106740L;

	private final UUID id;
	private final String login;

	public Customer(String login) {
		this.id = UUID.randomUUID();
		this.login = login;
	}
}