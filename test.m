clc;
close all;
clear all;
%% testing PN sequence
%{
m=3;
y(1,:)=generatePNseq(m);
nSeq = 2^m-1;
for i=2:nSeq
y(i,:) = circshift(y(i-1,:),1,2);
end
y;
y=2.*cat(2,y,transpose(zeros(1,nSeq)))-1;
%}

%% Testing Random Interleaver, deInterleaver
%{
nUsers=5;
intBlockSize=100;
nBits=10000;
nIntBlocks=nBits/intBlockSize;
for i = 1 : nUsers
    inputData(i,:)=randi(2,1,nBits)-1 ;
end
intrMatrix=randIntr(nUsers,intBlockSize);

for i = 1 : nUsers
    for j = 1 : nIntBlocks
         dataBlock= inputData(i,(intBlockSize*(j-1)+1):intBlockSize*j);
         interleavedData(i,(intBlockSize*(j-1)+1):intBlockSize*j)=Interleaver(dataBlock,intrMatrix(i,:));
    end
end 


    for a = 1 : nUsers
        for b = 1 : nIntBlocks
           IntdataBlock= interleavedData(a,(intBlockSize*(b-1)+1):intBlockSize*b);
           deInterleavedData(a,(intBlockSize*(b-1)+1):intBlockSize*b)=deInterleaver(IntdataBlock,intrMatrix(a,:)); 
        end
    end 
    
    biterr(inputData,deInterleavedData)/numel(inputData);
%}
%% Testing Master Random Interleavers
%{
 M=[2 5 1 3 4];
 I2=Interleaver( M,M );
 I3=Interleaver(I2,M );
 I4=Interleaver(I3,M );
 powerIntr(M,6);
randi(2,1,5)-1;
%}
%% testing intCC from two OPN sequences of length 8, PN1,PN2 interleaving patterns
%{
int1=[2 1 3 5 4 6 7 8];
int2=[1 2 3 5 7 4 6 8];
intCC(int1,int2);
%}
%% testing a noisless IDMA system using orthogonal Intelrleavers and random intelreavers 
%{
nUsers=6;
nBits=4;

%generating random data
for i = 1 : nUsers
    inputData(i,:)=randi(2,1,nBits)-1;
end
inputData;

%BPSK modulation
modData=2.*inputData-1;


%spreading
sf=64;
sc=repmat([1 -1],1,sf/2);
for i= 1:nUsers
   spreadedData(i,:)= spreader( modData(i,:),sc) ;
end
spreadedData;


%Interleaving symbol by symbol
%interleavers=[2 1 3 5 4 6 7 8 ;1 2 3 5 7 4 6 8 ];
interleavers=randIntr(nUsers,sf);
for j= 1:nUsers
    for  i=1:nBits
        %"b" is the symbol begining index
        b=1+sf*(i-1);
        intData(j,b:(b+sf-1))=Interleaver(spreadedData(j,b:(b+sf-1)),interleavers(j,:));
       
    end
end
intData;

channelOutput=sum(intData);

%deInterleaving recieved data 
for j= 1:nUsers
    for  i=1:nBits
        %"b" is the symbol begining index
        b=1+sf*(i-1);
        deintData(j,b:(b+sf-1))=deInterleaver(channelOutput(1,b:(b+sf-1)),interleavers(j,:));
       
    end
end
deintData;

%deSpreading
for i= 1:nUsers
   outputData(i,:)= despreader( deintData(i,:),sc) ;
end
outputData;
%}
%% testing spreader
%{
sd=spreader( [1 -1 -1 ], [1 -1 1 -1] );
out=despreader(sd,[1 -1 1 -1]);
%}
%% testing tree based intelreavers
%{
k=1;
tmp=k;
L=0;
while(tmp>0)
    tmp=tmp-(2^(L+1));
    L=L+1;
end
L;
M2=[2 5 3 4 1];
M1=[3 5 1 4 2];

%testing for user 8
%intelreaving pattern: @2(@1(@1)) 
Interleaver(Interleaver(M1,M1),M2);
treeInt( M1, M2, 8 );
%}
%% testing turbo encoder/decoder
%{
nRuns=10;

for snr_db= 1:0.5:3
    
deltaExtr=zeros(1,15);

 for i=1:nRuns
     

%rng('default');  
blockSize=1280;
inputData= transpose(randi([0 1], blockSize, 1));
codeRate=1/2;
genPoly=[13 15];
feedbPoly= 13;
constrLength= 4;
encBlockSize=(1/codeRate)*blockSize;
[encData, rm_not_null,cc,rm,h_rm]= turboEncode(inputData, codeRate,genPoly, feedbPoly, constrLength, blockSize );

encData=2.*encData-1;
softLLR=zeros(1,2*blockSize);
ReceiverInput= awgn(encData,snr_db ,'measured') ;
 for nIterations= 1:15;
     extrLLRtmp= softLLR;
     [decData, softLLR]= turboDecode(ReceiverInput, nIterations, encBlockSize, rm_not_null,cc,rm,h_rm  );
     deltaExtr(nIterations) =deltaExtr(nIterations)+ sum(abs(softLLR-extrLLRtmp))./numel(softLLR);
 end
  
 end
 
 deltaExtr=deltaExtr./nRuns;
 plot([1:15],deltaExtr,'DisplayName',strcat('snr_{db}',int2str(snr_db)));

 hold on;
end
 legend('show');
 hold off;
 
 xlabel('Number of decoder Iterations');
 ylabel('Sum of Extrnsic LLR');

%biterr(inputData,decData)/numel(inputData)
%}
%% testing ESE
%{
ese=ESE( [ 1 3 0.5 4], [0.5 1 2.5 3 ; 1 1 2 3 ; -0.5 2 -2 1 ], [1 1 1], 2   );
%}
%% Testing rakeGaussianESE
%{
apLLR=[ 2 2 1 ;1 0 2; 2 1 3; 4 0 1];
H= [ 1 1 4 1 ; 1 2 1 3; 4 1 2 1];
R= [ 1 2 3 4 5 ];
noiseVar=2;
%rakeGaussianESE(apLLR, R, H, noiseVar );
%}
%% Testing channel
%{
channel([1 0 1 1 ; 1 1 1 0 ; 0 1 1 1 ],3,[ 1 2 1 ; 1 3 1; 0 2 1]);
mod(11,2);

%}
%% Testing Chain without ESE for single user
% Same output of the chain for SNR =0 --> ber = 0.1960

    

clear inputData
clear encData;
nUsers=1;
nBits=1000;
rng('default');
for i = 1 : nUsers
    inputData(i,:)=randi(2,1,nBits)-1 ;
end

blockSize=100;
codeRate=1/2;
nBlocks= nBits/blockSize;
encBlockSize=(1/codeRate)*blockSize;

hConEnc=comm.ConvolutionalEncoder('TerminationMethod','Truncated');
hAppDec = comm.APPDecoder(...
    'TrellisStructure',poly2trellis(7,[171 133]), ...
    'Algorithm','True APP','CodedBitLLROutputPort',true);




% Encoding
    for a = 1 : nUsers
       for b = 1 : nBlocks
         dataBlock= inputData(a,(blockSize*(b-1)+1):blockSize*b);
         encBits=step(hConEnc,transpose(dataBlock)); 
         encData(a,(encBlockSize*(b-1)+1):encBlockSize*b)=transpose(encBits);
       end
    end 
    
    
% Modulating    
encData=2.*encData-1;


% spreading
sf=1;
if sf==1
    spreadedData=encData;
    sprBlockSize=encBlockSize;
else
    repCode= repmat([1 -1],1,sf/2);
    sprBlockSize= sf*encBlockSize;
    for i = 1 : nUsers
        for j = 1 : nBlocks
         encBlock= encData(i,(encBlockSize*(j-1)+1):encBlockSize*j);
         spreadedData(i,(sprBlockSize*(j-1)+1):sprBlockSize*j)=spreader(encBlock, repCode); 
        end
    end
end






% Interleaving 
 intrMatrix= randIntr(nUsers,sprBlockSize);

for i = 1 : nUsers
    for j = 1 : nBlocks
         sprBlock= spreadedData(i,(sprBlockSize*(j-1)+1):sprBlockSize*j);
         interleavedData(i,(sprBlockSize*(j-1)+1):sprBlockSize*j)=Interleaver(sprBlock,intrMatrix(i,:));
    end
end 





%interleavedData=spreadedData;
%% Noise
interleavedData=awgn(interleavedData,100);



%% De Interleaving 
     for a = 1 : nUsers
        for b = 1 : nBlocks
           IntdataBlock= interleavedData(a,(sprBlockSize*(b-1)+1):sprBlockSize*b);
           desDecApLLR(a,(sprBlockSize*(b-1)+1):sprBlockSize*b)=deInterleaver(IntdataBlock,intrMatrix(a,:));
        end
     end 


%berInt=biterr(double(spreadedData>0),double(desDecApLLR>0))/numel(spreadedData)


%desDecApLLR=interleavedData;
%% Despreading
    if sf > 1 
      for a = 1 : nUsers
        for b = 1 : nBlocks
         sprBlock= desDecApLLR(a,(sprBlockSize*(b-1)+1):sprBlockSize*b);
         desDecApLLR(a,(encBlockSize*(b-1)+1):encBlockSize*b)= despreader(sprBlock, repCode);
        end
      end 
      
    else
        desDecApLLR= desDecApLLR;
    end


    
    
% Decoding
  for a = 1 : nUsers
       for b = 1 : nBlocks
         encBlock= desDecApLLR(a,(encBlockSize*(b-1)+1):encBlockSize*b);
         [outSoftData, outputExtrLLR]=step(hAppDec,zeros(blockSize,1),transpose(encBlock));
         outData(a,(blockSize*(b-1)+1):blockSize*b)=transpose(double(outSoftData> 0));
         ExtrLLR(a,(encBlockSize*(b-1)+1):encBlockSize*b)=transpose(outputExtrLLR);
         
       end
  end 



ber=biterr(inputData,outData)/numel(inputData)
%}
%% Testing CBC detector 
%{
R=[ 1 2 3 4];
intBlockSize=4;
encBlockSize=4;
H=[1 1 ];
sf=1;
noiseVar=0;
decItr=1;
recItr=2;
intrMatrix=[  3 1 4 2 ; 1 4 3 2 ];
rm_not_null=0;
cc=0;
rm=0;
h_rm=0;
blockSize=2;
hAppDec = comm.APPDecoder(...
    'TrellisStructure',poly2trellis(7,[171 133]), ...
    'Algorithm','True APP','CodedBitLLROutputPort',true);
hDemod=0;
snr_lin=0;


CBCdetector( R, intBlockSize, encBlockSize, H, sf, noiseVar, decItr,
recItr, intrMatrix, rm_not_null,cc,rm,h_rm, blockSize,hAppDec,hDemod,snr_lin);
%}
%% Testing convlutional encoder 
%{
hConEnc=comm.ConvolutionalEncoder('TerminationMethod','Truncated');
encBits=transpose(step(hConEnc,transpose([1 1 0 1])));
encBits=transpose(step(hConEnc,transpose([1 0 0 1])));
encBits=transpose(step(hConEnc,transpose([1 1 0 1])));
encBits=transpose(step(hConEnc,transpose([1 0 1 0]))) ;
%}
%{
rng('default');  
blockSize=1280;
inputData= transpose(randi([0 1], blockSize, 1));
codeRate=1/2;
genPoly=[13 15];
feedbPoly= 13;
constrLength= 4;
encBlockSize=(1/codeRate)*blockSize;
[encData, rm_not_null,cc,rm,h_rm]= turboEncode(inputData, codeRate,genPoly, feedbPoly, constrLength, blockSize );
     [decData, softLLR]= turboDecode(encData, 2, encBlockSize, rm_not_null,cc,rm,h_rm  );

     
     
     
     [encData, rm_not_null,cc,rm,h_rm]= turboEncode(inputData, codeRate,genPoly, feedbPoly, constrLength, blockSize );
     [decData, softLLR]= turboDecode(encData, 1, encBlockSize, rm_not_null,cc,rm,h_rm  );
     [decData, softLLR]= turboDecode(encData, 1, encBlockSize, rm_not_null,cc,rm,h_rm  );
 %}    

%% SINGLE user AWGN 
%{
inputData(1,:)=randi(2,1,10000)-1 ;
snr=3:1:15 ;
encData=2.*inputData-1;

for i=1:length(snr)
    ReceiverInput= awgn(encData ,snr(i) ,'measured') ;
    ReceiverOutput=double(ReceiverInput>0);
   ber(i)= biterr(inputData,ReceiverOutput)/numel(inputData);
end
figure
semilogy(snr,ber) ;
xlabel({'SNR_d_b'});
ylabel({'BER'});
%}

%% nUsers versus Eb/No for different BER


