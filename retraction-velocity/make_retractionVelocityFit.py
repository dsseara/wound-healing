import os
import csv
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd
import scipy.optimize as optimize
import seaborn as sns
mpl.rcParams['pdf.fonttype'] = 42
mpl.rcParams['text.usetex'] = True
plt.close('all')

sns.set_style('ticks', {'axes.edgecolor': '0.0',
                        'xtick.direction': 'in',
                        'ytick.direction': 'in'})

# Change this for your computer -------------------------
dropboxpath = '/media/daniel/storage1/Dropbox/Manuscript_WoundHealing'
# -------------------------------------------------------

datafile = os.path.join(dropboxpath,
                        'Figure1_Ablate/prepfiles/New_Retraction_Vals.xlsx')
savepath = os.path.join(dropboxpath,
                        'Figure1_Ablate/retraction_velocity')


def strainRateKelvinVoigt(t, sigma0, E, eta):
    '''
    Strain rate of Kelvin-Voigt solid after experiencing a uniform
    stress for a long time, and then suddenly released
    de/dt (t) = sigma0/eta * exp(-E*t/eta)
    where sigma0 is uniform stress, E is Young's modulus, eta is viscosity,
    t is elapsed time
    '''
    return sigma0 / eta * np.exp(-E * t / eta)


data = pd.read_excel(datafile,
                     skiprows=1,
                     parse_cols='B,C',
                     header=0)

data.columns = ['time', 'velocity']
data = data.dropna()

coeffs, cov = optimize.curve_fit(strainRateKelvinVoigt,
                                 data.time[3:],
                                 data.velocity[3:])

# Calculate r-squared value
residuals = data.velocity - strainRateKelvinVoigt(data.time, *coeffs)
ss_res = np.sum(residuals**2)
ss_tot = np.sum((data.velocity - data.velocity.mean())**2)
r_squared = 1 - (ss_res / ss_tot)

# Save the fit data to a csv file
fitDict = {'sigma0': coeffs[0],
           'E': coeffs[1],
           'eta': coeffs[2],
           'tau': coeffs[2] / coeffs[1],
           'r_squared': r_squared}

with open(os.path.join(savepath, 'fitSummary.csv'), 'w') as csv_file:
    w = csv.DictWriter(csv_file, fitDict.keys())
    w.writeheader()
    w.writerow(fitDict)

fig, ax = plt.subplots()

# Plot data
ax.plot(data.time, data.velocity, 'ko',
        alpha=1,
        markeredgewidth=0,
        label='data')

# Plot fit
ax.plot(data.time, strainRateKelvinVoigt(data.time, *coeffs), 'r--',
        linewidth=2,
        label='fit')

ax.set_xlabel(r'$t \; (s)$', fontsize=15)
ax.set_ylabel(r'$v \; (\mu m/s)$', fontsize=15)
ax.set_title(r'$\dot{\epsilon}(t) = A e^{-t/\tau}$')

# make axis square
x0, x1 = ax.get_xlim()
y0, y1 = ax.get_ylim()
ax.set_aspect((x1 - x0) / (y1 - y0))

# put in fit data
ax.text(90, 0.30, r'$R^2 = {:.2f}$'.format(r_squared), fontsize=12)
ax.text(90, 0.28,
        r'$\tau \equiv \eta/E ={:.3f} \; s$'.format(coeffs[2] / coeffs[1]),
        fontsize=12)
ax.text(90, 0.26,
        r'$A \equiv \sigma_0/\eta ={A:.2f} \; 1/s$'.format(A=coeffs[0] / coeffs[2]),
        fontsize=12)

plt.savefig(os.path.join(savepath, 'retractionVelocityFit.pdf'),
            transparent=True)
plt.show()
