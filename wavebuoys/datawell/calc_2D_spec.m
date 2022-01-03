%calcualte 2D spec from "waves" matlab structure save for each month

%calculate 2D sepc using MEM (Lygre and Krogstad, 1986 JPO) 
[NS, NE, ndirec] = lygre_krogstad_MC(waves.a1(ii,:),waves.a2(ii,:),waves.b1(ii,:),waves.b2(ii,:),waves.E(ii,:),1);
%NS=normalized
% NE=un-normalized
% ndirec=directional space

[waves.ndirec,I] = sort(ndirec); %sort 
NS = NS(:,I);
NE = NE(:,I);     

%plot normalized spectra
make_MEM_plot_no_save(waves.ndirec, waves.freq, NE, waves.hs(ii,1), waves.tp(ii,1), waves.dp(ii,1), waves.timewave(ii,1));
    