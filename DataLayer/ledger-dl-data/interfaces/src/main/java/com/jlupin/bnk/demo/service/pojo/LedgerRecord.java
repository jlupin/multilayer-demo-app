package com.jlupin.bnk.demo.service.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.io.Serializable;
import java.util.UUID;

@Data
@AllArgsConstructor
public class LedgerRecord implements Serializable {

    private static final long serialVersionUID = 6196304785055578714L;

    private UUID id;
    private String  customerId;

    public LedgerRecord(String customerId) {
        this.id = UUID.randomUUID();
        this.customerId = customerId;
    }
}
