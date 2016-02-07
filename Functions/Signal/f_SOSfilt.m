function v_SigFilt  = f_SOSfilt(pst_Filter,pv_Signal)

s_Scale                 = double(pst_Filter.G);
pst_Filter              = double(pst_Filter.SOS);
[s_SecNum,s_CoefNum]	= size(pst_Filter);

if s_CoefNum ~= 6
    error('[ERROR - f_sosfilt] - Filter Matrix is not SOS')
end
v_SigFilt	= double(pv_Signal);

for kk = 1:s_SecNum
    v_bCoef	= pst_Filter(kk,1:3);
    v_aCoef	= pst_Filter(kk,4:6);
    
    v_SigFilt   = filter(v_bCoef,v_aCoef,v_SigFilt);
end

% v_SigFilt	= v_SigFilt.*s_Scale;