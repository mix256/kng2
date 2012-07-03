package helpers;

import java.io.DataOutputStream;
import java.io.IOException;

public class Tile {

	private int data[] = new int[Tiles.TILE_HEIGHT_SMALL_CH * Tiles.TILE_WIDTH_CH];

	public Tile(int[] roomInChars, int x, int y, int mapWidth){
		int a = 0;
		for(int j = 0; j < Tiles.TILE_HEIGHT_SMALL_CH; j++)
			for(int i = 0; i < Tiles.TILE_WIDTH_CH; i++){
			{
				data[a] = roomInChars[(i + x) + ((j + y) * mapWidth)];
				a++;
			}
		}
	}
	
	public boolean equals(Tile tile){
		for(int i = 0; i < Tiles.TILE_HEIGHT_SMALL_CH * Tiles.TILE_WIDTH_CH; i++)
			if(data[i] != tile.getData()[i])
				return false;
		
		return true;
	}

	public int[] getData(){
		return data;
	}
	
	public void write(DataOutputStream dos) throws IOException{
		for(int j = 0; j < Tiles.TILE_WIDTH_CH; j++)
			for(int i = 0; i < Tiles.TILE_HEIGHT_SMALL_CH; i++)
			dos.write(data[j  + (i*Tiles.TILE_WIDTH_CH)]);
	}
	
}
