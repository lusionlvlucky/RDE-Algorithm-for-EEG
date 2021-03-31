clear all;
%Y_origin = xlsread('E:\EEG_Data\20121031083429.txt'); %Y is a 24 Dimension
%EEG signal Normal
Y_origin=importdata('F:\DFA\DFA_DATA\RDE��������\���\20121101111605.txt'); 
xx_origin = Y_origin(2000+1:2000+30,:)';  
traindata = xx_origin;
realdata = Y_origin(2000+1:2000+35,:)'; %5-step real data value
dlmwrite('F:\DFA\DFA_DATA\RDE��������\���\traindata_605.txt',traindata,'delimiter','\t','newline','pc');
dlmwrite('F:\DFA\DFA_DATA\RDE��������\���\realdata_605.txt',realdata,'delimiter','\t','newline','pc');
D = size(traindata,1); %D = 24
s = 2000;% the number of non-delay embedding
L = 6; % the value of L is calculated by FNN-cao
pre_value = zeros(D,5);
for k = (1:5) % 10-step prediction using 30-length original data
    
    disp(['The process has finished ' num2str(k) ' /5 ''.'])
    Y = textread('F:\DFA\DFA_DATA\RDE��������\���\traindata_605.txt'); %Y is a 24 Dimension EEG signal
    traindata = Y(1:end,:);  
    trainlength = size(traindata,2);
    one_step_value = zeros(D,1);




    


    for j = 1:D
        prediction = zeros(1,s);
        indexr = zeros(s,D);
        score = zeros(1,s);
        % making predictions with RDE using KDE schema;

        for i=1:s

            indexr(i,:)=randperm(D);
            predictions(i)=myprediction_gp(traindata(indexr(i,1:L),1:trainlength-1),traindata(j,2:trainlength),traindata(indexr(i,1:L),trainlength));% other kinds of fitting method could be used here
        end
        pp=outlieromit(predictions);% exclude the outliers
        [F,XI]=ksdensity(pp,linspace(min(pp),max(pp),10000));% use kernal density estimation to approximate the probability distribution
        prediction=sum(XI.*F/sum(F)); % use expectation as the final one-step predicted value 
        ystd=std(pp);
        pre_value(j,k) = prediction;
        one_step_value(j,1)=prediction;
    end
    
    traindata(:,end+1)=one_step_value;
    dlmwrite('F:\DFA\DFA_DATA\RDE��������\���\traindata_605.txt',traindata,'delimiter','\t','newline','pc');
    

    %     % plot the result
    %     figure
    %     plot(xx(j,1:trainlength+1),'-*');% real data
    %     hold on;
    %     plot(trainlength+1,prediction,'ro','MarkerSize',8); %predicted data
    % 
    %     figure
    %     plot(XI,F); % probablity distribution generated by RDE framework
    %     hold on
    %     plot(xx(j,trainlength+1),max(F),'bo','MarkerFaceColor','r'); % true value of the target variable

    dlmwrite('F:\DFA\DFA_DATA\RDE��������\���\prevalue_605.txt',pre_value,'delimiter','\t','newline','pc');
end
