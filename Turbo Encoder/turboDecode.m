function [ hardOutput extrLLRrm ] = turboDecode(encodedData, nIterations, encBlockSize, rm_not_null,cc,rm,h_rm )
%Function to apply the turbo decoder using the link level simulator.


%encodedData: Matrix where each row represents each single user encoded binary data
%nIterations: number of Turbo decoding iterations
%encBlockSize: size of each encoded block data
%hardOutput: hard decision output of the decoder
%extLLRrm: soft decision output of the decoder representing the extrinsic log likelhood 
%          ratios of each symbol 

cc.decoder_type= 'max_log_map';%'corr_log_map';%'max_log_map';
cc.crc_check= false;
cc.app_port= true;
cc.n_iterations= nIterations; 
turbo_dec = CcTurboDecMex(cc);
h_rdem = RmLteDec(rm);

codeRate=rm.code_rate;
[nUsers nEncBits]=size(encodedData);
nBlocks= nEncBits/encBlockSize;
dataBlockSize= encBlockSize*(codeRate);

for i = 1 : nUsers
    for j = 1 : nBlocks
         encdataBlock= encodedData(i,(encBlockSize*(j-1)+1):encBlockSize*j);
         encdataBlock_rdem = h_rdem.step(encdataBlock, dataBlockSize, rm_not_null);
         [hardOutput(i,(dataBlockSize*(j-1)+1):dataBlockSize*j) softLLR] = turbo_dec.step(-encdataBlock_rdem);
         
         
         [extrLLRrm(i,(encBlockSize*(j-1)+1):encBlockSize*j), rm_not_null_llr] = h_rm.step(softLLR, dataBlockSize, codeRate);
         
    end
end


end

