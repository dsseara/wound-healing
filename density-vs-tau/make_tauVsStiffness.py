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
                        'ytick.direction': 'in'})

filepath = os.path.join(os.sep, 'Users', 'Danny', 'Dropbox',
                        'Manuscript_WoundHealing', 'Figure1_Ablate',
                        'tau_vs_stiffness')


filename = 'Tau_vs_Stiffness.xlsx'

df = pd.read_excel(os.path.join(filepath, filename),
                   index_col=None, na_values=['NA'], parse_cols="A,B")

df.columns = ['stiffness', 'tau']

df = df.dropna()
byStiffness = df.groupby('stiffness')

# convert densities from um^-2 to mm^-2
slope, intercept, rvalue, pvalue, stderr = stats.linregress(df['stiffness'],
                                                            df['tau'])
statDict = {'slope': slope,
            'intercept': intercept,
            'r-squared': rvalue**2,
            'p-value': pvalue,
            'stderr': stderr}

# Plot points according to stiffness
means = byStiffness.mean()
stds = byStiffness.std()
fig, ax = plt.subplots(figsize=(6, 6))

ax.errorbar(means.reset_index()['stiffness'], means['tau'], yerr=stds['tau'],
            fmt='ko', markersize=20, markeredgewidth=2, capsize=15)

# Plot fitted line
xx = np.linspace(df['stiffness'].min(), df['stiffness'].max(), 500)
ax.plot(xx, xx * slope + intercept, '--k')

ax.set_xlabel('E (kPa)')
ax.set_ylabel(r'$\tau_0 \; (s)$')
ax.set_ylim([2, 45])
plt.savefig(os.path.join(filepath, 'tauVsStiffness.pdf'), transparent=True)

plt.show()
