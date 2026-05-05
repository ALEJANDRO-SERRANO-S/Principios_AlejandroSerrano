public class Main {

	public static void main(String[] args) {

		DVDPlayer dvd = new DVDPlayer();
		Amplifier amp = new Amplifier();
		Projector projector = new Projector();

		HomeTheaterFacade homeTheater =
			new HomeTheaterFacade(dvd, amp, projector);

		homeTheater.watchMovie("Matrix");
	}
}
