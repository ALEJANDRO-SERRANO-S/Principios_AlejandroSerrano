public class Main {

	public static void main(String[] args) {

		Graphic circle = new Circle();

		Graphic borderedCircle = new BorderDecorator(circle);
		Graphic fancyCircle = new ShadowDecorator(new BorderDecorator(circle));

		System.out.println("Circulo simple: ");
		circle.draw();

		System.out.println("\nCirculo con borde: ");
		borderedCircle.draw();

		System.out.println("\nCirculo con borde y sombra: ");
		fancyCircle.draw();
	}
}
