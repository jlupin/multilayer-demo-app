package com.jlupin.bnk.demo.service.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.io.Serializable;

@Data
@AllArgsConstructor
public class CustomerReadView implements Serializable {

	private String systemId;
	private String login;
	private String type;
}
