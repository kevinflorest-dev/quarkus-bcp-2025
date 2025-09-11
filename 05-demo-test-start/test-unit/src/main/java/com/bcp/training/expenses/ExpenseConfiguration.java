package com.bcp.training.expenses;

import io.smallrye.config.ConfigMapping;

import java.math.BigDecimal;

@ConfigMapping(prefix = "expense")
public interface ExpenseConfiguration {
    BigDecimal maxAmount();
}
