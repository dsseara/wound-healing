import os
import io
import csv
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
                        'tau1_vs_stiffness')
filename = 'Tau_vs_stiffness.xlsx'

df = pd.read_excel(os.path.join(filepath, filename), index_col=None,
                   na_values=['NA'], parse_cols='A,B')

df.columns = ['stiffness', 'tau1']

df = df.dropna()

slope, intercept, rvalue, pvalue, stderr = stats.linregress(df['stiffness'],
                                                            df['tau1'])


sns.lmplot(x='stiffness', y='tau1', data=df, hue='stiffness', fit_reg=False,
           palette="viridis", x_jitter=0.4, legend_out=False, x_ci='sd',
           scatter_kws={'edgecolors': 'none',
                        's': 200})
ax = plt.gca()
sns.regplot(x='stiffness', y='tau1', data=df, ax=ax, scatter=False, color='k')

sns.despine(top=False, right=False)

ax.set_ylabel(r'$\tau_1$')
ax.set_xlabel('E (kPa)')
ax.text(7, 35, 'p={pval:.3f}'.format(pval=pvalue))

statDict = {'slope': slope,
            'intercept': intercept,
            'r-squared': rvalue**2,
            'p-value': pvalue,
            'stderr': stderr}

# Save the fit data to a csv file
with open(os.path.join(filepath, 'fitSummary.csv'), 'w') as csv_file:
    w = csv.DictWriter(csv_file, statDict.keys())
    w.writeheader()
    w.writerow(statDict)

# Save the figure
plt.savefig(os.path.join(filepath, 'tau1VsStiffness.pdf'), transparent=True)
plt.show()
