package helpers;

import java.io.DataOutputStream;
import java.io.IOException;

public class ColorDefinition {

	// Values 0 - 15
	int selectedColor;
	int multiColor1;
	int multiColor2;
	int bkgColor;
	
	public ColorDefinition(){
		
	}

	public ColorDefinition(int selCol,
							int mCol1,
							int mCol2,
							int bkgCol) {
		
		selectedColor = selCol;
		multiColor1 = mCol1;
		multiColor2 = mCol2;
		bkgColor = bkgCol;
	}

	public void add(String col, String value)
	{
//		System.out.println(col + " - " + value);
		if("selCol".equals(col))
			selectedColor = Integer.parseInt(value);
		if("mCol1".equals(col))
			multiColor1 = Integer.parseInt(value);
		if("mCol2".equals(col))
			multiColor2 = Integer.parseInt(value);
		if("bkgCol".equals(col))
			bkgColor = Integer.parseInt(value);
	}
	
	public int getBitPair(int paletteEntry){
		if(paletteEntry == selectedColor)
			return 3;
		if(paletteEntry == multiColor2)
			return 2;
		if(paletteEntry == multiColor1)
			return 1;
		
		return 0;
		
	}
	
	
	public void print(){
		System.out.println("\t\tselCol " + selectedColor);
		System.out.println("\t\tmCol1 " + multiColor1);
		System.out.println("\t\tmCol2 " + multiColor2);
		System.out.println("\t\tbkgCol " + bkgColor);
	}

	public void write(DataOutputStream dos) throws IOException {
		dos.write(selectedColor);
		dos.write(multiColor1);
		dos.write(multiColor2);
		dos.write(bkgColor);
	}	
}
