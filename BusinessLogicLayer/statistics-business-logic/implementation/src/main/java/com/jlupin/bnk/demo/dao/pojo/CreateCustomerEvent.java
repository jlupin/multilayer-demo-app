package com.jlupin.bnk.demo.dao.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.io.Serializable;
import java.util.UUID;

@Data
@AllArgsConstructor
public class CreateCustomerEvent implements Serializable {
	private final UUID requestId;
	private final String login;
	private final String type;
}
