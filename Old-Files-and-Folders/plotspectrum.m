function done = plotspectrum(nucleus,varargin)
if strcmpi('h',nucleus) == 1;
        frequency = 599.72; %Mhz
        xmin=-2;
        xmax=11.6;
else if strcmpi('c',nucleus) == 1;
        frequency = 150.8; %Mhz
        xmin=-30;
        xmax=180;
else
    display('Not a correct entry')
    end
end
figure; set(gca,'XDir','reverse')
hold on
for i = 1:length(varargin)
    spectrum = varargin{i};
    plot(spectrum(:,1)/frequency,spectrum(:,2),'b','Linewidth',2)
    title('Metabolite Profile')
    xlabel('PPM')
    ylabel('Amplitude')
    xlim([xmin,xmax])
end
done=1;
% Changed