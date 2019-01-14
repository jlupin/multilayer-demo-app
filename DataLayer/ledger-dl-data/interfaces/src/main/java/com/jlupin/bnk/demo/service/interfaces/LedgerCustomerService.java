package com.jlupin.bnk.demo.service.interfaces;

import com.jlupin.bnk.demo.service.pojo.LedgerRecord;

public interface LedgerCustomerService {

    String SERVICE_NAME ="ledgerCustomerService";

    boolean save(LedgerRecord ledgerRecord);
}
