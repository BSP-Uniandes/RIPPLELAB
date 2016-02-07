function sos = old_zp2sos(z,p,k,direction_flag)
%ZP2SOS Zero-pole-gain to second-order sections linear system model conversion.
%   SOS = ZP2SOS(Z,P,K) finds a matrix SOS in second-order sections form
%   which represents the same system as the one with zeros in vector Z, 
%   poles in vector P and gain in scalar K.  The poles and zeros must 
%   be in complex conjugate pairs.
%
%   ZP2SOS(Z,P,K,'down') orders the sections so that the first row of SOS 
%   contains the poles closest to the unit circle. Without the 'down' flag,
%   the sections are ordered in the other direction.
%
%   The output SOS is an L by 6 matrix which contains the coefficients 
%   of each second-order section in its rows:
%       SOS = [ b01 b11 b21  a01 a11 a21 
%               b02 b12 b22  a02 a12 a22
%               ...
%               b0L b1L b2L  a0L a1L a2L ]
%   The pole-zero conjugate pairs which are closest to each other are 
%   arranged into the same 2nd-order section.  Furthermore, the numerator
%   coefficients of each section are scaled so that the maximum of the
%   magnitude of the DTFT of the cascade is very close to 1.
%
%   The system transfer function is the product of the second-order transfer
%   functions of the sections.  Each row of the SOS matrix describes
%   a 2nd order transfer function as
%           b0k +  b1k z^-1 +  b2k  z^-2
%           ----------------------------
%           a0k +  a1k z^-1 +  a2k  z^-2
%   where k is the row index. 
%
%   See also SOS2ZP, SOS2TF, SOS2SS, SS2SOS, CPLXPAIR.

%   NOTE: restricted to real coefficient systems (poles  and zeros 
%             must be in conjugate pairs)

%   Author(s): T. Krauss, 1993
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 1997/12/02 18:36:59 $
 
narginchk(2,4)
if nargin == 2,
    k = 1;
    direction_flag = 'up';
elseif nargin == 3,
    direction_flag = 'up';
else  % nargin = 4
    if ~(strcmp(direction_flag,'up') || strcmp(direction_flag,'down')),
       error('The fourth argument to ZP2SOS must be either ''up'' or ''down''.')
    end
end

if isempty(k)
    sos = [];
    return
end

z = cplxpair(z); p = cplxpair(p);

L = max(max(ceil(length(z)/2), ceil(length(p)/2)),1);
sos = zeros(L,6);

% break up conjugate pairs and real poles
ind = find(abs(imag(p))>0);
p_conj = p(ind);   % the poles that have conjugate pairs
ind_complement = 1:length(p);
if ~isempty(ind)
    ind_complement(ind) = [];
end
p_real = p(ind_complement);    % the poles that are real

% order the conjugate pole pairs according to proximity to unit circle
[temp,ind] = sort(abs(p_conj - exp(j*angle(p_conj))));
p_conj = p_conj(ind);
% order the real poles according to proximity to unit circle too
[temp,ind] = sort(abs(p_real - sign(p_real)));
p_real = p_real(ind);

% construct denominators of 2nd order sections 
p = [p_conj(:); p_real(:)]; 
nr = length(p);    % number of roots 
if rem(nr,2),   % odd number of roots
    p1 = p(1:2:nr-1);
    p2 = p(2:2:nr-1);
    if nr > 1
        sos(1:(nr-1)/2,4:6) = [ones((nr-1)/2,1)  -(p1+p2)  p1.*p2];
    end
    sos((nr+1)/2,4:6) = [1  -p(nr) 0];
    if nr+1 < 2*L,
        sos((nr+3)/2:L,4:6) = [ones(L-(nr+1)/2,1) zeros(L-(nr+1)/2,2)];
    end
else            % even number of roots
    p1 = p(1:2:nr);
    p2 = p(2:2:nr);
    if nr > 0
        sos(1:nr/2,4:6) = [ones(nr/2,1)  -(p1+p2)  p1.*p2];
    end
    if nr+2 <= 2*L,
        sos(nr/2+1:L,4:6) = [ones(L-nr/2,1) zeros(L-nr/2,2)];
    end
end

% break up conjugate pairs and real zeros
ind = find(abs(imag(z))>0);
z_conj = z(ind);   % the zeros that have conjugate pairs
ind_complement = 1:length(z);
if ~isempty(ind)
    ind_complement(ind) = [];
end
z_real = z(ind_complement);    % the zeros that are real

% order the conjugate zero pairs according to proximity to pole pairs
new_z = [];
for i = 1:length(z_conj)/2,
    if ~isempty(p_conj),
        [temp,ind1] = min(abs(z_conj-p_conj(1)));
        [temp,ind2] = min(abs(z_conj-p_conj(2)));
        new_z = [new_z; z_conj(ind1); z_conj(ind2)];
        p_conj([1 2]) = [];
        z_conj([ind1 ind2]) = [];
    elseif ~isempty(p_real),
        [temp,ind] = min(abs(z_conj-p_real(1)));
        new_z = [new_z; z_conj(ind); z_conj(ind+1)];
        z_conj([ind ind+1]) = [];
        p_real(1) = [];
        if ~isempty(p_real),
            p_real(1) = [];
        end
    else
        new_z = [new_z; z_conj];
        break
    end
end

% order the real zeros according to proximity to pole pairs too
for i = 1:length(z_real),
    if ~isempty(p_conj),
        [temp,ind] = min(abs(z_real-p_conj(1)));
        new_z = [new_z; z_real(ind)];
        z_real(ind) = [];
        p_conj(1) = [];
    elseif ~isempty(p_real),
        [temp,ind] = min(abs(z_real-p_real(1)));
        new_z = [new_z; z_real(ind)];
        z_real(ind) = [];
        p_real(1) = [];
    else
        new_z = [new_z; z_real];
        break
    end
end

% construct numerators of 2nd order sections
z = new_z;
nz = length(z);    % number of zeros
if rem(nz,2),   % odd number of zeros
    z1 = z(1:2:nz-1);
    z2 = z(2:2:nz-1);
    if nz > 1
        sos(1:(nz-1)/2,1:3) = [ones((nz-1)/2,1)  -(z1+z2)  z1.*z2];
    end
    sos((nz+1)/2,1:3) = [1  -z(nz) 0];
    if nz+1 < 2*L,
        sos((nz+3)/2:L,1:3) = [ones(L-(nz+1)/2,1) zeros(L-(nz+1)/2,2)];
    end
else            % even number of zeros
    z1 = z(1:2:nz);
    z2 = z(2:2:nz);
    if nz > 1
        sos(1:nz/2,1:3) = [ones(nz/2,1)  -(z1+z2)  z1.*z2];
    end
    if nz+2 <= 2*L,
        sos(nz/2+1:L,1:3) = [ones(L-nz/2,1) zeros(L-nz/2,2)];
    end
end

% change direction if requested
if strcmp(direction_flag,'up'),
    sos = flipud(sos);
end

% now perform the scaling
sos(1,1:3) = k*sos(1,1:3);
G = ones(512,1);
cascade_gain = 1;
for N = 1:L-1,
    [H,f] = old_freqz(sos(N,1:3),sos(N,4:6),512);
    G = cascade_gain*(G.*H);
    max_G = max(abs(G));
    cascade_gain = 1/max_G; 
    sos(N,1:3) = cascade_gain*sos(N,1:3);
    sos(N+1,1:3) = sos(N+1,1:3)/cascade_gain;
end    
% overall_gain = prod(sos(:,1));
