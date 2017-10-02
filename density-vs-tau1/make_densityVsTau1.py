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
                        'Manuscript_WoundHealing', 'Figure1_Ablate',
                        'density_tau_stiffness_scatter')
filename = 'Retraction_Masterfile_MM.xlsx'

df = pd.read_excel(os.path.join(filepath, filename), index_col=None,
                   na_values=['NA'], parse_cols="B,H,P")

df.columns = ['stiffness', 'tau1', 'density']

df = df.dropna()

# convert densities from um^-2 to mm^-2
df['density'] *= 1e6

slope, intercept, rvalue, pvalue, stderr = stats.linregress(df['density'],
                                                            df['tau1'])
xx = np.linspace(df['density'].min(), df['density'].max(), 500)

fig, ax1 = plt.subplots()
fig.set_size_inches(6, 6)
ax1.plot(xx, xx * slope + intercept, '--k')
ax1.text(5900, 25, 'p = %.3f' % pvalue)
colors = sns.color_palette("viridis", 5)

for index, (stiffness, data) in enumerate(df.groupby('stiffness')):
    ax1.plot(data['density'], data['tau1'], 'o', label=stiffness,
             color=colors[index], markeredgewidth=0, markersize=20)

plt.legend()
ax1.set_xlabel(r'$density \; (cells/mm^2$)')
ax1.set_ylabel(r'$\tau_1 \; (s)$')
plt.savefig(os.path.join(filepath, 'densityVsTau1.pdf'), transparent=True)

plt.show()
