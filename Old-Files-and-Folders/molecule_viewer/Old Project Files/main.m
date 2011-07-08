clc
clear

exitLoop = false;
while exitLoop == false
    user_choice = menu();
    if(user_choice == 1)
        readInFiles();
        exitLoop = false;
    elseif(user_choice == 2)
        load('molecules');
        exitLoop = false;
    elseif(user_choice == 3)
        plotGraph();
        exitLoop = false;
    elseif(user_choice == 4)
        exitLoop = true;
    else
        disp('This shouldn''t happen, crashing!');
    end
end


