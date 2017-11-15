function [ cc ] = intCC( int1,int2)
%Function to calaculate cross correlation between two interleavers as
%follows :

%Assume w and v are words of length L, and f notation represensts the
%spreading process in IDMA using an alternating sequence of +1 and -1 
%of length S ususally S>=64 as follows (+1,-1,+1,-1,..)  
%thus f(c) and f(w) both have length LS

%Let "@1" and "@2" be two interleavers and let "w" and "v" be two words we 
%define C(@1,w,@2,v) between @1 and @2 with respect to the words w and v as
%the scalar product between @1(f(w)) and @2(f(v))

%So two interleavers @1 and @2 are orthogonal, if for any two words w and v
%we have  C(@1,w,@2,v)=@1(f(w)).@2(f(v))=0

%generating spreading code
S=length(int1);
sc=repmat([1 -1],1,S/2);

%generating two random words
L=10;
w=randi(2,1,L)-1;
v=randi(2,1,L)-1;
w=2.*w-1;
v=2.*v-1;

%spreading 
fw=spreader(w,sc);
fv=spreader(v,sc);

%chip by chip interleaving for each symbol
for i=1:L
    %"b" is the symbol begining index
    b=1+S*(i-1);

    intfw(1,b:(b+S-1))=Interleaver(fw(1,b:(b+S-1)),int1);
    intfv(1,b:(b+S-1))=Interleaver(fv(1,b:(b+S-1)),int2);
end
cc=dot(intfw,intfv);


end

