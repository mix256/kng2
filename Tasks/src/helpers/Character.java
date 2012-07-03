package helpers;

import java.awt.image.BufferedImage;
import java.io.DataOutputStream;
import java.io.IOException;

public class Character {
	
	private int[] data = new int[8];

	public Character(int fill) {
		for(int i = 0; i < 8; i++)
			data[i] = fill;
	}	

	public Character(int[] _data) {
		for(int i = 0; i < 8; i++)
			data[i] = _data[i];
	}	
	public Character(BufferedImage img, int x, int y, Palette palette)
	{
		for(int j=0; j < Tiles.CHAR_SIZE_PX; j++)
		{
			int dat = 0;
			int a = 6;
			for(int i = 0; i < Tiles.CHAR_SIZE_PX; i += 2)
			{
				int col = (img.getRGB(x + i, y + j)) & 0x0ffffff;
				dat |= (palette.getBitPair(col, y) << a);
				a -= 2;
			}
			data[j] = dat;
		}
	}
	
	public int getData(int index){
		return data[index];
	}

	public void print(){
		System.out.print("\t");
		for(int i = 0; i < 8; i++)
			System.out.print(data[i] + ", ");
		
		System.out.println("");
	}
	
	public boolean equals(Character chara){
		
		for(int i = 0; i < 8; i++)
			if(data[i] != chara.getData(i))
				return false;
				
		return true;
	}
	
	public void write(DataOutputStream dos) throws IOException{
		for(int i = 0; i < data.length; i++)
			dos.write(data[i]);
	}	
}
