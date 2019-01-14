package com.jlupin.bnk.demo.service.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.io.Serializable;
import java.util.UUID;

@Data
@AllArgsConstructor
public class LedgerCustomer implements Serializable {

	private static final long serialVersionUID = -7319591455655365622L;

	private final UUID customerId;
	private final String login;
	private final String type;
}
