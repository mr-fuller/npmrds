select

percentile_disc(0.5) within group (order by am_peak_lottr_2017) as amp_2017_median,
percentile_disc(0.5) within group (order by midday_lottr_2017) as midd_2017_median,
percentile_disc(0.5) within group (order by pm_peak_lottr_2017) as pmp_2017_median,
percentile_disc(0.5) within group (order by lottr_we_2017) as we_2017_median,

percentile_disc(0.5) within group (order by am_peak_lottr_2016) as amp_2016_median,
percentile_disc(0.5) within group (order by midday_lottr_2016) as midd_2016_median,
percentile_disc(0.5) within group (order by pm_peak_lottr_2016) as pmp_2016_median,
percentile_disc(0.5) within group (order by lottr_we_2016) as we_2016_median,

percentile_disc(0.5) within group (order by am_peak_lottr_2015) as amp_2015_median,
percentile_disc(0.5) within group (order by midday_lottr_2015) as midd_2015_median,
percentile_disc(0.5) within group (order by pm_peak_lottr_2015) as pmp_2015_median,
percentile_disc(0.5) within group (order by lottr_we_2015) as we_2015_median,

percentile_disc(0.5) within group (order by am_peak_lottr_2014) as amp_2014_median,
percentile_disc(0.5) within group (order by midday_lottr_2014) as midd_2014_median,
percentile_disc(0.5) within group (order by pm_peak_lottr_2014) as pmp_2014_median,
percentile_disc(0.5) within group (order by lottr_we_2014) as we_2014_median,

percentile_disc(0.5) within group (order by am_peak_lottr_2013) as amp_2013_median,
percentile_disc(0.5) within group (order by midday_lottr_2013) as midd_2013_median,
percentile_disc(0.5) within group (order by pm_peak_lottr_2013) as pmp_2013_median,
percentile_disc(0.5) within group (order by lottr_we_2013) as we_2013_median,

percentile_disc(0.5) within group (order by am_peak_lottr_2012) as amp_2012_median,
percentile_disc(0.5) within group (order by midday_lottr_2012) as midd_2012_median,
percentile_disc(0.5) within group (order by pm_peak_lottr_2012) as pmp_2012_median,
percentile_disc(0.5) within group (order by lottr_we_2012) as we_2012_median
from congestion_lottr;
