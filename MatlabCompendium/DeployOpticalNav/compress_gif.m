gif_name = "animation_chipsat_compressed";
fld_name = "modeling_chipsat";
for i = 1:1000  % Сколько картинок обработать
    I = imread("local/"+ fld_name + "/" + string(i) + ".jpg");
    % Animation + pic saving
    if mod(i - 1, 3) == 0
        img = imresize(I,0.3);
        [img,cmap] = rgb2ind(img,256);
        if i == 1
            imwrite(img,cmap,"local/"+gif_name+".gif",'gif','LoopCount',Inf,'DelayTime',0.001);
        else
            imwrite(img,cmap,"local/"+gif_name+".gif",'gif','WriteMode','append','DelayTime',0.001);
        end        
    end
end

%% 
gif_name = "animation_starlink_compressed";
fld_name = "modeling_starlink";
for i = 1:51  % Сколько картинок обработать
    I = imread("local/"+ fld_name + "/" + string(i) + ".jpg");
    % Animation + pic saving
    if mod(i - 1, 3) == 0
        % img = imresize(I,0.3);
        img = I;
        [img,cmap] = rgb2ind(img,256);
        if i == 1
            imwrite(img,cmap,"local/"+gif_name+".gif",'gif','LoopCount',Inf,'DelayTime',0.3);
        else
            imwrite(img,cmap,"local/"+gif_name+".gif",'gif','WriteMode','append','DelayTime',0.3);
        end        
    end
end