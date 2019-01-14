package com.jlupin.bnk.demo.service.impl;

import com.jlupin.bnk.demo.service.interfaces.LedgerCustomerService;
import com.jlupin.bnk.demo.service.pojo.LedgerRecord;
import org.springframework.stereotype.Repository;
import pl.setblack.airomem.core.Command;
import pl.setblack.airomem.core.PersistenceController;
import pl.setblack.airomem.core.builders.PrevaylerBuilder;

import java.io.Serializable;
import java.nio.file.Paths;

@Repository(LedgerCustomerService.SERVICE_NAME)
public class LedgerCustomerServiceAiromem implements LedgerCustomerService, Serializable {

    private static final long serialVersionUID = -5516940670988391083L;

    private final PersistenceController<LedgerCustomerServiceImpl> controller;

    public LedgerCustomerServiceAiromem() {
        this.controller = PrevaylerBuilder
                .<LedgerCustomerServiceImpl>newBuilder()
                .withFolder(Paths.get("../storage/ledger-storage"))
                .useSupplier(LedgerCustomerServiceImpl::new)
                .disableRoyalFoodTester()
                .build();
    }

    @Override
    public boolean save(LedgerRecord ledgerRecord) {
        Command<LedgerCustomerServiceImpl, Boolean> saveRecord = new SaveRecord(ledgerRecord);
        return controller.executeAndQuery(saveRecord);
    }


    private static final class SaveRecord implements Command<LedgerCustomerServiceImpl, Boolean>{

        private final LedgerRecord record;

        private SaveRecord(LedgerRecord record) {
            this.record = record;
        }

        @Override
        public Boolean execute(LedgerCustomerServiceImpl ledgerCustomerService) {
            return ledgerCustomerService.save(record);
        }
    }
}
