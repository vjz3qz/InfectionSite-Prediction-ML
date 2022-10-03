
clc; clear;
%before starting, make sure to add folder/subfolders to class path
%%
%import output data (infection sites) in order
SRRtoInfectionSite=readcell("CSBL/SRRtoInfectionSite.xlsx");
[row,~]=size(SRRtoInfectionSite);
%manually add headers
output{1,1}=SRRtoInfectionSite{1,1};
output{1,2}=SRRtoInfectionSite{1,2};
k=2;
i=k;
%add 50 rows of each body site
%excludes SRR____133, 147, 148
while i<=row
    if i==93
        i=i+1;
    end
    if i==107
        i=i+2;
    end
    for j=1:50
        output{k,1}=SRRtoInfectionSite{i,1};
        output{k,2}=SRRtoInfectionSite{i,2};
        k=k+1;
    end
    i=i+1;
end
%%

%skipped 133, 147, 148, need to exclude those.
%creating headers
mainFolder = dir("/Users/varunpasupuleti/Documents/CSBL/matlab directory");%import directory
totalRxns={}; %lists total rxns
totalRxns(end+1)=output(1,1);
i=1;
while i<=numel(mainFolder) %iterates trhough the tsv folders
    %skipping skipped SRRs
    if i==92
        i=i+1;
    end
    if i==106
        i=i+2;
    end
    [data, header, raw]=tsvread(strcat("TSVFilesriptide_results_0.5_SRR",num2str(1056041+i),"/flux_samples.tsv")); 
    for rxn=1:length(header)-1 %loops through rxns to see if its in the array
        if sum(contains(totalRxns,string(header(rxn))))==0 %if not in array, add to array
            totalRxns(end+1)=header(rxn);
        end
    end
    i=i+1;
end
%saving body_site
%totalRxns{1,end+1}=output(1,2);
totalRxnHeaders=totalRxns;%saving only the headers
%%
%add a row for each srr, add vals for each rxn
%iterate through flux sample files again, get 50 rows of each srr
i=1;
k=i;
while i<=numel(mainFolder) %iterates trhough the tsv folders
    if i==92
        i=i+1;
    end
    if i==106
        i=i+2;
    end
    %open the flux sample file
    [data, header, raw]=tsvread(strcat("TSVFilesriptide_results_0.5_SRR",num2str(1056041+i),"/flux_samples.tsv"));
    %create a loop for 50 rows
    for j=1:50
        %loop for each row
        for rxn=1:length(header)-1 %loops through rxns
            totalRxns(k+1,1)={"SRR"+num2str(1056041+i)}; %correspond isolates to SRR in TotalRxns;adds SRR to TotalRxns
            if sum(contains(totalRxnHeaders,string(header(rxn))))~=0 %if in array, get index and add under that index
                col= find(strcmp(totalRxnHeaders,string(header(rxn))));
                totalRxns(k+1,col)=raw(j+1,rxn+1);%add in specified location
                
                %idk why the previous TotalRxns worked with () instead of {}, but im not going to change it
            end
        end
        k=k+1;
    end
    i=i+1;
end
%manually deleting skipped SRRs;
%totalRxns(108,:)=[];
%totalRxns(107,:)=[];
%totalRxns(93,:)=[];
[SRRLength, rxnLength]=size(totalRxns);
rxnLength=rxnLength-1; %account for first col being run and last col being body_site
SRRLength=SRRLength-1; %account for first row being rxnHeaders
%%
%task: iterate through TotalRxns again and add '0.0' for all empty cells
for i=2:SRRLength+1
    for j=2:rxnLength+1 %should be 1:477, but added an empty column to first column
        %if empty, set equal to 0
        if(isempty(totalRxns{i,j}))
            totalRxns{i,j}='0.0';
        end
    end
end
%%
%add body_sites to totalRxns
%[firstRow,lastCol]=find(totalRxns,string({'body_site'}));
%totalRxns{1,end+1}=output(1,2);
for i=1:SRRLength+1
    totalRxns{i,1}=output{i,1};
    totalRxns{i,rxnLength+2}=output{i,2}; %+2 to add run and at end
    %infectionSiteCellArray{i,1}=output{i,2};
end

%%
%copy TotalRxns to an excel file
writecell(totalRxns,"/Users/varunpasupuleti/Documents/CSBL/TotalRxns.xlsx");
%%
%remove nd's from TotalRxns
%FIX THIS
cleanedTotalRxns=totalRxns;
for i=SRRLength:-1:1
    if isequal(cleanedTotalRxns(i,end),{'nd'})
        cleanedTotalRxns(i,:)=[];
    end
end
%%
%remove headers
cleanedTotalRxns(1,:)=[];
%manually adding last body site 
%cleanedTotalRxns(109,493)={'respiratory tract'};
%get index of last column
[~,col]=size(cleanedTotalRxns);
%finalized infection site output data
infectionSites=cleanedTotalRxns(:,end);
%removed output column and SRR column
cleanedTotalRxns(:,col)=[];
cleanedTotalRxns(:,1)=[];
%convert input data to matrix
[row,col]=size(cleanedTotalRxns);
totalRxnsMatrix=zeros(row,col);
for i=1:row
    for j=1:col
        totalRxnsMatrix(i,j)=str2double(string(cleanedTotalRxns(i,j)));
    end
end

%line up the data, make sure same number of rows
%learn about models, play with the learner

%STARTING UP CLASSIFICATION LEARNER INSTRUCTIONS
%open classification learner, click input, add output from workspace 
%from workspace, use 10 for cross validation, start session
