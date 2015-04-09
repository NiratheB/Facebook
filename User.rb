class User

  def init
    @information = Hash.new{""};
    @friendList = Hash.new{|count,friendIDName| count[friendIDName]= Hash.new};
  end

  def initialize(id="")
    @user_id = id
    init
  end

  def getID
    @user_id
  end
  
  def setInfo(info)

    if(info.num_rows == 1)
      info.each_hash do |row|
        
        row.each do |key,value|
          @information[key]= value;
        end
      
      end
    else
      throw(:error, "User Information not found!!")
    end
  end
  
  def getInfo
    return @information;
  end
  
  def printInfo
    printf($title_format, "INFORMATION");
    format = "%-20s%-2s%-30s\n";
    @information.each do |col,value|
        printf(format, $table_list["User_Information"].getColumnDescription(col),":", value) unless($table_list["User_Information"].getColumnDescription(col)=="");
      end
  end
  def isAFriend?(friend_id)
    isFriend = false;
    @friendList.each do |count, friendIDName|
      if(@friendList[count]["ID"]== friend_id)
        isFriend= true
      end
    end
    return isFriend
  end
  def getFriendList
    return @friendList;
  end
  
  def setFriendList(sqlResult)
    count = 0
    sqlResult.each_hash do |row|
      count+=1
      row.each do |key,value|
        @friendList[count][key]= value;
      end
    end
  end
  
  def printFriendList
    printf($title_format, "FRIENDS");
    format = "   %-20s%-2s%-30s\n";
    @friendList.each do |key,valueHash|
      puts key
      valueHash.each do |valueKey, value|
        printf(format, valueKey,":", value);
      end

      end
  end
  
  
end