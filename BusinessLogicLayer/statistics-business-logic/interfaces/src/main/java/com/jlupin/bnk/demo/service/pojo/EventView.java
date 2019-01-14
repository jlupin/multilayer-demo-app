package com.jlupin.bnk.demo.service.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.io.Serializable;
import java.util.Map;

@Data
@AllArgsConstructor
public class EventView implements Serializable {

	private static final long serialVersionUID = -1806484073051120019L;

	private final String name;
	private final Map<String, ? extends Serializable> params;

}
