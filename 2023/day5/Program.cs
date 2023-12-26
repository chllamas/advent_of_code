class Day5
{
    static void Main()
    {
        string[] lines = {};
        string path = "./input.txt";

        try
        {
             string fileText = File.ReadAllText(path);
             lines = fileText.Split('\n');
        }
        catch (FileNotFoundException)
        {
            Console.WriteLine("Couldn't find file");
        }
        
        long[] ArrA= lines[0].Split(": ")[1].Split(" ").Select(s =>
                {
                    if (long.TryParse(s, out long result)) return result;
                    return 0;
                }).ToArray();
        long[] ArrB = Enumerable.Repeat<long>(-1, ArrA.Length).ToArray();

        for (int i = 3; i < lines.Length; i++)
        {
            string line = lines[i];
            if (line == "")
            {
                for (int j = 0; j < ArrB.Length; j++)
                {
                    if (ArrB[j] != -1) ArrA[j] = ArrB[j];
                    ArrB[j] = -1;
                }
                i++;
            }
            else
            {
                long[] mappings = line.Split(" ").Select(s =>
                        {
                            if (long.TryParse(s, out long result)) return result;
                            return 0;
                        }).ToArray();
                for (int j = 0; j < ArrA.Length; j++)
                {
                    long diff = ArrA[j] - mappings[1];
                    if (diff >= 0 && diff < mappings[2])
                    {
                        ArrB[j] = mappings[0] + diff;
                    }
                }
            }
        }

        Console.Write("Resulted Value: ");
        Console.WriteLine(ArrA.Min());
    }
}
