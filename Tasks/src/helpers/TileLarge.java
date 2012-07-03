package helpers;

import java.io.DataOutputStream;
import java.io.IOException;

public class TileLarge {

	int data[] = new int[5];

	public TileLarge(int[] tilesInRoom, int x, int mapWidth){
		int a = 0;
		for(int j = 0; j < 5; j++)
		{
			data[a] = tilesInRoom[x + (j * mapWidth)];
			a++;
		}
	}
	
	public boolean equals(TileLarge tile){
		for(int i = 0; i < 5; i++)
			if(data[i] != tile.getData()[i])
				return false;
		
		return true;
	}
	
	public int[] getData(){
		return data;
	}	
	
	public void write(DataOutputStream dos) throws IOException{
		for(int i = 0; i < data.length; i++)
			dos.write(data[i]);
	}
	
}
