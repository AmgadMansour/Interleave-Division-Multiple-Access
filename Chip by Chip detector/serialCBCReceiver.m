function [outData ] = serialCBCReceiver( R, H, sf, noiseVar, recItr, intrMatrix, hAppDec,codeRate)




[L K]= size(H);
N= length(R)-L+1;

eseApLLR= zeros(K,N); 

repCode= repmat([1 -1],1,sf/2);

[K intBlockSize]=size(intrMatrix);
nBlocks= N/intBlockSize


blockSize= (intBlockSize/sf)*codeRate ;

outData=zeros(K,blockSize);

for i=1:recItr

    
    for a=1:K

        
        ese= ESE(R, eseApLLR, H, noiseVar);
        size(ese)
        eseExtrBlock= ese(a,1:end);

        
        
         decApLLRBlock=deInterleaver(eseExtrBlock,intrMatrix(a,:));
         
         desDecApLLRBlock= despreader(decApLLRBlock, repCode);
         
         
         
       [outSoftData outLLR]= step(hAppDec,zeros(blockSize,1),transpose(desDecApLLRBlock)); 
        outSoftDataBlock= transpose(outSoftData);       
        outLLRBlock= transpose(outLLR);     


        outLLRBlock=desDecApLLRBlock;
        sprOutLLRBlock= spreader(outLLRBlock, repCode); 

        
        extOutLLRBlock= sprOutLLRBlock-decApLLRBlock;
        
        
        eseApLLR(a,1:end)=Interleaver(extOutLLRBlock,intrMatrix(a,:));


        
                if i== recItr
           outData(a,1:end)=double(outSoftDataBlock>0);
            
                end            
            
        end
        
        
    end


    
    

end




