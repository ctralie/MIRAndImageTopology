function r = shapexcorr(A,F,L)
% r = chromxcorr(A,F,L)
%   Cross-correlate two chroma ftr vecs in both time and
%   transposition
%   Both A and F can be long, result is full convolution
%   (length(A) + length(F) - 1 columns, in F order).
%   L is the maximum lag to search to - default 100.
%   of shorter, 2 = by length of longer
%   Optimized version.
% 2006-07-14 dpwe@ee.columbia.edu

%   Copyright (c) 2006 Columbia University.
% 
%   This file is part of LabROSA-coversongID
% 
%   LabROSA-coversongID is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License version 2 as
%   published by the Free Software Foundation.
% 
%   LabROSA-coversongID is distributed in the hope that it will be useful, but
%   WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with LabROSA-coversongID; if not, write to the Free Software
%   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
%   02110-1301 USA
% 
%   See the file "COPYING" for the text of the license.

if nargin < 3;  L = 100; end

[nshape,nbts1] = size(A);
[nshape2,nbts2] = size(F);

if nshape ~= nshape2
  error('Shape feature sizes dont match');
end

t=max(length(A), length(F))+2*L+1;
t2=ifft2(fft2(F, nshape, t).*conj(fft2(A, nshape, t)));
r = [t2(:,end-L+1:end) t2(:,1:L+1)];


% Normalize by shorter vector so max poss val is 1
r = r/min(nbts1,nbts2);
