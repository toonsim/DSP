
%% OFDM demodulation visualization
refresh_time = length(Rx)/nb_data_frames/fs;
subplot(2,2,2);colormap(colorMap); image(imageData); axis image; title('Transmitted image'); drawnow;
elapsedtime = 0;
Hbad = zeros(N/2,1);
for k = 1:nb_data_frames
    elapsedtime = elapsedtime + refresh_time;
    if (k==nb_data_frames)
        bitstreamend = length(rxBitStream);
    else
        bitstreamend = (k*(N/2-1-N_bad)*N_q);
    end
    hk = ifft(H_est(:,k)/N);
    Hk = H_est(1:N/2,k)/(N/2);
    if (k == 1)
        minh = min(hk)*1.10;
        maxh = max(hk)*1.10;
        minH = 1e-6;
        maxH = 1;
    end
    
    subplot(2,2,1);plot(hk);title('Channel in time domain');ylim([minh,maxh]);xlabel('samples');
    
    
    Hbad(bad_carriers) = Hk(bad_carriers);
    
    
    f = linspace(0,fs/2,(N/2));
    subplot(2,2,3);semilogy(f,abs(Hk));hold on;semilogy(f,abs(Hbad));hold off;ylabel('Magnitude [dB]');xlabel('frequency [Hz]')
  
    title('Channel in frequency domain (No DC)'); ylim([minH,maxH]);
    
    imageRx = bitstreamtoimage(rxBitStream(1:bitstreamend), imageSize, bitsPerPixel);
    
    subplot(2,2,4);colormap(colorMap); image(imageRx); axis image; title('Received image after '+string(elapsedtime)+ ' seconds'); drawnow;
    
    pause(refresh_time);
end


