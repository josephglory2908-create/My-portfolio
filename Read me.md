# Hotel bookings Power BI report

Open **Hotel Bookings.pbip** in Power BI Desktop, then select **Home > Refresh** to load the included CSV. Two report pages contain interactive charts and hotel/year filters. Save as PBIX after refresh if a single-file report is preferred.

The data source points to the included CSV at its current local location. If you move the folder, update File.Contents in Transform data > Advanced Editor.

## Metric definitions

- Bookings: `COUNTROWS(Bookings)`
- Canceled Bookings: `CALCULATE([Bookings], Bookings[is_canceled] = 1)`
- Cancellation Rate: `DIVIDE([Canceled Bookings], [Bookings])`
- Completed Stays: `CALCULATE([Bookings], Bookings[reservation_status] = "Check-Out")`
- Average ADR: `AVERAGE(Bookings[adr])`
- Average Lead Days: `AVERAGE(Bookings[lead_time])`
- Average Stay Nights: `AVERAGE(Bookings[Total Nights])`
- Completed Room Nights: `CALCULATE(SUM(Bookings[Total Nights]), Bookings[reservation_status] = "Check-Out")`

## Data notes

All 119,390 source rows are retained; identical rows are not assumed to be duplicate bookings. Source NULL country values become Unknown. Missing children, agent and company remain blank. Booking counts count source rows because there is no booking ID. ADR is an unweighted booking-level mean in unspecified source currency units; unusual and negative ADR values are retained. Completed stays use reservation_status = Check-Out. No occupancy or actual revenue is inferred. Arrival coverage is July 2015 through August 2017; do not compare partial-year totals as full years.

## Source checks

```json
{
  "bookings": 119390,
  "canceled": 44224,
  "cancellation_rate": 0.37041628277075134,
  "average_adr": 101.83112153446687,
  "average_nights": 3.4279001591423066,
  "completed": 75166,
  "date_min": "2015-07-01 00:00:00",
  "date_max": "2017-08-31 00:00:00"
}
```

Power BI project format: https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-report
