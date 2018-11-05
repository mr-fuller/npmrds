select

percentile_disc(0.5) within group (order by amp_dwdm_pct_2017) as amp_dwdm_pct_2017_median,
percentile_disc(0.5) within group (order by midday_dwdm_pct_2017) as midd_dwdm_pct_2017_median,
percentile_disc(0.5) within group (order by pmp_dwdm_pct_2017) as pmp_dwdm_pct_2017_median,
percentile_disc(0.5) within group (order by we_dwdm_pct_2017) as we_dwdm_pct_2017_median,

percentile_disc(0.5) within group (order by amp_dwdm_pct_2016) as amp_dwdm_pct_2016_median,
percentile_disc(0.5) within group (order by midday_dwdm_pct_2016) as midd_dwdm_pct_2016_median,
percentile_disc(0.5) within group (order by pmp_dwdm_pct_2016) as pmp_dwdm_pct_2016_median,
percentile_disc(0.5) within group (order by we_dwdm_pct_2016) as we_dwdm_pct_2016_median,

percentile_disc(0.5) within group (order by amp_dwdm_pct_2015) as amp_dwdm_pct_2015_median,
percentile_disc(0.5) within group (order by midday_dwdm_pct_2015) as midd_dwdm_pct_2015_median,
percentile_disc(0.5) within group (order by pmp_dwdm_pct_2015) as pmp_dwdm_pct_2015_median,
percentile_disc(0.5) within group (order by we_dwdm_pct_2015) as we_dwdm_pct_2015_median,

percentile_disc(0.5) within group (order by amp_dwdm_pct_2014) as amp_dwdm_pct_2014_median,
percentile_disc(0.5) within group (order by midday_dwdm_pct_2014) as midd_dwdm_pct_2014_median,
percentile_disc(0.5) within group (order by pmp_dwdm_pct_2014) as pmp_dwdm_pct_2014_median,
percentile_disc(0.5) within group (order by we_dwdm_pct_2014) as we_dwdm_pct_2014_median,

percentile_disc(0.5) within group (order by amp_dwdm_pct_2013) as amp_dwdm_pct_2013_median,
percentile_disc(0.5) within group (order by midday_dwdm_pct_2013) as midd_dwdm_pct_2013_median,
percentile_disc(0.5) within group (order by pmp_dwdm_pct_2013) as pmp_dwdm_pct_2013_median,
percentile_disc(0.5) within group (order by we_dwdm_pct_2013) as we_dwdm_pct_2013_median,

percentile_disc(0.5) within group (order by amp_dwdm_pct_2012) as amp_dwdm_pct_2012_median,
percentile_disc(0.5) within group (order by midday_dwdm_pct_2012) as midd_dwdm_pct_2012_median,
percentile_disc(0.5) within group (order by pmp_dwdm_pct_2012) as pmp_dwdm_pct_2012_median,
percentile_disc(0.5) within group (order by we_dwdm_pct_2012) as we_dwdm_pct_2012_median
from passenger_dwdm;
