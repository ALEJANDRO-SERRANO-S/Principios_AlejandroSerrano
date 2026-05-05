class HomeTheaterFacade {

	private DVDPlayer dvd;
	private Amplifier amp;
	private Projector projector;

	HomeTheaterFacade(DVDPlayer dvd, Amplifier amp, Projector projector) {
		this.dvd = dvd;
		this.amp = amp;
		this.projector = projector;
	}

	void watchMovie(String movie) {
		System.out.println("Preparando cine en casa...");
		projector.on();
		amp.on();
		amp.setVolume(5);
		dvd.on();
		dvd.play(movie);
	}
}
