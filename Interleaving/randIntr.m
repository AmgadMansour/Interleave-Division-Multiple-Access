function [ randIntr ] = randIntr(n,m)
%Function to generate a Matrix of "n" random Interleavers each of length "m"

for i=1:n
    randIntr(i,:)= permuter(m);
end


end

