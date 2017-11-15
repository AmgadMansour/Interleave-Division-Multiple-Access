clc;
clear all;
close all;
%% Comparing memory requirement of Interleavers based on the number of bits required per user 
nUsers= 1:1:100;
blockSize=256;

%% For random Interleavers
%Each user saves the whole package of interleavers used in the system even
%for all the other users. The base station communicates the user index
%then user specific interleaver is assigned based on the given index.

mem_Random= nUsers.*nUsers.*(log2(blockSize)*blockSize);



%% For Power Interleavers "Master Random Interleavers"
%For all users we need to store only the master random interleaver

mem_Power= nUsers.*(log2(blockSize)*blockSize)  ;

%% For tree based Interleavers
%For all users we need to store only the two main interleavers

mem_Tree= nUsers.*(2*log2(blockSize)*blockSize)  ;

%% plotting memory requirement versus number of users 
figure();

plot(nUsers,mem_Random./nUsers,nUsers,mem_Power./nUsers,nUsers,mem_Tree./nUsers);
legend('Random Interleaver','Power Interleaver','Tree Based Interleaver','Location','best');
xlabel({'Number Of Users'});
ylabel({'Memory requirement (No. of bits/user)'});
title({'Comparing memory requirement of the implemented interleavers'});
tmp=mem_Power./nUsers;
tmp(1,50)
tmp=mem_Random./nUsers;
tmp(1,50)
tmp=mem_Tree./nUsers;
tmp(1,50)
