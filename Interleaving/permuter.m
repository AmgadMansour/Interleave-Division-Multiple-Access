function [ randPerm ] = permuter(m)
%function to implement the permuter which is a device that generates random
%permutation of given memory addresses

%"m" : The length of the random permutation

perm=1:m;

for i=1:m
    r=randi(m-i+1); %pseudorandom scalar integer between 1 and m.
    randPerm(i)=perm(r);
    perm(r)=[]; %removing index to avoid repetition
end



end

