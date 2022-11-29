using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Reflection.PortableExecutable;
using System.Text;
using System.Threading.Tasks;

namespace DBAnalysisApp
{
  public static class QuerryRunner
  {
    private static void ClearBuffers(string connectionString)
    {
        using (OracleConnection connection = new OracleConnection(connectionString))
        {
            connection.Open();
            var command = new OracleCommand("alter system flush buffer_cache", connection);
            command.ExecuteReader();
            connection.Close();
            connection.Dispose();
        }
    }

    private static double RunQuery(string query, string connectionString)
    {
      DateTime start;
      DateTime end;
      double sum = 0;

        using (OracleConnection connection = new OracleConnection(connectionString))
        {
            connection.Open();
            foreach (var subQuery in query.Split(';').Where(x => !String.IsNullOrEmpty(x)))
            {
                start = DateTime.Now;
                var command = new OracleCommand(subQuery, connection);
                var reader = command.ExecuteReader();

                end = DateTime.Now;
                sum += (end - start).TotalMilliseconds;
            }
            connection.Close();
            connection.Dispose();
            return sum;
        }

    }

    private static void GetPlans(string query, string fileName, string connectionString)
    {

        using StreamWriter file = new($"..\\..\\..\\Plans\\plan_{fileName}.txt");
        using (OracleConnection connection = new OracleConnection(connectionString))
        {
            connection.Open();
            foreach (var subQuery in query.Split(';').Where(x => !String.IsNullOrEmpty(x)))
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
            connection.Close();
            connection.Dispose();
        }
    }

    private static void BackupDatabase(string connectionString)
    {
        using (OracleConnection connection = new OracleConnection(connectionString))
        {
            connection.Open();
            connection.Close();
            connection.Dispose();
        }
    }

    public static double RunAllForQuerry(string fileName, string connectionString, bool lastOperationNotChangedDb)
    {
      string query = String.Join("\n",System.IO.File.ReadAllLines(fileName));
      if(!lastOperationNotChangedDb)
        BackupDatabase(connectionString);


        GetPlans(query, fileName.Split('\\').Last().Split('.').First(), connectionString);
        ClearBuffers(connectionString);

        var time = RunQuery(query, connectionString);
        ClearBuffers(connectionString);
        return time;
    }
  }
}
