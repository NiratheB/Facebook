class Connection
  ServerIndex = "server";
  UsernameIndex = "username";
  PasswordIndex = "password";
  DatabaseIndex = "database";
  def initialize

  end

  def setServerInfo(serverInfo)
 
    @server = serverInfo[ServerIndex];
    @username = serverInfo[UsernameIndex];
    @password = serverInfo[PasswordIndex];
    @database = serverInfo[DatabaseIndex];
    
  end
  
  def connect
    begin
      @con = Mysql.new @server, @username, @password, @database;
    rescue Exception => errorMessage
      throw(:error, "Error in connection: #{errorMessage}")
    end
  end
  
  def close
    begin
      @con.close if @con;
    rescue Exception => errorMessage
      throw(:error, "Error in connection: #{errorMessage}")
    end

  end

  def executeQuery(query)
    begin
      connect
      result = @con.query query.to_s
      close
      return result
    rescue Exception => errorMessage
      throw(:error, "Error in execution of query: #{errorMessage}")
    end
  end
  
  
end