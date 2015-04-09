class SQLTable
  @name = "";
  @column_array = Hash.new{""};
  @table_description = "";


  def initialize(name,description = "")
    @name = name
    @column_array = Hash.new{""};
    @description = description;
  end

  def addColumn(name, description)
    @column_array[name] = description ;
  end

  def getColumns
    return @column_array;
  end

  def getColumnDescription(column)
    return @column_array[column];
  end
  def getColumnArray
    colArray = [];
    @column_array.each_key do |key|
      colArray << key;
    end
    return colArray;
  end

end


class Database
  @table_list= Hash.new{};

  def initialize
    user_information = SQLTable.new("User_Information","Profile");
    user_information.addColumn("user_id", "ID");
    user_information.addColumn("user_name", "Name");
    user_information.addColumn("dob", "Date of Birth");
    user_information.addColumn("gender", "Gender");
    user_information.addColumn("location", "Location");
    user_information.addColumn("email", "Email");
    
    @table_list= Hash.new{0};
    @table_list["User_Information"]= user_information;
  end
  def getTableList
    return @table_list;
  end
end