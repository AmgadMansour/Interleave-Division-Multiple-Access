function [despreadedData] = despreader( spreadedData , c )

%function to implement the despreader where the "spreadedData" is the high rate
%spreaded symbols and the "despreadedData" is the low bandwidth\rate
%output 
%c is the spreading code used 


%reshape the spreadedData such that each row represents a symbol
sf=length(c);
n = length(spreadedData)/sf ;
spreadedData = reshape(spreadedData,[sf,n]);  
spreadedData= transpose(spreadedData);

%despreading each symbol
c = repmat(c, [n,1] ) ;
tmp = spreadedData.*c;
despreadedData= sum (transpose(tmp)) ;
    

    
end




