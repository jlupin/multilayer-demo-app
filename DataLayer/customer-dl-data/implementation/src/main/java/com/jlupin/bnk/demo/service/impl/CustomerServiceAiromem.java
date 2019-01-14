package com.jlupin.bnk.demo.service.impl;

import com.jlupin.bnk.demo.service.interfaces.CustomerService;
import com.jlupin.bnk.demo.service.pojo.Customer;
import com.jlupin.bnk.demo.service.queue.StatsQueue;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;
import pl.setblack.airomem.core.Command;
import pl.setblack.airomem.core.PersistenceController;
import pl.setblack.airomem.core.Query;
import pl.setblack.airomem.core.builders.PrevaylerBuilder;

import java.io.Serializable;
import java.nio.file.Paths;
import java.util.Collection;
import java.util.Optional;
import java.util.UUID;

@Repository(value = CustomerService.SERVICE_NAME)
public class CustomerServiceAiromem implements CustomerService, Serializable {

    private static final long serialVersionUID = -6710094014599786972L;

    private final PersistenceController<CustomerServiceImpl> controller;

    private final StatsQueue statsQueue;

    @Autowired
    public CustomerServiceAiromem(
            @Qualifier("statsQueue") StatsQueue statsQueue) {
        this.statsQueue = statsQueue;
        this.controller = PrevaylerBuilder
                .<CustomerServiceImpl>newBuilder()
                .withFolder(Paths.get("../storage/customer-storage"))
                .useSupplier(CustomerServiceImpl::new)
                .disableRoyalFoodTester()
                .build();
    }

    @Override
    public Customer save(Customer customer, UUID createId) {
        SaveCustomer saveCustomer = new SaveCustomer(customer, createId);
        statsQueue.saveCustomer(
                saveCustomer.customer.getId(),
                createId,
                customer.getLogin()
        );
        return controller.executeAndQuery(saveCustomer);
    }

    @Override
    public Optional<Customer> read(UUID customerId) {
        return controller.query(new ReadCustomer(customerId));
    }

    @Override
    public Optional<Customer> readByLogin(String login) {
        return controller.query(new ReadCustomerByLogin(login));
    }

    @Override
    public Customer delete(Customer customer) {
        return controller.executeAndQuery(new DeleteCustomer(customer));
    }

    @Override
    public Collection<Customer> all() {
        return controller.query(new ReadAll());
    }

    private static final class SaveCustomer implements Command<CustomerServiceImpl, Customer> {
        private final Customer customer;
        private final UUID saveId;

        private SaveCustomer(Customer customer, UUID saveId) {
            this.customer = customer;
            this.saveId = saveId;
        }

        @Override
        public Customer execute(CustomerServiceImpl core) {
            return core.save(customer, saveId);
        }
    }

    private static final class DeleteCustomer implements Command<CustomerServiceImpl, Customer> {
        private final Customer customer;

        private DeleteCustomer(Customer customer) {
            this.customer = customer;
        }

        @Override
        public Customer execute(CustomerServiceImpl core) {
            return core.delete(customer);
        }
    }

    private static final class ReadCustomer implements Query<CustomerServiceImpl, Optional<Customer>> {

        private final UUID customerId;

        private ReadCustomer(UUID customerId) {
            this.customerId = customerId;
        }

        @Override
        public Optional<Customer> evaluate(CustomerServiceImpl core) {
            return core.read(customerId);
        }
    }

    private static final class ReadCustomerByLogin implements Query<CustomerServiceImpl, Optional<Customer>> {

        private final String customerLogin;

        private ReadCustomerByLogin(String customerLogin) {
            this.customerLogin = customerLogin;
        }

        @Override
        public Optional<Customer> evaluate(CustomerServiceImpl core) {
            return core.readByLogin(customerLogin);
        }
    }

    private static final class ReadAll implements Query<CustomerServiceImpl, Collection<Customer>> {

        @Override
        public Collection<Customer> evaluate(CustomerServiceImpl core) {
            return core.all();
        }
    }
}
