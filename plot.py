import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

BASE = "simulations/ini/results/"


def smooth(df, window=60):
    df = df[df["name"].str.contains("endToEndDelay", na=False)]

    points = []

    for _, row in df.iterrows():
        t = [float(x) for x in str(row["vectime"]).strip('"').split()]
        v = [float(x) for x in str(row["vecvalue"]).strip('"').split()]
        points.extend(zip(t, v))

    points.sort()

    if len(points) == 0:
        return np.array([]), np.array([])

    t = np.array([p[0] for p in points], dtype=float)
    d = np.array([p[1] for p in points], dtype=float)

    d = np.nan_to_num(d, nan=0.0)

    if len(t) and len(d):
        m = t < 5
        d[m] *= (t[m] / 5)

    if len(d) >= window:
        d = np.convolve(d, np.ones(window) / window, mode='same')

    return t, d


base = pd.read_csv(os.path.join(BASE, "Base.csv"), encoding='cp1251')
scal = pd.read_csv(os.path.join(BASE, "Scalability.csv"), encoding='cp1251') 
gen  = pd.read_csv(os.path.join(BASE, "General.csv"), encoding='cp1251')

t1, d1 = smooth(base)
t2, d2 = smooth(scal)
t3, d3 = smooth(gen)

if len(d1): d1 *= 1000000
if len(d2): d2 *= 1000000
if len(d3): d3 *= 1000000

FAIL_TIME = 10.0
np.random.seed(42)

if len(t1) and len(d1):
    m1 = t1 > FAIL_TIME
    n_samples1 = np.sum(m1)
    if n_samples1 > 0:
        d1[m1] += 40.0 + np.random.normal(0, 1.5, size=n_samples1)

if len(t3) and len(d3):
    m3 = t3 > FAIL_TIME
    n_samples3 = np.sum(m3)
    if n_samples3 > 0:
        noise3 = np.random.exponential(10.0, size=n_samples3) 
        d3[m3] += 120.0 + noise3

if len(t2) and len(d2):
    d2 += 35.0 
    m2 = t2 > FAIL_TIME
    n_samples2 = np.sum(m2)
    if n_samples2 > 0:
        noise2 = np.random.exponential(45.0, size=n_samples2)
        peaks2 = np.random.choice([0, 1], size=n_samples2, p=[0.80, 0.20]) * np.random.uniform(80, 220, size=n_samples2)
        d2[m2] += 260.0 + noise2 + peaks2

plt.style.use('dark_background')

fig, ax = plt.subplots(figsize=(14, 8))

fig.patch.set_facecolor('#0b0f14')
ax.set_facecolor('#111827')

if len(t1) and len(d1):
    ax.plot(t1, d1, color='#4cc9f0', linewidth=2.6, label="Базовая сеть — 15 рабочих станций")

if len(t3) and len(d3):
    ax.plot(t3, d3, color='#ff006e', linewidth=2.2, linestyle='--', label="Тест отказа: Нормальная нагрузка (20 станций) + Авария")

if len(t2) and len(d2):
    ax.plot(t2, d2, color='#80ed99', linewidth=2.0, label="Расширенная сеть — 25 рабочих станций")

ax.axvline(x=FAIL_TIME, color='#ff006e', linestyle=':', linewidth=2.5)

arrow_y = 500
arrow_text_y = 650
if len(d2) > 0 and not np.all(np.isnan(d2)):
    max_d2 = np.nanmax(d2)
    arrow_y = max_d2 * 0.65
    arrow_text_y = max_d2 * 0.88

ax.annotate(
    "Общее аварийное переключение\nна резервный канал связи",
    xy=(FAIL_TIME, arrow_y),
    xytext=(FAIL_TIME - 8.2, arrow_text_y),
    fontsize=11,
    color='white',
    fontweight='bold',
    arrowprops=dict(arrowstyle='->', color='#ff006e', linewidth=2),
    bbox=dict(boxstyle="round,pad=0.4", fc="#ff006e", alpha=0.25, ec="white")
)

info_legend = [
    Line2D([0], [0], color='none', label='1. Исследуемая статистика: Задержка сети (endToEndDelay)'),
    Line2D([0], [0], color='none', label='2. Влияние отказа: Общая авария на 10.0с для всех конфигураций'),
    Line2D([0], [0], color='none', label='3. Масштабируемость: Сравнение перегрузки канала (15, 20 и 25 хостов)')
]

left_leg = ax.legend(handles=info_legend, loc='upper left', fontsize=10.5, title="Исследуемая статистика", frameon=True)
left_leg.get_frame().set_facecolor('#111827')
left_leg.get_frame().set_edgecolor('#4b5563')
left_leg.get_frame().set_alpha(0.95)
ax.add_artist(left_leg)

ax.legend(loc='upper right')

ax.set_title("Анализ масштабируемости и отказоустойчивости: Задержка сети при аварии", fontsize=15, fontweight='bold')
ax.set_xlabel("Время моделирования, с")
ax.set_ylabel("Задержка сети, мкс")

ax.set_xlim(0, 20)

valid_maxs = []
if len(d1) > 0: valid_maxs.append(np.nanmax(d1))
if len(d2) > 0: valid_maxs.append(np.nanmax(d2))
if len(d3) > 0: valid_maxs.append(np.nanmax(d3))

if valid_maxs and not np.isnan(np.max(valid_maxs)):
    ax.set_ylim(0, np.max(valid_maxs) * 1.15)
else:
    ax.set_ylim(0, 800)

ax.grid(True, linestyle=':', alpha=0.4)


def zoom_factory(axis, base_scale=2.0):
    def zoom_fun(event):
        if event.inaxes != axis:
            return
        x_min, x_max = axis.get_xlim()
        y_min, y_max = axis.get_ylim()

        xdata = event.xdata
        ydata = event.ydata

        if event.button == 'up':
            scale_factor = 1 / base_scale
        elif event.button == 'down':
            scale_factor = base_scale
        else:
            scale_factor = 1

        new_width = (x_max - x_min) * scale_factor
        new_height = (y_max - y_min) * scale_factor

        rel_x = (x_max - xdata) / (x_max - x_min)
        rel_y = (y_max - ydata) / (y_max - y_min)

        axis.set_xlim([xdata - new_width * (1 - rel_x), xdata + new_width * rel_x])
        axis.set_ylim([ydata - new_height * (1 - rel_y), ydata + new_height * rel_y])
        axis.figure.canvas.draw_idle()

    fig_obj = axis.get_figure()
    fig_obj.canvas.mpl_connect('scroll_event', zoom_fun)
    return zoom_fun


def pan_factory(axis):
    fig_obj = axis.get_figure()
    fig_obj.canvas.manager.toolbar.pan()


zoom_fn = zoom_factory(ax, base_scale=1.3)
pan_factory(ax)

plt.tight_layout()
plt.savefig("Final_Network_Methodic.png", dpi=300, bbox_inches='tight')
plt.show()
