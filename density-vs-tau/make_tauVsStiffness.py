import os
import csv
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import seaborn as sns
from scipy import stats
import pandas as pd
mpl.rcParams['pdf.fonttype'] = 42

plt.close('all')

sns.set_style('ticks', {'axes.edgecolor': '0.0',
                        'xtick.direction': 'in',
                        'ytick.direction': 'in',
                        'xtick.position': 'both'})

filepath = os.path.join(os.sep, 'Users', 'Danny', 'Dropbox',
                        'Manuscript_WoundHealing', 'Figure1_Ablate',
                        'tau_vs_stiffness')


filename = 'Tau_vs_Stiffness.xlsx'

df = pd.read_excel(os.path.join(filepath, filename),
                   index_col=None, na_values=['NA'], parse_cols="A,B")

df.columns = ['stiffness', 'tau']

df = df.dropna()

# convert densities from um^-2 to mm^-2
slope, intercept, rvalue, pvalue, stderr = stats.linregress(df['stiffness'],
                                                            df['tau'])
statDict = {'slope': slope,
            'intercept': intercept,
            'r-squared': rvalue**2,
            'p-value': pvalue,
            'stderr': stderr}

# Plot points according to stiffness
means = df.groupby('stiffness').mean()
stds = df.groupby('stiffness').std()
sns.lmplot('stiffness', 'tau', data=df, fit_reg=False, hue='stiffness',
           palette='viridis', x_jitter=0.3, legend=False,
           scatter_kws={'s': 200})

sns.despine(top=False, right=False)

ax1 = plt.gca()
# Plot fitted line
xx = np.linspace(df['stiffness'].min(), df['stiffness'].max(), 500)
ax1.plot(xx, xx * slope + intercept, '--k')

plt.legend()
ax1.set_xlabel('E (kPa)')
ax1.set_ylabel(r'$\tau_0 \; (s)$')
plt.savefig(os.path.join(filepath, 'tauVsStiffness.pdf'), transparent=True)

plt.show()
