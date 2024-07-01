function  [zup] = ZeroUpX3(eta, dt)
%
% Calculate significant wave height Hs and mean period Tz based on zero
% upcrossing of the wave record eta. Also obtain individual wave heights 
% and periods, crests and troughs.
%
% Basically the same as ZeroUpX2, with the addition of Crests and Troughs
%
%Originally by Adi K (UWA-Albany). 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

k = 1:(length(eta)-1);
p = find(sign(eta(k)) <= 0 & sign(eta(k+1)) > 0); % indices of zero upcrossings

n = length(p)-1;
zup.Periods = zeros(n, 1);
zup.Heights = zeros(n, 1);
zup.Crests = zeros(n, 1);
zup.Troughs = zeros(n, 1);

for m = 1:n
%     ts = interp1([eta(p(m)) eta(p(m)+1)], dt * [p(m) p(m)+1], 0);
%     te = interp1([eta(p(m+1)) eta(p(m+1)+1)], dt * [p(m+1) p(m+1)+1], 0);

    % Linear interpolation to get zero-upcrossing times
    ts = dt * (p(m) - eta(p(m)) / (eta(p(m)+1) - eta(p(m))));
    te = dt * (p(m+1) - eta(p(m+1)) / (eta(p(m+1)+1) - eta(p(m+1))));
    zup.Periods(m) = te - ts; % wave period
    
    maxpos = max(eta(p(m)+1 : p(m+1)));
    maxneg = min(eta(p(m)+1 : p(m+1)));
    zup.Heights(m) = maxpos - maxneg; % wave height
    
    zup.Crests(m) = maxpos; % crest
    zup.Troughs(m) = maxneg; % trough
end

SortedH = sort(zup.Heights, 'descend');
% significant wave height according to traditional definition, i.e.
% average of the largest 1/3 of the wave heights. Note that the current 
% definition is Hs = 4 * std(eta).
zup.Hs = mean(SortedH(1:round(numel(zup.Heights)/3)));

% mean zero-upcrossing wave period
zup.Tz = mean(zup.Periods);
end

