
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

public class AdderGenerationTask extends Task
{
	String finalString = "";
	
	String outputDir;
	String inputFile;
	String worldName;

	ArrayList<String> type = new ArrayList<String>();
	ArrayList<String> x = new ArrayList<String>();
	ArrayList<String> xMsb = new ArrayList<String>();
	ArrayList<String> y = new ArrayList<String>();
	ArrayList<String> color = new ArrayList<String>();
	ArrayList<String> user1 = new ArrayList<String>();
	ArrayList<String> user2 = new ArrayList<String>();
	
	Map<String,String> definitions = new HashMap<String,String>();
	Map<String,String> commonDefinitions = new HashMap<String,String>();
	
	ArrayList<String> usedDefinitions = new ArrayList<String>();
	
	public void setWorldname(String name)
	{
		worldName = name;
	}
	
	public void setOutputDir(String filename)
	{
		outputDir = filename;
	}
	
	public void setInputFile(String filename)
	{
		inputFile = filename;
	}	

	/**
	 * Execute.
	 * 
	 * @throws BuildException the build exception
	 */
	public void execute() throws BuildException
	{
		try
		{
			validate();
			
			loadDefinitions();
			for(int i=0;i<10;i++)
			{
				type.clear();
				x.clear();
				xMsb.clear();
				y.clear();
				color.clear();
				user1.clear();
				user2.clear();
				convert(i);
			}
			save();
			
		}
		catch(Exception e)
		{
			throw new BuildException(e.toString());
		}
	}

	private void loadDefinition(BufferedReader br, Map def)
	{
		boolean done = false;
		while(!done)
		{
			String line;
			try {
				line = br.readLine();
				if(line != null)
				{
					String[] row = line.split("=");
					if(row.length == 2)
					{
						addDefinition(row, def);
					}
				}
				else
				{
					done = true;
					br.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
				done = true;
			}
		}
	}
	
	private void loadDefinitions()
	{
		FileReader is;
		FileReader is2;
		try {
			is = new FileReader(inputFile + "/object_definition_enemies.txt");
			is2 = new FileReader(inputFile + "/object_definition_common.txt");
		} catch (FileNotFoundException e1) {
			return;
		}
		BufferedReader br = new BufferedReader(is);
		loadDefinition(br, definitions);
		br = new BufferedReader(is2);
		loadDefinition(br, commonDefinitions);
	
		getIntegerFor("OBJECT_NONE");

		Set<String> set = commonDefinitions.keySet();
		Iterator<String> it = set.iterator();
		while(it.hasNext())
		{
			String key = it.next();
			System.out.println("######## " + key);
			getIntegerFor(key);
		}
		
	}

	private void addDefinition(String[] row, Map<String,String> def)
	{
		String property = row[0].trim();
		String value = row[1].trim();
		
		def.put(property, value);
	}

	private void convert(int index)
	{
		FileReader is;
		try {
			is = new FileReader(inputFile + "/" + worldName + "/adder/adder" + index + ".txt");
		} catch (FileNotFoundException e1) {
			return;
		}
		BufferedReader br = new BufferedReader(is);
		boolean done = false;
		while(!done)
		{
			String line;
			try {
				line = br.readLine();
				if(line != null)
				{
					String[] row = line.split(",");
					if(row.length == 6)
					{
						process(row);
					}
					else
					if(row.length == 1 && "OBJECT_NONE".equals(row[0]))
					{
						process(new String[] {"OBJECT_NONE","0","0","0","0","0"});
					}
				}
				else
				{
					done = true;
					br.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
				done = true;
			}

		}

		addStage(index);
		
	}
	
	private void process(String[] row)
	{
		try
		{
			String object = row[0].trim();
			int xpos = Integer.parseInt(row[1].trim());
			int ypos = Integer.parseInt(row[2].trim());
			int col = Integer.parseInt(row[3].trim());
			int usr1 = Integer.parseInt(row[4].trim());
			int usr2 = Integer.parseInt(row[5].trim());
			
			int objectInt = getIntegerFor(object);
			type.add("" + objectInt);
//			type.add(object);
			x.add("" + ((int)(xpos%256)));
			xMsb.add("" + ((int)(xpos/256)));
			y.add(""+ypos);
			color.add("" + col);
			user1.add("" + usr1);
			user2.add("" + usr2);
			
//			System.out.println("####################");
//			System.out.println(object);
//			System.out.println();
//			System.out.println();
//			System.out.println((int)(ypos));
//			System.out.println((int)(color));
//			System.out.println((int)(user1));
//			System.out.println((int)(user2));			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		

	}
	
	private int getIntegerFor(String object)
	{
		int index = usedDefinitions.indexOf(object);
		
		if (index == -1)
		{// create
			usedDefinitions.add(object);
			return (usedDefinitions.indexOf(object)) * 2;
		}
		
		return index * 2;
	}

	private void addToFinalString(String str)
	{
		finalString += str;
	}
	
	private void createOutput(ArrayList<String> list)
	{
		Iterator<String> output = list.iterator();
		while(output.hasNext()){
			addToFinalString(output.next());
			if(output.hasNext())
				addToFinalString(", ");
		}
	}


	private void addStage(int index)
	{
		addToFinalString("\n// ### Room: " + index + "\n");
		addToFinalString("\n//objecttypes:\n");
		addToFinalString("\t.byte ");
		createOutput(type);
		
		addToFinalString("\n//objectxpos:\n");
		addToFinalString("\t.byte ");
		createOutput(x);

		addToFinalString("\n//objectxpos_msb:\n");
		addToFinalString("\t.byte ");
		createOutput(xMsb);

		addToFinalString("\n//objectypos:\n");
		addToFinalString("\t.byte ");
		createOutput(y);
		
		addToFinalString("\n//objectcolor:\n");
		addToFinalString("\t.byte ");
		createOutput(color);

		addToFinalString("\n//objectuser1:\n");
		addToFinalString("\t.byte ");
		createOutput(user1);

		addToFinalString("\n//objectuser2:\n");
		addToFinalString("\t.byte ");
		createOutput(user2);
	}

	private void save() throws Exception
	{		
		System.out.println(finalString);
		
		// Write adder.asm
		FileOutputStream fl= new FileOutputStream(outputDir + "/" + worldName + "/adder.asm");
		DataOutputStream dos = new DataOutputStream(fl);
		dos.writeBytes(finalString);
		dos.close();
		
		// Write constants
		fl= new FileOutputStream(outputDir + "/" + worldName + "/constants.asm");
		dos = new DataOutputStream(fl);
		dos.writeBytes(getConstants());
		dos.close();
		
		
//		FileOutputStream fl= new FileOutputStream(outputFile);
//		DataOutputStream dos = new DataOutputStream(fl);

//		int a = 0;
//		log("Creating");
//		for(int j = 0; j < numberOfRows; j++)
//		{
//			String r1 = "\t" + row1 + " + " + r1i + " + " + a + "\n";
//			String r2 = "\t" + row2 + " + " + r2i + " + " + a + "\n";
//			dos.writeBytes(r1);
//			dos.writeBytes(r2);
//			a += adder;
//		}
//		
//		dos.writeBytes("\trts\n");
//		
	}

	private String getConstants()
	{
		String constants = "";

		// constants
		int objNo = 0;
		Iterator<String> keys = usedDefinitions.iterator();
		while(keys.hasNext())
		{
			String key = keys.next();
			constants += "\n\t.const " + key + " = " + objNo;
			objNo += 2;
		}

		// obj pointer list
		constants += "\n";
		objNo = 1;
		constants += "\n_world_object_pointer_list:";
		constants += "\n\t.word 0";
		keys = usedDefinitions.iterator();
		if(keys.hasNext())
			keys.next();

		while(keys.hasNext())
		{
			String key = keys.next();
			constants += "\n\t.word _label_" + objNo;
			objNo += 1;
		}
		
		// imports
		constants += "\n";
		objNo = 1;
		keys = usedDefinitions.iterator();
		if(keys.hasNext())
			keys.next();
		while(keys.hasNext())
		{
			String key = keys.next();
			String val = definitions.get(key);
			if(val == null)
				val = commonDefinitions.get(key);
				
			constants += "\n_label_" + objNo + ":";
			constants += "\n\t.import source " + val;
			objNo += 1;
		}
		
		return constants;
	}

	/**
	 * 
	 * @throws BuildException
	 */
	private void validate() throws BuildException
	{
		if(outputDir == null)
			throw new BuildException("Attribute outputDir has not been set");
		if(inputFile == null)
			throw new BuildException("Attribute inputFile has not been set");
		if(worldName == null)
			throw new BuildException("Attribute worldName has not been set");
	}
}