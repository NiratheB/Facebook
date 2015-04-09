require_relative 'Connection'
require_relative 'Query'
require_relative 'SQLTable'
require_relative 'User'
require 'mysql'

def initGlobalVar
  $user_information_columns = 
    {"user_id"=>"ID",
    "user_name"=>"Name", 
    "dob"=>"Date of Birth", 
    "gender"=>"Gender", 
    "email"=>"Email", 
    "location"=>"Location"};
  $user_id="";
  $title_format = "## %30s ##\n";
  $connection = Connection.new;
  $password = "";
  $query = Query.new();  
  $myself = User.new;
  $table_list = Database.new.getTableList;
end
def initConnection
  serverInfo = 
  {"server" => "localhost",
    "username" => "root",
    "password" => "therap",
    "database" => "Social_Network"}
  $connection.setServerInfo(serverInfo)
end


def welcomeMessage
  begin
    puts "Welcome!"
    welcomeCommand = Hash.new { |h, k| h[k] = Hash.new }
    welcomeCommand["1"]["Login"]= lambda{login("","")}
    welcomeCommand["2"]["Sign Up"]= lambda{signUp}
    showCommand(welcomeCommand)
    command = gets.chomp!
  rescue Exception=>e
    throw(:exit,"Bye! #{e}")
  end
  return parseCommand(welcomeCommand[command])

end

def login(user_id, password)
  if(user_id=="")
    user_id= prompt("ID")
  end
  if(password=="")
    password = prompt("Password");
  end
  $user_id = user_id;
  $password= password;
  return isLoginSuccessful?
end
def prompt(entity)
  puts "Enter #{entity}:";
  entity = gets.chomp!;
  entity = correctedField(entity)
  return entity;
end
def isLoginSuccessful?
  isSuccessful = false;
  if(verified?("User_Information", {"user_id"=> $user_id, "password"=>$password}))
    isSuccessful = true;
  end

  return isSuccessful;
end
def verified?(table_name, column_value_hash)
  #generate query
  query = $query.advanceSelect(table_name, column_value_hash);

  #execute query
  result = $connection.executeQuery(query);

  isSuccessful = false;

  if (result.num_rows == 1)
    isSuccessful = true;
  else
    isSuccessful = false;
  end

  return isSuccessful;

end

def signUp

  begin
    puts "Sign up in Social Network:"

    table_values = Hash.new{""}

    table = $table_list["User_Information"];
    columns = table.getColumns;
    table_values["user_id"]= prompt("User ID:")
    while(table_values["user_id"]=="" || !isUniqueID?(table_values["user_id"]))
      puts "Error in ID! Enter a different user id!"
      table_values["user_id"] = prompt("User_ID");
    end

    table_values["password"]= prompt("Password");
    $user_id= table_values["user_id"]
    $password = table_values["password"]

    columns.each do |colName,colDescription|
      if(colName=="dob")
        puts "Date of Birth: "
        table_values["dob"] = getDate()
      elsif(colName=="gender")
        puts "Gender: (Enter m for Male and f for Female)"
        table_values["gender"] = gets.chomp!
        while(table_values["gender"]!="m" && table_values["gender"]!="f")
          puts "Please Enter gender in correct format!"
          puts "Gender: (Enter m for Male and f for Female)"
          table_values["gender"] = gets.chomp!
        end
      elsif(colName!="user_id")
        table_values[colName]=prompt(colDescription);
      end

    end

    $query.insert("User_Information",table_values)
    $connection.executeQuery($query.to_s)

    return login($user_id,$password);

  rescue Exception => errorMessage
    throw(:error,errorMessage)
    raise
  end

end
def isUniqueID?(user_id)
  $query.select(["User_Information"], ["user_id"])
  $query.appendCondition("user_id = '#{user_id}'")
  result = $connection.executeQuery($query.to_s)
  return (result.num_rows<=0)
end


def getInfoFromDatabase(table= "User_Information",columns =["*"], condition= "")
  $query.select([table],columns);
  $query.appendCondition(condition);
  return $connection.executeQuery($query.to_s);
end

def showUserInfo(user= $myself)
  #get profile information
  user.printInfo

  #friend List
  user.printFriendList
end
def showProfilePage(user = $myself)

  if(user==$myself)
    initUser
    user= $myself
  end
  puts "Profile"
  showUserInfo(user)

  profileCommand = Hash.new{|h,k| h[k]= Hash.new}
  profileCommand["1"]["Edit Profile"]= lambda{editProfile}
  profileCommand["2"]["Add Status"] = lambda{status = prompt("Status")
                                              addStatus(status)}
  profileCommand["3"]["Add Friend"]= lambda{friendName = prompt("Name")
                                            friendID = getIDFromName(friendName)
                                            addFriend(friendID)}
  profileCommand["4"]["View Friend Profile"]= lambda{friend_id= prompt("Friend ID")
                                                     viewFriendProfile(friend_id)
                                                      }
  profileCommand["5"]["View Status"] = lambda{viewStatus}
  profileCommand["6"]["View your profile"]= lambda{showUserInfo($myself)}
  profileCommand["X"]["Log out"] = lambda{logout}

  showCommand(profileCommand)
  command = gets.chomp!

  while (parseCommand(profileCommand[command]))
    showCommand(profileCommand)
    command = gets.chomp!
  end

  return true
end

def viewFriendProfile(friend_id)
  isSuccessful = true
  if($myself.isAFriend?(friend_id))
    user = initUser(friend_id)
    showUserInfo(user)
  else
    puts "You're not friend with #{friend_id}!"
  end
  return isSuccessful
end
def editProfile
  isSuccessful = true
  updatedColumns = Hash.new;
  field = prompt("Field")
  tableName = "User_Information"
  columns = $table_list[tableName].getColumns

  while(field!="")
    columnName = ""
    if(field.to_s.downcase == "password")
      columnName= "password"
    else
      columns.each do |col,description|
        if(description == field)
          columnName= col
        end
      end
    end
    if(columnName!="user_id" && columnName!="")
      updatedColumns[columnName]= prompt("Value");
    end
    field = prompt("Field")
  end
  begin
    $query.update(tableName, updatedColumns)
    $connection.executeQuery($query.to_s)
    $myself = initUserInfo($myself)
  rescue Exception
      isSuccessful= false
      throw(:error, "Error in query execution")
  ensure
    return isSuccessful
  end

end
def addStatus(status)
  isSuccessful = true
  begin
    $query.insert("Status", {"user_id"=>$user_id,"status"=>status})

    $connection.executeQuery($query.to_s)
  rescue Exception
    isSuccessful= false
    raise
  end

  return isSuccessful

end
def correctedField(value)
  return value.gsub(/\'/, '\'\'')
end
def viewStatus
  format = "%20s - %20s - %-50s\n"
  $query.select(["Friend_List"],["user_id"])
  $query.appendCondition("friend_id = '#{$user_id}'")

  user_idQuery = $query.to_s

  $query.select(["Friend_List"],["friend_id"])
  $query.appendCondition("user_id = '#{$user_id}'")
  friend_idQuery = $query.to_s

  $query.select(["Status","User_Information"],["User_Information.user_id as user_id ","user_name","status","time_of_post"])
  $query.appendCondition("(Status.user_id = '#{$user_id}' or Status.user_id in (#{user_idQuery}) or Status.user_id in (#{friend_idQuery})) and Status.user_id = User_Information.user_id group by time_of_post desc ");

  #puts $query.to_s
  result = $connection.executeQuery($query.to_s)
  result.each_hash do |row|
    user_id = row["user_id"]
    printf(format, row["time_of_post"], row["user_name"], row["status"])
  end
end

def getIDFromName(name)
  $query.select(["User_Information"], ["user_id","user_name"])
  $query.appendCondition("user_name like '%#{name}%'")
  result = $connection.executeQuery($query)
  id = ""
  if(result.num_rows>=1)
    result.each_hash do |row|
      puts "#{row["user_id"]} : #{row["user_name"]}"
    end
    id = prompt(" Friend ID")
  else
    puts "No such person in database!"
  end

  return id
end
def addFriend(friendID)
  isSuccessful = true
  if(friendID=="")
    isSuccessful= false
  else
    $query.select(["Friend_List"],["*"])
    $query.appendCondition("(user_id = '#{$user_id}' and friend_id = '#{friendID}') or (user_id = '#{friendID}' and friend_id = '#{$user_id}')")
    result = $connection.executeQuery($query.to_s)

    if(result.num_rows<=0)
      $query.insert("Friend_List",{"user_id"=> $user_id, "friend_id"=>friendID})
      $connection.executeQuery($query.to_s)
      $myself= initUserFriendList($myself)
    else
      isSuccessful= false
    end
  end
  if(!isSuccessful)
    puts "Try again! (Probably you're already friends!)"
    isSuccessful= true
  end
  return isSuccessful

end

def initUserInfo(user)
  user_id = user.getID
  user.setInfo(getInfoFromDatabase("User_Information", ["*"], "user_id = '#{user_id}'"))
  return user
end

def initUserFriendList(user)
  user_id = user.getID
  user.setFriendList(getInfoFromDatabase("Friend_List,User_Information", ["User_Information.user_name as Name", " User_Information.user_id as ID "], "User_Information.user_id <> '#{user_id}'
                                              and (Friend_List.user_id = '#{user_id}' or Friend_List.friend_id = '#{user_id}')
                                              and (Friend_List.user_id = User_Information.user_id
                                              or Friend_List.friend_id = User_Information.user_id) group by friend_since asc"))
  return user
end

def initUser(user_id = $user_id)
  user = User.new(user_id)
  initUserInfo(user)
  initUserFriendList(user)

  if(user_id== $user_id)
    $myself = user
  else
    $friend = user
  end

  return user

end

def getUserInformation(user_id = $user_id)
  tableName = "User_Information";
  table_list = Database.new.getTableList;
  colArray = table_list[tableName].getColumnArray;
  $query.select([tableName],colArray);
  $query.appendCondition("user_id='#{user_id}';");
  result = $connection.executeQuery($query.to_s);
  
  return result;
end
def printUserInformation(user= $myself)
  
  printf($title_format, "INFORMATION");
  format = "%-20s%-2s%-30s\n";
  
  if(result.num_rows==1)
    result.each_hash do |row|
      row.each do |col,value|
        printf(format, $table_list["User_Information"].getColumnDescription(col),":", value);
      end
    end
  else
    throw(:error, "User Fake!")
  end
    
end
def printFriendList(user_id = $user_id)
  $query.select(["User_Information","Friend_List"],["User_Information.user_name as name"]);
  $query.appendCondition("User_Information.user_id <> '#{user_id}' and (Friend_List.user_id = '#{user_id}' or Friend_List.friend_id = '#{user_id}') and (Friend_List.user_id = User_Information.user_id or Friend_List.friend_id = User_Information.user_id)  group by friend_since asc");
  result = $connection.executeQuery($query.to_s);
  count=1;
  printf($title_format, "FRIEND LIST");
  format= "%-5s%-30s\n";
  result.each_hash do |row|
    printf(format,count.to_s, row["name"]);
    count = count+1;
  end
end

def logout
  $connection.close
  $user_id= ""
  $password= ""
  puts "Good bye!"
  puts "##############"
  puts
  puts
  throw(:exit)
  return false
end

def getDate()
  year = "", month = "", day ="";
  loop do
    puts "Year: "
    year = gets.chomp!;
    if (year =~ /\A\d\d\d\d\z/)
      break;
    end
  end

  puts "Month: (1 to 12)";
  month = gets.chomp!;
  while(!(month=~ /\A\d+\z/) || !(month.to_i > 0 && month.to_i <= 12))
    puts "Month: (1 to 12)";
    month = gets.chomp!;
  end
  loop do
    puts "Day: "
    day = gets.chomp!;
    if (day =~ /\A\d+\z/ && (day.to_i >0 && day.to_i<=31))
      break;
    end
  end
  return "#{year}-#{month}-#{day}";
end





def showCommand(commandList)
  puts "Enter "
  format = "%5s%-20s\n"
  commandList.each do |key,commandHash|
    commandHash.each do |command,func|
      printf(format, key.to_s+" ", command)
    end
  end
end


def parseCommand(functionHash)
  previousStepSuccessful = false;

  functionHash.each do |command, function|
    previousStepSuccessful = function.call;
  end
  return previousStepSuccessful;
end


def navigate(to)
  case to
    when "loginPage" then showLoginPage;
    when "profilePage" then showProfilePage;

  end
end

def showLoginPage
  # prompt user_id
  $user_id = prompt("ID");

  # prompt password
  $password = prompt("Password");

end
