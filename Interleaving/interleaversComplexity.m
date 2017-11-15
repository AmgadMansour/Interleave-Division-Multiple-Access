clc;
clear all;
close all;
%% Comparing complexity on Interleavers based on the number of interleavings required per user 
nUsers= 1:1:100;

%% For random Interleavers
nIntr_Random= nUsers;

%% For Power Interleavers "Master Random Interleavers"
%For user 1, only one Interleaving process is required, For user 2 two
%Interleaving processes are required and so on, so the number of 
%Interleavings required for a given number of users =1+2+3+...+n = n(n+1)/2

nIntr_Power= (nUsers.*(nUsers+1))./2 ;

%% For tree based Interleavers
%Each level "L" adds (2^L)*L Interleavings
%For example first level adds (2^1)*1 Interleavings, second
%level adds (2^2)*2 interlavings and so on..
%           Check the tree structure of tree based interleavers for more
%           information.

nIntr_Tree=zeros(1,100);
n= nUsers;
for i=1:100
L=1;
while(n(i)-(2^(L))>0)
    nIntr_Tree(i)= nIntr_Tree(i) + (2^(L)*L);
    n(i)=n(i)-(2^(L));
    L=L+1;
end
nIntr_Tree(i)= nIntr_Tree(i) + (L*n(i));
end



%% plotting complexity versusu number of users 
figure();

plot(nUsers,nIntr_Random./nUsers,nUsers,nIntr_Power./nUsers,nUsers,nIntr_Tree./nUsers);
legend('Random Interleaver','Power Interleaver','Tree Based Interleaver','Location','best');
xlabel({'Number Of Users'});
ylabel({'Interleaver Complexity (No. of Interleavings/user)'});
title({'Comparing complexity of the implemented interleavers'});

tmp=nIntr_Random./nUsers;
tmp(1,5)
tmp=nIntr_Power./nUsers;
tmp(1,5)
tmp=nIntr_Tree./nUsers;
tmp(1,5)





