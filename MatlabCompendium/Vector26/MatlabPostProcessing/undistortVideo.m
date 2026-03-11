%% Камера 1
path1 = '../PythonPreProcessing/local/videos/cam1/';
path2 = '../PythonPreProcessing/local/videos/cam1_undistort/';

load("local/camcal/cameraParams_cam1.mat")

for i=1:12768
     filename = ['img' sprintf('%05d', i) '.jpg'];
     try
         frame_dist = imread([path1 filename]);
         frame_undist = undistortImage(frame_dist,cameraParams_cam1); 
         imwrite(frame_undist, [path2 filename])
     catch
         disp(['File ' path1 string(filename) ' do not exists'])
     end
end

%% Камера 2
path1 = '../PythonPreProcessing/local/videos/cam2/';
path2 = '../PythonPreProcessing/local/videos/cam2_undistort/';

load("local/camcal/cameraParams_cam2.mat")

for i=1:13286
     filename = ['img' sprintf('%05d', i) '.jpg'];
     try
         frame_dist = imread([path1 filename]);
         frame_undist = undistortImage(frame_dist,cameraParams_cam2); 
         imwrite(frame_undist, [path2 filename])
     catch
         disp(['File ' path1 string(filename) ' do not exists'])
     end
end

%% Камера 3
path1 = '../PythonPreProcessing/local/videos/cam3/';
path2 = '../PythonPreProcessing/local/videos/cam3_undistort/';

load("local/camcal/cameraParams_cam3.mat")

for i=7984:15964
     filename = ['img' sprintf('%05d', i) '.jpg'];
     try
         frame_dist = imread([path1 filename]);
         frame_undist = undistortImage(frame_dist,cameraParams_cam3); 
         imwrite(frame_undist, [path2 filename])
     catch
         disp(['File ' path1 string(filename) ' do not exists'])
     end
end