

/**
 * Class CuentaBancaria
 */
public class CuentaBancaria {

  //
  // Fields
  //

  private double saldo;
  
  //
  // Constructors
  //
  public CuentaBancaria (double saldo) {
 	this.saldo = saldo;
  };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  /**
   * Set the value of saldo
   * @param newVar the new value of saldo
   */
  public void setSaldo (double newVar) {
    saldo = newVar;
  }

  /**
   * Get the value of saldo
   * @return the value of saldo
   */
  public double getSaldo () {
    return saldo;
  }

  //
  // Other methods
  //

  /**
   * @param        saldo
   */


  /**
   * @return       double
   */


  /**
   * @param        deposito
   */
  public void depositar(double deposito)
  {
	  saldo += deposito;
  }


  /**
   * @param        retirar
   */
  public void retirar(double retirar)
  {
	  if(this.saldo-retirar > -1){
		  this.saldo-=retirar;
		  System.out.println("retiro = "+retirar);
		  System.out.println("Saldo actual: "+this.saldo);
	  }
	  else{
		  this.saldo-=retirar;
		  System.out.println("Saldo insuficiente");
	  }
  }


}
