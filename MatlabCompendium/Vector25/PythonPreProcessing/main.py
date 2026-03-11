# >>>>>>>>>> Init <<<<<<<<<<
# import os
# from art import tprint
# from PIL import Image, ImageOps, ImageEnhance
import cv2
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from ultralytics import YOLO


N_exp = 1  # Номер эксперимента 
N_cam = 1  # Номер камеры
Output_video = False  # Надо ли делать видео с найденными боксами
Treshold = 0.3  # Порог уверенности в найденном шаре

# Raw files should be like "iss_exp1_cam1.MP4"
filename = f"videos/iss_exp{N_exp}_cam{N_cam}.MP4"
res_filename = f"result/res_exp{N_exp}_cam{N_cam}.mp4"
box_filename = f"result/boxes_new_{N_exp}_({N_cam}).txt"

# Load YOLO
model = YOLO('yolo_balls_11.pt')


# >>>>>>>>>> Find the balls <<<<<<<<<<
# Открытие исходного видеофайла
capture = cv2.VideoCapture(filename)

# Чтение параметров видео
fps = int(capture.get(cv2.CAP_PROP_FPS))
width = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
height = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))

# Настройка выходного файла
if Output_video:
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    writer = cv2.VideoWriter(res_filename, fourcc, fps, (width, height))

count = 0 
boxes_in_frames = []
f_balls = open(box_filename, 'w')
while True:
    # Захват кадра
    ret, frame = capture.read()
    count += 1
    print(f"Кадр {count}")
    if not ret: # or count > 20:
        break

    # Обработка кадра с помощью модели YOLO
    results = model(frame)[0]

    # Получение данных об объектах
    boxes_in_frame = []
    classes_names = results.names
    classes = results.boxes.cls.cpu().numpy()
    boxes = results.boxes.xyxy.cpu().numpy().astype(np.int32)
    # Рисование рамок и подписей на кадре
    for class_id, box, conf in zip(classes, boxes, results.boxes.conf):
        if conf > Treshold:
            class_name = classes_names[int(class_id)]
            color = colors[int(class_id) % len(colors)]
            x1, y1, x2, y2 = box
            boxes_in_frame += [box]
            if Output_video:
                cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
                cv2.putText(frame, class_name, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
    boxes_in_frames += [boxes_in_frame]

    # Запись положения найденного тела
    n = len(boxes_in_frame)
    txt = f"{n} "
    for i in range(n):
        for j in range(4):
            txt += f"{boxes_in_frame[i][j]} "
    f_balls.write(txt + "\n")

    # Запись обработанного кадра в выходной файл
    if Output_video:
        writer.write(frame)

# Освобождение ресурсов и закрытие окон
if Output_video:
    capture.release()
    writer.release()
f_balls.close()

# Отрисовка результатов, преобразование txt в csv
x,y = [], []
d = pd.DataFrame()
with open(box_filename, 'r') as f:
    for it, line in enumerate(f):
        l = line.split()
        d.loc[it, 'detected'] = int(l[0])
        if int(l[0]) > 0:
            d.loc[it, 'x0'] = int(float(l[1]))
            d.loc[it, 'y0'] = int(float(l[2]))
            d.loc[it, 'x1'] = int(float(l[3]))
            d.loc[it, 'y1'] = int(float(l[4]))
            x.append((float(l[1]) + float(l[3])) / 2)
            y.append((float(l[2]) + float(l[4])) / 2)
        else:
            d.loc[it, 'x0'] = 0
            d.loc[it, 'y0'] = 0
            d.loc[it, 'x1'] = 0
            d.loc[it, 'y1'] = 0
            x.append(0)
            y.append(0)
d.to_csv(fname.replace('txt','csv'))
plt.plot(x, label='x')
plt.plot(y, label='y')
plt.xlabel("Кадр")
plt.ylabel("Координаты центра ШТ")
plt.grid()
plt.legend()
plt.show()
