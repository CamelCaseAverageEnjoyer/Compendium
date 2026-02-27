function G = antenna_gain(theta,antennatype)
    %ATNENNA_GAIN рассчитывает направленные потери мощности сигнала
    %   ВНИМАНИЕ: Для рассчёта RSS далее умножается на пол. потери!            
    if antennatype == "short monopole"
        G = sin(theta).^2;
    elseif antennatype == "half-wave monopole"
        G = cos(pi/2 * cos(theta)).^2 ./ sin(theta).^2;
    elseif antennatype == "sin3"
        G = abs(sin(theta).^3);
    else
        G = 1;
    end
end