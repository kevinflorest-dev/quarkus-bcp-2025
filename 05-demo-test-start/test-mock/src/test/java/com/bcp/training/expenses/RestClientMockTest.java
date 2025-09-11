package com.bcp.training.expenses;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import org.eclipse.microprofile.rest.client.inject.RestClient;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

@QuarkusTest
public class RestClientMockTest {

    @InjectMock
    @RestClient
    FraudScoreService fraudScoreService;

    @Test
    public void highFraudScoreReturns400() {
        Mockito.when(
                fraudScoreService.getByAmount(Mockito.anyDouble())
        ).thenReturn(new FraudScore(500));
    }
}
