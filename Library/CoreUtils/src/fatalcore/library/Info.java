package fatalcore.library;

import processing.core.*;

public class Info {
	
	public final static String VERSION = "1.0.0";	

	public Info() {
		welcome();
	}
		
	private void welcome() {
		System.out.println("Core Utilities 1.0.0 by Kevin Formosa http://fatalcore.com");
	}
		
	/**
	 * Returns the version of the Library.
	 * 
	 * @return String
	 */
	public static String version() {
		return VERSION;
	}
}