using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Reflection.PortableExecutable;
using System.Text;
using System.Threading.Tasks;

namespace DBAnalysisApp
{
  public static class QuerryRunner
  {
    private static void ClearBuffers(OracleConnection connection)
    {
        var command = new OracleCommand("alter system flush buffer_cache", connection);
        command.ExecuteReader();
    }

    private static double RunQuery(string query, OracleConnection connection)
    {
      DateTime start;
      DateTime end;
      double sum = 0;
      foreach (var subQuery in query.Split(';').Where(x => !String.IsNullOrEmpty(x)))
      {
        start = DateTime.Now;
        var command = new OracleCommand(subQuery, connection);
        command.ExecuteReader();
        end = DateTime.Now;
        sum += (end - start).TotalMilliseconds;
      }
      return sum;
    }

    private static void GetPlans(string query, string fileName, OracleConnection connection)
    {

      using StreamWriter file = new($"..\\..\\..\\Results\\plan_{fileName}.txt");
      foreach (var subQuery in query.Split(';').Where(x=> !String.IsNullOrEmpty(x)))
      {
        var command = new OracleCommand($"EXPLAIN PLAN FOR {subQuery}", connection);
        command.ExecuteNonQuery();
        var command2 = new OracleCommand($"select plan_table_output from table(dbms_xplan.display('plan_table',null,'basic +predicate +cost'))", connection);
        var reader = command2.ExecuteReader();
        try
        {
          while (reader.Read())
          {
            file.WriteLine(reader.GetString(0));
          }
        }
        finally
        {
          reader.Close();
        }
      }
    }

    private static void BackupDatabase(string connectionString)
    {
      var backupPath = "";
      var destPath = "";
      ExecuteCommand("docker stop Oracle21c-xe");
      Thread.Sleep(10000);
      System.IO.File.Copy(backupPath, destPath);
      ExecuteCommand("docker start Oracle21c-xe");
      while (true)
      {
        try
        {
          var connection = new OracleConnection(connectionString);
          connection.Open();
          connection.Close();
          break;
        }
        catch (Exception e)
        {
          Thread.Sleep(5000);
        }
      }
    }

    public static double RunAllForQuerry(string fileName, string connectionString, bool lastOperationNotChangedDb)
    {
      string query = String.Join("\n",System.IO.File.ReadAllLines(fileName));
        //if (!lastOperationNotChangedDb)
        //    BackupDatabase(connectionString);

        using (OracleConnection connection = new OracleConnection(connectionString))
        {
            connection.Open();
            ClearBuffers(connection);
            GetPlans(query, fileName.Split('\\').Last().Split('.').First(), connection);
            ClearBuffers(connection);
            var time = RunQuery(query, connection);
            connection.Close();
            return time;
        }
    }
    public static void ExecuteCommand(string Command)
    {
        Process Process = new Process();
        ProcessStartInfo ProcessInfo = new ProcessStartInfo("cmd.exe", "/K " + Command);
        ProcessInfo.CreateNoWindow = false;
        ProcessInfo.UseShellExecute = true;
        Process.StartInfo = ProcessInfo;
        Process.Start();
    }

  }
}
