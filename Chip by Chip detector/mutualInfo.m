function [ I ] = mutualInfo( L )
% The function takes Log Likelhood Ratios as an input and gives the Mutual
% Information based on a GF(2)

I= sum(abs(1-log2(1+exp(-1.*L))))./length(L);





end

