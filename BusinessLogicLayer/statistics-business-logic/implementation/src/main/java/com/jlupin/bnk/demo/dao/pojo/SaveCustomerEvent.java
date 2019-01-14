package com.jlupin.bnk.demo.dao.pojo;

import lombok.Data;

import java.io.Serializable;
import java.util.UUID;

@Data
public class SaveCustomerEvent implements Serializable {
	private final UUID uuid;
	private final UUID createCustomerId;
	private final String login;
}
