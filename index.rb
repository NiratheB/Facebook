require_relative 'Library'


initGlobalVar
initConnection

error = ""
ErrorTolerance = 3
isSuccessful = true
errorCount = 0;

exitMessage = catch(:exit) do

  error = catch(:error) do
    isSuccessful = welcomeMessage
    while (!isSuccessful)
      puts "Error! Try again!"
      isSuccessful = welcomeMessage
    end
    ""
  end
  if(error!="")
    throw(:exit,"#{error}! Exiting...")
  end


  while(errorCount < ErrorTolerance)
    error = catch(:error) do
      showProfilePage
      ""
    end

    if error!=""
      puts error
      errorCount+=1
    end
  end
  ""
end

puts exitMessage if (exitMessage!="")









