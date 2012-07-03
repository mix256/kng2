package helpers;

import java.io.DataOutputStream;
import java.io.IOException;

public class Palette {

	// SELCOL = %11 = BLACK
	// MCOL2  = %10 = UDEF
	// MCOL1  = %01 = UDEF
	// BKGCOL = %00 = UDEF
		
	public static final int[] PALETTE =
	{
			0x000000,
			0xFFFFFF,
			0x68372B,
			0x70A4B2,
			0x6F3D86,
			0x588D43,
			0x352879,
			0xB8C76F,
			0x6F4F25,
			0x433900,
			0x9A6759,
			0x444444,
			0x6C6C6C,
			0x9AD284,
			0x6C5EB5,
			0x959595			
	};

	private static final int[] COORD_TO_LINE =
	{
		0, 0,
		1, 1, 1,
		2, 2, 2,
		3, 3, 3,
		4, 4, 4,
		5, 5, 5,
		6, 6, 6,
		7, 7, 7,
		8, 8
	};
	
	public Palette(){
		for(int i = 0; i < 9; i++){
			colorDefinitions[i] = new ColorDefinition();
		}
	}
	
	ColorDefinition[] colorDefinitions = new ColorDefinition[9];
	
	public void add(String lineCol, String value)
	{
//		System.out.println(lineCol + " - " + value);
		int iColType = lineCol.indexOf('.') + 1;
		int iLine = lineCol.indexOf('.') - 1;
		String col = lineCol.substring(iColType, lineCol.length());
		String line = lineCol.substring(iLine, iLine + 1);
		int lin = Integer.parseInt(line);
		colorDefinitions[lin].add(col.trim(), value.trim());
	}

	public int getBitPair(int value, int y){
		int line = COORD_TO_LINE[y  / Tiles.CHAR_SIZE_PX];
		for(int i = 0; i < 16; i++)
			if(PALETTE[i] == value)
			{
				return colorDefinitions[line].getBitPair(i);
			}
		return 0;
	}
	
	public void print(){
		for(int i = 0; i < 9; i++){
			System.out.println("\tLine " + i);
			colorDefinitions[i].print();
		}		
	}
	
	public void write(DataOutputStream dos) throws IOException{
		for(int i = 0; i < 9; i++){
			colorDefinitions[i].write(dos);
		}		
	}	
	
}
