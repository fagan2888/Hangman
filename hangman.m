% reading the data from file
dataset = fopen('dataset_5.txt','rt');
format = '%s %d';
A = textscan(dataset,format);
fclose(dataset);

%re-structuring the data
words = cell2mat(A{1});
frequency = (A{2});

% calculating probability of occurance for each word
P_word = length(words);

totalFreq = sum(frequency);
for i=1:length(words)
    P_word(i) = double(frequency(i)) / double(totalFreq);
end

%{
% printing some least frequent and most frequent word

[freqOrdered,index] = sort(frequency);
for i=1:14
    fprintf('%s %d %f\r\n', words(index(i),:), freqOrdered(i), P_w(index(i)));
end

for i=length(freqOrdered):-1:length(freqOrdered)-15
    fprintf('%s %d %f\r\n', words(index(i),:), freqOrdered(i), P_w(index(i)));
end
%}

% input the correctly and incorrectly guessed letters
isLetterGuessed = zeros(26,1);
guessedValue = zeros(5,1);
lettersGuessedCorrectly = [];
lettersGuessedIncorrectly = [];

input1 = input('Enter the string with the characters that are guessed correctly (put - for blank)\n','s');
for i=1:length(input1)
    if(input1(i)~='-')
        isLetterGuessed(double(input1(i)) - 64) = 1;
        guessedValue(i) = double(input1(i));
        lettersGuessedCorrectly = [lettersGuessedCorrectly input1(i)];
    end
end

input2 = input('Enter the comma separated list of characters that are guessed incorrectly\n','s');
temp = regexp(input2,',','split');
for i=1:length(temp)
    isLetterGuessed(double(temp{i}) - 64) = 1;
    lettersGuessedIncorrectly = [lettersGuessedIncorrectly temp{i}];
end

%processing the input to guess the next best letter having the highest
%probability among others

% pre-calculating the probability for the evidence E for efficiency 
P_evidence = 0;

for i=1:length(words)
    flag = 1;
    for j=1:5
        if(guessedValue(j)==0)
            % if the current position is blank, then the current word
            % should not have any already guessed letter at corresponding position
            if(any([lettersGuessedIncorrectly lettersGuessedCorrectly]==words(i,j)))
                flag = 0;
                break;
            end
            % if the current position is filled, then the current word
            % should have the same letter in it at the same position
        else if (words(i,j) ~= char(guessedValue(j)))
                flag = 0;
                break;
            end
        end
    end
    P_E_given_Wi = flag; 
    P_evidence = P_evidence + P_word(i)*P_E_given_Wi;
end

% choose one letter that has not been guessed yet and calculate its 
% probability of occurance given the evidence
P_Li_given_E = zeros(26,1);

for k=1:26
   if(isLetterGuessed(k)==0) 
       Li = char(k + 64);
   else
       continue;
   end
    
   for i=1:length(words)
        flag = 1;
        for j=1:5
            if(guessedValue(j)==0)
                % if the current position is blank, then the current word
                % should not have any already guessed letter at corresponding position
                if(any([lettersGuessedIncorrectly lettersGuessedCorrectly]==words(i,j)))
                    flag = 0;
                    break;
                end
                % if the current position is filled, then the current word
                % should have the same letter in it at the same position
            else if (words(i,j) ~= char(guessedValue(j)))
                    flag = 0;
                    break;
                end
            end
        end
        P_E_given_Wi = flag;
        
        % Using the Bayes rule, determining the probability of ocurrance of current
        % word, given the evidence
        P_Wi_given_E = (P_E_given_Wi * P_word(i))/P_evidence;

        % Given the word, determining the probability of occurance of 
        P_Li_given_Wi = 0;
        for j=1:5
            if(guessedValue(j)==0)
                if(Li == words(i,j))
                    P_Li_given_Wi = 1;
                    break;
                end
            end
        end
        
        %update probability of ocurrance of chosen letter under the context
        %of current word
        P_Li_given_E(k) = P_Li_given_E(k) + (P_Wi_given_E * P_Li_given_Wi);
   end
end

%select the letter with maximum probability
[nextGuess, In] = max(P_Li_given_E);

fprintf('\nBest Next Guess: %c \nProbability of occurance: %.4f\r\n', char(In + 64), nextGuess);