function [ intrSeq ] = Interleaver( seq, perm )
%function to implement the interleaver block where :
%"seq" : input sequence to be interleaved 
%"perm" : random permutation

% Example :
%seq: [ a b c d e ]
%perm: [ 2 5 1 3 4 ]
%intrSeq: [ b e a c d]
%So @1=3, @2=1, @3=4, @4=5, @5=2, where "@" represents mapping of the
%interleaver

for i=1:length(seq)
    intrSeq(i)=seq(perm(i));
end



end

