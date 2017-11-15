clc;
clear all;
close all;

%% %%%%%...System Parameters...%%%%%%
Users=[16];
nBits=2560;            %Number of bits per user
blockSize=256;          %when decreasing block size perofrmance is better 
sf=64;                   %Repetition spreading code length (spreading factor)
intr='random';          %Class of interleavers used {'random','power','tree'}
modOrder=2;             %modulation order ( number of points in singal constellation)
nPaths=3;               %Number of paths in the channel,consider it to bes ame for all users for simplicity
nBlocks= nBits/blockSize;
recItr=15;              %Number of iterations in the iterative receiver
decItr=6;               %Number of iterations in each user's turbo decoder
code='None';            %Class of chanel coding used {'Conv','Turbo','None'}

%%%%%%%...Initializing Data...%%%%%%
ebno=0:1:10;            %energy per bit to noise power spectral density ratio
berRun=zeros(1,length(ebno)); %ber values after each run
ber=zeros(1,length(ebno));  
nRuns=10;                %Number of runs of the code to increase output certainity

%% %%%%%...Starting Simulation...%%%%%%
for k=1:length(Users)
    
  nUsers=Users(1,k)
  ber=zeros(1,length(ebno)); %Total averaged ber for all code runs

for r=1:nRuns
 
inputData=randi(2,nUsers,nBits)-1 ;  %Generating random binary data for given number of users

%%  Low rate encoder
%encData: Matrix where each row represents each single user encoded binary data

if isequal(code,'Turbo')
%Turbo Coded IDMA
hAppDec=0;
codeRate=1/2;
encBlockSize=(1/codeRate)*blockSize;
genPoly = [13 15];           %generator polynomial of the encoder (octal value)
feedbPoly = 13;              %feedback polynomial of the encoder (octal value)
constrLength = 4;            %constraint length of the encoder (memory length + 1)
[encData, rm_not_null, cc, rm, h_rm] = turboEncode(inputData, codeRate, genPoly, feedbPoly, constrLength, blockSize );

elseif isequal(code,'Conv')
%Convlutional coded IDMA
rm_not_null=0;
cc=0;
rm=0;
h_rm=0;
codeRate=1/2;
constrLength=1; 
encBlockSize=(1/codeRate)*(blockSize+constrLength-1);
hConEnc=comm.ConvolutionalEncoder('TerminationMethod','Truncated','TrellisStructure',poly2trellis(5,[35 23],23));
hAppDec = comm.APPDecoder(...
    'TerminationMethod','Truncated','TrellisStructure',poly2trellis(5,[35 23],23), ...
    'Algorithm','True APP','CodedBitLLROutputPort',true);

    for a = 1 : nUsers
       for b = 1 : nBlocks
         dataBlock= inputData(a,(blockSize*(b-1)+1):blockSize*b);
         encBits=step(hConEnc,transpose(dataBlock)); 
         encData(a,(encBlockSize*(b-1)+1):encBlockSize*b)=transpose(encBits);
       end
    end 
    
else
    
%Uncoded IDMA
constrLength=1;
rm_not_null=0;
cc=0;
rm=0;
h_rm=0;
hAppDec=0;
codeRate=1;
encData=inputData;
encBlockSize=blockSize; 
end

%% Optional repetition spreading code

if sf==1
    spreadedData=encData; %Matrix where each row represents single user spreaded encoded binary data
    sprBlockSize=encBlockSize; %Size of each spreaded encoded block of data
else
    encData=2.*encData-1;
    repCode= repmat([1 -1],1,sf/2);
    sprBlockSize= sf*encBlockSize;
    for i = 1 : nUsers
        for j = 1 : nBlocks
         encBlock= encData(i,(encBlockSize*(j-1)+1):encBlockSize*j);
         spreadedData(i,(sprBlockSize*(j-1)+1):sprBlockSize*j)=spreader(encBlock, repCode);
        end
    end
    spreadedData=(spreadedData+1)./2;
    encData= (encData+1)./2;
end

%% Chip Level Interleaver
%intrMatrix: Matrix where each row represents each user specific interleaver
%                       Please put into consideration that random
%                       interleavers are saved in memory in the base
%                       station and mobile station, while in power
%                       interleavers only the  master interleaver is
%                       saved and each user specific interleaver is
%                       generated according to its index by a defined 
%                       scheme in the attached report, while in tree based 
%                       interleavers only the two master interleavers 
%                       are  saved and each user specific intelreaver is 
%                       generated  by its index which saves momory and 
%                       improves the computional complexity.

%intBlockSize: size of the block on which interleaving was done
%n : number of encoded blocks taken at a time to be interleaved 
%nIntBlocks:  Total number of blocks on which interleaving is done 
%..Example... If length of input data is 12800, code rate is (1/5), sf is 1.
%             Data block size is 128.Length of each spreaded block is (5*128)
%             If n is 2, 2 spreaded encoded  blocks will be taken together to be 
%             interleaved and intBlockSize = 2*(5*128).
n=1;
if mod(nBlocks,n)~=0
    disp('INVALID Interleaving block size, please choose n to be factor of ');
    disp(nBlocks);
else
intBlockSize= n*sprBlockSize;
nIntBlocks= length(spreadedData)/intBlockSize;

if isequal(intr,'random')
    intrMatrix= randIntr(nUsers,intBlockSize);
elseif isequal(intr,'power')
    M= permuter(intBlockSize);
    intrMatrix(1,:)= M;
    for i= 2: nUsers
        intrMatrix(i,:)= powerIntr(M,i);
    end    
elseif isequal(intr,'tree') 
     M1= permuter(intBlockSize);
     M2= permuter(intBlockSize);
     intrMatrix(1,:)= M1;
     intrMatrix(2,:)= M2;
    for i= 3: nUsers
        intrMatrix(i,:)= treeInt(M1,M2,i);
    end
end
 
for i = 1 : nUsers
    for j = 1 : nIntBlocks
         sprBlock= spreadedData(i,(intBlockSize*(j-1)+1):intBlockSize*j);
         interleavedData(i,(intBlockSize*(j-1)+1):intBlockSize*j)=Interleaver(sprBlock,intrMatrix(i,:));
    end
end

end

%% Symbol Mapper
modData=2.*interleavedData-1;

%% Multi Paths Channel
hu=exp([0:-1:-(nPaths-1)]);    %assume exponential channel response per user for simplicity
H=repmat(transpose(hu),1,nUsers);
chanOutput= channel(modData,nPaths,H);

for p= 1: length(ebno)
    
%% AWGN Channel
snr_lin= ((10^(ebno(p)/10))*codeRate)/(sf/2); %Eb: Information bit energy
%NOTE........................... For real signals, N=N0/2, S(per chip)=(Eb/sf), (S/N)=(Eb/sf)*(2/N0),
%................................(Eb/No)= (S/N)*(sf/2)
snr_db = 10*log10(snr_lin);
ReceiverInput= awgn(sum(chanOutput,1) ,snr_db ) ;
noiseVar=1/(2*snr_lin);           %sigma^2 linear

%% Chip by chip detector
[outputData,sprLLR,decLLR,sprIN,decIN,sprSoftOut,decSoftOut,blokTrac]= CBCReceiever(ReceiverInput,H,sf,noiseVar,recItr,intrMatrix,codeRate,decItr,hAppDec,rm_not_null,cc,rm,h_rm,constrLength,code);
berRun(p)=biterr(inputData,outputData)/(numel(inputData));

      end %end Eb/No
ber= ber+ berRun;

   end %end runs
ber=ber/(nRuns); %average BER per user

end %end users





