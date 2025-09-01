package pe.joedayz.helidonjsonstore;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.List;

@Path("/expenses")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ExpenseResource {

    @Inject
    private OracleJsonService oracleJsonService;

    @GET
    public List<Expense> getAllExpenses() {
        return oracleJsonService.findAll();
    }

    @GET
    @Path("/{id}")
    public Response getExpenseById(@PathParam("id") String id) {
        return oracleJsonService.findById(id)
                .map(expense -> Response.ok(expense).build())
                .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }

    @GET
    @Path("/category/{category}")
    public List<Expense> getExpensesByCategory(@PathParam("category") String category) {
        return oracleJsonService.findByCategory(category);
    }

    @GET
    @Path("/method/{method}")
    public List<Expense> getExpensesByMethod(@PathParam("method") String method) {
        return oracleJsonService.findByMethod(method);
    }

    @GET
    @Path("/amount-range")
    public List<Expense> getExpensesByAmountRange(
            @QueryParam("min") double minAmount, 
            @QueryParam("max") double maxAmount) {
        return oracleJsonService.findByAmountRange(minAmount, maxAmount);
    }

    @GET
    @Path("/search")
    public List<Expense> searchExpensesByDescription(@QueryParam("q") String description) {
        return oracleJsonService.findByDescriptionContaining(description);
    }

    @POST
    public Response createExpense(Expense expense) {
        Expense savedExpense = oracleJsonService.save(expense);
        return Response.status(Response.Status.CREATED)
                .entity(savedExpense)
                .build();
    }

    @PUT
    @Path("/{id}")
    public Response updateExpense(@PathParam("id") String id, Expense expense) {
        if (!oracleJsonService.findById(id).isPresent()) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        
        Expense updatedExpense = new Expense(id, expense.amount(), expense.method(), 
                                          expense.category(), expense.createdAt(), expense.description());
        Expense saved = oracleJsonService.update(updatedExpense);
        return Response.ok(saved).build();
    }

    @DELETE
    @Path("/{id}")
    public Response deleteExpense(@PathParam("id") String id) {
        if (!oracleJsonService.findById(id).isPresent()) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        
        oracleJsonService.deleteById(id);
        return Response.noContent().build();
    }

    @GET
    @Path("/statistics")
    public Response getExpenseStatistics() {
        OracleJsonService.ExpenseStatistics stats = oracleJsonService.getStatistics();
        return Response.ok(stats).build();
    }

    @GET
    @Path("/total/category/{category}")
    public Response getTotalByCategory(@PathParam("category") String category) {
        double total = oracleJsonService.getTotalByCategory(category);
        return Response.ok(new TotalAmount(category, total)).build();
    }

    @GET
    @Path("/total/method/{method}")
    public Response getTotalByMethod(@PathParam("method") String method) {
        double total = oracleJsonService.getTotalByMethod(method);
        return Response.ok(new TotalAmount(method, total)).build();
    }

    // Helper class for total amount response
    public static class TotalAmount {
        private final String type;
        private final double total;

        public TotalAmount(String type, double total) {
            this.type = type;
            this.total = total;
        }

        public String getType() { return type; }
        public double getTotal() { return total; }
    }
}
