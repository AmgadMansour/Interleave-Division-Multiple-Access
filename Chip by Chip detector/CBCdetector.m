function [ outData, ILA, ILE] = CBCdetector( R, intBlockSize, encBlockSize, H, sf, noiseVar, decItr, recItr, intrMatrix, rm_not_null,cc,rm,h_rm, blockSize,hAppDec,snr_lin)
%Function to apply the chip by chip detection algorithm in the IDMA

%R: composite received symbols at the receiver input
%N: length of the encoded spreaded symbols
%       r1 r2 r3 ... rN       For single path channel
%       r1 r2 r3 ... r(N+L-1) For L-paths channel

%intBlockSize: size of the block on which interleaving process was done 

%H: channel coefficents for all K users in an L-Taps channel, where (h1)1
%   is the first user line of sight channel coefficent, (h1)2 is the first
%   user second path channel coefficent and so on.
%       (h1)1 (h2)1 (h3)1 .... (hK)1
%       (h1)2 (h2)2 (h3)2 .... (hK)2
%                    .
%                    .
%       (h1)L (h2)L (h3)L .... (hK)L
%In case of single path channel only the first row is available.

%sf: spreading factor is the length of the repetion spreading code

%noiseVar: Noise power

%decItr: Number of iterations in each user's decoder

%recItr: Number of iterations in the turbo-type iterative process between
%        the elementary signal estimator and deocder

%intrMatrix: matrix where each row represents each user specific
%            interleaver, please put into consideration that for random
%            interleavers the whole interleavers matrix is saved in both the reciever
%            and transmitter, while in master and tree based
%            interleavers only the master interlavers used are saved at the
%            receiver end and interleavers are generated respeively based on each user
%            index, however for simplicity we consider that the reciever
%            has already done the process of generating interleavers and the intealeavers 
%            matrix is already available.



[L K]= size(H);
N= length(R)-L+1;
nIntBlocks= N/intBlockSize;
nEncBlocks= (N/sf)/encBlockSize;
sprBlockSize= sf*encBlockSize;

if sf > 1
repCode= repmat([1 -1],1,sf/2);
end


%Elementary signal estimator a priori log likelehood ratios initalized to
%zeros
eseApLLR= zeros(K,N); 
decApLLR= zeros(K,N);

ILA=[];
ILE=[];


for i = 1:recItr
 

%% ESE, to calculate the ESE extrinsic log likelhood ratios
    if L==1
        eseExtrLLR= ESE(R, eseApLLR, H, noiseVar);
    else
        eseExtrLLR= rakeGaussianESE(R, eseApLLR, H, noiseVar );
    end
    
    

    %% De-Interleaving, to calculate the decoder a priori log likelhood ratios
   
    for a = 1 : K
        for b = 1 : nIntBlocks
           IntdataBlock= eseExtrLLR(a,(intBlockSize*(b-1)+1):intBlockSize*b);
           decApLLR(a,(intBlockSize*(b-1)+1):intBlockSize*b)=deInterleaver(IntdataBlock,intrMatrix(a,:));
        end
    end 

    
    
       % ILA(i)=mutualInfo(decApLLR(1,1:end));


 %% Despreading in case of repetion code 
    if sf > 1 
      for a = 1 : K
        for b = 1 : nEncBlocks
         sprBlock= decApLLR(a,(sprBlockSize*(b-1)+1):sprBlockSize*b);
         desDecApLLR(a,(encBlockSize*(b-1)+1):encBlockSize*b)= despreader(sprBlock, repCode);
        end
      end 
      
    else
        desDecApLLR= decApLLR;
    end
    
    
    
    
    
    
    
    
    


 %% Decoding, to calculate the decoder extrinsic log likelhood ratios

   %[outData  decOutLLRtmp]= turboDecode(desDecApLLR, decItr, encBlockSize, rm_not_null,cc,rm,h_rm);
    
    
 
     for a = 1 : K
       for b = 1 : nEncBlocks
         encBlock= desDecApLLR(a,(encBlockSize*(b-1)+1):encBlockSize*b);
         [outSoftData outputLLR]=step(hAppDec,zeros(blockSize,1),transpose(encBlock));
         outData(a,(blockSize*(b-1)+1):blockSize*b)=transpose(double(outSoftData> 0));
        decOutLLR(a,(encBlockSize*(b-1)+1):encBlockSize*b)=transpose(outputLLR)./max(abs(outputLLR));

         
       end
     end 
  %}
  
  
  
   %{
     for a = 1 : K
       for b = 1 : nEncBlocks
         encBlock= desDecApLLR(a,(encBlockSize*(b-1)+1):encBlockSize*b);
         
            for c = 1:encBlockSize 
              
         encBlocktmp=encBlock;
         encBlocktmp(1,c)=0;
         [outSoftDatatmp outputLLRtmp]=step(hAppDec,zeros(blockSize,1),transpose(encBlocktmp));
         %outDatatmp=transpose(double(outSoftDatatmp> 0));
        decOutLLRtmp=transpose(outputLLRtmp);
          %outData(a,(b*blockSize)+c)=outDatatmp(1,c);
          decOutLLR(a,(b*encBlockSize)+c)=decOutLLRtmp(1,c);
            end

        [outSoftData outputLLRtmp2]=step(hAppDec,zeros(blockSize,1),transpose(decOutLLR(a,(encBlockSize*(b-1)+1):encBlockSize*b)));
         outData(a,(blockSize*(b-1)+1):blockSize*b)=transpose(double(outSoftData> 0));
         
       end
     end 
  %}
 
       
   
  
  
   % decOutLLR=desDecApLLR;
   %outData=double(decOutLLR>0);
    %}
 %% Spreading in case of repition code 
    if sf > 1 
      for a = 1 : K
        for b = 1 : nEncBlocks
         decBlock= decOutLLR(a,(encBlockSize*(b-1)+1):encBlockSize*b);
         sprDecExtrLLR(a,(sprBlockSize*(b-1)+1):sprBlockSize*b)= spreader(decBlock, repCode); 
        end
      end 
    else
        sprDecExtrLLR= decOutLLR;
    end
    

    
    sprDecExtrLLR= sprDecExtrLLR-decApLLR;
    
    

   % ILE(i)=mutualInfo(sprDecExtrLLR(1,1:end));

    
%% Interleaving, to calculate the ESE a priori log likelhood ratios
    
    for a = 1 : K
       for b = 1 : nIntBlocks
         dataBlock= sprDecExtrLLR(a,(intBlockSize*(b-1)+1):intBlockSize*b);
         eseApLLR(a,(intBlockSize*(b-1)+1):intBlockSize*b)=Interleaver(dataBlock,intrMatrix(a,:));
       end
    end 
   
    
end
end

