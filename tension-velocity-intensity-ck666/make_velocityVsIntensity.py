import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import seaborn as sns
from scipy import stats
import pandas as pd
mpl.rcParams['pdf.fonttype'] = 42

sns.set_style('ticks', {'axes.edgecolor': '0.0',
                        'xtick.direction': 'in',
                        'ytick.direction': 'in',
                        'xtick.position': 'both'})

filepath = os.path.join(os.sep, 'Users', 'Danny', 'Dropbox',
                        'Manuscript_WoundHealing', 'Figure5_Transition',
                        'PartX_CK666Ring')
filename = 'Stress_20170214_CK666.xlsx'

df = pd.read_excel(os.path.join(filepath, filename), sheetname='Actin_12.2kPa_CK666_20170214',
                   index_col=None, na_values=['NA'], parse_cols="E,w")

df.columns = ['intensity', 'velocity']

df = df.dropna()

slope, intercept, rvalue, pvalue, stderr = stats.linregress(df['intensity'],
                                                            df['velocity'])

fig, ax = plt.subplots()
ax.plot(df['intensity'], df['velocity'], 'ko')
ax.set_xlabel(r'$I_{actin}$')
ax.set_ylabel(r'$v (\mu m /min)$')
print(pvalue)
plt.show()
