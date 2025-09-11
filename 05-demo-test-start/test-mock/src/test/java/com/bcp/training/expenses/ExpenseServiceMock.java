package com.bcp.training.expenses;

import io.quarkus.test.InjectMock;
import io.quarkus.test.Mock;
import io.restassured.http.ContentType;
import jakarta.enterprise.context.ApplicationScoped;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.util.UUID;

import static io.restassured.RestAssured.given;

@Mock
@ApplicationScoped
public class ExpenseServiceMock extends ExpenseService{

    @InjectMock
    ExpenseService mockExpenseService;

    @Override
    public boolean exists(UUID uuid) {
        return !uuid.equals(UUID.fromString(CrudTest.NON_EXISTING_UUID));
    }


}
