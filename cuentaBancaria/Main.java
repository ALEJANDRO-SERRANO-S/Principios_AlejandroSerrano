

/**
 * Class Main
 */

import java.util.Scanner;

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
  public static void main(String[] args)
  {
	  CuentaBancaria cuenta1 = new CuentaBancaria(1000);

	  Scanner entrada = new Scanner(System.in);
	  
	  System.out.println("Saldo inicial = "+ cuenta1.getSaldo());
	  
	  System.out.print("deposito = ");
	  cuenta1.depositar(entrada.nextDouble());
	 
	  do{
		  System.out.print("retirando ");
		  cuenta1.retirar(entrada.nextDouble());
		  
	  }while(cuenta1.getSaldo()>=0);
  }


}
