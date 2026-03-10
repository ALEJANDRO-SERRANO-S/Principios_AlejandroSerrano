import java.sql.Connection;

public class Main {
	public static void main(String[] args) {
		// Obtener la conexión desde diferentes puntos
		Connection conn1 = DatabaseConnection.getInstance().getConnection();
		Connection conn2 = DatabaseConnection.getInstance().getConnection();

		// Ambas referencias apuntan a la misma conexión
		System.out.println(conn1 == conn2); // true
	}
}
