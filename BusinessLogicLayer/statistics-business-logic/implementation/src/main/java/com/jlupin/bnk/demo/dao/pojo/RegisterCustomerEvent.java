package com.jlupin.bnk.demo.dao.pojo;

import lombok.Data;

import java.io.Serializable;
import java.util.UUID;

@Data
public class RegisterCustomerEvent implements Serializable {
	private final UUID uuid;
	private final String type;
}
