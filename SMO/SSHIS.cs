using System;
using System.Data;
using System.Data.SqlClient;
using Microsoft.SqlServer.Management.Smo;
using Microsoft.SqlServer.Management.Common;
using System.IO;
using System.Xml;
using System.Globalization;

namespace SSHIS
{
    class Program
    {
     static void Main()
     {
      string connectionString;
      Array Servers;

      Console.WriteLine("Process to gather server information has started.");

      connectionString = GetConnectionString();

      Servers = getServerListfromConfigurationFile("C:\\work\\SMO\\config\\ServerList.xml");
      foreach(String ServerName in Servers)
      {
	UpdateSSHISDatawarehouse(connectionString, ServerName);
      }

      Console.WriteLine("Process to gather server information has finished.");
     }

    private static Array getServerListfromConfigurationFile(String ConfigurationFilename)
     {
      // Load XML Document
      XmlDocument doc = new XmlDocument();
      doc.Load(ConfigurationFilename);
      XmlNodeList Nodes = doc.GetElementsByTagName("Server"); 

      Array Servers=Array.CreateInstance(typeof(String),Nodes.Count);
      string Server;
      int i = 0;

      foreach (XmlNode node in Nodes)
      {       
       if (node.Attributes != null)
       {
        Server = node.Attributes["name"].InnerText;
        Servers.SetValue(Server, i);
        i++;
       }
      }
       return Servers;
     }

    private static Server CreateServerConnection(String ServerName)
     {
      ServerConnection Connection = new ServerConnection();
      Connection.ServerInstance = ServerName;
      Connection.DatabaseName = "master";
      Connection.ApplicationName = "SMO.exe";
      Connection.LoginSecure = true;
      Connection.LockTimeout = 30;
      Connection.ConnectTimeout = 30;
      Server Server = new Server(Connection);	 
      // Disable Auto Disconnect Mode
      // This is being done to control connections

      Server.ConnectionContext.AutoDisconnectMode = AutoDisconnectMode.NoAutoDisconnect;
      return Server;
     }

    private static string GetConnectionString()
    {
        return "Data Source=SLISQLUT01;Initial Catalog=TFS_DB_Monitoring;Trusted_Connection=true;" + 
	       "Application Name=TestProcedureCall;";
    } 

    private static void DisplayProcedureOutput(SqlCommand command)
    {
      Console.WriteLine("Result:" + command.Parameters["@result"].Value.ToString());
    }

    private static void DisplaySqlErrors(SqlException exception)
    {
      for (int i = 0; i < exception.Errors.Count; i++)
	{
          Console.WriteLine("Error at index number " + i + ".\n" +
          "Number: " + exception.Errors[i].Number + "\n" +
          "Message: " + exception.Errors[i].Message + "\n" +
          "Source: "  + exception.Errors[i].Source + "\n" +
          "Server: " + exception.Errors[i].Server + "\n" +
          "Procedure: " + exception.Errors[i].Procedure + "\n" +
	  "LineNumber: " + exception.Errors[i].LineNumber + "\n");
	}
    }

    private static void UpdateSSHISDatawarehouse(string connectionString, string ServerName)
    {
	//Creates a CompareInfo that uses the InvariantCulture.
 	CompareInfo CompInfo = CultureInfo.InvariantCulture.CompareInfo;

	// This try catch was added as a quick fix.  There is an issue with some servers where the process is being blocked.
	try
	{
      Console.WriteLine("Connecting to Server ({0}).", ServerName);
      Server Server = CreateServerConnection(ServerName);
 
      Console.WriteLine("Gathering information for Server ({0}).", Server.Name);
      UpdateServerInformation(Server,connectionString);
      foreach(Login login in Server.Logins)
      {
        Console.WriteLine("Gathering information for Login ({0}).", login.Name);
        UpdateLoginInformation(Server.Name,login,connectionString, Server.Information.VersionString);		
      }

      foreach(Database db in Server.Databases)
      {
        Console.WriteLine("Gathering information for Database ({0}).", db.Name);
	// Added to handle when the database is offline or part of a mirror
	if (CompInfo.Compare(db.Status.ToString(), "Normal", CompareOptions.IgnoreCase) == 0)
	{
	  UpdateDatabaseInformation(Server.Name, db, connectionString);
	  UpdateDatabaseHistoricalInformation(Server.Name, db, connectionString);
	  foreach(FileGroup fg in db.FileGroups)
          {
 	    UpdateFileGroupInformation(Server.Name, db.Name, fg, connectionString);
	    foreach(DataFile df in fg.Files)
            {
  	      UpdateDataFileInformation(Server.Name, db.Name, fg.Name, df, connectionString);	
  	      UpdateDataFileHistoricalInformation(Server.Name, db.Name, fg.Name, df, connectionString);
            }
          }
         foreach(LogFile lf in db.LogFiles)
         {
           UpdateLogFileInformation(Server.Name, db.Name, lf, connectionString);	
           UpdateLogFileHistoricalInformation(Server.Name, db.Name, lf, connectionString);
         }
        }
        else
        {
          Console.WriteLine("Database ({0}) is in a ({1}) Status and will not be added.", db.Name, db.Status);
        }
      }
      //Disconnect the current connection
      Server.ConnectionContext.Disconnect();
	}
	catch(System.Exception e)
	{
	  Console.WriteLine(e.Message);
	};

    }
    
    private static void UpdateServerInformation(Server Server, string connectionString)
    {
	String ServerName, NetName, InstanceName, Product, Edition, Version, Platform,OSVersion;
	int Processors, PhysicalMemory;
        String RootDirectory, MasterDBPath, MasterDBLogPath, ErrorLogPath;

	ServerName = Server.Name;
	NetName = Server.Information.NetName;
        InstanceName = Server.InstanceName;
        Product = Server.Information.Product;
	Version = Server.Information.VersionString;
        Edition = Server.Information.Edition;
        Platform = Server.Information.Platform;	
        OSVersion = Server.Information.OSVersion;
        Processors = Server.Information.Processors;
        PhysicalMemory = Server.Information.PhysicalMemory;
        RootDirectory = Server.Information.RootDirectory;
        MasterDBPath = Server.Information.MasterDBPath;
        MasterDBLogPath = Server.Information.MasterDBLogPath;
        ErrorLogPath = Server.Information.ErrorLogPath;      

	using (SqlConnection connection = new SqlConnection(connectionString))
	{
          SqlCommand command = new SqlCommand("[SSHIS].[UpdateServerInformation]", connection);
	  try
	    {
	      command.CommandType = CommandType.StoredProcedure;

	      SqlParameter Param;
	      Param = command.Parameters.Add("@ServerName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = ServerName;
	      Param = command.Parameters.Add("@NetName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = NetName;
	      Param = command.Parameters.Add("@InstanceName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = InstanceName;
	      Param = command.Parameters.Add("@Product", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Product;
	      Param = command.Parameters.Add("@Version", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Version;
	      Param = command.Parameters.Add("@Edition", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Edition;
	      Param = command.Parameters.Add("@Platform", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Platform;
	      Param = command.Parameters.Add("@OSVersion", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = OSVersion;
	      Param = command.Parameters.Add("@Processors", SqlDbType.Int);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Processors;
	      Param = command.Parameters.Add("@PhysicalMemory", SqlDbType.BigInt);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = PhysicalMemory;
	      Param = command.Parameters.Add("@RootDirectory", SqlDbType.NVarChar,260);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = RootDirectory;
	      Param = command.Parameters.Add("@MasterDBPath", SqlDbType.NVarChar,260);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = MasterDBPath;
	      Param = command.Parameters.Add("@MasterDBLogPath", SqlDbType.NVarChar,260);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = MasterDBLogPath;
	      Param = command.Parameters.Add("@ErrorLogPath", SqlDbType.NVarChar,260);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = ErrorLogPath;

	      
	      command.Connection.Open();
	      command.ExecuteNonQuery();
	    }
	    catch (SqlException ex)
	    {
	      DisplaySqlErrors(ex);
	    }
       	  command.Connection.Close();
	}
    }

    private static void UpdateDatabaseInformation(string ServerName, Database db, string connectionString)
    {
	String DatabaseName, CompatibilityLevel, PrimaryFilePath, RecoveryModel;
	DateTime CreateDate = new DateTime();
	DateTime LastBackupDate =  new DateTime();
	DateTime LastLogBackupDate = new DateTime();

	DatabaseName = db.Name;
	CompatibilityLevel = db.CompatibilityLevel.ToString();
 	PrimaryFilePath = db.PrimaryFilePath;
	CreateDate = db.CreateDate;
	LastBackupDate = db.LastBackupDate;
        LastLogBackupDate = db.LastLogBackupDate;

	RecoveryModel = db.DatabaseOptions.RecoveryModel.ToString().ToUpper();

	using (SqlConnection connection = new SqlConnection(connectionString))
	{
          SqlCommand command = new SqlCommand("[SSHIS].[UpdateDatabaseInformation]", connection);
	  try
	    {
	      command.CommandType = CommandType.StoredProcedure;

	      SqlParameter Param;
	      Param = command.Parameters.Add("@ServerName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = ServerName;
	      Param = command.Parameters.Add("@DatabaseName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = DatabaseName;
	      Param = command.Parameters.Add("@CompatibilityLevel", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = CompatibilityLevel;
	      Param = command.Parameters.Add("@PrimaryFilePath", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = PrimaryFilePath;
	      
              Param = command.Parameters.Add("@CreateDate", SqlDbType.DateTime);
              Param.Direction=ParameterDirection.Input;
	      Param.Value = CreateDate;
	      if (CreateDate == DateTime.MinValue)
	      {
 	        Param.Value = System.DBNull.Value;
              }
	      else
              {
 	        Param.Value = CreateDate;
              }

              Param = command.Parameters.Add("@LastBackupDate", SqlDbType.DateTime);
              Param.Direction=ParameterDirection.Input;
	      if (LastBackupDate == DateTime.MinValue)
	      {
 	        Param.Value = System.DBNull.Value;
              }
	      else
              {
 	        Param.Value = LastBackupDate;
              }

              Param = command.Parameters.Add("@LastLogBackupDate", SqlDbType.DateTime);
	      Param.Direction=ParameterDirection.Input;

	      if (LastLogBackupDate == DateTime.MinValue)
	      {
 	        Param.Value = System.DBNull.Value;
              }
	      else
              {
 	        Param.Value = LastLogBackupDate;
              }

	      Param = command.Parameters.Add("@RecoveryModel", SqlDbType.NVarChar,30);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = RecoveryModel;
	      
	      command.Connection.Open();
	      command.ExecuteNonQuery();
	    }
	    catch (SqlException ex)
	    {
	      DisplaySqlErrors(ex);
	    }
       	  command.Connection.Close();
	}
    }

    private static void UpdateDatabaseHistoricalInformation(string ServerName, Database db, string connectionString)
    {
	String DatabaseName, Status;
	double DataSpaceUsage_KB, IndexSpaceUsage_KB, SpaceAvailable_KB, DatabaseSize_MB;

	DatabaseName = db.Name;
	Status = Convert.ToString(db.Status);
	DataSpaceUsage_KB = db.DataSpaceUsage;
	IndexSpaceUsage_KB = db.IndexSpaceUsage;
	SpaceAvailable_KB = db.SpaceAvailable;
	DatabaseSize_MB = db.Size;



	using (SqlConnection connection = new SqlConnection(connectionString))
	{
          SqlCommand command = new SqlCommand("[SSHIS].[UpdateDatabaseHistoricalInformation]", connection);
	  try
	    {
	      command.CommandType = CommandType.StoredProcedure;

	      SqlParameter Param;
	      Param = command.Parameters.Add("@ServerName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = ServerName;
	      Param = command.Parameters.Add("@DatabaseName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = DatabaseName;
	      Param = command.Parameters.Add("@Status", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Status;
	      Param = command.Parameters.Add("@DataSpaceUsage_KB", SqlDbType.BigInt);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = DataSpaceUsage_KB;
	      Param = command.Parameters.Add("@IndexSpaceUsage_KB", SqlDbType.BigInt);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = IndexSpaceUsage_KB;
	      Param = command.Parameters.Add("@SpaceAvailable_KB", SqlDbType.BigInt);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = SpaceAvailable_KB;
	      Param = command.Parameters.Add("@DatabaseSize_MB", SqlDbType.BigInt);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = DatabaseSize_MB;	      
	      
	      command.Connection.Open();
	      command.ExecuteNonQuery();
	    }
	    catch (SqlException ex)
	    {
	      DisplaySqlErrors(ex);
	    }
       	  command.Connection.Close();
	}
    }

    private static void UpdateFileGroupInformation(string ServerName, string DatabaseName, FileGroup fg, string connectionString)
    {
	string FileGroupName;
	bool IsDefault, IsReadOnly;		

	FileGroupName = fg.Name;
        IsDefault = fg.IsDefault;
        IsReadOnly = fg.ReadOnly;

	using (SqlConnection connection = new SqlConnection(connectionString))
	{
          SqlCommand command = new SqlCommand("[SSHIS].[UpdateFileGroupInformation]", connection);
	  try
	    {
	      command.CommandType = CommandType.StoredProcedure;

	      SqlParameter Param;
	      Param = command.Parameters.Add("@ServerName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = ServerName;
	      Param = command.Parameters.Add("@DatabaseName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = DatabaseName;
	      Param = command.Parameters.Add("@FileGroupName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = FileGroupName;
	      Param = command.Parameters.Add("@IsDefault", SqlDbType.Bit);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = IsDefault;
	      Param = command.Parameters.Add("@IsReadOnly", SqlDbType.Bit);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = IsReadOnly;
	      
	      command.Connection.Open();
	      command.ExecuteNonQuery();
	    }
	    catch (SqlException ex)
	    {
	      DisplaySqlErrors(ex);
	    }
       	  command.Connection.Close();
	}
    }

    private static void UpdateDataFileInformation(string ServerName, string DatabaseName, string FileGroupName, DataFile df, string connectionString)
    {
	string FileName, FileFullName, GrowthType;
	double Growth_KB, Growth_Percent;		

	FileName = df.Name;
	FileFullName = df.FileName;
        GrowthType = Convert.ToString(df.GrowthType);
	if(GrowthType == "Percent")
	{
	 Growth_KB = 0;
         Growth_Percent = df.Growth;
        }
        else
	{
         Growth_KB = df.Growth;
         Growth_Percent = 0;
        }


	using (SqlConnection connection = new SqlConnection(connectionString))
	{
          SqlCommand command = new SqlCommand("[SSHIS].[UpdateDataFileInformation]", connection);
	  try
	    {
	      command.CommandType = CommandType.StoredProcedure;

	      SqlParameter Param;
	      Param = command.Parameters.Add("@ServerName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = ServerName;
	      Param = command.Parameters.Add("@DatabaseName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = DatabaseName;
	      Param = command.Parameters.Add("@FileGroupName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = FileGroupName;
	      Param = command.Parameters.Add("@FileName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = FileName;
	      Param = command.Parameters.Add("@FileFullName", SqlDbType.NVarChar,260);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = FileFullName;
	      Param = command.Parameters.Add("@GrowthType", SqlDbType.NVarChar,260);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = GrowthType;
	      Param = command.Parameters.Add("@Growth_KB", SqlDbType.BigInt);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Growth_KB;
	      Param = command.Parameters.Add("@Growth_Percent", SqlDbType.Int);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Growth_Percent;

	      
	      command.Connection.Open();
	      command.ExecuteNonQuery();
	    }
	    catch (SqlException ex)
	    {
	      DisplaySqlErrors(ex);
	    }
       	  command.Connection.Close();
	}
    }

    private static void UpdateDataFileHistoricalInformation(string ServerName, string DatabaseName, string FileGroupName, DataFile df, string connectionString)
    {
	string FileName;
	double AvailableSpace_KB, Size_KB, MaxSize_MB, UsedSpace_KB;		

	FileName = df.Name;
	AvailableSpace_KB = df.AvailableSpace;
	Size_KB = df.Size;
	MaxSize_MB = df.MaxSize;
	UsedSpace_KB = df.UsedSpace;		

	using (SqlConnection connection = new SqlConnection(connectionString))
	{
          SqlCommand command = new SqlCommand("[SSHIS].[UpdateDataFileHistoricalInformation]", connection);
	  try
	    {
	      command.CommandType = CommandType.StoredProcedure;

	      SqlParameter Param;
	      Param = command.Parameters.Add("@ServerName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = ServerName;
	      Param = command.Parameters.Add("@DatabaseName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = DatabaseName;
	      Param = command.Parameters.Add("@FileGroupName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = FileGroupName;
	      Param = command.Parameters.Add("@FileName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = FileName;
	      Param = command.Parameters.Add("@AvailableSpace_KB", SqlDbType.BigInt);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = AvailableSpace_KB;
	      Param = command.Parameters.Add("@Size_KB", SqlDbType.BigInt);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Size_KB;
	      Param = command.Parameters.Add("@MaxSize_MB", SqlDbType.BigInt);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = MaxSize_MB;
	      Param = command.Parameters.Add("@UsedSpace_KB", SqlDbType.Int);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = UsedSpace_KB;

	      
	      command.Connection.Open();
	      command.ExecuteNonQuery();
	    }
	    catch (SqlException ex)
	    {
	      DisplaySqlErrors(ex);
	    }
       	  command.Connection.Close();
	}
    }

    private static void UpdateLogFileInformation(string ServerName, string DatabaseName, LogFile lf, string connectionString)
    {
	string FileName, FileFullName, GrowthType;
	double Growth_KB, Growth_Percent;		

	FileName = lf.Name;
	FileFullName = lf.FileName;
        GrowthType = Convert.ToString(lf.GrowthType);
	if(GrowthType == "Percent")
	{
	 Growth_KB = 0;
         Growth_Percent = lf.Growth;
        }
        else
	{
         Growth_KB = lf.Growth;
         Growth_Percent = 0;
        }


	using (SqlConnection connection = new SqlConnection(connectionString))
	{
          SqlCommand command = new SqlCommand("[SSHIS].[UpdateLogFileInformation]", connection);
	  try
	    {
	      command.CommandType = CommandType.StoredProcedure;

	      SqlParameter Param;
	      Param = command.Parameters.Add("@ServerName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = ServerName;
	      Param = command.Parameters.Add("@DatabaseName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = DatabaseName;
	      Param = command.Parameters.Add("@FileName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = FileName;
	      Param = command.Parameters.Add("@FileFullName", SqlDbType.NVarChar,260);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = FileFullName;
	      Param = command.Parameters.Add("@GrowthType", SqlDbType.NVarChar,260);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = GrowthType;
	      Param = command.Parameters.Add("@Growth_KB", SqlDbType.BigInt);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Growth_KB;
	      Param = command.Parameters.Add("@Growth_Percent", SqlDbType.Int);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Growth_Percent;

	      
	      command.Connection.Open();
	      command.ExecuteNonQuery();
	    }
	    catch (SqlException ex)
	    {
	      DisplaySqlErrors(ex);
	    }
       	  command.Connection.Close();
	}
    }

    private static void UpdateLogFileHistoricalInformation(string ServerName, string DatabaseName, LogFile lf, string connectionString)
    {
	string FileName;
	double Size_KB, MaxSize_MB, UsedSpace_KB;		

	FileName = lf.Name;
	Size_KB = lf.Size;
	MaxSize_MB = lf.MaxSize;
	UsedSpace_KB = lf.UsedSpace;		

	using (SqlConnection connection = new SqlConnection(connectionString))
	{
          SqlCommand command = new SqlCommand("[SSHIS].[UpdateLogFileHistoricalInformation]", connection);
	  try
	    {
	      command.CommandType = CommandType.StoredProcedure;

	      SqlParameter Param;
	      Param = command.Parameters.Add("@ServerName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = ServerName;
	      Param = command.Parameters.Add("@DatabaseName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = DatabaseName;
	      Param = command.Parameters.Add("@FileName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = FileName;
	      Param = command.Parameters.Add("@Size_KB", SqlDbType.BigInt);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Size_KB;
	      Param = command.Parameters.Add("@MaxSize_MB", SqlDbType.BigInt);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = MaxSize_MB;
	      Param = command.Parameters.Add("@UsedSpace_KB", SqlDbType.Int);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = UsedSpace_KB;

	      
	      command.Connection.Open();
	      command.ExecuteNonQuery();
	    }
	    catch (SqlException ex)
	    {
	      DisplaySqlErrors(ex);
	    }
       	  command.Connection.Close();
	}
    }

    private static void UpdateLoginInformation(string ServerName, Login login, string connectionString, string serverVersionString)
    {

	String LoginName, DefaultDatabase, Language, LanguageAlias, LoginType;
	DateTime CreateDate = new DateTime();
	DateTime DateLastModified = new DateTime();
	bool DenyWindowsLogin,HasAccess,IsDisabled,IsSystemObject;

	LoginName = login.Name;
	CreateDate = login.CreateDate;
	DateLastModified = login.DateLastModified;	    	
	DefaultDatabase = login.DefaultDatabase;	    	
	DenyWindowsLogin = login.DenyWindowsLogin;	    	
	HasAccess = login.HasAccess;	    	

	try
	  {
 	   IsDisabled = login.IsDisabled;	    	
	  }
	catch
	  {
	   IsDisabled = false;	    	
	  }

	IsSystemObject = login.IsSystemObject;	    	
	Language = login.Language;	    	

	if (Language.Length > 0){
          LanguageAlias = login.LanguageAlias;	    	
	}
	else{
	  Language = "Unknown";	    	
	  LanguageAlias = "Unknown";	    	
	}

	LoginType = login.LoginType.ToString();	    	


	using (SqlConnection connection = new SqlConnection(connectionString))
	{
          SqlCommand command = new SqlCommand("[SSHIS].[UpdateLoginInformation]", connection);
	  try
	    {
	      command.CommandType = CommandType.StoredProcedure;

	      SqlParameter Param;
	      Param = command.Parameters.Add("@ServerName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = ServerName;
	      Param = command.Parameters.Add("@LoginName", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = LoginName;
	      Param = command.Parameters.Add("@CreateDate", SqlDbType.DateTime);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = CreateDate;
	      Param = command.Parameters.Add("@DateLastModified", SqlDbType.DateTime);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = DateLastModified;
	      Param = command.Parameters.Add("@DefaultDatabase", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = DefaultDatabase;
	      Param = command.Parameters.Add("@DenyWindowsLogin", SqlDbType.Bit);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = DenyWindowsLogin;
	      Param = command.Parameters.Add("@HasAccess", SqlDbType.Bit);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = HasAccess;
	      Param = command.Parameters.Add("@IsDisabled", SqlDbType.Bit);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = IsDisabled;
	      Param = command.Parameters.Add("@IsSystemObject", SqlDbType.Bit);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = IsSystemObject;
	      Param = command.Parameters.Add("@Language", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = Language;
	      Param = command.Parameters.Add("@LanguageAlias", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = LanguageAlias;
	      Param = command.Parameters.Add("@LoginType", SqlDbType.NVarChar,128);
	      Param.Direction=ParameterDirection.Input;
	      Param.Value = LoginType;

	      // These values are set only when the login type is SQLLogin		
	      // This is a quick fix...this will need to be reviewed at a later time to clean it up.
	      // The following does a compare thats case insensitive
		      // Add test for SQL Server 2000 Version
	      if ((String.Compare(LoginType, "SqlLogin", true) == 0) && (serverVersionString.Substring(0,1) != "8"))
	      {
		      Param = command.Parameters.Add("@PasswordPolicyEnforced", SqlDbType.Bit);
		      Param.Direction=ParameterDirection.Input;
		      Param.Value = login.PasswordPolicyEnforced;
		      Param = command.Parameters.Add("@IsLocked", SqlDbType.Bit);
		      Param.Direction=ParameterDirection.Input;
		      Param.Value = login.IsLocked;
		      Param = command.Parameters.Add("@IsPasswordExpired", SqlDbType.Bit);
		      Param.Direction=ParameterDirection.Input;
		      Param.Value = login.IsPasswordExpired;
		      Param = command.Parameters.Add("@MustChangePassword", SqlDbType.Bit);
		      Param.Direction=ParameterDirection.Input;
		      Param.Value = login.MustChangePassword;
		      Param = command.Parameters.Add("@PasswordExpirationEnabled", SqlDbType.Bit);
		      Param.Direction=ParameterDirection.Input;
		      Param.Value = login.PasswordExpirationEnabled;
	      }
	      else
	      {
		      Param = command.Parameters.Add("@PasswordPolicyEnforced", SqlDbType.Bit);
		      Param.Direction=ParameterDirection.Input;
		      Param.Value = false;
		      Param = command.Parameters.Add("@IsLocked", SqlDbType.Bit);
		      Param.Direction=ParameterDirection.Input;
		      Param.Value = false;
		      Param = command.Parameters.Add("@IsPasswordExpired", SqlDbType.Bit);
		      Param.Direction=ParameterDirection.Input;
		      Param.Value = false;
		      Param = command.Parameters.Add("@MustChangePassword", SqlDbType.Bit);
		      Param.Direction=ParameterDirection.Input;
		      Param.Value = false;
		      Param = command.Parameters.Add("@PasswordExpirationEnabled", SqlDbType.Bit);
		      Param.Direction=ParameterDirection.Input;
		      Param.Value = false;
	      }

	      command.Connection.Open();
	      command.ExecuteNonQuery();
	    }
	    catch (SqlException ex)
	    {
	      DisplaySqlErrors(ex);
	    }
       	  command.Connection.Close();
	}
    }
   }
}