abstract class GraphicDecorator implements Graphic {

	protected Graphic graphic;

	protected GraphicDecorator(Graphic graphic) {
		this.graphic = graphic;
	}

	@Override
	public void draw() {
		graphic.draw();
	}
}

class ShadowDecorator extends GraphicDecorator {

	public ShadowDecorator(Graphic graphic) {
		super(graphic);
	}

	@Override
	public void draw() {
		super.draw();
		System.out.println("   -> agregando sombra");
	}
}
