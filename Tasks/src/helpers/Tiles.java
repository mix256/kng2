package helpers;

import java.io.DataOutputStream;
import java.io.IOException;

public class Tiles {

	public static final int CHAR_SIZE_PX = 8;
	public static final int TILE_WIDTH_CH = 4;
	public static final int TILE_WIDTH_PX = TILE_WIDTH_CH * CHAR_SIZE_PX;
	public static final int TILE_HEIGHT_SMALL_CH = 5;
	public static final int TILE_HEIGHT_SMALL_PX = TILE_HEIGHT_SMALL_CH * CHAR_SIZE_PX;
	
	private Tile[] tilesSmall;
	private int currentSmallTile = 0;

	private TileLarge[] tilesLarge;
	private int currentLargeTile = 0;

	public Tiles() {
		tilesSmall = new Tile[256];
		tilesLarge = new TileLarge[256];
	}
	
	public int checkAndAddSmall(Tile tile){
		for(int i = 0; i < currentSmallTile; i++)
			if(tilesSmall[i].equals(tile))
					return i;
		
		return addSmall(tile);
	}
	
	public int addSmall(Tile tile){
		tilesSmall[currentSmallTile] = tile;
		currentSmallTile++;
		return currentSmallTile - 1;
	}

	public int checkAndAddLarge(TileLarge tile){
		for(int i = 0; i < currentLargeTile; i++)
			if(tilesLarge[i].equals(tile))
					return i;
		
		return addLarge(tile);
	}
	
	public int addLarge(TileLarge tile){
		tilesLarge[currentLargeTile] = tile;
		currentLargeTile++;
		return currentLargeTile - 1;
	}	
	
	public void print(){
		System.out.println("Number of small tiles: " + currentSmallTile +" (" + (currentSmallTile * TILE_WIDTH_CH * TILE_HEIGHT_SMALL_CH) + " bytes)");
		System.out.println("Number of large tiles: " + currentLargeTile +" (" + (currentLargeTile * 5) + " bytes)");
	}
	
	public void writeSmall(DataOutputStream dos) throws IOException{
//		dos.write(currentSmallTile);	// len
		for(int i = 0; i < currentSmallTile; i++)
				tilesSmall[i].write(dos);
	}

	public void writeLarge(DataOutputStream dos) throws IOException{
//		dos.write(currentLargeTile);	// len
		for(int i = 0; i < currentLargeTile; i++)
			tilesLarge[i].write(dos);
	}	
}

