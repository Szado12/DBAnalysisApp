﻿using DBAnalysisApp;

string connString = "DATA SOURCE=localhost:1521/XEPDB1;PERSIST SECURITY INFO=True;USER ID=ZSBD_ADM; password=passwd; Pooling = False; Statement Cache Size=0";
Console.WriteLine("Number of tests:");
int numberOfTests = Convert.ToInt32(Console.ReadLine());
Dictionary<string, List<double>> times = new Dictionary<string, List<double>>();
string[] files = new[] { "select1", "select2", "select3"};
foreach (string file in files)
{
  times.Add(file,new List<double>());
}


for (int i=0; i< numberOfTests; i++)
{
  string previous = null;
  foreach (string file in files)
  {
    times[file].Add(QuerryRunner.RunAllForQuerry($"..\\..\\..\\Query\\{file}.sql", connString, previous?.Contains("select") ?? true));
    previous = file;
  }
 
}

using StreamWriter outputfile = new($"..\\..\\..\\Plans\\times.txt");
foreach (string file in files)
{
    var x = times[file];
  outputfile.WriteLine($"{file}:");
  outputfile.WriteLine($"Number of runs: {numberOfTests}");
  outputfile.WriteLine($"Min time: {times[file].Min()} ms");
  outputfile.WriteLine($"Max time: {times[file].Max()} ms");
  outputfile.WriteLine($"Avg time: {times[file].Average()} ms");
}