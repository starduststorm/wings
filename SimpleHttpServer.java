import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.function.Consumer;

public class SimpleHttpServer {

  private Consumer<Map<String, String>> callback;
  HttpServer server = null;
  
    public void setup(Consumer<Map<String, String>> callback) throws Exception {
      this.callback = callback;
      start();
    }
    
    public void start() throws Exception {
        HttpServer server = HttpServer.create(new InetSocketAddress(8000), 0);
        server.createContext("/", new RequestHandler(this));
        server.setExecutor(null); // Use the default executor
        server.start();
        System.out.println("Server started on port 8000...");
    }

  
    class RequestHandler implements HttpHandler {
      private final SimpleHttpServer server;

        public RequestHandler(SimpleHttpServer server) {
            this.server = server;
        }

        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String query = exchange.getRequestURI().getQuery();
            Map<String, String> parameters = getQueryMap(query);
            
            if (server.callback != null) {
                server.callback.accept(parameters);
            }
            
            String response = "Received parameters: " + parameters.toString();
            exchange.sendResponseHeaders(200, response.getBytes().length);
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }

        private Map<String, String> getQueryMap(String query) {
            Map<String, String> queryParams = new HashMap<>();
            if (query != null) {
                String[] pairs = query.split("&");
                for (String pair : pairs) {
                    String[] keyValue = pair.split("=");
                    if (keyValue.length == 2) {
                        queryParams.put(keyValue[0], keyValue[1]);
                    }
                }
            }
            return queryParams;
        }
    }
}
