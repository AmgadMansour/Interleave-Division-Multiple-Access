function [ deintrSeq ] = deInterleaver( intrseq, perm )
%function to implement the deinterleaver block where :
%"seq" : input sequence to be deinterleaved 
%"perm" : random permutation

% Example :
%intrseq: [ b e a c d ] 
%perm: [ 2 5 1 3 4 ]
%deintrSeq: [ a b c d e ]


for i=1:length(intrseq)
    deintrSeq(perm(i))=intrseq(i);
end



end


