package helpers;

import java.io.DataOutputStream;
import java.io.IOException;

public class Characters {

	// Char0-3 Reserved
	private Character characters[] = new Character[256];
	private int currentChar = 4;
	
	public Characters() {
		initChars();
	}

	private void initChars(){
		characters[0] = new Character(255);
		characters[1] = new Character(0);
		characters[2] = new Character(new int[]{255,247, 81,247,247, 81,247,255});
		characters[3] = new Character(new int[]{247, 81,  0, 81, 81,  0, 81,247});
		for(int i = 4; i < 256 ; i++)
		{
			characters[i] = new Character(0);
		}
	}	
	
	public int checkAndAdd(Character chr){
		for(int i = 0; i < currentChar; i++)
			if(characters[i].equals(chr))
				return i;
		
		return add(chr);
	}

	private int add(Character chr){
		characters[currentChar] = chr;
		currentChar++;
		return currentChar - 1;
	}
	
	public void print(){
		System.out.println("Number of Characters used: " + currentChar);
	}	
	
	public void write(DataOutputStream dos) throws IOException{
		for(int i = 0; i < 256; i++)
			characters[i].write(dos);
	}
}


