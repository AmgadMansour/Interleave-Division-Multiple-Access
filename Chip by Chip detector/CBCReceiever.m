function [outData,sprLLR,decLLR,sprIN,decIN,sprSoftOut,decSoftOut,blokTrac] = CBCReceiever(R,H,sf,noiseVar,recItr,intrMatrix,codeRate,decItr,hAppDec,rm_not_null,cc,rm,h_rm,constrLength,code)
%Function to apply the chip by chip detection algorithm in IDMA

%R: composite received symbols at the receiver input
%N: length of the encoded spreaded symbols
%       r1 r2 r3 ... rN       For single path channel
%       r1 r2 r3 ... r(N+L-1) For L-path channel

%noiseVar: Noise power in watts, sigma^2 

%H: channel coefficents for all K users in an L-Taps channel, where (h1)1
%   is the first user line of sight channel coefficent, (h1)2 is the first
%   user second path channel coefficent and so on.
%       (h1)1 (h2)1 (h3)1 .... (hK)1
%       (h1)2 (h2)2 (h3)2 .... (hK)2
%                    .
%                    .
%       (h1)L (h2)L (h3)L .... (hK)L
%In case of single path channel only the first row is available.



%%%%%%%...Collecting_Data...%%%%%%
[L K]= size(H); %L:Number of paths in the channel, K: number of users
N= length(R)-L+1; %Length of information bits
[K intBlockSize]=size(intrMatrix); %intBlockSize: size of the block on which interleaving process was done 
nBlocks= N/intBlockSize;
if isequal(code,'Turbo')
    constrLength=1;
end
    
blockSize= ((intBlockSize/sf)-constrLength+1)*codeRate ; %size of the original information data block
encBlockSize= (blockSize+constrLength-1)*(1/codeRate); %size of each encoded block of data
if sf > 1
repCode= repmat([1 -1],1,sf/2); 
end

%%%%%%%%..Tracing..%%%%%%%%
tracLength=64;
sprLLR=zeros(recItr,tracLength);
decLLR=zeros(recItr,tracLength);
sprIN=zeros(recItr,tracLength);
decIN=zeros(recItr,tracLength);
blokTrac=zeros(4*recItr,tracLength);
x=1;
sprSoftOut=zeros(recItr,tracLength);
decSoftOut=zeros(recItr,tracLength);
tmpOutSoftData=zeros(K,N);


eseApLLR= zeros(K,N); % Input to ESE initlazied to zeros
outData=[]; %Receiver hard output initlaization

for i= 1: recItr 
    
%ESE ( Elementay Singal Estimator), to calculate the ESE extrinsic log likelhood ratios
%NOTE:      The ESE can be considered in the block by block receiver
%           operations, however, we perofrm the ESE on the whole data
%           before going into the loop for improving the code running time.
    if L==1
        eseExtrLLR= ESE(R, eseApLLR, H, noiseVar);
    else
        eseExtrLLR= rakeGaussianESE(R, eseApLLR, H, noiseVar );
    end
    
for a= 1:K
    
    for b=1:nBlocks
        
        eseExtrBlock= eseExtrLLR(a,(intBlockSize*(b-1)+1):intBlockSize*b); %current block of ESE extrinsic LLRs
        decApLLRBlock=deInterleaver(eseExtrBlock,intrMatrix(a,:)); % De-Interleaving, to calculate the decoder a priori log likelhood ratios
        
        %%%%%%%%..Testing..%%%%%%%%
        %..Normalizing spreaded LLR input to decoder..%    
        %mx=max(abs(decApLLRBlock));
        %decApLLRBlock=decApLLRBlock./mx;
        
        %Despreading in case of repetion code
        if sf > 1
            desDecApLLRBlock= despreader(decApLLRBlock, repCode);
        else
            desDecApLLRBlock= decApLLRBlock;
        end
        
        %.................................Decoding.....................................%

         if isequal(code,'Conv')
        %...Convlutional Decoding...%
        tmp=desDecApLLRBlock;
        ini=zeros(blockSize,1); %inital LLR values of information bits
        
        %%%%%%%%..Testing..%%%%%%%%
        %..Updating LLR values of information bits ..% 
        %ini=transpose(tmpOutSoftData(a,(blockSize*(b-1)+1):blockSize*b));
        
        %%%%%%%%..Testing..%%%%%%%%
        %..Normalizing de-spreaded LLR input to decoder..%         
        %tmp=tmp./max(abs(tmp));
        
        %%%%%%%%..Testing..%%%%%%%%       
        %..Normalizing probablities input to decoder..%
        %inProbBlock= exp(tmp)./(1+exp(tmp));
        %inProbBlock=inProbBlock./max(abs(inProbBlock));
        %inLLRBlock=log(inProbBlock./(1-inProbBlock));
        %tmp=inLLRBlock;
           
        [outSoftData outLLR]= step(hAppDec,ini,transpose(tmp)); 
        outSoftDataBlock= transpose(outSoftData);       %outSoftData: Soft output of the decoded bits 
        %outLLRBlock= transpose(outLLR);  %outLLR: LLR values of the encoded bits fed back from the decoder
               
        
        %%%%%%%%..Testing..%%%%%%%%
        %..Normalizing LLR values output from decoder..%
        %outLLRBlock= outLLRBlock./max(abs( outLLRBlock));
 
        
        %%%%%%%%..Testing..%%%%%%%%
        %..Updating LLR values of information bits ..% 
        %tmpOutSoftData(a,(blockSize*(b-1)+1):blockSize*b)=outSoftDataBlock;
        
         elseif isequal(code,'Turbo')
        %...Turbo Decoding...%
        [hardOutput, extrLLRrm] = turboDecode(desDecApLLRBlock, decItr, encBlockSize, rm_not_null, cc, rm, h_rm );
        %outLLRBlock= extrLLRrm;
        
        %outLLRBlock=outLLRBlock./max(abs(outLLRBlock));
        else   
        outSoftDataBlock= desDecApLLRBlock; %For un-coded IDMA
        end
       %.............................................................................%
       
        outLLRBlock= desDecApLLRBlock; %no standard APP decoding, the feedback is given directly from despreader
        
        
        %%%%%%%%..Testing..%%%%%%%%       
        %..Normalizing probablities output from decoder..%
        %outProbBlock= exp(outLLRBlock)./(1+exp(outLLRBlock));
        %outProbBlock=outProbBlock./max(abs(outProbBlock));
        %outLLRBlock=log(outProbBlock./(1-outProbBlock));
        

        % Spreading in case of repition code 
        if sf > 1
            sprOutLLRBlock= spreader(outLLRBlock, repCode); 
        else
            sprOutLLRBlock= outLLRBlock ;
        end
 
        extOutLLRBlock= sprOutLLRBlock-decApLLRBlock; %Extrinsic Information from decoder output
  
        %%%%%%%%..Testing..%%%%%%%%  
        %Performing extrinsic calculation before spreading, worse
        %ext=outLLRBlock-desDecApLLRBlock;
        %extOutLLRBlock=spreader(ext, repCode); 
        
        

          
        % Interleaving, to update the ESE a priori log likelhood ratios
        eseApLLR(a,(intBlockSize*(b-1)+1):intBlockSize*b)=Interleaver(extOutLLRBlock,intrMatrix(a,:));
        
        
        
       %%%%%%%%..Testing..%%%%%%%%  
       %... Normalizing input to the ESE...%     
       %g=eseApLLR(a,(intBlockSize*(b-1)+1):intBlockSize*b);
       %eseApLLR(a,(intBlockSize*(b-1)+1):intBlockSize*b)=(g./(max(abs(g))));
       
       %xtmp=eseApLLR(a,(intBlockSize*(b-1)+1):intBlockSize*b);
       
       %{
       if b==1 & a==1
       %sprLLR(i,1:end)=sprOutLLRBlock(1,1:tracLength);
       %sprIN(i,1:end)=decApLLRBlock(1,1:tracLength);
       %sprSoftOut(i,1:end)=outSoftDataBlock(1,1:tracLength);
       %decLLR(i,1:end)=outLLRBlock(1,1:tracLength);
       blokTrac(x,1:end)=eseExtrBlock(1,1:tracLength);
       x=x+1;
       blokTrac(x,1:tracLength/8)=desDecApLLRBlock(1,1:tracLength/8);
       x=x+1;
       blokTrac(x,1:tracLength/8)=outLLRBlock(1,1:tracLength/8);
       x=x+1;
       blokTrac(x,1:end)=xtmp(1,1:tracLength);
       x=x+1;
      
       %decIN(i,1:end)=decApLLRBlock(1,1:tracLength);
       %decSoftOut(i,1:end)=outSoftDataBlock(1,1:tracLength);
       end
       %}
       %end  


       %Final iteration hard output
       if i== recItr
          if isequal(code,'Turbo')
           outData(a,(blockSize*(b-1)+1):blockSize*b)= hardOutput; % For turbo coded system  
          else
         outData(a,(blockSize*(b-1)+1):blockSize*b)=double(outSoftDataBlock>0); % For Convlutioanl coded and uncoded IDMA 
          end
       end
 
       
       end % end b
     end % end a
   end %end recItr
end %end function



