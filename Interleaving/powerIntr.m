function [ intr ] = powerIntr(M,k)
%Function to generate user specific interleaver based on master random
%interleavers method as follows :

%"M" is the ideal random permutation chosen as our master Inteleaver
%I1=M=@(c)
%I2=@(@(c))
%I3=@(@(@(c)))

%"K" The power index assigned by the base station to each user k and then
% "@k" will be generated at the mobile station for user k accordingly, 


% This process of generating patterns increases the performance in the term
% of information that has to be sent by the BS to MS, thus more efficent
% use of bandwidth. It also reduces the memory cost in comparison
% to random interleavers.

intr=M;

for i=2:k
    intr=Interleaver(intr,M);
 
end


end
