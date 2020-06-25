import datetime as dt

def matlab2datetime(matlab_datenum):
    day = dt.datetime.fromordinal(int(matlab_datenum))
    dayfrac = dt.timedelta(days=matlab_datenum%1) - dt.timedelta(days = 366)
    date = day + dayfrac
    return date.replace(second=0, microsecond=0, minute=0, hour=date.hour)