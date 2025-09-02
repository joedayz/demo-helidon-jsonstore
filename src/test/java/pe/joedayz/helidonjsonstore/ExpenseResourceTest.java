package pe.joedayz.helidonjsonstore;

import io.helidon.microprofile.testing.junit5.HelidonTest;
import jakarta.inject.Inject;
import jakarta.ws.rs.client.Entity;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.junit.jupiter.api.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

@HelidonTest
class ExpenseResourceTest {

    @Inject
    private jakarta.ws.rs.client.WebTarget webTarget;

    @Test
    void testCreateAndGetExpense() {
        // Create a new expense
        Expense expense = Expense.of(25.50, "CARD", "FOOD", "Lunch at restaurant");
        
        Response response = webTarget.path("/expenses")
                .request(MediaType.APPLICATION_JSON)
                .post(Entity.entity(expense, MediaType.APPLICATION_JSON));
        
        assertThat(response.getStatus(), is(201));
        
        Expense createdExpense = response.readEntity(Expense.class);
        assertThat(createdExpense.getAmount(), is(25.50));
        assertThat(createdExpense.getMethod(), is("CARD"));
        assertThat(createdExpense.getCategory(), is("FOOD"));
        assertThat(createdExpense.getDescription(), is("Lunch at restaurant"));
        assertThat(createdExpense.getId(), is(notNullValue()));
        
        // Get the expense by ID
        Response getResponse = webTarget.path("/expenses/" + createdExpense.getId())
                .request(MediaType.APPLICATION_JSON)
                .get();
        
        assertThat(getResponse.getStatus(), is(200));
        
        Expense retrievedExpense = getResponse.readEntity(Expense.class);
        assertThat(retrievedExpense.getId(), is(createdExpense.getId()));
        assertThat(retrievedExpense.getAmount(), is(25.50));
    }

    @Test
    void testGetAllExpenses() {
        Response response = webTarget.path("/expenses")
                .request(MediaType.APPLICATION_JSON)
                .get();
        
        assertThat(response.getStatus(), is(200));
        
        Expense[] expenses = response.readEntity(Expense[].class);
        assertThat(expenses, is(notNullValue()));
    }

    @Test
    void testGetExpensesByCategory() {
        Response response = webTarget.path("/expenses/category/FOOD")
                .request(MediaType.APPLICATION_JSON)
                .get();
        
        assertThat(response.getStatus(), is(200));
        
        Expense[] expenses = response.readEntity(Expense[].class);
        assertThat(expenses, is(notNullValue()));
    }

    @Test
    void testGetExpensesByMethod() {
        Response response = webTarget.path("/expenses/method/CARD")
                .request(MediaType.APPLICATION_JSON)
                .get();
        
        assertThat(response.getStatus(), is(200));
        
        Expense[] expenses = response.readEntity(Expense[].class);
        assertThat(expenses, is(notNullValue()));
    }
}
