function [ encDataRM, rm_not_null,cc, rm,h_rm ] = turboEncode(inputData, codeRate,genPoly, feedbPoly, constrLength, blockSize )
%Function to apply the turbo encoder using the link level simulator.


%inputData: Matrix where each row represents each single user input binary
%encDataRM: Matrix where each row represents each single user encoded binary data
%constrLength: constraint length of the encoder (memory length + 1)
%genPoly: generator polynomial of the encoder (octal value)
%feedbPoly: feedback polynomial of the encoder (octal value)
%blockSize: Size of each input binary data block
%encBlockSizeRM: Size of each encoded block data
%codeRate: Turbo Encoder rate


cc.use= 'turbo';
cc.constr_length= constrLength; 
cc.gen_poly= genPoly; 
cc.feedb_poly= feedbPoly; 
cc.intlvr_source= 'constructor';
cc.intlvr_idc= getLteInterleaverIdc(blockSize);                                  
turboEnc = CcTurboEncMex(cc);
% Rate matcher
rm.use       = true;
rm.source    = 'step'; 
rm.tbs       = []; 
rm.code_rate = codeRate;
h_rm = RmLteEnc(rm);

[nUsers nBits]=size(inputData);
nBlocks= nBits/blockSize;
encBlockSizeRM= (1/codeRate)*(blockSize);

for i = 1 : nUsers
    for j = 1 : nBlocks
         dataBlock= inputData(i,(blockSize*(j-1)+1):blockSize*j); 
         encBlock= turboEnc.step(transpose(dataBlock));
         [encDataRM(i,(encBlockSizeRM*(j-1)+1):encBlockSizeRM*j), rm_not_null]= h_rm.step(transpose(encBlock), blockSize, codeRate);
    end
end
end

