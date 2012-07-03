package helpers;

import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;

import javax.imageio.ImageIO;


public class Room {

	private String file;
	
	private BufferedImage png;
	private int width;
	private int height;
	
	Palette palette;
	
	int[] roomInCharacters;
	int widthInChars;
	int heightInChars;
	
	int[] roomInTiles;
	int widthInTiles;
	int heightInTiles;
	
	int[] roomInLargeTiles;
	int widthInLargeTiles;
	
	public void loadImage(String filename, int number) throws IOException
	{
		file = filename + "_" + number + ".png";
		System.out.println("Reading File: " + file);
		png = ImageIO.read(new File(file));		
		width = png.getWidth();
		height = png.getHeight();

		widthInChars = width / Tiles.CHAR_SIZE_PX;
		heightInChars = height / Tiles.CHAR_SIZE_PX;
		
		widthInTiles = widthInChars / Tiles.TILE_WIDTH_CH;
		heightInTiles = heightInChars / Tiles.TILE_HEIGHT_SMALL_CH;
		
		widthInLargeTiles = widthInTiles;

		if(height != 200)
		{
			System.out.println("Invalid image height: " + height);
			throw new IOException();
		}
		if((widthInChars % Tiles.TILE_WIDTH_CH) != 0)
		{
			System.out.println("Invalid image width: " + width);
			throw new IOException();
		}
		
		palette = new Palette();
		
		roomInCharacters = new int[widthInChars * heightInChars];
		System.out.println("roomInCharacters len " + roomInCharacters.length);
		
		roomInTiles = new int[widthInTiles * heightInTiles];
		System.out.println("roomInTiles len " + roomInTiles.length);
		
		roomInLargeTiles = new int[widthInLargeTiles];
		System.out.println("roomInLargeTiles len " + roomInLargeTiles.length);
		
	}
	
	public void loadColorDefinitions(String filename, int number){
		String pFile = filename + "_" + number + ".properties";
		System.out.println("Reading File: " + pFile);
		
		FileReader file = null;
		try {
			file = new FileReader(pFile);
		} catch (FileNotFoundException e1) {
			e1.printStackTrace();
			return;
		}
		
		BufferedReader br = new BufferedReader(file);
		
		boolean done = false;
		
		while(!done){
			String line;
			try {
				line = br.readLine();
				if(line != null){
					String[] props = line.split("=");
					if(props.length == 2){
						props[0].trim();
						props[1].trim();
						palette.add(props[0], props[1]);
					}
				}
				else
					done = true;
			} catch (IOException e) {
				done = true;
			} catch (Exception e) {
				e.printStackTrace();
				done = true;
			}
		}
	}
	
	public void convert(Characters chars, Tiles tiles)
	{
		System.out.println("Creating chars for " + file);
		int a = 0;
		for(int j = 0; j < height; j += Tiles.CHAR_SIZE_PX)
		{
			for(int i = 0; i < width; i += Tiles.CHAR_SIZE_PX)
			{
				Character chr = new Character(png, i, j, palette);
				roomInCharacters[a] = chars.checkAndAdd(chr);
				a++;
			}
		}

		System.out.println("Creating Small tiles for " + file);
		a = 0;
		for(int j = 0; j < heightInChars; j += Tiles.TILE_HEIGHT_SMALL_CH)
		{
			for(int i = 0; i < widthInChars; i += Tiles.TILE_WIDTH_CH)
			{
				Tile tile = new Tile(roomInCharacters, i, j, widthInChars);
				roomInTiles[a] = tiles.checkAndAddSmall(tile);
				a++;
			}
		}

		System.out.println("Creating Large tiles for " + file);
		a = 0;
		for(int i = 0; i < widthInTiles; i ++)
		{
			TileLarge tile = new TileLarge(roomInTiles, i, widthInTiles);
			roomInLargeTiles[a] = tiles.checkAndAddLarge(tile);
			a++;
		}
	}	
	
	public void print(){
		//palette.print();
		int a = 0;
		System.out.println("Room (in large tiles):");
		for(int i = 0; i < widthInLargeTiles; i++)
		{
			System.out.print(" " + roomInLargeTiles[a]);
			a++;
		}
		System.out.println();
		System.out.println("Room Size (chars): " + widthInChars +  "x" + heightInChars);
		System.out.println("Room Size (tiles): " + widthInTiles +  "x" + heightInTiles);
		System.out.println("Room Size (ltiles): " + widthInLargeTiles +  "x1");
		System.out.println("Total size (bytes): " + (widthInTiles) + " bytes");
	}
	
	public void save(DataOutputStream dos) throws IOException{
		int a = 0;
		palette.write(dos);
		dos.write(widthInLargeTiles); // len
		for(int i = 0; i < widthInLargeTiles; i++){
			dos.write(roomInLargeTiles[i]);
		}
	}
}
