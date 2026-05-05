class RealImage implements Image {

	private String filename;

	public RealImage(String filename) {
		this.filename = filename;
		loadFromDisk();
	}

	private void loadFromDisk() {
		System.out.println("Cargando imagen desde disco: "+ filename);
	}

	@Override
	public void display() {
		System.out.println("Mostrar imagen: "+ filename);
	}
}
