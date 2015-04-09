class Query
  @query = "";
  
  def initialize
    @query = "";
  end
  
  def execute(connection)
    return connection.query @query;
  end



  def insert(tableName, values)

    colArray = [];
    valueArray = [];
    values.each do |key,value|
      if(value!="")
        colArray << key;
        valueArray << "'#{value}'";
      end
    end

    @query = "insert into #{tableName} " + " (" + listIn(colArray) +") ";
    @query = @query + "values ";
    @query = @query + " ( "+ listIn(valueArray) +" ) ";

    return @query;
  end

  def update(tableName, values)

    valueList = [];
    values.each do |key,value|
      valueList << "#{key} = '#{value}'";
    end

    @query = "update #{tableName} set "
    @query = @query + listIn(valueList);
    @query = @query + " where user_id = '#{$user_id}'"
    return @query
  end

  def appendCondition(condition)
    @query = @query + " where #{condition} ";
  end

  def select(tables, columns)
    @query = "select " + listIn(columns) + " from " + listIn(tables);
  end

  def advanceSelect(tableName,column_value_hash)
    condition = generateCondition(column_value_hash);
    @query = select([tableName],["*"]);
    appendCondition(condition);
    return @query;
  end

  def generateCondition(column_value_hash)

    condition = "";
    firstItem = true;
    column_value_hash.each do |colName,value|
      condition = condition + " #{colName} = '#{value}' " if firstItem;
      condition = condition + " and #{colName} = '#{value}' " if !firstItem;
      firstItem = false;
    end

    return condition;
  end



  def getQuery
    return @query;
  end

  def listIn(array)
    list = "";
    isBeginning = true;
    array.each do |item|
      
      if !isBeginning
        list = list+ ",";
      else
        isBeginning = false;
      end
      
      list = list + item.to_s+ " ";
    end
    return list;
  end

  def isADate?(text)
    isADate = false;
    dateExpression = /\A[\d]+[-]\d+[-]\d+\z/;
    return (text =~ dateExpression);
  end
  
  def to_s
    return @query;
  end


  

  

  
end