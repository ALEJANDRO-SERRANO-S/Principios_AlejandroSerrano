import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
	// Instancia única del Singleton
	private static DatabaseConnection instance;
	// Objeto conexión
	private Connection connection;
	// Datos de conexión
	private static final String URL = "jdbc:mysql://localhost:3306/mi_base";
	private static final String USER = "alejandro";
	private static final String PASSWORD = "alejandro";
	// Constructor privado
	private DatabaseConnection() {
		try {
			// Crear la conexión
			connection = DriverManager.getConnection(URL, USER, PASSWORD);
			System.out.println("Conexión establecida");
		} catch (SQLException e) {
			throw new RuntimeException("Error al conectar a la base de datos", e);
		}
	}
	// Método de acceso global
	public static DatabaseConnection getInstance() {
		if(instance  == null) {
			instance = new DatabaseConnection();
		}
		return instance;
	}

	// Método para obtener la conexión
	public Connection getConnection() {
		return connection;
	}
}
