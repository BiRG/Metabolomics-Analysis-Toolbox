function reproduce_improper_assignment( )
%Reproduce the improper assignment error that killed my test run

peaks = GaussLorentzPeak([1,.02,1,0.5,   1,.02,1,0.500000001]);
spec.x = 0:0.0001:1;
spec.Y = sum(peaks.at(spec.x),1)';
[b,~,~]=deconv_initial_vals_dirty(spec.x, spec.Y, 0,1,[0.5, 0.500000001], ...
    0.04, 12, 75, @do_nothing);
dec=GaussLorentzPeak(b);
plot(spec.x, dec(1).at(spec.x), spec.x, dec(2).at(spec.x));
end

