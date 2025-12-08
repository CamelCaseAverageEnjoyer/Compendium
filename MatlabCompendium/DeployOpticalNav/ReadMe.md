Проект для препринта-1 *"Оптическая навигация роя сверхмалых космических аппаратов при отделении".*
> Отображение КА с метками и без. Навигация по меткам/граням КА.
```
+graphics/
├── get_cube.m                  возвращает точки куба
└── show_aruco.m                отрисовывает метку из чёрных и белых квадратов
+utils/
├── dynamics.m                  класс движения ХКУ + угловое 
├── q2dcm.m                     матрица поворота из кватерниона
├── qdot.m                      кватернионное умножение
└── spacecraft.m                класс КА
local/
├── camcal
|   └── ...                     картинки смоделированной шахматной доски для расчёта cameraParams
├── camcalcheck
|   └── ...                     картинки Aruco-метки для проверки cameraParams
├── modeling
|   └── ...                     картинки движения без меток
├── cameraPrams.mat             cameraParams         
├── video_edgeims.mat           для ...
└── video_lines.mat             для ...
camcal.m                        рассчёт и проверка cameraParams 
chipsat1_deploy.m               моделирование КА с метками
starlink1_1st_frame_process.m   обработка 1-го кадра видео с YouTube
starlink2_video_process.m       обработка N кадров видео с YouTube
starlink3_model_video.m         моделирование КА без меток
```