function [ I ] = treeInt( M1, M2, k )
%Function to generate user "k" specific interleaver based on tree based
%interleavers method as follows :

%Two randomly generated interleavers, "M1" and "M2" are chosen, they are both
%known by the base station and mobile station.
%These interleavers are tested to have zero cross correlation between each
%other.

%The allocation of the interleaving mask to the user "k" uses a particular
%combination of the two master interleaers that follow the tree format as
%shown in the attached report and there after data is intelreaved accordingly.

%First check if the two assigned random interleavers are orthogonal
%if(intCC(M1,M2)~=0)
 %   disp('INVALID MASTER INTERLEAVERS, please enter an orthogonal interleaver pair');
%else
    
%According to user "K", level(L) of tree is determined
tmp=k;
L=0;
while(tmp>0)
    tmp=tmp-(2^(L+1));
    L=L+1;
end

%Determine the starting index(si) of level(L)
si=0;
for j=0:(L-1)
    si=si+(2^j);
end


%Generating Interleaving sequence
m=L;
I=1:length(M1);
for i=1:m
    
   tmp=k-(2^(L-1));
  
   %if the tmp calaculated index >= starting index that means it is a left
   %branch otherwsie it is right branch
   if(tmp>=si)
       I=Interleaver(I,M2);
       k=k-(2^L);
   else
       I=Interleaver(I,M1);
       k=k-(2^(L-1));
   end
   
   L=L-1;
   si=si-(2^L);
   
     
end
    
%end




end

