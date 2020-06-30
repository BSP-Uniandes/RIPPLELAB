function memStats = memoryInfo()
    % Cross-platform function to get memory usage
    % 
    % @author Sviatoslav Danylenko <dev@udf.su>
    % @license BSD
    %
    % Return values:
    % memStats: memory info @type struct.
    %
    % The following is the fields of memStats:
    % free: the amount of free memory in kB
    % swap: the struct with info for swap (paging) file in kB
    %   swap.usedMatlab: the total amount of by current MATLAB process used swap
    %   swap.used: the total amount of used swap
    %   swap.total: the total amount of used swap
    %   swap.free: the total amount of used swap
    % total: the total amount of memory in kB
    % used: the total amount of used memory in kB
    % cache: the total amount of memory used for cache in kB
    % usedMatlab: the maount of by current MATLAB process used memory in kB
    
    % Commands List for Unix:
    %  Get process memory usage:
    %   ps -p <PID> -o rss --no-headers
    %  Get process memory and swap usage in separate rows:
    %   awk '/VmSwap|VmRSS/{print $2}' /proc/<PID>/status
    %  Get memory usage information:
    %   free -m | sed -n ''2p''
    
    memStats = struct('total', false, ...
        'free', false, ...
        'used', false, ...
        'cache', false, ...
        'usedMatlab', false, ...
        'swap', struct('total', false, ...
            'free', false, ...
            'used', false, ...
            'usedMatlab', false)...
        );
    if ismac % Included by Miguel Navarrete 20-may-2016
        try
        [s,m]   = unix('vm_stat | grep free');
        spaces  = strfind(m,' ');
        memStats.free = str2num(m(spaces(end):end))*4096;
        memStats.free = bytes2kBytes(memStats.free);
        catch err 
            memStats.free = NaN;
        end
        
    elseif isunix
        pid = feature('getpid');
        
        [~, usedMatlab] = unix(['awk ''/VmSwap|VmRSS/{print $2}'' /proc/' num2str(pid) '/status']);
        try
            usedMatlab = regexp(usedMatlab, '\n', 'split');
            memStats.usedMatlab = str2double(usedMatlab{1});
            memStats.swap.usedMatlab = str2double(usedMatlab{2});
        catch err %#ok
        end
        
        [~, memUsageStr] = unix('free -k | sed -n ''2p''');
        try
            memUsage = cell2mat(textscan(memUsageStr,'%*s %u %u %u %*u %*u %u','delimiter',' ','collectoutput',true,'multipleDelimsAsOne',true));
            memStats.total = memUsage(1);
            memStats.used = memUsage(2);
            memStats.free = memUsage(3);
            memStats.cache = memUsage(4);
        catch err %#ok
        end
        
        
        [~, swapUsageStr] = unix('free -k | tail -1');
        try
            swapUsage = cell2mat(textscan(swapUsageStr,'%*s %u %u %u','delimiter',' ','collectoutput',true,'multipleDelimsAsOne',true));
            memStats.swap.total = swapUsage(1);
            memStats.swap.used = swapUsage(2);
            memStats.swap.free = swapUsage(3);
        catch err %#ok
        end
    else
        [user, sys] = memory;
        memStats.usedMatlab = bytes2kBytes(user.MemUsedMATLAB);
        memStats.total = bytes2kBytes(sys.PhysicalMemory.Total);
        memStats.free = bytes2kBytes(sys.PhysicalMemory.Available);
        memStats.used = memStats.total - memStats.free;
        freeMemWithSwap = bytes2kBytes(sys.SystemMemory.Available);
        freeSwap = freeMemWithSwap - memStats.free;
        memStats.swap.free = freeSwap; % swap available for MATLAB
%         memStats.swap.free = bytes2kBytes(sys.VirtualAddressSpace.Available);
        memStats.swap.total = bytes2kBytes(sys.VirtualAddressSpace.Total);
        memStats.swap.used = memStats.swap.total - memStats.swap.free;
    end
    
end

function kbytes = bytes2kBytes(bytes)
    % bytes to kB konversion
    kbytes = round(bytes/1024);
end