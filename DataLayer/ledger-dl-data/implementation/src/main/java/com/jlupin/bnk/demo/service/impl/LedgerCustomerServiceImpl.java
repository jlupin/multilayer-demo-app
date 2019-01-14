package com.jlupin.bnk.demo.service.impl;

import com.jlupin.bnk.demo.service.interfaces.LedgerCustomerService;
import com.jlupin.bnk.demo.service.pojo.LedgerRecord;

import java.io.Serializable;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

class LedgerCustomerServiceImpl implements LedgerCustomerService, Serializable {

    private static final long serialVersionUID = 7910779296202987621L;

    private final ConcurrentHashMap<UUID, LedgerRecord> storage;

    LedgerCustomerServiceImpl() {
        storage = new ConcurrentHashMap<>();
    }

    @Override
    public boolean save(LedgerRecord ledgerRecord) {
        storage.put(ledgerRecord.getId(), ledgerRecord);
        return true;
    }
}
