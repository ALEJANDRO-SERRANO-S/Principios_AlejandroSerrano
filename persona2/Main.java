

/**
 * Class Main
 */
public class Main {

  //
  // Fields
  //

  
  //
  // Constructors
  //
  public Main () { };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  //
  // Other methods
  //

  /**
   * @param        args
   */
  public static void main(String args [])
  {
	  Estudiante e1 = new Estudiante("Alejandro",19,"H",24003929,72.89,"ISW");
	  Estudiante e2 = new Estudiante("VictorLalo",19,"H",24003984,78.90,"ISW");	  Estudiante e3 = new Estudiante("Paco",21,"H",24003941,87.08,"ISW");
	  Docente d1 = new Docente("adsoftsito",50,"H",1,50000.00,"Doctor");
	  Docente d2 = new Docente("Martin",50,"H",2,51000.00,"Profesor");
	  Docente d3 = new Docente("Rita",33,"M",3,53000,"Profesor");
	  e1.datosAlumno();
	  e2.datosAlumno();
	  e3.datosAlumno();
	  d1.datosDocente();
	  d2.datosDocente();
	  d3.datosDocente();
  }


}
