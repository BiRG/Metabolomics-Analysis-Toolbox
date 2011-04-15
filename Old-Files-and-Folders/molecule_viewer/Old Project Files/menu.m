function [choice] = menu()

choiceOne = '1.) Read in peak files.';
choiceTwo = '2.) Load current peak file.';
choiceThree = '3.) Display current peak file (plot graph).';
choiceFour = '4.) Exit';
errorMessage = 'Error occured, try again!';

choice = 0;
exitLoop = false;

while(exitLoop == false)
    
        disp(choiceOne);
        disp(choiceTwo);
        disp(choiceThree);
        disp(choiceFour);
        user_choice = input('Choice: ', 's');
        
        if isempty(user_choice)
            disp(errorMessage);
        elseif str2double(user_choice) == 1
            choice = 1;
            exitLoop = true;
        elseif str2double(user_choice) == 2
            choice = 2;
            exitLoop = true;
        elseif str2double(user_choice) == 3
            choice = 3;
            exitLoop = true;
        elseif str2double(user_choice) == 4
            choice = 4;
            exitLoop = true;
        else
            disp(errorMessage);
        end
end

