function [spreadedData] = spreader( inputData , c )

%function to implement the spreader where the "inputData" is the low rate
%unspreaded symbols and the "spreadedData" is the higher bandwidth\rate
%output 
%c is the spreading code used 

sf=length(c);
n=length(inputData) ;
spreadedData = repmat( inputData ,[sf,1] );
spreadedData = reshape( spreadedData ,[1, sf*n]) ;
   
%multiplying each symbol with the spreading code 
spreadedData = spreadedData.*repmat(c,[1,n]);




end

