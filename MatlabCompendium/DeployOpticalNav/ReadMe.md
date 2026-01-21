Отображение КА с метками и без. Навигация по меткам/граням КА.
> Проект для препринта-1 *"Оптическая навигация роя сверхмалых космических аппаратов при отделении".*
```
+graphics/
├── arrow3.m                    рисует 3D стрелку
├── myplot3.m                   рисует 3D линию по матрице (3,N)
├── show_aruco.m                отрисовывает метку из чёрных и белых квадратов
└── show_cube.m                 отрисовывает параллелипипед
+project_utils/
├── dynamics.m                  класс движения ХКУ
├── spacecraft.m                класс КА
└── unitVec.m                   делит вектор на его модуль
local/
├── camcal
|   └── ...                     картинки смоделированной шахматной доски для расчёта cameraParams
├── camcalcheck
|   └── ...                     картинки Aruco-метки для проверки cameraParams
├── modeling_chipsat
|   └── ...                     картинки движения КА с метками
├── modeling_starlink
|   └── ...                     картинки движения КА без меток
├── cameraPrams.mat             cameraParams         
├── video_edgeims.mat           для starlink2_video_progress.m
└── video_lines.mat             для starlink2_video_progress.m
camcal.m                        рассчёт и проверка cameraParams 
chipsat1_deploy.m               моделирование КА с метками
config.m                        основные параметры моделирования (в основном ChipSat)
starlink1_1st_frame_process.m   обработка 1-го кадра видео с YouTube
starlink2_video_process.m       обработка N кадров видео с YouTube
starlink3_model_video.m         моделирование КА без меток
```