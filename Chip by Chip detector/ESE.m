function [ extrLLR ] = ESE( R, apLLR, H, noiseVar   )
%Function to implement the Elementary Signal Estimator Block for a single
%path muliple access channel

%R: composite received symbols block at the receiver input, N is th length of encoded data.
%       r1 r2 r3 ... rN       For single path channel

%H: channel coefficents for all users
%       h1 h2 h3 .... hK

%noiseVar: variance of the AWGN

%apLLR: Matrix represnting the ESE a priori logarithm likelihood ratios about
%       each user k symbol "ap(Xk)j", where j is the current symbol index,
%       N is the length of spreaded encoded symbols, K is number of active users in the system.
%      ap(X1)1  ap(X1)2  ...  ap(X1)N
%      ap(X2)1  ap(X2)2  ...  ap(X2)N 
%      ap(X3)1  ap(X3)2  ...  ap(X3)N
%                 .
%                 .
%      ap(XK)1  ap(XK)2  ...  ap(XK)N
    


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

avgR=sum(transpose((avgX.').*repmat(H,N,1)),1);

    
%      avg(r1) avg(r2) avg(r3) ... avg(rN) 

%Variance of each composite received symbol

varR=sum(transpose((varX.').*repmat(abs(H).^2,N,1)),1)+ noiseVar;



%      var(r1) var(r2) var(r3) ... var(rN) 

%extrLLR: Matrix represnting the extrinsic logarithm likelihood ratios about
%         each user k symbol "ext(Xk)j",where j is the current symbol index,
%         N is the the length of spreaded encoded symbols, K is number of active users in the system.
%      ext(X1)1  ext(X1)2  ...  ext(X1)N
%      ext(X2)1  ext(X2)2  ...  ext(X2)N 
%      ext(X3)1  ext(X3)2  ...  ext(X3)N
%                 .
%                 .
%      ext(XK)1  ext(XK)2  ...  ext(XK)N


% Simplifying the expression as stated in the report to "2(hk)(a/b)" where 
% "hk" is the corresponding channel response of the current user



a= repmat((R-avgR),K,1)+(repmat(H.',1,N).*avgX);
b= repmat(varR,K,1)-(repmat(abs(H.').^2,1,N).*varX);
extrLLR= 2*repmat(H.',1,N).*(a./b) ;



%% Test Unit
%3 users each with 4 bits in a single path channel
%R: [ 1 3 0.5 4] received composite symbols 
%H= [ 1 2 1 ]
%apLLR= [0.5 1 2.5 3 ; 1 1 2 3 ; -0.5 2 -2 1 ] 
%noiseVar = 2
%Theoriticaly tested output :          0.1054    0.4722   -0.1276    0.9846
%                                      1.0309    2.2159    0.6122    3.5492
%                                     -0.0556    0.5440   -0.9451    0.8848









               




end

