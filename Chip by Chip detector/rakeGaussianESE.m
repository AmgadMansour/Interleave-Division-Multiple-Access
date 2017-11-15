function [ extrLLR ] = rakeGaussianESE(R,apLLR, H, noiseVar )
%Function to implement the Elementary Signal Estimator Block for a
%multipath muliple access channel based on the the Rake gaussian approach
%to combine information about the current user k symbol "(Xk)j" from the
%received composite symbols in which we can observe "(Xk)j".

%For example: In a 3-paths channel, user 1 symbol 1 "(X1)1" can be
%             observed in the recieved composite symbols "R(1),R(2),R(3)" 
%             so it makes since to make an estimate of "(X1)1" based
%             on these observations, where R(1)and R(3) are the first and
%             the third received cmposite symbols respectively.

%R: composite received symbols block at the receiver input, where r1 is the
%   first received symbol and r(N+L-1) is the last one, putting into
%   consideration that more symbols are added due to the delay caused by
%   the multipaths channel.
%       r1 r2 r3 ... r(N+L-1) 

%apLLR: Matrix represnting the a priori logarithm likelihood ratios about
%       each user k symbol "ap(Xk)j", where j is the current symbol index,
%       N is the block size, K is number of active users in the system.
%      ap(X1)1  ap(X1)2  ...  ap(X1)N
%      ap(X2)1  ap(X2)2  ...  ap(X2)N 
%      ap(X3)1  ap(X3)2  ...  ap(X3)N
%                 .
%                 .
%      ap(XK)1  ap(XK)2  ...  ap(XK)N
 
%H: channel coefficents for all K users in an L-Taps channel, where (h1)1
%   is the first user line of sight channel coefficent, (h1)2 is the first
%   user second path channel coefficent and so on.
%       (h1)1 (h2)1 (h3)1 .... (hK)1
%       (h1)2 (h2)2 (h3)2 .... (hK)2
%                    .
%                    .
%       (h1)L (h2)L (h3)L .... (hK)L

%noiseVar: variance of the AWGN



%Mean of each user symbol
avgX = tanh(apLLR./2);
%      avg(X1)1  avg(X1)2  ...  avg(X1)N
%      avg(X2)1  avg(X2)2  ...  avg(X2)N 
%      avg(X3)1  avg(X3)2  ...  avg(X3)N
%                 .
%                 .
%      avg(XK)1  avg(XK)2  ...  avg(XK)N

%Variance of each user symbol
varX = 1-(avgX).^2;

%Mean of each composite received symbol
[K N]= size(apLLR);
[L K]= size(H);

Htmp = flipud(H);
avgXtmp = cat(1,cat(1,zeros(L-1,K),transpose(avgX)),zeros(L-1,K));

for i= 1:(N+L-1)

    avgR(1,i)= sum(transpose(sum(Htmp.*avgXtmp(i:(i+L-1),:))));
end

avgR;
%Variance of each composite received symbol
Htmp = abs(Htmp).^2;
varXtmp = cat(1,cat(1,zeros(L-1,K),transpose(varX)),zeros(L-1,K));

for i= 1:(N+L-1)
    varR(1,i)= sum(transpose(sum(Htmp.*varXtmp(i:(i+L-1),:))));
end
varR= varR+ noiseVar;
varR;
% Simplifying the expression as stated in the report to "2(h(k,L))(a/b)" for each delay
% where "h(k,L)" is the corresponding delay channel response of the current user
extrLLR= zeros(K,N);

for i=1:L
    a= repmat((R(1,i:(i+N-1))-avgR(1,i:(i+N-1))),K,1)+(repmat(H(i,:).',1,N).*avgX);
    b= repmat(varR(1,i:(i+N-1)),K,1)-(repmat(abs(H(i,:).').^2,1,N).*varX);
    extrLLR= extrLLR+ 2*repmat(H(i,:).',1,N).*(a./b);
end

%                The Algorithm was tested manually through the theoritical
%                calculations found in the attached report and was found to
%                provide the same output.








end

