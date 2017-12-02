
%% OFDM demodulation visualization
refresh_time = length(Rx)/nb_data_packets/fs;
subplot(2,2,2);colormap(colorMap); image(imageData); axis image; title('Transmitted image'); drawnow;
elapsedtime = 0;
for k = 1:nb_data_packets
    elapsedtime = elapsedtime + refresh_time;
    if (k==nb_data_packets)
        bitstreamend = length(rxBitStream);
    else
        bitstreamend = (k*(N/2-1)*(L_d)*N_q);
    end
    hk = ifft(H_est(:,k));
    if (k == 1)
        minh = min(hk)*1.10;
        maxh = max(hk)*1.10;
        minH = min(min(abs(H_est)))*1.10;
        maxH = max(max(abs(H_est)))*1.10;
    end

    subplot(2,2,1);plot(hk);title('Channel in time domain');ylim([minh,maxh])
    subplot(2,2,3);semilogy(linspace(0,fs/2,(N/2)),abs([0;H_est(1:(N/2-1),k)]));
    title('Channel in frequency domain (No DC)'); ylim([minH,maxH]);
    imageRx = bitstreamtoimage(rxBitStream(1:bitstreamend), imageSize, bitsPerPixel);
    subplot(2,2,4);colormap(colorMap); image(imageRx); axis image; title('Received image after '+string(elapsedtime)+ ' seconds'); drawnow;
    
    pause(refresh_time);
end


