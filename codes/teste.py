#!/usr/bin/env python
# coding: utf-8

# Plot FchlxPAR SiMCosta SC01 (Carberry et al., 2019)

# Importando bibliotecas

import os
import glob
import numpy as np
import pandas as pd
import datetime as dt
import matplotlib.pyplot as plt
plt.ion()
import progressbar
import ephem
from pandas.plotting import register_matplotlib_converters
register_matplotlib_converters()
from dt_converter import matlab2datetime as dn2dt
from scipy.io import loadmat
from scipy.signal import find_peaks
from scipy import interpolate

from matplotlib.font_manager import FontProperties

fontP = FontProperties()
fontP.set_size('small')

###

# Definindo diretório para os dados
datadir = r"../data"
files = glob.glob(os.path.join(datadir,'*.csv'))
files

# Carregando dados SiMCosta
simcosta = pd.read_csv(os.path.join(datadir,files[0]), header=26, sep=',')
# lendo variáveis da planilha
fchl = simcosta['Median Fluo'][:16208]
qc_flu = simcosta['QC_Flu'][:16208] #índice filtros QARTOD
s_date = simcosta['Date (YYYY-MM-DD hh:mm:ss)'][:16208]
# selecionando dados de Fchl filtrados
qc_ok = np.where(qc_flu>1)[0] # Dados não aprovados pelos filtros
fchl[qc_ok]=np.nan # transformando dados nulos em NaNs
# formatando vetor tempo para pandas series
s_dates = pd.Series([dt.datetime.strptime("{}".format(s_date[k]),'%Y-%m-%d %H:%M:%S') for k in range(len(s_date))])
# Criando novo dataframe tempo e Fchl
df_sc=pd.DataFrame({'dt':s_dates,'flu':fchl})
# Retidando datas duplciadas
df_sc = df_sc.drop([15488,15493])
# Criando a série temporal horária sem falhas da boia.
times = pd.date_range('2017-02-22 17:00:00','2019-11-17 05:00:00', freq='60min')
# Criando dataframe com a série temporal horária como indice e preenchendo com nan as datas sem dados.
df_sc = df_sc.set_index('dt').reindex(times).fillna(np.nan).rename_axis('dt')
#df_sc = df_sc.set_index('dt')

# interpolando para o preenchimento de pequenos gaps
df_sc = df_sc.interpolate(method='time',limit=6,limit_area='inside',limit_direction='both')

# Lacuna de coletas
i1 = np.arange(3211,3358)
i2 = np.arange(3915,5421)
i3 = np.arange(6579,6837)
i4 = np.arange(8874,9022)
i5 = np.arange(11588,12189)
i6 = np.arange(13004,16609)
i7 = np.arange(18835,19991)
i8 = np.arange(21606,22703)

null_idx = np.sort([*i1,*i2,*i3,*i4,*i5,*i6,*i7,*i8])

df_sc.loc[null_idx,'flu']=np.nan

## SPIKE CRITICO NOS DADOS BRUTOS
df_sc.loc[16827,'flu']=np.nan
df_sc.loc[3122,'flu']=np.nan

# plot teste do conjunto de dados originais
plt.plot(df_sc['flu'],'k.')



# Carregando dados Inmet
inmet = pd.read_csv(os.path.join(datadir,files[1]), header=9, sep=',')
rad_head_list = list(inmet.columns[73:87])

# Criando lista com data e valores de radiância global
i_dates = []
rad = []
for day in range(53, 1036): # limites definidos para as datas de Fchl amostrados
    for header in rad_head_list:
        rad.append(inmet[header][day])
        d = inmet['Unnamed: 0'][day]
        t = str(int(inmet[header][0]))
        if len(t)==1:
            t = "00:0"+t
            date = dt.datetime.strptime("{} {}".format(d,t),'%d-%b-%Y %H:%M')
        elif len(t)==3:
            t = "0"+t[0]+":00"
            date = dt.datetime.strptime("{} {}".format(d,t),'%d-%b-%Y %H:%M')
        elif len(t)== 4:
            t = t[0:2]+":00"
            date = dt.datetime.strptime("{} {}".format(d,t),'%d-%b-%Y %H:%M')
        i_dates.append(date)

# criando dataframe com os valores de radiância global por tempo     
i_dates = pd.Series(i_dates)
df_in=pd.DataFrame({'dt':i_dates,'rad':rad})


df_in = df_in.set_index('dt').reindex(times).fillna(np.nan).rename_axis('dt')
#df_in = df_in.reset_index()

# substituindo valores nulos de rad por 0
idx = np.where(np.isnan(df_in['rad'])==True)[0]
df_in.rad[idx]=0

# aplicando fator de conversão de Radiação Global para PAR
df_in.rad = df_in.rad*0.48

# Plotando dados brutos

plt.scatter(df_in['rad'],df_sc['flu'],c=times.hour ,vmin=0, vmax=24, cmap="jet",s=2)
plt.grid()
plt.title("Point observations")
plt.xlabel("PAR")
plt.ylabel("Fchl")
cbar= plt.colorbar()
cbar.set_label("Hour of day", labelpad=+1)
plt.savefig(os.path.join(resdir,'fhcl_par.png'))

# Calculando os horários de crepusculo com a biblioteca ephem
# Criando o observador
boia      = ephem.Observer()
#Localização do observador
boia.lon  = str(-48.42101867)      #Note that lon should be in string format
boia.lat  = str(-27.27445333)      #Note that lat should be in string format
#Elevação do observador em metros
boia.elev = 0
# criando listas vazias para os vetores tempo e fchl para o período noturno
dn_dt = []
dn_flu = []
nh = []
# laço para cada passo de tempo da série temporal
bar = progressbar.ProgressBar(max_value=progressbar.UnknownLength)
for h in range(len(df_sc.index)):
    bar.update(h) # barra de progresso
    boia.date = df_sc.index[h].strftime("%Y-%m-%d") # dia da medição
    sunrise = boia.next_rising(ephem.Sun()) # horário do nascer do sol no dia
    sunset  = boia.next_setting(ephem.Sun()) #horário por do sol no dia
    
    if sunset.datetime()-dt.timedelta(hours=1)<=df_sc.index[h].to_pydatetime(): # seleção para os dados amostrados após o pôr do sol
        dn_dt.append(df_sc.index[h]) # adicionando os horários à lista tempo
        dn_flu.append(df_sc['flu'][h]) # adicionando os dados à lista de Fchl
        nh.append(h)
    if sunrise.datetime()+dt.timedelta(hours=1)>=df_sc.index[h].to_pydatetime(): # seleção para os dados amostrados antes do nascer do sol
        dn_dt.append(df_sc.index[h]) # adicionando os horários à lista tempo
        dn_flu.append(df_sc['flu'][h]) # adicionando os dados à lista de Fchl 
        nh.append(h)

os.system('cls') # limpando o display de resultados 
dn = pd.DataFrame({'dt':dn_dt,'flu':dn_flu}) # criando pandas  dataframe com os dados noturnos
max_night = dn.groupby(pd.Grouper(key='dt', freq='1D')).agg({'flu':[np.max]}) # agrupando os maiores valores por dia


# Corrigindo com a maré
# Carregando .mat com a previsão de maré elaborado pelo t-tide no matlab
dbpath = r'C:\Users\Queiroz\Documents\GitHub\Fchl_calibration\data\mare\mare_pedra\data'
mare_mat = loadmat(os.path.join(dbpath,'forecast_tide.mat'))

mare = pd.DataFrame({'elev':[],'dt':[]})

for t in range(len(mare_mat['mtime_prev'][0])):
    mare['dt'][t] = dn2dt(mare_mat['mtime_prev'][0][t])
    mare['elev'][t] = mare_mat['elev_prev'][0][t]

m_alta_idx, _ = find_peaks(mare.elev, height=-20)
m_baixa_idx, _ = find_peaks(mare.elev*-1, height=-20)
m_idx = np.sort([*m_alta_idx,*m_baixa_idx])

plt.plot(mare.dt,mare.elev,'k.-')
plt.plot(mare.dt[m_alta_idx],mare.elev[m_alta_idx],'bx')
plt.plot(mare.dt[m_baixa_idx],mare.elev[m_baixa_idx],'rx')
plt.savefig(os.path.join(resdir,'mare_prevista'))
### INDICE maré alta (an) e baixa (bn) com PAR menor que 300.
rad_idx = np.where(df_in.rad<300)[0]
an = np.sort(list(set(rad_idx)&set(m_alta_idx)))
bn = np.sort(list(set(rad_idx)&set(m_baixa_idx)))

n_idx = np.sort([*an,*bn])

#mare_df = df_sc.flu[n_idx].copy()

ndt = []
nfchl = []
for i in range(len(m_idx[:-1])):
    print(df_sc.index[m_idx[i]])
    A = (1/2)*(df_sc.flu[m_idx[i+1]]-df_sc.flu[m_idx[i]])
    midpoint = (df_sc.flu[m_idx[i+1]]+df_sc.flu[m_idx[i]])/2
    #for n in range(len(df_sc.flu[m_idx])):
    t1 = df_sc.index[m_idx[i]]
    t2 = df_sc.index[m_idx[i+1]]
    t = df_sc.index[m_idx[i]]+(t2-t1)/2
    nfchl.append(-A*np.cos(np.pi*(t-t1)/(t2-t1))+midpoint)
    ndt.append(df_sc.index[m_idx[i]])

#Fchl = pd.DataFrame({'dt':ndt,'fchl':nfchl})

# Figura 4 Carberry

fig, (ax1,ax2,ax3) = plt.subplots(3, 1,sharey=True,sharex=True,figsize=(8,8))

ax1.plot(df_sc.flu,
         marker='.',
         color='#B3B6B7',
         linestyle='',
         label=r'Raw F$_c$$_h$$_l$'
         )
ax1.plot(df_sc.flu[rad_idx],
         color='#17202A',
         marker='.',
         linestyle='',
         label=r'Nightly Raw F$_c$$_h$$_l$'
         )
ax1.set_ylabel(r'F$_c$$_h$$_l$ (mg/m³)')
ax1.grid()
ax1.legend()

ax2.plot(df_sc.flu,
         marker='.',
         color='#B3B6B7',
         linestyle='',
         label=r'Raw F$_c$$_h$$_l$'
         )
ax2.plot(df_sc.flu[m_alta_idx],
         marker='.',
         color='#1B4F72',
         linestyle='',
         label=r'High tide raw F$_c$$_h$$_l$'
         )
ax2.plot(df_sc.flu[m_baixa_idx],
         marker='.',
         color='#E74C3C',
         linestyle='',
         label=r'Low tide raw F$_c$$_h$$_l$'
         )
ax2.set_ylabel(r'F$_c$$_h$$_l$ (mg/m³)')
ax2.grid()
ax2.legend()

ax3.plot(df_sc.flu,
         marker='.',
         color='#B3B6B7',
         linestyle='',
         label=r'Raw F$_c$$_h$$_l$'
         )
ax3.plot(df_sc.flu[rad_idx],
         color='#17202A',
         marker='.',
         linestyle='',
         label=r'Nightly Raw F$_c$$_h$$_l$'
         )
ax3.plot(df_sc.flu[an],
         marker='.',
         color='#1B4F72',
         linestyle='-',
         label=r'High tide raw F$_c$$_h$$_l$'
         )
ax3.plot(df_sc.flu[bn],
         marker='.',
         color='#E74C3C',
         linestyle='-',
         label=r'Low tide raw F$_c$$_h$$_l$'
         )
ax3.set_ylabel(r'F$_c$$_h$$_l$ (mg/m³)')
ax3.set_xlabel('Date')
ax3.grid()
ax3.legend(prop=fontP)

fig.savefig(os.path.join(resdir,'Fig4_1_carberry'))

# interpolando resultados modelados
df_an = df_sc.flu[an].copy()
df_an = df_an.reindex(df_sc.index[m_alta_idx]).fillna(np.nan).rename_axis('dt')
df_an = df_an.interpolate(method='time',limit=3,limit_area='inside',limit_direction='both')
an_null = np.sort(list(set(times[null_idx])&set(df_an.index)))
df_an.loc[an_null]=np.nan

df_bn = df_sc.flu[bn].copy()
df_bn = df_bn.reindex(df_sc.index[m_baixa_idx]).fillna(np.nan).rename_axis('dt')
df_bn = df_bn.interpolate(method='time',limit=3,limit_area='inside',limit_direction='both')
bn_null = np.sort(list(set(times[null_idx])&set(df_bn.index)))
df_bn.loc[bn_null]=np.nan

df_nn = df_an.append(df_bn).sort_index()

df_fn = df_nn.copy()
df_fn = df_nn.reindex(times).fillna(np.nan).rename_axis('dt')
df_fn = df_fn.interpolate(method='linear',limit=12,limit_area='inside',limit_direction='both')
df_fn[null_idx]=np.nan

from matplotlib.font_manager import FontProperties

fontP = FontProperties()
fontP.set_size('small')

# Figura 5 Carberry
fig, (ax1,ax2,ax3,ax4) = plt.subplots(4, 1,sharey=True,sharex=True,figsize=(8,8))

ax1.plot(df_an,
         marker='o',
         color='blue',
         mfc='white',
         linestyle='',
         ms=4,
         label=r'Filled F$_c$$_h$$_l$ for high tide'
         )
ax1.plot(df_bn,
         marker='o',
         color='red',
         linestyle='',
         mfc='white',
         ms=4,
         label=r'Filled F$_c$$_h$$_l$ for low tide'    
         )
ax1.plot(df_sc.flu[m_alta_idx],
         marker='.',
         color='#104E8B',
         linestyle='--',
         ms=4,
         label=r'High tide raw F$_c$$_h$$_l$'
         )
ax1.plot(df_sc.flu[m_baixa_idx],
         marker='.',
         color='#8B1A1A',
         linestyle='--',
         ms=4,
         label=r'Low tide raw F$_c$$_h$$_l$'
         )
ax1.plot(df_sc.flu[an],
         marker='o',
         color='blue',
         linestyle='-',
         ms=4,
         label=r'Nightly raw F$_c$$_h$$_l$ at high tide'
         )
ax1.plot(df_sc.flu[bn],
         marker='o',
         color='red',
         linestyle='-',
         ms=4,
         label=r'Nightly raw F$_c$$_h$$_l$ at low tide'
         )
ax1.set_ylabel(r'F$_c$$_h$$_l$ (mg/m³)')
ax1.grid()
ax1.legend(loc='upper right', ncol=1,fancybox=True,shadow=True,prop=fontP)


ax2.plot(df_an,
         marker='o',
         color='blue',
         linestyle='',
         ms=4,
         label=r'New nightly F$_c$$_h$$_l$ at high tide'
         )
ax2.plot(df_bn,
         marker='o',
         color='red',
         linestyle='',
         ms=4,
         label=r'New nightly raw F$_c$$_h$$_l$ at low tide'
         )
ax2.plot(df_nn,
         marker='',
         color='#2E4053',
         linestyle='-',
         ms=4,
         label=r'New nightly F$_c$$_h$$_l$ tide corrected'
         )
ax2.set_ylabel(r'F$_c$$_h$$_l$ (mg/m³)')
ax2.grid()
ax2.legend(loc='upper right', ncol=1,fancybox=True,shadow=True,prop=fontP)

error  = df_sc.flu-df_fn
rmse = np.sqrt(((error) ** 2).mean())

ax3.plot(df_sc.flu,
         marker='o',
         color='#B3B6B7',
         mfc='w',
         linestyle='',
         label=r'Raw F$_c$$_h$$_l$'
         )
ax3.plot(df_sc.flu[rad_idx],
         marker='.',
         color='#17202A',
         linestyle='',
         label=r'Nightly Raw F$_c$$_h$$_l$'
         )
ax3.plot(df_fn,
         marker='',
         color='#1F618D',
         linestyle='-',
         label=r'Hourly modeled F$_c$$_h$$_l$'        
         )
ax3.fill_between(df_fn.index,df_fn-rmse,df_fn+rmse,color='#A9CCE3')
         # marker='.',
         # color='blue',
         # linestyle='-',
         # label=r'Hourly modeled F$_c$$_h$$_l$'        
         # )

ax3.set_ylabel(r'F$_c$$_h$$_l$ (mg/m³)')
ax3.grid()
ax3.legend(loc='upper right', ncol=1,fancybox=True,shadow=True,prop=fontP)

line = np.zeros(len(times))

ax4.plot(times,
         up,
         ls='--',
         color='#D7DBDD'
         )
ax4.plot(times,
         dw,
         ls='--',
         color='#D7DBDD'
         )
ax4.plot(error,
         marker='.',
         color='k',
         linestyle='',
         label=r'Error of F$_c$$_h$$_l$'
         )
ax4.fill_between(times,
                 line+rmse,
                 line-rmse, 
                 color='#A9CCE3',
                 label=r'RMSE envelope' 
                 )
ax4.grid()
ax4.set_ylabel(r'Residual F$_c$$_h$$_l$ (mg/m³)')
ax4.legend(loc='upper right', ncol=1,fancybox=True,shadow=True,prop=fontP)
ax4.set_xlabel('Date')

fig.savefig(os.path.join(resdir,'Fig5_1_carberry'))

bar = progressbar.ProgressBar(max_value=progressbar.UnknownLength)
raw_ratio = []
cor_ratio = []
for i in range(len(df_fn)):
    bar.update(i)
    for index, row in max_night.iterrows():
        if df_fn.index[i].date() == index.date():
            tmp_raw = df_sc.flu[i]/max_night['flu']['amax'][index]
            tmp_cor = df_fn[i]/max_night['flu']['amax'][index]
    raw_ratio.append(tmp_raw)
    cor_ratio.append(tmp_cor)    
    os.system('cls')

df_ratio = pd.DataFrame({'dt':times,'raw_ratio':raw_ratio,'cor_ratio':cor_ratio})

df_ratio.to_csv(r'..\data\all_ratios_fchl.csv')


fig, ax = plt.subplots(1, 1,figsize=(7,5))
cs=ax.scatter(df_in['rad'],df_ratio['raw_ratio'],c=times.hour ,vmin=0, vmax=24, cmap="jet",s=5)
ax.grid()
plt.title("Points of observations")
ax.set_xlabel("PAR")
ax.set_ylabel(r"$\frac{Raw F_chl}{nightly max F_chl}$")
cbar = plt.colorbar(cs)
cbar.set_label("Hour of day")#, labelpad=+1)
fig.savefig(os.path.join(resdir,'raw_ratio_PAR.png'))

df_ratio.loc[16827,'cor_ratio']=np.nan

fig, ax = plt.subplots(1, 1,figsize=(7,5))
cs=ax.scatter(df_in['rad'],df_ratio['cor_ratio'],c=times.hour ,vmin=0, vmax=24, cmap="jet",s=5)
ax.grid()
plt.title("Points of observations")
ax.set_xlabel("PAR")
ax.set_ylabel(r"$\frac{Corrected F_chl}{nightly max F_chl}$")
cbar = plt.colorbar(cs)
cbar.set_label("Hour of day")#, labelpad=+1)
fig.savefig(os.path.join(resdir,'cor_ratio_PAR.png'))

dfr= df_ratio.set_index('dt')

# Agrupando por horário do dia
a = dfr['cor_ratio'].groupby(dfr.index.hour).describe()

fig, ax = plt.subplots()
ax.bar(a.index,a['mean'],
       yerr=a['std'],
       align='center',
       alpha=0.5,
       color='gray',
       ecolor='black',
       capsize=5
       )
ax.set_ylabel(r"$\frac{Corrected F_chl}{nightly max F_chl}$")
ax.set_xlabel(r"Hour of Day")

b = dfr['raw_ratio'].groupby(dfr.index.hour).describe()

fig, ax = plt.subplots()
ax.bar(b.index,b['mean'],
       yerr=b['std'],
       align='center',
       alpha=0.5,
       color='gray',
       ecolor='black',
       capsize=5
       )
ax.set_ylabel(r"$\frac{Raw F_chl}{nightly max F_chl}$")
ax.set_xlabel(r"Hour of Day")


fig, ax = plt.subplots(1, 1,figsize=(7,5))
cs=ax.scatter(df_sc['flu'],dfr['cor_ratio'],c=times.hour ,vmin=0, vmax=24, cmap="jet",s=5)
ax.grid()
plt.title("Points of observations")
ax.set_xlabel(r"Raw F$_c$$_h$$_l$")
ax.set_ylabel(r"Corrected F$_c$$_h$$_l$")
cbar = plt.colorbar(cs)
cbar.set_label("Hour of day")#, labelpad=+1)
fig.savefig(os.path.join(resdir,'cor_x_raw.png'))


#Salvando csv com dados brutos para matchup
Lon = np.zeros(len(times))-48.42101867
Lat = np.zeros(len(times))-27.27445333
Station = []
Date = []
Time = []
for k in range(len(dfr)):
    Station.append('SiMCosta-SC01')
    Date.append(dfr.index[k].strftime('%m/%d/%Y'))
    Time.append(dfr.index[k].strftime('%H:%M'))


#fluo = flu_fil[ff_idx[0]].reset_index()
dataset = pd.DataFrame({'Lon':Lon,'Lat':Lat,'Date':Date,'Time':Time,'Station':Station,'Fchl':dfr.cor_ratio})
#dataset = dataset.interpolate(method='linear',limit=12,limit_area='inside',limit_direction='both')
dataset.to_csv('simcosta_fluor_corrected_for_matchup.csv',sep=',',index=False)

