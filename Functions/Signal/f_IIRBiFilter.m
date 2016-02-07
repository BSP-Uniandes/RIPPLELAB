% function f_IIRBiFilter.m
% 
function v_FiltSig = ...
    f_IIRBiFilter( ...
    pv_Sig, ...
    pv_H1, ...
    pv_H2)

    if nargin < 2
        error('[f_IIRBiFilter] - ERROR: bad parameters!')
    end

    if size(pv_Sig, 1) == 1
        pv_Sig = pv_Sig(:);
    end
    
    v_FiltSig = filter(pv_H1, pv_Sig);
    v_FiltSig = filter(pv_H1, flipud(v_FiltSig));
%     v_FiltSig = flipud(v_FiltSig);

    if exist('pv_H2', 'var') && ~isempty(pv_H2)
        v_FiltSig = filter(pv_H2, v_FiltSig);
        v_FiltSig = filter(pv_H2, flipud(v_FiltSig));
%         v_FiltSig = flipud(v_FiltSig);
    else
        v_FiltSig = flipud(v_FiltSig);
    end
  
return;
