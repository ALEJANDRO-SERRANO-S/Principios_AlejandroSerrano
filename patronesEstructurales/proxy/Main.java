public class Main {

	public static void main(String[] args) {

		Image = image = new ProxyImage("foto.png");

		// La imagen se carga solo la primera vez
		image.display();
		image.display();
	}
}
