function [ chanOutput] = channel( inputData , L , H )
%function to simulate effect of a multipath channel
%inputData: Matrix where each row represents each single user
%           transmitted  data, K is the number of active users.
%                   (I1)1  (I1)2  .  .  .  (I1)N      
%                   (I2)1  (I2)2  .  .  .  (I3)N   
%                         .
%                         .
%                   (IK)1  (IK)2  .  .  .  (IK)N 


%H: channel coefficents for all K users in an L-Taps channel, where (h1)1
%   is the first user line of sight channel coefficent, (h1)2 is the first
%   user second path channel coefficent and so on.
%       (h1)1 (h2)1 (h3)1 .... (hK)1
%       (h1)2 (h2)2 (h3)2 .... (hK)2
%                    .
%                    .
%       (h1)L (h2)L (h3)L .... (hK)L

%chanOutput: Matrix where each row represents the channel output for each
%            user after passing through a single or multipaths channel
%            according to the channel responeses H
%                   (C1)1  (C1)2  .  .  .  (C1)N      
%                   (C2)1  (C2)2  .  .  .  (C3)N   
%                         .
%                         .
%                   (CK)1  (CK)2  .  .  .  (CK)N 



[ nUsers , N ] = size(inputData) ;

for i = 1 : nUsers
    
    d = zeros(1,N+L-1) ;
    
    for j = 1 : L
    
    currentPath=zeros(1,N+L-1);
    currentPath(j:(j+N-1)) = inputData(i,:) ;
    
    %current channel weight       
    w=H(j,i);    
    d = d + w.*currentPath ;
  
    end
     chanOutput(i,:)=d ;
     
end


%% Test Unit
%3 users each with 4 bits in a 3 paths channel
%inputData: [1 0 1 1 ; 1 1 1 0 ; 0 1 1 1 ];
%L=3;
%H= [ 1 2 1 ; 1 3 1; 0 2 1]
%Theoriticaly tested output :          1     1     1     2     1     0
%                                      2     5     7     5     2     0
%                                      0     1     2     3     2     1

    
end

