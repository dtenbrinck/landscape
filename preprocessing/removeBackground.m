function data = removeBackground( data )
%REMOVEBACKGROUND Summary of this function goes here
%   Detailed explanation goes here

% TODO: Test best size of structuring element experimentally!

% Generate structural elements for preprocessing
struct_element_small = strel('disk',11);
struct_element_big = strel('disk',53);

% preprocess Dapi data
data.Dapi = imtophat(data.Dapi, struct_element_small);

% preprocess GFP data
data.GFP = imtophat(data.GFP, struct_element_big);

% preprocess mCherry data
data.mCherry = imtophat(data.mCherry, struct_element_small);
end

