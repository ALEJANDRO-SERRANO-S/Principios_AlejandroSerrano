public class House {
	private String walls;
	private String roof;
	private boolean garage;

	// Setters (solo para el Builder)
	public void setWalls(String walls){
		this.walls = walls;
	}

	public void setRoof(String roof) {
		this.roof = roof;
	}

	public void setGarage(boolean garage){
		this.garage = garage;
	}

	public void show() {
		System.out.println(
				"Casa con "+ walls +
				", techo de " + roof +
				", garaje: " + garage);
	}
}

